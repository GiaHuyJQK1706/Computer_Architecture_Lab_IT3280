.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv KEY_CODE 0xFFFF0004 		# ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 	# =1 if has a new keycode ?
			#Auto clear after lw

.eqv HEADING 0xffff8010 		# Integer: An angle between 0 and 359
 			# 0 : North (up)
 			# 90: East (right)
			# 180: South (down)
			# 270: West (left)
.eqv MOVING 0xffff8050 		# Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 	# Boolean (0 or non-0):
 			# whether or not to leave a track
.eqv WHEREX 0xffff8030 		# Integer: Current x-location of MarsBot
.eqv WHEREY 0xffff8040 		# Integer: Current y-location of MarsBot


.data
# Key value
#0-3
	.eqv KEY_0 0x11
	.eqv KEY_1 0x21
	.eqv KEY_2 0x41
	.eqv KEY_3 0x81
#4-7
	.eqv KEY_4 0x12
	.eqv KEY_5 0x22
	.eqv KEY_6 0x42
	.eqv KEY_7 0x82
#8-b
	.eqv KEY_8 0x14
	.eqv KEY_9 0x24
	.eqv KEY_a 0x44
	.eqv KEY_b 0x84
#c-f
	.eqv KEY_c 0x18
	.eqv KEY_d 0x28
	.eqv KEY_e 0x48
	.eqv KEY_f 0x88

#Function code
	ChuyenDong: .asciiz "1b4"		#Marsbot bat dau chuyen dong
	Dung: .asciiz "c68"		#Marsbot dung im
	ReTrai: .asciiz "444"		#Re trai
	RePhai: .asciiz "666"		#Re phai
	DeVet: .asciiz "dad"		#De lai vet tren duong
	DungDeVet: .asciiz "cbc" 		#Cham dut de lai vet tren duong
	DiNguoc: .asciiz "999"		#Di lo trinh nguoc lai
	MaLoi: .asciiz "Ma khong hop le!"

	InputCode: .space 50
	InputCode1: .space 50
	CodeLong: .word 0
	CodeLong1: .word 0
	HuongDi: .word 0

# duong di cua masbot duoc luu tru vao mang Path
# moi 1 canh duoc luu tru duoi dang 1 structure
# 1 structure co dang {x, y, z}
# trong do: 	x, y la toa do diem dau tien cua canh
#		z la huong cua canh do
# mac dinh:	structure dau tien se la {0,0,0}
# do dai duong di ngay khi bat dau la 12 bytes (3x 4byte)
	Path: .space 600
	PathLong: .word 12		#bytes



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
ReadKey:	lw $t6, 0($k0)			#$t6 = [$k0] = KEY_CODE
		beq $t6, 127 , Delete		#if $t6 == delete key then remove input
						#127 is delete key in ascii
		beq $t6, 32, repeat
		
		beq $t6, 13 , loop		#if $t6 != '\n' then Polling
		nop
		beq $t6, 13 , loop
	
			
#Cac code chuc nang
#--------------------------------------------------------------------------------------------------	
#Chuong trinh con thuc hien ma code vua nhan tu digital lab sim	
CheckInput:	
		jal storePath
		
		la $s2, CodeLong
		lw $s2, 0($s2)
		bne $s2, 3, Error
		
		la $s3, ChuyenDong
		jal Equal
		beq $t0, 1, CodeGO
		
		la $s3, Dung
		jal Equal
		beq $t0, 1, CodeStop
			
		la $s3, ReTrai
		jal Equal
		beq $t0, 1, CodeLeft
		
		la $s3, RePhai
		jal Equal
		beq $t0, 1, CodeRight
		
		la $s3, DeVet
		jal Equal
		beq $t0, 1, CodeTrack

		la $s3, DungDeVet
		jal Equal
		beq $t0, 1, CodeUntrack
		
		la $s3, DiNguoc
		jal Equal
		beq $t0, 1, CodeReturn
		
		beq $t0, 0, Error
			
			
