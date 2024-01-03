.eqv	SEVENSEG_LEFT	0xFFFF0011	# Address of the LEFT LED				
.eqv	SEVENSEG_RIGHT	0xFFFF0010	# Address of the RIGHT LED
.eqv 	IN_ADDRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv 	OUT_ADDRESS_HEXA_KEYBOARD 	0xFFFF0014

.data
# Values corresponding to LED digits
zero:  		.byte 0x3f
one:   		.byte 0x6
two:   		.byte 0x5b
three: 		.byte 0x4f
four:  		.byte 0x66
five:  		.byte 0x6d
six:   		.byte 0x7d
seven: 		.byte 0x7
eight: 		.byte 0x7f
nine:  		.byte 0x6f

mess1: 	.asciiz 	"Can not divide by 0!\n"

.text
main:

Init:
	li 	$t0, SEVENSEG_LEFT     	# Variable contains value of the LEFT LED
        li 	$t5, SEVENSEG_RIGHT    # Variable contains value of the RIGHT LED
        li 	$s0, 0      		# Variable contains type of input: (0: digit), (1: operand)
        li 	$s1, 0     		# Variable on the LEFT LED
        li 	$s2, 0   		# Variable on the RIGHT LED
        li 	$s3, 0     		# Variable contains type of operand (1: +, 2: -, 3: *, 4: /, 5: %)
        li 	$s4, 0      		# The first number
        li 	$s5, 0   		# The second number
        li 	$s6, 0     		# Result
        li 	$t9, 0 			# Temp value
	
	li 	$t1, IN_ADDRESS_HEXA_KEYBOARD  	# Variable contronls keyboard rows and enable keyboard interrupt
	li 	$t2, OUT_ADDRESS_HEXA_KEYBOARD 	# Variable contains key locations
	li 	$t3, 0x80			# bit used to enable keyboard interrupt and enable check each keyboard row
	sb 	$t3, 0($t1)
	li 	$t7, 0       		# Variable contains value of number on the LED
	li 	$t4, 0			# Byte showed on LED (0->9)
	
First_value:
	li 	$t7, 0        		# Value of needed to be showed initial bit
	addi 	$sp,$sp, 4		# Push to stack
        sb 	$t7, 0($sp)	
	lb 	$t4, zero 		# First bit to be showed
	addi 	$sp, $sp, 4  		# Push to stack
        sb 	$t4, 0($sp)

Loop1:
	nop
	nop
	nop
	nop
	b 	Loop1		# Wait for interrupt
	nop
	nop
	nop
	nop
	b 	Loop1		
	nop
	nop
	nop
	nop
	b 	Loop1		
end_loop1:

# Handle interrupt
# -> Show clicked key on the LED
# Check each row for clicked row
end_main:
	li 	$v0, 10
	syscall
	
	
.ktext 0x80000180
# If row contains clicked key
# -> Move to that row
	jal 	check_row1		# Check row 1
	bnez 	$t3, convert_row1	# t3 != 0 -> clicked key, find clicked key on the row -> exstract that key
	nop
	
	jal 	check_row2		# The same go to row 2...
	bnez 	$t3, convert_row2	
	nop
	
	jal 	check_row3		
	bnez 	$t3, convert_row3	
	nop
	
	jal 	check_row4		
	bnez 	$t3, convert_row4	
	
# Functions check for clicked key on the row or not
check_row1:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 		# Store -> can be changed
        li 	$t3, 0x81     		# Execute interrupt
        sb 	$t3, 0($t1)
        jal 	Get_value		# Get location of clicked key (if existed)
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

check_row2:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 		
        li 	$t3, 0x82   		
        sb 	$t3, 0($t1)
        jal 	Get_value		
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

check_row3:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 		
        li 	$t3, 0x84     		
        sb 	$t3, 0($t1)
        jal 	Get_value		
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

check_row4:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 		
        li 	$t3, 0x88     		
        sb 	$t3, 0($t1)
        jal 	Get_value		
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

# Exstract the value of clicked key
Get_value:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 
        li 	$t2, OUT_ADDRESS_HEXA_KEYBOARD 	# Address containing location of clicked key
        lb 	$t3, 0($t2)			# Load the location
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

# Convert from location -> value of the LED
convert_row1:	
	beq 	$t3, 0x11, case_0		# Digit 0
	beq 	$t3, 0x21, case_1		# Digit 1
	beq 	$t3, 0x41, case_2		# Digit 2
	beq 	$t3, 0xffffff81, case_3		# Digit 3
case_0:
	lb 	$t4,zero	# t4 = 0, value of '0" on Digital Lab Sim
	li 	$t7,0		# t7 = 0
	j 	update_tg
