.eqv MONITOR_SCREEN 0x10010000 #Dia chi bat dau cua bo nho man hinh

.eqv KEY_CODE	0xFFFF0004
.eqv KEY_READY	0xFFFF0000

.data
circle:		.word

.text
initialize:
	# center
 	li	$s0, 256		# x = 256
 	li	$s1, 256		# y = 256
 	# direction that the circle is moving
 	li	$s2, 1			# dx = 1
	li	$s3, 0			# dy = 0
	# radius
  	li	$s4, 20			# R = 20
  	# sleep time
	li	$a0, 50			# t = 50
	jal	circle_push
  	 

input:	
	li	$k0, KEY_READY
	lw	$t0, 0($k0)
	bne	$t0, 1, hit_edge
	li	$k0, KEY_CODE
	lw	$t0, 0($k0)
	beq	$t0, 'a', pressed_a
	beq	$t0, 'd', pressed_d
	beq	$t0, 's', pressed_s
	beq	$t0, 'w', pressed_w
	beq	$t0, 'x', pressed_x
	beq	$t0, 'z', pressed_z

pressed_a:
	li	$s2, -1		# dx = -1	
	li	$s3, 0		# dy = 0
	j	hit_edge
	
pressed_d:
	li	$s2, 1		# dx = 1
	li	$s3, 0		# dy = 0
	j	hit_edge
	
pressed_s:
	li 	$s3, 1		# dy = 1
	li	$s2, 0		# dx = 0	
	j	hit_edge

pressed_w:
	li 	$s3, -1		# dy = -1
	li	$s2, 0		# dx = 0	
	j	hit_edge

pressed_x:
	addi	$a0, $a0, 10	# t += 10
	j	hit_edge
	
pressed_z:
	beq	$a0, 0, hit_edge
	addi	$a0, $a0, -10	# t -= 10
	j	hit_edge

hit_edge:
	beq	$s2, 1, right_edge
	beq	$s2, -1, left_edge
	beq	$s3, -1, up_edge
	beq	$s3, 1, down_edge
	j	move_circle
	
right_edge:	
	add	$t0, $s0, $s4	# Rightest side of the circle
	beq	$t0, 511, reverse
	j	move_circle

left_edge:
	sub	$t0, $s0, $s4	# Leftest side of the circle
	beq	$t0, 1, reverse
	j	move_circle
	
down_edge:
	add	$t0, $s1, $s4	# Downest side of the circle
	bge	$t0, 511, reverse
	j	move_circle
	
up_edge:
	sub	$t0, $s1, $s4	#Upest side of the circle
	ble	$t0, 1, reverse
	j	move_circle
	
reverse:
	sub	$s2, $0, $s2	# dx = -dx
	sub	$s3, $0, $s3	# dy = -dy
	j	move_circle

move_circle:
	li	$s5, 0		# Set color to black
	jal	draw_circle	# Erase the old circle
	
	add	$s0, $s0, $s2 	# Set the center of the new circle 
	add	$s1, $s1, $s3 
	li	$s5, 0x00FFFF00	# Set color to yellow
	jal	draw_circle	# Draw the new circle

loop:
	li $v0, 32	 	# Sleep
	syscall
	j	input		# Renew the cycle
	
draw_circle:
	addi	$sp, $sp, -4	# Save $ra 
	sw 	$ra, 0($sp)
	la	$s6, circle	# pointer to the circle array
	
draw_loop:
	beq	$s6, $v1, draw_end	# Stop when $s6 = $v1 (pointer at the end of the array)
	lw	$a1, 0($s6)		# Get px
	lw	$a2, 4($s6)		# Get py
	jal	draw
	addi	$s6, $s6, 8		# Move the pointer
	j	draw_loop
	
draw_end:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra										
					
draw:
	li	$t0, MONITOR_SCREEN
	add	$t1, $s0, $a1
	add	$t2, $s1, $a2	
	sll	$t2, $t2, 9	# Move to y coordinate
	add	$t2, $t2, $t1	# Move to x coordinate
	sll	$t2, $t2, 2	# Multiply by 4 for address
	add	$t0, $t0, $t2
	sw	$s5, 0($t0)
	jr	$ra

	
circle_push:
	addi	$sp, $sp, -4
	sw 	$ra, 0($sp)
	la 	$s5, circle	# $s5 = pointer of the "circle" array
	mul	$a3, $s4, $s4	# $a3 = R*R	
	add	$s7, $0, $0	# px = 0
	
circle_cal_loop:
	bgt	$s7, $s4, circle_end
	mul	$t0, $s7, $s7	# $t0 = px^2
	sub	$a2, $a3, $t0	# $a2 = R^2 - px^2 = py^2
	beqz	$a2, cal_continue
	jal	root		# $a2 = py
cal_continue:	
	move	$a1, $s7	# $a1 = px
	li	$s6, 0		

# Saving (px, py), (-px, py), (-px, -py), (px, -py)
push:
	jal	push_save
	sub	$a1, $0, $a1	
	jal	push_save
	sub	$a2, $0, $a2 
	jal	push_save
	sub	$a1, $0, $a1	
	jal	push_save
# then save (-py, px), (py, px), (py, -px), (-py, -px)
	move	$t0, $a1	# Swap px and -py
	move	$a1, $a2
	move	$a2, $t0
	addi	$s6, $s6, 1
	beq	$s6, 2, push_finish
	j	push
push_finish:	
	addi	$s7, $s7, 1
	j	circle_cal_loop
	
push_save:
	sw	$a1, 0($s5)	# Store px
	sw	$a2, 4($s5)	# Store py
	addi	$s5, $s5, 8	# Move the pointer
	jr	$ra	
	
circle_end:
	move	$v1, $s5	# Save the end address of the "circle" array
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
root:
	li	$t0, 0
	li	$t1, 0
	move	$t2, $a2
	div	$t3, $a2, 2 
root_loop:
	div	$t4, $a2, $t2
	add	$t4, $t2, $t4
	div	$t2, $t4, 2
	addi	$t1, $t1, 1
	blt	$t1, $t3, root_loop
	move	$a2, $t2
	jr	$ra
