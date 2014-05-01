# This file, list.asm, holds procedures for dealing with singly linked lists.

.data
# songly-linked-list memory layout:
# pointer to user data
# pointer to next node

.globl list_new
.globl list_add
.globl list_get
.globl list_remove
.globl list_size

.text
list_new:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

list_add:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

list_get:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

list_remove:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

list_size:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
