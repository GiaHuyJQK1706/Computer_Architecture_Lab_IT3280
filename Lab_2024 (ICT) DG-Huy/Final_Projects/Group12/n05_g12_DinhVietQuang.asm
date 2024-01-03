#+++++++++++Assembly Language and Computer Architecture Lab+++++++++++
# 			Dinh Viet Quang - 20215235    		      #
# Student of ICT, SOICT, Hanoi University of Science and Technology  #
#  Task 5: Convert Infix to Postfix and calculate that expression    #
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.data
infix: .space 256
postfix: .space 256
operatorStack: .space 256
valueStack: .space 200
message1: .asciiz "\nDo you want to continue(1/0): "
message2: .asciiz "Enter infix: "
message3: .asciiz "Invalid infix\n"
message4: .asciiz "Valid infix\n"
message5: .asciiz "Postfix: "
message6: .asciiz "\nResult: "

.text
init:
	la $s0, infix
	la $s1, postfix
	la $s2, operatorStack
	la $s3, valueStack
	li $s4, 0 #s4: postIdx
	li $s5, 0 #s5: opIdx
	li $s6, 0 #s6: valIdx
main:
process:
	li $v0, 4
	la $a0, message2
	syscall
	
	li $v0, 8
	la $a0, infix  
	li $a1, 256
	syscall  #enter infix
check_valid:	
	li $t5, 1 #t5: lastWasOperator (previous was operator or operand?)
	li $t6, 0 #t6: inOperand (in the middle of operand?)
	li $t7, 0 #t7: number of parentheses
	li $t0, 0 #i = 0
loop_check:
	add $t1, $s0, $t0 
	lb $t2, 0($t1) #t2: infix[i]
	beq $t2, 0, end_loop_check #infix[i] = null -> end loop
	
	beq $t2, ' ', case_space_in_loop_check
	beq $t2, '\n', case_space_in_loop_check
	
	beq $t2, '(', case_open_paren_in_loop_check
	
	beq $t2, ')', case_close_paren_in_loop_check
	
	move $a0, $t2
	jal isOperator #isOperator(infix[i])
	beq $v0, 1, case_operator_in_loop_check
	
	move $a0, $t2
	jal isDigit #isDigit(infix[i])
	beq $v0, 1, case_digit_in_loop_check

	j invalid #contain invalid character	
case_space_in_loop_check:
	li $t6, 0 #inOperand = 0
	j continue_loop_check
case_open_paren_in_loop_check:
	addi $t7, $t7, 1 #numParen ++
	li $t5, 1 #lastWasOperator = 1
	li $t6, 0 #inOperand = 0
	j continue_loop_check
case_close_paren_in_loop_check:
	addi $t7, $t7, -1
	li $t6, 0 #inOperand = 0
	bltz $t7, invalid #numParen < 0 -> invalid
	j continue_loop_check #else continue
case_operator_in_loop_check:
	beq $t5, 1, invalid  #2 consecutive operators -> invalid
	li $t5, 1 #lastWasOperator = 1
	li $t6, 0 #inOperand = 0
	j continue_loop_check
case_digit_in_loop_check:
	beq $t5, 1, not_2_consecutive_operands #lastWasOperator = 1 -> not 2 consecutive operands
	beq $t6, 1, not_2_consecutive_operands #inOperand = 1 -> not 2 consecutive operands
	
	j invalid #2 consecutive operands -> invalid
not_2_consecutive_operands:
	li $t5, 0  #lastWasOperator = 0
	li $t6, 1 #inOperand = 1
	j continue_loop_check
continue_loop_check:
	addi $t0, $t0, 1
	j loop_check
end_loop_check:
	beq $t5, 1, invalid #end with operator -> invalid
	bne $t7, 0, invalid #numParenthese not zero -> invalid
	j valid
invalid:
	li $v0, 4
	la $a0, message3  
	syscall #notify "invalid expression"
	j enter_choice  #ask user whether to continue
valid:
	li $v0, 4
	la $a0, message4 
	syscall #notify "valid expression"

convert:
	li $t0, 0 #i=0
loop_convert:
	add $t1, $s0, $t0	
	lb $t2, 0($t1) #t2: infix[i]
	beq $t2, 0, end_loop_convert #infix[i] = null -> end loop
	
	beq $t2, ' ', continue_loop_convert #infix[i] = ' ' -> continue
	beq $t2, '\n', continue_loop_convert #infix[i] = '\n' -> continue
	
	beq $t2, '(', case_open_paren_in_loop_convert
	
	beq $t2, ')', case_close_paren_in_loop_convert
	
	move $a0, $t2
	jal isDigit #isDigit(infix[i])
	beq $v0, 1, case_digit_in_loop_convert
	
	move $a0, $t2
	jal isOperator #isOperator(infix[i])
	beq $v0, 1, case_operator_in_loop_convert
	
