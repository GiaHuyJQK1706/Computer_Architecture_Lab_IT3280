.data
	start: .asciiz "Enter the string : "
	string: .space 5000
	disk1: .space 4				
	disk2: .space 4
	disk3: .space 4
	parity: .space 32
	hexa: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' 
	message: .asciiz "Do you want to try again?"
	error: .asciiz "Length is not valid! Please enter again!\n"
	disk: .asciiz "      Disk 1                 Disk 2               Disk 3\n"
	open: .asciiz "----------------       ----------------       ----------------\n"
	open_disk: .asciiz "|     "
	close_disk: .asciiz "     |       "
	open_bracket: .asciiz "[[ "
	close_bracket: .asciiz "]]       "
	comma: .asciiz ","
	newline: .asciiz "\n"
	
.text
	la 		$s1, disk1			# the address of disk 1
	la 		$s2, disk2			# the address of disk 2
	la 		$s3, disk3			# the address of disk 3
	la 		$a2, parity			# the address of parity data


	
main:	
	li 		$v0, 4				# print start
	la 		$a0, start
	syscall
	
	li 		$v0, 8				# read string from user
	la 		$a0, string
	li 		$a1, 1000
	syscall
	move 		$s0, $a0			# s0 = address of string 
	
	li 		$v0, 4
	la 		$a0, disk			# print disk
	syscall
	
	li 		$v0, 4
	la 		$a0, open			# print open
	syscall
	
		


# Subprogram: check_length
# Purpose: To check if the length of the string $s0 is divisible by 8 or not
begin: 
	addi 		$t3, $zero, 0 			# the length of string
	addi 		$t0, $zero, 0 			# initialize the counter

length: 
	add 		$t1, $s0, $t0 			# t1 = s0 = address of string[i]
	lb 		$t2, 0($t1) 			# load the element in string respectively to t2
	nop
	beq 		$t2, 10, check_length		# t2 = 10 = LF = line feed => string ends
	nop
	addi 		$t3, $t3, 1 			# length increment
	addi 		$t0, $t0, 1			# counter increment
	j 		length
	nop


check_length: 
	addi 		$t4, $t3, 0			# t4 = t3 = length of string
	srl  		$t4, $t4, 3			# shift t4 right by 3 bits
	sll 		$t4, $t4, 3			# shift t4 left by 3 bits
	bne 		$t4, $t3, wrong			# if t4 != t3 => branch to wrong
	j 		initialize_1			# else => the string is acceptable
	
wrong:	
	li 		$v0, 4				# print error
	la 		$a0, error
	syscall
	j 		main				# jump to main to take another input from user
	
	
# Subprogram: hexadecimal
# Purpose: to get the hexadecimal value of binary number
# Input:	$t8 - the binary number
# Output:	$a0 - the string of hexadecimal type converted
hexadecimal:	
	li 		$t5, 7				# initialize the counter
	
loop:	
	blt 		$t5, $zero, end_hexa		# if t5 < 0 => branch to end_hexa
	rol 		$t8, $t8, 4			# rotate the number 4 bits to the left
	andi 		$a0, $t8, 0xf 			# mask the bytes with 1111 to get the final byte a0
	
	la 		$t6, hexa 			# load the address of string hexa
	add 		$t6, $t6, $a0 			# t6 = t6 + a0
	
	bgt 		$t5, 1, continue		# if t5 > 1 => branch to continue
	lb 		$a0, 0($t6) 			# load the element at the position t6 in hexa array to a0
	li 		$v0, 11				# print string of hexadecimal type
	syscall
	
continue:	
	addi 		$t5, $t5, -1			# counter decrement
	j 		loop
	
end_hexa: 
	jr 		$ra				# jump back



# Subprogram: RAID5 disk simulation for 4 first block
# Purpose: to simulate RAID5 disk for 4 first block
# Input:	$s0 - the string
# 2 blocks of data are stored in disk 1 and 2, while disk 3 contains parity data
initialize_1:	
	addi 		$t0, $zero, 0			# initialize the counter for block of data
	addi 		$t7, $zero, 0			# initialize the counter for disk 1
	addi 		$t8, $zero, 0			# initialize the counter for disk 2
	
	la 		$s1, disk1			# the address of disk 1 
	la 		$s2, disk2			# the address of disk 2
	la 		$a2, parity			# the address of parity data
	
	li 		$v0, 4				# print open_disk
	la 		$a0, open_disk
	syscall
	
