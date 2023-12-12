#project 5: Chuong trinh nhap vao mot bieu thuc trung to, in ra bieu thuc hau to va gia tri bieu thuc
#-------------------------------------------------------------------------------
.data
	infix: .space 256
	postfix: .space 256
	operator: .space 256
	stack: .space 256
	endMsg: .asciiz "continue??"
	errorMsg: .asciiz "input not correct"
	startMsg: .asciiz "please enter infix\nNote: contain + - * / % ()\nnumber from 00-99"
	prompt_postfix: .asciiz "postfix expression: "
	prompt_result: .asciiz "result: "
	prompt_infix: .asciiz "infix expression: "
.text
start:
# nhap vao bieu thuc trung to
	li $v0, 54
	la $a0, startMsg
	la $a1, infix
 	la $a2, 256
 	syscall
 	beq $a1,-2,end			# if cancel then end 
 	beq $a1,-3,start		# if enter then start
# in bieu thuc trung to  
	li $v0, 4
	la $a0, prompt_infix
	syscall
	li $v0, 4
	la $a0, infix
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
# khoi tao cac trang thai
	li $s7,0					# bien trang thai $s7 
					
								# trang thai "1" khi nhan vao so (0 -> 99)
								# trang thai "2" khi nhan vao toan tu * / + - %
								# trang thai "3" khi nhan vao dau "("
								# trang thai "4" khi nhan vao dau ")"
	li $t9,0					# dem so chu so?
	li $t5,-1					# luu dinh cua offset postfix
	li $t6,-1					# luu dinh cua offset toan tu
	la $t1, infix				# load cac dia chi cua cac offset
	la $t2, postfix
	la $t3, operator	
	addi $t1,$t1,-1				# Set dia chi khoi tao infix la -1
# chuyen sang postfix
scanInfix: 						# For each moi ki tu trong postfix
# kiem tra dau vao
	addi $t1, $t1, 1				# tang vi tri con tro infix len 1 don vi i = i + 1 
	lb $t4, 0($t1)					# lay gia tri cua con tro infix hien tai
	beq $t4, ' ', scanInfix			# neu la space tiep tuc scan
	beq $t4, '\n', EOF				# Scan ket thuc pop tat ca cac toan tu sang postfix
	beq $t9, 0, digit1				# Neu trang thai la 0 => co 1 chu so
	beq $t9, 1, digit2				# Neu trang thai la 1 => co 2 chu so
	beq $t9, 2, digit3				# neu trang thai la 2 => co 3 chu so
	continueScan:
	beq $t4, '+', plusMinus			# kiem tra ki tu hien tai $t4
	beq $t4, '-', plusMinus
	beq $t4, '*', multiplyDivideModulo
	beq $t4, '/', multiplyDivideModulo
	beq $t4, '%', multiplyDivideModulo
	beq $t4, '(', openBracket
	beq $t4, ')', closeBracket
wrongInput:							# dau vao loi
	li $v0, 55
 	la $a0, errorMsg
 	li $a1, 2
 	syscall
 	j ask
finishScan:
# in bieu thuc infix
	# Print prompt:
	li $v0, 4
	la $a0, prompt_postfix
	syscall
	li $t6,-1						# set gia tri infix hien tai la $s6= -1
printPostfix:
	addi $t6,$t6,1					# tang offset cua postfix hien tai 
	add $t8,$t2,$t6					# load dia chi cua postfix hien tai
	lbu $t7,($t8)					# Load gia tri cua postfix hien tai
	bgt $t6,$t5,finishPrint			# in ra postfix xong roi tïnh ket qua
	bgt $t7,99,printOperator		# neu postfix hien tai > 99 --> la mot toan tu
	# Neu khong thi la mot toan hang
	li $v0, 1
	add $a0,$t7,$zero
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	j printPostfix				# Loop
	printOperator:
	li $v0, 11
	addi $t7,$t7,-100			# Decode toan tu
	add $a0,$t7,$zero
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	j printPostfix				# Loop
finishPrint:
	li $v0, 11
	li $a0, '\n'
	syscall
# tïnh toan ket qua
	li $t9,-4					# set offset cua dinh stack la -4
	la $t3,stack				# Load dia chi dinh stack 
	li $t6,-1					# Dat offset cua Postfix hien tai la -1
CalculatorPost:	
	addi $t6,$t6,1				# tang offset hien tai cua Postfix  
	add $t8,$t2,$t6				# Load dia chi cua postfix hien tai
	lbu $t7,($t8)				# Load gia tri cua postfix hien tai
	bgt $t6,$t5,printResult			# tïnh toan ket qua va in ra
	bgt $t7,99,calculate			# neu gia tri postfix hien tai > 99 --> toan tu --> lay ra 2 toan hang va tïnh toan
	# neu khong thi la toan hang
	addi $t9,$t9,4				# tang offset dinh stack len 
	add $t4,$t3,$t9				# tang dia chi cua dinh stack
	sw $t7, ($t4)				# day so vao stack
	j CalculatorPost				# Loop
	calculate:	
		# Pop 1 so
		add $t4,$t3,$t9		
		lw $t0,($t4)
		# pop so tiep theo
		addi $t9,$t9,-4
		add $t4,$t3,$t9		
		lw $t1,($t4)
		# Decode toan tu
		beq $t7,143,plus
		beq $t7,145,minus
		beq $t7,142,multiply
		beq $t7,147,divide
		beq $t7, 137, modulo
		plus:
			add $t0,$t0,$t1		# tinh tong gia tri cua 2 con tro dang luu gia tri toan hang
			sw $t0,($t4)		# luu gia tri cua con tro ra $t4