#Thuc hien in ra code vua duoc nhan va thuc thi 		
#sau do sao luu ma code do sang mot bien khac de dung cho code repeat
Print:	
	li $v0, 4
	la $a0, InputCode
	syscall
	nop
	
	#backup
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $s2, 0($sp)
	addi $sp,$sp,4
	sw $s0, 0($sp)
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	
	#processing
	la $s1, InputCode
	la $s2, InputCode1
	strcpy1:
		add $s0, $zero, $zero # s0 = i = 0
		L1:
		add $t1,$s0, $s1 # t1 = s0 + a1 = dia chi y[i]
		lb $t2, 0($t1) # t2 = gia tri tai dia chi t1 = gia tri cua y[i]
		add $t3, $s2, $s0 # t3 = dia chi bat dau cua xau dich + index = dia chi cua x[i]
		sb $t2, 0($t3) # Gan gia tri cua y[i] cho thanh ghi co dia chi t3 (x[i])
		beq $t2, $zero, end_of_strcpy1 #Neu ki tu vua doc duoc la KI TU KET THUC CHUOI, KET THUC
		nop
		addi $s0, $s0, 1 # s0 = s0+1 = i+1
		j L1
		nop
		end_of_strcpy1:
	la $s1, CodeLong
	la $s2, CodeLong1
	strcpy3:
		add $s0, $zero, $zero # s0 = i = 0
		L3:
		add $t1,$s0, $s1 # t1 = s0 + a1 = dia chi y[i]
		lb $t2, 0($t1) # t2 = gia tri tai dia chi t1 = gia tri cua y[i]
		add $t3, $s2, $s0 # t3 = dia chi bat dau cua xau dich + index = dia chi cua x[i]
		sb $t2, 0($t3) # Gan gia tri cua y[i] cho thanh ghi co dia chi t3 (x[i])
		beq $t2, $zero, end_of_strcpy3 #Neu ki tu vua doc duoc la KI TU KET THUC CHUOI, KET THUC
		nop
		addi $s0, $s0, 1 # s0 = s0+1 = i+1
		j L3
		nop
		end_of_strcpy3:
	#restore
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $s0, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
		
		
#Delete code cho nhan phim Delete		
Delete:			
	#backup
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
	
	#processing
	la $s2, CodeLong
	lw $t3, 0($s2)					#$t3 = CodeLong
	addi $t1, $zero, -1				#$t1 = -1 = i
	addi $t2, $zero, 0				#$t2 = '\0'
	la $s1, InputCode
	addi $s1, $s1, -1
Delete_loop: addi $t1, $t1, 1			#i++	
	add $s1, $s1, 1				#$s1 = InputCode + i
	sb $t2, 0($s1)				#InputCode[i] = '\0'
				
	bne $t1, $t3, Delete_loop	#if $t1 <=3 Delete loop
	nop
	bne $t1, $t3, Delete_loop
		
	add $t3, $zero, $zero			
	sw $t3, 0($s2)					#CodeLong = 0
		
	#restore
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
	
	j loop
	nop
	j loop
	
	
