.eqv MONITOR_SCREEN 0x10000000 #Dia chi bat dau cua bo nho man hinh
.eqv RED 0x00ed1c23 			#Cac gia tri mau thuong su dung
.eqv GREEN 0x0000FF00
.eqv BLUE 0x0000b7ef
.eqv WHITE 0x00FFFFFF
.eqv YELLOW 0x00FFF200
.eqv PINK 0x00ffa3f3
.eqv PCBLUE 0x00546d8e
.eqv GRAY 0x00f0dde8
.eqv BLACK 0x00000000 
.eqv DTt 0x00100c26
.eqv DT 0x006f3198
.data
Menu: .asciiz "Bang chon mau: 0. Black 1. PC blue 2. RED 3. YELLOW 4. WHITE 5. PINK 6. BLUE 7. GRAY 8. Thoat\n"
M0: .asciiz "Nhap so mau: "
M1: .asciiz "Nhap du lieu: "
M2: .space 100000000


.text
start:
 	li 	$k1, MONITOR_SCREEN #Nap dia chi bat dau cua man hinh
 	li 	$t8, 64
 	li 	$t9, 64
 	li 	$s0, 0		# i ngang
 	li 	$s1, 0		# j doc
 	
nen:
 	sll 	$s2, $s0, 8
 	sll 	$s3, $s1, 2
 	add 	$k0, $k1, $s2
 	add 	$k0, $k0, $s3
 	li 	$t4, DT   
 	sw 	$t4, 0($k0)
 	addi 	$s1, $s1, 1
 	beq 	$s1, 64, dong
 	j 	nen
 	
 dong:
 	addi 	$s0, $s0, 1
 	li 	$s1, 0
 	beq 	$s0, 64, main
 	j 	nen
 	
start2:
 	li 	$k1, MONITOR_SCREEN #Nap dia chi bat dau cua man hinh
 	li 	$t8, 64
 	li 	$t9, 64
 	li 	$s0, 0		# i ngang
 	li 	$s1, 0		# j doc
 
main:
	li 	$v0, 4 
	la 	$a0, Menu
	syscall
	li 	$v0, 4
	la	$a0, M0
	syscall
	li 	$v0, 5
 	syscall
 	move $s2, $v0
 	beq 	$s2, 8, end
	
print_hang:
 	li 	$v0, 4
 	la 	$a0, M1
 	syscall
 	la 	$a0, M2 
 	li 	$v0, 8 
 	li 	$a1, 1000000
 	syscall
 	move $k0, $a0
 	li 	$s0, 0

next_i:
	
	add 	$t0, $k0, $s0			# $t0 tro toi dia chi xau A[i]
	lb 	$t1, 0($t0)				# Lay ky tu thu nhat trong mang chi hang chuc cua so thu tu hang
	lb 	$t2, 1($t0)				# Lay ky tu thu hai trong mang chi hang don vi cua so thu tu hang
	addi 	$t1, $t1, -48			# Lay gia tri hang chuc cua so thu tu hang ($t1 luc dau la gia tri ma ASCII)
	addi 	$t2, $t2, -48			# Lay gia tri hang don vi cua so thu tu hang ($t1 luc dau la gia tri ma ASCII)
	mul 	$s3, $t1, 10			# Nhan chu so hang chuc voi 10
	add 	$s6, $s3, $t2			# $s6 = so thu tu hang duoc nhap vao
	addi 	$s6, $s6, -1 			# i hang ngang
	addi 	$s0, $s0, 3				# Lay so tiep theo (thu hai) trong moi hang 
	sll 	$s6, $s6, 8				# Nhan voi 256 de lay dia chi hang tiep theo vi moi hang co 64 don vi anh
	
make2:	
	add 	$t0, $k0, $s0			# $t0 tro toi dia chi xau A[i]
	lb 	$t1, 0($t0)
	lb 	$t2, 1($t0)
	lb 	$t5, -1($t0)
	beqz $t1, start2 
	beq 	$t5, 10, next_i
	addi 	$t1, $t1, -48
	addi 	$t2, $t2, -48
	mul 	$s3, $t1, 10
	add 	$s7, $s3, $t2			# j cot doc
	addi 	$s7, $s7, -1 
	sll 	$s7, $s7, 2
	add 	$a3, $k1, $s6 
	add 	$a3, $a3, $s7
	jal 	color
	nop
	addi 	$s0, $s0, 3
	j 	make2
	
color:
	beqz $s2, BLACK1
	addi 	$t3, $s2, -1
	beqz $t3, PCBLUE1
	addi 	$t3, $t3, -1
	beqz $t3, RED1
	addi 	$t3, $t3, -1
	beqz $t3, YELLOW1
	addi 	$t3, $t3, -1
	beqz $t3, WHITE1
	addi 	$t3, $t3, -1
	beqz $t3, PINK1
	addi 	$t3, $t3, -1
	beqz $t3, BLUE1
	addi 	$t3, $t3, -1
	beqz $t3, GRAY1
	j main
	
	
BLACK1: 
	li 	$t4, BLACK
 	sw 	$t4, 0($a3)
 	jr 	$ra
PCBLUE1: 
	li 	$t4, PCBLUE
 	sw 	$t4, 0($a3)
 	jr 	$ra
RED1: 
	li 	$t4, RED
 	sw 	$t4, 0($a3)
 	jr 	$ra
YELLOW1: 
	li 	$t4, YELLOW
 	sw 	$t4, 0($a3)
 	jr 	$ra
WHITE1: 
	li 	$t4, WHITE
 	sw 	$t4, 0($a3)
 	jr 	$ra
PINK1: 
	li 	$t4, PINK
 	sw 	$t4, 0($a3)
 	jr 	$ra
BLUE1: 
	li 	$t4, BLUE
 	sw 	$t4, 0($a3)
 	jr 	$ra
GRAY1: 
	li 	$t4, GRAY
 	sw 	$t4, 0($a3)
 	jr 	$ra
 	
 	
 

	
end :
	li 	$v0, 10
	syscall
	

 
 
 
 
