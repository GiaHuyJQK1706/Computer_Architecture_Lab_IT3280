.data
CharPtr1:	.word 	0	# Bien con tro, tro toi kieu asciiz
CharPtr2:	.word 	0	# Bien con tro, tro toi kieu asciiz
ArrayPtr:	.word 	0	# Bien con tro mang 1 chieu
Array2Ptr:	.word	0	# Bien con tro mang 2 chieu
message1:	.asciiz	"\n\n1. Xu ly mang mot chieu\n"
message2:	.asciiz	"2. Sao chep mang ky tu\n"
message3:	.asciiz	"3. Xu ly mang hai chieu\n"
message4:	.asciiz	"4. Giai phong bo nho\n"
message0.1:	.asciiz "So phan tu: "
message0.2:	.asciiz "So byte moi phan tu (1 hoac 4): "
message0.3:	.asciiz "Nhap phan tu: "
message1.1:	.asciiz	"Gia tri cua con tro: "
message1.2:	.asciiz	"\nDia chi cua con tro: "
message1.3:	.asciiz "\nTong dia chi da cap phat: "
message2.1:	.asciiz "So ky tu toi da: "
message2.2:	.asciiz "\nNhap chuoi ky tu: "
message2.3:	.asciiz	"\nChuoi ky tu duoc copy: "
message3.1:	.asciiz	"\nSo hang: "
message3.2:	.asciiz	"\nSo cot: "
message3.3:	.asciiz	"\n1. getArray[i][j]\n"
message3.4:	.asciiz	"2. setArray[i][j]\n"
message3.5:	.asciiz	"3. Thoat\n"
message3.6:	.asciiz "\nGia tri cua phan tu: "
message3.01:	.asciiz	"i = "
message3.02:	.asciiz	"j = "
message4.1:	.asciiz	"Da giai phong toan bo bo nho cap phat.\n"
select:		.asciiz	"Lua chon: "
errmessage:	.asciiz	"\nSo vua nhap khong hop le.\n"

.kdata
# Bien chua dia chi dau tien cua vung nho con trong
Sys_TheTopOfFree:	.word 	1
# Vung khong gian tu do, dung de cap bo nho cho cac bien con tro
Sys_MyFreeSpace:

.text
#Khoi tao vung nho cap phat dong
	jal	SysInitMem

	menu:
	li	$v0, 4
	la	$a0, message1
	syscall
	la	$a0, message2
	syscall
	la	$a0, message3
	syscall
	la	$a0, message4
	syscall
	la	$a0, select
	syscall
	li	$v0, 5
	syscall
case_1:	
	bne	$v0, 1, case_2
	li	$v0, 4
	la	$a0, message0.1
	syscall
	li	$v0, 5
	syscall
	bltz	$v0, error
	move	$a1, $v0
	li	$v0, 4
	la	$a0, message0.2
	syscall
	li	$v0, 5
	syscall
is1:	beq	$v0, 1, ready  
is4:	beq	$v0, 4, ready
	j	error
ready:	move	$a2, $v0
	la	$a0, ArrayPtr
	jal	malloc
	move	$t0, $v0
	li	$v0, 4
	la	$a0, message0.3
	syscall
	move	$a0, $t0
	add	$t0, $0, $0
input_loop:
	beq	$t0, $a1, input_end
	li	$v0, 5
	syscall
	bne	$a2, 1, byte_4
byte_1:
	sb	$v0, 0($a0)
	addi	$a0, $a0, 1
	addi	$t0, $t0, 1
	j	input_loop
byte_4:	
	sw	$v0, 0($a0)
	addi	$a0, $a0, 4
	addi	$t0, $t0, 1
	j	input_loop
input_end:
	li	$v0, 4
	la	$a0, message1.1
	syscall
	la	$a0, ArrayPtr
	jal	getValue
	move	$a0, $v0
	li	$v0, 34
	syscall
	li	$v0, 4
	la	$a0, message1.2
	syscall
	la	$a0, ArrayPtr
	jal	getAddress
	move	$a0, $v0
	li	$v0, 34
	syscall
	li	$v0, 4
	la	$a0, message1.3
	syscall
	jal	memoryCalculate
	move	$a0, $v0
	li	$v0, 1
	syscall
	j	menu
