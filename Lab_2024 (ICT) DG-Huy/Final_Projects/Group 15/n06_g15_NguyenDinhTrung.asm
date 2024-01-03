.data
CharPtr1:	.word 	0	
CharPtr2:	.word 	0	
ArrayPtr:	.word 	0	
Array2Ptr:	.word	0	
mess1:	.asciiz	"\n\n1. Mang mot chieu\n"
mess2:	.asciiz	"2. Sao chep mang ky tu\n"
mess3:	.asciiz	"3. Mang hai chieu\n"
mess4:	.asciiz	"4. Giai phong bo nho\n"
mess5:	.asciiz	"5. Hien thi bo nho\n"
mess6:  .asciiz "6. Ket thuc chuong trinh\n"
mess0.1:	.asciiz "So phan tu: "
mess0.2:	.asciiz "So byte moi phan tu (1 hoac 4): "
mess0.3:	.asciiz "Nhap phan tu: \n"
mess1.1:	.asciiz	"Gia tri cua con tro: "
mess1.2:	.asciiz	"\nDia chi cua con tro: "
mess1.3:	.asciiz "\nTong bo nho da cap phat: "
mess2.1:	.asciiz "So ky tu toi da: "
mess2.2:	.asciiz "\nNhap chuoi ky tu: "
mess2.3:	.asciiz	"\nChuoi ky tu duoc copy: "
mess3.1:	.asciiz	"\nSo hang: "
mess3.2:	.asciiz	"\nSo cot: "
mess3.3:	.asciiz	"\n1. getArray[i][j]\n"
mess3.4:	.asciiz	"2. setArray[i][j]\n"
mess3.5:	.asciiz	"3. Thoat\n"
mess3.6:	.asciiz "\nGia tri cua phan tu: "
mess3.01:	.asciiz	"i = "
mess3.02:	.asciiz	"j = "
mess4.1:	.asciiz	"Da giai phong toan bo bo nho cap phat.\n"
select:		.asciiz	"Lua chon: "
errmess:	.asciiz	"\nSo vua nhap khong hop le.\n"

.kdata
# Bien chua dia chi dau tien cua vung nho con trong
Sys_TheTopOfFree:	.word 	1
# Vung khong gian tu do, dung de cap bo nho cho cac bien con tro
Sys_MyFreeSpace:

.text
#Khoi tao vung nho cap phat dong
	jal	SysInitMem
#Hien thi menu
menu:
	li	$v0, 4
	la	$a0, mess1
	syscall
	la	$a0, mess2
	syscall
	la	$a0, mess3
	syscall
	la	$a0, mess4
	syscall
	la	$a0, mess5
	syscall
	la	$a0, mess6
	syscall
	la	$a0, select
	syscall
	li	$v0, 5 #Nhap lua chon
	syscall
#1. Sua loi bo nho cua vi du
case_1:	
	bne	$v0, 1, case_2 
	li	$v0, 4 
	la	$a0, mess0.1
	syscall
	li	$v0, 5 #Nhap so phan tu cua day 1 chieu
	syscall
	bltz	$v0, error #Kiem tra so da nhap vao, neu v0 < 0 thi bao loi va yeu cau nhap lai
	move	$a1, $v0 #Luu so phan tu vao a1
	li	$v0, 4
	la	$a0, mess0.2
	syscall
	li	$v0, 5 #Nhap kich thuc moi phan tu cua day
	syscall
is1:	beq	$v0, 1, ready  
is4:	beq	$v0, 4, ready
	j	error	#Kiem tra kich thuoc nhap vao, neu không phai 1 hay 4 thi bao loi va yeu cau nhap lai
ready:	move	$a2, $v0 #Luu kich thuoc moi phan tu vao a2
	la	$a0, ArrayPtr #Luu dia chi bat dau cua chuoi mot chieu
	jal	malloc #Chay ham malloc cho chuoi 1 chieu
	move	$t0, $v0 #Dat dia chi bat dau tra tu malloc vao t0
	li	$v0, 4
	la	$a0, mess0.3
	syscall
	move	$a0, $t0 #Dat a0 = t0
	li	$t0, 0 #Dat t0 = 0
