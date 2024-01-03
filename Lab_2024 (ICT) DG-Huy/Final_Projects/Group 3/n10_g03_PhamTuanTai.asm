.eqv IN_ADDRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 	0xFFFF0014
.eqv SEVENSEG_LEFT 0xFFFF0011		 # left LED
.eqv SEVENSEG_RIGHT 0xFFFF0010 		 # right LED

.data
	zero:  .byte 0x3f
	one:   .byte 0x6
	two:   .byte 0x5b
	three: .byte 0x4f
	four:  .byte 0x66
	five:  .byte 0x6d
	six:   .byte 0x7d
	seven: .byte 0x7
	eight: .byte 0x7f
	nine:  .byte 0x6f
	mess1:  .asciiz "Cannot calculate negative numbers \n"
	mess2: .asciiz "Cannot divide by zero \n"

.text
main:
	li $t0,SEVENSEG_LEFT     	 # $t0: value of left LED
        li $t5,SEVENSEG_RIGHT     	 # $t1: value of right LED
        li $s0,0      			 # check input 0: number, 1: operation
        li $s1,0     			 # number displayed in left LED
        li $s2,0   			 # number displayed in right LED
        li $s3,0     			 # representing operation: 1:add, 2:sub, 3:mul, 4:div, 5: mod
        li $s4,0      			 # first num
        li $s5,0   			 # second num
        li $s6,0     			 # result
	#---------------------------------------------------------
	li $t1, IN_ADDRESS_HEXA_KEYBOARD  
	li $t2, OUT_ADDRESS_HEXA_KEYBOARD 
	li $t3, 0x80			  #enable keyboard interrupt 
	sb  $t3, 0($t1)
	li $t7,0       			  #the value of displaying number
	li $t4,0			  #byte for displaying on LED (1->9)
storefirstvalue:
	li $t7,0        		  #first display bit
	addi $sp,$sp,4			  #push to stack
        sb $t7,0($sp)	
	lb $t4,zero 			  #first displaying bit
	addi $sp,$sp,4  		  #push to stack
        sb $t4,0($sp)
loop1:
	nop
	nop
	nop
	nop
	b loop1
end_main:
	li $v0,10
	syscall
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
process:
	jal checkrow1			#check rows if there is key press
	bnez $t3,convertrow1		#t3 != 0 --> key pressed convert to led
	nop
	jal checkrow2
	bnez $t3,convertrow2
	nop
	jal checkrow3
	bnez $t3,convertrow3
	nop
	jal checkrow4
	bnez $t3,convertrow4
checkrow1:
	addi $sp,$sp,4
        sw $ra,0($sp) 
        li $t3,0x81     	# enable interrupt
        sb $t3,0($t1)
        jal getvalue		# get the position ( col and row ) if pressed
        lw $ra,0($sp)
        addi $sp,$sp,-4
        jr $ra
checkrow2:
	addi $sp,$sp,4
        sw $ra,0($sp) 
	li $t3,0x82     	# enable interrupt for row 2
        sb $t3,0($t1)
        jal getvalue
        lw $ra,0($sp)
        addi $sp,$sp,-4
        jr $ra
checkrow3:
	addi $sp,$sp,4
        sw $ra,0($sp) 
	li $t3,0x84     	# enable interrupt for row 3
        sb $t3,0($t1)
        jal getvalue
        lw $ra,0($sp)
        addi $sp,$sp,-4
        jr $ra
checkrow4:
	addi $sp,$sp,4
        sw $ra,0($sp) 
	li $t3,0x88     	# enable interrupt for row 4
        sb $t3,0($t1)
        jal getvalue
        lw $ra,0($sp)
        addi $sp,$sp,-4
        jr $ra
getvalue:
	addi $sp,$sp,4
        sw $ra,0($sp) 
        li $t2,OUT_ADDRESS_HEXA_KEYBOARD  #adress contains position of the key pressed
        lb $t3,0($t2)			  #load
        lw $ra,0($sp)
        addi $sp,$sp,-4
        jr $ra
convertrow1:			#convert from position to number
	beq $t3,0x11,case_zero			#0x11 -->row 1 col 1--> 0
	beq $t3,0x21,case_one
	beq $t3,0x41,case_two
	beq $t3,0xffffff81,case_three
case_zero:
	lb $t4,zero		#convert
	li $t7,0		#t7= t4
	j done