#Repeat code cho nhan phim space
repeat:
	#backup
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $s2, 0($sp)
	addi $sp,$sp,4
	sw $s0, 0($sp)
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)
	
	#processing
	la $s1, InputCode1
	la $s2, InputCode
	strcpy2:
		add $s0, $zero, $zero # s0 = i = 0
		L2:
		add $t1,$s0, $s1 # t1 = s0 + a1 = dia chi y[i]
		lb $t2, 0($t1) # t2 = gia tri tai dia chi t1 = gia tri cua y[i]
		add $t3, $s2, $s0 # t3 = dia chi bat dau cua xau dich + index = dia chi cua x[i]
		sb $t2, 0($t3) # Gan gia tri cua y[i] cho thanh ghi co dia chi t3 (x[i])
		beq $t2, $zero, end_of_strcpy2 #Neu ki tu vua doc duoc la KI TU KET THUC CHUOI, KET THUC
		nop
		addi $s0, $s0, 1 # s0 = s0+1 = i+1
		j L2
		nop
		end_of_strcpy2:
	la $s1, CodeLong1
	la $s2, CodeLong
	strcpy4:
		add $s0, $zero, $zero # s0 = i = 0
		L4:
		add $t1,$s0, $s1 # t1 = s0 + a1 = dia chi y[i]
		lb $t2, 0($t1) # t2 = gia tri tai dia chi t1 = gia tri cua y[i]
		add $t3, $s2, $s0 # t3 = dia chi bat dau cua xau dich + index = dia chi cua x[i]
		sb $t2, 0($t3) # Gan gia tri cua y[i] cho thanh ghi co dia chi t3 (x[i])
		beq $t2, $zero, end_of_strcpy4 #Neu ki tu vua doc duoc la KI TU KET THUC CHUOI, KET THUC
		nop
		addi $s0, $s0, 1 # s0 = s0+1 = i+1
		j L4
		nop
		end_of_strcpy4:
	#restore
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $s2, 0($sp)
	addi $sp,$sp,-4
	lw $s0, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	
	j CheckInput
	nop
	j CheckInput
	
	
#luu lai vi tri hien tai va huong di cua marsbot
storePath:
	#backup
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
	
	#processing
	li $t1, WHEREX
	lw $s1, 0($t1)		#s1 = x
	li $t2, WHEREY	
	lw $s2, 0($t2)		#s2 = y
	
	la $s4, HuongDi
	lw $s4, 0($s4)		#s4 = now heading

	la $t3, PathLong
	lw $s3, 0($t3)		#$s3 = PathLong (dv: byte)
	
	la $t4, Path
	add $t4, $t4, $s3		#position to store
	
	sw $s1, 0($t4)		#store x
	sw $s2, 4($t4)		#store y
	sw $s4, 8($t4)		#store heading
	
	addi $s3, $s3, 12		#update PathLong
				#12 = 3 (word) x 4 (bytes)
	sw $s3, 0($t3)
	
	#restore
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
	
#Code check xem ma code nhan duoc va ma code theo dau bai cho co dung format hay khong	
#Luc nay $s3 se chua dia chi co cac code chuc nang theo format da cho
#$t0 la output neu code nhan vao dung format se tra ve 1, nguoc lai la 0			
Equal:
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
	addi $t1, $zero, -1				#$t1 = -1 = i
	add $t0, $zero, $zero
	la $s1, InputCode			#$s1 = InputCode
Equal_loop:  addi $t1, $t1, 1			#i++

	add $t2, $s1, $t1			#$t2 = InputCode + i
	lb $t2, 0($t2)				#$t2 = InputCode[i]
		
	add $t3, $s3, $t1			#$t3 = s + i
	lb $t3, 0($t3)				#$t3 = s[i]
		
	bne $t2, $t3, isNotEqual		#if $t2 != $t3 -> not equal

	bne $t1, 2, Equal_loop	#if $t1 <=2 Delete loop
	nop
	bne $t1, 2, Equal_loop
isEqual:
	#restore
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	add $t0, $zero, 1		#update $t0
	jr $ra
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
		
#Code bao loi				
Error: li $v0, 4
	la $a0, InputCode
	syscall
	nop
	
	li $v0, 55
	la $a0, MaLoi
	syscall
	nop
	nop
	j Delete
	nop
	j Delete
#---------------------------------------------------------------------------------	
	
	
	
#Code thuc hien cac chuc nang theo yeu cau 
#-------------------------------------------------------------------------------------
#Di theo lo trinh nguoc lai	
CodeReturn:	la $s7, Path
	la $s5, PathLong
	lw $s5, 0($s5)
	add $s7, $s7, $s5
