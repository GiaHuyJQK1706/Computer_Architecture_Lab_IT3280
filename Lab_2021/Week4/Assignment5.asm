#Laboratory Exercise 4, Assignment 5
.text
	li $s0, 10
	li $s1, 16
	li $s2, 0		# i = 0
	move $t1, $s1
loop: 	
	beq $t1, 1, multiple	# Kiem tra t1 = 1 thi nhay den multiple
	srl $t1, $t1, 1		# Dich phai t1 sang 1 bit (t1 = t1 / 2)
	addi $s2, $s2, 1		# i = i + 1 
	j loop
multiple: 
	sllv $t0, $s0, $s2 	# Dich trai s0 sang s2 bit (t0 = s0 * 2^s2)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	