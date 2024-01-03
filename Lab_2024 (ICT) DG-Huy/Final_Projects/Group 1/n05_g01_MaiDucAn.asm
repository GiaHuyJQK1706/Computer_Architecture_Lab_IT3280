#-----------------------------------------------------------#
# 		Mai Duc An - 20210008 - ICT01 - K66	    #
# 			Project 05 - Group 01		    #
#-----------------------------------------------------------#
.data
infix:		.space 256
postfix: 	.space 256
postfix_:		.space 256 
stack: 		.space 256
msg_read_infix: 	.asciiz "Please enter an infix expression: "
msg_print_infix: 	.asciiz "Infix expression: "
msg_print_postfix: 	.asciiz "Postfix expression: "
msg_print_result: 	.asciiz "Result of the expression: "
msg_enter: 		.asciiz "\n"
msg_error1:	 	.asciiz "You enter a number that greater than 99. Please try again!"
msg_error2: 		.asciiz "You enter a number that less than 0. Please try again!"
msg_error3: 		.asciiz "ERROR: You enter a divisor that equal 0."
msg_error4: 		.asciiz "ERROR: You enter a bracket that has wrong position."
.text
#---------------------------------------------------------------------
# @brief      get the infix expression from user and display
# @param[in]  $a0	argument value
#	      $a1       argument value   
#             $a2       argument value
#	      $v0	service number 
#---------------------------------------------------------------------
input_infix:	
	li $v0, 54
	la $a0, msg_read_infix		# address of string of message
	la $a1, infix 				# address of input buffer
	la $a2, 256				# maximum number of characters 
	syscall
	li $v0, 4
	la $a0, msg_print_infix		# address of string to print
	syscall
	li $v0, 4
	la $a0, infix			# address of string to print
	syscall	
#---------------------------------------------------------------------
# @brief      convert infix expression to postfix expression
# @param[in]  $s0	index of infix array
# 	      $s1       index of postfix array
#	      $s2	index of stack array
# 	      $a3       amount of the left parenthesises
#	      $t0 	character that considered 
# 	      $t2       character that considered 
#             $t4	character that considered 
# @return     $a0 	the result of postfix expression
#---------------------------------------------------------------------
convert_postfix:
	li $s0, 0				# index j of infix
	li $s1, 0				# index i of postfix
	li $s2, -1				# index k of stack
	li $a3, 0				# lparcount = 0
	li $s3, 0 				# element to push to postfix
	lb $t0, infix($s0)
	beq $t0, '-', lt0_error 		# check the first number is nagative
	nop 
loop_infix:	
	lb $t0, infix($s0)			# $t0 = infix[j]
	beq $t0, $0, end_loop_infix		# $t0 = 0 -> end loop
	nop						
	beq $t0, '\n', end_loop_infix 	
	nop	
	beq $t0, ' ', remove_space1
	nop		
# if $t0 is operand, to arrange according to priority of operands than push to stack					
	beq $t0, '+', consider_plus_minus		
	nop
	beq $t0, '-', consider_plus_minus
	nop
	beq $t0, '*', consider_mul_div
	nop
	beq $t0, '%', consider_mul_div
	nop
	beq $t0, '/', consider_mul_div
	nop
	beq $t0, '(', consider_lpar		# check nagative number if get '('
	nop
	beq $t0, ')', consider_rpar1
	nop
# if $t0 is operand, push to postfix immediately
	sb $t0, postfix($s1)		# postfix[i] = $t0	
	addi $s1, $s1, 1			# i++
# if 9 < number < 100 -> look ahead for a character 
loop_continue:	
	addi $s0, $s0, 1			# j++ 
	lb $t2, infix($s0)			# $t2 = infix[j]
	beq $t2, '0', continue
	nop
	beq $t2, '1', continue
	nop
	beq $t2, '2', continue
	nop
	beq $t2, '3', continue
	nop
	beq $t2, '4', continue
	nop
	beq $t2, '5', continue
	nop
	beq $t2, '6', continue
	nop
	beq $t2, '7', continue
	nop
	beq $t2, '8', continue
	nop
	beq $t2, '9', continue
	nop	
	beq $t2, ' ', loop_continue
	nop
	li $s3, ' ' 		
	sb $s3, postfix($s1)		# postfix[i] = ' '
	addi $s1, $s1, 1			# i++
	j loop_infix		
	nop
