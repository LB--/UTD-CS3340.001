# This file, main.asm, contains the main procedure.

.data
Welcome:    .asciiz "\n\n\nWelcome to Jumbline: MIPS Edition!\n\n"
CharPrompt: .asciiz "Do you want to play with 5, 6, or 7 letters?\n"
InvalidNum: .asciiz "You must enter either 5, 6, or 7 - try again.\n"
LetterInfo: .asciiz "Your letters are: "
Newline:    .asciiz "\n"
DictStart:  .asciiz "Identifying dictionary words"
DictFind:   .asciiz "."
DictFound:  .asciiz "\nDictionary words found.\n"
DictNone:   .asciiz "No dictionary words for these letters\n"
Prompt:     .asciiz "What do you want to do? 1 = rearrange letters, 2 = guess a word\n"
Reprompt:   .asciiz "Invalid option, 1 = rearrange letters, 2 = guess a word\n"
WordsA:     .asciiz "There are "
WordsB:     .asciiz " words of length "
ScoreIs:    .asciiz "Your score is currently "
BadGuess:   .asciiz "Sorry, that's not one of the words! Try again.\n"
GoodGuessA: .asciiz "Yep, that's a word! You get "
GoodGuessB: .asciiz " points.\n"
AlphabetU:  .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
RandID:     .word 0 # MARS allows multiple independent RNGs identified by ID
HasWords:   .word 0 # boolean: more than 0 words?
DictFail:   .word 0 # number of times dictionary failed
Score:      .word 0 # player's score
Letters:    .space 8 # at most 7 letters plus null
Guess:      .space 8 # longest word is 7 letters, plus null
# word lists:
Words3L:    .word 0 # null
Words4L:    .word 0 # null
Words5L:    .word 0 # null
Words6L:    .word 0 # null
Words7L:    .word 0 # null

.globl main # for MARS, do not invoke

.text
main:
	# display welcome message
	li $v0, 4 # print string
	la $a0, Welcome
	syscall

	new_game:	
	# display letter prompt
	li $v0, 4 # print string
	la $a0, CharPrompt
	syscall

	j get_num_letters

	get_num_letters_again:
	li $v0, 4 # print string
	la $a0, InvalidNum
	syscall

	get_num_letters:
	# get number of letters
	li $v0, 5 # read integer
	syscall # $v0 contains the integer
	blt $v0, 5, get_num_letters_again
	bgt $v0, 7, get_num_letters_again
	move $s0, $v0

	# seed random generator from system time
	li $v0, 30 # get system time
	syscall # time in $a0, $a1
	move $a1, $a0 # seed
	lw $a0, RandID
	li $v0, 40 # set seed
	syscall

	li $v0, 4 # print string
	la $a0, DictStart
	syscall

	generate_letters:
	move $t0, $s0
	sb $zero, Letters($t0) # add null terminator
	letter_loop:
	subi $t0, $t0, 1 # --$t0
	li $v0, 42 # generate random int in range
	lw $a0, RandID
	li $a1, 25 # alphabet 0-25
	syscall # $a0 is random int in [0, 25]

	lb $t1, AlphabetU($a0) # get random letter of alphabet
	sb $t1, Letters($t0) # insert into letters
	bgtz $t0, letter_loop # loop while $t0 > 0

	# Get dictionary words
	la $a0, Letters # first argument: address of letters
	la $a1, on_word # second argument: valid word callback
	jal parse_dictionary # call dictionary parsing procedure

	# retry if no words found, give up after 100 tries
	lw $t0, DictFail
	addi $t0, $t0, 1
	beq $t0, 100, end_main
	sw $t0, DictFail
	lw $t0, HasWords
	beqz $t0, generate_letters

	li $v0, 4 # print string
	la $a0, DictFound
	syscall

	jal show_letters
	jal show_wordcounts

	# ask user what they want to do
	user_choice:
	li $v0, 4 # print string
	la $a0, Prompt
	syscall
	j get_user_choice

	get_user_choice_again:
	li $v0, 4 # print string
	la $a0, Reprompt
	syscall

	get_user_choice:
	li $v0, 5 # read integer
	syscall # $v0 contains the integer
	beq $v0, 1, choice_1_shuffle
	beq $v0, 2, choice_2_guess
	j get_user_choice_again

	choice_1_shuffle:
	la $a0, Letters # first argument: address of range to shuffle
	move $a1, $s0 # second argument: length of range to shuffle
	jal shuffle
	jal show_letters
	j user_choice

	choice_2_guess:
	li $v0, 8 # read string
	la $a0, Guess # address of input buffer
	li $a1, 8 # size of buffer (will null pad)
	syscall # write to address pointed by $a0 in-place
	jal string_uppercase # convert string to uppercase in-place
	jal string_trim_end # trim end of string in-place
	jal string_length # $v0 is length of string
	move $s0, $v0
	beq $v0, 3, g3
	beq $v0, 4, g4
	beq $v0, 5, g5
	beq $v0, 6, g6
	beq $v0, 7, g7
	j bad_guess
	g3:
	la $a0, Words3L
	j after_g
	g4:
	la $a0, Words4L
	j after_g
	g5:
	la $a0, Words5L
	j after_g
	g6:
	la $a0, Words6L
	j after_g
	g7:
	la $a0, Words7L
	j after_g
	after_g:
	la $a1, if_guess_matches
	jal list_find_if # $v0 is boolean for if match found
	move $s1, $a0
	move $a0, $v0
	jal play_sound
	bnez $a0, good_guess

	bad_guess:
	li $v0, 4 # print string
	la $a0, BadGuess
	syscall
	j after_good_guess
	after_bad_guess:

	good_guess:
	move $a0, $s1
	jal list_remove_if
	li $v0, 4 # print string
	la $a0, GoodGuessA
	syscall
	li $v0, 1 # print integer
	move $a0, $s0
	syscall
	li $v0, 4 # print string
	la $a0, GoodGuessB
	syscall
	lw $t0, Score
	add $t0, $t0, $s0
	sw $t0, Score
	after_good_guess:

	jal show_letters
	jal show_wordcounts
	j user_choice

	end_main:
	# end of main - exit game program
	li $v0, 10 # exit
	syscall

