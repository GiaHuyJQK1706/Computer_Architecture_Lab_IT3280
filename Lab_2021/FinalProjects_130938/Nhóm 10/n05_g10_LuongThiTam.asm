.data
bttrungto: .space 256
bthauto: .space 256
nganxep: .space 256
arr: .space 256

string: .asciiz "\n"
message1: .asciiz "Bieu thuc trung to: "
message2: .asciiz "Bieu thuc hau to: "
message3: .asciiz "Ket qua bieu thuc vua nhap: "
message4: .asciiz "Nhap vao bieu thuc trung to: "
message5: .asciiz "MENU\n1.Chay chuong trinh\n2.Thoat chuong trinh\nBan chon?\n "
message6: .asciiz "Bieu thuc khong hop le.\n"
.text
main:la $a0, message5
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	beq $v0, 2, end_main
	
	jal INPUT
	nop
	jal CHECK
	nop
	beq $v0, 0, next1
	nop
	
	jal OUTPUT1
	nop
	jal CONVERT
	nop
	jal OUTPUT2
	jal CALCULATE
	jal OUTPUT3
	j main	
	nop
next1:la $a0, message6
	li $v0, 4
	syscall
	
	j main
end_main:
	li $v0, 10
	syscall	

#Nhap bieu thuc trung to
INPUT:la $a0, message4
	li $v0, 4
	syscall
	
	li $v0, 8
	la $a0, bttrungto
	la $a1, 256
	syscall 
	
	jr $ra
	nop
#In bieu thuc trung to ra man hinh
OUTPUT1:la $a0, message1
	li $v0, 4
	syscall
	
	la $a0, bttrungto
	li $v0, 4
	syscall
	
	jr $ra
	nop
#In bieu thuc hau to ra man hinh
OUTPUT2: la $a0, message2
	li $v0, 4
	syscall
	
	la $a0, bthauto
	li $v0, 4
	syscall
	
	la $a0, string
	li $v0, 4
	syscall
	
	jr $ra
	nop
#In ket qua ra man hinh
OUTPUT3:la $a0, message3
	li $v0, 4
	syscall
	
	lb $a0, -1($s3)
	li $v0, 1
	syscall
	
	la $a0, string
	li $v0, 4
	syscall
	
	jr $ra
	nop
#Kiem tra tinh hop le cua bieu thuc vua nhap
CHECK:addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, bttrungto
	li $t1, 0
load:add $t2, $t1, $a0
	lb $t3, 0($t2)
	beq $t3, 10, end_check
	jal check_number
	beq $v0, 1, continue
	jal check_operator
	beq $v0, 1, continue
	jal check_space
	beq $v0, 1, continue
	j end_check

continue:
	addi $t1, $t1, 1
	j load
	
end_check:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	nop
#CONVERT	: chuyen bieu thuc trung to thanh bieu thuc hau to
CONVERT:addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $s1, bttrungto
	la $s2, bthauto
	la $s3, nganxep
	li $s6, 0
	li $s7, 0
	li $t7, -1
while1:add $s4, $s1, $s6
	lb $t3, 0($s4)
	beq $t3, 10, end_while1
	jal check_number
	beq $v0, 1, push_number
next3:beq $t3, 10, end_while1
	jal check_operator
	beq $v0, 1, check_before_push_operator
next2:addi $s6, $s6, 1
	j while1
push_number:add $s4, $s2, $s7
	sb $t3, 0($s4)
	addi $s7, $s7, 1
	addi $s6, $s6, 1
	add $s4, $s1, $s6
	lb $t3, 0($s4)
	jal check_number
	beq $v0, 1, push_number
	li $t2, ' '
	add $s4, $s2, $s7
	sb $t2, 0($s4)
	addi $s7, $s7, 1
	j next3
check_before_push_operator:beq $s0, 0, push_operator1
	beq $t7, -1, push_operator1
	addi $t1, $t3, 0
	addi $a0, $s0, 0
after_pop:beq $t7, -1, push_operator2
	add $s4, $t7, $s3
	lb $t3, 0($s4)
	jal check_operator
	ble $a0, $s0, pop_operator
	j push_operator2
pop_operator:beq $t3, '(', before_pop_operator
	add $s4, $s2, $s7
	sb $t3, 0($s4)
	addi $s7, $s7, 1
	li $t2, ' '
	add $s4, $s2, $s7
	sb $t2, 0($s4)
	addi $s7, $s7, 1
	addi $t7, $t7, -1
	j after_pop
before_pop_operator:addi $t7, $t7, -1
	j push_operator2
push_operator1:addi $t7, $t7, 1
	add $s4, $s3, $t7
	sb $t3, 0($s4)
	j next2
push_operator2:beq $t1, ')', after_pop2
	addi $t7, $t7, 1
	add $s4, $s3, $t7
	sb $t1, 0($s4)
	j next2
after_pop2:
	add $s4, $t7, $s3
	lb $t3, 0($s4)
	addi $t7, $t7, -1
	beq $t3, '(', push_operator3
	add $s4, $s2, $s7
	sb $t3, 0($s4)
	addi $s7, $s7, 1
	li $t2, ' '
	add $s4, $s2, $s7
	sb $t2, 0($s4)
	addi $s7, $s7, 1
	j after_pop2
push_operator3:
	j next2
end_while1:beq $t7, -1, rt3
	add $s4, $s3, $t7
	lb $t3, 0($s4)
	addi $t7, $t7, -1
	add $s4, $s2, $s7
	sb $t3, 0($s4)
	addi $s7, $s7, 1
	li $t2, ' '
	add $s4, $s2, $s7
	sb $t2, 0($s4)
	addi $s7, $s7, 1
	j end_while1
