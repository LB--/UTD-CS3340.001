# This file, sound.asm, has procedures for playing sounds to indicate
# right or wrong to the player.

.data
Pitch:       .word 70 # A# or Bb
Duration:    .word 1000 # milliseconds
Volume:      .word 126 # max volume is 127
Instrument:  .word 0 # Piano

.globl play_sound

.text
play_sound:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal save_to_stack

	move $s0, $a0 # boolean: answer correct?

	li $v0, 33 # MIDI out synchronous
	lw $a0, Pitch
	lw $a1, Duration
	lw $a2, Instrument
	lw $a3, Volume
	bnez $s0, do_syscall # if correct
	subi $a0, $a0, 12 # if incorrect, go down an octave
	do_syscall:
	syscall

	jal restore_from_stack
	lw $ra, ($sp)
	subi $sp, $sp, -4
	jr $ra