case_1:
	lb 	$t4,one		# So on
	li 	$t7,1		
	j 	update_tg
case_2:
	lb	$t4,two		
	li 	$t7,2		
	j	update_tg
case_3:
	lb 	$t4, three	
	li 	$t7, 3		
	j 	update_tg


convert_row2:	
	beq 	$t3, 0x12, case_4		
	beq 	$t3, 0x22, case_5		
	beq 	$t3, 0x42, case_6		
	beq 	$t3, 0xffffff82, case_7		
case_4:
	lb 	$t4, four	
	li 	$t7, 4		
	j 	update_tg
case_5:
	lb 	$t4, five	
	li 	$t7, 5		
	j 	update_tg
case_6:
	lb	$t4, six	
	li 	$t7,6		
	j	update_tg
case_7:
	lb 	$t4, seven	
	li 	$t7, 7		
	j 	update_tg


convert_row3:	
	beq 	$t3, 0x14, case_8		
	beq 	$t3, 0x24, case_9		
	beq 	$t3, 0x44, case_a		
	beq 	$t3, 0xffffff84, case_b		
case_8:
	lb 	$t4, eight	
	li 	$t7, 8		
	j 	update_tg
case_9:
	lb 	$t4, nine	
	li 	$t7, 9		
	j 	update_tg

# Case a: addition
case_a:	
	addi 	$a3, $zero, 1
	addi 	$s0, $s0, 1          	# s0 = 1, entered operand
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 1		# s3 = 1 -> addition
	
	j 	set_first_number        # Move to fucntion converting showed number on LED -> compute
	
case_b:
	addi 	$a3, $zero, 2
	addi 	$s0, $s0, 1		
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 2		# s3 = 2 -> substraction
	j 	set_first_number


convert_row4:	
	beq 	$t3, 0x18, case_c		
	beq 	$t3, 0x28, case_d		
	beq 	$t3, 0x48, case_e		
	beq 	$t3, 0xffffff88, case_f		
	
case_c:	
	addi 	$a3, $zero, 3
	addi 	$s0, $s0, 1          	
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 3		
	
	j set_first_number        	
	
case_d:
	addi 	$a3, $zero, 4
	addi 	$s0, $s0, 1		
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 4		
	j 	set_first_number

case_e:	
	addi 	$a3, $zero, 5
	addi 	$s0, $s0, 1          	
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 5		
	j 	set_first_number        
	
# Convert the number on LED -> value of the first number
set_first_number:      
	addi 	$s4, $t9, 0
	li 	$t9, 0
	j 	done

# Case f:
case_f: 
	addi $s5, $t9, 0
	
# Convert the number on LED -> value of the second number
set_second_number:  
	beq 	$s3, 1, addition	
	beq 	$s3, 2, substraction	
	beq 	$s3, 3, multiplication	
	beq 	$s3, 4, division	
	beq	$s3, 5, find_remainder	

addition:
	add 	$s6, $s5, $s4
	li 	$s3, 0
	li 	$t9, 0 
	j 	print_addition
	nop     		

print_addition:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		# reset the first number to 0
	
	li 	$v0, 11
	li 	$a0, '+'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		# Reset the second number to 0
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	nop
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	# Exstract 2 last digit of the result
	j show_result_in_led	# Show it
	nop

substraction:
	sub 	$s6, $s4, $s5   
	li 	$s3, 0
	li 	$t9, 0 
	j 	print_substraction
	nop
	
print_substraction:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '-'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		
	
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6		    	
	j 	show_result_in_led	
	nop

multiplication:
	mul 	$s6, $s4, $s5    
	li 	$s3, 0
	li 	$t9, 0 
	j 	print_multiplication
	nop
	
print_multiplication:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '*'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		
	
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	
	j show_result_in_led    
	nop

division:
	beq 	$s5, 0, divide_by_0	
	li 	$s3, 0
	div 	$s4, $s5   	    
	mflo 	$s6
	mfhi 	$s7
	li 	$t9, 0 
	j 	print_division
	nop

divide_by_0: 
	li 	$v0, 55
	la 	$a0, mess1
	li 	$a1, 0
	syscall
	j 	reset_led

print_division:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '/'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		
	
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
		
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6		    	
	j 	show_result_in_led	
	nop


find_remainder:
	beq 	$s5, 0, find_remainder_0	
	li 	$s3, 0
	div 	$s4, $s5   	    
	mflo 	$s7
	mfhi 	$s6
	li 	$t9, 0 
	j 	print_find_remainder
	nop

find_remainder_0: 
	li 	$v0, 55
	la 	$a0, mess1
	li 	$a1, 0
	syscall
	j 	reset_led

