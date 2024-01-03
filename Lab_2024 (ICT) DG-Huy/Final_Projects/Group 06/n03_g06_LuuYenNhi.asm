#----------------------------------------------------------------------
                          #LUU YEN NHI
#----------------------------------------------------------------------
.eqv SEVENSEG_LEFT 0xFFFF0011 		#Dia chi led 7 doan trai
.eqv SEVENSEG_RIGHT 0xFFFF0010 		#Dia chi led 7 doan phai
.eqv IN_ADDRESS_HEXA_KEYBOARD       0xFFFF0012  #d/c đầu vào bàn phím hexa
.eqv MASK_CAUSE_COUNTER 0x00000400 	#Bit 10: bitmask cho ngắt của bộ đếm
.eqv COUNTER 0xFFFF0013 		#Time Counter
.eqv KEY_CODE   0xFFFF0004         	#mã ASCII từ bàn phím
.eqv KEY_READY  0xFFFF0000        	#=1 if has a new keycode  
.data
mang_so: .byte 	63, 6,  91, 79, 102, 109 ,125, 7, 127, 111	 #tu 0 den 9
string: .asciiz "bo mon ky thuat may tinh" 
message1:	.asciiz	"Thoi gian hoan thanh: "
message2: 	.asciiz	"(s) \nSo ki tu tren don vi thoi gian: "
message3:	.asciiz	" tu/phut\n"

#----------------------------------------------------------------------

.text	
	li	$k0,  KEY_CODE              
	li  	$k1,  KEY_READY   
	li 	$t1, COUNTER		#time counter
	sb 	$t1, 0($t1)
	addi	$s0, $0, 0		#Dem so ky tu trong 1s
	addi	$s1, $0, 0		#đếm tổng kí tự đúng
	addi	$s2, $0, 1		#đếm tổng kí tự nhập vào
	addi	$s3, $0, 0		#đếm số lần ngắt từ bộ đếm
	addi	$s4, $0, 0		#lưu kí tự trc đó
	addi	$s5, $0, 0		#đếm tgian(s)
	la	$a1, string
#-----------------------------------------------------------------------

loop: 
	lw   	$t1, 0($k1)                 	#$t1 = [$k1] = KEY_READY          
	bne  	$t1, $zero, make_Keyboard_Intr	#t1 != 0 <-> có kí tự từ bàn phím -> nhảy đến nhãn xử lí interrupt từ bàn phím
	addi	$v0, $0, 32
	li	$a0, 5
	
	syscall
	b 	loop				
#-----------------------------------------------------------------------
make_Keyboard_Intr:
	teqi	$t1, 1   #nếu bằng 1 sẽ xác đinh trạng thái ngắt
	b	loop				#Quay lai vong lap de cho doi su kien interrupt tiep theo
	nop
end_Main:


#-----------------------------------------------------------------------
.ktext 0x80000180

dis_int:li 	$t1, COUNTER 			
	sb 	$zero, 0($t1)

#Kiểm tra loại interrupt 
get_Caus:mfc0 	$t1, $13 			#$t1 = Coproc0.cause, lấy giá trị nguyên nhân ngắt
isCount:li 	$t2, MASK_CAUSE_COUNTER	
	 and 	$at, $t1,$t2
	 bne 	$at,$t2, keyboard_Intr
#---------------------------------------------------------------------
#NGAT DO BO DEM COUNTER
counter_Intr:
	blt	$s3, 40, continue		#biến đếm số lần ngắt đã đủ timer chưa nếu chưa đủ, nhảy đến continue và tăng biến đếm số lần ngắt lên 1
	jal	hien_thi                       #nếu đủ (1s) thì hiển thị 
	addi	$s3, $0, 0			#khởi tạo lại biến đếm số lần ngắt
	addi	$s5, $s5, 1			#tăng biến đếm th�?i gian lên 1
	j	en_int 
	nop
continue:
	addi	$s3, $s3, 1			
	j 	en_int
	nop
keyboard_Intr:
#-------------------------------------------------------------------

check_Matching:					
	lb	$t0, 0($a1)			#lấy kí tự thứ i trong mảng
	beq	$t0, $0, end_Program		#dừng ct nếu gặp null
	lb	$t1, 0($k0)			#lấy kí tự nhập vào từ bàn phím
	beq	$t1, $0, en_int			
	bne	$t0, $t1, check_Space		#kí tự nhập vào và kí tự từ string k khớp -> check space 
	nop
	addi	$s1, $s1, 1			#còn nếu = nhau thì biến đếm kí tự đúng(s1) tăng lên 1
check_Space:					
	bne	$t1, ' ', end_Process		#kí tự nhập vào != ' ' và trc nó là ' ' thì tăng biến đếm số kí tự nhập vào lên
	nop
	beq	$s4, ' ', end_Process          #s4 kí tự trc đó từ bàn phím
	nop
	addi	$s2, $s2, 1			
end_Process:
	addi	$s0, $s0, 1			#Tang so ky tu trong 1s len 1
	addi	$s4, $t1, 0			#Cap nhat lai thanh ghi chua ky tu nhap vao ban phim truoc do
	addi	$a1, $a1, 1 			#Tang con tro len 1 <=> string+i, ktra kí tự tiếp theo
#---------------------------------------------------------------------------------
en_int: 
	li 	$t1, COUNTER                    
	sb 	$t1, 0($t1)
	mtc0 	$zero, $13 			
next_pc: mfc0 	$at, $14 			
	 addi 	$at, $at, 4 			
	 mtc0 	$at, $14 			
return: eret 					


#--------------------------------------------------------------------------------------
hien_thi:
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	addi	$t0, $0, 10
	div	$s0, $t0
	mflo	$v1				#số hàng chục
	mfhi	$v0				#số hàng đơn vị
	la 	$a0, mang_so
	add	$a0, $a0, $v1
	lb 	$a0, 0($a0) 			#Set value for segments
	jal 	SHOW_7SEG_LEFT 			
	la 	$a0, mang_so 
	add	$a0, $a0, $v0
	lb 	$a0, 0($a0) 			#Set value for segments
	jal 	SHOW_7SEG_RIGHT 		
	addi	$s0, $0, 0			#Sau khi chieu ra man hinh thi khoi tao lai bien dem
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr 	$ra
SHOW_7SEG_LEFT: 
	li 	$t0, SEVENSEG_LEFT 		#Assign port's address
	sb 	$a0, 0($t0) 			#Assign new value
	jr 	$ra
SHOW_7SEG_RIGHT: 
	li 	$t0, SEVENSEG_RIGHT 		#Assign port's address
	sb 	$a0, 0($t0) 			#Assign new value
	jr 	$ra
	nop


#----------------------------------------------------------------------------
end_Program:
	addi	$v0, $0, 4
	 la	$a0, message1
	 syscall
	 addi	$v0, $0, 1
	 addi	$a0, $s5, 0
	 syscall
	 addi	$v0, $0, 4
	 la	$a0, message2
	 syscall
	 
	 addi	$v0, $0, 1
	 addi	$a0, $0, 60
	 mult	$s2, $a0
	 mflo	$s2
	 div	$s2, $s5
	 mflo	$a0
	 syscall
	 addi	$v0, $0, 4
	 la	$a0, message3
	 syscall
	 addi	$s0, $s1, 0
	 jal	hien_thi
	 
	
	 
	 