store_d11:	
	lb 		$t1, ($s0)			# load the character in the string to t1
	addi 		$t3, $t3, -1			# length decrement
	sb 		$t1, ($s1)			# store the value of t1 to disk 1
	
store_d21:	
	add 		$s5, $s0, 4			# address increment to next block of data
	lb 		$t2, ($s5)			# load the character in the string to t2
	addi 		$t3, $t3, -1			# length decrement
	sb 		$t2, ($s2)			# store the value of t2 to disk 2
	
store_d31:	
	xor 		$a3, $t1, $t2			# using XOR between t1 and t2 to get the value of parity 
	sw 		$a3, ($a2)			# store that value to parity data
	
	addi 		$a2, $a2, 4			# address increment in parity data
	addi 		$t0, $t0, 1			# counter increment for block of data
	addi 		$s0, $s0, 1			# address increment in string
	addi 		$s1, $s1, 1			# address increment in disk 1
	addi 		$s2, $s2, 1			# address increment in disk 2
	
	bgt 		$t0, 3, print_1			# if counter > 3 => branch to print_1
	j 		store_d11			# else => jump to store_d11
	
print_1:	
	la 		$s1, disk1			# the address of disk 1
	la 		$s2, disk2			# the address of disk 2
	
print_d11:
	lb 		$a0, ($s1)			# load the value in disk 1 to a0
	li 		$v0, 11				# print a0
	syscall
	
	addi 		$t7, $t7, 1			# counter increment for disk 1
	addi 		$s1, $s1, 1			# address increment for disk 1
	
	bgt 		$t7, 3, next_d21		# if counter = 3 => branch to next_d21
	j 		print_d11
		
next_d21:	
	li 		$v0, 4				# print close_disk
	la 		$a0, close_disk
	syscall
	
	li 		$v0, 4				# print open_disk
	la 		$a0, open_disk
	syscall
	
print_d21:
	lb 		$a0, ($s2)			# load the value in disk 2 to a0
	li 		$v0, 11				# print a0
	syscall
	
	addi 		$t8, $t8, 1			# counter increment for disk 2
	addi 		$s2, $s2, 1			# address increment for disk 2
	
	bgt 		$t8, 3, next_d31		# if counter = 3 => branch to next_d31
	j 		print_d21
	
next_d31:	
	li 		$v0, 4				# print close_disk
	la 		$a0, close_disk
	syscall
	
	li 		$v0, 4				# print open_bracket
	la 		$a0, open_bracket
	syscall
	
	la 		$a2, parity			# the address of parity data
	addi 		$t9, $zero, 0			# initialize the counter
	
print_d31:
	lb 		$t8, ($a2)			# load the value in binary type in parity data to t8
	jal 		hexadecimal			# convert to hexadecimal type and print
	
	li 		$v0, 4				# print comma							
	la 		$a0, comma
	syscall
	
	addi 		$t9, $t9, 1			# counter increment for parity data
	addi 		$a2, $a2, 4			# address increment for parity data
	
	bgt 		$t9, 2, end_1			# if the counter = 2 => no more printing comma
	j 		print_d31					
		
end_1:	
	lb 		$t8, ($a2)			# load the final value in binary type in parity data to t8 
	jal 		hexadecimal			# convert to hexadecimal type and print
	
	li 		$v0, 4				# print close_bracket
	la 		$a0, close_bracket
	syscall
	
	li 		$v0, 4				# print newline
	la 		$a0, newline
	syscall
	
	beq 		$t3, 0, end_disk		# if length of string = 0 => branch to end_disk
	


############################################################################################
# Subprogram: RAID5 disk simulation for 4 next block
# Purpose: to simulate RAID5 disk for 4 next block
# Input:	$s0 - the string
# 2 blocks of data are stored in disk 1 and 3, while disk 2 contains parity data
initialize_2:	
	addi 		$s0, $s0, 4			# address increment to next block of data
	addi 		$t0, $zero, 0			# initialize the counter for block of data
	addi 		$t7, $zero, 0			# initialize the counter for disk 1
	
	la 		$a2, parity			# the address of parity data 
	la 		$s1, disk1			# the address of disk 1 
	la 		$s3, disk3			# the address of disk 1 
	
	li 		$v0, 4				# print open_disk
	la 		$a0, open_disk
	syscall
	
store_d12:	
	lb 		$t1, ($s0)			# load the character in the string to t1
	addi 		$t3, $t3, -1			# length decrement
	sb 		$t1, ($s1)			# store the value of t1 to disk 1
	
