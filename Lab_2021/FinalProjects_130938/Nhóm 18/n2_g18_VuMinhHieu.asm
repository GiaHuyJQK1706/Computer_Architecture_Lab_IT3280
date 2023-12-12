######################################################################
#                              Circle                                #
######################################################################
#                                                                    #
#       This program requires the Keyboard and Display MMIO          #
#       and the Bitmap Display to be connected to MIPS.              #
#                                                                    #
#       Bitmap Display Settings                                      #
#       Unit Width:                 1                                #
#       Unit Height:                1                                #
#       Display Width:              512                              #
#       Display Height:             512                              #
#       Base Address for Display:   0x10010000 (static data)         #
#                                                                    #
######################################################################


# Author: Vu Minh Hieu
# Hanoi University of Science and Technology.
# Create date: 12/07/2022

.eqv SCREEN 	0x10010000	# Base Addresss ở cài đặt Bitmap Display
.eqv BORDER 	0xFFC72A	# Màu của viền đường tròn
.eqv RADIUS	24		# Bán kính đường tròn
.eqv BACKGROUND	0x000000	# Màu nền

.eqv KEY_a 	0x61
.eqv KEY_s	0x73
.eqv KEY_d	0x64
.eqv KEY_w	0x77
.eqv KEY_z	0x7A
.eqv KEY_x	0x78

.eqv KEY_A 	0x41
.eqv KEY_S	0x53
.eqv KEY_D	0x44
.eqv KEY_W	0x57
.eqv KEY_Z	0x5A
.eqv KEY_X	0x58

.eqv KEY_ENTER	0x0a

.eqv DELTA_X	10
.eqv DELTA_Y	10
.eqv DELAY_TIME	150
.eqv KEY_CODE	0xFFFF0004
.eqv KEY_READY	0xFFFF0000


#-------------------------------------------------------------------------
# Delay chương trình
# Khoảng thời gian delay giữa các lần di chuyển hình tròn (ms)

.macro delay
	li	$v0, 32		# Gọi sleep
	add	$a0, $t6, 0
	syscall
.end_macro
	
.macro branchIfLessOrEqual(%r1, %r2, %branch)
	sle	$v0, %r1, %r2
	bnez	$v0, %branch
.end_macro
	 
.macro setColorAndDrawCirle(%color)
	li	$s5, %color	# Đặt màu viền theo màu nền
				# để xoá hình tròn cũ
	jal	drawCircle
.end_macro

.kdata
CIRCLE_DATA:	.space 512	# Mảng gồm 512 phần tử

.text
	li	$s0, 256	# x0 = 256	Toạ độ x của tâm đường tròn
	li	$s1, 256	# y0 = 256	Toạ độ y của tâm đường tròn
	li	$s2, RADIUS	# R = 24	Bán kính đường tròn
	li	$s3, 512	# SCREEN_WIDTH = 512	Chiều rộng màn hình
	li	$s4, 512	# SCREEN_HEIGHT = 512	Chiều cao màn hình
	li	$s5, BORDER	# Màu của viền hình tròn (Màu vàng)
	li	$s7, 0		# dx = 0
	li	$t8, 0		# dy = 0
	li	$t6, DELAY_TIME	# currentDelay = 150


#-------------------------------------------------------------------------
# circleInit()
# Hàm khởi tạo đường tròn
# Tạo array lưu tạo độ các điểm của đường tròn
# A[i] = j

circleInit:
	la	$t5, CIRCLE_DATA	# Trỏ vào địa chỉ
					# mảng dữ liệu của đường tròn
	li	$t0, 0			# i = 0

