.data
 	command: .asciiz "Enter an instruction: "	
 	str1: .asciiz "opcode: "
	str2: .asciiz "operand: "
	str3: .asciiz ", correct.\n"
	str4: .asciiz ", incorrect!\n"
	msg_correct: .asciiz "The instruction you entered has the correct syntax.\n"
	msg_incorrect: .asciiz "The instruction you entered has incorrect syntax !\n"	
	msg_continue: .asciiz "Do you want to continue the program ? Enter 1 for Yes and 0 for No: "
	input: .space 100
	token: .space 20
	list: .asciiz "add**111;addi*112;addu*111;and**111;andi*112;beq**113;bgez*130;bgtz*130;blez*130;bltz*130;bne**113;div**110;eret*000;jr***100;jal**300;j****300;lui**120;lb***121;lh***121;lw***121;mfhi*100;mflo*100;mul**111;mult*110;nop**000;nor**111;ori**112;or***111;srl**112;srlv*111;sll**112;sllv*111;slt**111;slti*112;sra**112;sb***121;sh***121;sw***121;sub**111;teq**110;teqi*120;xor**111;xori*112"
	char: .asciiz "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
	register: .asciiz "$zero*;$at***;$v0***;$v1***;$a0***;$a1***;$a2***;$a3***;$t0***;$t1***;$t2***;$t3***;$t4***;$t5***;$t6***;$t7***;$s0***;$s1***;$s2***;$s3***;$s4***;$s5***;$s6***;$s7***;$t8***;$t9***;$k0***;$k1***;$gp***;$sp***;$fp***;$ra***;$0****;$1****;$2****;$3****;$4****;$5****;$6****;$7****;$8****;$9****;$10***;$11***;$12***;$13***;$14***;$15***;$16***;$17***;$18***;$19***;$20***;$21***;$22***;$23***;$24***;$25***;$26***;$27***;$28***;$29***;$30***;$31***;$32***"
.text
main:

getInput:
        li $v0, 4
	la $a0, command 
	syscall
	
	li $v0, 8	# read a string
	la $a0, input   # a0 = address of input string
	li $a1, 100 
	syscall
	
	la $a1,token # a1 = address of token (a substring of the input string, to store opcode or operands)
	li $s7,0 # i= 0 = current input string index
	li $t8,0 # Used to check whether the input string contains '('
	li $t9,0 # Used to check whether the input string contains ')'
	j getOpcode
exit:
# Exit the program
	li $v0,10
        syscall     
end_main:

getOpcode: # Extract opcode from input string, store to token
        
        add $t1,$a0,$s7 # t1 = address of input[i]
        add $t3,$a1,$s7 # t3 = address of token[i]
        lb $t2,0($t1)
        beq $t2, ' ', done
	beq $t2, '\n', done
        sb $t2,0($t3)         	
	addi $s7, $s7, 1
	j getOpcode
done:
        li $t2,'\0'
        sb $t2,0($t3)	# Append '\0' to token   		
	la $a2, list # a2 = address of list
	jal checkOpcode 		
	
	beq $s2, 1, correctOpcode 	
	j incorrectOpcode
		  		
correctOpcode:			
	
	li $v0, 4
	la $a0, str1		
	syscall
	
	li $v0, 4
	la $a0, token
	syscall
	
	li $v0, 4
	la $a0, str3
	syscall
	
	li $s5,5 # Used to get the first operand's type
	li $s6,8 # Used for condition after finish checking 3 operand's types
	j getOpr
incorrectOpcode:
        
	li $v0, 4
	la $a0, str1		
	syscall
	
	li $v0, 4
	la $a0, token
	syscall
	
	li $v0, 4
	la $a0, str4
	syscall
	
	j incorrect
