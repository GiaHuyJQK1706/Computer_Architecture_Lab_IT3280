.eqv SCREEN 	0x10010000	
.eqv YELLOW 	0x00FFFF00
.eqv BLACK 	0x00000000
.eqv KEY_A 	0x00000061
.eqv KEY_S	0x00000073
.eqv KEY_D	0x00000064
.eqv KEY_W	0x00000077
.eqv KEY_Z  	0x0000007A
.eqv KEY_X  	0x00000078
.eqv KEY_CODE	0xFFFF0004
.eqv KEY_READY	0xFFFF0000

.data	
	circle_bound: 	.space 100
# $a2, $a3: loop's iterators
.text 
	li $s0, 256		# X_0 = 256
	li $s1, 256		# Y_0 = 256		
	li $s2, 16		# R = 16
	li $s3, 512		# width of screen
	li $s4, 512		# height of screen
	li $s5, 0		# deltaX = 0
	li $s6, 0		# deltaY = 0  
	li $s7, 2 		# speed
	
circle_bound_init: # use $t0, $t1, $t2, $t3, no need to keep
	la $t1, circle_bound
	li $a2, 0
	mul $t2, $s2, $s2 # $t2 = R^2
circle_bound_loop:
	ble $s2, $a2, end_circle_bound_loop
	mul $t3, $a2, $a2 
	sub $t3, $t2, $t3 # $t3 = R^2-i^2
 	move $t0, $t3 # $t0 = sqrt(R^2-i^2)
	jal sqrt
	sw $t0, 0($t1)
	add $a2, $a2, 1
	add $t1, $t1, 4
	j circle_bound_loop
end_circle_bound_loop:
game_loop:
read_keyboard:
 	lw $k1, KEY_READY 				# if a key is clicked, $k1 = 1
 	beq $k1, $zero, position_check  	# $k1 = 0 then run position check
 	lw $k0, KEY_CODE
 	beq $k0, KEY_A, case_a
 	beq $k0, KEY_S, case_s
 	beq $k0, KEY_D, case_d
 	beq $k0, KEY_W, case_w
 	beq $k0, KEY_Z, case_z
 	beq $k0, KEY_X, case_x
 	j position_check
case_a:
 	jal move_left
 	j position_check 
case_s:
 	jal move_down
 	j position_check
case_d:
 	jal move_right
 	j position_check
case_w:
 	jal move_up
 	j position_check
case_z:
	jal speed_up
	j position_check
case_x:
	jal slow_down

# Check if the circle touches an edge or not. After checking 4 directions, draw the circle
position_check: # use $t0, no need to keep
check_right:
 	add $t0, $s0, $s2		
 	add $t0, $t0, $s5		# $t0 = X_0 + R + deltaX: rightest point on the circle after this time step
 	ble $t0, $s3, check_left # if $t0 < width of screen, no need to check more. If not, reverse the direction
 	jal move_left
check_left:
 	sub $t0, $s0, $s2	
 	add $t0, $t0, $s5		# $t0 = X_0 - R + deltaX: leftest point on the circle after this time step
 	ble $zero, $t0, check_top# if 0 < $t0, no need to check more. If not, reverse the direction 
 	jal move_right
check_top:
 	sub $t0, $s1, $s2	
 	add $t0, $t0, $s6		# t2 = Y_0 - R + deltaY: highest point on the circle after this time step
 	ble $zero, $t0, check_bottom # if 0 < $t0, no need to check more. If not, reverse the direction
 	jal move_down
check_bottom:
 	add $t0, $s1, $s2	
 	add $t0, $t0, $s6		# t2 = Y_0 + R + deltaY: highest point on the circle after this time step
 	ble $t0, $s4, draw		# if $t0 < height of screen, no need to check more. If not, reverse the direction
 	jal move_up		

