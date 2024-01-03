# eqv for Digital Lab Sim
.eqv key0 0x11 
.eqv key1 0x21
.eqv key2 0x41
.eqv key3 0x81
.eqv key4 0x12
.eqv key5 0x22
.eqv key6 0x42
.eqv key7 0x82
.eqv key8 0x14
.eqv key9 0x24
.eqv keya 0x44
.eqv keyb 0x84
.eqv keyc 0x18
.eqv keyd 0x28
.eqv keye 0x48
.eqv keyf 0x88

# eqv for Keyboard
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv KEY_CODE 0xFFFF0004 	
.eqv KEY_READY 0xFFFF0000 	
    				

# eqv for Mars bot
.eqv HEADING 0xffff8010     	
.eqv MOVING 0xffff8050 		
.eqv LEAVETRACK 0xffff8020 	
.eqv WHEREX 0xffff8030 		
.eqv WHEREY 0xffff8040 		

.data
	
	string1: .asciiz "1b4" 
	string2: .asciiz "c68"
	string3: .asciiz "444"
	string4: .asciiz "666"
	string5: .asciiz "dad"
	string6: .asciiz "cbc"
	string7: .asciiz "999"
 
	error:  .asciiz "Invalid command : "


	# HISTORY
	# save history before changing direction
 
	x_his: .word 0 : 16 
	y_his: .word 0 : 16 
 
	# For rotation
	a_his: .word 0 : 16
	l_his: .word 4  		

	a_now: .word 0  		
 
	is_going: .word 0
	is_tracking: .word 0
 
	# Array and variables
	control_code: .space 8  
	code_length: .word 0  		

 	prev_code: .space 8 	

.text
 
main: 
	li $k0, KEY_CODE
 	li $k1, KEY_READY
  
	li $t1, IN_ADRESS_HEXA_KEYBOARD # enable the interrupt of Digital Lab Sim
	li $t3, 0x80   # bit 7 = 1 to enable
	sb $t3, 0($t1)
 
# run at start of program
init: 
	# increase length history by 4
	# (as saving current state: x = 0; y = 0; a = 90)
 
	lw $t7, l_his # l_history += 4
	addi $t7, $zero, 4
	sw $t7, l_his
 
	li $t7, 90
	sw $t7, a_now # a_current = 90 -> head to the right
	jal ROTATE
	nop
 
	sw $t7, a_his # a_history[0] = 90
 
	j waitForKey

# Function to print to console
printError: 
	li $v0, 4
	la $a0, error
	syscall
  
printCode: 
	li $v0, 4
	la $a0, control_code
	syscall
	j resetInput

repeatCode:

	jal strcpyPrevToCur
	j checkCode

resetInput: 
	jal strClear   
	nop   

#input
waitForKey: 
	lw $t5, 0($k1)   # $t5 = [$k1] = KEY_READY
	beq $t5, $zero, waitForKey  # if $t5 == 0 -> Polling 
	nop
	beq $t5, $zero, waitForKey
 
readKey: 
	lw $t6, 0($k0)   # $t6 = [$k0] = KEY_CODE
	# if $t6 == 'DEL' -> reset input
	beq $t6, 0x8, resetInput  
	
	# if $t6 == 'SPACE' -> reset copy from previous input and
	# go to checkCode label
	beq $t6, 0x20, repeatCode
	
	# if $t6 != 'ENTER' -> Polling
	bne $t6, 0x0a, waitForKey  
	nop
	bne $t6, 0x0a, waitForKey

checkCode: 
	lw $s2, code_length   # code_length != 3 -> invalid code
	bne $s2, 3, printError
  
	la $s3, string1
	jal strcmp
	beq $t0, 1, go
  
	la $s3, string2
	jal strcmp
	beq $t0, 1, stop
  
	la $s3, string3
	jal strcmp
	beq $t0, 1, turnLeft
 
	la $s3, string4
	jal strcmp
	beq $t0, 1, turnRight
 
	la $s3, string5
	jal strcmp
	beq $t0, 1, track

	la $s3, string6
	jal strcmp
	beq $t0, 1, untrack
 
	la $s3, string7
	jal strcmp
	beq $t0, 1, goBackward
	nop
 
	j printError
 

