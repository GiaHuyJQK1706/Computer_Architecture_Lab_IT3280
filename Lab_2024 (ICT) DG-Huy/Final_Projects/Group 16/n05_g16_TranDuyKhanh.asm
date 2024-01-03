.data
	infix: .space 256
	postfix: .space 256
	operator: .space 256
	stack2: .space 256
	endMsg: .asciiz "continue??"
	errorMsg: .asciiz "input not correct"
	startMsg: .asciiz "please enter infix\nNote: number must be 0from 00-99"
	prompt_postfix: .asciiz "postfix expression: "
	prompt_result: .asciiz "result: "
	prompt_infix: .asciiz "infix expression:  "
.text
start:
# input infix notation
	li $v0, 54
	la $a0, startMsg
	la $a1, infix
 	la $a2, 256
 	syscall
 	beq $a1,-2,end			# if cancel then end 
 	beq $a1,-3,start		# if enter then start
# print the infix notation
	li $v0, 4
	la $a0, prompt_infix
	syscall
	li $v0, 4
	la $a0, infix
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
# initialize 
	li $s7,0					# check condition variable
					
								# 1 - number from 0 - 99
								# 2 -  "* / + - %"
								# 3 - "("
								# 4 - ")"
	li $t9,0					# count the number of operand
	li $t5,-1					# store postfix
	li $t6,-1					# store operators
	la $t1, infix				# load address
	la $t2, postfix
	la $t3, operator	
	addi $t1,$t1,-1				# infix init index = -1
# change to postfix
scanInfix: 						
# check input 
	addi $t1, $t1, 1				# infix index ++ 
	lb $t4, 0($t1)					# value of infix notation 
	beq $t4, ' ', scanInfix			# space then continue
	beq $t4, '\n', EOF				# if enter , then pop all the remaining operator in stack
	beq $t9, 0, digit1				# t9 =  0 => 0 number
	beq $t9, 1, digit2				# t9 = 1 => 1 numbers
	beq $t9, 2, digit3				# t9 = 2 => already have 2 numbers => can not input more number
	continueScan:
	beq $t4, '+', plusMinus			
	beq $t4, '-', plusMinus
	beq $t4, '*', multiplyDivideModulo
	beq $t4, '/', multiplyDivideModulo
	beq $t4, '%', multiplyDivideModulo
	beq $t4, '(', openBracket
	beq $t4, ')', closeBracket
wrongInput:							
	li $v0, 55
 	la $a0, errorMsg
 	li $a1, 2
 	syscall
 	j ask
finishScan:
# print postfix
	
	li $v0, 4
	la $a0, prompt_postfix
	syscall
	li $t6,-1						# index of postfix = -1 
printPostfix:
	addi $t6,$t6,1					# index of postfix ++ 
	add $t8,$t2,$t6					# load address of postfix
	lbu $t7,($t8)					
	bgt $t6,$t5,finishPrint			# after print -> calculate result
	bgt $t7,99,printOperator		# value > 99 --> operator.  
	# if not then it is operand
	li $v0, 1
	add $a0,$t7,$zero
	syscall
	li $v0, 11
	li $a0, ' '
	syscall
	j printPostfix				# Loop
	printOperator:
	li $v0, 11
	addi $t7,$t7,-100			# Decode operator. 
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
#calculate
	li $t9,-4					# index stack  -4
	la $t3,stack2				# 
	li $t6,-1					# index postfix = -1
CalculatorPost:	
	addi $t6,$t6,1				# index postfix ++ 
	add $t8,$t2,$t6				# load address of postfix
	lbu $t7,($t8)				
	bgt $t6,$t5,printResult			
	bgt $t7,99,calculate			# value of postfix > 99 --> operator --> pop 2 operands
	# if not then it is operand
	addi $t9,$t9,4				# index stack + 4
	add $t4,$t3,$t9				
	sw $t7, ($t4)				 #put operand into stack
	j CalculatorPost				# Loop
	calculate:	
		# Pop first operand
		add $t4,$t3,$t9		
		lw $t0,($t4)
		# pop second operand
		addi $t9,$t9,-4
		add $t4,$t3,$t9		
		lw $t1,($t4)
		# Decode operator
		beq $t7,143,plus
		beq $t7,145,minus
		beq $t7,142,multiply
		beq $t7,147,divide
		beq $t7, 137, modulo
		plus:
			add $t0,$t0,$t1		
			sw $t0,($t4)		
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
	beq $s7,2,wrongInput			# error when the end is operators or "("
	beq $s7,3,wrongInput
	beq $t5,-1,wrongInput			#  no input -> error
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
	
	jal numberToPostfix
	j continueScan
