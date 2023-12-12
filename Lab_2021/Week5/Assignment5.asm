#Laboratory Exercise 5, Assignment 5
.data
	get_char: .space 20
	message1: .asciiz "Nhap ky tu thu "
	message2: .asciiz ": "
	message3: .asciiz "\n"
	message4: .asciiz "Chuoi ky tu vua nhap la: "
	
.text
    	li $s0, 20	  	# N = 20
    	li $s1, 0		# i = 0
	la $s2, get_char  	# Load address of get_char[0]
	li $s3, 10  		# Char \n in ASCII

read_char:	
	beq $s1, $s0, end_read_char # i = N branch to exit
	
	# Show message "Nhap ky tu thu i: "
	li $v0, 4
	la $a0, message1 
	syscall
	
	addi $t1, $s1, 1
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, message2
	syscall
	
    	li $v0, 12	# Read character
    	syscall
    	move $t0, $v0
    	beq $t0, $s3, end_read_char # Press "Enter" branch to exit
    	
    	li $v0, 4
    	la $a0, message3
    	syscall
    	
	add $s5, $s2, $s1	# $s5 = Address of get_char[i] = get_char[0] + i
	sb $t0, 0($s5)		# Store character to get_char[i]
	addi $s1, $s1, 1    	# i++
	j read_char
end_read_char:
	li $v0, 4
	la $a0, message4
	syscall
print_string:
	li $v0, 11
	lb $a0, 0($s5)
	syscall
	
	beq $s5, $s2, exit
	addi $s5, $s5, -1
	j print_string
exit:
	li $v0, 10
	syscall
