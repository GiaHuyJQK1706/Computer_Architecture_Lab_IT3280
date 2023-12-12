.text
	li $v0, 1 	# service 1 is print integer
	li $a0, 0x307 	# the interger to be printed is 0x307
	syscall 		# execute