remove_space1:	
	addi $s0, $s0, 1			# i++
	j loop_infix
	nop
# check the next character 
continue: 	
	addi $t3, $s0, 1			# $t3 = j++
	lb $t4, infix($t3)			# infix[$t3] = $t4
	
# if greater than 99 -> branch to error alert
check_gt99:	
	beq $t4, '0', gt99_error
	nop
	beq $t4, '1', gt99_error
	nop
	beq $t4, '2', gt99_error
	nop
	beq $t4, '3', gt99_error
	nop
	beq $t4, '4', gt99_error
	nop
	beq $t4, '5', gt99_error
	nop
	beq $t4, '6', gt99_error
	nop
	beq $t4, '7', gt99_error
	nop
	beq $t4, '8', gt99_error
	nop
	beq $t4, '9', gt99_error
	nop
	sb $t2, postfix($s1)  		# else postfix[i] = $t2
	addi $s1, $s1, 1			# i++
	li $s3, ' '		
	sb $s3, postfix($s1)			# postfix[i] = ' '
	addi $s1, $s1, 1			# i++
	addi $s0, $s0, 1			# j++
	j 	loop_infix		
	nop
gt99_error:	
	li $v0, 55			
	la $a0, msg_error1			# address of error message
	syscall
	j 	input_infix			
	nop
#---------------------------------------------------------------------
# procedure to handle minus and plus 
# operator '+' and '-' have the same priority 
# $s0	index of infix array
# $s1   index of postfix array
# $s2	index of stack array
# $t1   temporary value
# $t9   temporary value
#---------------------------------------------------------------------
consider_plus_minus:	
	beq $s2, -1, push_op		# if stack is null, push this operator to stack 
	nop
	lb $t9, stack($s2)		
	beq $t9, '(', push_op	# if peek of stack is '(', push this operator to stack
	nop
	lb $t1, stack($s2)		# else pop all operators out of stack then push this operator to stack
	sb $t1, postfix($s1)	
	addi $s2, $s2, -1			# k--
	addi $s1, $s1, 1			# i++
	li $s3, ' ' 		
	sb $s3, postfix($s1)		# postfix[i] = ' '
	addi $s1, $s1, 1			# i++
	j consider_plus_minus	
	nop
#---------------------------------------------------------------------
# procedure to handle multiply and division 
# operator '*', '%' and '/' have the same priority
# $s0	index of infix array
# $s1   index of postfix array
# $s2	index of stack array
# $t1   temporary value
# $t9   temporary value
#---------------------------------------------------------------------
consider_mul_div:
	beq $s2, -1, push_op		# if stack is null, push this operator to stack
	nop				
	lb $t9, stack($s2)			
	beq $t9, '+', push_op		# if peek of stack is '+', '-', '(', push this operator to stack
	nop
	beq $t9, '-', push_op
	nop
	beq $t9, '(', push_op
	nop
	lb $t1, stack($s2)        	# else pop all operators out of stack then push this operator to stack
	sb $t1, postfix($s1)
	addi $s2, $s2, -1	       	# k--
	addi $s1, $s1, 1			# i++
	li $s3, ' ' 		
	sb $s3, postfix($s1)		# postfix[i] = ' '
	addi $s1, $s1, 1			# i++
	j consider_mul_div
	nop
#---------------------------------------------------------------------
# procedure to handle parentheses
# $s0	index of infix array
# $s1   index of postfix array
# $s2	index of stack array
# $t1   temporary value
# $t3   temporary value
# $t4   temporary value
# $a3   amount of the left parenthesises
#---------------------------------------------------------------------	
consider_lpar:		
	addi $a3, $a3, 1			# lparcount++
	addi $t3, $s0, 1			# $t3 = j++
	lb $t4, infix($t3)			# $t4 = infix[j]
	beq $t4, '-', lt0_error		# if infix[j] == '-' -> negative value -> branch to error alert
	nop
	j 	push_op				# else push to stack
	nop			