case_one:
	lb $t4,one
	li $t7,1
	j done
case_two:
	lb $t4,two
	li $t7,2
	j done
case_three:
	lb $t4,three
	li $t7,3
	j done
convertrow2:
	beq $t3,0x12,case_four
	beq $t3,0x22,case_five
	beq $t3,0x42,case_six
	beq $t3,0xffffff82,case_seven
case_four:
	lb $t4,four
	li $t7,4
	j done
case_five:
	lb $t4,five
	li $t7,5
	j done
case_six:
	lb $t4,six
	li $t7,6
	j done
case_seven:
	lb $t4,seven
	li $t7,7
	j done
convertrow3:
	beq $t3,0x14,case_eight
	beq $t3,0x24,case_nine
	beq $t3 0x44,case_a
	beq $t3 0xffffff84,case_b
case_eight:
	lb $t4,eight
	li $t7,8
	j done
case_nine:
	lb $t4,nine
	li $t7,9
	j done
case_a:	#addition
	addi $a3,$zero,1
	addi $s0,$s0,1          #check variable turns to 1 (operator)
	bne $s3,0,setnextoperator
	addi $s3,$zero,1	#operator type =  1(addition)
	
	j setfirstnumber        #convert 2 byte that are being displayed on 2 led to number to calculate 
case_b: #subtraction
	addi $a3,$zero,2
	addi $s0,$s0,1
	bne $s3,0,setnextoperator
	addi $s3,$zero,2
	j setfirstnumber
convertrow4:
	beq $t3,0x18,case_c
	beq $t3,0x28,case_d
	beq $t3,0x48,case_e
	beq $t3 0xffffff88,case_f
case_c: #multiplication
	addi $a3,$zero,3
	addi $s0,$s0,1
	bne $s3,0,setnextoperator
	addi $s3,$zero,3
	j setfirstnumber	
case_d: #division
	addi $a3,$zero,4
	addi $s0,$s0,1
	bne $s3,0,setnextoperator
	addi $s3,$zero,4
	j setfirstnumber

case_e: #modular
	addi $a3, $zero, 5
	addi $s0, $s0, 1
	bne $s3, 0, setnextoperator
	addi $s3, $zero, 5
	j setfirstnumber


setfirstnumber:       		# calculate the displaying value
	mul $s4,$s2,10		# s4=s2*10+s1
	add $s4,$s4,$s1
	j done

case_f:  #press =
setsecondnumber:  #calculate second number that displaying
	mul $s5,$s2,10         # s5=s2*10+s1
	add $s5,$s5,$s1
	beq $s3,1,addition         # s3=1--> addition
	beq $s3,2,subtraction
	beq $s3,3,multiplication
	beq $s3,4,division
	beq $s3, 5, modular
addition:
	add $s6,$s5,$s4
	li $s3,0
	j printadd
	nop     		# s6=s5+s4
	
printadd:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '+'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	li $s7,100
	div $s6,$s7
	mfhi $s6	    # only takes 2 last digit of result to led
	j splitnumber       # split to display on LED
	nop
	
subtraction:
	sub $s6,$s4,$s5    # s6=s4-s5
	li $s3,0
	blt $s6,0,subneg
	j printsub
	nop
printsub:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '-'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	j splitnumber      
	nop
multiplication:
	mul $s6,$s4,$s5     # s6=s4*s5
	li $s3,0
	j printmul
	nop
printmul:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '*'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	li $s7,100
	div $s6,$s7
	mfhi $s6	    # chi lay 2 chu so sau cùng cua ket qua in ra
	j splitnumber       # chuyen den ham chia ket qua thanh 2 chu so de hien thi len tung led
	nop
division:
	beq $s5,0,div0
	li $s3,0
	div $s4,$s5   	    # s6=s4/s5
	mflo $s6
	mfhi $s7
	j printdiv
	nop
printdiv:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '/'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 11
	li $a0, 'r'
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s7
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	j splitnumber       
	nop
modular:
	beq $s5,0,div0
	li $s3,0
	div $s4,$s5   	    # s6=s4/s5
	mfhi $s6
	j printmod
	nop
printmod:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '%'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	j splitnumber       
	nop
div0: 
	li $v0, 55
	la $a0, mess2
	li $a1, 0
	syscall
	j resetled
