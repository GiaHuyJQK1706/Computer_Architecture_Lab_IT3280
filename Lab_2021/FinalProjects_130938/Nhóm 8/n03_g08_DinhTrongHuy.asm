.eqv SEVENSEG_LEFT    0xFFFF0011 # Dia chi cua den led 7 doan trai	
					#Bit 0 = doan a         
					#Bit 1 = doan b	
					#Bit 7 = dau . 
.eqv SEVENSEG_RIGHT   0xFFFF0010 # Dia chi cua den led 7 doan phai 

.eqv KEY_READY  0xFFFF0000        	# =1 if has a new keycode, auto clear after lw
.eqv KEY_CODE   0xFFFF0004         # ascii của ký tự nhập từ bàn phím
                                         
.eqv DISPLAY_CODE   0xFFFF000C   	# show ascii
.eqv DISPLAY_READY  0xFFFF0008   	# =1 if the display has already to do  
	                                # Auto clear after sw  
.eqv KEYBOARD_CAUSE   0x0000034     # Keyboard Cause    
  
.data 
bytehex     : .byte 63,6,91,79,102,109,125,7,127,111    # hiển thị led
                                                        # chữ số từ 0->9
input_string : .space 1000	# lưu ký tự nhập từ bàn phím
string_origin : .asciiz "bo mon ky thuat may tinh" 
Message1: .asciiz "\nSo ky tu trong 1s:  "
Message2: .asciiz "\nBan vua nhap: "
right_num: .asciiz  "\nSo ky tu nhap dung la: "  
ask_return: .asciiz "\nBan co muon quay lai chuong trinh khong? "
speed1: .asciiz "\nToc do danh may trung binh: "
speed2: .asciiz " ky tu/giay\n"

.text
        li   $k0,  KEY_CODE              
	li   $k1,  KEY_READY                    
	li   $s0, DISPLAY_CODE              
	li   $s1, DISPLAY_READY 
MAIN:
	li $s3, 0  # đếm số vòng lặp
	li $s4, 0  # đếm số ký tự nhập vào
	li $s5, 10   # để chia 10, lưu ở led trái
	li $s6, 250   # lưu số vòng lặp, chính là đơn vị thời gian để đo (4*250=1000ms=1s)
	li $t4, 0     # đếm số ký tự nhập dc trong 1 khoảng thời gian
	li $t5, 0
	li $t6, 0    # đếm tổng thời gian
LOOP:
WAIT_KEY:
	lw $t1, 0($k1)   # $t1 = KEY_READY 
	beqz $t1, KT_ky_tu      # $t1==1 then pooling 
DEM:
	addi $t4,$t4,1    		#tang bien dem ky tu nhap duoc trong 1s len 1
	teqi $t1, 1                       # nếu $t1 = 1 thì trap
KT_ky_tu:   # lặp 250 vòng xong thì xử lý ký tự 
	addi $s3, $s3, 1     # tăng số vòng lặp 
	div $s3, $s6
	mfhi $t7       # chia số vòng lặp cho 250, nếu dư=0 thì là được 1 vòng
	bnez $t7, SLEEP   # nếu chưa được 1 vòng thì sleep
# Nếu đã được 1 vòng thì in ra màn hình
PRINT_COUNT:
	li $s3, 0   # thiết lập lại cho lần đếm tiếp theo
	la $a0, Message1
	li $v0, 4   # in ra message
	syscall
	
	li $v0, 1   # in ra số ký tự trong 1 chu kỳ
	add $a0, $t4, $zero
	syscall
LED_DISPLAY:
	div $t4, $s5    # số ký tự nhập trong 1 chu kỳ chia 10
	mflo $t7        # lấy phần nguyên (để hiển thị ở led trái)
	la $s2, bytehex   # lấy mảng lưu giá trị từng chữ số đèn led
	add $s2, $s2, $t7    # lấy chữ số cần hiển thị
	lb $a0,0($s2)
	jal   SHOW_7SEG_LEFT    # hiện thị phần nguyên ở led trái
	
	mfhi $t7          # lấy phần dư (để hiển thị ở led phải)
	la $s2, bytehex   # lấy mảng lưu giá trị từng chữ số đèn led
	add $s2, $s2, $t7    # lấy chữ số cần hiển thị
	lb $a0,0($s2)
	jal   SHOW_7SEG_RIGHT    # hiện thị phần dư ở led phải
	
	li $t4, 0   # reset về 0 để bắt đầu chu kỳ mới
	beq $t5, 1, ASK_CONTINUE
	
SLEEP:	
	addi $t6, $t6, 4
	addi $v0, $zero, 32                   
	li $a0, 4              	# sleep 4 ms         
	syscall         
	nop           	                    
	b LOOP          	 # trở lại Loop 
END_MAIN:
	li $v0, 10
	syscall

SHOW_7SEG_LEFT:  
	li   $t0,  SEVENSEG_LEFT 	# assign port's address                   
	sb   $a0,  0($t0)        	# assign new value                    
	jr   $ra 