digit3: 
	# if scan a third number --> error
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
	
	jal numberToPostfix
	j continueScan
	
	storeDigit1:
	beq $s7,4,wrongInput			# if number is read after ")" then error 
	addi $s4,$t4,-48				# change char type to integer type
	add $t9,$zero,1					# t9 changes to 1 
	li $s7,1
	j scanInfix
storeDigit2:
	beq $s7,4,wrongInput			# if number is read after ")" then error 
	addi $s5,$t4,-48				# change char type to integer type
	mul $s4,$s4,10
	add $s4,$s4,$s5					# number = first digit * 10 + second digit
	add $t9,$zero,2					#  t9 changes to 2 
	li $s7,1
	j scanInfix
	
numberToPostfix:
	beq $t9,0,endnumberToPostfix
	addi $t5,$t5,1
	add $t8,$t5,$t2			
	sb $s4,($t8)				
	li $t9, 0					
	endnumberToPostfix:
	jr $ra
		
plusMinus:							# Input is + -
	beq $s7,2,wrongInput			# error when it is scaned after "("
	beq $s7,3,wrongInput
	beq $s7,0,wrongInput			# error when operator is scanned first.
	li $s7,2	
					
continuePlusMinus:
	beq $t6,-1,inputOperatorToStack              #nothing in stack 	
	add $t8,$t6,$t3						# load address of operator
	lb $t7,($t8)						
	beq $t7,'(',inputOperatorToStack	
	beq $t7,'+',equalPrecedence			
	beq $t7,'-',equalPrecedence
	beq $t7,'*',lowerPrecedence			
	beq $t7,'/',lowerPrecedence
	beq $t7,'%',lowerPrecedence
multiplyDivideModulo:					
	beq $s7,2,wrongInput				
	beq $s7,3,wrongInput
	beq $s7,0,wrongInput				
	li $s7,2							
	beq $t6,-1,inputOperatorToStack	
	add $t8,$t6,$t3						# load address of operator 
	lb $t7,($t8)						# load value of operator
	beq $t7,'(',inputOperatorToStack	
	beq $t7,'+',inputOperatorToStack	
	beq $t7,'-',inputOperatorToStack
	beq $t7,'*',equalPrecedence		
	beq $t7,'/',equalPrecedence
	beq $t7,'%',equalPrecedence
openBracket:							
	beq $s7,1,wrongInput			            # "(" is placed after operand or ")"-> error	
	beq $s7,4,wrongInput	                                 
	li $s7,3							
	j inputOperatorToStack
closeBracket:							
	beq $s7,2,wrongInput				# ")" is placed after operator or "(" -> error. 
	beq $s7,3,wrongInput	
	li $s7,4							
	add $t8,$t6,$t3					
	lb $t7,($t8)						
	beq $t7,'(',wrongInput				# it is () -> error. 
continueCloseBracket:
	beq $t6,-1,wrongInput				
	add $t8,$t6,$t3						
	lb $t7,($t8)						
	beq $t7,'(',matchBracket			# match the bracket
	jal PopOperatorToPostfix			# day toan tu o dinh vao postfix
	j continueCloseBracket			# tiep tuc vong lap cho den khi tim duoc ngoac phu hop	
	
matchBracket:					
	addi $t6,$t6,-1				#remove brackets.
	j scanInfix	
equalPrecedence:					
	jal PopOperatorToPostfix			
	j inputOperatorToStack			
lowerPrecedence:					
	jal PopOperatorToPostfix			
	j continuePlusMinus			
inputOperatorToStack:			
	add $t6,$t6,1				# index operator ++
	add $t8,$t6,$t3				 
	sb $t4,($t8)				#store value into stack
	j scanInfix
PopOperatorToPostfix:			
	addi $t5,$t5,1				#index postfix ++
	add $t8,$t5,$t2				# load address of postfix
	addi $t7,$t7,100			# decode operator +100
	sb $t7,($t8)				# store value
	addi $t6,$t6,-1				#index operator --
	jr $ra

popAllOperatorInStack:				
	jal numberToPostfix
	beq $t6,-1,finishScan			# empty stack -> finish 
	add $t8,$t6,$t3					# load address of stack
	lb $t7,($t8)					
	beq $t7,'(',wrongInput			# still have unmatched bracket --> error
	beq $t7,')',wrongInput
	jal PopOperatorToPostfix
	j popAllOperatorInStack					# pop until empty


