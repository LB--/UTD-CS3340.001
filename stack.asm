# This file, stack.asm, contains helper procedures for other procedures.
# save_to_stack saves registers to the stack, and guess what restore_from_stack
# does. Neither affects the value of $ra, since that's how it knows where to
# jump back to the calling code. $ra has to be saved and restored manually.

.data

.globl save_to_stack
.globl restore_from_stack

.text
save_to_stack:
	addi $sp, $sp, -4
	 sw $a0, ($sp)
	addi $sp, $sp, -4
	 sw $a1, ($sp)
	addi $sp, $sp, -4
	 sw $a2, ($sp)
	addi $sp, $sp, -4
	 sw $a3, ($sp)
	addi $sp, $sp, -4
	 sw $s0, ($sp)
	addi $sp, $sp, -4
	 sw $s1, ($sp)
	addi $sp, $sp, -4
	 sw $s2, ($sp)
	addi $sp, $sp, -4
	 sw $s3, ($sp)
	addi $sp, $sp, -4
	 sw $s4, ($sp)
	addi $sp, $sp, -4
	 sw $s5, ($sp)
	addi $sp, $sp, -4
	 sw $s6, ($sp)
	addi $sp, $sp, -4
	 sw $s7, ($sp)
	jr $ra

restore_from_stack:
	lw $s7, ($sp)
	 subi $sp, $sp, -4
	lw $s6, ($sp)
	 subi $sp, $sp, -4
	lw $s5, ($sp)
	 subi $sp, $sp, -4
	lw $s4, ($sp)
	 subi $sp, $sp, -4
	lw $s3, ($sp)
	 subi $sp, $sp, -4
	lw $s2, ($sp)
	 subi $sp, $sp, -4
	lw $s1, ($sp)
	 subi $sp, $sp, -4
	lw $s0, ($sp)
	 subi $sp, $sp, -4
	lw $a3, ($sp)
	 subi $sp, $sp, -4
	lw $a2, ($sp)
	 subi $sp, $sp, -4
	lw $a1, ($sp)
	 subi $sp, $sp, -4
	lw $a0, ($sp)
	 subi $sp, $sp, -4
	jr $ra
