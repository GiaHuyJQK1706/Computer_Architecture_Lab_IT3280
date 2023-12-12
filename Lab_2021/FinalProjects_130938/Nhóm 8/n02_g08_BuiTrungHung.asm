.eqv MONITOR_SCREEN 0x10010000 #Dia chi bat dau cua bo nho man hinh

.eqv TopHead_1 118012	# D1 ban dau
.eqv TopTeal_1 118020	# C1 ban dau

.eqv TopHead_2 120060	# D2 ban dau
.eqv TopTeal_2 120068	# C2 ban dau


.eqv KEY_CODE 0xFFFF0004 	# ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 	# =1 if has a new keycode ?
 # Auto clear after lw
 
.eqv DISPLAY_CODE 0xFFFF000C 	# ASCII code to show, 1 byte
.eqv DISPLAY_READY 0xFFFF0008 	# =1 if the display has already to do
 # Auto clear after sw


.text

# ----------------------------------------------------------------------------------------
# TAC DUNG CUA CAC THANH GHI TRONG CODE TAO HINH TRON
#-----------------------------------------------------------------------------------------
# s0 : dem so dong
# s1, s2 : 2 bien trong ham tinh cal
# s3, s4 : 2 bien trong ham tinh calcu
# s5, s6 : 2 bien trong ham to mau
# t8: dia chi diem dau stack
# t9: dia chi diem cuoi stack
# ----------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------
#	CODE TAO HINH TRON
# ----------------------------------------------------------------------------------------
	li $k0, MONITOR_SCREEN 	# Nap dia chi bat dau cua man hinh
	li $s0, 1		# So dong 
	add $t8, $sp, $zero 	# Luu dia chi diem dau stack


# Ham xet tung dong
main:
	
main_root:
	# cac bien dau tien cho ham cal*
	li $s1, TopHead_1
	li $s2, TopTeal_1
	
	# cac bien dau tien cua ham calcu*
	li $s3, TopHead_2
	li $s4, TopTeal_2
	
	# To mau dong dau tien
	li $s5, TopHead_1
	li $s6, TopTeal_1
	jal color_main
	
	addi $s0, $s0, 1	# tang so dong
	
main_ele_circle_1:
	# dong 2
	beq $s0, 2, main_ele_1
	# dong 3 -> 5
	slti $t1, $s0, 6 
	li $t3, 2
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_ele_3
	# dong 6 -> 12
	slti $t1, $s0, 13 
	li $t3, 5
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_ele_4
	# dong 13
	beq $s0, 13, main_ele_5
	# dong 14
	beq $s0, 14, main_ele_4
	# dong 15
	beq $s0, 15, main_ele_5
	# dong 16
	beq $s0, 16, main_ele_4
	# dong 17
	beq $s0, 17, main_ele_5
	# dong 18
	beq $s0, 18, main_ele_4
	# dong 19 -> 21
	slti $t1, $s0, 22 
	li $t3, 18
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_ele_5
	# dong 22
	beq $s0, 22, main_ele_4
	# dong 23 -> 30
	slti $t1, $s0, 31 
	li $t3, 22
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_ele_5
	
	
	# dong 31
	beq $s0, 31, convert_1
main_ele_circle_1_back:
	beq $s0, 31, main_ele_4
	# dong 32 -> 34
	slti $t1, $s0, 35 
	li $t3, 31
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_ele_5
	# dong 35
	beq $s0, 35, main_ele_4
	# dong 36
	beq $s0, 36, main_ele_5
	# dong 37
	beq $s0, 37, main_ele_4
	# dong 38
	beq $s0, 38, main_ele_5
	# dong 39
	beq $s0, 39, main_ele_4
	# dong 40
	beq $s0, 40, main_ele_5
	# dong 41 -> 47
	slti $t1, $s0, 48 
	li $t3, 40
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_ele_4
	# dong 48 -> 50
	slti $t1, $s0, 51 
	li $t3, 47
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_ele_3
	# dong 51
	beq $s0, 51, main_ele_1
	
