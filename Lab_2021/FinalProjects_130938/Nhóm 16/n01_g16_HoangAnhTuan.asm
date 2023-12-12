.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014

.eqv KEY_CODE 0xFFFF0004 	# ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 	# =1 if has a new keycode ?
 				# Auto clear after lw
#-------------------------------------------------------------------------------
# Key value
	.eqv KEY_0 0x11
	.eqv KEY_1 0x21
	.eqv KEY_2 0x41
	.eqv KEY_3 0x81
	.eqv KEY_4 0x12
	.eqv KEY_5 0x22
	.eqv KEY_6 0x42
	.eqv KEY_7 0x82
	.eqv KEY_8 0x14
	.eqv KEY_9 0x24
	.eqv KEY_a 0x44
	.eqv KEY_b 0x84
	.eqv KEY_c 0x18
	.eqv KEY_d 0x28
	.eqv KEY_e 0x48
	.eqv KEY_f 0x88
#-------------------------------------------------------------------------------
# Marsbot
.eqv HEADING 0xffff8010 	# Integer: An angle between 0 and 359
 				# 0 : North (up)
 				# 90: East (right)
				# 180: South (down)
				# 270: West (left)
.eqv MOVING 0xffff8050 		# Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 	# Boolean (0 or non-0):
 				# whether or not to leave a track
.eqv WHEREX 0xffff8030 		# Integer: Current x-location of MarsBot
.eqv WHEREY 0xffff8040 		# Integer: Current y-location of MarsBot

#===============================================================================
#===============================================================================
.data

#Control code
	MOVE_CODE: 	.asciiz "1b4"
	STOP_CODE: 	.asciiz "c68"
	GO_LEFT_CODE: 	.asciiz "444"
	GO_RIGHT_CODE: 	.asciiz "666"
	TRACK_CODE: 	.asciiz "dad"
	UNTRACK_CODE: 	.asciiz "cbc"
	GO_BACK_CODE: 	.asciiz "999"
	WRONG_CODE: 	.asciiz "Wrong code!"
#-------------------------------------------------------------------------------
	inputControlCode: 	.space 50
	lengthControlCode: 	.word 0
	nowHeading: 		.word 0
#---------------------------------------------------------
# duong di cua marsbot duoc luu tru vao mang path
# moi 1 diem duoc luu tru duoi dang 1 structure
# 1 structure co dang {x, y, z}
# trong do: 	x, y la toa do diem
#		z la huong cua canh do
# mac dinh:	structure dau tien se la {0,0,90}
#---------------------------------------------------------
	path: 		.space 600
	lengthPath: 	.word 12		# bytes
	
	isGoing:	.word 0
	isTracking:	.word 0
	isRight: 	.word 0

#===============================================================================
#===============================================================================
.text	
main:
	li $k0, KEY_CODE
 	li $k1, KEY_READY
#---------------------------------------------------------
# Enable the interrupt of Keyboard matrix 4x4 of Digital Lab Sim
#---------------------------------------------------------
	li $t1, IN_ADDRESS_HEXA_KEYBOARD
	li $t3, 0x80 # bit 7 = 1 to enable
	sb $t3, 0($t1)
#---------------------------------------------------------
# Init
#---------------------------------------------------------
	sw $zero, isGoing
	sw $zero, isTracking
	
	# Luu toa do goc xuat phat vao mang path
	la $s2, lengthPath
	lw $s3, 0($s2)		# $s3 = lengthPath (dv: byte)
	
	la $s4, path
	add $s4, $s4, $s3	# vi tri bat dau luu
	
	sw $zero, 0($s4)	# luu x
	sw $zero, 4($s4)	# luu y
	
	li $s1, 90
	sw $s1, 8($s4)		# luu huong ban dau heading = 90
	sw $s1, nowHeading
					
	jal ROTATE
	nop
	addi $s3, $s3, 12	# lengthPath = lengthPath + 12
				# 12 = 3 (word) x 4 (bytes)
	sw $s3, 0($s2)		

# XU LY LENH KICH HOAT TU KEYBOARD & DISPLAY MMIO SIMULATOR
loop:		nop
WaitForKey:	lw $t5, 0($k1)			# $t5 = [$k1] = KEY_READY
		beq $t5, $zero, WaitForKey	#neu $t5 == 0 thi lap lai  
		nop
		beq $t5, $zero, WaitForKey		
