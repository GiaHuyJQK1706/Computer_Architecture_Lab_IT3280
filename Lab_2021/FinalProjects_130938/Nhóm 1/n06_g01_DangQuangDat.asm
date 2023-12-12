.data
CharPtr: .word  0 # Bien con tro, tro toi kieu asciiz
BytePtr: .word  0 # Bien con tro, tro toi kieu Byte
WordPtr: .word  0 # Bien con tro, tro toi kieu Word
ArrayPtr: .word 0

Nhapdulieu: .asciiz "Nhap du lieu : \n"

GtriChar: .asciiz "Gia tri bien con tro Char: " 
GtriByte: .asciiz "Gia tri bien con tro Byte: " 
GtriWord: .asciiz "Gia tri bien con tro Word: " 
DiachiChar: .asciiz "Dia chi con tro Char: "
DiachiByte: .asciiz "Dia chi con tro Byte: "
DiachiWord: .asciiz "Dia chi con tro Word: "
Nhaphangi: .asciiz "\nA[i][j]\nNhap so hang i: "
Nhapcotj: .asciiz "Nhap so cot j: "
NhapAij: .asciiz "\nNhap A[i][j]\n"
XuatAij: .asciiz "\nXuat A[i][j]\n"
Nhapi: 	.asciiz "Nhap i: "
Nhapj:	.asciiz "Nhap j: "
Tieptuc: .asciiz "Tiep tuc?"
Ketqua: .asciiz "A[i][j] = "
Bonho_Capphat: .asciiz "Luong bo nho da cap phat (byte): "
.kdata
Sys_TheTopOfFree: .word  1
Sys_MyFreeSpace: 
.text	
#Khoi tao vung nho cap phat dong
	li	$s5, 0
	jal  	SysInitMem 
	la  	$a0, CharPtr
	addi	$a1, $zero, 3
	addi	$a2, $zero, 4
	jal	malloc 
	jal	NhapDulieu
	la	$a0, BytePtr
	addi	$a1, $zero, 2
	addi	$a2, $zero, 4
	jal	malloc 
	jal	NhapDulieu
	la  	$a0, WordPtr
	addi 	$a1, $zero, 1
	addi 	$a2, $zero, 4
	jal  	malloc 
	jal	NhapDulieu
 	j 	Giatri

SysInitMem:  
	la	$t9, Sys_TheTopOfFree  #Lay con tro chua  dau tien con trong, khoi tao
	la	$t7, Sys_MyFreeSpace #Lay dia chi dau tien con trong, khoi tao 
	sw	$t7, 0($t9) # Luu lai
	jr   $ra

malloc:   
	la   	$t9, Sys_TheTopOfFree   
	lw  	$t8, 0($t9)	#Lay dia chi dau tien con trong
	sw	$t8, 0($a0)	#Cat dia chi do vao bien con tro
	addi	$v0, $t8, 0	#Dong thoi laket qua tra ve cua ham
 	mul	$t7, $a1,$a2	#Tinh kich thuoc cua mang can cap phat
 	add	$t6, $t8, $t7	#Tinh dia chi dau tien controng 
 	sw	$t6, 0($t9)	#Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree 
 	jr   $ra
NhapDulieu: 
	li	$s3, 0
	la	$a0, Nhapdulieu
	li	$v0, 4
	syscall
	LapDl:
	li 	$v0, 5
	syscall
	sw	$v0, 0($t8)
	addi	$t8, $t8, 4
	addi	$s3, $s3, 1
	beq 	$s3, $a1, DungLap
	j	LapDl
	DungLap:
	jr	$ra
	
#2.Ham lay gia tri bien con tro
Giatri:
	la	$a0, CharPtr
	lw	$t8, 0($a0)
	lw	$t5, 0($t8)	
	la 	$a0, GtriChar
	li 	$v0, 56
	move	$a1, $t5
	syscall
	
	la	$a0, BytePtr
	lw	$t8, 0($a0)
	lw	$t5, 0($t8)
	la 	$a0, GtriByte
	li 	$v0, 56
	move	$a1, $t5
	syscall
	
	la	$a0, WordPtr
	lw	$t8, 0($a0)
	lw	$t5, 0($t8)
	la 	$a0, GtriWord
	li 	$v0, 56
	move	$a1, $t5
	syscall
#3. Ham lay dia chi bien con tro
	la	$a0, CharPtr
	lw	$t8, 0($a0)
	la 	$a0, DiachiChar
	li 	$v0, 56
	move	$a1, $t8
	syscall
	
	la	$a0, BytePtr
	lw	$t8, 0($a0)
	la 	$a0, DiachiByte
	li 	$v0, 56
	move	$a1, $t8
	syscall
	
	la	$a0, WordPtr
	lw	$t8, 0($a0)
	la 	$a0, DiachiWord
	li 	$v0, 56
	move	$a1, $t8
	syscall
