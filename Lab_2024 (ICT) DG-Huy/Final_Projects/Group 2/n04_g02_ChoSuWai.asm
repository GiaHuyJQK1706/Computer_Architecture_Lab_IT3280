.eqv HEADING 0xffff8010 	# Integer: An angle between 0 and 359
 			 	# 0 : North (up)
 			 	# 90: East (right)
			 	# 180: South (down)
			 	# 270: West (left)
.eqv MOVING 0xffff8050  	# Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 	# Boolean (0 or non-0):
 				# whether or not to leave a track
.eqv WHEREX 0xffff8030	 	# Integer: Current x-location of MarsBot
.eqv WHEREY 0xffff8040 		# Integer: Current y-location of MarsBot
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014

.data
#DCE -> Key matrix 0
ps1: .asciiz "150,5000,0;180,5800,1;80,500,1;70,500,1;60,500,1;50,500,1;40,500,1;30,500,1;20,500,1;10,500,1;0,500,1;350,500,1;340,500,1;330,500,1;320,500,1;310,500,1;300,500,1;290,500,1;280,490,1;90,9000,0;180,1000,0;310,400,1;300,400,1;290,400,1;280,400,1;270,800,1;260,400,1;250,400,1;240,400,1;230,400,1;220,400,1;210,400,1;200,400,1;190,400,1;180,800,1;170,400,1;160,400,1;150,400,1;140,400,1;130,400,1;120,400,1;110,400,1;100,400,1;90,800,1;80,400,1;70,400,1;60,400,1;50,400,1;120,3000,0;0,5800,1;90,2000,1;180,2900,0;270,2000,1;180,2900,0;90,2000,1;;90,3000,0;"

#CSW -> Key matrix 4
ps2: .asciiz "150,5000,0;90,5000,0;270,5000,1;180,5000,1;90,5000,1;90,2500,0;90,5000,1;0,2500,1;270,5000,1;0,2500,1;90,5000,1;90,2500,0;150,5000,1;30,5000,1;150,5000,1;30,5000,1;90,2500,0;"

#DHA -> Key matrix 8
ps3: .asciiz "150,5000,0;180,12000,1;0,12000,0;110,2500,1;130,2500,1;150,2500,1;180,2500,1;210,2500,1;230,2500,1;250,2500,1;90,8000,0;0,12000,1;180,6000,0;90,6000,1;0,6000,0;180,12000,1;90,2000,0;30,12000,1;150,12000,1;330,6000,0;270,6000,1;90,10000,0;"

.text
	li $t1, IN_ADDRESS_HEXA_KEYBOARD 	#assign expected row index into the byte at address 0xFFFF0012
	li $t2, OUT_ADDRESS_HEXA_KEYBOARD	#read byte at address 0xFFFF0014 to detect which key button was pressed
polling: 
key_0:
	li $t5, 0x01 			# row 1 of key 
	sb $t5, 0($t1) 			#reassign value for address 0xFFFF0012 to row 1
	lb $a0, 0($t2) 			#read the byte of pressed button from 0xFFFF0014
	bne $a0, 0x11, key_4 		#compare to numpad 0
	la $a1, ps1
	j main
key_4:
	li $t5, 0x02 			# row 2 of key matrix
	sb $t5, 0($t1)			#reassign value for address 0xFFFF0012 to row 2
	lb $a0, 0($t2)			#read the byte of pressed button from 0xFFFF0014
	bne $a0, 0x12, key_8		#compare to numpad 4
	la $a1, ps2
	j main
key_8:
	li $t5, 0X04 			# row-3 of key matrix
	sb $t5, 0($t1)			#reassign value for address 0xFFFF0012 to row 3
	lb $a0, 0($t2)			#read the byte of pressed button from 0xFFFF0014
	bne $a0, 0x14, polling 		#compare to numpad 8, if not 0,4,8 then choose again
	la $a1, ps3
	j main

main:
	jal GO

input_ps: 
	addi $t3, $zero, 0 		# angle rotate
	addi $t4, $zero, 0 		# time
input_rotate:
 	add $t7, $a1, $t6 		# shift bit
	lb $t5, 0($t7)  		# read each digit in postscript
	beq $t5, 0, END 		# end of postscript (null)
 	beq $t5, 44, input_time 	# ',' 
 	mul $t3, $t3, 10 
 	addi $t5, $t5, -48 		# 0 is 48 in ASCII
 	add $t3, $t3, $t5  		# add the digits
 	addi $t6, $t6, 1 		# increase iterator $t6 by 1
 	j input_rotate 			# keep reading until ','
input_time:
 	add $a0, $t3, $zero
	jal ROTATE
 	addi $t6, $t6, 1
 	add $t7, $a1, $t6 		# ($a1 is address of postscript)
	lb $t5, 0($t7) 
	beq $t5, 44, input_track	# ','
	mul $t4, $t4, 10
 	addi $t5, $t5, -48
 	add $t4, $t4, $t5
 	j input_time 			# keep reading until ','	
input_track:
 	addi $v0,$zero,32 		# Keep mars bot running by sleeping with time=$t4
 	add $a0, $zero, $t4
 	addi $t6, $t6, 1 
 	add $t7, $a1, $t6
	lb $t5, 0($t7) 
 	addi $t5, $t5, -48
 	beq $t5, $zero, check_untrack 	# 1 = track, 0 = untrack
 	jal UNTRACK
	jal TRACK
	j skip
	
check_untrack:
	jal UNTRACK
skip:
	syscall 
	addi $t6, $t6, 2	#iterator to go through the postscript
	j input_ps		#add 2 to skip the ";"

GO: 
 	li $at, MOVING 		# change MOVING port
 	addi $k0, $zero,1 	# to logic 1,
 	sb $k0, 0($at) 		# to start running
 	jr $ra
STOP: 
	li $at, MOVING 		# change MOVING port to 0
 	sb $zero, 0($at)	# to stop
 	jr $ra
TRACK: 	
	li $at, LEAVETRACK 	# change LEAVETRACK port
 	addi $k0, $zero,1 	# to logic 1,
	sb $k0, 0($at) 		# to start tracking
 	jr $ra
UNTRACK:
	li $at, LEAVETRACK 	# change LEAVETRACK port to 0
 	sb $zero, 0($at) 	# to stop drawing tail
 	jr $ra
ROTATE: 
	li $at, HEADING 	# change HEADING port
 	sw $a0, 0($at) 		# to rotate robot
 	jr $ra
END:
	jal STOP
	li $v0, 10
	syscall
	j polling
