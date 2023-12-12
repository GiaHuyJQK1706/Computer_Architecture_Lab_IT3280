.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
# receive row and column of the key pressed, 0 if not key pressed
# Eg. equal 0x11, means that key button 0 pressed.
# Eg. equal 0x28, means that key button D pressed.
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.text
main: 
li 	$t1, IN_ADRESS_HEXA_KEYBOARD
li 	$t2, OUT_ADRESS_HEXA_KEYBOARD
li 	$t3, 0x01 # check row 4 with key C, D,E, F
li 	$t4, 0x02 # check row 4 with key C, D,E, F
li 	$t5, 0x04 # check row 4 with key C, D,E, F
li 	$t6, 0x08 # check row 4 with key C, D,E, F
li 	$t0, 0
polling: 
beq	$t0, 100, exit
sb 	$t3, 0($t1 ) # must reassign expected row
lb 	$a0, 0($t2) # read scan code of key button
bne	$a0, $zero, print

sb 	$t4, 0($t1 ) # must reassign expected row
lb 	$a0, 0($t2) # read scan code of key button
bne	$a0, $zero, print

sb 	$t5, 0($t1 ) # must reassign expected row
lb 	$a0, 0($t2) # read scan code of key button
bne	$a0, $zero, print

sb 	$t6, 0($t1 ) # must reassign expected row
lb 	$a0, 0($t2) # read scan code of key button
bne	$a0, $zero, print
j 	continue

print: 
li 	$v0, 34 # print integer (hexa)
syscall

continue:
addi 	$t0, $t0, 1

sleep: 	
li 	$a0, 1000 # sleep 1000ms
li 	$v0, 32
syscall
back_to_polling: 
j 	polling # continue polling
exit:

