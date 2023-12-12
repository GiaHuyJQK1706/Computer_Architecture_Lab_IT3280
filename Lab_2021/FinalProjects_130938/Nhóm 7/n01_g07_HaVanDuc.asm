.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012 # so hang lenh cua ban phim thap luc phan(bit 0 den 3) va cho phep ngat ban phim(bit 7)
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
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
.eqv HEADING 0xffff8010 # Integer: An angle between 0 and 359
 			# 0 : North (up)
 			# 90: East (right)
			# 180: South (down)
			# 270: West (left)
.eqv MOVING 0xffff8050 # Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 # Boolean (0 or non-0):
 			# whether or not to leave a track
.eqv WHEREX 0xffff8030 # Integer: Current x-location of MarsBot
.eqv WHEREY 0xffff8040 # Integer: Current y-location of MarsBot

#===============================================================================
#===============================================================================
.data

#Control code
	MOVE_CODE: .asciiz "1b4"
	STOP_CODE: .asciiz "c68"
	GO_LEFT_CODE: .asciiz "444"
	GO_RIGHT_CODE: .asciiz "666"
	TRACK_CODE: .asciiz "dad"
	UNTRACK_CODE: .asciiz "cbc"
	GO_BACK_CODE: .asciiz "999"
	WRONG_CODE: .asciiz "Wrong control code!"
#-------------------------------------------------------------------------------
	inputControlCode: .space 50 #Mang luu tru ma dieu khien
	lengthControlCode: .word 0 # do dai cua ma dieu khien
	nowHeading: .word 0 # huong di chuyen hien tai cua marbots
#---------------------------------------------------------
# duong di cua masbot duoc luu tru vao mang path
# moi 1 canh duoc luu tru duoi dang 1 structure
# 1 structure co dang {x, y, z}
# trong do: 	x, y la toa do diem dau tien cua canh
#		z la huong cua canh do
# mac dinh:	structure dau tien se la {0,0,0}
# do dai duong di ngay khi bat dau la 12 bytes (3x 4byte)
#---------------------------------------------------------
	path: .space 600 # mang luu tru duong di cua marbot
	lengthPath: .word 12		#do dai duong di (bytes)

#===============================================================================
#===============================================================================
.text	
main:
	li $k0, KEY_CODE
 	li $k1, KEY_READY
#---------------------------------------------------------
# Enable the interrupt of Keyboard matrix 4x4 of Digital Lab Sim
#---------------------------------------------------------
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t3, 0x80 # bit 7 = 1 to enable
	sb $t3, 0($t1)
#---------------------------------------------------------
loop:		nop
WaitForKey:	lw $t5, 0($k1)			#$t5 = [$k1] = KEY_READY
		beq $t5, $zero, WaitForKey	#if $t5 == 0 then Polling 
		nop
		beq $t5, $zero, WaitForKey
ReadKey:		lw $t6, 0($k0)			#$t6 = [$k0] = KEY_CODE
		beq $t6, 127 , continue		#if $t6 == delete key thi xoa input
						#127 la ma ascii cua phim delete
		bne $t6, '\n' , loop		#if $t6 != '\n' then Polling
		nop
		bne $t6, '\n' , loop
CheckControlCode:
		la $s2, lengthControlCode
		lw $s2, 0($s2)
		#----------------
		bne $s2, 3, pushErrorMess # do dai ma dieu khien khac 3 -> bao loi
		
		
		la $s3, MOVE_CODE
		jal isEqualString
		beq $t0, 1, go
		
		la $s3, STOP_CODE
		jal isEqualString
		beq $t0, 1, stop
			
		
		la $s3, GO_LEFT_CODE
		jal isEqualString
		beq $t0, 1, goLeft
		
		la $s3, GO_RIGHT_CODE
		jal isEqualString
		beq $t0, 1, goRight
		
		la $s3, TRACK_CODE
		jal isEqualString
		beq $t0, 1, track

		
		la $s3, UNTRACK_CODE
		jal isEqualString
		beq $t0, 1, untrack
		
		
		la $s3, GO_BACK_CODE
		jal isEqualString
		beq $t0, 1, goBack
		
		beq $t0, 0, pushErrorMess # qua het cac truong hop ma van bang 0 -> ma dieu khien loi
			
printControlCode:	
	li $v0, 4	# print string
	la $a0, inputControlCode
	syscall
	nop
		
continue:
	jal removeControlCode	# xoa ma dieu khien nhap vao		
	nop
	j loop
	nop
	j loop