main_ele_circle_2:
	# dong 6
	beq $s0, 6, main_element_1
	# dong 7
	beq $s0, 7, main_element_3
	# dong 8, 9
	beq $s0, 8, main_element_2
	beq $s0, 9, main_element_2
	# dong 10
	beq $s0, 10, main_element_1
	# dong 11
	beq $s0, 11, main_element_2
	# dong 12
	beq $s0, 12, main_element_1
	# dong 13
	beq $s0, 13, main_element_0
	# dong 14
	beq $s0, 14, main_element_1
	# dong 15
	beq $s0, 15, main_element_1
	# dong 16
	beq $s0, 16, main_element_0
	# dong 17
	beq $s0, 17, main_element_1
	# dong 18
	beq $s0, 18, main_element_0
	# dong 19
	beq $s0, 19, main_element_1
	# dong 20, 21
	beq $s0, 20, main_element_0
	beq $s0, 21, main_element_0
	# dong 22
	beq $s0, 22, main_element_1
	# dong 23 -> 30
	slti $t1, $s0, 31 
	li $t3, 22
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_element_0
	
	# dong 31
	beq $s0, 31, convert_2
main_ele_circle_2_back:
	beq $s0, 31, main_element_1
	# dong 32, 33
	beq $s0, 32, main_element_0
	beq $s0, 33, main_element_0
	# dong 34
	beq $s0, 34, main_element_1
	# dong 35
	beq $s0, 35, main_element_0
	# dong 36
	beq $s0, 36, main_element_1
	# dong 37
	beq $s0, 37, main_element_0
	# dong 38, 39
	beq $s0, 38, main_element_1
	beq $s0, 39, main_element_1
	# dong 40
	beq $s0, 40, main_element_0
	# dong 41, 42
	beq $s0, 41, main_element_1
	beq $s0, 42, main_element_1
	# dong 43
	beq $s0, 43, main_element_2
	# dong 44
	beq $s0, 44, main_element_1
	# dong 45, 46
	beq $s0, 45, main_element_2
	beq $s0, 46, main_element_2
	
main_color:
	# dong 1 -> 5
	slti $t1, $s0, 6 
	li $t3, 0
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_color_1	# neu thuoc dong 1 -> 5 thi nhay den nhan
	# dong 6 -> 46
	slti $t1, $s0, 47 
	li $t3, 5
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_color_2	# neu thuoc dong 6 -> 46 thi nhay den nhan
	# dong 47 -> 51
	slti $t1, $s0, 52
	li $t3, 46
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, main_color_1	# neu thuoc dong 47 -> 51 thi nhay den nhan
	
main_color_1:
	# To mau tu D1 -> C1
	add $s5, $s1, $zero	# s5 = s1
	add $s6, $s2, $zero	# s6 = s2
	jal color_main
	# Sau khi to mau xong thi tang so dong len
	j main_raise
	
main_color_2:
	# To mau D1 -> D2
	add $s5, $s1, $zero	# s5 = s1
	add $s6, $s3, $zero	# s6 = s3
	jal color_main
	# To mau C2 -> C1
	add $s5, $s4, $zero	# s5 = s4
	add $s6, $s2, $zero	# s6 = s2
	jal color_main
	# Sau khi to mau xong thi tang so dong len
	j main_raise


# Ham tang so dong
main_raise:
	beq $s0, 51, main_out	# neu den dong 51 thi thoat main
	addi $s0, $s0, 1	# tang so dong
	j main_ele_circle_1

# Ham mo rong nhay den Cal* va quay lai main_ele_circle_2 
main_ele_1:	
	jal Cal_4
	j main_ele_circle_2
main_ele_3:
	jal Cal_2
	j main_ele_circle_2
main_ele_4:
	jal Cal_1
	j main_ele_circle_2
main_ele_5:
	jal Cal_0
	j main_ele_circle_2
	
# Ham mo rong nhay den Calcu* va quay lai main_raise de tang so dong
main_element_0:	
	jal Calcu_0
	j main_color
main_element_1:
	jal Calcu_1
	j main_color
main_element_2:
	jal Calcu_2
	j main_color
main_element_3:
	jal Calcu_3
	j main_color

	
	
