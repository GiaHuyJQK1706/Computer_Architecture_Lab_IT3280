.data
# declaring table
# postscript length = numberOfLines*3
postscript1:	.word		180,1,6000, 90,1,1500, 60,1,1000, 0,1,5000, 300,1,1000, 270,1,1500, 90,0,6500, 270,1,1500, 240,1,1000, 180,1,5000, 120,1,1000, 90,1,1500, 90,0,2500, 270,1,1500, 0,1,3000, 90,1,1500, 270,0,1500, 0,1,3000, 90,1,1500   
postscript1_length:	.word	57
postscript2:	.word		180,1,6000, 90,1,1500, 60,1,1000, 0,1,5000, 300,1,1000, 270,1,1500, 90,0,5000, 270,1,1500, 180,1,3000, 90,1,1500, 270,0,1500, 180,1,3000, 90,1,1500, 90,0,1500, 0,1,3000, 135,1,4200, 315,0,4200, 45,1,4200, 225,0,4200, 0,1,3000, 90,0,5000, 180,1,5500, 120,1,1000, 90,1,1000, 60,1,1000, 0,1,5500
postscript2_length:	.word	78
postscript3: 	.word		90,1,1500, 270,0,1500, 240,1,1000, 180,1,5000, 120,1,1000, 90,1,1500, 60,1,1000, 0,1,5000, 300,1,1000, 90,0,2500, 180,1,6000, 0,0,6000, 120,1,1500, 60,1,1500, 180,1,6000, 90,0,2000, 0,0,500, 0,1,5000, 60,1,1000, 90,1,1500, 120,1,1000, 180,1,1500, 0,0,1500, 300,0,1000, 270,0,1500, 240,0,1000, 180,0,5000, 120,1,1000, 90,1,1500, 60,1,1000, 0,1,1500, 270,0,1000, 90,1,2000 
postscript3_length:	.word	99

Msg:	.asciiz		"Invalid input for postscript!\n"
Msg1:	.asciiz		"You choose to print DCE!\n"
enter:	.asciiz		"\n"
Msg2:	.asciiz		"You choose to print DEKU!\n"
Msg3: 	.asciiz		"You choose to print OMG!\n"
space:	.asciiz		" "

.eqv 	IN_ADDRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv 	OUT_ADDRESS_HEXA_KEYBOARD 	0xFFFF0014 

.eqv 	HEADING 	0xffff8010 	# Integer: An angle between 0 and 359
					# 0 : North (up)
					# 90: East (right)
					# 180: South (down)
					# 270: West (left)
.eqv	MOVING 		0xffff8050 	# Boolean: whether or not to move
.eqv 	LEAVETRACK 	0xffff8020 	# Boolean (0 or non-0):
 					# whether or not to leave a track
.eqv	WHEREX 		0xffff8030 	# Integer: Current x-location of MarsBot
.eqv 	WHEREY 		0xffff8040 	# Integer: Current y-location of MarsBot

.text 
	li 	$t4, 0			# count number of successful postscript
	li 	$t5, 0			# check whether or not have postscript1 done
					# 0 - not yet, 1 - done => t4 += 1
					# t4 === 3 => all 3 postscript are done => complete
	li	$t6, 0 			# check whether or not have postscript2 done
	li	$s5, 0			# check whether or not have postscript3 done
polling:
row1: 
	li 	$t1, IN_ADDRESS_HEXA_KEYBOARD 
 	li 	$t2, OUT_ADDRESS_HEXA_KEYBOARD 
 	li 	$t3, 0x01 				# check row 1 with key 0, 1, 2, 3
 	sb 	$t3, 0($t1) 				# must reassign expected row
 	lb 	$a0, 0($t2) 				# read scan code of key button
	bne	$a0, 0x00000011, row2			# 0 - postscript1
	li	$v0, 4
	la	$a0, Msg1
	syscall
	la	$t8, postscript1
	bne	$t5, 0, postscript1_already_done
	li	$t5, 1					# postscript1 done
	addi	$t4, $t4, 1				# done 1 postscript
postscript1_already_done:
	la	$t7, postscript1_length
	lw	$t7, 0($t7)
	j	main
	nop

row2: 
	li 	$t1, IN_ADDRESS_HEXA_KEYBOARD 
 	li 	$t2, OUT_ADDRESS_HEXA_KEYBOARD 
	li 	$t3, 0x02 				# check row 2 with key 4, 5, 6, 7
	sb 	$t3, 0($t1) 				# must reassign expected row
	lb 	$a0, 0($t2) 				# read scan code of key button
	bne	$a0, 0x00000012, row3			# 4 - postscript2
	li	$v0, 4
	la	$a0, Msg2
	syscall
	la	$t8, postscript2
	bne 	$t6, 0, postscript2_already_done
	li	$t6, 1					# postscript2 done
	addi	$t4, $t4, 1				# done 1 postscript