print_find_remainder:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '%'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
		
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6		    	
	j 	show_result_in_led	
	nop

# Show result on the LED
# Number 'ab'
# LEFT LED = a = ab div 10
# RIGHT LED = b = ab mod 10
show_result_in_led:
	li 	$t8, 10			# Immediate value = 10
	div 	$s6, $t8    		# s6 = a
	mflo 	$t7        		# t7 = result
	jal 	check    		# Move to function converting result in t7 to LED

        sb 	$t4, 0($t0)  		# Show on LEFT LED
     	add 	$sp, $sp, 4
	sb 	$t7, 0($sp)		# Push to stack
	add 	$sp, $sp, 4
	sb 	$t4, 0($sp)    		# Push to stack
	add 	$s2, $t7, $zero   	# s2 = value of LEFT LED
	
	mfhi 	$t7       	# t7 = remainder
	jal 	check    	# Converting t7 to LED
        sb 	$t4, 0($t5)  	# Show LED RIGHT
       	add 	$sp, $sp, 4
	sb 	$t7, 0($sp)	# Push to stack
	add 	$sp, $sp, 4
	sb 	$t4, 0($sp)    	# Push to stack
	add 	$s1, $t7, $zero	# s1 = value of RIGHT LED
        j 	reset_led     	# Reset LED
           
check:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp)
        beq 	$t7, 0, check_0		# Show '0' on the LED
        beq 	$t7, 1, check_1	   	
        beq 	$t7, 2, check_2		
        beq 	$t7, 3, check_3		
        beq 	$t7, 4, check_4		
        beq 	$t7, 5, check_5		
        beq 	$t7, 6, check_6		
        beq 	$t7, 7, check_7		
        beq 	$t7, 8, check_8		
        beq 	$t7, 9, check_9		
        
check_0:	
	lb 	$t4, zero    
	j 	finish_check
check_1:
	lb 	$t4, one
	j 	finish_check
check_2:
	lb 	$t4, two
	j 	finish_check
check_3:
	lb 	$t4, three
	j	finish_check
check_4:
	lb 	$t4, four
	j 	finish_check
check_5:
	lb 	$t4, five
	j 	finish_check
check_6:
	lb 	$t4, six
	j 	finish_check
check_7:
	lb 	$t4, seven
	j 	finish_check
check_8:
	lb 	$t4, eight
	j 	finish_check
check_9:
	lb 	$t4, nine
	j 	finish_check	

finish_check:
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, -4
	jr 	$ra

update_tg:			
	 mul 	$t9, $t9, 10
	 add 	$t9, $t9, $t7

# Showed one number -> reset LED
done:
	beq $s0,1,reset_led   # s0 = 1 -> operand -> reset LED
	nop

# Function showing LEFT LED
load_to_left_led: 
	lb 	$t6, 0($sp)       # Load bit from stack
	add 	$sp, $sp, -4
	lb 	$t8, 0($sp)       # Load value of that bit
	add 	$sp, $sp, -4      
	add 	$s2, $t8, $zero   # s2 = value of LEFT LED
	sb 	$t6, 0($t0)       # Show LEFT LED

# Function showing RIGHT LED
load_to_right_led:	
	sb 	$t4, 0($t5)       # Same
	add 	$sp, $sp,4
	sb 	$t7, 0($sp)	  
	add 	$sp, $sp,4
	sb 	$t4, 0($sp)       
	add 	$s1, $t7, $zero   
	j 	finish            

reset_led:
	li 	$s0, 0           
        li 	$t8, 0
	addi 	$sp, $sp, 4
        sb 	$t8, 0($sp)
        lb 	$t6, zero        
	addi 	$sp, $sp, 4
        sb 	$t6, 0($sp)
finish:
	j 	return
	nop



return:
	la 	$a3, Loop1
	mtc0 	$a3, $14
	eret

set_next_operator:


# Compute second number
set_second_number1: 
	addi 	$s5, $t9, 0
	beq 	$s3, 1, addition_1         	
	beq 	$s3, 2, substraction_1		
	beq 	$s3, 3, multiplication_1		
	beq 	$s3, 4, division_1		
	beq	$s3, 5, find_remainder_1		

addition_1:
	add 	$s6, $s5, $s4
	li 	$s3, 0
	li 	$t9, 0 
	j 	print_addition_1
	nop     		

print_addition_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '+'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	nop
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	# Exstract 2 last digit of the result
	j show_result_in_led_1	# Show on LED
	nop

substraction_1:
	sub 	$s6, $s4, $s5   
	li 	$s3, 0
	li 	$t9, 0 
	j 	print_substraction_1
	nop
	
