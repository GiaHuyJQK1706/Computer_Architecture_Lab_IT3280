.data
	parity: .space 32 #Parity string
	prompt: .asciiz "Enter string: "
	hex: .byte  '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'
	d1: .space 4 #Disk 1
	d2: .space 4 #Disk 2
	d3: .space 4 #Disk 3
	string: .space 1000 #input string
	endline: .asciiz "\n"
	error: .asciiz "Invalid input"
	continue: .asciiz "Continue input? (Y/N)"
	disk: .asciiz  "      Disk 1                Disk 2                 Disk 3\n"
	ms1: .asciiz   "-----------------      ----------------       ----------------\n"
	ms2: .asciiz   "|     "
	ms3: .asciiz   "      |      "
	ms4: .asciiz  "[[ "
	ms5: .asciiz "]]       "
	comma: .asciiz ","
	
.text

main:

	main_loop:
	jal input
	jal check_validation
	bgezal $s1, RAID5
	
	continue_main:
	j check_continue_input
	
input:
	la $a0, prompt
	li $v0, 4
	syscall
	
	la $a0, string
	li $a1, 1000
	li $v0, 8
	syscall
	
	move $s0, $a0 
	jr $ra

#check if string has length is a multiple of 8
check_validation:
	li $s1, 0 #Set s1 = 0 means valid
	li $t3, 0 #i=0
	loop_check: 
	        add $t1, $s0, $t3
		lb $t2, 0($t1) #string[i]
		beq $t2, 10, end_loop_check
		addi $t3, $t3, 1
		j loop_check
	end_loop_check:
		beq $t3, 0, error_msg
		div $t4, $t3, 8
		mfhi $t4
		bne $t4, 0, error_msg
		jr $ra
		nop
		error_msg:
			li $s1, -1 #s1=-1 means invalid input
			la $a0, error
			li $v0, 4
			syscall
			jr $ra
			
convert: 
# Convert parity string to hexa 
	li $t4, 1				#t4 = 7
	
loopH:	
	blt $t4, $0, endloopH			# t4 < 0  -> endloop
	sll $s6, $t4, 2				# s6 = t4*4
	srlv $a0, $t8, $s6			# a0 = t8>>s6
	andi $a0, $a0, 0x0000000f 		# a0 = a0 & 0000 0000 0000 0000 0000 0000 0000 1111 => Get the last byte
	la $t7, hex 				# t7 = adrress of hex
	add $t7, $t7, $a0 			# t7 = t7 + a0
	lb $a0, 0($t7) 				# print hex[a0]
	li $v0, 11						
	syscall


nextc:	addi $t4,$t4,-1				# t4 --
	j loopH					
	nop

endloopH: 
	jr $ra
	nop


RAID5:
#block 1 : save byte parity into disk 3
#block 2 : save byte parity into disk 2
#block 3 : save byte parity into disk 1
block1:	 		


	addi $t0, $zero, 0			# bytes printed (4 byte)
	addi $t9, $zero, 0				
	addi $t8, $zero, 0
	la $s1, d1				# s1 = adress of d1
	la $s2, d2				# s2 = address of d2
	la $a2, parity				# 
	
print11:					
	li $v0, 4				# print message2 : "|     " 
	la $a0, ms2			
	syscall
	

b11:	
				
	lb $t1, ($s0)				# t1 = first value of input string 			
	addi $t3, $t3, -1			# t3 = t3 -1, decrease the length of string
	sb $t1, ($s1)				# store t1 to disk 1  	
b12:	

	add $s5, $s0, 4				# s5 = s0 +4
	lb $t2, ($s5)				# t2 = inputstring[5]
	addi $t3, $t3, -1			# t3 = t3  - 1  
	sb $t2, ($s2)				# store t2 vao disk 2
b13:	
# Save xor result into disk 3
	xor $a3, $t1, $t2			# a3 = t1 xor t2
	sw $a3, ($a2)				# save a3 to ($a2)
	addi $a2, $a2, 4			# Parity string
	addi $t0, $t0, 1			# Get next character
	addi $s0, $s0, 1				
	addi $s1, $s1, 1			# Increment disk 1 index 
	addi $s2, $s2, 1			# Increment disk 2 index 
	bgt $t0, 3, reset			#  Reset disk
	j b11
	nop