checkOpcode:
        li $s2,0 # Initial value for check = 0
        li $s0,0 # i=0
        loop1:
        add $t0,$a2,$s0 # t0 = address of list[i]
        lb $t0,0($t0) # t0 = list[i]
        beq $t0,0,finish # No matches were found
        move $s1,$s0 # j=i
        li $s3,0 # k = 0 
        inner_loop:        
        add $t0,$a2,$s1 # t0 = address of list[j]
        lb $t0,0($t0) # t0 = list[j]
        
        add $t1,$a1,$s3 # t1 = address of token[k]
        lb $t1,0($t1) # t1 = token[k]
        
        bne $t0,'*',skip 
        bne $t1,'\0',end # If we get a '*' means that the token must terminate (the correspoding char must be '\0')
        li $s2,1 # Find a match
        j finish
        skip:
        beq $t0,$t1,cont # If list[j] == token[k], continue checking this instruction opcode
        j end
        cont:
        addi $s1,$s1,1 # j++
        addi $s3,$s3,1 # k++
        j inner_loop
        end:
        addi $s0,$s0,9 # Go to next instruction opcode
	j loop1
        finish:
        jr $ra
getOpr:        # Extract operands from input string, store to token
        la $a0,input
        li $t0,0  # i = 0
        
        add $t1,$a0,$s7
        lb $t2,0($t1)
        beq $t2, '(',openBracket
        # Ignore space and comma
        truncate:
        addi $s7,$s7,1 
        add $t1,$a0,$s7
        lb $t2,0($t1)
        beq $t2, ' ',truncate  
        beq $t2, ',',truncate
        beq $t2, '(',openBracket
        # Get the operand
        
        loop2:         
        add $t1,$a0,$s7 # t1 = address of next input string character
        add $t3,$a1,$t0 # t3 = address of token[i]
        lb $t2,0($t1)
        beq $t2, ',', doneGetOpr
	beq $t2, '\n', doneGetOpr
	beq $t2,'\0',doneGetOpr
	beq $t2,' ',closeBracket
	beq $t2,'(',doneGetOpr
	beq $t2,')',closeBracket
        sb $t2,0($t3)
        cont2:         	
	addi $t0, $t0, 1
	addi $s7,$s7,1
	j loop2
	
doneGetOpr:
        li $t2,'\0'
        sb $t2,0($t3)	# Append '\0' to token 
        
        add $t0,$s0,$s5 # t0 = index of first operand's type in this instruction format
        add $t0,$a2,$t0 
        lb $t0,0($t0) 
        addi $t0,$t0,-48 # t0 = first operand's type
        li $s4,0 # Initialize checkOpr = 0
        case0:		
		bne $t0, 0, case1		
		jal checkNullOpr 	
		j checked			
	case1:	
		bne $t0, 1, case2 					
		jal checkRegisterOpr 		
		j checked			
	case2:
		bne $t0, 2, case3 		
		jal checkIntegerOpr		
		j checked				
	case3:		
		jal checkLabelOpr		
		j checked	
	checked:
	        addi $t2,$s5,1
	        bne $t2,$s6,skipBracket
	        xor $t1,$t8,$t9
	        bne $t1,$zero,incorrect
	        skipBracket:
		beq $s4, 1, correctOpr	# If checkOpr = 1, print a correct message
		j incorrectOpr			
	
checkNullOpr: # Check the null operand (does not exist) 
        lb $t2,0($a1)
        beq $t2,'\0',isEmpty
        j endCheckNullOpr
        isEmpty:
        li $s4,1
endCheckNullOpr:
        jr $ra
        
checkRegisterOpr: # Check the register operand
       # Compare the token with each register in the string 'register'
       li $s4,1 
       la $a3,register # a3 = address of string of registers
       li $t1,0 # i=0          
       loop5:  
       move $t2,$t1 # j=i
       li $t5,0 # k=0
       inner_loop5:
       add $t3,$a3,$t2
       lb $t3,0($t3) # t3 = register[j]
       add $t4,$a1,$t5
       lb $t4,0($t4) # t4 = token[k]   
       beq $t3,'\0', isNotRegister
       beq $t3,'*',skip5      # If we get a '*' means that the token must terminate (the correspoding char must be '\0')
       bne $t3,$t4,outer5
       j cont5
       skip5:
       beq $t4,'\0',endCheckRegisterOpr
       j outer5
       cont5:
       addi $t2,$t2,1 # j++
       addi $t5,$t5,1 # k++
       j inner_loop5
       outer5:
       addi $t1,$t1,7 # Check the next register in the list
       j loop5
       isNotRegister:
       li $s4,0