# Ham tinh D = s1, C = s2
Cal_0:
	addi $s1, $s1, 512
	addi $s2, $s2, 512
	jr $ra

# Ham tinh D = s1, C = s2
Cal_1:
	addi $s1, $s1, 511
	addi $s2, $s2, 513
	jr $ra

# Ham tinh D = s1, C = s2
Cal_2:
	addi $s1, $s1, 510
	addi $s2, $s2, 514
	jr $ra
	
# Ham tinh D = s1, C = s2
Cal_4:
	addi $s1, $s1, 508
	addi $s2, $s2, 516
	jr $ra
	
# Ham tinh D = s3, C = s4
Calcu_0:
	addi $s3, $s3, 512
	addi $s4, $s4, 512
	jr $ra

# Ham tinh D = s3, C = s4
Calcu_1:
	addi $s3, $s3, 511
	addi $s4, $s4, 513
	jr $ra

# Ham tinh D = s3, C = s4
Calcu_2:
	addi $s3, $s3, 510
	addi $s4, $s4, 514
	jr $ra
	
# Ham tinh D = s3, C = s4
Calcu_3:
	addi $s3, $s3, 509
	addi $s4, $s4, 515
	jr $ra
			
# Ham to mau cac pixel tu s5 -> s6			
color_main:
	slt $t5, $s5, $s6	# neu s5 > s6 thi can convert s5 va s6
	beqz $t5, convert_3
color_main_back:
	add $t1, $s5, $zero	# t1 = s5
color_ele:
	add $t6, $t1, $zero
	sw $t6, 0($sp)		# Loop gan toan bo cac diem pixel vao stack
	addi $sp, $sp, -4	# Den ngan tiep theo

	mul $t3, $t1, 4		# t3 = t1 * 4
	add $t4, $k0, $t3	# t4 = k0 + t1 * 4
	li $t2, 0x00FFFF00	# t2 = YELLOW	
	sw $t2, 0($t4)		# k0 = YELLOW
	beq $t1, $s6, color_out	# neu t1 = s6 thi thoat khoi ham to mau
	addi $t1, $t1, 1	# t1 = t1 + 1
	j color_ele
color_out:
	jr $ra

# Doi vi tri tu s1 thanh s2 va nguoc lai
convert_1:
	add $t1, $s1, $zero	# t1 = s1
	add $s1, $s2, $zero	# s1 = s2
	add $s2, $t1, $zero	# s2 = t1
	j main_ele_circle_1_back


# Doi vi tri tu s3 thanh s4 va nguoc lai												
convert_2:	
	add $t1, $s3, $zero	# t1 = s3
	add $s3, $s4, $zero	# s3 = s4
	add $s4, $t1, $zero	# s4 = t1										
	j main_ele_circle_2_back	

# Doi vi tri tu s5 thanh s6 va nguoc lai	
convert_3:	
	add $t1, $s5, $zero	# t1 = s5
	add $s5, $s6, $zero	# s5 = s6
	add $s6, $t1, $zero	# s6 = t1										
	j color_main_back	
	
# Ham thoat khoi chuong trinh main
main_out:
	add $t9, $sp, $zero	# Luu dia chi diem cuoi stack
# ----------------------------------------------------------------------------------------
	
	
#----------------
#GIAI PHONG BO NHO
li $s1, 0
li $s2, 0
li $s3, 0
li $s4, 0
li $s5, 0
li $s6, 0
li $t1, 0
li $t2, 0
li $t3, 0
li $t4, 0
li $t6, 0
#---------------
	
	
	
	
# ----------------------------------------------------------------------------------------
# TAC DUNG CUA CAC THANH GHI TRONG CODE TAO CO CHE DI CHUYEN CUA HINH TRON
#-----------------------------------------------------------------------------------------
# s0: gia tri diem pixel lay ra tu stack
# s1: gia tri tuong ung voi che do di chuyen (W, D, S, A)
#
# 
# t8: dia chi diem dau stack
# t9: dia chi diem cuoi stack
# ----------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------
#	CODE TAO CO CHE DI CHUYEN CUA HINH TRON
# ----------------------------------------------------------------------------------------											


	li $a3, KEY_CODE	# ASCII code from keyboard, 1 byte
	li $k1, KEY_READY	# =1 if has a new keycode ?
				# Auto clear after lw
				
	li $a2, DISPLAY_CODE	# ASCII code to show, 1 byte
	li $a1, DISPLAY_READY	# =1 if the display has already to do
				# Auto clear after sw
				
	li $s7, 0		# bien toc do cho 
				