subneg:
	li $v0, 55
	la $a0, mess1
	li $a1, 0
	syscall
	j resetled

splitnumber:	#split the last 2 digits to display on each LED
	li $t8,10
	div $s6,$t8    #s6/10
	mflo $t7       #t7 = result
	jal convert    #convert number to LED
        #---------
        sb $t4,0($t0)  # left LED
     	add $sp,$sp,4
	sb $t7,0($sp)	    #push to stack
	add $sp,$sp,4
	sb $t4,0($sp)       #push to stack
	add $s2,$t7,$zero   #s1 = value of left LED
      
	#----------
	mfhi $t7       #t7= remainder
	jal convert    
        sb $t4,0($t5)  #right LED
       	add $sp,$sp,4
	sb $t7,0($sp)	    #push to stack
	add $sp,$sp,4
	sb $t4,0($sp)       #push to stack
	add $s1,$t7,$zero   #s1 = value of left LED
        j resetled     
convert:
	addi $sp,$sp,4
        sw $ra,0($sp)
        beq $t7,0,case_0   
        beq $t7,1,case_1
        beq $t7,2,case_2
        beq $t7,3,case_3
        beq $t7,4,case_4
        beq $t7,5,case_5
        beq $t7,6,case_6
        beq $t7,7,case_7
        beq $t7,8,case_8
        beq $t7,9,case_9
case_0:	
	lb $t4,zero    #t4=zero
	j finishconvert
case_1:
	lb $t4,one
	j finishconvert
case_2:
	lb $t4,two
	j finishconvert
case_3:
	lb $t4,three
	j finishconvert
case_4:
	lb $t4,four
	j finishconvert
case_5:
	lb $t4,five
	j finishconvert
case_6:
	lb $t4,six
	j finishconvert
case_7:
	lb $t4,seven
	j finishconvert
case_8:
	lb $t4,eight
	j finishconvert
case_9:
	lb $t4,nine
	j finishconvert
finishconvert:
	lw $ra,0($sp)
	addi $sp,$sp,-4
	jr $ra
done:
	beq $s0,1,resetled   #s0=1-->operator-->reset led
loadtoleftled:   # display left LED
	lb $t6,0($sp)       #load from stack
	add $sp,$sp,-4
	lb $t8,0($sp)       
	add $sp,$sp,-4      
	add $s2,$t8,$zero   #s2 = value of left LED
	sb $t6,0($t0)       # display
loadtorightled:
	sb $t4,0($t5)      
	add $sp,$sp,4
	sb $t7,0($sp)	    
	add $sp,$sp,4
	sb $t4,0($sp)       
	add $s1,$t7,$zero   #s1 = value of right LED
	j finish            
resetled:
	li $s0,0           #s0=0--> wait for next number
        li $t8,0
	addi $sp,$sp,4
        sb $t8,0($sp)
        lb $t6,zero        # push zero
	addi $sp,$sp,4
        sb $t6,0($sp)
finish:
	j end_exception
	nop
end_exception:
	# return to start of the loop instead of where the interrupt occur, since the loop doesn't do meaningful thing
	la $a3, loop1
	mtc0 $a3, $14
	eret
setnextoperator:
setsecondnumber1:  #find second number
	mul $s5,$s2,10         # s5=s2*10+s1
	add $s5,$s5,$s1
	beq $s3,1,add1         # s3=1--> addition
	beq $s3,2,sub1
	beq $s3,3,mul1
	beq $s3,4,div1
	beq $s3,5,mod1
add1:
	add $s6,$s5,$s4
	j printadd1
	nop     		# s6=s5+s4
	
printadd1:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '+'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	li $s7,100
	div $s6,$s7
	mfhi $s6	    # chi lay 2 chu so cuoi cua ket qua de in ra led
	j splitnumber1       # chuyen den ham chia ket qua thanh 2 chu so de hien thi len tung led
	nop
	
sub1:
	sub $s6,$s4,$s5    # s6=s4-s5
	blt $s6,0,subneg1
	j printsub1
	nop
printsub1:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '-'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	j splitnumber1       # chuyen den ham chia ket qua thanh 2 chu so de hien thi len tung led
	nop
mul1:
	mul $s6,$s4,$s5     # s6=s4*s5
	j printmul1
	nop
