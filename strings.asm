# This file, strings.asm, has procedures for dealing with
# null-terminated strings.

.data
AlphabetU: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
AlphabetL: .asciiz "abcdefghijklmnopqrstuvwxyz"

.globl string_length
.globl string_copy_to_heap

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