reset:	
	la $s1, d1				# reset index to the first element in disk 1 
	la $s2, d2				# reset index to the first element in disk 2
	
print12: 					#in Disk 1 
	lb $a0, ($s1)				#print each char  in Disk 1		
	li $v0, 11		
	syscall
	addi $t9, $t9, 1		
	addi $s1, $s1, 1
	bgt $t9, 3, next11			
	j print12
	nop
	
next11:	 					#Prepare to print Disk 2    "|         |"
	li $v0, 4			
	la $a0, ms3
	syscall
	li $v0, 4
	la $a0, ms2
	syscall
	
print13:						# Print disk 2 
	lb $a0, ($s2)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s2, $s2, 1
	bgt $t8, 3, next12			
	j print13				
	nop
	
next12:						# Prepare to print Disk 3 
	li $v0, 4										
	la $a0, ms3
	syscall
	li $v0, 4
	la $a0, ms4
	syscall
	la $a2, parity			# a2 = address of parity string[i]
	addi $t9, $zero, 0		# t9 = i
	
print14:				# Convert parity string to ASCII and print
	lb $t8, ($a2)			# t8 = adress of parity string[i]
	jal convert
	nop
	li $v0, 4			
	la $a0, comma			# print  " , " 
	syscall
	
	addi $t9, $t9, 1		# parity string's index  + 1
	addi $a2, $a2, 4		
	bgt $t9, 2, end1		# Print the first 3 pair of parity string with ","
	j print14	
end1:				# Print the last pair of parity string and finish Disk 3
	lb $t8, ($a2)			
	jal convert
	nop
	li $v0, 4
	la $a0, ms5
	syscall
	
	li $v0, 4			# Endline to start new block
	la $a0, endline
	syscall
	beq $t3, 0, exit1		# If string's length = 0 means no more string to print   , exit
	j block2			# If there are still more left => block2
	nop
	
#-------------------------------------------------------------------------------------

block2:	
#Similar to block1 but with parity string printed in Disk 2

	la $a2, parity				
	la $s1, d1				# s1 = address of Disk 1
	la $s3, d3				# s3 =            Disk 3
	addi $s0, $s0, 4
	addi $t0, $zero, 0
		
print21:					
# print "|     "
	li $v0, 4
	la $a0, ms2
	syscall
	
b21:	

	lb $t1, ($s0)				# t1 = address of Disk 1
	addi $t3, $t3, -1			
	sb $t1, ($s1)				
b23:	
# Next 4 bytes into Disk 3
	add $s5, $s0, 4
	lb $t2, ($s5)
	addi $t3, $t3, -1
	sb $t2, ($s3)
	
b22:	
# 4 byte parity vao Disk 2
	xor $a3, $t1, $t2
	sw $a3, ($a2)
	addi $a2, $a2, 4
	addi $t0, $t0, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	bgt $t0, 3, reset2
	j b21
	nop
reset2:	
	la $s1, d1			
	la $s3, d3			
	addi $t9, $zero, 0		
	
print22:
# print Disk 1
	lb $a0, ($s1)
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s1, $s1, 1
	bgt $t9, 3, next21
	j print22
	nop
	
next21:		
	li $v0, 4
	la $a0, ms3
	syscall
	la $a2, parity	
	addi $t9, $zero, 0
	li $v0, 4
	la $a0, ms4
	syscall	
	
print23:	
	lb $t8, ($a2)
	jal convert				
	nop
	li $v0, 4
	la $a0, comma			#print ","
	syscall
	addi $t9, $t9, 1
	addi $a2, $a2, 4
	bgt $t9, 2, next22	
	j print23
	nop
		
next22:		
#print Disk 2 in ACSII 
	lb $t8, ($a2)
	jal convert
	nop
	
	li $v0, 4
	la $a0, ms5
	syscall
	
	li $v0, 4
	la $a0, ms2
	syscall
	addi $t8, $zero, 0
	