store_d32:	
	add 		$s5, $s0, 4			# address increment to next block of data
	lb 		$t2, ($s5)			# load the character in the string to t2
	addi 		$t3, $t3, -1			# length decrement
	sb 		$t2, ($s3)			# store the value of t2 to disk 3
	
store_d22:	
	xor 		$a3, $t1, $t2			# using XOR between t1 and t2 to get the value of parity 
	sw 		$a3, ($a2)			# store that value to parity data
	
	addi 		$a2, $a2, 4			# address increment in parity data
	addi 		$t0, $t0, 1			# counter increment for block of data
	addi 		$s0, $s0, 1			# address increment in string
	addi 		$s1, $s1, 1			# address increment in disk 1
	addi	 	$s3, $s3, 1			# address increment in disk 3
	
	bgt 		$t0, 3, print_2			# if the counter = 3 => branch to print_2
	j 		store_d12
	
print_2:	
	la 		$s1, disk1			# the address of disk 1 
	la 		$s3, disk3			# the address of disk 3
	
print_d12:
	lb 		$a0, ($s1)			# load the value in disk 1 to a0
	li 		$v0, 11				# print a0
	syscall
	
	addi 		$t7, $t7, 1			# counter increment 
	addi 		$s1, $s1, 1			# address increment in disk 1
	
	bgt 		$t7, 3, next_d22		# if counter = 3 => branch to next_d22
	j 		print_d12
	
next_d22:	
	addi 		$t9, $zero, 0			# initilize the counter for disk 2
	la 		$a2, parity			# the address of parity data
	
	li 		$v0, 4				# print close_disk
	la 		$a0, close_disk
	syscall

	li 		$v0, 4				# print open_bracket
	la 		$a0, open_bracket
	syscall
	
print_d22:
	lb 		$t8, ($a2)			# load the value in binary type in parity data to t8
	jal 		hexadecimal			# convert to hexadecimal type and print
	
	li 		$v0, 4				# print comma
	la 		$a0, comma
	syscall
	
	addi 		$t9, $t9, 1			# counter increment for parity data
	addi 		$a2, $a2, 4			# address increment for parity data
	
	bgt 		$t9, 2, next_d32		# if counter = 2 => no more printing comma
	j 		print_d22
			
next_d32:	
	lb 		$t8, ($a2)			# load the final value in binary type in parity data to t8
	jal 		hexadecimal			# convert to hexadecimal type and print
	
	li 		$v0, 4				# print close_bracket
	la 		$a0, close_bracket
	syscall
	
	li 		$v0, 4				# print open_disk
	la 		$a0, open_disk
	syscall
	
	addi 		$t8, $zero, 0			# initialize the counter for disk 3
	
print_d32:
	lb 		$a0, ($s3)			# load the value in disk 3 to a0
	li 		$v0, 11				# print a0
	syscall
	
	addi 		$t8, $t8, 1			# counter increment in disk 3
	addi 		$s3, $s3, 1			# address increment in disk 3
	
	bgt 		$t8, 3, end_2			# if counter = 3 => branch to end_2
	j 		print_d32

end_2:	
	li 		$v0, 4				# print close_disk
	la		$a0, close_disk
	syscall
	
	li 		$v0, 4				# print newline
	la 		$a0, newline
	syscall
	
	beq 		$t3, 0, end_disk		# if length of string = 0 => branch to end_disk



# Subprogram: RAID5 disk simulation for 4 next block
# Purpose: to simulate RAID5 disk for 4 next block
# Input:	$s0 - the string
# 2 blocks of data are stored in disk 2 and 3, while disk 1 contains parity data
initialize_3:	
	la 		$a2, parity			# the address of parity data
	la 		$s2, disk2			# the address of disk 2
	la 		$s3, disk3			# the address of disk 3
	
	addi 		$s0, $s0, 4			# address increment to next block of data
	addi 		$t0, $zero, 0			# initialize the counter
		
	li 		$v0, 4				# print open_bracket
	la 		$a0, open_bracket
	syscall
	
store_d23:	
	lb 		$t1, ($s0)			# load the character in the string to t1
	addi 		$t3, $t3, -1			# length decrement
	sb 		$t1, ($s2)			# store the value of t1 to disk 2
	
store_d33:	
	add 		$s5, $s0, 4			# address increment to next block of data
	lb 		$t2, ($s5)			# load the character in the string to t2
	addi 		$t3, $t3, -1			# length decrement
	sb 		$t2, ($s3)			# store the value of t1 to disk 3
	