ReadKey:	lw $t6, 0($k0)			# $t6 = [$k0] = KEY_CODE
		# DELETE
		beq $t6, 127 , continue		# neu $t6 == delete key thi xoa input
						# 127 la delete key trong ma ascii
		nop
		beq $t6, 32, repeat		# neu $t6 == space key thi lap lai
						# ma dieu khien truoc do 
		nop
		# Neu lenh nhap vao khong nam trong 3 lenh enter, delete va space
		# thi se khong xu ly va tiep tuc cho user nhap lenh dung
		bne $t6, '\n' , loop		# neu $t6 != '\n' thi quay lai loop
		nop
		bne $t6, '\n' , loop
		
# neu $t6 == Enter key thi xu ly ma dieu khien duoc nhap vao 
		
check:
		# Kiem tra do dai ma dieu khien 
		la $s2, lengthControlCode
		lw $s2, 0($s2)
		#----------------
		bne $s2, 3, error
		
		# So sanh ma dieu khien nhap vao voi ma tieu chuan (1b4, c68,...)
		# neu ma dieu khien hop le thi cho marsbot thuc hien cac hang dong 
		# tuong ung
		la $s3, MOVE_CODE
		jal isEqual
		beq $t0, 1, go
		
		la $s3, STOP_CODE
		jal isEqual
		beq $t0, 1, stop	
		
		la $s3, GO_LEFT_CODE
		jal isEqual
		beq $t0, 1, goLeft
				
		la $s3, GO_RIGHT_CODE
		jal isEqual
		beq $t0, 1, goRight
		
		la $s3, TRACK_CODE
		jal isEqual
		beq $t0, 1, track
		
		la $s3, UNTRACK_CODE
		jal isEqual
		beq $t0, 1, untrack
		
		la $s3, GO_BACK_CODE
		jal isEqual
		beq $t0, 1, goBack
		
		# Neu khong khop voi ma dieu khien nao -> hien thi loi 
		beq $t0, 0, error
		nop
repeat:	
	# backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	addi $sp,$sp,4
	sw $s7, 0($sp)
	addi $sp,$sp,4
	sw $t6, 0($sp)
	addi $sp,$sp,4
	sw $t7, 0($sp)
	addi $sp,$sp,4
	sw $t8, 0($sp)
	addi $sp,$sp,4
	sw $t9, 0($sp)
	addi $sp,$sp,4
	sw $s0, 0($sp)
	
	# processsing
	lw $t9, isGoing
	beqz	$t9, noGo
	nop
	lw $s0, isTracking
	lw $t6, isRight
	beq $t6, 2, repeat_end
	nop
	jal STOP
	nop
	jal UNTRACK
	nop
	
	la $s7, path
	la $s5, lengthPath
	lw $s5, 0($s5)		# $s5 = lengthPath
	add $s7, $s7, $s5	# $s7 = &path[lengthPath]
	
	addi $s5, $s5, -12 	# lui lai 1 structure
	
	addi $s7, $s7, -12	# vi tri luu tru thong tin ve canh cuoi cung
	lw $s6, 8($s7)		# huong cua canh cuoi cung
	
	la $t8, nowHeading	# gan huong truoc do cho marsbot
	lw $s6, 0($t8)
	
	beqz $t6, turnLeft	# Neu isRight = 0 thi marsbot 
	nop			# dang re trai
turnRight:	
 	add $s6, $s6, 90
	j next_repeat
	nop
turnLeft:
	add $s6, $s6, -90
next_repeat:
	sw $s6, 0($t8)
	jal storePath
	jal ROTATE
	nop
	
	beqz	$s0, noTrack
	nop
	jal	TRACK
noTrack:	nop
	
	beqz	$t9, noGo
	nop
	jal	GO
noGo:	nop
repeat_end:		
	# restore
	lw $s0, 0($sp)
	addi $sp,$sp,-4
	lw $t9, 0($sp)
	addi $sp,$sp,-4
	lw $t8, 0($sp)
	addi $sp,$sp,-4
	lw $t7, 0($sp)
	addi $sp,$sp,-4
	lw $t6, 0($sp)
	addi $sp,$sp,-4
	lw $s7, 0($sp)
	addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	j printControlCode				
# Print control code to console	
printControlCode:	
	li $v0, 4
	la $a0, inputControlCode
	syscall
	nop

# Xoa lenh vua duoc nhap vao va quay lai cho user nhap lenh moi 	
continue:
	jal remove			
	nop
	j loop
	nop
	j loop