#			li $t0, 0			# Reset t0, t1
#			li $t1, 0	
			j CalculatorPost
		minus:
			sub $t0, $t1,$t0
			sw $t0,($t4)	
#			li $t0, 0			# Reset t0, t1
#			li $t1, 0	
			j CalculatorPost
		multiply:
			mul $t0, $t1,$t0
			sw $t0,($t4)	
#			li $t0, 0			# Reset t0, t1
#			li $t1, 0	
			j CalculatorPost
		divide:
			div $t1, $t0
			mflo $t0
			sw $t0,($t4)	
#			li $t0, 0			# Reset t0, t1
#			li $t1, 0	
			j CalculatorPost
		modulo:
			div $t1, $t0
			mfhi $t0
			sw $t0,($t4)	
#			li $t0, 0			# Reset t0, t1
#			li $t1, 0	
			j CalculatorPost
printResult:	
	li $v0, 4
	la $a0, prompt_result
	syscall
	li $v0, 1
	lw $a0,($t4)				# load gia tri cua $t4 ra con tro $t0
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
ask: 						# tiep tuc khong??
 	li $v0, 50
 	la $a0, endMsg
 	syscall
 	beq $a0,0,start
 	beq $a0,2,ask
# End program
end:
 	li $v0, 10
 	syscall
 
# Sub program
EOF:
	beq $s7,2,wrongInput			# ket thuc khi gap toan tu hoac dau ngoac mo
	beq $s7,3,wrongInput
	beq $t5,-1,wrongInput			# -1 thi khong co dau vao
	j popAllOperatorInStack
digit1:
	beq $t4,'0',storeDigit1
	beq $t4,'1',storeDigit1
	beq $t4,'2',storeDigit1
	beq $t4,'3',storeDigit1
	beq $t4,'4',storeDigit1
	beq $t4,'5',storeDigit1
	beq $t4,'6',storeDigit1
	beq $t4,'7',storeDigit1
	beq $t4,'8',storeDigit1
	beq $t4,'9',storeDigit1
	j continueScan
	
digit2: 
	beq $t4,'0',storeDigit2
	beq $t4,'1',storeDigit2
	beq $t4,'2',storeDigit2
	beq $t4,'3',storeDigit2
	beq $t4,'4',storeDigit2
	beq $t4,'5',storeDigit2
	beq $t4,'6',storeDigit2
	beq $t4,'7',storeDigit2
	beq $t4,'8',storeDigit2
	beq $t4,'9',storeDigit2
	# neu khong nhap vao chu so thu 2
	jal numberToPostfix
	j continueScan
digit3: 
	# neu scan ra chu so thu 3 --> error
	beq $t4,'0',wrongInput
	beq $t4,'1',wrongInput
	beq $t4,'2',wrongInput
	beq $t4,'3',wrongInput
	beq $t4,'4',wrongInput
	beq $t4,'5',wrongInput
	beq $t4,'6',wrongInput
	beq $t4,'7',wrongInput
	beq $t4,'8',wrongInput
	beq $t4,'9',wrongInput
	# neu khong co chu so thu  3
	jal numberToPostfix
	j continueScan
plusMinus:							# Input is + -
	beq $s7,2,wrongInput			# Nhan toan tu sau toan tu hoac "("
	beq $s7,3,wrongInput
	beq $s7,0,wrongInput			# nhan toan tu truoc bat ki so nao
	li $s7,2						# Thay doi trang thai dau  vao thanh 2
	continuePlusMinus:
	beq $t6,-1,inputOperatorToStack		# Khong co gi trong  stack -> day vao
	add $t8,$t6,$t3						# Load dia chi cua toan tu o dinh
	lb $t7,($t8)						# Load byte gia tri cua toan tu o dinh
	beq $t7,'(',inputOperatorToStack	# neu dinh la ( --> day vao
	beq $t7,'+',equalPrecedence			# neu dinh la + - --> day vao
	beq $t7,'-',equalPrecedence
	beq $t7,'*',lowerPrecedence			# neu dinh la * / % thi lay * / % ra roi day vao
	beq $t7,'/',lowerPrecedence
	beq $t7,'%',lowerPrecedence
