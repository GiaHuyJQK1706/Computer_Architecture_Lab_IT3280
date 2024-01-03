######################################################################
# 			     Circle 	                              #  
######################################################################
#                                                                    #
######################################################################
#	This program requires the Keyboard and Display MMIO          #
#       and the Bitmap Display to be connected to MIPS.              #
#								       #
#       Bitmap Display Settings:                                     #
#	Unit Width: 1						       #
#	Unit Height: 1						       #
#	Display Width: 512					       #
#	Display Height: 512					       #
######################################################################


#Author: Kiều Thái Thịnh	
#Student_ID:	20215246

#Create date: 21/12/2023

#Hanoi university of science and technology.


.data
.eqv KEY_CODE 0xFFFF0004 # ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 # =1 if has a new keycode ?
 # Auto clear after lw
.eqv DISPLAY_CODE 0xFFFF000C # ASCII code to show, 1 byte
.eqv DISPLAY_READY 0xFFFF0008 # =1 if the display has already to do
 # Auto clear after sw
 
.eqv MONITOR_SCREEN 0x10010000
.eqv GREEN 0x0000FF00
.eqv BLACK 0x00000000

.text
	#ban đầu vẽ hình tròn ở giữa
main:	li $t8, 256
	li $t9, 256
	li $t0, GREEN
	jal draw_circle
	
main_1:		#hàm nhập vào lệnh và xử lý lệnh
 		li $k1, KEY_READY
 		li $k0, KEY_CODE
 		li $s0, DISPLAY_CODE
 		li $s1, DISPLAY_READY
		nop
	li $t2, -1
	li $t3, -1
	li $t4, 64 	#ban đầu tốc độ trung binhf
			#lưu trữ tốc độ, tương đương thời gian ngủ
			#mỗi lần ngủ càng ngắn càng nhanh
	#li $t5, 0	#dùng để check riêng hệ thống speed run
	li $t6, 2
	
	
 
	WaitForKey: 	lw $t1, 0($k1) # $t1 = [$k1] = KEY_READY
 			beq $t1, $zero, WaitForKey # if $t1 == 0 then Polling 
 						#hàm này có ý nghĩa muốn pass qua được cần nhập một từ vào keybroad
 			j ReadKey
 	input:		lw $t1, 0($k1)
 			beq $t1, $zero, duplicate_state
	ReadKey: 	lw $t0, 0($k0) # $t0 = [$k0] = KEY_CODE
			# khi không trùng trạng thái 
 			addi $t2, $t0, 0 #cập nhật lại trạng thái cũ
 			beq $t0, 'z', speed_up
 			beq $t0, 'x', speed_down
 			beq $t0, 'd', turn_right_1
 			beq $t0, 'a', turn_left_1
 			beq $t0, 'w', turn_up_1
 			beq $t0, 's', turn_down_1
 			beq $t0, 'p', WaitForKey #ấn p sẽ dừng 
 			j exit_program
 			
 	duplicate_state:	beq $t3, 0, turn_right
 				beq $t3, 1, turn_left
 				beq $t3, 2, turn_up
 				beq $t3, 3, turn_down
 	