input_loop:
	beq	$t0, $a1, input_end #Bat dau vong lap nhap du lieu, ket thuc khi t0 = a1
	li	$v0, 5
	syscall
	bne	$a2, 1, byte_4 
byte_1:
	sb	$v0, 0($a0)
	addi	$a0, $a0, 1 #Neu kich thuoc phan tu bang 1 thi con tro tien 1 don vi
	addi	$t0, $t0, 1
	j	input_loop
byte_4:	
	sw	$v0, 0($a0)
	addi	$a0, $a0, 4 #Neu kich thuoc phan tu bang 4 thi con tro tien 4 don vi
	addi	$t0, $t0, 1
	j	input_loop
input_end:
#2. Gia tri cua con tro
	li	$v0, 4
	la	$a0, mess1.1
	syscall
	la	$a0, ArrayPtr
	jal	getValue
	move	$a0, $v0
	li	$v0, 34
	syscall
#3. Dia chi cua con tro
	li	$v0, 4
	la	$a0, mess1.2
	syscall
	la	$a0, ArrayPtr
	jal	getAddress
	move	$a0, $v0
	li	$v0, 34
	syscall

	j	menu
#4. Vi?t hàm th?c hi?n copy 2 con tr? xâu kí t?.
case_2:
	bne	$v0, 2, case_3
	li	$v0, 4
	la	$a0, mess2.1
	syscall
	li	$v0, 5 #Nhap vao so ky tu toi da cua chu?i
	syscall
	move	$a1, $v0 #Luu so ky tu toi da vao a1
	li	$a2, 1 #Dat a2 = 1
	la	$a0, CharPtr1 #Dat dia chi cua chuoi 1 vao a0 va goi malloc
	jal	malloc
	move	$s0, $v0 #Dat s0 lam bien con tro cua chuoi 1
	la	$a0, CharPtr2#Dat dia chi cua chuoi 2 vao a0 va goi malloc
	jal	malloc
	move	$s1, $v0 #Dat s0 lam bien con tro cua chuoi 2
	li	$v0, 4
	la	$a0, mess2.2
	syscall
	move	$a0, $s0 #Nhap vao chuoi thu nhat
	li	$v0, 8
	syscall
	move	$a1, $s1 #Dat a1 la bien con tro cua chu?i 2.
	jal	strcpy
	li	$v0, 4	#In ra hai chuoi
	la	$a0, mess2.3
	syscall
	move	$a0, $s1 
	syscall
	j	menu
#7. Viet ham malloc 2:
case_3:
	bne	$v0, 3, case_4
	li	$v0, 4 
	la	$a0, mess3.1
	syscall
	li	$v0, 5 #Nhap vao so hang
	syscall
	move	$a1, $v0
	li	$v0, 4
	la	$a0, mess3.2
	syscall
	li	$v0, 5 #Nhap vao so cot
	syscall
	move	$a2, $v0
	la	$a0, Array2Ptr #Luu vao a0 dia chi cua mang 2 chieu
	jal	malloc2
	move	$t0, $v0 #Gan t0 bien con tro
	li	$v0, 4
	la	$a0, mess0.3
	syscall
	move	$a0, $t0 #Gan a0 thanh bien con tro
	add	$t0, $0, $0#Khoi tâo t0 = 0
	move	$t1, $a1 #t1 la so hang
	mul	$a1, $a1, $a2 #a1 la so phan tu
input_loop2:
	beq	$t0, $a1, input_end2 #su dung chuoi de nhap vao day, ket thuc khi t0 == so phan tu
	li	$v0, 5
	syscall
	sw	$v0, 0($a0)
	addi	$a0, $a0, 4
	addi	$t0, $t0, 1
	j	input_loop2
input_end2:
	move	$a1, $t1 #tra lai so hang ve a1	