# Perform function MarsBot
go:  
	jal strCpy2
	jal GO
	j printCode
  
stop:  
	jal strCpy2
	jal STOP
	j printCode

track:  
	jal strCpy2
	jal TRACK
	j printCode
 
untrack: 
	jal strCpy2
	jal UNTRACK
	j printCode

    
turnRight:
	jal strCpy2
	lw $t7, is_going
	lw $s0, is_tracking
 
	jal STOP
	nop
	jal UNTRACK
	nop
 
	la $s5, a_now
	lw $s6, 0($s5)  
	addi $s6, $s6, 90 
	sw $s6, 0($s5)  
 
	jal saveHistory
	jal ROTATE
 
	beqz $s0, noTrack1
	nop
	jal TRACK
	noTrack1: nop
 
	beqz $t7, noGo1
	nop
	jal GO
noGo1: 
	nop
	j printCode 
 
   
turnLeft: 
	jal strCpy2
	lw $t7, is_going
	lw $s0, is_tracking
 
	jal STOP
	nop
	jal UNTRACK
	nop

	la $s5, a_now
	lw $s6, 0($s5)  # $s6 is heading at now
	addi $s6, $s6, -90 # decrease alpha by 90*
	sw $s6, 0($s5)  # update a_current
 
	jal saveHistory
	jal ROTATE
 
	beqz $s0, noTrack2
	nop
	jal TRACK
	noTrack2: nop
 
	beqz $t7, noGo2
	nop
	jal GO
noGo2: 
	nop
	j printCode 


goBackward:
	jal strCpy2
	li $t7, IN_ADRESS_HEXA_KEYBOARD # Disable interrupts when going backward
    	sb $zero, 0($t7)

	lw $s5, l_his  # $s5 = code_length
	jal UNTRACK
	jal GO
 
goBackward_turn: 
	addi $s5, $s5, -4   # code_length-- 
	lw $s6, a_his($s5)  # $s6 = a_history[code_length]
	addi $s6, $s6, 180  # $s6 = the reverse direction of alpha
	sw $s6, a_now
	jal ROTATE
	nop
 
goBackward_toTurningPoint:
	lw $t9, x_his($s5)  # $t9 = x_history[i] 
	lw $t7, y_his($s5)  # $t9 = y_history[i]
 
get_x: 
	li $t8, WHEREX   # $t8 = x_current
	lw $t8, 0($t8)
	
	bne $t8, $t9, get_x  # x_current == x_history[i]
	nop   
	bne $t8, $t9, get_x 
get_Y: 
	li $t8, WHEREY   # $t8 = y_current
	lw $t8, 0($t8)
	bne $t8, $t7, get_Y  # y_current == y_history[i]
	nop    
	bne $t8, $t7, get_Y  # y_current == y_history[i]
	beq $s5, 0, goBackward_end  # l_history == 0
	nop    # -> end
	j goBackward_turn   # else -> turn
 
goBackward_end: 
	jal STOP
	sw $zero, a_now  # update heading
	jal ROTATE
	addi $s5, $zero, 4
	sw $s5, l_his  # reset l_history = 0
	j printCode
 
#-----------------------------------------------------------
# saveHistory()
#-----------------------------------------------------------

saveHistory: 
	addi $sp, $sp, 4   # backup
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	sw $t2, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4
	sw $t4, 0($sp)
	addi $sp, $sp, 4
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $s2, 0($sp)
	addi $sp, $sp, 4
	sw $s3, 0($sp)
	addi $sp, $sp, 4
	sw $s4, 0($sp)
 
	lw $s1, WHEREX   # s1 = x 
	lw $s2, WHEREY   # s2 = y
	lw $s4, a_now  # s4 = a_current
	
	lw $t3, l_his  # $t3 = l_history
	sw $s1, x_his($t3)  # store: x, y, alpha
	sw $s2, y_his($t3)
	sw $s4, a_his($t3)
	
	addi $t3, $t3, 4   # update lengthPath
	sw $t3, l_his
	
	lw $s4, 0($sp)   # restore backup
	addi $sp, $sp, -4
	lw $s3, 0($sp)
	addi $sp, $sp, -4
	lw $s2, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t4, 0($sp)
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
saveHistory_end: 
	jr $ra  

