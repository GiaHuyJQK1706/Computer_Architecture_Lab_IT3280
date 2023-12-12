.data
	#cau lenh mips gom opcode va 3 toan hang. 
	register: .asciiz "$zero-$at-$v0-$v1-$a0-$a1-$a2-$a3-$t0-$t1-$t2-$t3-$t4-$t5-$t6-$t7-$t8-$t9-$s1-$s2-$s3-$s4-$s5-$s6-$s7-$k0-$k1-$gp-$sp-$fp-$ra-$0-$1-$2-$3-$4-$5-$6-$7-$8-$9-$10-$11-$12-$13-$14-$15-$16-$17-$18-$19-$20-$21-$22-$23-$24-$25-$26-$27-$28-$29-$30-$31-"
	#ma opcode hop le:
	opcode: .asciiz "lw-lb-sw-sb-addi-add-addiu-addu-and-andi-beq-bne-div-divu-j-jal-lui-mfhi-mflo-mul-nop-nor-or-ori-sll-slt-slti-sub-subu-syscall-xor-xori-"
	#quy uoc toan hang: 1 - thanh ghi, 2 - so, 3 - Label, 4 - offset(base): number(register), 0 - null
	#toan hang tuong ung voi cac opcode tren:
	operand: .asciiz "140-140-140-140-112-111-112-111-111-112-113-113-110-110-300-300-120-100-100-111-000-111-111-112-112-111-112-111-111-000-111-112-"

	msg1: 	.asciiz	 "Nhap lenh can kiem tra: "
	msg2: 	.asciiz	 "\nopcode: "
	msg21:	.asciiz	 ": hop le!\n"
	msg22:	.asciiz	 ": khong hop le!\n"
	msg3:	.asciiz	 "\nToan hang: "
	msg4: 	.asciiz	 "\nCau lenh"
	msg5: 	.asciiz	 "\kiem tra them 1 lenh nua? 1(yes)|0(no): "
	input: 	.space 	 200 		# chuỗi đầu vào 
	tmp: 	.space	 20 		# biến tmp lưu các thành phần cắt được  
	tmp2: 	.space 	 20 		# lưu khuôn dạng code
	tmp3:	.space 	 20 		# thành phần cắt được offset(base)
.text
main:
Input: 					# lấy đầu vào 
	li	$v0, 4
	la	$a0, msg1
	syscall
	li	$v0, 8
	la	$a0, input 
	li	$a1, 200
	syscall
	
#-------------------------Tách chữ và so sánh----------------------- 

	la	$s0, input 		# Lưu địa chỉ input
	add	$s1, $zero, $zero 	# i -> đếm kí tự trong tmp
readOpcode: 
	add	$a0, $s0, $zero 	# a0 -> &input 
	add	$a1, $s1, $zero 	# a1 = i 
	la	$a2, tmp
	jal	cutComponent
	add	$s1, $v0, $zero 	# i 
	add	$s7, $v1, $zero 	# j - số kí tự trong opcode
checkOpcode:	
	la	$a0, tmp		# a0 -> tmp
	add	$a1, $s7, $zero		# a1 = j
	la	$a2, opcode		# a2 -> opcode
	jal 	compareOpcode
	add	$s2, $v0, $zero 	# s2 = check 
	add	$s3, $v1, $zero 	# s3 = vị trí opcode 
	li	$v0, 4
	la	$a0, msg2
	syscall
	li	$v0, 4
	la	$a0, tmp
	syscall
	bne	$s2, $zero, validOpcode 	# if (check != 0) validOpcode    //check == 1
						# else invalidOpcode
invalidOpcode: 					# opcode không hợp lệ 
	li	$v0, 4
	la	$a0, msg22
	syscall
	j	exit
validOpcode:					# opcode hợp lệ 
	li	$v0, 4
	la	$a0, msg21
	syscall
	
