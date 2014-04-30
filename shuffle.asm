# This file, shuffle.asm, holds the shuffle procedure.
# It expects $a0 to be the start f the range to shuffle
# and $a1 to be the length of the range to shuffle.
# It uses registers to save values that should be preserved
# across calls, so it does not adjust the stack pointer.

.data
RandID:   .word 1 # MARS allows multiple independent RNGs identified by ID
Unseeded: .word 1 # initially not seeded, set to 0 after seeding

.globl shuffle # allow procedure to be called by other files

.text
shuffle:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	# copy arguments before syscalls overwrite them
	move $t0, $a0 # start of range
	move $t1, $a1 # length of range

	# seed random generator from system time
	lw $t2, Unseeded
	beqz $t2, skip_seeding # only need to seed once
	sw $zero, Unseeded # don't seed next time
	li $v0, 30 # get system time
	syscall # time in $a0, $a1
	move $a1, $a0 # seed
	lw $a0, RandID
	li $v0, 40 # set seed
	syscall
	skip_seeding:

	# perform the shuffle
	mul $t2, $t1, 10 # will swap random indexes diff*10 times
	shuffle_loop:
	li $v0 42 # generate random int in range
	lw $a0, RandID
	move $a1, $t1 # from 0 to size of range
	syscall # $a0 is random in in range [0, $t1]
	beq $a0, $zero, shuffle_loop # no need to swap first byte with itself
	lb $t3, ($t0) # save first byte
	add $t4, $t0, $a0 # will acess nth byte
	lb $t5, ($t4)
	sb $t3, ($t4)
	sb $t5, ($t0)
	subi $t2, $t2, 1 # --$t2
	bgtz $t2, shuffle_loop # loop while $t2 > 0

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
