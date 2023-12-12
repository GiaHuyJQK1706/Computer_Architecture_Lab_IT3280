#Truong Cong Nghe Thong Tin & Truyen Thong - Dai Hoc Bach Khoa Ha Noi
#Bo mon Ky thuat may tinh
#IT3280 - Thuc hanh kien truc may tinh
#LeTruongGiang 20205077
#Curiosity Marsbot  
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv KEY_CODE 0xFFFF0004 	# ma ASCII tu ban phim, 1 byte
.eqv KEY_READY 0xFFFF0000 	# =1 neu co ma khoa moi
 				# tu dong xoa sau lw
#-------------------------------------------------------------------------------
# Marsbot
.eqv HEADING 0xffff8010 # so nguyen: tu 0 den 359 do 
 			# 0 : Di len ( Bac )
 			# 90: Sang phai ( Dong ) 
			# 180: Di xuong ( Nam ) 
			# 270: Sang Trai ( Tay )
.eqv MOVING 0xffff8050 # Boolean cho lenh kich hoat thuc thi
.eqv LEAVETRACK 0xffff8020 # Boolean (0 or non-0):
 			
.eqv WHEREX 0xffff8030 # vi tri x cua MarsBot
.eqv WHEREY 0xffff8040 # vi tri y cua MarsBot


.data
# gia tri nhan vao
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
#tao cac lenh chuc nang 
	DiChuyen: .asciiz "1b4"		# di chuyen
	DungLai: .asciiz "c68"		# dung im
	ReTrai: .asciiz "444"	# re trai 90 do 
	RePhai: .asciiz "666"	# re phai 90 do
	DauVet: .asciiz "dad"	# ve 
	BoDauVet: .asciiz "cbc"	# ko ve
	QuayXe: .asciiz "999"	# quay tro lai, ko ve. ko nhan ma toi khi het
	msg_output: .asciiz "Da nhap ma dieu khien sai !"
#-------------------------------------------------------------------------------
	MaDieuKhien: .space 50 # dau vao ma dieu khien
	MaTruocDo: .space 50 # dau vao ma dieu khien
	DoDai: .word 0  # ma khiem soat do dai
	nowHeading: .word 0
#--------------------------------------------------------------------------------
	dauvet: .space 800
	DoDaiDauVet: .word 20	#bytes

.text	
setup:	
	la $s7, dauvet
	sw	$0, 0($s7)
	sw	$0, 4($s7)
	sw	$0, 8($s7)
	la	$t0, DoDaiDauVet
	li	$t1, 12
	sw	$t1, 0($t0)
	li	$t0, HEADING
	sw	$0, 0($t0)
main:
	li $k0, KEY_CODE		# ma khoa 
 	li $k1, KEY_READY	# khoa san sang 

# ngat ma tran ban phim 4x4 trong Digital Lab Sim

	li $t1, IN_ADRESS_HEXA_KEYBOARD
	li $t3, 0x80 # bit 7 = 1 de kich hoat
	sb $t3, 0($t1)
#---------------------------------------------------------
loop:		nop
WaitForKey:	
	lw $t5, 0($k1)			#$t5 = [$k1] = khoa san sang
	beq $t5, $zero, WaitForKey	#neu $t5 == 0 quay lai WaitForKey cho tin hieu
	nop
	beq $t5, $zero, WaitForKey	
ReadKey:
	lw $t6, 0($k0)			#$t6 = [$k0] = KEY_CODE
	beq $t6, 127 , delete	#if $t6 == Del thi xoa toan bo dau vao 
					#127 la ma Delete xong ASCII
					
	
	beq $t6, ' ' ,laplai	#neu $t6 == " " thi lap lai lenh truoc do
	
	bne $t6, '\n' , loop		#neu t6 = \n thi quay lai loop de lay code dieu khien
	nop
	bne $t6, '\n' , loop
CheckMaDieuKhien:	#kiem tra ma 
	la $s2, DoDai	#ma kiem soat do dai
	lw $s2, 0($s2)
	#----------------
	bne $s2, 3, pushErrorMess	#thong bao ma dieu khien dua vao la sai

	la $s3, DiChuyen		#lenh di chuyen 
	jal SoSanh		#kiem tra chuoi
	beq $t0, 1, go
	
	la $s3, DungLai		#lenh dung
	jal SoSanh		#kiem tra chuoi
	beq $t0, 1, stop
		
	la $s3, ReTrai		#lenh re trai
	jal SoSanh		#kiem tra chuoi
	beq $t0, 1, moveLeft
	
	la $s3, RePhai		#lenh re phai
	jal SoSanh		#kiem tra chuoi
	beq $t0, 1, moveRight
	
	la $s3, DauVet		#lenh ve
	jal SoSanh		#kiem tra chuoi
	beq $t0, 1, track
		
	la $s3, BoDauVet		#lenh khong ve
	jal SoSanh		#kiem tra chuoi
	beq $t0, 1, untrack
	
	la $s3, QuayXe		#lenh quay lai
	jal SoSanh		#kiem tra chuoi
	beq $t0, 1, goBack		
	
	beq $t0, 0, pushErrorMess	#ma dieu khien dua vao la sai
		