SHOW_7SEG_RIGHT: 
	li   $t0,  SEVENSEG_RIGHT 	# assign port's address                  
	sb   $a0,  0($t0)         	# assign new value                   
	jr   $ra 
	
# Xử lý trap
.ktext 0x80000180   # mips exception vector
	mfc0 $t1, $13   # examine cause register
	li $t2, KEYBOARD_CAUSE
	and   $at, $t1,$t2              
	beq   $at,$t2, READ_KEYBOARD            
	j    END_PROCESS  
	
#COUNTER_KEYBOARD:
READ_KEYBOARD:  lb   $t0, 0($k0)            # $t0 = KEY_CODE 
DISPLAY_WAIT: 
	lw   $t2, 0($s1)            	# $t2 = DISPLAY_READY            
	beq  $t2, $zero, DISPLAY_WAIT
LOAD_KEY: 
	sb $t0, 0($s0)              	# load ký tự vừa nhập từ bàn phím
        la  $t7, input_string			# $s7 là địa chỉ chuỗi nhập vào
        add $t7, $t7, $s4		
        sb $t0, 0($t7)
        addi $s4, $s4, 1
        beq $t0, 10, END           # đến "\n" thì kết thúc, bắt đầu so sánh             
END_PROCESS:
# Trap handler in the standard MIPS32 kernel text segment
TRAP_HANDLER:
	mfc0 $at,$14   # Coprocessor 0 register $14 has address of trapping instruction
   	addi $at,$at,4 # Add 4 to point to next instruction
   	mtc0 $at,$14   # Store new address back into $14
   	eret           # Error return; set PC to value in $14
END:
SPEED_COUNT:  # đếm tốc độ gõ phím
	mtc1 $t6, $f1    # f1 là tổng thời gian gõ
	cvt.s.w $f1, $f1
	
	mtc1 $s5, $f3    # f3 = 10
	cvt.s.w $f3, $f3
	
	mtc1 $s4, $f2    # f2 là tổng số ký tự
	cvt.s.w $f2, $f2
	
	# đổi từ ms -> s
	div.s $f1, $f1, $f3
	div.s $f1, $f1, $f3
	div.s $f1, $f1, $f3
	
	div.s $f2, $f2, $f1  # tổng ký tự / tổng thời gian gõ
COMPARE_LENGTH:
	li $v0, 11
	li $a0, '\n'    # xuống dòng
	syscall
	li $t1, 0       # đếm số ký tự được xét
	li $t3, 0       # đếm số ký tự nhập đúng
	li $t8, 24      # độ dài của string_origin
	
	slt $t7,$s4,$t8			# so sánh độ dài xâu nhập từ bàn phím và xâu ban đầu
					# xâu nào ngắn hơn thì duyệt theo xâu đó
	li $v0, 4
	la $a0, Message2
	syscall
	
	bne $t7,1, PRINT_INPUT        # nếu $s4>$t8 thì check theo $t8
	add $t8, $zero, $s4            # nếu không thì xét theo $s4
	addi $t8, $t8, -1			# trừ 1 vì không xét '\n'

PRINT_INPUT:   # in ra string nhập từ bàn phím
	la $t2, input_string
	add $t2, $t2, $t1
	lb $t9, 0($t2)      
        
        li $v0, 11
        move $a0, $t9
        syscall
        
        addi $t1, $t1, 1
        bge $t1, $s4, PRINT_SPEED
        j PRINT_INPUT
PRINT_SPEED:        
        # in tốc độ gõ phím trung bình
        li $v0,4
	la $a0,speed1
	syscall
	li $v0, 2
	mov.s $f12, $f2
	syscall
	li $v0,4
	la $a0,speed2
	syscall
        
RESET_1:
	li $t1, 0
CHECK_STRING:
	la $t2, input_string
	add $t2,$t2,$t1
	lb $t9, 0($t2)			# lấy ký tự thứ $t1 trong input_string lưu vào $t9 để so sánh với ký tự thứ $t1 ở string_origin
	
	la $s7, string_origin
	add $s7, $s7, $t1
	lb $t4, 0($s7)                 # lưu ký tự thứ $t1 trong string_origin lưu vào $t4
	
	bne $t4, $t9, CONTINUE         # nếu khác nhau thì vào CONTINUE, giống thì tăng $t3 rồi vào CONTINUE
	addi $t3, $t3, 1
CONTINUE:
	addi $t1, $t1, 1
	beq $t1, $t8, PRINT_RIGHT          # nếu duyệt hết thì print
	j CHECK_STRING

PRINT_RIGHT: 
	li $v0, 4
	la $a0, right_num
	syscall
	
	li $v0, 1
	add $a0, $t3, $zero   # in số ký tự đúng
	syscall
	
	li $t5, 1
	li $t4, 0
	add $t4, $t3, $zero
	b LED_DISPLAY
ASK_CONTINUE:
	li $v0, 50
	la $a0, ask_return
	syscall
	beq $a0, 0, MAIN		
	b EXIT
EXIT:
	li $v0, 10
	syscall
	
	



	
	
	