#8. Ham getArray va setArray
sub_menu:
	li	$v0, 4
	la	$a0, mess3.3
	syscall
	la	$a0, mess3.4
	syscall
	la	$a0, mess3.5
	syscall
	la	$a0, select
	syscall
	li	$v0, 5
	syscall
sub_case_1:
	bne	$v0, 1, sub_case_2
	li	$v0, 4
	la	$a0, mess3.01
	syscall
	li	$v0, 5 #Nhap so hang
	syscall
	move	$s0, $v0 #Luu vao s0
	li	$v0, 4
	la	$a0, mess3.02
	syscall
	li	$v0, 5 #Nhap so cot
	syscall
	move	$s1, $v0 #Luu vao s1
	la	$t0, Array2Ptr
	lw	$a0, 0($t0)
	jal	getArray
	move	$s2, $v0
	li	$v0, 4
	la	$a0, mess3.6
	syscall
	li	$v0, 1
	move	$a0, $s2
	syscall
	j	sub_menu
sub_case_2:
 	bne	$v0, 2, sub_case_3
 	li	$v0, 4
	la	$a0, mess3.01
	syscall
	li	$v0, 5
	syscall
	move	$s0, $v0
	li	$v0, 4
	la	$a0, mess3.02
	syscall
	li	$v0, 5
	syscall
	move	$s1, $v0
	move	$s2, $v0
	li	$v0, 4
	la	$a0, mess0.3
	syscall
	li	$v0, 5
	syscall
	la	$t0, Array2Ptr
	lw	$a0, 0($t0)
	jal	setArray
	j	sub_menu
sub_case_3:
	bne	$v0, 3, error
	j	menu
#5. Gi?i phóng b? nh?
case_4:
	bne	$v0, 4, case_5
	jal	free
	li	$v0, 4
	la	$a0, mess4.1
	syscall
	li	$v0, 4
	la	$a0, mess1.3
	syscall
	jal	memoryCalculate
	move	$a0, $v0
	li	$v0, 1
	syscall	
	j	menu
#6. Vi?t hàm tính toàn b? l??ng b? nh? ?ã c?p phát.
case_5:

	bne	$v0, 5, case_6
	li	$v0, 4
	la	$a0, mess1.3
	syscall
	jal	memoryCalculate
	move	$a0, $v0
	li	$v0, 1
	syscall
	j	menu
case_6:

	bne $v0, 6, error
	li $v0, 10
	syscall
error:
	li	$v0, 4
	la	$a0, errmess
	syscall
	j	menu
#------------------------------------------

SysInitMem: 
	la	$t9, Sys_TheTopOfFree	# Lay con tro chua dau tien con trong, khoi tao
	la	$t7, Sys_MyFreeSpace	# Lay dia chi dau tien con trong, khoi tao   
	sw	$t7, 0($t9)		# Luu lai
	jr	$ra
#------------------------------------------

malloc:  
	la	$t9, Sys_TheTopOfFree
	lw	$t8, 0($t9)		# Lay dia chi dau tien con trong
	bne	$a2, 4, initialize	# Neu mang khoi tao co kieu Word, kiem tra dia chi dau co dam bao quy tac khong
	andi	$t0, $t8, 0x03		# Lay so du khi chia dia chi trong cho 4
	beq	$t0, 0, initialize	# Neu khong co du, bo qua
	addi	$t8, $t8, 4		# Neu co, tien toi dia chi chia het cho 4 tiep theo
	subu	$t8, $t8, $t0
initialize:	
	sw	$t8, 0($a0)	# Cat dia chi do vao bien con tro
	move	$v0, $t8	# Dong thoi la ket qua tra ve cua ham 
	mul	$t7, $a1,$a2	# Tinh kich thuoc cua mang can cap phat
	add	$t6, $t8, $t7	# Tinh dia chi dau tien con trong 
	sw	$t6, 0($t9)	# Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree
	jr	$ra
#------------------------------------------

