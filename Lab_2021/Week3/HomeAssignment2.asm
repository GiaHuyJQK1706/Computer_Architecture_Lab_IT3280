# Laboratory 3, Home Assigment 2
# Author: Pham Huy Canh

.data
	A: .word 2,3,0,5,-6

.text
	addi $s1, $zero, 0 	# i = 0
	addi $s3, $zero, 5	# n = 5	
	addi $s4, $zero, 1	# step = 1
	addi $s5, $zero, 0 	# sum = 0
	la $s2, A		# load address A[0] to $s2
loop:  
	slt $t2, $s1, $s3
	beq $t2, $zero, endloop
	add $t1, $s1, $s1	# $t1 = 2 * $s1
	add $t1, $t1, $t1 	# $t1 = 4 * $s1
	add $t1, $t1, $s2 	# $t1 store the address of A[i]
	lw $t0, 0($t1) 		# load value of A[i] in $t0
	beq $t0, $zero, endloop	# branch to endloop if A[i] = 0
	add $s5, $s5, $t0	# sum = sum + A[i] 
	add $s1, $s1, $s4 	# i = i + step
	j loop 			# goto loop
endloop:




















