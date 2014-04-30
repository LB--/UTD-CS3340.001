# This file, main.asm, contains the main procedure.

.data
Welcome:    .asciiz "Welcome to Jumbline: MIPS Edition!\n\n"
CharPrompt: .asciiz "Do you want to play with 5, 6, or 7 letters?\n"
InvalidNum: .asciiz "You must enter either 5, 6, or 7 - try again.\n"
DictStart:  .asciiz "Identifying dictionary words...\n"
DictFound:  .asciiz "Dictionary words found.\n"
DictNone:   .asciiz "No dictionary words for these letters\n"
RandID:     .word 0 # MARS allows multiple independent RNGs identified by ID
AlphabetU:  .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
AlphabetL:  .asciiz "abcdefghijklmnopqrstuvwxyz"
Letters:    .space 8 # at most 7 letters plus null
LetterInfo: .asciiz "Your letters are: "
Newline:    .asciiz "\n"
Guess:      .space 8 # longest word is 7 letters, plus null

.globl main

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

	# call show_letters procedure
	jal show_letters

	# Get dictionary words
	li $v0, 4 # print string
	la $a0, DictStart
	syscall
	la $a0, Letters # first argument: address of range to shuffle
	la $a1, on_word # second argument: valid word callback
	jal parse_dictionary # call dictionary parsing procedure
	li $v0, 4 # print string
	la $a0, DictFound
	syscall

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

	# should store the word in a data structure somewhere
	# for testing, just prints the word
	li $v0, 4 # print string
	# $a0 already has word in it
	syscall
	la $a0, Newline
	syscall

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra