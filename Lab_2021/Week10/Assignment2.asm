.eqv SEVENSEG_LEFT    0xFFFF0011	# Dia chi cua den led 7 doan trai.
					# Bit 0 = doan a; #     Bit 1 = doan b; ... 
					# Bit 7 = dau .
.eqv SEVENSEG_RIGHT   0xFFFF0010	# Dia chi cua den led 7 doan phai
.data
	message: .asciiz "Nhap vao mot so nguyen: "
.text
main:	
	li	$v0, 4
	la	$a0, message
	syscall
	li 	$v0, 5
	syscall
	move 	$s0, $v0
	li	$t2, 10
	div	$s0, $t2
	mfhi	$t1
	case0r:	bne	$t1, 0, case1r
	li	$a0, 0x3F
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case1r:	bne	$t1, 1, case2r
	li	$a0, 0x6
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case2r:	bne	$t1, 2, case3r
	li	$a0, 0x5B
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case3r:	bne	$t1, 3, case4r
	li	$a0, 0x4F
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case4r:	bne	$t1, 4, case5r
	li	$a0, 0x66
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case5r:	bne	$t1, 5, case6r
	li	$a0, 0x6D
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case6r:	bne	$t1, 6, case7r
	li	$a0, 0x7D
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case7r:	bne	$t1, 7, case8r
	li	$a0, 0x7
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case8r:	bne	$t1, 8, case9r
	li	$a0, 0x7F
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
case9r:	bne	$t1, 9, defaultr
	li	$a0, 0x6F
	jal    	SHOW_7SEG_RIGHT
	j 	defaultr
defaultr:
	sub	$s0, $s0, $t1
	div	$s0, $t2
	mflo	$t3
	div	$t3, $t2
	mfhi	$t1
case0l:	bne	$t1, 0, case1l
	li	$a0, 0x3F
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case1l:	bne	$t1, 1, case2l
	li	$a0, 0x6
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case2l:	bne	$t1, 2, case3l
	li	$a0, 0x5B
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case3l:	bne	$t1, 3, case4l
	li	$a0, 0x4F
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case4l:	bne	$t1, 4, case5l
	li	$a0, 0x66
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case5l:	bne	$t1, 5, case6l
	li	$a0, 0x6D
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case6l:	bne	$t1, 6, case7l
	li	$a0, 0x7D
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case7l:	bne	$t1, 7, case8l
	li	$a0, 0x7
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case8l:	bne	$t1, 8, case9l
	li	$a0, 0x7F
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
case9l:	bne	$t1, 9, defaultl
	li	$a0, 0x6F
	jal    	SHOW_7SEG_LEFT
	j 	defaultl
defaultl:
	li    	$v0, 10
	syscall
endmain:
#---------------------------------------------------------------
# Function  SHOW_7SEG_LEFT : turn on/off the 7seg
# param[in]  $a0   value to shown       
# remark     $t0 changed
#---------------------------------------------------------------
SHOW_7SEG_LEFT:	
	li   $t0, SEVENSEG_LEFT 	# assign port's address
	sb   $a0, 0($t0)		# assign new value
	jr   $ra
#---------------------------------------------------------------
# Function  SHOW_7SEG_RIGHT : turn on/off the 7seg
# param[in]  $a0   value to shown       
# remark     $t0 changed
#---------------------------------------------------------------
SHOW_7SEG_RIGHT: 
	li   $t0,  SEVENSEG_RIGHT	# assign port's address
	sb   $a0,  0($t0)		# assign new value
	jr   $ra
	
	