draw: # use $t0, $t1, no need to keep $t1 for child
	la $t0, BLACK
	jal draw_circle
	add $s0, $s0, $s5
	add $s1, $s1, $s6 # 2 lines: move the center to the new position after the time step: X = X + deltaX, Y = Y + deltaY

	la $t0, YELLOW
	jal draw_circle
	li $v0, 32
	li $t1, 50
	syscall # Stop for a while: 50ms
	j game_loop

# draw 4 arcs of the circle
# input: $t0: color of the circle
draw_circle: # use $t1, $t2, $t3, $t4, no need to keep
	add $t9, $0, $ra #Luu lai gia tri cua $ra
	la $t1, circle_bound
	li $a2, 0
draw_circle_loop: # $t2 = circle_bound[i]
	ble $s2, $a2, end_draw_circle_loop
	lw $t2, 0($t1)
		 
 	move $t3, $a2				# i = $a0 = $t0(index cua mang)
	move $t4, $t2				# j = $a1
	jal drawCirclePoint			# Lay toa do de ve (Xo + i, Yo + j), (Xo + j, Yo + i)
	sub $t4, $zero, $t2
	jal drawCirclePoint			# (Xo + i, Yo - j), (Xo + j, Yo - i)
	sub $t3, $zero, $a2
	jal drawCirclePoint			# (Xo - i, Yo - j), (Xo - j, Yo - i)
	add $t4, $zero, $t2
	jal drawCirclePoint			# (Xo - i, Yo + j), (Xo - j, Yo + i)
	
	add $a2, $a2, 1
	add $t1, $t1, 4
	j draw_circle_loop
end_draw_circle_loop:
	add $ra, $t9, $0 # tra lai gia tri $ra

 	jr $ra
 	
drawCirclePoint:
 	
 	add $t5, $s0, $t3 	# Xi = X0 + i
	add $t6, $s1, $t4	# Yi = Y0 + j
	mul $t6, $t6, $s3	# Yi * SCREEN_WIDTH
	add $t5, $t5, $t6	# Yi * SCREEN_WIDTH + Xi (Toa do 1 chieu cua diem anh)
	sll $t5, $t5, 2		# Dia chi tuong doi cua diem anh
	sw $t0, SCREEN($t5)	# Ve diem anh
	add $t5, $s0, $t4 	# Xi = Xo + j
	add $t6, $s1, $t3	# Yi = Y0 + i
	mul $t6, $t6, $s3	# Yi * SCREEN_WIDTH
	add $t5, $t5, $t6	# Yi * SCREEN_WIDTH + Xi (Toa do 1 chieu cua diem anh)
	sll $t5, $t5, 2		# Dia chi tuong doi cua diem anh
	sw $t0, SCREEN($t5)	# Ve diem anh
		
	jr $ra

# Note: in speed_up, we are based on the direction to call move again, so that the speed are immediately changed
move_left:
	sub $s5, $zero, $s7 # move left $s7 unit
 	li $s6, 0
	jr $ra 	
move_right:
	add $s5, $zero, $s7 # move right $s7 unit
 	li $s6, 0
	jr $ra 	
move_up:
	li $s5, 0
 	sub $s6, $zero, $s7 # move up $s7 unit
	jr $ra 	
move_down:
	li $s5, 0
 	add $s6, $zero, $s7 # move down $s7 unit
	jr $ra 
speed_up: # $s7 += 1
	add $s7, $s7, 1
	
	jr $ra
slow_down: # $s7 -= 1, min speed: 1
	add $s7, $s7,-1 
	blt $zero, $s7, back
	li $s7, 1
back:
	jr $ra

# Calculate sqrt of
# Input: $t0
# Output: $t0 = sqrt($t0)
sqrt: 
	mtc1 $t0, $f0    # $f0 = $t0
	cvt.s.w $f0, $f0	 
	sqrt.s $f0, $f0
	cvt.w.s $f0, $f0 # 3 lines: $f0 = sqrt($f0) 
	mfc1 $t0, $f0    
	jr $ra