endCheckRegisterOpr:
        jr $ra
        
checkIntegerOpr: # Check the integer operand
       li $s4,1
       li $t1,0 # i=0     
       add $t2,$a1,$t1 
       lb $t2,0($t2) # t2 = token[0]
       beq $t2,'\0',isNotInteger  # To avoid the case that token is empty
       bne $t2,'-',loop3
       addi $t1,$t1,1 # i++
       add $t2,$a1,$t1 
       lb $t2,0($t2)
       beq $t2,'\0',isNotInteger # To avoid the case that token contains only a '-'
       loop3:
       add $t2,$a1,$t1 
       lb $t2,0($t2) # t2 = token[i]
       beq $t2,'\0',endCheckIntegerOpr
       blt $t2,48,isNotInteger
       bgt $t2,57,isNotInteger
       addi $t1,$t1,1 # i++
       j loop3
       isNotInteger:
       li $s4,0
endCheckIntegerOpr:
        jr $ra
        
checkLabelOpr: # Check the label 
       li $s4,1 
       li $t1,0 # i=0    
       add $t2,$a1,$t1 
       lb $t2,0($t2) # t2 = token[0]
       beq $t2,'\0',isNotLabel  # To avoid the case that token is empty
       la $a3,char # a3 = address of string of accepted characters         
       add $t2,$a1,$t1 
       lb $t2,0($t2) # t2 = token[0]  
       slti $t3,$t2,58
       li $at,47
       slt $t4,$at,$t2
       and $t5,$t3,$t4
       beq $t5,1,isNotLabel
       loop4:
       add $t2,$a1,$t1 
       lb $t2,0($t2) # t2 = token[i]
       beq $t2,'\0',endCheckLabelOpr
       li $t6,0 # j=0
       inner_loop4:
       add $t7,$a3,$t6
       lb $t7,0($t7) # t7 = char[j]
       beq $t7,'\0',isNotLabel
       beq $t7,$t2,outer3
       addi $t6,$t6,1 # j++
       j inner_loop4
       outer3:
       addi $t1,$t1,1 # i++
       j loop4
       isNotLabel:
       li $s4,0
endCheckLabelOpr:
        jr $ra
correctOpr:

        beq $t0,0,correct
	li $v0, 4
	la $a0, str2		
	syscall
	
	li $v0, 4
	la $a0, token
	syscall
	
	li $v0, 4
	la $a0, str3
	syscall
	
        addi $s5,$s5,1
	blt $s5,$s6,getOpr # Continue to get the next operand, if there are not enough 3 operands
	
	j correct        
incorrectOpr:
        
	li $v0, 4
	la $a0, str2		
	syscall
	
	li $v0, 4
	la $a0, token
	syscall
	
	li $v0, 4
	la $a0, str4
	syscall
incorrect: # The instruction is incorrect
	li $v0, 4
	la $a0, msg_incorrect
	syscall
	j continue
correct: # The instruction is correct
	li $v0, 4
	la $a0, msg_correct
	syscall
continue:	# Continue the program or not
	li $v0, 4
	la $a0, msg_continue
	syscall
	
	li $v0, 5
	syscall
	
	bne $v0, $zero, getInput
	j exit
openBracket:
# Find a '(', set $t8 to 1
        li $t8,1
        j truncate
closeBracket:
# Check if the remaining characters of the input string contain ')'
         move $t4,$s7
         loop6:
         add $t2,$a0,$t4
         lb $t2,0($t2)
         beq $t2,'\0',skip6
         beq $t2,')',close
         j cont6
         close:
         li $t9,1
         j skip6
         cont6:
         addi $t4,$t4,1
         j loop6
         skip6:
         j doneGetOpr

	


	
       

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
