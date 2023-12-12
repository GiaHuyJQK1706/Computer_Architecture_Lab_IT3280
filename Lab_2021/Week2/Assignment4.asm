#Laboratory Exercise 2, Assignment 4
.text
	# Assign X, Y
	addi $t1, $zero, 5	# X = $t1 = 0 + 5 = 5
	addi $t2, $zero, -1	# Y = $t2 = 0 + (-1) = (-1)
	# Expression Z = 2X + Y
	add $s0, $t1, $t1	# $s0 = $t1 + $t1 = X + X = 2X
	add $s0, $s0, $t2	# $s0 = $s0 + $t2 = 2X + Y
	