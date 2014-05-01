# This file, main.asm, contains the main procedure.

.data
Welcome:    .asciiz "Welcome to Jumbline: MIPS Edition!\n\n"
CharPrompt: .asciiz "Do you want to play with 5, 6, or 7 letters?\n"
InvalidNum: .asciiz "You must enter either 5, 6, or 7 - try again.\n"
LetterInfo: .asciiz "Your letters are: "
Newline:    .asciiz "\n"
DictStart:  .asciiz "Identifying dictionary words...\n"
DictFound:  .asciiz "Dictionary words found.\n"
DictNone:   .asciiz "No dictionary words for these letters\n"
Prompt:     .asciiz "What do you want to do? 1 = rearrange letters, 2 = guess a word\n"
Reprompt:   .asciiz "Invalid option, 1 = rearrange letters, 2 = guess a word\n"
AlphabetU:  .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
RandID:     .word 0 # MARS allows multiple independent RNGs identified by ID
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
	# initialize word lists
	la $a0, Words3L
	jal list_new
	la $a0, Words4L
	jal list_new
	la $a0, Words5L
	jal list_new
	la $a0, Words6L
	jal list_new
	la $a0, Words7L
	jal list_new

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
	li $v0, 4 # print string
	la $a0, DictStart
	syscall
	la $a0, Letters # first argument: address of letters
	la $a1, on_word # second argument: valid word callback
	jal parse_dictionary # call dictionary parsing procedure
	li $v0, 4 # print string
	la $a0, DictFound
	syscall

	jal show_letters

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
	syscall
	# ...work in progress...
	jal show_letters
	j user_choice

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

on_word: # callback procedure for parse_dictionary
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# $a0 already has word in it
	jal string_length
	move $s0, $v0 # length of string
	jal string_copy_to_heap
	move $s1, $v0 # address of string

	#

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
