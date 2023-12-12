#Author: Nguyen Thi Hoai Thu
#Hanoi University of Science and Technology

.eqv SCREEN 	0x10010000	
.eqv YELLOW 	0x00FFFF66
.eqv BACKGROUND 0x00000000
# Thiet lap ky tu 
.eqv KEY_A 	0x00000061		# di chuyen sang trai
.eqv KEY_D	0x00000064		# di chuyen sang phai
.eqv KEY_S	0x00000073		# di chuyen xuong duoi	
.eqv KEY_W	0x00000077		# di chuyen len tren
.eqv KEY_Z	0x0000007A		# giam toc do di chuyen
.eqv KEY_X	0x00000078 		# tang toc do di chuyen
.eqv KEY_ENTER	0x0000000A		# chuong trinh dung lai
# thiet lap khoang cach giua hai duong tron
.eqv khoang_cach	10	
.eqv KEY_CODE	0xFFFF0004
.eqv KEY_READY	0xFFFF0000
#==========================================================================================
.data	
	Array: 	.space 512 	#cap bo nho luu toa do cac diem cua duong tron
.text
 	li	 $s0, 256		# x = 256 khoi tao toa do x ban dau cua tam duong tron
 	li	 $s1, 256		# y = 256 khoi tao toa do y ban dau cua tam duong tron
 	li	 $s2, 20		# R = 20  R la ban kinh cua duong tron
	li	 $s3, 512		# SCREEN_WIDTH = 512 chieu rong man hinh
 	li	 $s4, 512		# SCREEN_HEIGHT = 512chieu dai man hinh
 	li	 $s5, YELLOW 	# duong tron co mau vang
 	li	 $t6, khoang_cach	# Khoang cach giua cac hinh tron
 	li	 $s7, 0		# dx = 0 toa do x hien tai cua tam duong tron
 	li	 $t8, 0		# dy = 0 toa do y hien tai cua tam duong tron
 	li	 $t9, 70    	# Thanh ghi luu tru thoi gian delay (toc do di chuyen cua hinh tron)
 
#==========================================================================================
 # HAM KHOI TAO TOA DO DUONG TRON
 #=========================================================================================
 khoi_tao: 
	li	 $t0, 0			# khoi tao i = 0
	la	 $t5, Array			# luu dia chi cua mang vao thanh ghi $t5
 loop:					# tao vong lap chay tu i den R
 	slt	 $v0, $t0, $s2		# v0=1 neu i<R
 	beq	 $v0,$zero,ket_thuc		# v0=0 <=>i >=R thi nhay den ket_thuc
	mul	 $s6, $s2, $s2		# s6=R*R=R^2
	mul	 $t3, $t0, $t0			# t3=i*i=i^2
	sub	 $t3, $s6, $t3		# $t3 = R^2 - i^2   
	move	 $v1, $t3			# v1=t3
	jal	 sqrt			# nhay den ham tinh can cua t3
				
	sw	 $a0, 0($t5)		# lay gia tri cua thanh ghi a0= sqrt(R^2 - i^2) luu vao mang du lieu
	addi	 $t0, $t0, 1		# i=i+1 
	add	 $t5, $t5, 4		# di den vi tri tiep theo cua mang du lieu
	j	 loop
 ket_thuc:
 #----------------------------------------------------------------
 # tao ham lam cho chuong trinh dung chay trong 1 khoang thoi gian
 # thoi gian co gia tri luu o thanh ghi %r khi goi ham 
.macro delay(%r)	
 	addi 	$a0,%r,0
 	li      $v0, 32 
 	syscall
.end_macro
#tao ham de dat lai mau va ve them duong tron o vi tri moi
#dia chi cua mau luu o thanh ghi %color khi goi ham	
.macro datmauveduongtron(%color)
	li 	 $s5, %color		
 	jal	ham_ve_duong_tron		
