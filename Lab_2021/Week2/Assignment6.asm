#Laboratory Exercise 2, Assignment 6
.data				# DECLARE VARIABLES
X: .word 5			# Variable X, word type, init value = 5
Y: .word -1			# Variable Y, word type, init value = -1
Z: .word 			# Variable Z, word type, no init value
.text				# DECLARE INSTRUCTIONS
	# Load X, Y to registers
	la $t8, X		# Get the address of X in Data Segment
	la $t9, Y		# Get the address of Y in Data Segment
	lw $t1, 0($t8)		# $t1 = X
	lw $t2, 0($t9)		# $t2= Y
	
	# Calculate the expression Z = 2X + Y with registers only
	add $s0, $t1, $t1	# $s0 = $t1 + $t1 = X + X = 2X
	add $s0, $s0, $t2	# $s0 = $s0 + $t2 = 2X + Y
	
	# Store result from register to variable Z
	la $t7, Z		# Get the address of Z in Data Segment
	sw $s0, 0($t7)		# Z = $s0 = 2X + Y 