#-----------------------------------------------------------
# luu canh hien tai vao mang path
# param[in] 	nowHeading 
#		lengthPath 
#-----------------------------------------------------------	
storePath:
	# backup
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	addi $sp,$sp,4
	sw $t4, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $s2, 0($sp)
	addi $sp,$sp,4
	sw $s3, 0($sp)
	addi $sp,$sp,4
	sw $s4, 0($sp)
	
	# processing
	li $t1, WHEREX
	lw $s1, 0($t1)		# s1 = x
	abs $s1, $s1
	
	li $t2, WHEREY	
	lw $s2, 0($t2)		# s2 = y
	abs $s2, $s2
	
	la $s4, nowHeading
	lw $s4, 0($s4)		# s4 = now heading

	la $t3, lengthPath
	lw $s3, 0($t3)		# $s3 = lengthPath (dv: byte)
	
	la $t4, path
	add $t4, $t4, $s3	# vi tri bat dau luu
	
	sw $s1, 0($t4)		# luu x
	sw $s2, 4($t4)		# luu y
	sw $s4, 8($t4)		# luu huong hien tai heading
	
	addi $s3, $s3, 12	# lengthPath = lengthPath + 12
				# 12 = 3 (word) x 4 (bytes)
	sw $s3, 0($t3)
	
	# restore
	lw $s4, 0($sp)
	addi $sp,$sp,-4
	lw $s3, 0($sp)
	addi $sp,$sp,-4
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t4, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop	
	jr $ra
#-----------------------------------------------------------
# Dieu khien cho marsbot di nguoc lai
#-----------------------------------------------------------		
goBack:
	# Disable interrupts when going backward
	li	$t7, IN_ADDRESS_HEXA_KEYBOARD	
    	sb	$zero, 0($t7)
	
	# backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	addi $sp,$sp,4
	sw $s7, 0($sp)
	addi $sp,$sp,4
	sw $t8, 0($sp)
	addi $sp,$sp,4
	sw $t9, 0($sp)
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	
	jal UNTRACK
	jal GO
	la $s7, path
	la $s5, lengthPath
	lw $s5, 0($s5)		# $s5 = lengthPath
	add $s7, $s7, $s5	# $s7 = &path[lengthPath]
begin:	
	addi $s5, $s5, -12 	# lui lai 1 structure
	
	addi $s7, $s7, -12	# vi tri luu tru thong tin ve canh cuoi cung
	lw $s6, 8($s7)		# huong cua canh cuoi cung
	addi $s6, $s6, 180	# dao nguoc lai huong cua canh cuoi cung
	
	
	la $t8, nowHeading	# marsbot quay nguoc lai
	sw $s6, 0($t8)
	jal ROTATE
	
loop_go_back:	
	lw $t9, 0($s7)		# toa do x cua diem cuoi cua canh
	li $t8, WHEREX		# toa do x hien tai
	lw $t8, 0($t8)
	abs $t8, $t8
	
	bne $t8, $t9, loop_go_back
	nop
	bne $t8, $t9, loop_go_back
	
	lw $t9, 4($s7)		# toa do y cua diem cuoi cua canh
	li $t8, WHEREY		# toa do y hien tai
	lw $t8, 0($t8)
	abs $t8, $t8
	
	bne $t8, $t9, loop_go_back
	nop
	bne $t8, $t9, loop_go_back
	
	beq $s5, 0, finish
	nop
	beq $s5, 0, finish
	
	j begin
	nop
	j begin
finish:
	jal STOP
	
	la $t8, nowHeading
	li $t9, 90
	sw $t9, 0($t8)		# cap nhat lai huong
	la $t8, lengthPath
	addi $s5, $zero, 12
	sw $s5, 0($t8)		# gan lai lengthPath = 12
	
	
	li $t1, IN_ADDRESS_HEXA_KEYBOARD
	li $t3, 0x80 # bit 7 = 1 to enable
	sb $t3, 0($t1)
	# restore
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	lw $t9, 0($sp)
	addi $sp,$sp,-4
	lw $t8, 0($sp)
	addi $sp,$sp,-4
	lw $s7, 0($sp)
	addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal ROTATE
	j printControlCode
#-----------------------------------------------------------
# Dieu khien marsbot de lai vet va in ra control code
#-----------------------------------------------------------	
track: 	jal TRACK
	j printControlCode
#-----------------------------------------------------------
# Dieu khien marsbot khong de lai vet va in ra control code
#-----------------------------------------------------------	
untrack: jal UNTRACK
	 j printControlCode