show_letters: # internal procedure
	# inform user of chosen letters
	li $v0, 4 # print string
	la $a0, LetterInfo
	syscall
	la $a0, Letters
	syscall
	la $a0, Newline
	syscall
	jr $ra # return to calling code

show_wordcounts: # informs user of number of words of each length
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	la $a0, Words3L
	li $s1, 3
	jal do_show
	la $a0, Words4L
	li $s1, 4
	jal do_show
	la $a0, Words5L
	li $s1, 5
	jal do_show
	la $a0, Words6L
	li $s1, 6
	jal do_show
	la $a0, Words7L
	li $s1, 7
	jal do_show

	j after_do_show
	do_show:
	move $s0, $ra
	jal list_size
	move $s2, $v0
	bnez $s2, print_string
	jr $s0
	print_string:
	li $v0, 4 # print string
	la $a0, WordsA
	syscall
	li $v0, 1 # print integer
	move $a0, $s2
	syscall
	li $v0, 4 # print string
	la $a0, WordsB
	syscall
	li $v0, 1 # print integer
	move $a0, $s1
	syscall
	li $v0, 4 # print string
	la $a0, Newline
	syscall
	jr $s0
	after_do_show:

	li $v0, 4 # print string
	la $a0, ScoreIs
	syscall
	li $v0, 1, # print integer
	lw $a0, Score
	syscall
	li $v0, 4 # print string
	la $a0, Newline
	syscall

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

on_word: # callback procedure for parse_dictionary
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# $a0 already has word in it
	jal string_length
	move $s0, $v0 # length of string
	jal string_copy_to_heap
	move $s1, $v0 # address of string

	li $t0, 1 # more than 0 words
	sw $t0, HasWords

	# calculate which list to use
	beq $s0, 3, len3
	beq $s0, 4, len4
	beq $s0, 5, len5
	beq $s0, 6, len6
	beq $s0, 7, len7
	li $a0, 0 # should never reach this line
	j after_len
	len3:
	la $a0, Words3L
	j after_len
	len4:
	la $a0, Words4L
	j after_len
	len5:
	la $a0, Words5L
	j after_len
	len6:
	la $a0, Words6L
	j after_len
	len7:
	la $a0, Words7L
	j after_len
	after_len:
	move $a1, $s1 # list node data
	jal list_add

	li $v0, 4 # print string
	la $a0, DictFind
	syscall

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

if_guess_matches: # callback procesdure for list_find_if
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # string address

	la $s1, Guess

	li $v0, 1 # assume it is a match at first

	compare_loop:
	lb $t0, ($s0)
	lb $t1, ($s1)
	addi $s0, $s0, 1 # ++$s0
	addi $s1, $s1, 1 # ++$s1
	seq $t2, $t0, $zero
	seq $t3, $t1, $zero
	xor $t4, $t2, $t3
	beqz $t4, continue_compare # both not null or both null
	move $v0, $zero # mismatching lengths (strange)
	j after_compare_loop
	continue_compare:
	beqz $t0, after_compare_loop
	beq $t0, $t1, compare_loop
	move $v0, $zero # mismatching characters (normal)
	after_compare_loop:

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
