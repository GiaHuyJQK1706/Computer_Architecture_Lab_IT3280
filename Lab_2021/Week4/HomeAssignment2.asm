#Laboratory Exercise 4, Home Assignment 2
.text
	li $s0, 0x0563 		# load test value for these function
	andi $t0, $s0, 0xff 	#Extract the LSB of $s0
	andi $t1, $s0, 0x0400 	#Extract bit 10 of $s0