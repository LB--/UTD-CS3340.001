# This file, dictionary.asm, contains procedures for processing the dictionary.
# For parse_dictionary, $a0 is the null-terminated string of characters that
# words must be made up of, and $a1 must be a callback procedure to be called
# for each suitable word. The callback procedure should expect the word
# as a null-terminated string adressed by $a0

# NOTICE: The diction file is specially formatted for these procedures.
# Newlines must be \n only and not \n\r and all words must be UPPER CASE.

.data
DictFile:  .asciiz "dictionary.txt"
FileError: .asciiz "!!! Error opening dictionary.txt !!!"
Word:      .space 8 # at most 7 characters plus null
LetterUse: .space 8 # used to track which letters have been used
Newline:   .ascii "\n"

.globl parse_dictionary

.text
parse_dictionary:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# copy arguments before syscalls overwrite them
	move $s0, $a0 # string of required characters
	move $s1, $a1 # callback procedure

	# open the file
	li $v0, 13 # open file
	la $a0, DictFile # filename
	move $a1, $zero # flags
	move $a2, $zero # mode (ignored)
	syscall # $v0 contains the file descriptor
	move $s2, $v0
	bgez $s2, after_open_file # done, opened successfully
	# error - exit program
	li $v0, 4 # print string
	la $a0, FileError
	syscall
	li $v0, 17 # exit2
	li $a0, -1 # exit code
	syscall
	after_open_file:

	# read each word and invoke callback
	word_loop:
	la $t0, Word
	addi $t1, $t0, 8
	lb $t2, Newline
		read_loop:
		bge $t0, $t1, after_read_loop # prevent buffer overflows
		li $v0, 14 # read from file
		move $a0, $s2 # file descriptor
		move $a1, $t0 # where to store read characters
		li $a2, 1 # number of charactrs to read
		syscall # $v0 contains number of characters read
		blez $v0, after_word_loop # stop if no more characters
		lb $t3, ($t0)
		addi $t0, $t0, 1 # ++$t0
		bne $t3, $t2, read_loop # if not newline, keep looping
		after_read_loop:
	sb $zero, -1($t0)

	# check if the word uses only the letters given
	# first, clear the letter use flags
	la $t0, LetterUse
	sb $zero, 0($t0)
	sb $zero, 1($t0)
	sb $zero, 2($t0)
	sb $zero, 3($t0)
	sb $zero, 4($t0)
	sb $zero, 5($t0)
	sb $zero, 6($t0)
	sb $zero, 7($t0)
	la $t0, Word # get address of word
	# loop through the word
		check_loop:
		lb $t1, ($t0) # get current letter from word
		beqz $t1, after_check_loop # stop at end of word
		move $t2, $zero # loop index
		# loop through the usable characters
			use_loop:
			add $t3, $s0, $t2 # get current letter address
			lb $t3, ($t3) # get current letter
			add $t2, $t2, 1 # ++$t2
			beqz $t3, word_loop # stop after all letters
			bne $t3, $t1, use_loop # letters don't match, try next
			lb $t4, LetterUse($t2) # get current use flag
			bnez $t4, word_loop # can't use this word
			li $t4, 1 # set use flag
			sb $t4, LetterUse($t2) # this letter is used
			after_use_loop:
		add $t0, $t0, 1 # ++$t0
		j check_loop
		after_check_loop:
	# word is acceptable, invoke callback
	la $a0, Word # argument to callback
	jalr $s1 # invoke callback
	j word_loop
	after_word_loop:

	# close the file
	li $v0, 16 # close file
	move $a0, $s2 # file descriptor
	syscall

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