#-----------------------------------------------------------
# storePath procedure :  luu duong di cua marsbot vao bien path
# param[in] 	nowHeading variable
#		lengthPath variable
#-----------------------------------------------------------	
storePath:
	#backup
	addi $sp,$sp,4
	sw $t1, 0($sp) # toa do x hien tai
	addi $sp,$sp,4
	sw $t2, 0($sp) # toa do y hien tai
	addi $sp,$sp,4
	sw $t3, 0($sp) # do dai duong di
	addi $sp,$sp,4
	sw $t4, 0($sp) # duong di
	addi $sp,$sp,4
	sw $s1, 0($sp) # luu toa do x
	addi $sp,$sp,4
	sw $s2, 0($sp) # luu toa do y
	addi $sp,$sp,4
	sw $s3, 0($sp) # luu do dai duong di
	addi $sp,$sp,4 
	sw $s4, 0($sp) # luu huong di chuyen hien tai
	
	#processing
	li $t1, WHEREX
	lw $s1, 0($t1)		#s1 = x
	li $t2, WHEREY	
	lw $s2, 0($t2)		#s2 = y
	
	la $s4, nowHeading
	lw $s4, 0($s4)		#s4 = now heading

	la $t3, lengthPath
	lw $s3, 0($t3)		#$s3 = lengthPath (dv: byte)
	
	la $t4, path
	add $t4, $t4, $s3	#position to store
	
	sw $s1, 0($t4)		#store x
	sw $s2, 4($t4)		#store y
	sw $s4, 8($t4)		#store heading
	
	addi $s3, $s3, 12	#update lengthPath
				#12 = 3 (word) x 4 (bytes)
	sw $s3, 0($t3)
	
	#restore - phuc hoi
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
	
	jr $ra # ve chuong trinh chinh
	nop
	jr $ra		
#-----------------------------------------------------------
# goBack procedure : dieu khien marsbot di nguoc lai
# param[in] 	path array, lengthPath array
#-----------------------------------------------------------		
goBack:
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp) # do dai duong di
	addi $sp,$sp,4
	sw $s6, 0($sp) # huong di chuyen nguoc lai cua nowHeading
	addi $sp,$sp,4
	sw $s7, 0($sp) # duong di
	addi $sp,$sp,4
	sw $t8, 0($sp) # dat lai nowHeading
	addi $sp,$sp,4
	sw $t9, 0($sp) # thanh ghi sp
	
	jal UNTRACK # khong ve duong di chuyen
	jal GO # di chuyen
	la $s7, path
	la $s5, lengthPath
	lw $s5, 0($s5)
	add $s7, $s7, $s5
begin:
	
	addi $s5, $s5, -12 	#lui lai 1 structure
	
	addi $s7, $s7, -12	# vi tri cua thong tin ve canh cuoi cung
	lw $s6, 8($s7)		#huong cua canh cuoi cung
	addi $s6, $s6, 180	#nguoc lai huong cua canh cuoi cung
	
	
	la $t8, nowHeading	#marsbot quay nguoc lai
	sw $s6, 0($t8)
	jal ROTATE

go_to_first_point_of_edge:	# di den diem dau cua canh
	lw $t9, 0($s7)		#toa do x cua diem dau tien cua canh
	li $t8, WHEREX		#toa do x hien tai
	lw $t8, 0($t8)

	bne $t8, $t9, go_to_first_point_of_edge
	nop
	bne $t8, $t9, go_to_first_point_of_edge
	
	lw $t9, 4($s7)		#toa do y cua diem dau tien cua canh
	li $t8, WHEREY		#toa do y hien tai
	lw $t8, 0($t8)
	
	bne $t8, $t9, go_to_first_point_of_edge
	nop
	bne $t8, $t9, go_to_first_point_of_edge
	
	beq $s5, 0, finish
	nop
	beq $s5, 0, finish
	
	j begin
	nop
	j begin
	
finish:
	jal STOP
	
	la $t8, nowHeading
	add $s6, $zero, $zero
	sw $s6, 0($t8)		#update heading - tro lai bang 0
	la $t8, lengthPath
	addi $s5, $zero, 12
	sw $s5, 0($t8)		#update lengthPath = 12 -mac dinh
	
	#restore - phuc hoi
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
	
	jal ROTATE # quay robot theo huong da cai lai
	j printControlCode # in ma dieu khien
#-----------------------------------------------------------
# track procedure : dieu khien marsbot ve duong di chuyen va in ma dieu khien
# param[in] none
#-----------------------------------------------------------	
track: 	jal TRACK
	j printControlCode
#-----------------------------------------------------------
# untrack procedure :  dieu khien marsbot khong ve duong di chuyen va in ma dieu khien
# param[in] none
#-----------------------------------------------------------	
untrack: jal UNTRACK
	j printControlCode