loop:					# for loop i -> R
	slt	$v0, $t0, $s2		# if (i < R)
	beqz	$v0, end_circleInit
	mul	$s6, $s2, $s2		# R^2
	mul	$t3, $t0, $t0		# i^2
	sub	$t3, $s6, $t3		# $t3 = R^2 - i^2
	move	$v0, $t3
	jal	sqrt
				#         /|
				#       /  |
				#  R  /	   |  j
				#   /______|
				# O    i
	sw	$a0, 0($t5)	# Lưu j = sqrt(R^2 - i^2) vào array
	addi	$t0, $t0, 1	# i++
	add	$t5, $t5, 4	# Đi đến vị trí tiếp theo của array CIRCLE_DATA
	j	loop
end_circleInit:


#-------------------------------------------------------------------------
# readKeyboard()
# Hàm xử lý ký tự nhập vào từ bàn phím

programLoop:
readKeyboard:
	lw	$k1, KEY_READY		# Kiểm tra xem đã nhập ký tự nào chưa
	beqz	$k1, positionCheck	
	lw	$k0, KEY_CODE
	beq	$k0, KEY_a, case_a
	beq	$k0, KEY_A, case_a
	beq	$k0, KEY_s, case_s
	beq	$k0, KEY_S, case_s
	beq	$k0, KEY_d, case_d
	beq	$k0, KEY_D, case_d
	beq	$k0, KEY_w, case_w
	beq	$k0, KEY_W, case_w
	beq	$k0, KEY_Z, case_z
	beq	$k0, KEY_z, case_z
	beq	$k0, KEY_X, case_x
	beq	$k0, KEY_x, case_x
	beq	$k0, KEY_ENTER, case_enter
	j	positionCheck
	nop
case_a:
	jal	moveToLeft
	j	positionCheck
case_s:
	jal	moveToDown
	j	positionCheck
case_d:
	jal	moveToRight
	j	positionCheck
case_z:
	jal	speedUp
	j	positionCheck
case_x:
	jal	speedDown
	j	draw
case_w:
	jal	moveToUp
	j	draw
case_enter:
	j	endProgram

positionCheck:
checkRightEdge:
	add	$v0, $s0, $s2	# x0 + R
	add	$v0, $v0, $s7	# if (x0 + R + DELTA_X >= SCREEN_WIDTH) then moveToLeft
	branchIfLessOrEqual($v0, $s3, checkLeftEdge)	# else check left edge
	jal	moveToLeft
	nop
checkLeftEdge:
	sub	$v0, $s0, $s2	
	add	$v0, $v0, $s7	# if (x0 - R + DELTA_X <= 0) then moveToRight
	branchIfLessOrEqual($zero, $v0, checkTopEdge)	# else check top edge	
	jal	moveToRight	
	nop
checkTopEdge:
	sub	$v0, $s1, $s2	
	add	$v0, $v0, $t8	# if (y0 - R + DELTA_Y <= 0) then moveToDown
	branchIfLessOrEqual($zero, $v0, checkBottomEdge) # else check bottom edge
	jal	moveToDown	
	nop
checkBottomEdge:
	add	$v0, $s1, $s2	
	add	$v0, $v0, $t8	# if (y0 + R + DELTA_Y >= SCREEN_HEIGHT) then moveToUp
	branchIfLessOrEqual($v0, $s4, draw)	# else vẽ đường tròn
	jal	moveToUp				
	nop


#-------------------------------------------------------------------------
# Hàm vẽ đường tròn

draw:
	setColorAndDrawCirle(BACKGROUND)	# Vẽ đường tròn trùng màu nên
	add	$s0, $s0, $s7			# Cập nhật toạ độ mới của đường tròn
	add	$s1, $s1, $t8		

	setColorAndDrawCirle(BORDER) 		# Vẽ đường tròn mới
	delay					# Dừng chương trình 1 lúc
	j	programLoop

endProgram:
	setColorAndDrawCirle(BACKGROUND)
	li	$v0, 10				# Gọi exit
	syscall


# ^^^^^^^^^^^^^^^^^^^^^^^
#-------------------------------------------------------------------------
# Hàm vẽ đường tròn
# Sử dụng data của array CIRCLE_DATA tạo ở circleInit

