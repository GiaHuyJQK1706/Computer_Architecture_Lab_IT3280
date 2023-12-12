.eqv SEVENSEG_LEFT    0xFFFF0011 		# Dia chi cua den led 7 doan trai
.eqv SEVENSEG_RIGHT   0xFFFF0010 		# Dia chi cua den led 7 doan phai 
.eqv IN_ADRESS_HEXA_KEYBOARD       0xFFFF0012  
.eqv OUT_ADRESS_HEXA_KEYBOARD      0xFFFF0014	
.eqv KEY_CODE   0xFFFF0004         	# ASCII code from keyboard, 1 byte 
.eqv KEY_READY  0xFFFF0000        	# =1 if has a new keycode ?                                  
			# Auto clear after lw  
  
.eqv COUNTER_TIMER	0xFFFF0013	#Counter Timer's Address
.eqv MASK_CAUSE_COUNTER 0x00000400 	# Bit 10: Counter interrupt
 
.data 
bytedec     : .byte 63,6,91,79,102,109,125,7,127,111 
inputString : .space 1000		#khoang trong de luu cac ky tu nhap tu ban phim.
SRCString : .asciiz "bo mon ky thuat may tinh" 
msg_counter : .asciiz "\n So ky tu da nhap la :  "
numCorrectKey: .asciiz  "\n So ky tu nhap dung la: "  
msg_request_loop: .asciiz "\n ban co muon quay lai chuong trinh? "
msg_speed: .asciiz "\nToc do danh may la: "
msg_unit: .asciiz " cps (character/second)"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# MAIN Procedure
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.text
	li   $k0,  KEY_CODE              
	li   $k1,  KEY_READY                    
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# $s4: Sum of character from input's user
# $t4: Number 10
# $t9 - Boolean: For request loop program or not from user
# $s5 - Boolean: true if Enter key is press
# $s6: Counter Time from start to the end of program
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
main:         
	li $s4,0 		
 	li $t4,10			
	li $t9,0
	li $s5, 0	
	li $s6, 0
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# Enable Counter (Digital Lab Sim)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
START_COUNTER:
	li $s2, COUNTER_TIMER
	sb $s2, 0($s2)
LOOP:          
WAIT_FOR_KEY:  
 	lw   $t1, 0($k1)              	# $t1 = [$k1] = KEY_READY               
	beq  $t1, $zero, WAIT_FOR_KEY        # if $t1 == 0 then Polling  

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# 1. Store key in array 'inputString'
# 2. Add 1 for Sum of character from user input
# 3.  Check if Current character is Enter key
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
READ_KEY:
	lw $t0, 0($k0)
	la  $t7,inputString	
	add $t7,$t7,$s4		
	sb $t0,0($t7)
	addi $s4,$s4,1
	beq $t0,10,is_Entered
	nop
	j LOOP
	

is_Entered: 
	li $s5, 1	#If $t0 is Enter key set $s5 = 1
	b END	#branch to END
	

	       	 
	
END_MAIN: 
	li $v0,10
	syscall
	
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# INTERUPT COUNTER
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.ktext    0x80000180         	  
#--------------------------------------------------------
# Temporary disable interrupt
#--------------------------------------------------------
dis_int:
	li $s2, COUNTER_TIMER
	sb $zero, 0($s2)
#--------------------------------------------------------
# Processing
#--------------------------------------------------------
get_caus:   
	mfc0  $t8, $13                 
	li    $t2, MASK_CAUSE_COUNTER              # if Cause value confirm Counter..
	and   $at, $t8,$t2              
	beq   $at,$t2, Counter_Intr     
	j end_process

Counter_Intr:				# Processing Counter Interrupt
	li $v0, 4
	la $a0, msg_counter		#Just print msg about sum of input character
	syscall	
	nop
	li $v0, 1 # service 1 is print integer
	add  $a0, $s4, $zero
	syscall # execute
	nop
		

end_process:
	mtc0 $zero, $13
check_WaitForKey:	#If on Loop Wait for key please dont next_pc
	beq  $t1, $zero, en_int
check_Entered:		#If on Loop main Please font next_pc
	beq $s5, 0, en_int	

