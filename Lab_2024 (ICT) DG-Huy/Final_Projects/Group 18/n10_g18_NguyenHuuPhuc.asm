.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012  
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014  
.eqv SEVENSEG_LEFT 0xFFFF0011 
.eqv SEVENSEG_RIGHT 0xFFFF0010 

.data
# 7-segment display values for digits 0-9 
SEGMENT_VALUES: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x79

.text  

main:  
    li $t1, IN_ADDRESS_HEXA_KEYBOARD  
    li $t2, OUT_ADDRESS_HEXA_KEYBOARD  
    
    li $s0, 0 #s0 is first variable
    li $s1, 0 #s1 is second variable
    li $s2, 0 #s2 is unit number display code
    li $s3, 0 
    li $s4, 0 #s4 is 10- number display code
    li $s5, 0
    li $s7, 0 #s7 is the operation memory
print0:
    li $a0, 0
    j printChar
print1:
    li $a0, 1
    j printChar
print2:
    li $a0, 2
    j printChar
print3:
    li $a0, 3
    j printChar
print4:
    li $a0, 4
    j printChar
print5:
    li $a0, 5
    j printChar
print6:
    li $a0, 6
    j printChar
print7:
    li $a0, 7
    j printChar
print8:
    li $a0, 8
    j printChar
print9:
    li $a0, 9
    j printChar
    
displayReset:
    li $s0, 0
    
    li $s4, 0
    li $s2, 0
    
    lw $s5, SEGMENT_VALUES($s4)
    jal SHOW_7SEG_LEFT
    lw $s3, SEGMENT_VALUES($s2)
    jal SHOW_7SEG_RIGHT
    j cont
    
swapVar:
    la $s1, ($s0)
    j displayReset
printErr:
    li $s4, 40
    lw $s5, SEGMENT_VALUES($s4)
    jal SHOW_7SEG_LEFT
    li $s2, 40
    lw $s3, SEGMENT_VALUES($s2)
    jal SHOW_7SEG_RIGHT
    j exit
printPlus:
    li $s7, 1
    beq $s1, 0, swapVar
    add $s1, $s0, $s1
    j displayReset
printMinus:
    li $s7, 2
    beq $s1, 0, swapVar
    slt $a3, $s0, $s1
    beq $a3, 0, printErr
    sub $s1, $s1, $s0
    j displayReset
printMul:
    li $s7, 3
    beq $s1, 0, swapVar
    mul $s1, $s0, $s1
    j displayReset
printDiv:
    li $s7, 4
    beq $s1, 0, swapVar
    beq $s0, 0, printErr
    div $s1, $s0
    mflo $s1
    j displayReset
printMod:
    li $s7, 5
    beq $s1, 0, swapVar
    beq $s0, 0, printErr
    div $s1, $s0
    mfhi $s1
    j displayReset
    
Plus:
    add $s1, $s0, $s1
    li $s0, 0
    j next
Minus:
    slt $a3, $s0, $s1
    beq $a3, 0, printErr
    sub $s1, $s1, $s0
    li $s0, 0
    j next
Mul: 
    mul $s1, $s0, $s1
    li $s0, 0
    j next
Div:
    beq $s0, 0, printErr
    div $s1, $s0
    mflo $s1
    li $s0, 0
    j next
Mod:
    beq $s0, 0, printErr
    div $s1, $s0
    mfhi $s1
    li $s0, 0
    j next
    
printEq: #Get the value of s1 to screen
    li $a0, '='
    beq $s7, 1, Plus
    beq $s7, 2, Minus
    beq $s7, 3, Mul
    beq $s7, 4, Div
    beq $s7, 5, Mod
    
    next:
    li $t3, 4
    li $s6, 100
    div $s1, $s6
    mfhi $t6
    li $s6, 10
    div $t6, $s6
    mfhi $t7		# Last digit
    mflo $t6		# 10- digit
    
    # Display the 10- number
    li $t3, 4
    la $s4, ($t6)
    mul $s4, $s4, $t3
    lw $s5, SEGMENT_VALUES($s4)
    jal SHOW_7SEG_LEFT
    
    # Display the last number
    li $t3, 4              # Each element in SEGMENT_VALUES is a word (4 bytes) 
    la $s2, ($t7)	    
    mul $s2, $s2, $t3      # Multiply the last digit by 4 to get the offset 
    lw $s3, SEGMENT_VALUES($s2)
    jal SHOW_7SEG_RIGHT
    
    j cont
    

printChar:
    # Print the character
    la $s4, ($s2)
    lw $s5, SEGMENT_VALUES($s4)
    jal SHOW_7SEG_LEFT
    
    # Calculate the address offset for SEGMENT_VALUES array 
    li $t3, 4              # Each element in SEGMENT_VALUES is a word (4 bytes) 
    la $s2, ($a0)
    mul $s2, $s2, $t3      # Multiply the last digit by 4 to get the offset 
    lw $s3, SEGMENT_VALUES($s2)
    jal SHOW_7SEG_RIGHT
    
    # Load the 2 stored variables s0, s1 for calculation
    mul $s0, $s0, 10
    add $s0, $s0, $a0
    
printTerminal:
    li $v0, 34
    syscall
    j cont

SHOW_7SEG_LEFT: 
    li $t0, SEVENSEG_LEFT 
    sb $s5, 0($t0) 
    jr $ra 
    #j printTerminal
    
SHOW_7SEG_RIGHT: 
    li $t0, SEVENSEG_RIGHT 
    sb $s3, 0($t0) 
    jr $ra 
    #j printTerminal
    
print:
    # Check each possible value of $a0 and print the corresponding character
    beq $a0, 0x11, print0
    beq $a0, 0x21, print1
    beq $a0, 0x41, print2
    beq $a0, 0xffffff81, print3
    beq $a0, 0x12, print4
    beq $a0, 0x22, print5
    beq $a0, 0x42, print6
    beq $a0, 0xffffff82, print7
    beq $a0, 0x14, print8
    beq $a0, 0x24, print9
    beq $a0, 0x44, printPlus
    beq $a0, 0xffffff84, printMinus
    beq $a0, 0x18, printMul
    beq $a0, 0x28, printDiv
    beq $a0, 0x48, printMod
    beq $a0, 0xffffff88, printEq
    j printTerminal
     
loop_rows: 
        li $t3, 0x01 
        li $t4, 1 
        li $a0, 500      # sleep 500ms  
        li $v0, 32 
        syscall 
         
loop: 
        beq $t4, 5, loop_rows 
        sb $t3, 0($t1)  # must reassign expected row  
        lb $a0, 0($t2)  # read scan code of key button  
        # Print the row and scan code 

        bne $a0, 0, print 

cont: 
        # Increment row and check if all rows have been processed 
        beq $t4, 5, loop_rows 
        sll $t3, $t3, 1   # Shift left to the next row 
        addi $t4, $t4, 1 
        li $a0, 100	#sleep 50ms 
        li $v0, 32 
        syscall 
        j loop 

    # End of program 
exit:
    li $v0, 10  
    syscall 