rt3:	li $t2, '\0'
	add $s4, $s2, $s7
	sb $t2, 0($s4)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	nop
	
#CACULATE
# $s2 : bieu thuc hau to
# $s3 : ngan xep 
CALCULATE:addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $s6, 0
	li $s7, -4
	la $t2, arr
while2:add $s4, $s2, $s6
	lb $t3, 0($s4)
	beq $t3, 0, end_while2
	jal check_number
	li $t9, -1
	li $s5, 0
	beq $v0, 1, before_convert_num
next4:beq $t3, 0, end_while2
	jal check_operator
	beq $v0, 1, ccl
next5:addi $s6, $s6, 1
	j while2
before_convert_num:add $s4, $t2, $s5
	sb $t3, 0($s4)
	addi $s5, $s5, 1
	addi $t9, $t9, 1
	addi $s6, $s6, 1
	add $s4, $s2, $s6
	lb $t3, 0($s4)
	jal check_number
	beq $v0, 1, before_convert_num
	jal convert_num
	j next4
ccl: addi	$s3, $s3, -2
	lb	$a0, ($s3)
	lb	$a1,	1($s3)
	jal CAL
	j next5
end_while2:
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
#Check xem co phai ki tu space khong?
# $v0 = 0 -> khong la space
# $v0 = 1 -> la space
check_space:
	bne $t3, ' ', check_space_false
check_space_true:
	li $v0, 1
	jr $ra
	nop
check_space_false:
	li $v0, 0
	jr $ra
	nop
#Check xem co phai toan tu khong?
# $v0 = 0 -> khong phai la toan tu
# $v0 = 1 -> la toan tu, $s0 luu tru thu tu uu tien cua toan tu
check_operator:
	addi	$sp, $sp, -28
	sw	$s2, 24($sp)
	sw	$s3, 20($sp)
	sw	$s4, 16($sp)
	sw	$s5, 12($sp)
	sw	$s6, 8($sp)
	sw	$s7, 4($sp)
	sw	$t8, ($sp)
	li $s2, '+'
     li $s3, '-'
     li $s4, '*'
     li $s5, '/'
     li $s6, '%'
     li $s7, '('
     li $t8, ')'
     beq $t3, $s2, operator1
     beq $t3, $s3, operator1
     beq $t3, $s4, operator2
     beq $t3, $s5, operator2
     beq $t3, $s6, operator2
     beq $t3, $s7, operator0
     beq $t3, $t8, operator3
     j check_operator_false
operator0:li $s0,0
	j check_operator_true
operator1:li $s0, 1
	j check_operator_true
operator2:li $s0, 2
	j check_operator_true
operator3:li $s0, 3
check_operator_true:
	li $v0, 1
	j rt1
	nop
check_operator_false:
	li $v0, 0
rt1:	lw	$s2, 24($sp)
	lw	$s3, 20($sp)
	lw	$s4, 16($sp)
	lw	$s5, 12($sp)
	lw	$s6, 8($sp)
	lw	$s7, 4($sp)
	lw	$t8, ($sp)
	addi	$sp, $sp, 28
	jr	$ra
	nop
#Check xem co phai so khong?
# $v0 = 0 -> khong la so
# $v0 = 1 -> la so
check_number:
	addi	$sp, $sp, -8
	sw	$t8, 4($sp)
	sw	$t9, ($sp)   
	li $t8, '0'
	li $t9, '9'
	
	beq $t8, $t3, check_number_true
	beq $t9, $t3, check_number_true
	bgt $t8, $t3, check_number_false
	bgt $t3, $t9, check_number_false
check_number_true:
	li $v0, 1
	j	rt2
check_number_false:
	li $v0, 0
rt2:
	lw	$t9, ($sp)
	lw	$t8, 4($sp)
	addi	$sp, $sp, 8
	jr	$ra
#Tinh gia tri bieu thuc
# $a0 : phan tu truoc
# $a1 : phan tu sau
# $t3 : op 
# $a0 op $a1
CAL:
add_op:	bne	$t3, '+', minus_op
	add	$v0, $a0, $a1
	j	rt_cal
minus_op:	bne	$t3, '-', mul_op
	sub	$v0, $a0, $a1
	j	rt_cal
mul_op:	bne	$t3, '*', div_op
	mult	$a0, $a1
	mflo	$v0
	j	rt_cal
div_op:	bne	$t3, '/', divr_op
	div	$a0, $a1
	mflo	$v0
	j	rt_cal
divr_op:	bne	$t3, '%',	rt_cal
	div	$a0, $a1
	mfhi	$v0
rt_cal:
	sb	$v0, ($s3)
	addi	$s3, $s3, 1
	jr	$ra
#Chuyen doi ky tu thanh so
# $t2 : luu ki tu
# $s3 : lu so tuong ung
# $t9 : bien dem cua mang luu ki tu
convert_num:
	addi	$sp, $sp, -8
	sw	$t1, ($sp)
	sw	$t5, 4($sp)
	bne	$t9, $0, twoNum
	lb	$t1, 0($t2)
	addi	$t1, $t1, -48
	j	push
twoNum:
	lb	$t1, 0($t2)
	addi	$t1, $t1, -48
	addi	$t5, $0, 10
	mult	$t1, $t5
	mflo	$t1
	lb	$t5, 1($t2)
	addi	$t5, $t5, -48
	add	$t1, $t1, $t5
push:sb $t1, 0($s3)
	addi $s3, $s3, 1
	lw	$t5, 4($sp)
	lw	$t1, ($sp)
	addi	$sp, $sp, 8
	j rt4
end_loop2:
end_loop1:
rt4:jr $ra
	nop
	
	