loop: 
	nop
#-----------------------------------------------------
WaitForKey: 
	lw $t1, 0($k1) # $t1 = [$k1] = KEY_READY
 	nop
	beq $t1, $zero, WaitForKey # if $t1 == 0 then Polling
	nop
#-----------------------------------------------------
ReadKey: 
	lw $t0, 0($a3) # $t0 = [$k0] = KEY_CODE
	nop
#-----------------------------------------------------
WaitForDis: 
	lw $t2, 0($a1) # $t2 = [$s1] = DISPLAY_READY
	nop
	beq $t2, $zero, WaitForDis # if $t2 == 0 then Polling
	nop
#-----------------------------------------------------
ShowKey: 
	sw $t0, 0($a2) # show key
	nop
	
CheckKey:
	beq $t0, 'w', key_W 
	beq $t0, 'd', key_D
	beq $t0, 's', key_S
	beq $t0, 'a', key_A
	beq $t0, 'z', key_Z
	beq $t0, 'x', key_X
	bne $s1, 0, check_border
	j WaitForKey

# Xac dinh huong di chuyen
# len
key_W:
	li $s1, -512
	j convert_color
# trai
key_A:
	li $s1, -1
	j convert_color
# phai
key_D:
	li $s1, 1
	j convert_color_2
# xuong
key_S:
	li $s1, 512
	j convert_color_2
	
# giam toc
key_X:
	addi $s7, $s7, 2
	beq $s1, -512, convert_color
	beq $s1, -1, convert_color
	beq $s1, 512, convert_color_2
	beq $s1, 1, convert_color_2

# tang toc 
key_Z:
	addi $s7, $s7, -2
	bltz $s7, key_Z_ex
	j key_Z_cont
key_Z_ex:
	li $s7, 0
key_Z_cont:
	beq $s1, -512, convert_color
	beq $s1, -1, convert_color
	beq $s1, 512, convert_color_2
	beq $s1, 1, convert_color_2
	
# Dao chieu di chuyen
convert_color_back:
	mul $s1, $s1, -1	# dao chieu khi va phai bien
	beq $s1, -512, convert_color
	beq $s1, -1, convert_color
	beq $s1, 512, convert_color_2
	beq $s1, 1, convert_color_2

# Ham to mau cac pixel tu dau stack -> cuoi stack			
convert_color:
	add $sp, $t8, $zero	# lay diem dau stack

convert_color_ele:
	lw $s0, 0($sp)		# lay vi tri pixel tu ngan xep
	# Convert pixel vang -> den
	mul $t3, $s0, 4		# t3 = s0 * 4
	add $t4, $k0, $t3	# t4 = k0 + s0 * 4
	li $t2, 0x0		# t2 = DARK	
	sw $t2, 0($t4)		# k0 = DARK
	
	# Luu vao stack
	add $s0, $s0, $s1	# Xac dinh pixel can to mau
	add $s6, $s0, $zero
	sw $s6, 0($sp)		# gan lai vao ngan stack vua lay

	# convert pixel den -> vang
	mul $t3, $s0, 4		# t3 = s0 * 4
	add $t4, $k0, $t3	# t4 = k0 + s0 * 4
	li $t2, 0x00FFFF00	# t2 = YELLOW	
	sw $t2, 0($t4)		# k0 = YELLOW
	
	addi $sp, $sp, -4	# den ngan nho tiep theo
	beq $sp, $t9, check_new_key	# neu het stack thi khong to mau nua
	j convert_color_ele	# lap de to mau pixel tiep theo
	
