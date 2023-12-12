# Laboratory Exercise 3, Home Assignment 1
# Author: Pham Huy Canh
.data
	x: .word 1
	y: .word 1
	z: .word 1
.text
	addi $s1, $zero, 5 	# Khoi tao i = 5
	addi $s2, $zero, 4	# Khoi tao j = 4
	addi $s3, $zero, 5	# Khoi tao j = 4
	addi $s4, $zero, 3	# Khoi tao j = 4	
	la $a0, x		# Lay dia chi cua x
	lw $t1, 0($a0)		# Load gia tri cua x vao thanh ghi $t1
	la $a0, y		# Lay dia chi cua y
	lw $t2, 0($a0)		# Load gia tri cua y vao thanh ghi $t2
	la $a0, z		# Lay dia chi cua z
	lw $t3, 0($a0)		# Load gia tri cua z vao thanh ghi $t3
	
	
start:
	slt $t4, $s1, $s2	# i<j
	beq $t4, $zero, else	# branch to else if i>=j
	addi $t1,$t1,1 		# then part: x=x+1
	addi $t3,$zero,1 	# z=1
	j endif 			# skip “else” part
else: 	
	addi $t2,$t2,-1 		# begin else part: y=y-1
	add $t3,$t3,$t3 		# z=2*z
endif:
	