#===============================================================================
# Procedure for Mars bot
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GO()
#-----------------------------------------------------------
GO:  
	addi $sp, $sp, 4   # backup
	sw $at, 0($sp)
	addi $sp, $sp, 4
	sw $k0, 0($sp)

	li $at, MOVING   # change MOVING port
	addi $k0, $zero, 1  # to logic 1,
	sb $k0, 0($at)   # to start running
	
	li $t7, 1   # is_going = 0
	sw $t7, is_going  
	
	lw $k0, 0($sp)   # restore back up
	addi $sp, $sp, -4
	lw $at, 0($sp)
	addi $sp, $sp, -4
 
GO_end: 
	jr $ra
 
#-----------------------------------------------------------
# STOP()
#-----------------------------------------------------------
STOP:  
	addi $sp, $sp, 4   # backup
	sw $at, 0($sp)
	
	li $at, MOVING   # change MOVING port to 0
	sb $zero, 0($at)  # to stop
	
	sw $zero, is_going  # is_going = 0
	
	lw $at, 0($sp)   # restore back up
	addi $sp, $sp, -4
 
STOP_end: 
	jr $ra
 
#-----------------------------------------------------------
# TRACK()
#-----------------------------------------------------------
TRACK: 
	addi $sp, $sp, 4   # backup
	sw $at, 0($sp)
	addi $sp, $sp, 4
	sw $k0, 0($sp)

	li $at, LEAVETRACK  # change LEAVETRACK port
	addi $k0, $zero,1  # to logic 1,
	sb $k0, 0($at)   # to start tracking
	
	addi $s0, $zero, 1
	sw $s0, is_tracking
	
	lw $k0, 0($sp)   # restore back up
	addi $sp, $sp, -4
	lw $at, 0($sp)
	addi $sp, $sp, -4
    
TRACK_end: 
	jr $ra
 
#-----------------------------------------------------------
# UNTRACK()
#-----------------------------------------------------------
UNTRACK: 
	addi $sp, $sp, 4  # backup
	sw $at, 0($sp)
	
	li $at, LEAVETRACK # change LEAVETRACK port to 0
	sb $zero, 0($at) # to stop drawing tail
	
	sw $zero, is_tracking
	
	lw $at, 0($sp)  # restore back up
	addi $sp, $sp, -4
    
UNTRACK_end: 
	jr $ra

#-----------------------------------------------------------
# ROTATE()
#-----------------------------------------------------------
ROTATE: 
	addi $sp, $sp, 4  # backup
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	sw $t2, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	
	li $t1, HEADING # change HEADING port
	la $t2, a_now
	lw $t3, 0($t2)  # $t3 is heading at now
	sw $t3, 0($t1)  # to rotate robot
	
	lw $t3, 0($sp)  # restore back up
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
    
ROTATE_end: 
	jr $ra
 
#===============================================================================
# Procedure for string 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# strcmp()
# - input: $s3 = string to compare with control_code
# - output: $t0 = 0 if not equal, 1 if equal
#-----------------------------------------------------------     
strcmp: 
	addi $sp, $sp, 4   # back up
	sw $t1, 0($sp)
	addi $sp, $sp, 4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	
	xor $t0, $zero, $zero  # $t1 = return value = 0
	xor $t1, $zero, $zero  # $t1 = i = 0
 
strcmp_loop: 
	beq $t1, 3, strcmp_equal  # if i = 3 -> end loop -> equal
	nop
	
	lb $t2, control_code($t1)  # $t2 = control_code[i]
	
	add $t3, $s3, $t1  # $t3 = s + i
	lb $t3, 0($t3)   # $t3 = s[i]
	
	beq $t2, $t3, strcmp_next  # if $t2 == $t3 -> continue the loop
	nop
	
	j strcmp_end