#----------------- Lấy khuôn dạng tương ứng với opcode -------------------

	la	$a0, operand
	add	$a1, $s3, $zero 		# a1 = vị trí của opcode 
	jal	getOperand 			# Trả về tmp2(khuôn dạng code)
	
	li	$v0, 4
	la	$a0, tmp2
	syscall
	
	la	$s4, tmp2			# khuon dang
	add	$s5, $zero, $zero 	 	# toan hang 1 2 3  - dem
	add	$t9, $zero, 48 			#0
	addi	$t8, $zero, 49 			#1
	addi	$t7, $zero, 50 			#2
	addi	$t6, $zero, 51 			#3
	addi	$t5, $zero, 52 			#4
Cmp: 
# -------------------Kiểm tra dạng của từng toán hạng và check---------------
	slti	$t0, $s5, 3
	beq	$t0, $zero, end			# if (s5 >= 3) end
#------------------- lấy toán hạng ---------------------
	add	$a0, $s0, $zero
	add	$a1, $s1, $zero
	la	$a2, tmp
	jal	cutComponent
	add	$s1, $v0, $zero
	add	$s7, $v1, $zero 		# số kí tự trong tmp 
#------------------ so sánh toán hạng ------------------
	add	$t0, $s5, $s4
	lb	$s6, 0($t0) 			# dạng của toán hạng i 
	beq	$s6, $t8, reg
	beq	$s6, $t7, number
	beq	$s6, $t6, label
	beq	$s6, $t5, offsetbase
	beq	$s6, $t9, null
reg:
	la	$a0, tmp
	add	$a1, $s7, $zero
	la	$a2, register
#	return  0 -> error 
#		1 -> ok
	jal	compareOpcode
	j	checkValid
number:
	la	$a0, tmp
	add	$a1, $s7, $zero
	jal 	checkNumber
	j	checkValid
label:
	la	$a0, tmp
	add	$a1, $s7, $zero
	jal	checkLabel
	j	checkValid
offsetbase:
	la	$a0, tmp
	add	$a1, $s7, $zero
	jal	checkOffsetBase
	j 	checkValid
null:
	j	print	
checkValid:
	add	$s2, $v0, $zero
	li	$v0, 4
	la	$a0, msg3
	syscall
	li	$v0, 4
	la	$a0, tmp
	syscall
	beq	$s2, $zero, error		# if (check == 0) error
	j	ok				# else ok
updateCheck:					
	addi	$s5, $s5, 1
	j	Cmp				# Quay lại check Cmp 

error:
	li	$v0, 4
	la	$a0, msg22
	syscall
	j	exit
ok:
	li	$v0, 4
	la	$a0, msg21
	syscall
	j	updateCheck
end:
	add	$a0, $s0, $zero
	add	$a1, $s1, $zero
	jal	cutComponent
	add	$s1, $v0, $zero 		# i hiện tại 
	add	$s7, $v1, $zero 		# s7 = strlen(tmp)
print:	
	li	$v0, 4
	la	$a0, msg4
	syscall
	bne	$s7, $zero, error			
	li	$v0, 4
	la	$a0, msg21
	syscall
exit:
repeatMain:
	li	$v0, 4
	la	$a0, msg5
	syscall
	li	$v0, 8
	la	$a0, input
	li	$a1, 100
	syscall
	checkRepeat:
		addi	$t2, $zero, 48			# t2 = '0'	
		addi	$t3, $zero, 49			# t3 = '1'
		add	$t0, $a0, $zero 		# t0 = &input
		lb	$t0, 0($t0)			# t0 = input[0]
		beq	$t0, $t2, out			# if (t0 == '0') out
		beq	$t0, $t3, main			# if (t0 == '1') main
		j	repeatMain 			# else repeatMain
out:
	li $v0, 10 					#exit
	syscall
#--------------------------------------------------------	
# tách toán hạng, opcode từ chuỗi đầu vào 
# a0 address input, a1 = i (chỉ số mảng input). a2 address tmp
# v0 = i, v1 strlen(tmp)
#--------------------------------------------------------
cutComponent:
	addi	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s0, 12($sp) 			# space
	sw	$s2, 8($sp)			# j
	sw	$s3, 4($sp) 			# input[i]
	sw	$s4, 0($sp) 			# dấu phảy = 44
	
	addi	$s0, $zero, 32 			# space
	addi	$t2, $zero, 10 			# \n
	addi	$s4, $zero, 44 			# dấu phảy = 44
	addi	$t3, $zero, 9 			# \t
	