draw_circle:	#cung cấp trước giá trị vi trí tâm là $t8, $t9 lần lượt thuộc trục ox và oy
		#bán kính hình tròn là 10
		
		#tính vị trí tâm hình tròn
		li $s4, MONITOR_SCREEN
		add $s1, $t8, 0
		mul $s2, $t9, 512
		add $s1, $s2, $s1
		mul $s1, $s1, 4
		add $s4, $s4, $s1
		
		#xác định vị trí đầu tiên của hình tròn để bắt đầu vẽ
		#512*10+10
		li $s2, 5130
		mul $s2, $s2, 4
		sub $s4, $s4, $s2
		
		li $s7, 0
		draw_first_line:	addi $s5, $s4, 0
					addi $s4, $s4, 24
					li $s3, 0
					loop_1_1:	beq $s3, 8, out_loop_1_1
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_1_1
					out_loop_1_1:	addi $s4, $s5, 0
							li $s2, 512
							mul $s2, $s2, 4
							add $s4, $s4, $s2
							beq $s7, 1, finish_circle
		draw_second_line:	addi $s5, $s4, 0
					addi $s4, $s4, 16
					li $s3, 0
					loop_2_1:	beq $s3, 12, out_loop_2_1
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_2_1
					out_loop_2_1:	addi $s4, $s5, 0
							li $s2, 512
							mul $s2, $s2, 4
							add $s4, $s4, $s2
							beq $s7, 1, draw_first_line
		draw_third_line:	addi $s5, $s4, 0
					addi $s4, $s4, 8
					li $s3, 0
					loop_3_1:	beq $s3, 4, out_loop_3_1
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_3_1
					out_loop_3_1:	addi $s4, $s4, 32
							li $s3, 0
					loop_3_2:	beq $s3, 4, out_loop_3_2
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_3_2
					out_loop_3_2:	addi $s4, $s5, 0
							li $s2, 512
							mul $s2, $s2, 4
							add $s4, $s4, $s2
							beq $s7, 1, draw_second_line
		draw_fourth_line:	addi $s5, $s4, 0
					addi $s4, $s4, 8
					li $s3, 0
					loop_4_1:	beq $s3, 2, out_loop_4_1
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_4_1
					out_loop_4_1:	addi $s4, $s4, 48
							li $s3, 0
					loop_4_2:	beq $s3, 2, out_loop_4_2
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_4_2
					out_loop_4_2:	addi $s4, $s5, 0
							li $s2, 512
							mul $s2, $s2, 4
							add $s4, $s4, $s2
							beq $s7, 1, draw_third_line
		draw_fifth_line:	addi $s5, $s4, 0
					addi $s4, $s4, 4
					li $s3, 0
					loop_5_1:	beq $s3, 2, out_loop_5_1
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_5_1
					out_loop_5_1:	addi $s4, $s4, 56
							li $s3, 0
					loop_5_2:	beq $s3, 2, out_loop_5_2
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_5_2
					out_loop_5_2:	addi $s4, $s5, 0
							li $s2, 512
							mul $s2, $s2, 4
							add $s4, $s4, $s2
							beq $s7, 1, draw_fourth_line
		draw_sixth_line:	addi $s5, $s4, 0
					li $s3, 0
					loop_6_1:	beq $s3, 3, out_loop_6_1
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_6_1
					out_loop_6_1:	addi $s4, $s4, 56
							li $s3, 0
					loop_6_2:	beq $s3, 3, out_loop_6_2
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_6_2
					out_loop_6_2:	addi $s4, $s5, 0
							li $s2, 512
							mul $s2, $s2, 4
							add $s4, $s4, $s2
							beq $s7, 1, draw_fifth_line
			li $s6, 0
		draw_8_rows:	beq $s6, 8, out_draw_8_rows
					addi $s5, $s4, 0
					li $s3, 0
					loop_7_1:	beq $s3, 2, out_loop_7_1
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_7_1
					out_loop_7_1:	addi $s4, $s4, 64
							li $s3, 0
					loop_7_2:	beq $s3, 2, out_loop_7_2
							sw $t0, 0($s4)
							addi $s4, $s4, 4
							addi $s3, $s3, 1
							j loop_7_2
					out_loop_7_2:	addi $s4, $s5, 0
							li $s2, 512
							mul $s2, $s2, 4
							add $s4, $s4, $s2
							addi $s6, $s6, 1
							j draw_8_rows
		out_draw_8_rows: 	addi $s7, $s7, 1 #check để vẽ nốt hình tròn
					j draw_sixth_line
finish_circle: #kết thúc vẽ hình tròn
		jr $ra
 				
speed_up:	#tăng tốc độ
		addi $t5, $t5, 1
		beq $t4, 1, duplicate_state #tốc độ nhanh nhất không cần tăng nữa
		div $t4, $t6
		mflo $t7
		addi $t4, $t7, 0
		j duplicate_state
		
speed_down:	#giảm tốc độ
		addi $t5, $t5, 1
		beq $t4, 1024, duplicate_state #tốc độ thấp nhất không cần tăng nữa
		mul $t4, $t4, 2
		j duplicate_state

turn_right_1:	li $t3, 0	#định nghĩa nếu bằng 0 thì đi sang phải
turn_right:	li $t0, BLACK
		jal draw_circle
		addi $t8, $t8, 2
		li $t0, GREEN
		jal draw_circle
		jal speed
		beq $t8, 502, change_direction_right
		j input
change_direction_right:	#khi đến vị trí này cần đi ngược lại bên trái
			li $t3, 1
			j input
			
turn_left_1:	li $t3, 1	#định nghĩa nếu bằng 1 thì đi sang trái
turn_left:	li $t0, BLACK
		jal draw_circle
		sub $t8, $t8, 2
		li $t0, GREEN
		jal draw_circle
		jal speed
		beq $t8, 10, change_direction_left
		j input
change_direction_left:	#khi đến vị trí này cần đi ngược lại bên phải
			li $t3, 0
			j input

turn_up_1:	li $t3, 2	#định nghĩa nếu bằng 1 thì đi sang trái
turn_up:	li $t0, BLACK
		jal draw_circle
		sub $t9, $t9, 2
		li $t0, GREEN
		jal draw_circle
		jal speed
		beq $t9, 10, change_direction_up
		j input
change_direction_up:	#khi đến vị trí này cần đi ngược lại bên phải
			li $t3, 3
			j input
			
turn_down_1:	li $t3, 3	#định nghĩa nếu bằng 1 thì đi sang trái
turn_down:	li $t0, BLACK
		jal draw_circle
		addi $t9, $t9, 2
		li $t0, GREEN
		jal draw_circle
		jal speed
		beq $t9, 502, change_direction_down
		j input
change_direction_down:	#khi đến vị trí này cần đi ngược lại bên phải
			li $t3, 2
			j input

speed: 	addi $a0, $t4, 0
 	li $v0, 32 
 	syscall 
 	jr $ra
exit_program:

#t8, t9 lần lượt lưu trữ giá trị trục ox, oy