strcmp_next: 
	addi $t1, $t1, 1
	j strcmp_loop

strcmp_equal: 
	add $t0, $zero, 1  # i++

strcmp_end: 
	lw $t3, 0($sp)   # restore the backup
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4

	jr $ra

#-----------------------------------------------------------
# strClear()
#-----------------------------------------------------------    
strClear: 
	addi $sp, $sp, 4   # backup
	sw $t1, 0($sp)
	addi $sp, $sp, 4 
	sw $t2, 0($sp) 
	addi $sp, $sp, 4 
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4 
	sw $s2, 0($sp)
	
	lw $t3, code_length   # $t3 = code_length
	addi $t1, $zero, -1  # $t1 = -1 = i
    
strClear_loop: 
	addi $t1, $t1, 1   # i++ 
	sb $zero, control_code  # control_code[i] = '\0'
	    
	bne $t1, $t3, strClear_loop # if $t1 <=3 resetInput loop
	nop
	    
	sw $zero, code_length  # reset code_length = 0
 
strClear_end: 
	lw $s2, 0($sp)   # restore backup
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jr $ra
	
#-----------------------------------------------------------
# strcpyPrevToCur(): copy value from prev to current code
#-----------------------------------------------------------   
strcpyPrevToCur:
	addi $sp, $sp, 4   # backup
	sw $t1, 0($sp)
	addi $sp, $sp, 4 
	sw $t2, 0($sp) 
	addi $sp, $sp, 4 
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4 
	sw $s2, 0($sp)
	
	li $t2, 0
	# load address of control_code
	la $s1, control_code
	
	# load address of prev_control_code
	la $s2, prev_code
	
strCpy1_loop:
	beq $t2, 3, strCpy1_end
	
	# $t1 as control_code[i]
	lb $t1, 0($s2)
	sb $t1, 0($s1)
	
	addi $s1, $s1, 1
	addi $s2, $s2, 1
	addi $t2, $t2, 1
	
	j strCpy1_loop
	
strCpy1_end: 
	# reset code length
	li $t3, 3
	sw $t3, code_length
	
	lw $s2, 0($sp)   # restore backup
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jr $ra	
	

#-----------------------------------------------------------
# strcpyCurToPrev(): copy value from current code to prev code
#-----------------------------------------------------------   
strCpy2:
	addi $sp, $sp, 4   # backup
	sw $t1, 0($sp)
	addi $sp, $sp, 4 
	sw $t2, 0($sp) 
	addi $sp, $sp, 4 
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	addi $sp, $sp, 4 
	sw $s2, 0($sp)
	
	li $t2, 0
	# load address of prev_control_code
	la $s1, prev_code
	
	# load address of control_code
	la $s2, control_code
	
strCpy2_loop:
	beq $t2, 3, strCpy2_end
	
	# $t1 as control_code[i]
	lb $t1, 0($s2)
	sb $t1, 0($s1)
	
	addi $s1, $s1, 1
	addi $s2, $s2, 1
	addi $t2, $t2, 1
	
	j strCpy2_loop
	
strCpy2_end: 
	lw $s2, 0($sp)   # restore backup
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jr $ra	

#===============================================================================
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
#-------------------------------------------------------
# SAVE the current REG FILE to stack
#-------------------------------------------------------
backup: 
	addi $sp, $sp, 4
	sw $ra, 0($sp)
	
	addi $sp, $sp, 4
	sw $t1, 0($sp)
	
	addi $sp, $sp, 4
	sw $t2, 0($sp)
	
	addi $sp, $sp, 4
	sw $t3, 0($sp)
	
	addi $sp, $sp, 4
	sw $a0, 0($sp)
	
	addi $sp, $sp, 4
	sw $at, 0($sp)
	addi $sp, $sp, 4
	sw $s0, 0($sp)
	addi $sp, $sp, 4
	sw $s1, 0($sp)
	addi $sp, $sp, 4
	sw $s2, 0($sp)
	addi $sp, $sp, 4
	sw $t4, 0($sp)
	addi $sp, $sp, 4
	sw $s3, 0($sp)
	#--------------------------------------------------------
	# Processing
	#--------------------------------------------------------
