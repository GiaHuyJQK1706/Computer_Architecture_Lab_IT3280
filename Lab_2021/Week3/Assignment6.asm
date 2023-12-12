# Laboratory Exercise 3, Assignment 6
# Author: Pham Huy Canh
.data
	A: .word 1, -3, -10, 6, -29, 3, -39
	message: .asciiz "Tri tuyet doi lon nhat la: "
.text
	addi $s0, $zero, 0	# max = 0
	la $a0, A
	lw $s1, 0($a0)		# A[0]
	addi $s2, $zero, 0	# i = 0
	addi $s3, $zero, 7	# n = 7
	
loop:	slt $t2, $s2, $s3	# i<n
	beq $t2, $zero, endloop	# i>=n branch to endloop
	sll $t1, $s2, 2		# t1 = i * 4
	add $a1, $a0, $t1	# a1 = a0 + 4
	lw $s4, 0($a1)		# s4 = A[i]
if_nhohon:
	bgez $s4, if_lonhon	# s4>0 branch to if_lonhon
	sub $s4, $zero, $s4	# s4 = 0 - s4
	j if_lonhon
if_lonhon: 		
	slt $t4, $s0, $s4	# max < s4
	bne $t4, $zero, max	# max < s4 branch to max
	j reloop			# jump reloop
max: 	add $s0, $zero, $s4	# max = 0 + s4
	j reloop			# jump reloop
reloop: 	addi $s2, $s2, 1		# i=i+1
	j loop			# jump loop
endloop:







	
	
	
	
	
	
	
	
	
	
	
	
	
	