#-----------------------------------------------------------
# go : cho marsbot di chuyen va in ra ma dieu khien
# param[in] none
#-----------------------------------------------------------	
go: 	
	jal GO
	j printControlCode
#-----------------------------------------------------------
# stop : cho marsbot di chuyen va in ra ma dieu khien
# param[in] none
#-----------------------------------------------------------	
stop: 	jal STOP
	j printControlCode
#-----------------------------------------------------------
# goRight procedure :  dieu khien marsbot quay sang phai va in ra ma dieu khien
# param[in] nowHeading variable
# param[out] nowHeading variable
#-----------------------------------------------------------	
goRight:
	#backup - sao luu du lieu
	addi $sp,$sp,4
	sw $s5, 0($sp) # huong di chuyen hien tai
	addi $sp,$sp,4 
	sw $s6, 0($sp) # goc di chuyen so voi huong di chuyen hien tai
	#restore - phuc hoi du lieu
	la $s5, nowHeading
	lw $s6, 0($s5)	#$s6 tro thanh huong di chuyen hien tai
	addi $s6, $s6, 90 #tang 90 do - di chuyen sang phai
	sw $s6, 0($s5) # update nowHeading
	#restore
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal storePath # luu duong di
	jal ROTATE # quay con bot
	j printControlCode # in ra ma dieu khien
#-----------------------------------------------------------
# goLeft procedure : dieu khien con bot quay sang ben trai va in ma dieu khien
# param[in] nowHeading variable
# param[out] nowHeading variable
#-----------------------------------------------------------	
goLeft:	
	#backup
	addi $sp,$sp,4
	sw $s5, 0($sp)
	addi $sp,$sp,4
	sw $s6, 0($sp)
	#processing
	la $s5, nowHeading
	lw $s6, 0($s5)	#$s6 is heading at now
	addi $s6, $s6, -90 #increase heading by 90*
	sw $s6, 0($s5) # update nowHeading
	#restore
	lw $s6, 0($sp)
	addi $sp,$sp,-4
	lw $s5, 0($sp)
	addi $sp,$sp,-4
	
	jal storePath
	jal ROTATE
	j printControlCode				
#-----------------------------------------------------------
# removeControlCode procedure :  to remove inputControlCode string
#				inputControlCode = ""
# param[in] none
#-----------------------------------------------------------				
removeControlCode:
	#backup - sao luu du lieu
	addi $sp,$sp,4
	sw $t1, 0($sp) # chi so i cua mang
	addi $sp,$sp,4
	sw $t2, 0($sp) # $t2 = inputControlCode[i]
	addi $sp,$sp,4
	sw $s1, 0($sp) # inputControlCode
	addi $sp,$sp,4
	sw $t3, 0($sp) # do dai chuoi - bien tmp
	addi $sp,$sp,4
	sw $s2, 0($sp) # do dai chuoi
	
	#processing - qua trinh xu li
	la $s2, lengthControlCode
	lw $t3, 0($s2)					#$t3 = lengthControlCode
	addi $t1, $zero, -1				#$t1 = -1 = i
	addi $t2, $zero, 0				
	la $s1, inputControlCode
	addi $s1, $s1, -1
	for_loop_to_remove:
		addi $t1, $t1, 1				#i++
	
		add $s1, $s1, 1				#$s1 = inputControlCode + i
		sb $t2, 0($s1)				#inputControlCode[i] = '\0'
				
		bne $t1, $t3, for_loop_to_remove		#if $t1 <=3 continue loop
		nop
		bne $t1, $t3, for_loop_to_remove
		
	add $t3, $zero, $zero			
	sw $t3, 0($s2)					#lengthControlCode = 0
		
	#restore - phuc hoi du lieu
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
# thu tuc isEqualString dung de kiem tra chuoi inputControlCode(ma dieu khien nhap vao)
#				co trung voi chuoi s (store in $s3 )
#				do dai 2 chuoi nhu nhau
# param[in] $s3, chua dia chi cua chuoi s
# param[out] $t0, 1 neu bang nhau , 0 neu khong bang nhau
#-----------------------------------------------------------					
isEqualString:
	#backup - de khong b? mat di nhung thong tin quan trong cua nhung lan nhap truoc do
	addi $sp,$sp,4 
	sw $t1, 0($sp) # chi so mang inputControlCode
	addi $sp,$sp,4
	sw $s1, 0($sp) # inputControlCode
	addi $sp,$sp,4
	sw $t2, 0($sp) # inputControlCode[i]
	addi $sp,$sp,4
	sw $t3, 0($sp)	
	
	#processing - qua trinh xu li
	addi $t1, $zero, -1				#$t1 = -1 = i
	add $t0, $zero, $zero
	la $s1, inputControlCode			#$s1 = inputControlCode
	for_loop_to_check_equal:
		addi $t1, $t1, 1			#i++
	
		add $t2, $s1, $t1			#$t2 = inputControlCode + i
		lb $t2, 0($t2)				#$t2 = inputControlCode[i]
		
		add $t3, $s3, $t1			#$t3 = s + i
		lb $t3, 0($t3)				#$t3 = s[i]
		
		bne $t2, $t3, isNotEqual		#if $t2 != $t3 -> not equal
 		# co 2 cai bne la de khi bat hoac tat delaybranching code cx chay ok
		bne $t1, 2, for_loop_to_check_equal	#if $t1 <=2 continue loop
		nop
		bne $t1, 2, for_loop_to_check_equal
