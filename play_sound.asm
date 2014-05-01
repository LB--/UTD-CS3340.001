# This simply just plays the sounds for correct and wrong answers
.data

tone: .byte 70 		# A# or Bb
duration: .byte 150 	# 150 milliseconds
volume: .byte 126	# max volume is 127

instrument1: .byte 16	# This is an Organ
instrument2: .byte 70 	# This is a Reed

.text
correct_sound:
li $v0, 33
la $a0, tone
lbu $a0, 0($a0) 	#loads the tone

la $a1, duration
lbu $a1, 0($a1) 	#loads duration in milliseconds

la $a2, instrument1
lbu $a2, 0($a2)     	#loads the instrument

la $a3, volume
lbu $a3, 0($a3)	   	#loads the volume

move $t2, $a0
move $t3, $a1
move $t4, $a2
move $t5, $a3

syscall

			# same as above except for the instrument
wrong_sound:
li $v0, 33
la $a0, tone
lbu $a0, 0($a0)

la $a1, duration
lbu $a1, 0($a1)

la $a2, instrument2
lbu $a2, 0($a2)

la $a3, volume
lbu $a3, 0($a3)

move $t2, $a0
move $t3, $a1
move $t4, $a2
move $t5, $a3

syscall
j end

end:
jr $ra