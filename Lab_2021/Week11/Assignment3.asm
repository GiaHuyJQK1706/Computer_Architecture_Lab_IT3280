.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.data
Message: .asciiz "Key scan code "
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MAIN Procedure
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.text
main:
#---------------------------------------------------------
# Enable interrupts you expect
#---------------------------------------------------------
# Enable the interrupt of Keyboard matrix 4x4 of Digital Lab Sim
	li 	$t1, IN_ADRESS_HEXA_KEYBOARD
	li 	$t3, 0x80 		# bit 7 = 1 to enable
	sb 	$t3, 0($t1)
#---------------------------------------------------------
# Loop an print sequence numbers
#---------------------------------------------------------
	xor 	$s0, $s0, $s0 		# count = $s0 = 0
Loop: 
	addi 	$s0, $s0, 1 		# count = count + 1
prn_seq:
	addi 	$v0,$zero,1
	add 	$a0,$s0,$zero 		# print auto sequence number
	syscall
prn_eol:
	addi 	$v0,$zero,11
	li 	$a0,'\n' 		# print endofline
	syscall
sleep: 
	addi 	$v0,$zero,32
	li 	$a0,300	 		# sleep 300 ms
	syscall
	nop 				# WARNING: nop is mandatory here.
	b Loop 				# Loop
end_main:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
#-------------------------------------------------------
# SAVE the current REG FILE to stack
#-------------------------------------------------------
IntSR: 
	addi 	$sp,$sp,4 	# Save $ra because we may change it later
	sw 	$ra,0($sp)
	addi 	$sp,$sp,4 	# Save $at because we may change it later
	sw 	$at,0($sp)
	addi 	$sp,$sp,4	# Save $sp because we may change it later
	sw 	$v0,0($sp)
	addi 	$sp,$sp,4 	# Save $a0 because we may change it later
	sw 	$a0,0($sp)
	addi 	$sp,$sp,4 	# Save $t1 because we may change it later
	sw 	$t1,0($sp)
	addi 	$sp,$sp,4 	# Save $t3 because we may change it later
	sw 	$t3,0($sp)
#--------------------------------------------------------
# Processing
#--------------------------------------------------------
prn_msg:
	addi 	$v0, $zero, 4
	la 	$a0, Message
	syscall
get_cod:
li 	$t1, IN_ADRESS_HEXA_KEYBOARD
	li 	$t3, 0x81 	# check row 4 and re-enable bit 7
	sb 	$t3, 0($t1) 	# must reassign expected row
	li 	$t1, OUT_ADRESS_HEXA_KEYBOARD
	lb 	$a0, 0($t1)
	bne 	$a0, $zero, prn_cod
	
	li 	$t1, IN_ADRESS_HEXA_KEYBOARD
	li 	$t3, 0x82 	# check row 4 and re-enable bit 7
	sb 	$t3, 0($t1) 	# must reassign expected row
	li 	$t1, OUT_ADRESS_HEXA_KEYBOARD
	lb 	$a0, 0($t1)
	bne 	$a0, $zero, prn_cod
	
	li 	$t1, IN_ADRESS_HEXA_KEYBOARD
	li 	$t3, 0x84 	# check row 4 and re-enable bit 7
	sb 	$t3, 0($t1) 	# must reassign expected row
	li 	$t1, OUT_ADRESS_HEXA_KEYBOARD
	lb 	$a0, 0($t1)
	bne 	$a0, $zero, prn_cod
	
	li 	$t1, IN_ADRESS_HEXA_KEYBOARD
	li 	$t3, 0x88 	# check row 4 and re-enable bit 7
	sb 	$t3, 0($t1) 	# must reassign expected row
	li 	$t1, OUT_ADRESS_HEXA_KEYBOARD
	lb 	$a0, 0($t1)
	bne 	$a0, $zero, prn_cod

		
prn_cod:
	li 	$v0,34
	syscall
	li 	$v0,11
	li 	$a0,'\n' 	# print endofline
	syscall
#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:
	mfc0 	$at, $14 	# $at <= Coproc0.$14 = Coproc0.epc
	addi 	$at, $at, 4 	# $at = $at + 4 (next instruction)
	mtc0 	$at, $14 	# Coproc0.$14 = Coproc0.epc <= $at
#--------------------------------------------------------
# RESTORE the REG FILE from STACK
#--------------------------------------------------------
restore:
	lw 	$t3, 0($sp) 	# Restore the registers from stack
	addi 	$sp,$sp,-4
	lw 	$t1, 0($sp) 	# Restore the registers from stack
	addi 	$sp,$sp,-4
	lw 	$a0, 0($sp) 	# Restore the registers from stack
	addi 	$sp,$sp,-4
	lw 	$v0, 0($sp) 	# Restore the registers from stack
	addi 	$sp,$sp,-4
	lw 	$ra, 0($sp)	# Restore the registers from stack
	addi 	$sp,$sp,-4
	lw 	$ra, 0($sp) 	# Restore the registers from stack
	addi 	$sp,$sp,-4
return: 
	eret 			# Return from exception