#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:   
	mfc0    $at, $14	        # $at <= Coproc0.$14 = Coproc0.epc              
	addi    $at, $at, 4	 # $at = $at + 4 (next instruction)              
	mtc0    $at, $14	       	# Coproc0.$14 = Coproc0.epc <= $at  

#--------------------------------------------------------
# Re-enable interrupt
#--------------------------------------------------------	
en_int:
	li $s2, COUNTER_TIMER
	sb $s2, 0($s2)
	
SLEEP:  	addi $s6, $s6, 5
	addi    $v0,$zero,32                   
	li      $a0, 5		#Sleep 5ms
	syscall         
	nop
#	b      LOOP		#Branch to LOOP   

RETURN:   
	eret                       	# Return from exception
	
END:
Calc_Speed:
	mtc1  $s6, $f1
	cvt.s.w $f1, $f1
	
	mtc1 $t4, $f3
	cvt.s.w $f3, $f3
	
	mtc1 $s4, $f2
	cvt.s.w $f2, $f2
	
	div.s $f1, $f1, $f3
	div.s $f1, $f1, $f3
	div.s $f1, $f1, $f3
	
	div.s $f2, $f2, $f1
	
	li $v0,11         
	li $a0,'\n'         	
	syscall 
	li $t1,0 		#Count the sum of character which is compared
	li $t3,0                      	#Count the sum of correct character
	li $t8,24		#The lenght of Source String
	slt $t7,$s4,$t8		#Compare length of Source String with User's String
	bne $t7,1, CHECK_STRING	#Which is lesser $t8 := that
	add $t8,$zero, $s4
	addi $t8,$t8,-1		#Skip Enter character from the end of string.
	beq $t8, 0, Print
CHECK_STRING:			
	la $t2,inputString
	add $t2,$t2,$t1
	li $v0,11		#Get character of index $t1  of User's String to store in $t5
	lb $t5,0($t2)	
	move $a0,$t5
	syscall 		#Print User's String
	
	la $t4,SRCString
	add $t4,$t4,$t1
	lb $t6,0($t4)		#Get character of index $t1  of Source String to store in $t6
	bne $t6, $t5,CONTINUE	#Compare $t5, with $t6
	addi $t3,$t3,1
CONTINUE: 
	addi $t1,$t1,1		#Add 1 for counter
	beq $t1,$t8,Print	#if no more character to compare go PRINT
	j CHECK_STRING		#else compare next character
Print:	
	li $v0,4
	la $a0,numCorrectKey
	syscall
	li $v0,1
	add $a0,$0,$t3
	syscall
	
	li $v0,4
	la $a0,msg_speed
	syscall
	li $v0, 2
	mov.s $f12, $f2
	syscall
	li $v0,4
	la $a0,msg_unit
	syscall
	
	li $t9,1
	li $t6,0		
	li $t4,10		# set $t4 = 10
	li $s6, 0
	add $t6,$0,$t3		#$t6 will be store the sum of correct character
	   
	
DISPLAY_DIGITAL: 
	div $t6,$t4		
	mflo $t7		#$t7 = $t6 div $t4
	la $s2,bytedec		#convert to decimal
	add $s2,$s2,$t7		
	lb $a0,0($s2)                 	        
	jal   SHOW_7SEG_LEFT       	# show on left LED
#------------------------------------------------------------------------
	mfhi $t7		#$t7 = $t6 mod $t4
	la $s2,bytedec			
	add $s2,$s2,$t7
	lb $a0,0($s2)                	    
	jal  SHOW_7SEG_RIGHT      	# show on right LED 
#------------------------------------------------------------------------                                            
	li    $t6,0		# Set $t6 to 0 for rerun program
	beq $t9,1,RequestForLoop
	
RequestForLoop: 
	li $v0, 50
	la $a0, msg_request_loop
	syscall
	beq $a0,0,main	
	nop	
	b EXIT
    
SHOW_7SEG_LEFT:  
	li   $t0,  SEVENSEG_LEFT 	# assign port's address                   
	sb   $a0,  0($t0)        	# assign new value                    
	jr   $ra 
	
SHOW_7SEG_RIGHT: 
	li   $t0,  SEVENSEG_RIGHT 	# assign port's address                  
	sb   $a0,  0($t0)         	# assign new value                   
	jr   $ra 

EXIT: 