consider_rpar1:	
	addi $a3, $a3, -1			# lparcount--
	j 	consider_rpar
	nop			
consider_rpar:	
	beq $s2, -1, push_op		# if stack is null, push right parentheses to stack
	nop
	lb $t1, stack($s2)  		# else pop operator out of stack
	sb $t1, postfix($s1)		# postfix[i] = $t1
	addi $s2, $s2, -1			# k-- 
	addi $s1, $s1, 1			# i++
	beq $t1, '(', push_op		# until get '(' then push to stack
	j consider_rpar
	nop			
lt0_error:	
	li $v0, 55
	la $a0, msg_error2			# address of error message
	syscall
	j input_infix		
	nop						
push_op:	
	addi $s2, $s2, 1			# k++ 
	sb $t0, stack($s2)			# stack[k] = $t0 
	addi $s0, $s0, 1			# j-- 
	j loop_infix
	nop
# pop the other operators of stack then push to postfix
end_loop_infix:	
	beq $s2, -1, remove_parentheses
	nop
	lb $t0, stack($s2)		# $t0 = stack[k]
	sb $t0, postfix($s1)		# postfix[i] = $t0
	addi $s2, $s2, -1			# k--
	addi $s1, $s1, 1			# i++
	li $s3, ' ' 		
	sb $s3, postfix($s1)		# postfix[i] = ' '
	addi $s1, $s1, 1			# i++
	j end_loop_infix
	nop
# remove parentheses procedure
	li $s6, 0				# index of postfix
	li $s7, 0				# index of postfix_
remove_parentheses:	
	lb $t5, postfix($s6)		# $t5 = postfix[i]
	addi $s6, $s6, 1			# i++
	beq $t5, '(', remove_parentheses
	nop
	beq $t5, ')', remove_parentheses
	nop
	beq $t5, 0, print_postfix 		# if get a null character -> branch to print postfix expression
	nop
	sb $t5, postfix_($s7)		# postfix_[j] = $t5
	addi $s7, $s7, 1			# j++
	j remove_parentheses
	nop
# print postfix procedure
print_postfix:	
	bne $a3, 0, error1			# if lparcount != 0 -> branch to error alert
	nop
	li $v0, 4
	la $a0, msg_print_postfix		# address of message
	syscall
	li $v0, 4
	la $a0, postfix_			# address of final result
	syscall
	li $v0, 4
	la $a0, msg_enter
	syscall
	j calculate_postfix 		
	nop	
error1:			
	li $v0, 55
	la $a0, msg_error4
	syscall
	li $v0, 10				# exit
	syscall		
#---------------------------------------------------------------------
# @brief   calculate by postfix expression
# @param[in]  	$s1     index of postfix_ array
# 		$s2	index of stack array
# 		$t0 	character is considered 
# 		$t2	character is considered
# 		$t3     temporary value
# @return    	$t4	value of postfix expression
#---------------------------------------------------------------------
calculate_postfix:	
	li $s1, 0 				# i = 0
loop_postfix: 	
	lb $t0, postfix_($s1)		# $t0 = postfix[i]
	beq $t0, $0, print_result		# if $t0 = '\0' -> branch to print result 
	nop
	beq $t0, ' ', remove_space		# skip space
	nop
# if character is number -> check the next character
	beq $t0, '0', next			
	nop
	beq $t0, '1', next
	nop
	beq $t0, '2', next
	nop
	beq $t0, '3', next
	nop
	beq $t0, '4', next
	nop
	beq $t0, '5', next
	nop
	beq $t0, '6', next
	nop
	beq $t0, '7', next
	nop
	beq $t0, '8', next
	nop
	beq $t0, '9', next
nop
operator:	
	lw $t6, -8($sp)			# load the first value (a) from stack pointer
	lw $t7, -4($sp)			# load the second value (b) from stack pointer 
	addi $sp, $sp, -8
	beq $t0, '+', add_func		# if $t0 = '+' -> branch to add function
	nop
	beq $t0, '-', sub_func		# if $t0 = '-' -> branch to sub function
	nop
	beq $t0, '*', mul_func		# if $t0 = '*' -> branch to mul function
	nop
	beq $t0, '%', mod_func		# if $t0 = '%' -> branch to mod function
	nop
	beq $t0, '/', div_func		# if $t0 = '/' -> branch to div function
	nop
	addi $s1, $s1, 1			# i++
	j loop_postfix