multiplyDivideModulo:					# dau vao la * / %
	beq $s7,2,wrongInput				# Nhan toan tu sau toan tu hoac "("
	beq $s7,3,wrongInput
	beq $s7,0,wrongInput				# Nhan toan tu truoc bat ki so nao
	li $s7,2							# Thay doi trang thai dau vao thanh 2
	beq $t6,-1,inputOperatorToStack		# Khong co gi trong stack -> day vao
	add $t8,$t6,$t3						# Load dia chi cua toan tu o dinh
	lb $t7,($t8)						# Load byte gia tri cua toan tu o dinh
	beq $t7,'(',inputOperatorToStack	# neu dinh la ( --> day vao
	beq $t7,'+',inputOperatorToStack	# neu dinh la + - --> day vao
	beq $t7,'-',inputOperatorToStack
	beq $t7,'*',equalPrecedence			# neu dinh la * / % day vao
	beq $t7,'/',equalPrecedence
	beq $t7,'%',equalPrecedence
openBracket:							# dau vap la (
	beq $s7,1,wrongInput				# Nhan "(" sau mot so hoac dau ")"
	beq $s7,4,wrongInput	
	li $s7,3							# Thay doi trang thai dau vao thanh 3
	j inputOperatorToStack
closeBracket:							# dau vao la  ")"
	beq $s7,2,wrongInput				# Nhan ")" sau mot toan tu hoac toan tu
	beq $s7,3,wrongInput	
	li $s7,4							# Thay doi trang thai dau vao thanh 4
	add $t8,$t6,$t3						# Load dia chi toan tu dinh  
	lb $t7,($t8)						# Load gia tri cua toan tu o dinh
	beq $t7,'(',wrongInput				# Input bao gom () khong co gi o giua  --> error
	continueCloseBracket:
	beq $t6,-1,wrongInput				# khong tïm duoc dau "(" --> error
	add $t8,$t6,$t3						# Load dia chi cua toan tu o dinh
	lb $t7,($t8)						# Load gia tri cua toan tu o dinh
	beq $t7,'(',matchBracket			# Tïm ngoac phu hop
	jal PopOperatorToPostfix			# day toan tu o dinh vao postfix
	j continueCloseBracket			# tiep tuc vong lap cho den khi tim duoc ngoac phu hop		
equalPrecedence:					#  nhan + - vao dinh stack la + - || nhan * / % vao dinh stack la * / %
	jal PopOperatorToPostfix			# lay toan tu dinh stack ra Postfix
	j inputOperatorToStack			# day toan tu moi vao stack 
lowerPrecedence:					# nhan + - vao dinh stack * / %
	jal PopOperatorToPostfix			# lay toan tu dinh stack ra va day vao postfix
	j continuePlusMinus			# tiep tuc vong lap
inputOperatorToStack:			# day dau vao cho toan tu
	add $t6,$t6,1				# tang offset cua toan tu o dinh len 1
	add $t8,$t6,$t3				# load dia chi cua  toan tu o dinh
	sb $t4,($t8)				# luu toan tu nhap vao stack
	j scanInfix
PopOperatorToPostfix:			# lay toan tu o dinh va luu vao postfix
	addi $t5,$t5,1				# tang offet cua toan tu o dinh stack len 1
	add $t8,$t5,$t2				# load dia chi cua toan tu o dinh stack
	addi $t7,$t7,100			# mï¿½ hï¿½a toan tu + 100
	sb $t7,($t8)				# luu toan tu vao postfix
	addi $t6,$t6,-1				# giam offset cua toan tu o dinh stack di 1
	jr $ra
matchBracket:					# xoa cap dau ngoac
	addi $t6,$t6,-1				# giam offset cua toan tu o dinh stack di 1
	j scanInfix
popAllOperatorInStack:				# lay het toan tu vao postfix
	jal numberToPostfix
	beq $t6,-1,finishScan			# stack rong --> ket thuc
	add $t8,$t6,$t3					# lay dia chi cua toan tu o dinh stack 
	lb $t7,($t8)					# lay gia tri cua toan tu o dinh stack
	beq $t7,'(',wrongInput			# ngoac khong phu hop --> error
	beq $t7,')',wrongInput
	jal PopOperatorToPostfix
	j popAllOperatorInStack					# lap cho den khi stack rong
storeDigit1:
	beq $s7,4,wrongInput			# nhan vao so sau  ")"
	addi $s4,$t4,-48				# luu chu so dau tien duoi dang so ma ascii cua chu so 0 la 48
	add $t9,$zero,1					# Thay doi trang thai thanh 1 
	li $s7,1
	j scanInfix
storeDigit2:
	beq $s7,4,wrongInput			# nhan vao so sau  ")"
	addi $s5,$t4,-48				# luu chu so thu hai duoi dang so
	mul $s4,$s4,10
	add $s4,$s4,$s5					# luu number = first digit * 10 + second digit
	add $t9,$zero,2					# thay doi trang thai thanh 2 
	li $s7,1
	j scanInfix
numberToPostfix:
	beq $t9,0,endnumberToPostfix
	addi $t5,$t5,1
	add $t8,$t5,$t2			
	sb $s4,($t8)				# luu so vao postfix
	li $t9, 0					# thay doi trang thai ve 0
	endnumberToPostfix:
	jr $ra