case_open_paren_in_loop_convert:
	move $a0, $t2
	jal operatorPush #opStack.push(infix[i])
	j continue_loop_convert
case_close_paren_in_loop_convert:
	loop_pop_until_open:
		jal operatorTop #v0 = opStack.top()
		move $t3, $v0 #t3: operator
		beq $t3, '(', end_loop_pop_until_open
		
		move $a0, $t3
		jal postfixAppend #postfix.append(operator)
		li $a0, ' '
		jal postfixAppend #postfix.append(' ')
		
		jal valueTop
		move $a2, $v0 #a2: operand2 = valStack.top()
		addi $s6, $s6, -1 #valStack.pop()
		jal valueTop
		move $a1, $v0 #a1: operand1 = valStack.top()
		addi $s6, $s6, -1 #valStack.pop()
		move $a3, $t3 #a3: operator
		jal calculate
		move $a0, $v0 #a0: result = calculate(operand1, operand2, operator)
		jal valuePush #valStack.push(result)
		
		addi $s5, $s5, -1 #opStack.pop()
		j loop_pop_until_open
	end_loop_pop_until_open:
		addi $s5, $s5, -1 #opStack.pop(), pop '('
		j continue_loop_convert
case_digit_in_loop_convert:
	li $t3, 0 #t3: val=0
	loop_digit:
		add $t1, $s0, $t0 
		lb $t2, 0($t1) #t2: infix[i]
		
		move $a0, $t2
		jal isDigit #isDigit(infix[i])
		beq $v0, 0, end_loop_digit #infix[i] is not digit -> end loop
		
		mul $t3, $t3, 10 #val = val*10
		add $t3, $t3, $t2 #val = val*10 + infix[i]
		sub $t3, $t3, '0' #val = val*10 + (infix[i] - '0')
		
		move $a0, $t2
		jal postfixAppend #postfix.append(infix[i])
		addi $t0, $t0, 1 #i++
		j loop_digit
	end_loop_digit:
		move $a0, $t3 
		jal valuePush #valStack.push(val)
		
		li $a0, ' '
		jal postfixAppend #postfix.append(' ')
		
		addi $t0, $t0, -1 #i--
		j continue_loop_convert
case_operator_in_loop_convert:
	loop_pop_until_lower_prec:
		blez $s5, end_loop_pop_until_lower_prec  #opStack is empty -> end loop
		
		jal operatorTop
		move $t3, $v0 #t3: operator = opStack.top()
		move $a0, $t3 
		jal prec
		move $t4, $v0 #t4: prec(operator)
		move $a0, $t2
		jal prec
		move $t5, $v0 #t5: prec(infix[i])
		blt $t4, $t5, end_loop_pop_until_lower_prec #prec(operator) < prec(infix[i]) -> end loop
		
		move $a0, $t3
		jal postfixAppend #postfix.append(operator)
		li $a0, ' '
		jal postfixAppend #postfix.append(' ')
		
		jal valueTop
		move $a2, $v0 #a2: operand2 = valStack.top()
		addi $s6, $s6, -1 #valStack.pop()
		jal valueTop
		move $a1, $v0 #a1: operand1 = valStack.top()
		addi $s6, $s6, -1 #valStack.pop()
		move $a3, $t3 #a3: operator
		jal calculate
		move $a0, $v0 #a0: result = calculate(operand1, operand2, operator)
		jal valuePush #valStack.push(result)
		
		addi $s5, $s5, -1 #opStack.pop()
		j loop_pop_until_lower_prec
	end_loop_pop_until_lower_prec:	
		move $a0, $t2
		jal operatorPush
		j continue_loop_convert	
continue_loop_convert:	
	addi $t0, $t0, 1
	j loop_convert