#------ Bỏ qua dấu space và tab ------#
checkSpace: 
	add	$t0, $a0, $a1 			# &input[i]
	lb	$s3, 0($t0) 			# value input[i]
	beq	$s3, $s0, cutSpace 		# if (input[i] == ' ')cutSpace
	beq	$s3, $t3, cutSpace		# if (input[i] == '\t')cutSpace
	beq	$s3, $s4, cutSpace 		# if (input[i] == ',')cutSpace
	j	cut			
cutSpace:
	addi	$a1, $a1, 1			# i++
	j	checkSpace			# Quay lại checkSpace
cut:
	add	$s2, $zero, $zero 		# j = 0
loopCut:
	beq	$s3, $zero, endCut		# if (input[i] == '\0') endCut
	beq	$s3, $t2, endCut		# if (input[i] == '\n')endCut
	beq	$s3, $s0, endCut 		# if (input[i] == ' ')endCut
	beq	$s3, $t3, endCut		# if (input[i] == '\t')endCut
	beq	$s3, $s4, endCut 		# if (input[i] == ',')endCut
	
	add	$t0, $a2, $s2 			# &tmp[j]
	sb	$s3, 0($t0) 			# tmp[j] = input[i]
	addi	$a1, $a1, 1			# i++
	add	$t0, $a0, $a1 			# &input[i]
	lb	$s3, 0($t0) 			# value input[i]
	
	addi	$s2, $s2, 1			# j++
	j	loopCut
endCut:
	add	$t0, $a2, $s2 			# &tmp[j]
	sb	$zero, 0($t0) 			# tmp[j] = '\0'
	add	$v0, $a1, $zero			# return i 
	add	$v1, $s2, $zero			# return j 
	
	lw	$ra, 16($sp)
	lw	$s0, 12($sp)
	lw	$s2, 8($sp)
	lw	$s3, 4($sp)
	lw	$s4, 0($sp)
	addi	$sp, $sp, 20
	
	jr	$ra
	
#--------------------------------------------------------
# so sánh toán hạng, opcode với toán hạng, opcode chuẩn 
# a0 = &tmp, a1 = strlen(tmp), a2  = opcode, register chuẩn 
# boolean v0 = 0 or 1 (check), v1 vị trí opcode
#--------------------------------------------------------
compareOpcode:
	addi	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s1, 16($sp) 			# i -> opcode
	sw	$s2, 12($sp) 			# j -> tmp
	sw	$s3, 8($sp) 			# value tmp[j]
	sw	$s4, 4($sp)			# value opcode[i]
	sw	$s5, 0($sp) 			# '-'
	
	beq	$a1, $zero, endCmp		# if (a1 == 0) endCmp

	add	$s1, $zero, $zero		# s1 = i (chỉ số của chuỗi opcode) 
	add	$s2, $zero, $zero		# s2 = j (chỉ số của chuỗi tmp)
	addi	$s5, $zero, 45			# s5 = '-'
	addi	$v0, $zero, 1			# v0 = 1
	addi	$v1, $zero, 0			# v1 = 0
loopCmp:
	add	$t0, $a2, $s1 			# &opcode[i]
	lb	$s4, 0($t0) 			# value opcode[i]
	beq	$s4, $s5, checkCmp		# if (opcode[i] == '-') checkCmp
	beq	$s4, $zero, endCmp		# if (opcode[i] == '0') endCmp
	add	$t0, $a0, $s2 			# &tmp[j]    
	lb	$s3, 0($t0) 			# value tmp[j]
	bne	$s3, $s4, falseCmp		# if (tmp[j] != opcode[i]) falseCmp
	
	addi	$s1, $s1, 1			# i++
	addi	$s2, $s2, 1			# j++
	j	loopCmp
checkCmp:
	bne	$a1, $s2, falseCmp		# if (strlen(tmp) != j) falseCmp
trueCmp:
	addi	$v0, $zero, 1			# check = 1 (tìm thấy opcode)
	j	endFunc  
	