# if get a space then remove it
remove_space:	
	addi $s1, $s1, 1			# i++
	j loop_postfix
	nop
next:		
	addi $s1, $s1, 1			# i++
	lb $t2, postfix_($s1)		# $t2 = postfix_[i]
	beq $t2, '0', push_number 	
	nop
	beq $t2, '1', push_number
	nop
	beq $t2, '2', push_number
	nop
	beq $t2, '3', push_number
	nop
	beq $t2, '4', push_number
	nop
	beq $t2, '5', push_number
	nop
	beq $t2, '6', push_number
	nop
	beq $t2, '7', push_number
	nop
	beq $t2, '8', push_number
	nop
	beq $t2, '9', push_number
	nop
	addi $t0, $t0, -48			# if number < 10 then convert character from char to number 
	sw $t0, 0($sp)			
	addi $sp, $sp, 4
	j loop_postfix
	nop	
push_number:	
	addi $t0, $t0, -48			# convert character from char to number
	addi $t2, $t2, -48			# convert character from char to number
	mul $t3, $t0, 10
	add $t3, $t3, $t2 			# $t3 = 10 * $t0 + $t2
	sw $t3, 0($sp)			# $sp = $t3
	addi $sp, $sp, 4
	addi $s1, $s1, 1			# i++ 
	j loop_postfix		
#---------------------------------------------------------------------
# add function 
# $t6	the first number/ the result
# $t7   the second number
# $s1   index of postfix_ array
# $sp   stack pointer
#---------------------------------------------------------------------	
add_func:	
	add $t6, $t6, $t7			# $t6 = $t6 + $t7
	sw $t6, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4		
	addi $s1, $s1, 1			# i++
	j loop_postfix
	nop
#---------------------------------------------------------------------
# sub function 
# $t6	the first number/ the result
# $t7   the second number
# $s1   index of postfix_ array
# $sp   stack pointer
#---------------------------------------------------------------------	
sub_func:	
	sub $t6, $t6, $t7			# $t6 = $t6 - $t7
	sw $t6, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4
	addi $s1, $s1, 1			# i++
	j loop_postfix
	nop
#---------------------------------------------------------------------
# mul function 
# $t6	the first number/ the result
# $t7   the second number
# $s1   index of postfix_ array
# $sp   stack pointer
#---------------------------------------------------------------------	
mul_func:	
	mul $t6, $t6, $t7			# $t6 = $t6 * $t7
	sw $t6, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4
	addi $s1, $s1, 1			# i++
	j loop_postfix
#---------------------------------------------------------------------
# modulo function 
# $t6	the first number/ the result
# $t7   the second number
# $s1   index of postfix_ array
# $sp   stack pointer
#---------------------------------------------------------------------	
mod_func:	
	beq $t7, 0, invalid_divisor		# if the divisor == 0 -> branch to error alert
	nop
	div $t6, $t7 				# $t9 = $t6 % $t7
	mfhi $t9
	sw $t9, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4
	addi $s1, $s1, 1			# i++
	j loop_postfix
	nop
#---------------------------------------------------------------------
# div function 
# $t6	the first number/ the result
# $t7   the second number
# $s1   index of postfix_ array
# $sp   stack pointer
#---------------------------------------------------------------------	
div_func:	
	beq $t7, 0, invalid_divisor		# if the divisor == 0 -> branch to error alert
	nop
	div $t6, $t6, $t7			# $t6 = $t6/$t7
	sw $t6, 0($sp)			# $sp = $t6
	addi $sp, $sp, 4
	addi $s1, $s1, 1			# i++
	j loop_postfix
	nop
invalid_divisor:
	li $v0, 55
	la $a0, msg_error3
	syscall
	#j input_infix
	li $v0, 10				# exit
	syscall
print_result:		
	li $v0, 4
	la $a0, msg_print_result
	syscall
	li $v0, 1
	lw $t4, -4($sp)
	la $a0, ($t4)
	syscall
	li $v0, 4
	la $a0, msg_enter
	syscall
