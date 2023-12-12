.eqv KEY_CODE 0xFFFF0004  
.eqv KEY_READY 0xFFFF0000
                                    		
.eqv SCREEN_MONITOR 0x10010000

.data
circle_end:	.word	1	# The end of the "circle" array
circle:		.word		# The pointer to the "circle" 2-dimentional array
.text
setup:
	addi	$s0, $0, 255	# x = 255
	addi	$s1, $0, 255	# y = 255
	addi	$s2, $0, 1	# dx = 1
	add	$s3, $0, $0	# dy = 0
	addi	$s4, $0, 20	# r = 20
	addi	$a0, $0, 50	# t = 50ms/frame
	jal	circle_data

input:		
	li	$k0, KEY_READY	# Check whether there is input data
	lw	$t0, 0($k0)
	bne	$t0, 1, edge_check
	jal	direction_change

# Check whether the circle has touched the edge
edge_check:

right:	
	bne	$s2, 1, left
	j	check_right

left:
	bne	$s2, -1, down
	j	check_left
	
down:
	bne	$s3, 1, up
	j	check_down
	
up:
	bne	$s3, -1, move_circle
	j	check_up

move_circle:
	add	$s5, $0, $0	# Set color to black
	jal	draw_circle	# Erase the old circle
	
	add	$s0, $s0, $s2 	# Set x and y to the coordinates of the center of the new circle 
	add	$s1, $s1, $s3 
	li	$s5, 0x00FFFF00	# Set color to yellow
	jal	draw_circle	# Draw the new circle

loop:
	li $v0, 32	 	# Syscall value for sleep
	syscall
	j	input		# Renew the cycle

# Procedure below

circle_data:
	addi	$sp, $sp, -4	# Save $ra
	sw 	$ra, 0($sp)
	la 	$s5, circle	# $s5 becomes the pointer of the "circle" array
	mul	$a3, $s4, $s4	# $a3 = r^2	
	add	$s7, $0, $0	# pixel x (px) = 0
	
pixel_data_loop:
	bgt	$s7, $s4, data_end
	mul	$t0, $s7, $s7	# $t0 = px^2
	sub	$a2, $a3, $t0	# $a2 = r^2 - px^2 = py^2
	jal	root		# $a2 = py
	
	add	$a1, $0, $s7	# $a1 = px
	add	$s6, $0, $0	# After saving (px, py), (-px, py), (-px, -py), (px, -py), we swap px and py, then save (-py, px), (py, px), (py, -px), (-py, -px)
	
symmetric:
	beq	$s6, 2, finish
	jal	pixel_save	# px, py >= 0
	sub	$a1, $0, $a1	
	jal	pixel_save	# px <= 0, py >= 0
	sub	$a2, $0, $a2 
	jal	pixel_save	# px, py <= 0
	sub	$a1, $0, $a1	
	jal	pixel_save	# px >= 0, py <= 0
	
	add	$t0, $0, $a1	# Swap px and -py
	add	$a1, $0, $a2
	add	$a2, $0, $t0
	addi	$s6, $s6, 1
	j	symmetric

finish:	
	addi	$s7, $s7, 1
	j	pixel_data_loop
	
data_end:
	la	$t0, circle_end	
	sw	$s5, 0($t0)	# Save the end address of the "circle" array
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
root:				# Find the square root of $a2
	add	$t0, $0, $0	# Set $t0 = 0
	add	$t1, $0, $0	# $t1 = $t0^2

root_loop:				
	beq	$t0, $s4, root_end	# If $t0 exceeds 20, 20 will be the square root
	addi	$t2, $t0, 1		# $t2 = $t0 + 1
	mul	$t2, $t2, $t2		# $t2 = ($t0 + 1)^2
	sub	$t3, $a2, $t1		# $t3 = $a2 - $t0^2
	bgez	$t3, continue		# If $t3 < 0, $t3 = -$t3
	sub	$t3, $0, $t3

continue:
	sub	$t4, $a2, $t2		# $t4 = $a2 - ($t0 + 1)^2
	bgez	$t4, compare		# If $t4 < 0, $t4 = -$t4
	sub	$t4, $0, $t4