#-------------------------------------------------
falseCmp:
#--- if (strlen(tmp) != j ){
#---	j == 0;
#---	check = 0;
#---	-> bỏ qua opcode   
#--- }
	addi	$v0, $zero, 0			# check = 0
	addi	$s2, $zero, 0			# j = 0
loopXspace:
	beq	$s4, $s5, Xspace		# if (opcode[i] == '-') Xspace
	addi	$s1, $s1, 1			# i++
	add	$t0, $a2, $s1 			# &opcode[i]
	lb	$s4, 0($t0) 			# value opcode[i]
	j	loopXspace
Xspace:
	add	$v1, $v1, 1			# v1 = v1+1
	addi	$s1, $s1, 1			# i++
	j	loopCmp
#--------------------------------------------------
endCmp:
	addi	$v0, $zero, 0
endFunc:	
	lw	$ra, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp) 
	lw	$s4, 4($sp)	
	lw	$s5, 0($sp)
	addi	$sp, $sp, 24
	jr	$ra
#--------------------------------------------------------
# Lấy khuôn dạng tương ứng với Opcode 
# a0 = &operand - a1 = vị trí Opcode 
# return tmp2 (trả về khuôn dạng code tương ứng)
#--------------------------------------------------------
getOperand: 
	addi	$sp, $sp, -20
	sw	$s0, 16($sp) 			# i
	sw	$s1, 12($sp) 			# op[i]
	sw	$s2, 8($sp) 			# 45
	sw	$s3, 4($sp) 			# &tmp2
	sw	$s4, 0($sp)			# j

	addi	$t0, $zero, 4 			# mỗi khuôn chiếm 4 byte 
	mul	$s0, $a1, $t0 			# i = count*4
	addi	$s2, $zero, 45 			# '-'
	la	$s3, tmp2			# s3 = &tmp 
	add	$s4, $zero, $zero 		# j
loopGet:	
	add	$t0, $a0, $s0 			# $operand[i]
	lb	$s1, 0($t0)			# value of $operand[i]
	beq	$s1, $s2, endGet		# if (operand[i] == '-') endGet
	add	$t0, $s3, $s4 			# &tmp[i]
	sb	$s1, 0($t0)
	
	addi	$s0, $s0, 1			# i++
	addi	$s4, $s4, 1			# j++
	j	loopGet
endGet:
	add	$t0, $s3, $s4 			# &tmp[i]
	sb	$zero, 0($t0)
	
	lw	$s0, 16($sp) 
	lw	$s1, 12($sp) 
	lw	$s2, 8($sp) 
	lw	$s3, 4($sp)
	lw	$s4, 0($sp)
	addi	$sp, $sp, 20
	
	jr $ra
#--------------------------------------------------------
# Kiểm tra chuỗi tmp có là số hay không 
# a0 = &tmp, a1 = strlen(tmp)
# Nếu là số return 1, ngược lại return 0
#--------------------------------------------------------
checkNumber:
	add	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp) 			# '+'
	sw	$s3, 12($sp) 			# '-'
	sw	$s0, 8($sp)
	sw	$s1, 4($sp)
	sw	$s2, 0($sp) 			# 
	add	$v0, $zero, 0
	add	$s0, $zero, $zero 		#s0 = i
	
	beq	$a1, $zero, endCheckN		# return v0 = 0
checkFirstN:
	addi 	$s3, $zero, 45 			# s3 = '-'
	addi	$s4, $zero, 43 			# s4 = '+'
	addi	$s2, $zero, 1			# s2 = 1
	add	$t0, $a0, $s0 			# &tmp[i]
	lb	$s1, 0($t0)			# value of tmp[i]
	#check - +  -> 123
checkMinus: 
	bne	$s1, $s3, checkPlus		# if (tmp[i] != '-') checkPlus
	beq	$a1, $s2, endCheckN		# if (strlen(tmp) == 1) endCheckN
	# if (tmp[i] == '-') 
	j	update
checkPlus:
	bne	$s1, $s4, _123			# if (tmp[i] != '+') _123
	beq	$a1, $s2, endCheckN
	j	update
	
checkI:
	beq 	$s0, $a1, trueN			# if (i == strlen(tmp)) trueN
	add	$t0, $a0, $s0 			# t0 = $tmp[i]
	lb	$s1, 0($t0)			# s1 = tmp[i]