print_substraction_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '-'
	syscall
	li 	$s5, 0		
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 55
	li 	$a0, '\n'
	syscall
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	
	j show_result_in_led_1	
	nop

multiplication_1:
	mul 	$s6, $s4, $s5    
	li 	$s3, 0
	li 	$t9, 0 
	j 	print_multiplication_1
	nop
	
print_multiplication_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '*'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	
	j show_result_in_led_1    
	nop

division_1:
	beq 	$s5, 0, division_01
	li 	$s3, 0
	div 	$s4, $s5   	    
	mflo 	$s6
	mfhi 	$s7
	li 	$t9, 0 
	j 	print_division_1
	nop

# Handle divide by 0
division_01: 
	li 	$v0, 55
	la 	$a0, mess1
	li 	$a1, 0
	syscall
	j 	reset_led1

print_division_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '/'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	   	
	j show_result_in_led_1  
	nop

find_remainder_1:
	beq 	$s5, 0, find_remainder_01
	li 	$s3, 0
	div 	$s4, $s5   	    
	mflo 	$s7
	mfhi 	$s6
	li 	$t9, 0 
	j 	print_find_remainder_1
	nop

# Handle divide by 0
find_remainder_01: 
	li 	$v0, 55
	la 	$a0, mess1
	li 	$a1, 0
	syscall
	j 	reset_led1

print_find_remainder_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '%'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s4, 0		
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
		
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6		    	
	j 	show_result_in_led_1	
	nop

show_result_in_led_1:
	li 	$t8, 10		
	div 	$s6, $t8    	
	mflo 	$t7        	
	jal 	check_l1    	
	
        sb 	$t4, 0($t0)  	
     	add 	$sp, $sp, 4
	sb 	$t7, 0($sp)	
	add 	$sp, $sp, 4
	sb 	$t4, 0($sp)       	
	add 	$s2, $t7, $zero   	

	mfhi 	$t7       	
	jal 	check_l1    	
        sb 	$t4, 0($t5)  	
       	add 	$sp, $sp, 4
	sb 	$t7, 0($sp)	
	add 	$sp, $sp, 4	
	sb 	$t4, 0($sp)     	
	add 	$s1, $t7, $zero   	
        j 	reset_led1     		
 
             
check_l1:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp)
        beq 	$t7, 0, check_01		
        beq 	$t7, 1, check_11	   	
        beq 	$t7, 2, check_21		
        beq 	$t7, 3, check_31		
        beq 	$t7, 4, check_41		
        beq 	$t7, 5, check_51		
        beq 	$t7, 6, check_61		
        beq 	$t7, 7, check_71		
        beq 	$t7, 8, check_81		
        beq 	$t7, 9, check_91		
        



check_01:	
	lb 	$t4, zero    
	j 	finish_check_1
check_11:
	lb 	$t4, one
	j 	finish_check_1
check_21:
	lb 	$t4, two
	j 	finish_check_1
check_31:
	lb 	$t4, three
	j	finish_check_1
check_41:
	lb 	$t4, four
	j 	finish_check_1
check_51:
	lb 	$t4, five
	j 	finish_check_1
check_61:
	lb 	$t4, six
	j 	finish_check_1
check_71:
	lb 	$t4, seven
	j 	finish_check_1
check_81:
	lb 	$t4, eight
	j 	finish_check_1
check_91:
	lb 	$t4, nine
	j 	finish_check_1


finish_check_1:
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, -4
	jr 	$ra

done_1:
	beq $s0,1,reset_led1   
	nop

reset_led1:
	li 	$s0, 0           
        li 	$t8, 0
	addi 	$sp, $sp, 4
        sb 	$t8, 0($sp)
        lb 	$t6, zero        
	addi 	$sp, $sp, 4
        sb 	$t6, 0($sp)
        
	beq 	$a3, 1, set_add
	nop
	
	beq 	$a3, 2, set_sub
	nop
	
	beq 	$a3, 3, set_mul
	nop
	
	beq 	$a3, 4, set_div
	nop
	
	beq	$a3, 5, set_mod
	nop
	
set_add: 
	addi 	$s3, $zero, 1
	j 	finish1
	nop
	
set_sub: 
	addi 	$s3, $zero, 2
	j 	finish1
	nop
	
set_mul: 
	addi 	$s3, $zero, 3
	j  	finish1
	nop
	
set_div: 
	addi 	$s3, $zero, 4
	j 	finish1
	nop

set_mod:
	addi	$s3, $zero, 5
	j	finish1
	nop
        
finish1:
	j return_1
	nop



return_1:
	la $a3, Init
	mtc0 $a3, $14
	eret