isEqual:
	#restore
	lw $t3, 0($sp) # restore theo chi?u ng??c l?i c?a backup
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	add $t0, $zero, 1				#update $t0
	jr $ra	# quay lai lenh tiep theo cua chuong trinh chinh
	nop
	jr $ra
isNotEqual:
	#restore
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4

	add $t0, $zero, $zero				#update $t0
	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# pushErrorMess procedure : in ra thong bao ma dieu khien nhap vao bi loi
# param[in] none
#-----------------------------------------------------------					
pushErrorMess:
	li $v0, 4 # print string
	la $a0, inputControlCode # in ma nhap vao
	syscall
	nop
	
	li $v0, 55 # print wrong
	la $a0, WRONG_CODE
	syscall
	nop
	nop
	j continue
	nop
	j continue				
#-----------------------------------------------------------
# GO procedure, to start running
# param[in] none
#-----------------------------------------------------------
GO: 	#backup - sao luu
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	#processing
	li $at, MOVING # change MOVING port
 	addi $k0, $zero,1 # to logic 1,
	sb $k0, 0($at) # to start running	
	#restore
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# STOP procedure, to stop running
# param[in] none
#-----------------------------------------------------------
STOP: 	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	#processing
	li $at, MOVING # change MOVING port to 0
	sb $zero, 0($at) # to stop
	#restore
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# TRACK procedure, to start drawing line
# param[in] none
#-----------------------------------------------------------
TRACK: 	#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	#processing
	li $at, LEAVETRACK # change LEAVETRACK port
	addi $k0, $zero,1 # to logic 1,
 	sb $k0, 0($at) # to start tracking
 	#restore
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# UNTRACK procedure, to stop drawing line
# param[in] none
#-----------------------------------------------------------
UNTRACK:#backup
	addi $sp,$sp,4
	sw $at,0($sp)
	#processing
	li $at, LEAVETRACK # change LEAVETRACK port to 0
 	sb $zero, 0($at) # to stop drawing tail
 	#restore
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra
#-----------------------------------------------------------
# ROTATE procedure, to control robot to rotate
# param[in] nowHeading variable, store heading at present
#-----------------------------------------------------------
ROTATE: 
	#backup
	addi $sp,$sp,4
	sw $t1,0($sp)# dia chi HEADING
	addi $sp,$sp,4
	sw $t2,0($sp) # nowHeading
	addi $sp,$sp,4
	sw $t3,0($sp) # Heading sau khi quay
	#processing
	li $t1, HEADING # change HEADING port
	la $t2, nowHeading
	lw $t3, 0($t2)	#$t3 la heading moi o thoi diem hien tai
 	sw $t3, 0($t1) # quay robot
 	#restore
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
.ktext 0x80000180 # Subsequent items (instructions) stored in Kernel Text segment at next available address
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
# Processing
#--------------------------------------------------------
get_cod:
	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t2, OUT_ADRESS_HEXA_KEYBOARD
scan_row1:
	li $t3, 0x81
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
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
	la $s1, inputControlCode
	la $s2, lengthControlCode
	lw $s3, 0($s2)				#$s3 = strlen(inputControlCode)
	addi $t4, $t4, -1 			#$t4 = i 
	for_loop_to_store_code:
		addi $t4, $t4, 1
		bne $t4, $s3, for_loop_to_store_code
		add $s1, $s1, $t4		#$s1 = inputControlCode + i
		sb  $s0, 0($s1)			#inputControlCode[i] = $s0
		
		addi $s0, $zero, '\n'		#Them '\n' la ket thuc cua string
		addi $s1, $s1, 1			#Them '\n' la ket thuc cua string
		sb  $s0, 0($s1)			#Them '\n' la ket thuc cua string
		
		
		addi $s3, $s3, 1
		sw $s3, 0($s2)			#thay doi chieu dai cua ma dieu khien
		
#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:
	mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4 # $at = $at + 4 (next instruction)
	mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at
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