#-----------------------------------------------------------
# Dieu khien cho marsbot bat dau di chuyen va in ra control code
#-----------------------------------------------------------	
go: 	
	# backup
	addi $sp,$sp,4
	sw $t6, 0($sp)
	addi $sp,$sp,4
	sw $t7, 0($sp)
	
	la $t6, isRight
	li $t7, 2		# Neu ma nhap vao la 1b4 thi 
				# luc bam space marsbot se khong doi 
				# huong
	sw $t7, 0($t6)
	
	# restore
	lw $t6, 0($sp)
	addi $sp,$sp,-4
	lw $t7, 0($sp)
	addi $sp,$sp,-4
	jal GO
	j printControlCode
#-----------------------------------------------------------
# Dieu khien cho marsbot dung lai va in ra control code
#-----------------------------------------------------------	
stop: 	jal STOP
	j printControlCode
#-----------------------------------------------------------
# Dieu khien cho marsbot di sang phai va in ra control code
#-----------------------------------------------------------	
# goRight procedure, control marsbot to go left and print control code
# param[in] nowHeading 
# param[out] nowHeading 
#-----------------------------------------------------------	
goRight:
	# backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	addi $sp,$sp,4
	sw $t6, 0($sp)
	#addi $sp,$sp,4
	#sw $t7, 0($sp)
	#addi $sp,$sp,4
	#sw $s0, 0($sp)
	addi $sp,$sp,4
	sw $t8, 0($sp)
	
	# processsing
	lw $t7, isGoing
	lw $s0, isTracking
	la $t8, isRight
	jal STOP
	nop
	jal UNTRACK
	nop
	
	la $s5, nowHeading
	lw $s6, 0($s5)		# $s6 - huong hien tai
	addi $s6, $s6, 90	
	sw $s6, 0($s5)    	# cap nhat lai nowHeading = nowHeading + 90
	
	li $t6, 1
	sw $t6, 0($t8)		# isRight = 1

	# restore
	lw $t8, 0($sp)
	addi $sp,$sp,-4
	#lw $s0, 0($sp)
	#addi $sp,$sp,-4
	#lw $t7, 0($sp)
	#ddi $sp,$sp,-4
	lw $t6, 0($sp)
	addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal storePath
	jal ROTATE
	
	beqz	$s0, noTrack1
	nop
	jal	TRACK
noTrack1:	nop
	
	beqz	$t7, noGo1
	nop
	jal	GO
noGo1:	nop
	
	j printControlCode	
#-----------------------------------------------------------
#dieu khien cho marsbot di sang trai va in ra control code
#-----------------------------------------------------------	
goLeft:	
	# backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	# add
	# sw $t7, 0($sp)
	# addi $sp,$sp,4
	# sw $s0, 0($sp)
	addi $sp,$sp,4
	sw $t8, 0($sp)
	
	# processing
	lw $t7, isGoing
	lw $s0, isTracking
	la $t8, isRight
	jal	STOP
	nop
	jal	UNTRACK
	nop
	
	la $s5, nowHeading
	lw $s6, 0($s5)		# $s6 huong hien tai
	addi $s6, $s6, -90 
	sw $s6, 0($s5) 		# cap nhat nowHeading = nowHeading - 90
	
	sw $zero, 0($t8)		# isRight = 0
	
	# restore
	lw $t8, 0($sp)
	addi $sp,$sp,-4
	#lw $s0, 0($sp)
	#addi $sp,$sp,-4
	#lw $t7, 0($sp)
	#addi $sp,$sp,-4
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal storePath
	jal ROTATE
	
	beqz	$s0, noTrack2
	nop
	jal	TRACK
noTrack2:	nop
	
	beqz	$t7, noGo2
	nop
	jal	GO
noGo2:	nop
	j printControlCode				