.end_macro  
 #===========================================================================================
 # HAM NHAP DU LIEU TU BAN PHIM
 #===========================================================================================
 Start :
 doc_ky_tu:
 	lw	 $k1, KEY_READY 		# kiem tra da nhap ki tu nao chua?
 	beqz	 $k1, check_vi_tri		# Neu k1!=0 =>da nhap ky tu thi nhay den ham kiem tra vi tri 
 	lw	 $k0, KEY_CODE		# thanh ghi k0 luu gia tri ki tu nhap vao
 	beq	 $k0, KEY_A, case_a  	# di chuyen qua trai
 	beq	 $k0, KEY_D, case_d 	# di chuyen qua phai
 	beq	 $k0, KEY_S, case_s	# di chuyen xuong duoi
 	beq	 $k0, KEY_W, case_w 	# di chuyen len tren
 	beq	 $k0, KEY_X, case_x 	# Giam toc do
 	beq	 $k0, KEY_Z, case_z 	# Tang toc do
 	beq	 $k0, KEY_ENTER, case_enter # Dung chuong trinh
 	j	 check_vi_tri
 	nop
 case_a:
 	jal	 di_sang_trai
 	j	 check_vi_tri
 case_d:
 	jal	 di_sang_phai
 	j	 check_vi_tri 	
 case_s:
 	jal	 di_chuyen_xuong
 	j	 check_vi_tri
 case_w:
 	jal	 di_chuyen_len
 	j	 check_vi_tri
 case_x:
	addi	 $t9,$t9,-30		
 	j	 check_vi_tri
 case_z:
 	addi	 $t9,$t9,30
 	j	 check_vi_tri 
 case_enter: 
 	j	 endProgram
 endProgram:
 	li	 $v0, 10
 	syscall
 #==========================================================================================			 					
 # CAC HAM DI CHUYEN 
 #==========================================================================================
di_sang_trai:				# thay doi toa do x, giu nguyen toa do y
	sub	 $s7, $zero, $t6		# toa do x hien tai cua duong tron =  - khoang cach giua 2 duong tron
 	li	 $t8, 0			
	jr	 $ra 	
di_sang_phai:				# thay doi toa do x, giu nguyen toa do y
	add	 $s7, $zero, $t6		# toa do x hien tai cua duong tron =  + khoang cach giua 2 duong tron
 	li	 $t8, 0			
	jr	 $ra 	
di_chuyen_len:				# thay doi toa do y, giu nguyen toa do x
	li 	$s7, 0
	sub 	$t8, $zero, $t6		# toa do y hien tai cua duong tron = - khoang cach giua 2 duong tron
	jr 	$ra 	
di_chuyen_xuong:
	li 	$s7, 0
	add 	$t8, $zero, $t6		# toa do y hien tai cua duong tron = + khoang cach giua 2 duong tron
	jr 	$ra 
 #===============================================================================================
 # HAM KIEM TRA VI TRI 
 #===============================================================================================
 check_vi_tri:		
 phia_ben_phai:
 	add	 $v0, $s0, $s2		# v0=x0 + R , toa do tam hien tai+ ban kinh
 	add	 $v0, $v0,$s7		# neu x0 + R + khoang_cach > 512 thi nhay den ham di_sang_trai
 	slt	 $v1, $v0,$s3		# v1=1 neu v0< 512
 	bne 	 $v1, $zero,phia_ben_trai
 	jal	 di_sang_trai	
 	nop
 phia_ben_trai:
 	sub	 $v0, $s0, $s2		# v0=x0-R
 	add	 $v0, $v0, $s7		# neu x0 - R + khoang_cach < 0 thi nhay den ham di_sang_phai
 	slt	 $v1, $v0, $zero 		# v1=1 neu v0< 0
 	beq	 $v1, $zero, phia_tren	
 	jal	 di_sang_phai	
 	nop
phia_tren:
 	sub 	 $v0, $s1, $s2		# v0=y0 - R
 	add 	 $v0, $v0, $t8		# neu y0 - R + khoang_cach < 0 thi nhay den ham di chuyen len
 	slt	 $v1, $v0, $zero 		# v1=1 neu v0< 0
 	beq	 $v1, $zero, phia_duoi
 	jal 	 di_chuyen_xuong	
 	nop
 phia_duoi:
 	add 	 $v0, $s1, $s2		# v0 = y0 + R
 	add 	 $v0, $v0, $t8		# neu y0 + R + khoang_cach > 512 thi nhay den ham di_chuyen_xuong
 	slt	 $v1, $v0,$s4		# v1=1 neu v0< 512
 	bne 	 $v1, $zero,draw
 	jal 	di_chuyen_len				
 	nop 	

