.eqv SEVENSEG_LEFT 0xFFFF0011 		#Dia chi cua den led 7 doan trai
.eqv SEVENSEG_RIGHT 0xFFFF0010 		#Dia chi cua den led 7 doan phai
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012  
.eqv MASK_CAUSE_COUNTER 0x00000400 	#Bit 10: Counter interrupt
.eqv COUNTER 0xFFFF0013 		#Time Counter
.eqv KEY_CODE   0xFFFF0004         	#ASCII code from keyboard, 1 byte 
.eqv KEY_READY  0xFFFF0000        	#=1 if has a new keycode?   
.data
mang_so: .byte 	63, 6,  91, 79, 102, 109 ,125, 7, 127, 111	 #tu 0 den 9
string: .asciiz "Bo mon ky thuat may tinh" 
message1: .asciiz "Thoi gian hoan thanh: "
message2: .asciiz "(s) \nToc do go trung binh: "
message3: .asciiz " tu/phut\n"
Continue: .asciiz "Tiep tuc nhap?"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
# MAIN Procsciiz ciiz edure 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.text	#bien toan cuc : k0, k1, s0, s1, s2, s3, s4, s5, a1
MAIN:	li	$k0,  KEY_CODE              
	li  	$k1,  KEY_READY   
	li 	$t1, COUNTER		#Khoi tao bo dem timer
	sb 	$t1, 0($t1)
	addi	$s0, $0, 0		#Dem so ky tu trong 1s
	addi	$s1, $0, 0		#Dem tong so ky tu dung
	addi	$s2, $0, 0		#Dem tong so tu nhap vao
	addi	$s3, $0, 0		#Dem so lan counter_intr
	addi	$s4, $0, 0		#Luu tru ky tu truoc do
	addi	$s5, $0, 0		#Dem thoi gian (giay)
	la	$a1, string
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#VONG LAP VO HAN DE DOI INTERRRUPT
loop: 
	lw   	$t1, 0($k1)                 	#$t1 = [$k1] = KEY_READY              
	bne  	$t1, $zero, make_Keyboard_Intr	#Tao interrupt khi nhan duoc ky tu tu ban phim
	addi	$v0, $0, 32
	li	$a0, 5
	syscall
	b 	loop				#So lenh trong 1 vong lap = 6 => cu lap 5 lan thi tao 1 counter interrupt
	nop
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
make_Keyboard_Intr:
	teqi	$t1, 1
	b	loop				#Quay lai vong lap de cho doi su kien interrupt tiep theo
	nop

end_Main:

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#PHAN PHUC VU NGAT
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
.ktext 0x80000180

dis_int:li 	$t1, COUNTER 			#BUG: must disable with Time Counter
	sb 	$zero, 0($t1)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#LAY GIA TRI CUA THANH GHI C0.cause DE KIEM TRA LOAI INTERRUPT
get_Caus:mfc0 	$t1, $13 			#$t1 = Coproc0.cause
isCount:li 	$t2, MASK_CAUSE_COUNTER		#if Cause value confirm Counter..
	 and 	$at, $t1,$t2
	 bne 	$at,$t2, keyboard_Intr
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#NGAT DO BO DEM COUNTER
counter_Intr:
	blt	$s3, 40, continue		#Neu so lap ngat do counter = 40 : da du 1s -> khoi tao lai $s3, chieu toc do go ra DLS, tang bien dem thoi gian len 1
	jal	hien_thi
	addi	$s3, $0, 0			#Khoi tao lai $s3
	addi	$s5, $s5, 1			#Tang bien dem thoi gian(s)
	j	en_int 
	nop
continue:
	addi	$s3, $s3, 1			#Neu chua du 1s thi tang bien dem so lan ngat
	j 	en_int
	nop
keyboard_Intr:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
#NGAT DO BAN PHIM
kiem_tra_ky_tu:					#Kiem tra ky tu nhap vao
	lb	$t0, 0($a1)			#Lay ki tu thu i trong mang da cho
	lb	$t1, 0($k0)			#Lay ki tu nhap vao tu ban phim
	beq	$t1, $0, en_int			#Loi
	beq 	$t1, '\n', end_Program		#Ki tu la '\n', tien hanh kiem tra va in
	bne	$t0, $t1, kiem_tra_dau_cach	#Neu ki tu nhap vao va ki tu thu i trong mang da cho giong nhau -> dem so ki tu dung
	nop
	addi	$s1, $s1, 1			#Tang bien dem so ky tu dung
kiem_tra_dau_cach:				#Kiem tra ki tu nhap vao co phai la ' ' hay ko
	bne	$t1, ' ', end_Process		#Neu ky tu nhap vao == ' ' && ky tu truoc do != ' ' thi dem so tu da nhap
	nop
	beq	$s4, ' ', end_Process
	nop
	addi	$s2, $s2, 1			#Tang bien dem so tu da nhap
end_Process:
	addi	$s0, $s0, 1			#Tang so ky tu trong 1s len 1
	addi	$s4, $t1, 0			#Cap nhat lai ky tu truoc do
	addi	$a1, $a1, 1 			#Tang con tro len 1 <=> string+i
	j en_int
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CHIEU RA MAN HINH DIGITAL LAB SIM GIA TRI CUA $s0
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
hien_thi:
	addi	$sp, $sp, -4			
	sw	$ra, ($sp)
	addi	$t0, $0, 10
	div	$s0, $t0
	mflo	$v1				#Lay so hang chuc
	mfhi	$v0				#Lay so hang don vi
	la 	$a0, mang_so
	add	$a0, $a0, $v1
	lb 	$a0, 0($a0) 			#Set value for segments
	jal 	SHOW_7SEG_LEFT 			#Hien thi
	
	la 	$a0, mang_so 
	add	$a0, $a0, $v0
	lb 	$a0, 0($a0) 			#Set value for segments
	jal 	SHOW_7SEG_RIGHT 		#Hien thi
	
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
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# KET THUC CHUONG TRINH VA HIEN THI SO KY TU DUNG
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
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
CONTINUE:
	li $v0, 50
	la $a0, Continue
	syscall
	beq $a0, 0, MAIN		
	li $v0, 10
	syscall	 
	
# ----------------------- Ket thuc xu ly ngat --------------------------------------
en_int: 
	li 	$t1, COUNTER
	sb 	$t1, 0($t1)
	mtc0 	$zero, $13 			#Must clear cause reg
next_pc: mfc0 	$at, $14 			#$at <= Coproc0.$14 = Coproc0.epc
	 addi 	$at, $at, 4 			#$at = $at + 4 (next instruction)
	 mtc0 	$at, $14 			#Coproc0.$14 = Coproc0.epc <= $at
return: eret 					#Return from exception