_123: #48 -> 57
	slti	$t0, $s1, 48			# if (s1 < 48) return 0 
	bne	$t0, $zero, endCheckN
	slti	$t0, $s1, 58			# if (s1 >= 58) return 0
	beq	$t0, $zero, endCheckN
update:
	addi	$s0, $s0, 1			# i++
	j	checkI
trueN:
	addi	$v0, $v0, 1
endCheckN:
	lw	$ra, 20($sp)
	lw	$s4, 16($sp) 			
	lw	$s3, 12($sp) 			
	lw	$s0, 8($sp)
	lw	$s1, 4($sp)
	lw	$s2, 0($sp)
	add	$sp, $sp, 24
	jr	$ra
#--------------------------------------------------------
# Kiểm tra chuỗi tmp có là Label hay không, kí tự đầu tiên: _ | A -> _ | A | 1 
# a0 =  &tmp, a1 = strlen(tmp)
# v0 0|1 
#--------------------------------------------------------
checkLabel:
	add	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	add	$v0, $zero, 0
	add	$s0, $zero, $zero 		# s0 = i
	
	beq	$a1, $zero, endCheckL		# if (strlen(tmp) == 0) endCheckL

checkFirstChar:
	add	$t0, $a0, $s0 			# t0 -> &tmp[i]
	lb	$s1, 0($t0)			# s1 = tmp[i]
	j	ABC	

checkIL:
	slt	$t0, $s0, $a1			# if (i == strlen(tmp)) trueL
	beq	$t0, $zero, trueL
	add	$t0, $a0, $s0 			# else { t0 = &tmp[i]; s1 = tmp[i]
	lb	$s1, 0($t0)			# }
_123L: #48 -> 57
	slti	$t0, $s1, 48
	bne	$t0, $zero, endCheckL
	slti	$t0, $s1, 58
	beq	$t0, $zero, ABC
	addi	$s0, $s0, 1
	j	checkIL
ABC: #65 -> 90
	slti	$t0, $s1, 65			# if (tmp[i] < 65) endCheckL
	bne	$t0, $zero, endCheckL
	slti	$t0, $s1, 91			# if (tmp[i] >= 91) _
	beq	$t0, $zero, _
	addi	$s0, $s0, 1			# i++
	j	checkIL
_:
	add	$t0, $zero, 95
	bne	$s1, $t0, abc			# if (tmp[i] != '_') abc
	addi	$s0, $s0, 1			# i++
	j	checkIL
abc: #97  -> 122
	slti	$t0, $s1, 97			# if (tmp[i] < 97) endCheckL
	bne	$t0, $zero, endCheckL
	slti	$t0, $s1, 123			# if (tmp[i] >= 123) endCheckL
	beq	$t0, $zero, endCheckL
	addi	$s0, $s0, 1			# i++
	j	checkIL
trueL:
	addi	$v0, $v0, 1			#  check = 1
endCheckL:					# return
	sw	$ra, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	add	$sp, $sp, 12
	jr	$ra
#--------------------------------------------------------
# Kiểm tra chuỗi tmp có đúng cấu trúc offset base hay không 
# a0 =  &tmp, a1 = strlen(tmp)
# v0 0|1 
#--------------------------------------------------------
checkOffsetBase: 
#0($s1) -> 0 $s1 	
	add	$sp, $sp, -28
	sw	$ra, 24($sp)
	sw	$s5, 20($sp) 			# độ dài xâu tmp 
	sw	$s4, 16($sp) 			# ')'
	sw	$s3, 12($sp) 			# '('
	sw	$s2, 8($sp) 			# check
	sw	$s1, 4($sp)			# tmp[i]
	sw	$s0, 0($sp) 			# s0 = i 
checkO:
	slti	$t0, $a1, 5 			# có ít nhất 5 kí tự, vd: 0($s1)
	bne	$t0, $zero, falseCheck		# if (a1 < 5)falseCheck 
	addi	$s3, $zero, 40			# s3 = '('
	addi	$s4, $zero, 41			# s4 = ')'
	add	$s0, $zero, $zero 		# i = 0
	add	$s2, $zero, $zero 		# boolean: check
	addi	$t2, $zero, 1			# t2 = 1
