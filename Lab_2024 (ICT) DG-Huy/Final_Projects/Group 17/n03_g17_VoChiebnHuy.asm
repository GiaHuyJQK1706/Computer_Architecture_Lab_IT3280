.eqv SEVENSEG_LEFT 0xFFFF0011 			#Address of the left 7-segment LED
.eqv SEVENSEG_RIGHT 0xFFFF0010 			#Address of the right 7-segment LED
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012  
.eqv MASK_CAUSE_COUNTER 0x00000400 		#Bit 10: Counter interrupt
.eqv COUNTER 0xFFFF0013 			#Time Counter
.eqv KEY_CODE   0xFFFF0004         		#ASCII code from the keyboard, 1 byte 
.eqv KEY_READY  0xFFFF0000        		#Non-zero if there is a new keycode   
.data
number_array: .byte 	63, 6,  91, 79, 102, 109 ,125, 7, 127, 111	 #from 0 to 9
string: .asciiz "Bo mon ki thuat may tinh" 
message1: .asciiz "Elapsed time: "
message2: .asciiz "(s) \nAverage typing speed: "
message3: .asciiz " words/minute\n"
Continue: .asciiz "Continue entering?"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# MAIN Procedure 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.text						#global variables: k0, k1, s0, s1, s2, s3, s4, s5, a1
MAIN:	li	$k0,  KEY_CODE              
	li  	$k1,  KEY_READY   
	li 	$t1, COUNTER			#Initialize the timer
	sb 	$t1, 0($t1)
	addi	$s0, $0, 0			#Count the number of characters in 1 second
	addi	$s1, $0, 0			#Count the total number of correct characters
	addi	$s2, $0, 0			#Count the total number of entered words
	addi	$s3, $0, 0			#Count the number of counter_intr occurrences
	addi	$s4, $0, 0			#Store the previous character
	addi	$s5, $0, 0			#Count the time (seconds)
	la	$a1, string
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#ENDLESS LOOP TO WAIT FOR INTERRUPTS
loop: 
	lw   	$t1, 0($k1)                 	#$t1 = [$k1] = KEY_READY              
	bne  	$t1, $zero, make_Keyboard_Intr	#Generate an interrupt when a key is pressed on the keyboard
	addi	$v0, $0, 32
	li	$a0, 5
	syscall
	b 	loop				#The number of instructions in one loop is 6 => after 5 iterations, generate a counter interrupt
	nop
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
make_Keyboard_Intr:
	teqi	$t1, 1
	b	loop				#Return to the loop to wait for the next interrupt event
	nop

end_Main:

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#INTERRUPT SERVICE ROUTINE
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.ktext 0x80000180

dis_int:li 	$t1, COUNTER 			#BUG: must disable with Time Counter
	sb 	$zero, 0($t1)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#GET THE VALUE OF THE CP0.CAUSE REGISTER TO CHECK THE TYPE OF INTERRUPT
get_Caus:mfc0 	$t1, $13 			#$t1 = Coproc0.cause
isCount:li 	$t2, MASK_CAUSE_COUNTER		#if Cause value confirms Counter..
	 and 	$at, $t1,$t2
	 bne 	$at,$t2, keyboard_Intr
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#COUNTER INTERRUPT
counter_Intr:
	blt	$s3, 40, continue		#If the interrupt count is less than 40: 1 second has passed -> reset $s3, display typing speed on DLS, increase the time counter by 1
	jal	hien_thi
	addi	$s3, $0, 0			#Reset $s3
	addi	$s5, $s5, 1			#Increase the time counter (seconds)
	j	en_int 
	nop
continue:
	addi	$s3, $s3, 1			#If less than 1 second, increase the interrupt count
	j 	en_int
	nop
keyboard_Intr:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#KEYBOARD INTERRUPT
test_char:					#Check the entered character
	lb	$t0, 0($a1)			#Get the i-th character from the given string
	lb	$t1, 0($k0)			#Get the entered character from the keyboard
	beq	$t1, $0, en_int			#Error
	beq 	$t1, '\n', end_Program		#If the character is '\n', check and print
	bne	$t0, $t1, kiem_tra_dau_cach	#If the entered character and the i-th character in the given string are the same, count the number of correct characters
	nop
	addi	$s1, $s1, 1			#Increase the count of correct characters
test_space:					#Check if the entered character is ' '
	bne	$t1, ' ', end_Process		#If the entered character == ' ' && the previous character != ' ', count the number of words entered
	nop
	beq	$s4, ' ', end_Process
	nop
	addi	$s2, $s2, 1			#Increase the count of entered words
end_Process:
	addi	$s0, $s0, 1			#Increase the number of characters in 1 second
	addi	$s4, $t1, 0			#Update the previous character
	addi	$a1, $a1, 1 			#Increase the pointer by 1 <=> string+i
	j en_int
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#DISPLAY ON THE DIGITAL LAB SIM SCREEN THE VALUE OF $s0
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
display:
	addi	$sp, $sp, -4			
	sw	$ra, ($sp)
	addi	$t0, $0, 10
	div	$s0, $t0
	mflo	$v1				#Get the tens place
	mfhi	$v0				#Get the units place
	la 	$a0, mang_so
	add	$a0, $a0, $v1
	lb 	$a0, 0($a0) 			#Set value for segments
	jal 	SHOW_7SEG_LEFT 			#Display
	
	la 	$a0, mang_so 
	add	$a0, $a0, $v0
	lb 	$a0, 0($a0) 			#Set value for segments
	jal 	SHOW_7SEG_RIGHT 		#Display
	
	addi	$s0, $0, 0			#After displaying on the screen, reset the counter
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr 	$ra
SHOW_7SEG_LEFT: 
	li 	$t0, SEVENSEG_LEFT 		#Assign port's address
	sb 	$a0, 0($t0) 			#Assign a new value
	jr 	$ra
SHOW_7SEG_RIGHT: 
	li 	$t0, SEVENSEG_RIGHT 		#Assign port's address
	sb 	$a0, 0($t0) 			#Assign a new value
	jr 	$ra
	nop
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#END THE PROGRAM AND DISPLAY THE NUMBER OF CORRECT CHARACTERS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
end_Program:
	 addi	$v0, $0, 4
	 la	$a0, message1
	 syscall
	 addi	$v0, $0, 1
	 addi	$a0, $s5, 0
	 syscall
	 addi	$v0, $0, 4
	 la	$a0, message2
	 syscall
	 addi	$v0, $0, 1
	 addi	$a0, $0, 60
	 mult	$s2, $a0
	 mflo	$s2
	 div	$s2, $s5
	 mflo	$a0
	 syscall
	 addi	$v0, $0, 4
	 la	$a0, message3
	 syscall
	 addi	$s0, $s1, 0
	 jal	hien_thi
CONTINUE:
	li $v0, 50
	la $a0, Continue
	syscall
	beq $a0, 0, MAIN		
	li $v0, 10
	syscall	 
	
# ----------------------- End of interrupt processing --------------------------------------
en_int: 
	li 	$t1, COUNTER
	sb 	$t1, 0($t1)
	mtc0 	$zero, $13 			#Must clear the cause register
next_pc: mfc0 	$at, $14 			#$at <= Coproc0.$14 = Coproc0.epc
	 addi 	$at, $at, 4 			#$at = $at + 4 (next instruction)
	 mtc0 	$at, $14 			#Coproc0.$14 = Coproc0.epc <= $at
return: eret 					#Return from the exception