end_loop_convert:
	loop_pop_remaining:
		blez $s5, end_loop_pop_remaining  #opStack is empty -> end loop
		
		jal operatorTop
		move $t3, $v0 #t3: operator
		
		move $a0, $t3
		jal postfixAppend #postfix.append(operator)
		li $a0, ' '
		jal postfixAppend #postfix.append(' ')
		
		jal valueTop
		move $a2, $v0 #a2: operand2 = valStack.top()
		addi $s6, $s6, -1 #valStack.pop()
		jal valueTop
		move $a1, $v0 #a1: operand1 = valStack.top()
		addi $s6, $s6, -1 #valStack.pop()
		move $a3, $t3 #a3: operator
		jal calculate
		move $a0, $v0 #a0: result = calculate(operand1, operand2, operator)
		jal valuePush #valStack.push(result)
		
		addi $s5, $s5, -1 #opStack.pop()
		j loop_pop_remaining
	end_loop_pop_remaining:
		li $a0, 0
		jal postfixAppend #postfix.append('\0')
		
		li $v0, 4
		la $a0, message5
		syscall
		
		li $v0, 4
		move $a0, $s1
		syscall #print postfix
		
		li $v0, 4
		la $a0, message6
		syscall
		
		jal valueTop
		move $a0, $v0
		li $v0, 1
		syscall #print result
reset:
	li $s4, 0
	li $s5, 0
	li $s6, 0
		
enter_choice:	
	li $v0, 4
	la $a0, message1
	syscall
	
	li $v0, 5
	syscall
	
	beq $v0, 1, main
end_main:
	li $v0, 10
	syscall
	
#int isOperator(char c)
#$a0: c
#return $v0
isOperator:
	beq $a0, '+', is_operator
	beq $a0, '-', is_operator
	beq $a0, '*', is_operator
	beq $a0, '/', is_operator
	beq $a0, '%', is_operator
	j is_not_operator
is_operator:
	li $v0, 1
	jr $ra
is_not_operator:
	li $v0, 0
	jr $ra	
	
#int isDigit(char c)
#$a0: c
#return $v0
isDigit:
	blt $a0, '0', is_not_digit
	bgt $a0, '9', is_not_digit
	j is_digit
is_digit:
	li $v0, 1
	jr $ra
is_not_digit:
	li $v0, 0
	jr $ra
	
#void operatorPush(char c)
#$a0: c
operatorPush:
	add $t8, $s2, $s5  #t8 = addr(opStack) + opIdx
	sb $a0, 0($t8) #opStack[opIdx] = c
	addi $s5, $s5, 1 #opIdx++
	jr $ra
	
#char operatorTop()
#return $v0
operatorTop:
	add $t8, $s2, $s5  #t8 = addr(opStack) + opIdx
	addi $t8, $t8, -1
	lb $v0, 0($t8) #v0 = opStack[opIdx-1]
	jr $ra

#void valuePush(int val)
#$a0: val
valuePush:
	add $t8, $s6, $s6
	add $t8, $t8, $t8
	add $t8, $s3, $t8 #t8 = addr(valStack) + 4*valIdx
	sw $a0, 0($t8) #valStack[valIdx] = val
	addi $s6, $s6, 1 #valIdx++
	jr $ra

#int valueTop()
#return $v0
valueTop:
	add $t8, $s6, $s6
	add $t8, $t8, $t8
	add $t8, $s3, $t8 #t8 = addr(valStack) + 4*valIdx
	addi $t8, $t8, -4
	lw $v0, 0($t8) #v0 = valStack[valIdx-1]	
	jr $ra
	
#void postfixAppend(char c)
#$a0: c
postfixAppend:
	add $t8, $s1, $s4 #t8: addr(postfix) + postIdx
	sb $a0, 0($t8) #postfix[postIdx] = c
	addi $s4, $s4, 1 #postIdx++
	jr $ra

#int calculate(int operand1, int operand2, char operator)
#$a1: operand1, $a2: operand2, $a3: operator
#return $v0
calculate:
	beq $a3, '+', plus
	beq $a3, '-', minus
	beq $a3, '*', multiply
	beq $a3, '/', divide
	beq $a3, '%', modulo
	j default_case
plus:
	add $v0, $a1, $a2
	jr $ra
minus:
	sub $v0, $a1, $a2
	jr $ra
multiply:
	mul $v0, $a1, $a2
	jr $ra
divide:
	beq $a2, 0, default_case
	div $v0, $a1, $a2
	jr $ra
modulo:
	beq $a2, 0, default_case
	div $a1, $a2
	mfhi $v0
	jr $ra
default_case:
	li $v0, 0
	jr $ra
	
#int prec(char c)
#$a0: c
#return $v0
prec:
	beq $a0, '*', high_prec
	beq $a0, '/', high_prec
	beq $a0, '%', high_prec
	beq $a0, '+', low_prec
	beq $a0, '-', low_prec
	j default_prec
high_prec:
	li $v0, 2
	jr $ra
low_prec:
	li $v0, 1
	jr $ra
default_prec:
	li $v0, 0
	jr $ra