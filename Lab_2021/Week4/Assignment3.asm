# Laboratory Exercise 4, Assignment 3
# Author: Pham Huy Canh
.text
	li $s0, 0
	li $s1, -5
	li $s2, 5
	
	# a. abs $s0, $s1
	sra $t0, $s1, 31		# Dich phai 31 bit cua s1 (Muc dich de bien cac bit giong voi gia tri cua bit dau)	
	xor $s0, $t0, $s1 
	subu $s0, $s0, $t0

	# b. move $s0, $s1
	addu $s0, $zero, $s1
	
	# c. not $s0, $s1
	nor $s0, $s1, $zero
		
	# d. ble $s1, $s2, label 
	slt $t0, $s2, $s1
	beq $t0, $zero, label

label:




























