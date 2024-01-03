# set 21 digits for each characters D,C,E
# set 1 digit for character '\n'
.data
	string:	.asciiz	"                                           *************       \n**************                            *3333333333333*      \n*222222222222222*                         *33333********       \n*22222******222222*                       *33333*              \n*22222*      *22222*                      *33333********       \n*22222*       *22222*      *************  *3333333333333*      \n*22222*       *22222*    **11111*****111* *33333********       \n*22222*       *22222*  **1111**       **  *33333*              \n*22222*      *222222*  *1111*             *33333********       \n*22222*******222222*  *11111*             *3333333333333*      \n*2222222222222222*    *11111*              *************       \n***************       *11111*                                  \n      ---              *1111**                                 \n    / o o \\             *1111****   *****                      \n    \\   > /              **111111***111*                       \n     -----                 ***********    dce.hust.edu.vn      \n"
	Menu:	.asciiz	"\nMENU:\n1. Hien thi:\n2. DCE chi con lai vien, khong con mau so, hien thi:\n3. Hoan doi vi tri thanh ECD, hien thi:\n4. Nhap ki tu mau cho D,C,E roi hien thi\n5. Thoat:\nNhap lua chon: "
	error:	.asciiz	"Lua chon khong phu hop. Tro ve MENU.\n"
	msg:	.asciiz	"Nhap lai mau so cua D,C,E:\n"
.text
main:
	la	$a0, Menu	# print MENU
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall
	
	beq	$v0, 1, task1
	beq	$v0, 2, task2
	beq	$v0, 3, task3
	beq	$v0, 4, task4
	beq	$v0, 5, exit
	
	la	$a0, error	# if your choice is not 1-5, choose again
	li	$v0, 4
	syscall
	
	j	main

task1:
	la	$a0, string
	li	$v0, 4
	syscall
	
	j	main
task2:
	la	$s0, string
	li	$t0, 1		# index of order of characters
loop_2:	
	bgt	$t0, 1024, main	# the size of the map is 64 x 16 = 1024
	lb	$a0, 0($s0)	# load an individual character into $a0
# the order of numbers 0-9 in ascii table is 48-57
	bgt	$a0, 57, print_2	# if ascii index of character > 57, then it is not a number, then print
	blt	$a0, 48, print_2	# if ascii index of character < 48, then it is not a number, then print
erase:	
	li	$a0, 32		# if this is a number, then replace it by 'space' character
print_2:	
	li	$v0, 11		# print character
	syscall
	
	addi	$s0, $s0, 1		# advance to the next character
	addi	$t0, $t0, 1		# advance the index
	
	j	loop_2
task3:
	li	$s0, 0		# index of the order of lines
loop_3:
	la	$a0, string
	beq	$s0, 16, main	# if reach the 16th line, task is completed
	sll	$s1, $s0, 6	
	add	$s1, $s1, $a0	# $s1 is the first character of the ($s0+1)th line 
print_E3:	# move character 42-62 of each line to 0-20 (not include 64 cause 64th character is 'next line'
	addi	$s2, $s1, 42	# print E, from the 43th character of the line
	jal	print_21_character
print_C3:
	addi	$s2, $s1, 21	# print C, from the 22th character of the line
	jal	print_21_character
print_D3:
	addi	$s2, $s1,  0	# print D, from the 1th character of the line
	jal	print_21_character
	
	li	$a0, 10	# print 'new line'
	li	$v0, 11
	syscall
	
	addi	$s0, $s0, 1	# advance line
	j	loop_3
	
print_21_character:
	li	$t0, 1	# index of the order of character in a line
loop_21_character:
	bgt	$t0, 21, back	# if reach the 21th character, jump back
	
	lb	$a0, 0($s2)	# print character	
	li	$v0, 11
	syscall
	
	addi	$s2, $s2, 1	# advance to next character
	addi	$t0, $t0, 1
	j	loop_21_character
back:	
	jr	$ra
task4:
input:
	la	$a0, msg	# print message
	li	$v0, 4
	syscall
	
	li	$v0, 5	# read color of D
	syscall
	move	$t2, $v0	# load color of D into $t2
	
	li	$v0, 5	# read color of C
	syscall
	move	$t3, $v0	# load color of C into $t3
	
	li	$v0, 5	# read color of E
	syscall
	move	$t4, $v0	# load color of E into $t4
output:
	li	$s0, 0		# index of the order of line
loop_4:
	la	$a0, string
	beq	$s0, 16, main	# if reach the 16th line, then complete
	sll	$s1, $s0, 6	
	add	$s1, $s1, $a0	# $s1 is the first character of the ($s0+1)th line
print_D4:
	addi	$s2, $s1, 0
	move	$t1, $t2	# load color of D into $t1
	jal	print_21
print_C4:
	addi	$s2, $s1, 21
	move	$t1, $t3	# load color of C into $t1
	jal	print_21
print_E4:
	addi	$s2, $s1, 42
	move	$t1, $t4	# load color of E into $t1
	jal	print_21
	
	li	$a0, 10	# print 'new line'
	li	$v0, 11
	syscall
	
	addi	$s0, $s0, 1	# advance line
	j	loop_4
	
print_21:
	li	$t0, 1	# index of the order of character in a line
loop_21:
	bgt	$t0, 21, back	# if reach the 21th character, jump back
	
	lb	$a0, 0($s2)
	bgt	$a0, 57, print_21_4	# if $a0 > 57, it is not a number, then print
	blt	$a0, 48, print_21_4	# if $a0 < 48, it is not a number, then print
	
	move	$a0, $t1	
	addi	$a0, $a0, 48	# load new color of character
print_21_4:
	li	$v0, 11	# print character
	syscall
	
	addi	$t0, $t0, 1
	addi	$s2, $s2, 1	# advance to next character
	
	j	loop_21
	
exit:
	
