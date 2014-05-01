# This file, strings.asm, has procedures for dealing with
# null-terminated strings.

.data
# these aren't used since MIPS has a fixed ASCII character set...otherwise they would be used
AlphabetU: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
AlphabetL: .asciiz "abcdefghijklmnopqrstuvwxyz"

.globl string_length
.globl string_copy_to_heap
.globl string_uppercase
.globl string_trim_end

.text
string_length: # get length of null-terminated string
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # string

	length_loop:
	lb $t0, ($a0)
	beqz $t0, after_length_loop # exit loop if null
	addi $a0, $a0, 1 # ++$a0
	j length_loop
	after_length_loop:

	sub $v0, $a0, $s0 # return value = $a0 - $s0

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

string_copy_to_heap: # copy given string to new place in heap
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # string

	jal string_length
	move $s1, $v0 # length of string

	li $v0, 9 # allocate heap memory
	addi $a0, $s1, 1 # include room for null
	syscall # $v0 contains address, will leave alone as return value

	move $t0, $v0
	copy_loop:
	lb $t1, ($s0)
	sb $t1, ($t0)
	beqz $t1, after_copy_loop
	addi $t0, $t0, 1 # ++$t0
	addi $s0, $s0, 1 # ++$s0
	j copy_loop
	after_copy_loop:

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

string_uppercase: # convert given string to upper-case in-place
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # the string to convert in-place

	convert_loop:
	lb $t0, ($s0)
	addi $s0, $s0, 1 # ++$s0
	beqz $t0, after_convert_loop # null
	blt $t0, 97, convert_loop # a
	bgt $t0, 122, convert_loop # z
	subi $t0, $t0, 32 # convert to uppercase
	sb $t0, -1($s0) # store back character
	j convert_loop
	after_convert_loop:

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

string_trim_end: # trim newline from end of given string in-place
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # the string to trim the end of

	trim_loop:
	lb $t0 ($s0)
	addi $s0, $s0, 1 # ++$s0
	beqz $t0, after_trim_loop # end at null
	bne $t0, 10, trim_loop # kep looping until newline
	sb $zero, -1($s0) # null-terminate
	after_trim_loop:

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
