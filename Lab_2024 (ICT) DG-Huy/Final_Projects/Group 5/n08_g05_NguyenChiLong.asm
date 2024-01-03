.data
inputMessage: .asciiz "Nhap chuoi ki tu : "
outputDisk: .asciiz "     Disk 1                Disk 2                Disk 3\n"
outputLine: .asciiz " --------------        --------------        --------------\n"
s: .space 1001
hex: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' 
errorMessage: .asciiz "Error: Length of the string must be divisible by 8\n"
.text
main:
input:
	li $v0, 4
	la $a0, inputMessage
	syscall
	li $v0, 8
	la $a0, s
	li $a1, 1001
	syscall
	
# $s0: size of string s
	la $t0, s
	li $s0, 0
check_length_loop:
	lb $t1, ($t0)
	beq $t1, 10, after_check_length_loop
	add $t0, $t0, 1
	add $s0, $s0, 1
	j check_length_loop
	
after_check_length_loop:
	rem $t0, $s0, 8
	beq $t0, $zero, valid_string
	li $v0, 4
	la $a0, errorMessage
	syscall
	j input
valid_string:
	li $v0, 4
	la $a0, outputDisk
	syscall
	li $v0, 4
	la $a0, outputLine
	syscall
	
# $t2, $t3, $t4, $t5: xors of 4 pairs
	la $t0, s
	li $t1, 0 
print_disk_memory_loop:
	beq $t1, $s0, after_print_disk_memory_loop
	
	lb $t6, 0($t0)
	lb $t7, 4($t0)
	xor $t2, $t6, $t7
	
	lb $t6, 1($t0)
	lb $t7, 5($t0)
	xor $t3, $t6, $t7
	
	lb $t6, 2($t0)
	lb $t7, 6($t0)
	xor $t4, $t6, $t7

	lb $t6, 3($t0)
	lb $t7, 7($t0)
	xor $t5, $t6, $t7
	
	rem $t6, $t1, 24
	beq $t6, 0, print_8_char1
	beq $t6, 8, print_8_char2
	beq $t6, 16, print_8_char3

# these print_8_char functions are used to print 3 types of 8-bit storage
print_8_char1:
	li $v0, 11
	li $a0, 124
	syscall
	jal print_5_spaces
	lb $t7, 0($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 1($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 2($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 3($t0)
	add $a0, $t7, $zero
	syscall
	jal print_5_spaces
	li $a0, 124
	syscall
	
	jal print_6_spaces
	
	li $a0, 124
	syscall
	jal print_5_spaces
	lb $t7, 4($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 5($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 6($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 7($t0)
	add $a0, $t7, $zero
	syscall
	jal print_5_spaces
	li $a0, 124
	syscall
	
	jal print_6_spaces
	
	li $a0, 91
	syscall
	li $a0, 91
	syscall
	
	li $a0, 32
	syscall
	
	srl $s2, $t2, 4
	and $s3, $t2, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t3, 4
	and $s3, $t3, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t4, 4
	and $s3, $t4, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t5, 4
	and $s3, $t5, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 93
	syscall
	li $a0, 93
	syscall
	
	li $a0, 10
	syscall
	j after_print_8_char	
	
print_8_char2:
	li $v0, 11
	li $a0, 124
	syscall
	jal print_5_spaces
	lb $t7, 0($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 1($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 2($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 3($t0)
	add $a0, $t7, $zero
	syscall
	jal print_5_spaces
	li $a0, 124
	syscall
	
	jal print_6_spaces
	
	li $a0, 91
	syscall
	li $a0, 91
	syscall
	
	li $a0, 32
	syscall
	
	srl $s2, $t2, 4
	and $s3, $t2, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t3, 4
	and $s3, $t3, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t4, 4
	and $s3, $t4, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t5, 4
	and $s3, $t5, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 93
	syscall
	li $a0, 93
	syscall
	
	jal print_6_spaces
	
	li $a0, 124
	syscall
	jal print_5_spaces
	lb $t7, 4($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 5($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 6($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 7($t0)
	add $a0, $t7, $zero
	syscall
	jal print_5_spaces
	li $a0, 124
	syscall
	
	li $a0, 10
	syscall
	j after_print_8_char	
	
print_8_char3:
	
	li $a0, 91
	syscall
	li $a0, 91
	syscall
	
	li $a0, 32
	syscall
	
	srl $s2, $t2, 4
	and $s3, $t2, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t3, 4
	and $s3, $t3, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t4, 4
	and $s3, $t4, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 44
	syscall
	
	srl $s2, $t5, 4
	and $s3, $t5, 0x0000000f
	
	lb $s4, hex($s2)
	move $a0, $s4
	syscall
	lb $s4, hex($s3)
	move $a0, $s4
	syscall
	
	li $a0, 93
	syscall
	li $a0, 93
	syscall
	
	jal print_6_spaces
	
	
	li $v0, 11
	li $a0, 124
	syscall
	jal print_5_spaces
	lb $t7, 0($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 1($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 2($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 3($t0)
	add $a0, $t7, $zero
	syscall
	jal print_5_spaces
	li $a0, 124
	syscall
	
	jal print_6_spaces
	
	li $a0, 124
	syscall
	jal print_5_spaces
	lb $t7, 4($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 5($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 6($t0)
	add $a0, $t7, $zero
	syscall
	lb $t7, 7($t0)
	add $a0, $t7, $zero
	syscall
	jal print_5_spaces
	li $a0, 124
	syscall
	
	li $a0, 10
	syscall
	j after_print_8_char	
	
after_print_8_char:
	add $t0, $t0, 8
	add $t1, $t1, 8
	j print_disk_memory_loop

after_print_disk_memory_loop:
	li $v0, 4
	la $a0, outputLine
	syscall
	li $v0, 10
	syscall

print_5_spaces:
    li $s1, 0       # Initialize loop counter

print_5_spaces_loop:
    beq $s1, 5, print_5_spaces_end  # Exit loop when counter reaches 5
    la $a0, 32  # Load address of space character
    syscall         # Print the space
    addi $s1, $s1, 1  # Increment counter
    j print_5_spaces_loop           # Jump back to the beginning of the loop

print_5_spaces_end:
    jr $ra          # Return from the function
    
print_6_spaces:
    li $s1, 0       # Initialize loop counter

print_6_spaces_loop:
    beq $s1, 6, print_6_spaces_end  # Exit loop when counter reaches 5
    la $a0, 32  # Load address of space character
    syscall         # Print the space
    addi $s1, $s1, 1  # Increment counter
    j print_6_spaces_loop           # Jump back to the beginning of the loop

print_6_spaces_end:
    jr $ra          # Return from the function