case_2:
	bne	$v0, 2, case_3
	li	$v0, 4
	la	$a0, message2.1
	syscall
	li	$v0, 5
	syscall
	move	$a1, $v0
	addi	$a2, $0, 1
	la	$a0, CharPtr1
	jal	malloc
	move	$s0, $v0
	la	$a0, CharPtr2
	jal	malloc
	move	$s1, $v0
	li	$v0, 4
	la	$a0, message2.2
	syscall
	move	$a0, $s0
	li	$v0, 8
	syscall
	move	$a1, $s1
	jal	strcpy
	li	$v0, 4
	la	$a0, message2.3
	syscall
	move	$a0, $s1
	syscall
	j	menu
case_3:
	bne	$v0, 3, case_4
	li	$v0, 4
	la	$a0, message3.1
	syscall
	li	$v0, 5
	syscall
	move	$a1, $v0
	li	$v0, 4
	la	$a0, message3.2
	syscall
	li	$v0, 5
	syscall
	move	$a2, $v0
	la	$a0, Array2Ptr
	jal	malloc2
	move	$t0, $v0
	li	$v0, 4
	la	$a0, message0.3
	syscall
	move	$a0, $t0
	add	$t0, $0, $0
	move	$t1, $a1
	mul	$a1, $a1, $a2
input_loop2:
	beq	$t0, $a1, input_end2
	li	$v0, 5
	syscall
	sw	$v0, 0($a0)
	addi	$a0, $a0, 4
	addi	$t0, $t0, 1
	j	input_loop2
input_end2:
	move	$a1, $t1	
sub_menu:
	li	$v0, 4
	la	$a0, message3.3
	syscall
	la	$a0, message3.4
	syscall
	la	$a0, message3.5
	syscall
	la	$a0, select
	syscall
	li	$v0, 5
	syscall
sub_case_1:
	bne	$v0, 1, sub_case_2
	li	$v0, 4
	la	$a0, message3.01
	syscall
	li	$v0, 5
	syscall
	move	$s0, $v0
	li	$v0, 4
	la	$a0, message3.02
	syscall
	li	$v0, 5
	syscall
	move	$s1, $v0
	la	$t0, Array2Ptr
	lw	$a0, 0($t0)
	jal	getArray
	move	$s2, $v0
	li	$v0, 4
	la	$a0, message3.6
	syscall
	li	$v0, 1
	move	$a0, $s2
	syscall
	j	sub_menu
sub_case_2:
 	bne	$v0, 2, sub_case_3
 	li	$v0, 4
	la	$a0, message3.01
	syscall
	li	$v0, 5
	syscall
	move	$s0, $v0
	li	$v0, 4
	la	$a0, message3.02
	syscall
	li	$v0, 5
	syscall
	move	$s1, $v0
	move	$s2, $v0
	li	$v0, 4
	la	$a0, message0.3
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
case_4:
	bne	$v0, 4, error
	jal	free
	li	$v0, 4
	la	$a0, message4.1
	syscall
	li	$v0, 4
	la	$a0, message1.3
	syscall
	jal	memoryCalculate
	move	$a0, $v0
	li	$v0, 1
	syscall	
	j	menu
error:
	li	$v0, 4
	la	$a0, errmessage
	syscall
	j	menu
#------------------------------------------
# Ham khoi tao cho viec cap phat dong
# @param	khong co
# @detail	Danh dau vi tri bat dau cua vung nho co the cap phat duoc
#------------------------------------------
SysInitMem: 
	la	$t9, Sys_TheTopOfFree	# Lay con tro chua dau tien con trong, khoi tao
	la	$t7, Sys_MyFreeSpace	# Lay dia chi dau tien con trong, khoi tao   
	sw	$t7, 0($t9)		# Luu lai
	jr	$ra
#------------------------------------------
# Ham cap phat bo nho dong cho cac bien con tro
# @param	[in/out]	$a0: Chua dia chi cua bien con tro can cap phat
# Khi ham ket thuc, dia chi vung nho duoc cap phat se luu tru vao bien con tro
# @param	[in]		$a1: So phan tu can cap phat
# @param	[in]		$a2: Kich thuoc 1 phan tu, tinh theo byte
# @return			$v0: Dia chi vung nho duoc cap phat
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
	addi	$v0, $t8, 0	# Dong thoi la ket qua tra ve cua ham 
	mul	$t7, $a1,$a2	# Tinh kich thuoc cua mang can cap phat
	add	$t6, $t8, $t7	# Tinh dia chi dau tien con trong 
	sw	$t6, 0($t9)	# Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree
	jr	$ra