#================================================================================================
# HAM VE DUONG TRON
#================================================================================================
	 					 				
draw: 	
 	datmauveduongtron(BACKGROUND) 	# ve duong tron trung mau nen
 	add	 $s0, $s0, $s7		# Cap nhat toa do x cua duong tron
 	add	 $s1, $s1, $t8		# cap nhat toa do y cua duong tron
 
 	datmauveduongtron(YELLOW) 		# ve duong tron moi mau vang
 	delay($t9)				# dung 1 khoang thoi gian roi ve duong tron moi	
 	j Start

 ham_ve_duong_tron:
	add	 $sp, $sp, -4
	sw	 $ra, 0($sp)
 	li	 $t0, 0			# khoi tao bien i = 0
 loop_ve_duong_tron:
  	slt	 $v0, $t0, $s2   		# v0=1 neu i< R
  	beq	 $v0, $zero, ket_thuc_ve	# neuv0=0 <=> i>=R => ket_thuc_ve
	sll	 $t5, $t0, 2		# dich trai thanh ghi t0 2bit	
	lw	 $t3, Array($t5) 		# nap sqrt(R^2-i^2) luu o Array vao thanh ghi $t3(y)
 	move 	 $a0, $t0			# i = #t0= $a0
	move	 $a1, $t3			# j = $t3= $a1
	jal	 ve_diem			# ve 2 diem (x0 + i, y0 + j), (x0 + j, y0 + i) tren phan tu thu I
	sub	 $a1, $zero, $t3
	jal	 ve_diem			# ve 2 diem (x0 + i, y0 - j), (x0 + j, y0 - i) tren phan tu thu II
	sub	 $a0, $zero, $t0
	jal	 ve_diem			# ve 2 diem (x0 - i, y0 - j), (x0 - j, y0 - i) tren phan tu thu III
	add	 $a1, $zero, $t3
	jal	 ve_diem			# ve 2 diem (x0 - i, y0 + j), (x0 - j, y0 + i) tren phan tu thu IV	
	addi	 $t0, $t0, 1
	j	 loop_ve_duong_tron
 ket_thuc_ve:
 	lw	 $ra, 0($sp)
 	add	 $sp, $sp, 0	
 	jr	 $ra
# Ham ve diem tren duong tron
 ve_diem:
 	
 	add	 $t1, $s0, $a0 		# xi = x0 + i
	add	 $t4, $s1, $a1		# yi = y0 + j
	mul	 $t2, $t4, $s3		# yi * SCREEN_WIDTH
	add	 $t1, $t1, $t2		# yi * SCREEN_WIDTH + xi (Toa do 1 chieu cua diem anh)
	sll	 $t1, $t1, 2		# dia chi tuong doi cua diem anh
	sw	 $s5, SCREEN($t1)		# ve anh
	add	 $t1, $s0, $a1 		# xi = x0 + j
	add	 $t4, $s1, $a0		# yi = y0 + i
	mul	 $t2, $t4, $s3		# yi * SCREEN_WIDTH
	add	 $t1, $t1, $t2		# yi * SCREEN_WIDTH + xi (Toa do 1 chieu cua diem anh)
	sll	 $t1, $t1, 2		# dia chi tuong doi cua diem anh
	sw	 $s5, SCREEN($t1)		# ve anh	
	jr	 $ra
#--------------------------------------------------------------------------------------------			 				
# Ham tinh can cua t3
sqrt: 
	mtc1	 $v1, $f1		# dua gia tri trong thanh ghi v1 vao thanh ghi f1
	cvt.s.w	 $f1, $f1 		# chuyen gia tri cua f1 tuong duong voi gia tri so nguyen 32 bit
	sqrt.s	 $f1, $f1 		# Tinh can bac hai cua gia tri thanh ghi f1
	cvt.w.s	 $f1, $f1 		# Chuyen f1 ve dang 32-bit
	mfc1	 $a0, $f1 		# dat gia tri thanh ghi a0=f1
	jr	 $ra
#end of project