printmul1:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '*'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	li $s7,100
	div $s6,$s7
	mfhi $s6	    # chi lay 2 chu so sau cùng cua ket qua in ra
	j splitnumber1       # chuyen den ham chia ket qua thanh 2 chu so de hien thi len tung led
	nop
div1:
	beq $s5,0,div01
	div $s4,$s5   	    # s6=s4/s5
	mflo $s6
	mfhi $s7
	j printdiv1
	nop
printdiv1:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '/'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
	
	li $v0, 11
	li $a0, ' '
	syscall
	
	li $v0, 11
	li $a0, 'r'
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s7
	syscall
	
	li $v0, 11
	li $a0, '\n'
	syscall
	j splitnumber1       # chuyen den ham chia ket qua thanh 2 chu so de hien thi len tung led
	nop
mod1:
	beq $s5,0,div01
	div $s4,$s5   	    # s6=s4/s5
	mfhi $s6
	j printmod1
	nop
printmod1:
	li $v0, 1
	move $a0, $s4
	syscall
	
	li $v0, 11
	li $a0, '%'
	syscall
	
	li $v0, 1
	move $a0, $s5
	syscall
	
	li $v0, 11
	li $a0, '='
	syscall
	
	li $v0, 1
	move $a0, $s6
	syscall
div01: 
	li $v0, 55
	la $a0, mess2
	li $a1, 0
	syscall
	j resetled1
subneg1:
	li $v0, 55
	la $a0, mess1
	li $a1, 0
	syscall
	j resetled1
splitnumber1:	#divide the result into 2 digit to display
	li $t8,10
	div $s6,$t8    #s6/10
	mflo $t7       #t7 = result
	jal convert1  
        #---------
     	add $sp,$sp,4
	sb $t7,0($sp)	    #push to stack
	add $sp,$sp,4
	sb $t4,0($sp)       #push to stack
	add $s2,$t7,$zero   
      
	#----------
	mfhi $t7       
	jal convert1   
       	add $sp,$sp,4
	sb $t7,0($sp)	    
	add $sp,$sp,4
	sb $t4,0($sp)       
	add $s1,$t7,$zero   
        j resetled1    
convert1:
	addi $sp,$sp,4
        sw $ra,0($sp)
        beq $t7,0,case_01    
        beq $t7,1,case_11
        beq $t7,2,case_21
        beq $t7,3,case_31
        beq $t7,4,case_41
        beq $t7,5,case_51
        beq $t7,6,case_61
        beq $t7,7,case_71
        beq $t7,8,case_81
        beq $t7,9,case_91
case_01:	#ham chuyen 0 thanh bit zero hien thi len led
	lb $t4,zero    #t4=zero
	j finishconvert1 #ket thuc
case_11:
	lb $t4,one
	j finishconvert1
case_21:
	lb $t4,two
	j finishconvert1
case_31:
	lb $t4,three
	j finishconvert1
case_41:
	lb $t4,four
	j finishconvert1
case_51:
	lb $t4,five
	j finishconvert1
case_61:
	lb $t4,six
	j finishconvert1
case_71:
	lb $t4,seven
	j finishconvert1
case_81:
	lb $t4,eight
	j finishconvert1
case_91:
	lb $t4,nine
	j finishconvert1
finishconvert1:
	lw $ra,0($sp)
	addi $sp,$sp,-4
	jr $ra
done1:
	beq $s0,1,resetled1
resetled1:
	li $s0,0           
        li $t8,0
	addi $sp,$sp,4
        sb $t8,0($sp)
        lb $t6,zero       
	addi $sp,$sp,4
        sb $t6,0($sp)
        mul $s4,$s2,10		# s4=s2*10+s1
	add $s4,$s4,$s1
	beq $a3,1,setadd
	nop
	beq $a3,2,setsub
	nop
	beq $a3,3,setmul
	nop
	beq $a3,4,setdiv
	nop
	beq $a3,5, setmod
	nop
setadd: addi $s3,$zero,1
	j finish1
	nop
setsub: addi $s3,$zero,2
	j finish1
	nop
setmul: addi $s3,$zero,3
	j finish1
	nop
setdiv: addi $s3,$zero,4
	j finish1
	nop
setmod: addi $s3, $zero, 5
	j finish1
	nop
        
finish1:
	j end_exception1
	nop
end_exception1:
	la $a3, loop1
	mtc0 $a3, $14
	eret