#------------------------------------------
# Ham lay gia tri cua bien con tro
# @param	[in]		$a0: Chua dia chi cua bien con tro can lay gia tri 
# @return			$v0: Gia tri cua bien con tro
#------------------------------------------
getValue:
	lw	$v0, 0($a0)	# Lay gia tri cua bien con tro trong o nho co dia chi luu trong $a0
	jr	$ra
#------------------------------------------
# Ham lay dia chi cua bien con tro
# @param	[in]		$a0: Chua dia chi cua bien con tro can lay dia chi
# @return			$v0: Dia chi cua bien con tro
#------------------------------------------	
getAddress:
	add	$v0, $0, $a0	# Lay dia chi tu $a0
	jr	$ra
#------------------------------------------
# Ham copy 2 con tro xau ky tu
# @param	[in]	$a0: Chua dia chi cua bien con tro xau ky tu nguon
# @param	[in]	$a1: Chua dia chi cua bien con tro xau ky tu dich
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
# Ham giai phong bo nho da cap phat	
# @param	khong co
#------------------------------------------
free:
	addi	$sp, $sp, -4	# Khoi tao 1 vi tri trong stack
	sw	$ra, 0($sp)	# Luu $ra vao stack
	jal	SysInitMem	# Tai lap lai vi tri cua con tro luu dia chi dau tien con trong
	lw	$ra, 0($sp)	# Tra gia tri cho $ra
	addi	$sp, $sp, 4	# Xoa stack
#------------------------------------------
# Ham tinh toan bo nho da cap phat	
# @param	khong co
# @return	$v0: so byte da cap phat
#------------------------------------------	
memoryCalculate:
	la	$t0, Sys_MyFreeSpace	# Lay dia chi dau tien duoc cap phat
	la	$t1, Sys_TheTopOfFree	# Lay dia chi luu dia chi dau tien con trong
	lw	$t2, 0($t1)		# Lay dia chi dau tien con trong
	sub	$v0, $t2, $t0		# Tru hai dia chi cho nhau
	jr	$ra
#------------------------------------------
# Ham cap phat bo nho cho mang word 2 chieu	
# @param	[in/out]	$a0: Chua dia chi cua bien con tro can cap phat
# Khi ham ket thuc, dia chi vung nho duoc cap phat se luu tru vao bien con tro
# @param	[in]		$a1: So hang can cap phat
# @param	[in]		$a2: So cot can cap phat
# @return			$v0: Dia chi vung nho duoc cap phat
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
# Ham lay gia tri cua phan tu trong mang 2 chieu
# @param	[in]		$a0: Chua dia chi cua bien con tro
# @param	[in]		$a1: So hang cua mang
# @param	[in]		$a2: So cot cua mang
# @param	[in]		$s0: Chi so i cua phan tu
# @param	[in]		$s1: Chi so j cua phan tu
# @return			$v0: Gia tri cua phan tu
#------------------------------------------	
getArray:
	mul	$t0, $s0, $a2	# Vi tri cua phan tu = i * so cot + j
	add	$t0, $t0, $s1
	sll	$t0, $t0, 2	# Do phan tu co kieu word nen phai * 4 de ra khoang cach dia chi tuong doi so voi dia chi dau
	add	$t0, $t0, $a0	# Cong dia chi dau de ra dia chi phan tu
	lw	$v0, 0($t0)	# Lay gia tri phan tu
	jr	$ra
#------------------------------------------
# Ham dat gia tri cua phan tu trong mang 2 chieu
# @param	[in]		$a0: Chua dia chi cua bien con tro
# @param	[in]		$a1: So hang cua mang
# @param	[in]		$a2: So cot cua mang
# @param	[in]		$s0: Chi so i cua phan tu
# @param	[in]		$s1: Chi so j cua phan tu
# @param	[in]		$v0: Gia tri can dat vao phan tu
#------------------------------------------		
setArray:
	mul	$t0, $s0, $a2	# Vi tri cua phan tu = i * so cot + j
	add	$t0, $t0, $s1
	sll	$t0, $t0, 2	# Do phan tu co kieu word nen phai * 4 de ra khoang cach dia chi tuong doi so voi dia chi dau
	add	$t0, $t0, $a0	# Cong dia chi dau de ra dia chi phan tu
	sw	$v0, 0($t0)	# Dat gia tri phan tu
	jr	$ra
	