#-----------------------------------------------------------
#Xoa inputControlCode 
#-----------------------------------------------------------				
remove:
	# backup
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	addi $sp,$sp,4
	sw $s2, 0($sp)
	
	# processing
	# Tao 1 vong lap duyet qua tung ky tu cua mang inputControlCode
	# va thay the no bang '\0', sau do cap nhat lai lengthControlCode
	la $s2, lengthControlCode
	lw $t3, 0($s2)				# $t3 = lengthControlCode
	addi $t1, $zero, -1			# $t1 = -1 = i
	la $s1, inputControlCode		# $s1 = &inputControlCode
	addi $s1, $s1, -1			# $s1 = &inputControlCode - 1
	remove_input_code:
		addi $t1, $t1, 1		# i++
	
		add $s1, $s1, 1			# $s1 = &inputControlCode + 1
		sb $zero, 0($s1)		# inputControlCode[i] = '\0'
				         
		bne $t1, $t3, remove_input_code	# Neu $t1 <= 3 quay lai for_loop_to_remove
		nop
		bne $t1, $t3, remove_input_code		
				
	sw $zero, 0($s2)				# lengthControlCode = 0
		
	# restore
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# Kiem tra inputControlCode co trung voi cac code dieu khien
# neu dung thi $t0 = 1 con khong dung thi $t0 = 0
#-----------------------------------------------------------					
isEqual:
	#backup
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)	
	
	#processing
	addi $t1, $zero, -1			# $t1 = -1 = i
	la $s1, inputControlCode		# $s1 = &inputControlCode
	check_equal:
		addi $t1, $t1, 1		# i++
	
		add $t2, $s1, $t1		# $t2 = inputControlCode + i
		lb $t2, 0($t2)			# $t2 = inputControlCode[i]
		
		add $t3, $s3, $t1		# $t3 = s + i
		lb $t3, 0($t3)			# $t3 = s[i]
		
		bne $t2, $t3, notEqual		# Neu $t2 != $t3 -> khong trung
		nop
		
		bne $t1, 2, check_equal		# Neu $t1 <=2 quay lai check_equal
		nop
		bne $t1, 2, check_equal
equal:
	# restore
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	add $t0, $zero, 1	# $t0 = 1 -> return true
	jr $ra
	nop
	jr $ra
notEqual:
	#restore
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4

	add $t0, $zero, $zero	# $t0 = 0 -> return false
	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# Thong bao loi
#-----------------------------------------------------------					
error:
	li $v0, 4
	la $a0, inputControlCode
	syscall
	nop
	
	li $v0, 55
	la $a0, WRONG_CODE
	syscall
	nop
	
	nop
	j continue
	nop
	j continue			
#-----------------------------------------------------------
# Bat dau di chuyen
#-----------------------------------------------------------
GO: 	
	# backup
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	addi $sp,$sp,4
	sw $t7,0($sp)
	
	# processing
	li $at, MOVING 		# change MOVING port
 	addi $k0, $zero,1 	# to logic 1,
	sb $k0, 0($at) 		# to start running 	
	
	li	$t7, 1			# isGoing = 1
	sw	$t7, isGoing	
	
	# restore
	lw $t7, 0($sp)
	addi $sp,$sp,-4
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# Dung marsbot
#-----------------------------------------------------------
STOP: 	# backup
	addi $sp,$sp,4
	sw $at,0($sp)
	
	# processing
	li $at, MOVING 		#change MOVING port to 0
	sb $zero, 0($at) 	#to stop
	
	sw $zero, isGoing	# isGoing = 0
	# restore
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# Bat dau de lai vet
#-----------------------------------------------------------
TRACK: 	
	# backup
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	addi $sp,$sp,4
	sw $s0,0($sp)
	
	# processing
	li $at, LEAVETRACK 	# change LEAVETRACK port
	addi $k0, $zero,1 	# to logic 1,
 	sb $k0, 0($at) 		# to start tracking
 	
 	addi	$s0, $zero, 1
 	sw	$s0, isTracking	# set isTracking = 1
 	
 	# restore
	lw $s0, 0($sp)
	addi $sp,$sp,-4
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# Dung de lai vet
#-----------------------------------------------------------
UNTRACK:
	# backup
	addi $sp,$sp,4
	sw $at,0($sp)
	
	# processing
	li $at, LEAVETRACK 	#change LEAVETRACK port to 0
 	sb $zero, 0($at) 	#to stop drawing tail
 	
 	sw	$zero, isTracking	# set isTracking = 0
 	# restore
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# chuyen huong cho marsbot
#-----------------------------------------------------------
ROTATE: 
	# backup
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	
	# processing
	li $t1, HEADING 	# change HEADING port
	la $t2, nowHeading
	lw $t3, 0($t2)		
 	sw $t3, 0($t1) 		# to rotate marsbot
 	
 	# restore
 	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra	
		