printMaDieuKhien:	# in ra ma dieu khien tren Mars Messages
	li $v0, 4
	la $a0, MaDieuKhien		#dau vao cua code 
	syscall
	nop

#sao chep MaDIeuKien vao MaTruocDo

	la $s1, MaDieuKhien
	la $s2, MaTruocDo
	jal strcpy
	la $s1, DoDai
	lw $t7, 0($s1)
	
		
delete:			#tiep theo 
	jal xoa	#Loai bo chuoi InputMaDieuKhien	
	nop
	j loop			#quay lai nhan key moi
	
laplai:
	
	
	la $s1, MaTruocDo
	la $s2, MaDieuKhien
	jal strcpy
	la $s1, DoDai
	sw $t7, 0($s1)
	
	
	j CheckMaDieuKhien

# ham luudauvet, luu tru duong dan cua MarsBot den bien duong dan

luudauvet:
	#luu lai tung ki tu vao cac bien
	#sp tro toi dinh cua stack
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
	
	#thuat tuan
	li $t1, WHEREX
	lw $s1, 0($t1)		#s1 = x
	li $t2, WHEREY	
	lw $s2, 0($t2)		#s2 = y
	
	la $s4, nowHeading
	lw $s4, 0($s4)		#s4 = now heading

	la $t3, DoDaiDauVet
	lw $s3, 0($t3)		#$s3 = DoDaiDauVet (dv: byte)
	
	la $t4, dauvet
	add $t4, $t4, $s3	#vi tri de luu tru vao mang dauvet
	#chuyen de lieu tu thanh ghi ra t4 ( 3 ki tu dieu khien ) 
	sw $s1, 0($t4)		#store x
	sw $s2, 4($t4)		#store y
	sw $s4, 8($t4)		#store heading
	
	addi $s3, $s3, 12	#cap nhat DoDaiDauVet
				#12 = 3 (word) x 4 (bytes)
	sw $s3, 0($t3)
	
	#khoi phuc lai gia tri trong stack
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
	
# ham con strcpy sao chep noi dung ben trong chuoi nay sang chuoi khac
	
	
strcpy:
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
	jr $ra
	nop
	jr $ra

# ham xoa , loai bo chuoi ma dieu kien dau vao 
			
xoa:
	#sao luu vao stack
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
	
	#thuat tuan
	la $s2, DoDai
	lw $t3, 0($s2)				#$t3 = DoDai
	addi $t1, $zero, -1			#i = -1 
	addi $t2, $zero, 0			#$t2 = '\0'
	la $s1, MaDieuKhien
	addi $s1, $s1, -1
loai_bo: addi $t1, $t1, 1		#i++	
	add $s1, $s1, 1				#$s1 = MaDieuKhien + i
	sb $t2, 0($s1)				#MaDieuKhien[i] = '\0'
				
	bne $t1, $t3, loai_bo		#if $t1 <=3 continue loop
	nop
	bne $t1, $t3, loai_bo
		
	add $t3, $zero, $zero			
	sw $t3, 0($s2)				#DoDai = 0
		
	#khoi phuc
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

# thuat tuan goBack, dieu khien MarsBot quay lai  

	
goBack:	la $s7, dauvet		# ma tran
	la $s5, DoDaiDauVet 	# byte toi da
	lw $s5, 0($s5)
	add $s7, $s7, $s5
begin:	beq $s5, 0, finish
	addi $s5, $s5, -12 	#lui lai 1 cau truc
	addi $s7, $s7, -12	#vi tri cua thong tin ve canh cuoi cung
	lw $s6, 8($s7)		#huong cua canh cuoi cung
	addi $s6, $s6, 180	#nguoc lai huong cua canh cuoi cung
	
	la $t8, nowHeading	#marsbot quay nguoc lai
	sw $s6, 0($t8)
	jal ROTATE

go_to_first_point_of_edge:	#toi diem dau cua canh
	lw $t9, 0($s7)		#toa do x cua diem dau tien cua canh
	li $t8, WHEREX		#toa do x hien tai
	lw $t8, 0($t8)

	bne $t8, $t9, go_to_first_point_of_edge

	lw $t9, 4($s7)		#toa do y cua diem dau tien cua canh
	li $t8, WHEREY		#toa do y hien tai
	lw $t8, 0($t8)
	
	bne $t8, $t9, go_to_first_point_of_edge
	
	j begin
	