begin:	addi $s5, $s5, -12 	#lui lai 1 structure
	
	addi $s7, $s7, -12	#vi tri cua thong tin ve canh cuoi cung
	lw $s6, 8($s7)		#huong cua canh cuoi cung
	addi $s6, $s6, 180	#nguoc lai huong cua canh cuoi cung
	#sub $s6, $zero, $s6
	
	la $t8, HuongDi	#marsbot quay nguoc lai
	sw $s6, 0($t8)
	jal ROTATE

Go_to_first_point_of_edge:	
	lw $t9, 0($s7)		#toa do x cua diem dau tien cua canh
	li $t8, WHEREX		#toa do x hien tai
	lw $t8, 0($t8)

	bne $t8, $t9, Go_to_first_point_of_edge
	
	lw $t9, 4($s7)		#toa do y cua diem dau tien cua canh
	li $t8, WHEREY		#toa do y hien tai
	lw $t8, 0($t8)
	
	bne $t8, $t9, Go_to_first_point_of_edge
	
	beq $s5, 0, finish
	
	j begin
	nop
	j begin
	
finish:	jal STOP
	la $t8, HuongDi
	add $s6, $zero, $zero
	sw $s6, 0($t8)		#update heading
	la $t8, PathLong
	sw $s5, 0($t8)		#update PathLong = 0
	jal ROTATE
	j Print

#De lai vet tren duong
CodeTrack: 	jal TRACK
	j Print

#Dung de lai vet tren duong	
CodeUntrack: jal UNTRACK
	j Print

#Bat dau chuyen dong	
CodeGO: 	jal GO
	j Print

#Marsbot dung im	
CodeStop: 	jal STOP
	j Print

#Re phai 90 do
CodeRight:	la $s5, HuongDi
	lw $s6, 0($s5)	#$s6 is heading at now
	addi $s6, $s6, 90 	#increase heading by 90*
	sw $s6, 0($s5) 	# update HuongDi
	jal storePath
	jal ROTATE
	j Print	

#Re trai 90 do
CodeLeft:	la $s5, HuongDi
	lw $s6, 0($s5)	#$s6 is heading at now
	addi $s6, $s6, -90 	#increase heading by 90*
	sw $s6, 0($s5) 	# update HuongDi
	jal storePath
	jal ROTATE
	j Print	
#---------------------------------------------------------------------
	
								
#Cac chuc nang cua Marsbot		
#-----------------------------------------------------------------------------

# GO procedure, to start running
# param[in] none
#-----------------------------------------------------------
GO: 	#backup
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
# ROTATE_RIGHT procedure, to control robot to rotate
# param[in] HuongDi variable, store heading at present
#-----------------------------------------------------------
ROTATE: 
	#backup
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	#processing
	li $t1, HEADING # change HEADING port
	la $t2, HuongDi
	lw $t3, 0($t2)	#$t3 is heading at now
 	sw $t3, 0($t1) # to rotate robot
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
#--------------------------------------------------------------------
		
				
#Nhan code input
#---------------------------------------------------------------
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
	sw $s4,0($sp)
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
	li $t3, 0x11
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
scan_row2:
	li $t3, 0x12
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
scan_row3:
	li $t3, 0x14
	sb $t3, 0($t1)
	lbu $a0, 0($t2)
	bnez $a0, get_code_in_char
scan_row4:
	li $t3, 0x18
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
	la $s1, InputCode 
	la $s2, CodeLong
	lw $s3, 0($s2)				#$s3 = strlen(InputCode)
	addi $t4, $t4, -1 			#$t4 = i 
	for_loop_to_store_code:
		addi $t4, $t4, 1
		bne $t4, $s3, for_loop_to_store_code
		add $s1, $s1, $t4		#$s1 = InputCode + i
		sb  $s0, 0($s1)			#InputCode[i] = $s0
		
		addi $s0, $zero, '\n'		#add '\n' character to end of string
		addi $s1, $s1, 1		#add '\n' character to end of string
		sb  $s0, 0($s1)			#add '\n' character to end of string
		
		
		addi $s3, $s3, 1
		sw $s3, 0($s2)			#update length of input control code
		
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
	lw $s4, 0($sp)
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
