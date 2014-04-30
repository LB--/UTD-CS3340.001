# This file, list.asm, holds procedures for dealing with linked lists.
# All procedure names start with ll, as in Linked List.

.data

.globl ll_new
.globl ll_add
.globl ll_get
.globl ll_remove
.globl ll_size

.text
ll_new:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

ll_add:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

ll_get:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

ll_remove:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra

ll_size:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# ... work in progress...

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