# Ham to mau cac pixel tu cuoi stack -> dau stack
convert_color_2:
	add $sp, $t9, $zero
	addi $sp, $sp, 4

convert_color_ele_2:
	lw $s0, 0($sp)		# lay vi tri pixel tu ngan xep
	# Convert pixel vang -> den
	mul $t3, $s0, 4		# t3 = s0 * 4
	add $t4, $k0, $t3	# t4 = k0 + s0 * 4
	li $t2, 0x0		# t2 = DARK	
	sw $t2, 0($t4)		# k0 = DARK
	
	# Luu vao stack
	add $s0, $s0, $s1	# Xac dinh pixel can to mau
	add $s6, $s0, $zero
	sw $s6, 0($sp)		# gan lai vao ngan stack vua lay

	# convert pixel den -> vang
	mul $t3, $s0, 4		# t3 = s0 * 4
	add $t4, $k0, $t3	# t4 = k0 + s0 * 4
	li $t2, 0x00FFFF00	# t2 = YELLOW	
	sw $t2, 0($t4)		# k0 = YELLOW
	
	beq $sp, $t8, check_new_key	# neu het stack thi khong to mau nua
	addi $sp, $sp, 4	# den ngan nho tiep theo
	j convert_color_ele_2	# lap de to mau pixel tiep theo
	
#check new key tu keyboard
check_new_key:
	lw $t1, 0($k1) # $t1 = [$k1] = KEY_READY
 	nop
	bne $t1, $zero, ReadKey # if $t1 == 0 then Polling
	nop
	
# bat dau check bien
check_border:
	add $sp, $t8, $zero	# con tro sp tro vao dau stack
	lw $s0, 0($sp)		# lay vi tri pixel tu ngan xep dau tien
	
	jal sleep
	beq $s1, -512, check_row_top
	beq $s1, 512, check_row_bottom
	beq $s1, -1, check_col_left
	beq $s1, 1, check_col_right
	beq $s1, 0, WaitForKey
	
# check s0 co thuoc 22 -> 483
check_row_top:
	slti $t1, $s0, 484 
	li $t3, 21
	slt $t2, $t3, $s0
	add $t4, $t1, $t2
	beq $t4, 2, convert_color_back	# neu thuoc khoang kiem tra thi dao chieu di chuyen
	j convert_color			# neu khong thi tiep tuc to mau

# check s0 co thuoc 236054 -> 236515
check_row_bottom:
	add $t5, $s0, $zero
	li $t6, -236000
	add $t5, $t5, $t6
	
	slti $t1, $t5, 516
	li $t3, 53
	slt $t2, $t3, $t5
	add $t4, $t1, $t2
	beq $t4, 2, convert_color_back	# neu thuoc khoang kiem tra thi dao chieu di chuyen
	j convert_color_2			# neu khong thi tiep tuc to mau

# check bien ben phai
check_col_right:
	add $t5, $s0, $zero
	addi $t5, $t5, 29
	div $t5, $t5, 512
	mfhi $t6
	bne $t6, 0, convert_color_2	# neu so du khac 0 thi chua den bien
	
	slti $t1, $t5, 463
	li $t3, 0
	slt $t2, $t3, $t5
	add $t4, $t1, $t2
	beq $t4, 2, convert_color_back	# neu thuoc khoang kiem tra thi dao chieu di chuyen
	j convert_color_2		# neu khong thi tiep tuc to mau
	
# check bien ben trai
check_col_left:
	add $t5, $s0, $zero
	addi $t5, $t5, 490
	div $t5, $t5, 512
	mfhi $t6
	bne $t6, 0, convert_color	# neu du khac 0 thi chua den bien
	
	slti $t1, $t5, 463
	li $t3, 0
	slt $t2, $t3, $t5
	add $t4, $t1, $t2
	beq $t4, 2, convert_color_back	# neu thuoc khoang kiem tra thi dao chieu di chuyen
	j convert_color		# neu khong thi tiep tuc to mau
#-----------------------------------------------------

# sleep sau moi lan di chuyen
sleep:
	li $v0, 32
	add $a0, $s7, $0
	syscall
	jr $ra