getValue:
	lw	$v0, 0($a0)	# Lay gia tri cua bien con tro trong o nho co dia chi luu trong $a0
	jr	$ra
#------------------------------------------

getAddress:
	add	$v0, $0, $a0	# Lay dia chi tu $a0
	jr	$ra
#------------------------------------------

strcpy:
	add	$t0, $0, $a0	# Khoi tao $t0 o dau xau ky tu nguon
	add	$t1, $0, $a1	# Khoi tao $t1 o dau xau ky tu dich
	addi	$t2, $0, 1	# Khoi tao $t2 la ky tu khac '\0' de chay vong lap
cpyLoop:
	beq	$t2, 0, cpyLoopEnd	# Neu ky tu duoc copy trong vong lap truoc la '\0', dung vong lap
	lb	$t2, 0($t0)		# Doc ky tu o xau ky tu nguon
	sb	$t2, 0($t1)		# Luu ky tu vua doc vao xau ky tu dich
	addi	$t0, $t0, 1		# Chuyen $t0 tro sang vi tri cua phan tu tiep theo trong xau ky tu nguon
	addi	$t1, $t1, 1		# Chuyen $t1 tro sang vi tri cua phan tu tiep theo trong xau ky tu dich
	j	cpyLoop
cpyLoopEnd:
	jr	$ra
#------------------------------------------

free:
	addi	$sp, $sp, -4	# Khoi tao 1 vi tri trong stack
	sw	$ra, 0($sp)	# Luu $ra vao stack
	jal	SysInitMem	# Tai lap lai vi tri cua con tro luu dia chi dau tien con trong
	lw	$ra, 0($sp)	# Tra gia tri cho $ra
	addi	$sp, $sp, 4	# Xoa stack
#------------------------------------------

memoryCalculate:
	la	$t0, Sys_MyFreeSpace	# Lay dia chi dau tien duoc cap phat
	la	$t1, Sys_TheTopOfFree	# Lay dia chi luu dia chi dau tien con trong
	lw	$t2, 0($t1)		# Lay dia chi dau tien con trong
	sub	$v0, $t2, $t0		# Tru hai dia chi cho nhau
	jr	$ra
#------------------------------------------

malloc2:
	addi	$sp, $sp, -12	# Luu cac gia tri can thiet de thuc hien 1 chuong trinh con malloc trong chuong trinh con nay
	sw	$ra, 8($sp)
	sw	$a1, 4($sp)
	sw	$a2, 0($sp)
	mul	$a1, $a1, $a2	# $a1 = so phan tu = so hang * so cot
	addi	$a2, $0, 4	# $a2 = so byte cua 1 phan tu kieu word = 4
	jal	malloc		# Chuyen mang 2 chieu thanh mang 1 chieu, khoi tao
	lw	$ra, 8($sp)	# Tra lai gia tri cho cac thanh ghi
	lw	$a1, 4($sp)
	lw	$a2, 0($sp)
	addi	$sp, $sp, 12
	jr	$ra
#------------------------------------------

getArray:
	mul	$t0, $s0, $a2	# Vi tri cua phan tu = i * so cot + j
	add	$t0, $t0, $s1
	sll	$t0, $t0, 2	# Do phan tu co kieu word nen phai * 4 de ra khoang cach dia chi tuong doi so voi dia chi dau
	add	$t0, $t0, $a0	# Cong dia chi dau de ra dia chi phan tu
	lw	$v0, 0($t0)	# Lay gia tri phan tu
	jr	$ra
#------------------------------------------

setArray:
	mul	$t0, $s0, $a2	# Vi tri cua phan tu = i * so cot + j
	add	$t0, $t0, $s1
	sll	$t0, $t0, 2	# Do phan tu co kieu word nen phai * 4 de ra khoang cach dia chi tuong doi so voi dia chi dau
	add	$t0, $t0, $a0	# Cong dia chi dau de ra dia chi phan tu
	sw	$v0, 0($t0)	# Dat gia tri phan tu
	jr	$ra
	