print24:	
# print Disk 3 
	lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s3, $s3, 1
	bgt $t8, 3, end2
	j print24
	nop

end2:	
# If there are no more characters then exit
# If there still remains then => block3
	li $v0, 4
	la $a0, ms3
	syscall
	li $v0, 4
	la $a0, endline
	syscall
	beq $t3, 0, exit1
#------------------------------------------------------------
block3:	
# Byte parity saved in Disk1
# 2 block 4 byte saved in Disk 2 , Disk 3 
	la $a2, parity						
	la $s2, d2			
	la $s3, d3
	addi $s0, $s0, 4			
	addi $t0, $zero, 0			
print31:					

	li $v0, 4
	la $a0, ms4
	syscall
b32:	
#  byte stored in Disk 2
				
	lb $t1, ($s0)			# in first loop, t1 = first H
	addi $t3, $t3, -1	
	sb $t1, ($s2)
b33:	
	# store in Disk 3 first
	add $s5, $s0, 4			# 
	lb $t2, ($s5)			# in first loop , t2 = the second "H"	
	addi $t3, $t3, -1		# stored in disk 3
	sb $t2, ($s3)			# stored t2 in disk 3
	
b31:	
# ham xor tinh parity 
	xor $a3, $t1, $t2		# a3 = parity number	
	sw $a3, ($a2)			# stored in parity string
	addi $a2, $a2, 4		# parity string's index + 4
	addi $t0, $t0, 1		
	addi $s0, $s0, 1		
	addi $s2, $s2, 1		#	disk2 +1 
	addi $s3, $s3, 1		# 	disk 3 +1
	bgt $t0, 3, reset3		
	j b32				
	nop
reset3:	
# Reset to first of disk2 , disk 3
	la $s2, d2
	la $s3, d3
	la $a2, parity	 
	addi $t9, $zero, 0		#index
	
print32:
# Print parity string
	lb $t8, ($a2)			
	jal convert				
	nop		
	li $v0, 4			
	la $a0, comma
	syscall
	
	addi $t9, $t9, 1
	addi $a2, $a2, 4		
	bgt $t9, 2, next31		
	j print32			
	nop		
	
next31:	
# print the last parity byte
	lb $t8, ($a2)
	jal convert
	nop

	li $v0, 4
	la $a0, ms5
	syscall
	li $v0, 4
	la $a0, ms2
	syscall
	addi $t9, $zero, 0
	
print33:
#print disk 2, print 4 byte from Disk 2
	lb $a0, ($s2)
	li $v0, 11
	syscall
	addi $t9, $t9, 1
	addi $s2, $s2, 1
	bgt $t9, 3, next32
	j print33
	nop
	
next32:	

	addi $t9, $zero, 0
	addi $t8, $zero, 0
	li $v0, 4
	la $a0, ms3
	syscall	
	li $v0, 4
	la $a0, ms2
	syscall	
print34:
#  print  4 byte from Disk 3
	lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s3, $s3, 1
	bgt $t8, 3, end3
	j print34
	nop

end3:	
#Finish printing Disk 3
	li $v0, 4
	la $a0, ms3			# Print: "      |"
	syscall
	
	li $v0, 4
	la $a0, endline			
	syscall	
	beq $t3, 0, exit1		# If there are no more characters -> exit
					# If there still remains  -> return to block1



nextloop: addi $s0, $s0, 4		#Skip 4 characters already printed
	j block1
	nop
	
exit1:	# Print ----------- and finish RAID 5 simulation
	li $v0, 4
	la $a0, ms1
	syscall
	
	j continue_main	
					
check_continue_input:
	la $a0, endline 
	li $v0, 4
	syscall
	
	la $a0, continue 	#Print continue message to ask if the user wants to continue input
	li $v0, 4
	syscall
	
	la $a0, endline 
	li $v0, 4
	syscall
	
	li $v0, 12		#Read command character "Y" to continue, "N" to terminate 
	syscall
	
	move $s7, $v0
	la $a0, endline 
	li $v0, 4
	syscall
	
	beq $s7, 'N', exit
	j main_loop
	
	exit:
	li $v0, 10
	syscall		
	
	
	