finish:	jal STOP
	addi $s5, $s5, 12
	la $t8, nowHeading
	add $s6, $zero, $zero
	sw $s6, 0($t8)		#cap nhat heading
	la $t8, DoDaiDauVet
	sw $s5, 0($t8)		#cap nhat DoDaiDauVet = 0
	jal ROTATE
	j printMaDieuKhien
#-----------------------------------------------------------
# thuat tuan track ,dieu khien MarsBot de theo doi va in ma dieu khien
# param[in] none
#-----------------------------------------------------------	
track: 	jal TRACK
	j printMaDieuKhien

# quy trinh untrack, bo theo doi, 
#dieu khien MarsBot de bo theo doi va in ma dieu khien

untrack: jal UNTRACK
	j printMaDieuKhien

# thuat tuan go, dieu khien MarsBot de di va in ra ma dieu khien

go: 	jal GO
	j printMaDieuKhien

# thuat tuan stop, dieu khien MarsBot dung va in ra ma dieu khien

stop: 	jal STOP
	j printMaDieuKhien

# thuat tuan moveRight , dieu khien MarsBot sang trai va in ma dieu khien

moveRight:la $s5, nowHeading
	lw $s6, 0($s5)		# $s6 = $s5 = n?Heading
	addi $s6, $s6, 90	# ( tang len 90 ) 
	sw $s6, 0($s5)		# cap nhat nowHeading
	jal luudauvet		# luu tru duong dan cua MarsBot vao stack
	jal ROTATE		# dieu khien robot xoay
	j printMaDieuKhien	# in ra ma dieu khien

# thuat tuan moveLeft,dieu khien MarsBot sang phai va in ma dieu khien

moveLeft:	la $s5, nowHeading
	lw $s6, 0($s5)		# $6 = nowHeading
	addi $s6, $s6, -90	# cong s6 them -90, xoay phai 90 do 
	sw $s6, 0($s5) 		# cap nhat nowHeading
	jal luudauvet		# luu tru duong dan cua MarsBot vao stack
	jal ROTATE		# dieu khien robot xoay
	j printMaDieuKhien	# in ra ma dieu khien		


# thuat tuan SoSanh , kiem tra MaDieuKhien 
#				kiem tra co bang voi chuoi s ( luu trong $s3)
#				Do dai 2 chuoi la nhu nhau
				
SoSanh:
	#sao luu vao stack
	addi $sp,$sp,4
	sw $t1, 0($sp)
	addi $sp,$sp,4
	sw $s1, 0($sp)
	addi $sp,$sp,4
	sw $t2, 0($sp)
	addi $sp,$sp,4
	sw $t3, 0($sp)	
	
	#thuat tuan
	addi $t1, $zero, -1			#$t1 = -1 = i
	add $t0, $zero, $zero
	la $s1, MaDieuKhien			#$s1 = MaDieuKhien
so_sanh: addi $t1, $t1, 1			#i++

	add $t2, $s1, $t1			#$t2 = MaDieuKhien + i
	lb $t2, 0($t2)				#$t2 = MaDieuKhien[i]
		
	add $t3, $s3, $t1			#$t3 = s + i
	lb $t3, 0($t3)				#$t3 = s[i]
		
	bne $t2, $t3, KhacNhau			#if $t2 != $t3 -> isNotequal

	bne $t1, 2, so_sanh	#if $t1 <=2 tiep tuc toi loop
	nop
	bne $t1, 2, so_sanh
GiongNhau:
	#sao luu vao stack
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4
	
	add $t0, $zero, 1	#cap nhat $t0
	jr $ra
	nop
	jr $ra
KhacNhau:
	#restore
	lw $t3, 0($sp)
	addi $sp,$sp,-4
	lw $t2, 0($sp)
	addi $sp,$sp,-4
	lw $s1, 0($sp)
	addi $sp,$sp,-4
	lw $t1, 0($sp)
	addi $sp,$sp,-4

	add $t0, $zero, $zero	#cap nhat $t0
	jr $ra
	nop
	jr $ra

# thuat tuan pushErrorMess , thong bao ma bi sai 
			
pushErrorMess: li $v0, 4
	la $a0, MaDieuKhien
	syscall
	nop
	
	li $v0, 55
	la $a0, msg_output
	syscall
	nop
	nop
	j delete
	nop
	j delete			

# thuat tuan GO , bat dau chay

GO: 	#sao luu vao stack
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	#thuat tuan
	li $at, MOVING 		# lenh kich hoat duoc thuc thi 
 	addi $k0, $zero,1 	# to logic 1,
	sb $k0, 0($at) 		# bat dau chay	
	#khoi phuc
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra

# thuat tuan STOP , dung chay

STOP: 	#sao luu
	addi $sp,$sp,4
	sw $at,0($sp)
	#thuat tuan
	li $at, MOVING 		# thay doi sang MOVING
	sb $zero, 0($at)		# dung lai
	#khoi phuc
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
	jr $ra
	nop
	jr $ra

# thuat tuan TRACK , ve duong

TRACK: 	#sao luu
	addi $sp,$sp,4
	sw $at,0($sp)
	addi $sp,$sp,4
	sw $k0,0($sp)
	#thuat tuan
	li $at, LEAVETRACK	 # thay doi sang LEAVETRACK
	addi $k0, $zero,1	 # to logic 1,
 	sb $k0, 0($at) 		 # to start tracking
 	#khoi phuc
	lw $k0, 0($sp)
	addi $sp,$sp,-4
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra

# thuat tuan UNTRACK , dung ve duong

UNTRACK:
	#sao luu
	addi $sp,$sp,4
	sw $at,0($sp)
	#thuat tuan
	li $at, LEAVETRACK 	# thay doi sang cong LEAVETRACK va cho = 0
 	sb $zero, 0($at) 	# dung ve
 	#khoi phuc
	lw $at, 0($sp)
	addi $sp,$sp,-4
	
 	jr $ra
	nop
	jr $ra

# thuat tuan ROTATE_RIGHT , dieu khien robot xoay

ROTATE: 
	#sao luu
	addi $sp,$sp,4
	sw $t1,0($sp)
	addi $sp,$sp,4
	sw $t2,0($sp)
	addi $sp,$sp,4
	sw $t3,0($sp)
	#thuat tuan
	li $t1, HEADING	 	# thay doi xong sang HEADING
	la $t2, nowHeading
	lw $t3, 0($t2)		# t3 = nowHeading
 	sw $t3, 0($t1)		# xoay robot
 	#khoi phuc
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
# GENERAL INTERRUPT SERVED ROUTINE cho tat ca interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
#-------------------------------------------------------
# luu cac tap tin vao stack
#-------------------------------------------------------
backup: 	#sao luu tu thanh ghi vao stack
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
# thuat tuan
#--------------------------------------------------------
get_cod:		#chuyen dia chi
	li $t1, IN_ADRESS_HEXA_KEYBOARD		#dia chi vao
	li $t2, OUT_ADRESS_HEXA_KEYBOARD		#dia chi ra
scan_row1:	#nhan tin hieu dong 1	
	li $t3, 0x11
	sb $t3, 0($t1)
	lbu $a0, 0($t2)		#dia chi ra
	bnez $a0, get_code_in_char
scan_row2:	#nhan tin hieu dong 2
	li $t3, 0x12
	sb $t3, 0($t1)
	lbu $a0, 0($t2)		#dia chi ra
	bnez $a0, get_code_in_char
scan_row3:	#nhan tin hieu dong 3
	li $t3, 0x14
	sb $t3, 0($t1)
	lbu $a0, 0($t2)		#dia chi ra
	bnez $a0, get_code_in_char
scan_row4:	#nhan tin hieu dong 4
	li $t3, 0x18
	sb $t3, 0($t1)
	lbu $a0, 0($t2) 		#dia chi ra
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
	
	#luu vao s0 nhung kieu char 
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
	la $s1, MaDieuKhien
	la $s2, DoDai
	lw $s3, 0($s2)			#$s3 = so ki tu trong mang MaDieuKhien
	addi $t4, $t4, -1 		#$t4 = i 
	for_loop_to_store_code:
		addi $t4, $t4, 1
		bne $t4, $s3, for_loop_to_store_code
		add $s1, $s1, $t4	#$s1 = MaDieuKhien + i
		sb  $s0, 0($s1)		#MaDieuKhien[i] = $s0
		
		addi $s0, $zero, '\n'	#them ky tu '\n' vao cuoi chuoi
		addi $s1, $s1, 1		#them ky tu '\n' vao cuoi chuoi
		sb  $s0, 0($s1)		#them ky tu '\n' vao cuoi chuoi
		
		
		addi $s3, $s3, 1
		sw $s3, 0($s2)		#cap nhat do dai cua InputMaDieuKhien
		
#--------------------------------------------------------
# Dang gia tra ve dia chi cua main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:
	mfc0 $at, $14 		# $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4	 	# $at = $at + 4 (next instruction)
	mtc0 $at, $14 		# Coproc0.$14 = Coproc0.epc <= $at

# khoi phuc tap tin trong stack

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
return: eret #tra lai ngoai le return Exception