compare:
	blt	$t4, $t3, root_continue	# If $t3 >= $t4, $t0 is not nearer to square root of $a2 than $t0 + 1
	add	$a2, $0, $t0		# Else $t0 is the nearest number to square root of $a2
	jr	$ra

root_continue:
	addi	$t0, $t0, 1
	add	$t1, $0, $t2
	j	root_loop

root_end:
	add	$a2, $0, $t0
	jr	$ra
	
pixel_save:
	sw	$a1, 0($s5)	# Store px in the "circle" array
	sw	$a2, 4($s5)	# Store py in the "circle" array
	addi	$s5, $s5, 8	# Move the pointer to a null block
	jr	$ra			
		
direction_change:
	li	$k0, KEY_CODE
	lw	$t0, 0($k0)

case_d:
	bne	$t0, 'd', case_a
	addi	$s2, $0, 1	# dx = 1
	add	$s3, $0, $0	# dy = 0
	jr	$ra

case_a:
	bne	$t0, 'a', case_s
	addi	$s2, $0, -1	# dx = -1	
	add	$s3, $0, $0	# dy = 0
	jr	$ra
	
case_s:
	bne	$t0, 's', case_w
	add	$s2, $0, $0	# dx = 0	
	addi	$s3, $0, 1	# dy = 1
	jr	$ra

case_w:
	bne	$t0, 'w', case_x
	add	$s2, $0, $0	# dx = 0	
	addi	$s3, $0, -1	# dy = -1
	jr	$ra

case_x:
	bne	$t0, 'x', case_z
	addi	$a0, $a0, 10	# t += 10
	jr	$ra
	
case_z:
	bne	$t0, 'z', default
	beq	$a0, 0, default	# Only reduce t when t >= 0 
	addi	$a0, $a0, -10	# t -= 10
		
default:
	jr	$ra

check_right:
	add	$t0, $s0, $s4	# Set $t0 to the right side of the circle
	beq	$t0, 511, reverse_direction	# Reverse direction if the side has touched the edge
	j	move_circle	# Return if not
	
check_left:
	sub	$t0, $s0, $s4	# Set $t0 to the left side of the circle
	beq	$t0, 0, reverse_direction	# Reverse direction if the side has touched the edge
	j	move_circle	# Return if not

check_down:
	add	$t0, $s1, $s4	# Set $t0 to the down side of the circle
	beq	$t0, 511, reverse_direction	# Reverse direction if the side has touched the edge
	j	move_circle	# Return if not
	
check_up:
	sub	$t0, $s1, $s4	# Set $t0 to the up side of the circle
	beq	$t0, 0, reverse_direction	# Reverse direction if the side has touched the edge
	j	move_circle	# Return if not
	
reverse_direction:
	sub	$s2, $0, $s2	# dx = -dx
	sub	$s3, $0, $s3	# dy = -dy
	j	move_circle

draw_circle:
	addi	$sp, $sp, -4	# Save $ra 
	sw 	$ra, 0($sp)
	la	$s6, circle_end	
	lw	$s7, 0($s6)	# $s7 becomes the end address of the "circle" array
	la	$s6, circle	# $s6 becomes the pointer to the "circle" array
	
draw_loop:
	beq	$s6, $s7, draw_end	# Stop when $s6 = $s7
	lw	$a1, 0($s6)		# Get px
	lw	$a2, 4($s6)		# Get py
	jal	pixel_draw
	addi	$s6, $s6, 8		# Get to the next pixel
	j	draw_loop
	
draw_end:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra										
					
pixel_draw:
	li	$t0, SCREEN_MONITOR
	add	$t1, $s0, $a1		# final x (fx) = x + px
	add	$t2, $s1, $a2		# fy = y + py
	sll	$t2, $t2, 9		# $t2 = fy * 512
	add	$t2, $t2, $t1		# $t2 += fx
	sll	$t2, $t2, 2		# $t2 *= 4
	add	$t0, $t0, $t2
	sw	$s5, 0($t0)
	jr	$ra