#5. Ham giai phong bo nho da cap phat
	la	$a0, Sys_MyFreeSpace
	la	$a1, Sys_TheTopOfFree
	lw	$a2, 0($a1)

	loop:
	sw	$0, 0($a2)
	beq	$a2, $a0, next
	subi	$a2, $a2, 4
	j	loop
	next:

	la	$a0, CharPtr
	sw	$zero, 0($a0)
	sw	$zero, 4($a0)
	sw	$zero, 8($a0)
	la	$a0, WordPtr
	lw	$t8, 0($a0)
	la 	$a0, DiachiWord
	li 	$v0, 56
	move	$a1, $t8
	syscall
	
#6. Ham tinh luong bo nho da cap phat
	la	$a0, Sys_MyFreeSpace
	la	$a1, Sys_TheTopOfFree
	lw	$a2, 0($a1)

	loop1:
	beq	$a2, $a0, next1
	addi	$s5, $s5, 4
	subi	$a2, $a2, 4
	j	loop1
	next1:
	la	$a0, Bonho_Capphat
	move	$a1, $s5
	li 	$v0, 56
	syscall

#7. Ham malloc2
	jal   SysInitMem
	la   $a0, ArrayPtr
	#ham nhap so dong i
	la	$a0, Nhaphangi
	li	$v0, 4
	syscall
	li	$v0, 5
	syscall
	move 	$a1, $v0	#so dong
	#Ham nhap so cot j
	la	$a0, Nhapcotj
	li	$v0, 4
	syscall
	li	$v0, 5
	syscall
	move 	$a2, $v0	#so cot
	addi	$a3, $zero, 4
	jal malloc2
	j	cau8
	malloc2:
	la   	$t9, Sys_TheTopOfFree   
	lw  	$t8, 0($t9)	#Lay dia chi dau tien con trong
	sw	$t8, 0($a0)	#Cat dia chi do vao bien con tro
	addi	$v0, $t8, 0	#Dong thoi laket qua tra ve cua ham
 	mul	$t7, $a1,$a2	#Tinh kich thuoc cua mang can cap phat
 	mul	$t5, $t7, $a3
 	add	$t6, $t8, $t5	#Tinh dia chi dau tien controng 
 	sw	$t6, 0($t9)	#Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree 
 	jr   $ra
#8. Ham get, set
cau8:
	#Ham set
	NhapDulieu1: 
	la  	$t8, Sys_MyFreeSpace
	la	$a0, NhapAij
	li	$v0, 4
	syscall
	#Nhap hang i
	la	$a0, Nhapi
	li	$v0, 4
	syscall
	laptimi:
	li 	$v0, 5
	syscall
	slt	$s4, $v0, $a1
	bne	$s4, $0, hetlaptimi
	j	laptimi
	hetlaptimi:
	move	$s1, $v0	#hang i luu vao s1

	#Nhap cot j
	la	$a0, Nhapj
	li	$v0, 4
	syscall
	laptimj:
	li 	$v0, 5
	syscall
	slt	$s4, $v0, $a2
	bne	$s4, $0, hetlaptimj
	j	laptimj
	hetlaptimj:
	move	$s2, $v0	#cot j luu vao s2
	
	la	$a0, Ketqua
	li	$v0, 4
	syscall
	li 	$v0, 5
	syscall
	mul	$s3, $s1, $a2
	add	$s3, $s3, $s2
	mul	$s3, $s3, $a3
	add	$t8, $t8, $s3
	sw	$v0, 0($t8)

	la	$a0, Tieptuc
	li	$v0, 50
	syscall
	beq	$a0, $0, NhapDulieu1
	j	XuatDulieu
	
	XuatDulieu: 	#ham get

	la	$a0, XuatAij
	li	$v0, 4
	syscall
	la  	$t8, Sys_MyFreeSpace
	#Nhap hang i
	la	$a0, Nhapi
	li	$v0, 4
	syscall
	laptimi1:
	li 	$v0, 5
	syscall
	slt	$s4, $v0, $a1
	bne	$s4, $0, hetlaptimi1
	j	laptimi1
	hetlaptimi1:
	move	$s1, $v0	#hang i luu vao s1

	#Nhap cot j
	la	$a0, Nhapj
	li	$v0, 4
	syscall
	laptimj1:
	li 	$v0, 5
	syscall
	slt	$s4, $v0, $a2
	bne	$s4, $0, hetlaptimj1
	j	laptimj1
	hetlaptimj1:
	move	$s2, $v0	#cot j luu vao s2
	
	la	$a0, Ketqua
	li	$v0, 4
	syscall
	mul	$s3, $s1, $a2
	add	$s3, $s3, $s2
	mul	$s3, $s3, $a3
	add	$t8, $t8, $s3
	lw	$a0, 0($t8)
	li	$v0, 1
	syscall
	la	$a0, Tieptuc
	li	$v0, 50
	syscall
	beq	$a0, $0, XuatDulieu
	j	exit
exit:
