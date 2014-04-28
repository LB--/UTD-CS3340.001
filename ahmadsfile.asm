.data
msg1:.asciiz "Welcome! How many letters would you like to start with? Either 5,6, or 7. "
msg1error: .asciiz "That's not a valid input"
msg2:.asciiz "Your letter combinations are: "
msg3:.asciiz "Can you guess a word that can be made using these letters?"
msg4:.asciiz "Sorry! That's incorrect!"
msg5:.asciiz"That's correct! great!"
msg6:.asciiz "Thank you for playing."
.text
.globl main
main:

li $v0,4
la $a0,msg1
syscall #print msg

li $v0,5
syscall #read
add $a0,$v0,$zero #User input will be in a0

jal wordgame #call wordgame

#***************
#ONE OF YALL GOTTA WRITE THiS WORDGAME FUNCTION^^^
#***************

add $a0,$v0,$zero  #Make sure final word is in v0 when you are ready
li $v0,4
syscall  #Print String

li $v0,10 #Exit
syscall