#===============================================================================
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
#-------------------------------------------------------
# SAVE the current REG FILE to stack
#-------------------------------------------------------
backup: 
	addi $sp,$sp,4
	sw $ra,0($sp)
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	addi $sp,$sp,4
	sw $a0,0($sp)
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $s0,0($sp)
	addi $sp,$sp,4
	sw $s1,0($sp)
	addi $sp,$sp,4
	sw $s2,0($sp)
	addi $sp,$sp,4
	sw $t4,0($sp)
	addi $sp,$sp,4
	sw $s3,0($sp)
	
	
#--------------------------------------------------------
# Processing - Nhap ma dieu khien 
#--------------------------------------------------------
 
get_code:
	li $t1, IN_ADDRESS_HEXA_KEYBOARD
	li $t2, OUT_ADDRESS_HEXA_KEYBOARD
scan_row1:
	li $t3, 0x81
	sb $t3, 0($t1)
	lbu $a0, 0($t2)		# Lay ki tu sau khi an 
	bnez $a0, get_code_in_char
scan_row2:
	li $t3, 0x82
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
scan_row3:
	li $t3, 0x84
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
scan_row4:
	li $t3, 0x88
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
	
# Kiem tra ki tu nhap vao khop voi key nao 
get_code_in_char:
	beq $a0, KEY_0, case_0
	beq $a0, KEY_1, case_1
	beq $a0, KEY_2, case_2
	beq $a0, KEY_3, case_3
	beq $a0, KEY_4, case_4
	beq $a0, KEY_5, case_5
	beq $a0, KEY_6, case_6
	beq $a0, KEY_7, case_7
	beq $a0, KEY_8, case_8
	beq $a0, KEY_9, case_9
	beq $a0, KEY_a, case_a
	beq $a0, KEY_b, case_b
	beq $a0, KEY_c, case_c
	beq $a0, KEY_d, case_d
	beq $a0, KEY_e, case_e
	beq $a0, KEY_f, case_f
	
	#$s0 store code in char type
case_0:	li $s0, '0'
	j store_code
case_1:	li $s0, '1'
	j store_code
case_2:	li $s0, '2'
	j store_code
case_3:	li $s0, '3'
	j store_code
case_4:	li $s0, '4'
	j store_code
case_5:	li $s0, '5'
	j store_code
case_6:	li $s0, '6'
	j store_code
case_7:	li $s0, '7'
	j store_code
case_8:	li $s0, '8'
	j store_code
case_9:	li $s0, '9'
	j store_code
case_a:	li $s0, 'a'
	j store_code
case_b:	li $s0, 'b'
	j store_code
case_c:	li $s0, 'c'
	j store_code
case_d:	li $s0, 'd'
	j store_code
case_e:	li $s0,	'e'
	j store_code
case_f:	li $s0, 'f'
	j store_code
store_code:
	la $s1, inputControlCode	# $s1 = &inputControlCode
	la $s2, lengthControlCode	# $s2 = &lengthControlCode
	lw $s3, 0($s2)			# $s3 = strlen(inputControlCode)
	addi $t4, $t4, -1 		# $t4 = i = -1
	
	for_loop_to_store_code:
		addi 	$t4, $t4, 1		# i++
	# Neu i != lengthControlCode thi quay lai vong lap
	# va tang i len 1. Cho den khi i = lengthControlCode
	# Luc nay i chinh la vi tri can dien ky tu (code) vua nhap vao
		bne 	$t4, $s3, for_loop_to_store_code
		
		# Gan ky tu moi cho s[i]
		add 	$s1, $s1, $t4		# $s1 = inputControlCode[i]
		sb  	$s0, 0($s1)		# inputControlCode[i] = $s0
		
		# Them ky tu ket thuc chuoi vao cuoi chuoi inputControlCode
		addi 	$s0, $zero, '\n'	
		addi 	$s1, $s1, 1	
		sb  	$s0, 0($s1)		
		
		# Cap nhat do dai cua chuoi inputControlCode
		addi $s3, $s3, 1
		sw $s3, 0($s2)			
		
#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:
	mfc0 $at, $14 		# $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4 	# $at = $at + 4 (next instruction)
	mtc0 $at, $14 		# Coproc0.$14 = Coproc0.epc <= $at
#--------------------------------------------------------
# RESTORE the REG FILE from STACK
#--------------------------------------------------------
restore:
	lw $s3, 0($sp)
	addi $sp,$sp,-4
	lw $t4, 0($sp)
	addi $sp,$sp,-4
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $s0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	lw $a0, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	lw $ra, 0($sp)
	addi $sp,$sp,-4
return: eret # Return from exception