store_d13:	
	xor 		$a3, $t1, $t2			# using XOR between t1 and t2 to get the value of parity 
	sw 		$a3, ($a2)			# store that value to parity data
	
	addi 		$a2, $a2, 4			# address increment in parity data
	addi 		$t0, $t0, 1			# counter increment for block of data
	addi 		$s0, $s0, 1			# address increment in string
	addi 		$s2, $s2, 1			# address increment in disk 2
	addi 		$s3, $s3, 1			# address increment in disk 3
	
	bgt 		$t0, 3, print_3			# if counter = 3 => branch to print_3
	j 		store_d23
	
print_3:	
	la 		$s2, disk2			# the address of disk 2
	la 		$s3, disk3			# the address of disk 3
	la 		$a2, parity			# the address of parity data
	addi 		$t7, $zero, 0
	
print_d13:
	lb 		$t8, ($a2)			# load the value in binary type in parity data to t8
	jal 		hexadecimal			# convert to hexadecimal type and print
	
	li 		$v0, 4				# print comma
	la 		$a0, comma
	syscall
	
	addi 		$t7, $t7, 1			# counter increment for parity data
	addi 		$a2, $a2, 4			# address increment for parity data
	
	bgt 		$t7, 2, next_d23		# if counter = 2 => no more printing comma
	j 		print_d13	
		
next_d23:	
	lb 		$t8, ($a2)			# load the final value in binary type in parity data to t8
	jal 		hexadecimal			# convert to hexadecimal type and print
	
	li 		$v0, 4				# print close_bracket
	la 		$a0, close_bracket
	syscall
	
	li 		$v0, 4				# print open_disk
	la 		$a0, open_disk
	syscall
	
	addi 		$t9, $zero, 0			# initialize the counter for disk 2
	
print_d23:
	lb 		$a0, ($s2)			# load the value in disk 2 to a0
	li 		$v0, 11				# print a0
	syscall
	
	addi 		$t9, $t9, 1			# counter increment in disk 2
	addi 		$s2, $s2, 1			# address increment in disk 2
	
	bgt 		$t9, 3, next_d33		# if counter = 3 => branch to next_d33
	j 		print_d23
	
next_d33:	
	addi 		$t8, $zero, 0			# initialize the counter for disk 3
	
	li 		$v0, 4				# print close_disk
	la 		$a0, close_disk
	syscall	
	
	li 		$v0, 4				# print open_disk
	la 		$a0, open_disk
	syscall	
	
print_d33:
	lb 		$a0, ($s3)			# load the value in disk 3 to a0
	li 		$v0, 11				# print a0
	syscall
	
	addi 		$t8, $t8, 1			# counter increment in disk 3
	addi 		$s3, $s3, 1			# address increment in disk 3
	
	bgt 		$t8, 3, end_3			# if counter = 3 => branch to end_3
	j 		print_d33
	
end_3:	
	li 		$v0, 4				# print close_disk
	la 		$a0, close_disk
	syscall
	
	li 		$v0, 4				# print newline
	la 		$a0, newline
	syscall
	
	beq 		$t3, 0, end_disk		# if length = 0 => branch to end_disk



############################################################################################
############################    end   of   simulation   ####################################

# Subprogram: next
# Purpose: end the process of loading the data to 3 current rows of RAID5 disk and jump to next process
# Input: 	$s0 - the address of string
# Output: none
next: 
	addi 		$s0, $s0, 4			# if length != 0 => address increment in string to next block of data
	j 		initialize_1
	
end_disk:	
	li 		$v0, 4				# print open
	la 		$a0, open
	syscall
	j 		ask				

# Subprogram: ask
# Purpose: display a message to user to choose
ask:	
	li 		$v0, 50				# display message to user
	la 		$a0, message
	syscall
	
	beq 		$a0, 0, reload			# if the answer is yes => branch to reload
	nop
	j 		exit				# else => exit
	nop

# Subprogram: clear
# Purpose: clear data in array to restart the process
# Input: 	$s0 - the address of string
#		$t5 - the length of string 
# Output: none
reload:	
	la 		$s0, string			# the address of string
	add 		$s3, $s0, $t4			# s3 = address of the last byte in string
	li 		$t1, 0				# initialize the counter
	
clear: 
	sb 		$t1, ($s0)			# set the byte in the string to 0
	nop
	
	addi 		$s0, $s0, 1			# adress increment in string
	
	bge 		$s0, $s3, main			# if string ends => branch to main
	nop
	j 		clear						
	nop



# Subprogram: Exit
exit:	
	li 		$v0, 10				# exit from program
	syscall



