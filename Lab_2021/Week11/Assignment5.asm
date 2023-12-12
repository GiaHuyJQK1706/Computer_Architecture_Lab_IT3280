.eqv KEY_CODE 0xFFFF0004 # ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 # =1 if has a new keycode ?
# Auto clear after lw
.eqv DISPLAY_CODE 0xFFFF000C # ASCII code to show, 1 byte
.eqv DISPLAY_READY 0xFFFF0008 # =1 if the display has already to do
# Auto clear after sw
.eqv MASK_CAUSE_KEYBOARD 0x0000034 # Keyboard Cause
.text
	li 	$k0, KEY_CODE
	li 	$k1, KEY_READY
	li 	$s0, DISPLAY_CODE
	li 	$s1, DISPLAY_READY
loop: 
	nop
WaitForKey: 
	lw 	$t1, 0($k1) 		# $t1 = [$k1] = KEY_READY
	beq 	$t1, $zero, WaitForKey	# if $t1 == 0 then Polling
MakeIntR: 
	teqi 	$t1, 1 			# if $t0 = 1 then raise an Interrupt
	j 	loop
#---------------------------------------------------------------
# Interrupt subroutine
#---------------------------------------------------------------
.ktext 0x80000180
get_caus: 
	mfc0 	$t1, $13 		# $t1 = Coproc0.cause
IsCount: 
	li 	$t2, MASK_CAUSE_KEYBOARD	# if Cause value confirm Keyboard..
	and	$at, $t1,$t2
	beq 	$at,$t2, Counter_Keyboard
	j 	end_process
Counter_Keyboard:
ReadKey: 
	lw 	$t0, 0($k0) 	# $t0 = [$k0] = KEY_CODE
WaitForDis: 
	lw 	$t2, 0($s1) 	# $t2 = [$s1] = DISPLAY_READY
	beq 	$t2, $zero, WaitForDis # if $t2 == 0 then Polling
Encrypt: 
	addi 	$t0, $t0, 1	# change input key
ShowKey: 
	sw 	$t0, 0($s0) 	# show key
	nop
end_process:
next_pc: 
	mfc0 	$at, $14 	# $at <= Coproc0.$14 = Coproc0.epc
	addi 	$at, $at, 4 	# $at = $at + 4 (next instruction)
	mtc0 	$at, $14 	# Coproc0.$14 = Coproc0.epc <= $at
return: 
	eret 			# Return from exception