getCode: 
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t2, OUT_ADRESS_HEXA_KEYBOARD

	# scan row 1
	li $t3, 0x81
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, getCodeInChar

	# scan row 2
	li $t3, 0x82
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, getCodeInChar

	# scan row 3
	li $t3, 0x84
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, getCodeInChar

	# scan row 4
	li $t3, 0x88
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, getCodeInChar

getCodeInChar:
	beq $a0, key0, case_0
	beq $a0, key1, case_1
	beq $a0, key2, case_2
	beq $a0, key3, case_3
	beq $a0, key4, case_4
	beq $a0, key5, case_5
	beq $a0, key6, case_6
	beq $a0, key7, case_7
	beq $a0, key8, case_8
	beq $a0, key9, case_9
	beq $a0, keya, case_a
	beq $a0, keyb, case_b
	beq $a0, keyc, case_c
	beq $a0, keyd, case_d
	beq $a0, keye, case_e
	beq $a0, keyf, case_f
 
case_0: 
	li $s0, '0'  # $s0 store code in char type
	j storeCode
case_1: 
	li $s0, '1'
	j storeCode
case_2: 
	li $s0, '2'
	j storeCode
case_3: 
	li $s0, '3'
	j storeCode
case_4: 
	li $s0, '4'
	j storeCode
case_5: 
	li $s0, '5'
	j storeCode
case_6: 
	li $s0, '6'
	j storeCode
case_7: 
	li $s0, '7'
	j storeCode
case_8: 
	li $s0, '8'
	j storeCode
case_9: 
	li $s0, '9'
	j storeCode
case_a: 
	li $s0, 'a'
	j storeCode
case_b: 
	li $s0, 'b'
	j storeCode
case_c: 
	li $s0, 'c'
	j storeCode
case_d: 
	li $s0, 'd'
	j storeCode
case_e: 
	li $s0, 'e'
	j storeCode
case_f: 
	li $s0, 'f'
	j storeCode
 
storeCode: 
	la  $s1, control_code
	la $s2, code_length
	lw $s3, 0($s2)   # $s3 = strlen(control_code)
	addi $t4, $t4, -1   # $t4 = i 

storeCodeLoop: 
	addi $t4, $t4, 1
	bne $t4, $s3, storeCodeLoop
	add $s1, $s1, $t4  # $s1 = control_code + i
	sb $s0, 0($s1)   # control_code[i] = $s0
    
	addi $s0, $zero, '\n'  # add '\n' character to end of string
	addi $s1, $s1, 1
	sb $s0, 0($s1)
    
	addi $s3, $s3, 1
	sw $s3, 0($s2)   # update code_length
  
#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:
	mfc0 $at, $14  # $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4  # $at = $at + 4 (next instruction)
	mtc0 $at, $14  # Coproc0.$14 = Coproc0.epc <= $at
#--------------------------------------------------------
# RESTORE the REG FILE from STACK
#--------------------------------------------------------
restore: 
	lw $s3, 0($sp)
	addi $sp, $sp, -4
	lw $t4, 0($sp)
	addi $sp, $sp, -4
	lw $s2, 0($sp)
	addi $sp, $sp, -4
	lw $s1, 0($sp)
	addi $sp, $sp, -4
	lw $s0, 0($sp)
	addi $sp, $sp, -4
	lw $at, 0($sp)
	addi $sp, $sp, -4
	lw $a0, 0($sp)
	addi $sp, $sp, -4
	lw $t3, 0($sp)
	addi $sp, $sp, -4
	lw $t2, 0($sp)
	addi $sp, $sp, -4
	lw $t1, 0($sp)
	addi $sp, $sp, -4
	lw $ra, 0($sp)
	addi $sp, $sp, -4
return: eret # Return from exception
