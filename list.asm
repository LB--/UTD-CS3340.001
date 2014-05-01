# This file, list.asm, holds procedures for dealing with singly linked lists.
# $a0 for all list functions is address of pointer to node, usually root node

.data
# songly-linked-list memory layout:
# user data (may be pointer)
# pointer to next node

.globl list_add
.globl list_find_if
.globl list_remove_if
.globl list_size

.text
list_add:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # address of pointer to root node
	move $s1, $a1 # user data

	li $v0, 9 # allocate heap memory
	li $a0, 8 # two pointers
	syscall # $v0 contains address

	sw $s1, ($v0) # store user data

	move $t0, $s0 # address of pointer to node
	lw $t1, ($t0) # pointer to node
	add_loop:
	beqz $t1, after_add_loop # if null, done searching
	addi $t0, $t1, 4 # address of new pointer
	lw $t1 ($t0) # pointer to node
	j add_loop
	after_add_loop:

	sw $v0, ($t0) # store pointer at address

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

list_find_if:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # address of pointer to root node
	move $s1, $a1 # callback accepting $a0 as user data from node

	move $s2, $zero # eventual return value

	move $s3, $s0 # address of pointer to node
	lw $s4, ($s3) # pointer to node
	find_loop:
	beqz $s4, after_find_loop # if null, done searching
	lw $a0, ($s4) # load user data
	jalr $s1
	beqz $v0, keep_finding # not found if return is 0
	li $s2, 1 # found
	j after_find_loop
	keep_finding:
	addi $s3, $s4, 4 # address of new pointer
	lw $s4 ($s3) # pointer to node
	j find_loop
	after_find_loop:

	move $v0, $s2 # return value = $s2

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

list_remove_if:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # address of pointer to root node
	move $s1, $a1 # callback accepting $a0 as user data from node

	move $s3, $s0 # address of pointer to node
	remove_loop:
	lw $s4, ($s3) # pointer to node
	beqz $s4, after_remove_loop # if null, done searching
	lw $a0, ($s4) # load user data
	jalr $s1
	beqz $v0, keep_removing # not found if return is 0
	addi $s2, $s4, 4 # address of new pointer
	lw $s2, ($s2) # pointer to node
	sw $s2, ($s3) # skip current node
#	j remove_loop
	keep_removing:
	addi $s3, $s4, 4 # address of new pointer
	lw $s4 ($s3) # pointer to node
	j remove_loop
	after_remove_loop:

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

list_size:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # address of pointer to root node

	li $v0, 0 # return value, will be incremented
	move $t0, $s0 # address of pointer to node
	lw $t1, ($t0) # pointer to node
	search_loop:
	beqz $t1, after_search_loop # if null, done searching
	addi $t0, $t1, 4 # address of new pointer
	lw $t1 ($t0) # pointer to node
	addi $v0, $v0, 1 # ++$v0
	j search_loop
	after_search_loop:

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