postscript2_already_done:
	la	$t7, postscript2_length
	lw	$t7, 0($t7)
	j	main
	nop			
	
row3: 
	li 	$t1, IN_ADDRESS_HEXA_KEYBOARD 
 	li 	$t2, OUT_ADDRESS_HEXA_KEYBOARD 
	li 	$t3, 0x04 				# check row 3 with key 8, 9, A, B
	sb 	$t3, 0($t1) 				# must reassign expected row
	lb 	$a0, 0($t2) 				# read scan code of key button
	bne	$a0, 0x00000014, invalid		# 8 - postscript3
	li	$v0, 4
	la	$a0, Msg3
	syscall
	la	$t8, postscript3
	bne	$s5, 0, postscript3_already_done
	li	$s5, 1					# postscript3 done
	addi	$t4, $t4, 1				# done 1 postscript
postscript3_already_done:
	la	$t7, postscript3_length
	lw	$t7, 0($t7)
	j	main
	nop		

invalid: 
	li	$v0, 4
	la	$a0, Msg
	syscall
sleep_wait: 
	li 	$a0, 1000 				# sleep 1000ms 
 	li 	$v0, 32 
	syscall 
	j 	polling

main: 
# Go to cut area
	jal 	UNTRACK 		# no draw track line
 	addi 	$s2, $zero, 135 	# Marsbot rotates given radius and start 
start_running:
 	jal 	ROTATE
 	jal 	GO
start_sleep: 
	addi 	$v0,$zero,32 		# Keep running by sleeping in 1000 ms
 	addi 	$a0,$zero,5000
 	syscall
 	
 	jal 	UNTRACK 		# keep old track
 	#jal 	TRACK 			# and draw new track line

	li 	$s0, 0			# Set index counter for postscript array
loop:
	beq	$s0, $t7, end_loop	# if i == numberOfLines*3 then quit
	sll 	$s1, $s0, 2		# s1 = 4i
	add	$s1, $s1, $t8		# s1 = A[i]'s address
	lw	$s2, 0($s1)		# s2 = A[i]'s value - move radius
	addi	$s1, $s1, 4
	lw	$s3, 0($s1)		# s3 = A[i+1]'s value - cut/not cut		
	addi	$s1, $s1, 4 
	lw	$s4, 0($s1)		# s4 = A[i+2]'s value - time per move
		
	jal 	TRACK_UNTRACK 		# draw track line/ or not 
running:
 	jal 	ROTATE
 	jal 	GO
sleep: 
	addi 	$v0,$zero,32 		# Keep running by sleeping in 1000 ms
 	add 	$a0,$zero,$s4
 	syscall
 
 	jal 	UNTRACK 		# keep old track
 	#jal 	TRACK 			# and draw new track line
 	
	addi	$s0, $s0, 3		# iterate next 3 values	
	j 	loop
end_loop:
	jal	STOP
	#j	end_main
	beq	$t4, 3, end_main	# done 3 postscript -> done
	j 	polling
end_main:	
	li	$v0, 10
	syscall
 
#-----------------------------------------------------------
# GO procedure, to start running
# param[in] none
#-----------------------------------------------------------

GO: 
	li 	$at, MOVING 		# change MOVING port
 	addi 	$k0, $zero,1 		# to logic 1,
 	sb 	$k0, 0($at) 		# to start running
 	jr 	$ra
 	
#-----------------------------------------------------------
# STOP procedure, to stop running
# param[in] none
#-----------------------------------------------------------

STOP: 
	li 	$at, MOVING 		# change MOVING port to 0
 	sb 	$zero, 0($at) 		# to stop
 	jr 	$ra
 	
#-----------------------------------------------------------
# TRACK procedure, to start drawing line 
# param[in] none
#----------------------------------------------------------- 

TRACK_UNTRACK: 
	li 	$at, LEAVETRACK 	# change LEAVETRACK port
 	sb 	$s3, 0($at) 		# to start tracking/ or not
 	jr 	$ra
 
#-----------------------------------------------------------
# UNTRACK procedure, to stop drawing line
# param[in] none
#----------------------------------------------------------- 

TRACK: 
	li 	$at, LEAVETRACK 	# change LEAVETRACK port
 	addi 	$k0, $zero,1 		# to logic 1,
 	sb 	$k0, 0($at) 		# to start tracking
 	jr 	$ra

UNTRACK:
	li 	$at, LEAVETRACK 	# change LEAVETRACK port to 0
 	sb 	$zero, 0($at) 		# to stop drawing tail
 	jr 	$ra
#-----------------------------------------------------------
# ROTATE procedure, to rotate the robot
# param[in] $a0, An angle between 0 and 359
# 0 : North (up)
# 90: East (right)
# 180: South (down)
# 270: West (left)
#-----------------------------------------------------------
ROTATE: 
	li 	$at, HEADING 		# change HEADING port
 	sw 	$s2, 0($at) 		# to rotate robot
 	jr 	$ra