drawCircle:
	add	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$t0, 0			# Khởi tạo i = 0
loop_drawCircle:
 	slt	$v0, $t0, $s2   	# if (i < R)
	beqz	$v0,  end_drawCircle

	sll	$t5, $t0, 2		# CIRCLE_DATA[i]
	lw	$t3, CIRCLE_DATA($t5)	# Load j to $t3 

	move 	$a0, $t0		# i = $a0
	move 	$a1, $t3		# j = $a1
	jal 	drawCirclePoint	# Draw (x0 + i, y0 + j), (x0 + j, y0 + i)
	sub 	$a1, $zero, $t3
	jal 	drawCirclePoint	# Draw (x0 + i, y0 - j), (x0 + j, y0 - i)
	sub 	$a0, $zero, $t0
	jal 	drawCirclePoint	# Draw (x0 - i, y0 - j), (x0 - j, y0 - i)
	add 	$a1, $zero, $t3
	jal 	drawCirclePoint	# Draw (x0 - i, y0 + j), (x0 - j, y0 + i)

	addi 	$t0, $t0, 1
	j 	loop_drawCircle
end_drawCircle:
	lw 	$ra, 0($sp)
	add 	$sp, $sp, 0
	jr 	$ra


#-------------------------------------------------------------------------
# Hàm vẽ điểm trên đường tròn
# Vẽ đồng thời 2 điểm
# (x0 + i, y0 + j) và (x0 + j, x0 + i)
# i = $a0, j = $a1
# Xi = $t1, Yi = $t4

drawCirclePoint: 	
	add	$t1, $s0, $a0		# Xi = x0 + i
	add	$t4, $s1, $a1		# Yi = y0 + j
	mul	$t2, $t4, $s3		# Yi * SCREEN_WIDTH
	add	$t1, $t1, $t2		# Xi + Yi * SCREEN_WIDTH
					# (Toạ độ 1 chiều của điểm ảnh)
	sll	$t1, $t1, 2		# Địa chỉ tương đối của điểm ảnh
	sw	$s5, SCREEN($t1)	# Draw ảnh

	add	$t1, $s0, $a1		# Xi = x0 + j
	add	$t4, $s1, $a0		# Yi = Y0 + i
	mul	$t2, $t4, $s3		# Yi * SCREEN_WIDTH
	add	$t1, $t1, $t2		# Xi + Yi * SCREEN_WIDTH
					# (Toạ độ 1 chiều của điểm ảnh)
	sll	$t1, $t1, 2		# Địa chỉ tương đối của điểm ảnh
	sw	$s5, SCREEN($t1)	# Draw ảnh
	
	jr	$ra


#-------------------------------------------------------------------------
# Các hàm di chuyển

moveToLeft:
	li	$s7, -DELTA_X
	li	$t8, 0
	jr	$ra 	
moveToRight:
	li	$s7, DELTA_X
	li	$t8, 0
	jr	$ra 	
moveToUp:
	li	$s7, 0
	li	$t8, -DELTA_Y
	jr	$ra 	
moveToDown:
	li	$s7, 0
	li	$t8, DELTA_Y
	jr	$ra 
speedUp:
	addi	$v0, $0, 20
	branchIfLessOrEqual($t6, $v0, end_speedUp)
	addi	$t6, $t6, -10
end_speedUp:
	jr	$ra
speedDown:
	addi	$t6, $t6, 10
	jr	$ra


#-------------------------------------------------------------------------
# Square Root
# Để sử dụng floating point thì phải chuyển sang coprocessor
# $v0 = S, $a0 = sqrt(S)

sqrt:
	mtc1	$v0, $f0	# Đưa từ $v0 vào $f0
	cvt.s.w	$f0, $f0 
	sqrt.s	$f0, $f0
	cvt.w.s	$f0, $f0 
	mfc1	$a0, $f0	# Đưa lại từ $f0 vào $a0
	jr	$ra