loopCheck:
	add	$t0, $a0, $s0 			# t0 = &tmp[i]
	lb	$s1, 0($t0)			# s1 = tmp[i]
	beq	$s1, $zero, endLoopO		# if (tmp[i] == 0)endLoop0
	beq	$s1, $s3, open_			# if (tmp[i] == '(' ) open_
	beq	$s1, $s4, close_		# if (tmp[i] == ')' ) close_
	j	updateO
open_:
	bne	$s2, $zero, falseCheck		# if (check == 1) falseCheck
	addi	$s2, $s2, 1			# else  check = 1;
	addi	$t1, $zero, 32			# 	t1 = ' '
	sb	$t1, 0($t0)			# 	tmp[i] = ' '
	j	updateO
close_:
	bne	$s2, $t2, falseCheck		# if (check == 0) falseCheck
	addi	$s2, $s2, 1			# else  check += 1;
	sb	$zero, 0($t0)			# 	tmp[i] == 0;
	
	addi	$s0, $s0, 1			# 	i++;
	bne	$s0, $a1, falseCheck		#	if (i != strlen(tmp)) falseCheck
	
updateO:
	addi	$s0, $s0, 1			# i++
	j	loopCheck
endLoopO:
	addi	$t2, $t2, 1 			# t2 = 2
	bne	$s2, $t2, falseCheck		# if(check != t2)falseCheck
#----
trueCheck:
	add	$s0, $zero, $zero 		# i
# -------------- cut component -----------------
	addi 	$sp, $sp, -8
	sw	$a0, 4($sp)
	sw	$a1, 0($sp)
	
	la	$a0, tmp			# a0 -> tmp
	add	$a1, $s0, $zero			# a1 = 0
	la	$a2, tmp3			# 
	jal	cutComponent
	add	$s0, $v0, $zero
	add	$s5, $v1, $zero 		# strlen(tmp3)
	
	lw	$a0, 4($sp)
	lw	$a1, 0($sp)
	addi 	$sp, $sp, 8
	
# -------------- check number -----------------
	addi 	$sp, $sp, -8
	sw	$a0, 4($sp)
	sw	$a1, 0($sp)
	la	$a0, tmp3
	add	$a1, $s5, $zero
	jal 	checkNumber
	add	$s2, $v0, $zero
	lw	$a0, 4($sp)
	lw	$a1, 0($sp)
	addi 	$sp, $sp, 8
	
	beq	$s2, $zero, falseCheck
# -------------- cutComponent ----------------
	addi 	$sp, $sp, -8
	sw	$a0, 4($sp)
	sw	$a1, 0($sp)
	
	la	$a0, tmp
	add	$a1, $s0, $zero
	la	$a2, tmp3
	jal	cutComponent
	add	$s0, $v0, $zero
	add	$s5, $v1, $zero #so ky tu co trong cutword
	
	lw	$a0, 4($sp)
	lw	$a1, 0($sp)
	addi 	$sp, $sp, 8
# -------------- checkReg ------------------------
	addi 	$sp, $sp, -12
	sw	$a0, 8($sp)
	sw	$a1, 4($sp)
	sw	$a2, 0($sp)
	
	la	$a0, tmp3
	add	$a1, $s5, $zero
	la	$a2, register
	#tra ve 0 -> error, 1 -> ok
	jal	compareOpcode
	add	$s2, $v0, $zero
	
	lw	$a0, 8($sp)
	lw	$a1, 4($sp)
	lw	$a2, 0($sp)
	addi 	$sp, $sp, 12
	
	beq	$s2, $zero, falseCheck
	#->ket luan
	addi	$v0, $zero, 1
	j	endO
falseCheck:
	add	$v0, $zero, $zero		 	# v0 = 0;
	j	endO
endO:
	lw	$ra, 24($sp)
	lw	$s5, 20($sp) 
	lw	$s4, 16($sp) 
	lw	$s3, 12($sp) 
	lw	$s2, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp) 
	add	$sp, $sp, 28
	jr	$ra
