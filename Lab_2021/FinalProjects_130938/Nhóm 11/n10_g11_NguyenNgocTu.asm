# Bai 10: 
# MSSV: 20205135

.eqv	SEVENSEG_LEFT	0xFFFF0011	# Dia chi cua den led 7 doan trai.
					# 	bit 0 = doan a;
					# 	bit 1 = doan b;
					#	bit 7 = dau .
.eqv	SEVENSEG_RIGHT	0xFFFF0010	# Dia chi cua den led 7 doan phai.
.eqv 	IN_ADDRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv 	OUT_ADDRESS_HEXA_KEYBOARD 	0xFFFF0014

.data
# ma hoa cua Digital Lab Sim
zero:  		.byte 0x3f
one:   		.byte 0x6
two:   		.byte 0x5b
three: 		.byte 0x4f
four:  		.byte 0x66
five:  		.byte 0x6d
six:   		.byte 0x7d
seven: 		.byte 0x7
eight: 		.byte 0x7f
nine:  		.byte 0x6f

mess1: 	.asciiz 	"Ket qua khong ton tai.Khong the chia cho so 0 \n"

.text
main:

Khoi_tao:
	li 	$t0, SEVENSEG_LEFT     	#Bien gia tri so cua den LED trai
        li 	$t5, SEVENSEG_RIGHT     #Bien gia tri so cua den LED phai
        li 	$s0, 0      		#Bien kiem tra loai bien nhap vao: (0: so), (1 :toan tu)
        li 	$s1, 0     		#so hien thi o led phai
        li 	$s2, 0   		#so hien thi o led trai
        li 	$s3, 0     		#bien kiem tra loai toan tu (1: +, 2: -, 3: *, 4: /, 5: %)
        li 	$s4, 0      		#so thu nhat
        li 	$s5, 0   		#so thu hai
        li 	$s6, 0     		#ket qua phep tinh: '+' , '-', '*', '/', '%' 
        li 	$t9, 0 			#gia tri tam thoi
	
	li 	$t1, IN_ADDRESS_HEXA_KEYBOARD  	#bien dieu khien hang keyboard va enable keyboard interrupt
	li 	$t2, OUT_ADDRESS_HEXA_KEYBOARD 	#bien chua vi tri key nhap vao the hang va cot
	li 	$t3, 0x80			# bit dung enable keyboard interrupt va enable kiem tra tung hang keyboard
	sb 	$t3, 0($t1)
	li 	$t7, 0       		#gia tri cua so hien tren led
	li 	$t4, 0			#byte hien thi len led, zero->nine
	
First_value:
	li 	$t7, 0        		#gia tri cua bit can hien thi ban dau
	addi 	$sp,$sp, 4		#day vao stack
        sb 	$t7, 0($sp)	
	lb 	$t4, zero 		#bit dau tien can hien thi
	addi 	$sp, $sp, 4  		#day vao stack
        sb 	$t4, 0($sp)

Loop1:
	nop
	nop
	nop
	nop
	b 	Loop1		#Wait for interrupt
	nop
	nop
	nop
	nop
	b 	Loop1		#Wait for interrupt
	nop
	nop
	nop
	nop
	b 	Loop1		#Wait for interrupt
end_loop1:

end_main:
	li 	$v0, 10
	syscall
	
#--------------------------------------------------------------
# Xu ly khi xay ra interupt
# Hien thi so vua bam len den led 7 doan
# Kiem tra tung hang xem co duoc bam hay khong
#--------------------------------------------------------------

.ktext 0x80000180
#--------------------------------------------------------------
# Processing
# Neu hang co phim duoc nhap -> chuyen toi hang do
#--------------------------------------------------------------

	jal 	check_row1		#Kiem tra hang 1 xem co phim nao duoc nhap hay khong
	bnez 	$t3, convert_row1	#t3 != 0 -> co phim duoc nhap, kiem tra cac phim trong hang, lay phim do ra
	nop
	
	jal 	check_row2		#Kiem tra hang 2 xem co phim nao duoc nhap hay khong		
	bnez 	$t3, convert_row2	#t3 != 0 -> co phim duoc nhap, kiem tra cac phim trong hang, lay phim do ra
	nop
	
	jal 	check_row3		#Kiem tra hang 3 xem co phim nao duoc nhap hay khong
	bnez 	$t3, convert_row3	#t3 != 0 -> co phim duoc nhap, kiem tra cac phim trong hang, lay phim do ra
	nop
	
	jal 	check_row4		#Kiem tra hang 4 xem co phim nao duoc nhap hay khong
	bnez 	$t3, convert_row4	#t4 != 0 -> co phim duoc nhap, kiem tra cac phim trong hang, lay phim do ra


#-------------------------------------------------------
#Kiem tra tung hang mot xem phim duoc nhap o hang nao
#-------------------------------------------------------
check_row1:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 		#luu ra lai vi ve sau co the doi 
        li 	$t3, 0x81     		#Kich hoat interrupt, cho phep bam phim o hang 1
        sb 	$t3, 0($t1)
        jal 	Get_value		#lay vi tri cua phim duoc nhap (neu co)
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

check_row2:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 		#luu ra lai vi ve sau co the doi 
        li 	$t3, 0x82   		#Kich hoat interrupt, cho phep bam phim o hang 2
        sb 	$t3, 0($t1)
        jal 	Get_value		#lay vi tri cua phim duoc nhap (neu co)
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

check_row3:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 		#luu ra lai vi ve sau co the doi 
        li 	$t3, 0x84     		#Kich hoat interrupt, cho phep bam phim o hang 3
        sb 	$t3, 0($t1)
        jal 	Get_value		#lay vi tri cua phim duoc nhap (neu co)
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

check_row4:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 		#luu ra lai vi ve sau co the doi 
        li 	$t3, 0x88     		#Kich hoat interrupt, cho phep bam phim o hang 4
        sb 	$t3, 0($t1)
        jal 	Get_value		#lay vi tri cua phim duoc nhap (neu co)
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra


#--------------------------------------
# Lay gia tri cua phim vua duoc nhap
#--------------------------------------
Get_value:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp) 
        li 	$t2, OUT_ADDRESS_HEXA_KEYBOARD 	#dia chi chua vi tri phim duoc nhap
        lb 	$t3, 0($t2)			#load vi tri phim duoc nhap
        lw 	$ra, 0($sp)
        addi 	$sp, $sp, -4
        jr 	$ra

#------------------------------------------
#Convert tu vi tri sang bit 
#------------------------------------------

#------------------------------------------
#Convert hang 1: co 4 gia tri: 0, 1, 2, 3
#Ma hoa tuong ung la:	zero:  .byte 0x3f
#			one:   .byte 0x6
#			two:   .byte 0x5b
#			three: .byte 0x4f
#-----------------------------------------

convert_row1:	
	beq 	$t3, 0x11, case_0		# 0x11 -> so 0
	beq 	$t3, 0x21, case_1		# 0x21 -> so 1		
	beq 	$t3, 0x41, case_2		# 0x41 -> so 2
	beq 	$t3, 0xffffff81, case_3		# 0xffffff81 -> so 3
case_0:
	lb 	$t4,zero	#t4 = zero (Ma hoa cua '0' tren Digital Lab Sim)
	li 	$t7,0		#t7= 0
	j 	update_tg
case_1:
	lb 	$t4,one		#t4 = one (Ma hoa cua '1' tren Digital Lab Sim)
	li 	$t7,1		#t7 = 1
	j 	update_tg
case_2:
	lb	$t4,two		#t4 = two (Ma hoa cua '2' tren Digital Lab Sim)
	li 	$t7,2		#t7 = 2
	j	update_tg
case_3:
	lb 	$t4, three	#t4 = three (Ma hoa cua '3' tren Digital Lab Sim)
	li 	$t7, 3		#t7 = 3
	j 	update_tg

#------------------------------------------
#Convert hang 2: co 4 gia tri: 4, 5, 6, 7
#Ma hoa tuong ung la: 	four:  .byte 0x66
#			five:  .byte 0x6d
#			six:   .byte 0x7d
#			seven: .byte 0x7
#-----------------------------------------

convert_row2:	
	beq 	$t3, 0x12, case_4		# 0x12 -> so 4
	beq 	$t3, 0x22, case_5		# 0x22 -> so 5		
	beq 	$t3, 0x42, case_6		# 0x42 -> so 6
	beq 	$t3, 0xffffff82, case_7		# 0xffffff82 -> so 7
case_4:
	lb 	$t4, four	#t4 = four (Ma hoa cua '4' tren Digital Lab Sim)
	li 	$t7, 4		#t7= 4
	j 	update_tg
case_5:
	lb 	$t4, five	#t4 = five (Ma hoa cua '5' tren Digital Lab Sim)
	li 	$t7, 5		#t7 = 5
	j 	update_tg
case_6:
	lb	$t4, six	#t4 = six (Ma hoa cua '6' tren Digital Lab Sim)
	li 	$t7,6		#t7 = 6
	j	update_tg
case_7:
	lb 	$t4, seven	#t4 = sevent (Ma hoa cua '7' tren Digital Lab Sim)
	li 	$t7, 7		#t7 = 7
	j 	update_tg

#------------------------------------------
#Convert hang 3: co 4 gia tri: 8, 9, a, b
#Ma hoa tuong ung la: 	eight: .byte 0x7f
#			nine:  .byte 0x6f
#-----------------------------------------

convert_row3:	
	beq 	$t3, 0x14, case_8		# 0x12 -> so 8
	beq 	$t3, 0x24, case_9		# 0x22 -> so 9		
	beq 	$t3, 0x44, case_a		# 0x42 -> phim a
	beq 	$t3, 0xffffff84, case_b		# 0xffffff82 -> phim b
case_8:
	lb 	$t4, eight	#t4 = eight (Ma hoa cua '8' tren Digital Lab Sim)
	li 	$t7, 8		#t7= 8
	j 	update_tg
case_9:
	lb 	$t4, nine	#t4 = nine (Ma hoa cua '9' tren Digital Lab Sim)
	li 	$t7, 9		#t7 = 9
	j 	update_tg

#------------------------------
#Truong hop phim a (phep cong)
#------------------------------
case_a:	
	addi 	$a3, $zero, 1
	addi 	$s0, $s0, 1          	#s0 = 1 -> toan tu duoc nhap vao
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 1		#s3 = 1 -> phep cong
	
	j 	set_first_number        #chuyen den ham chuyen 2 byte dang hien tren 2 led thanh so de tinh toan 
	
#-----------------------------
#Truong hop phim b (phep tru)
#----------------------------
case_b:
	addi 	$a3, $zero, 2
	addi 	$s0, $s0, 1		#s0 = 1 -> toan tu duoc nhap vao
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 2		#s3 = 2 -> phep tru
	j 	set_first_number

#------------------------------------------
#Convert hang 4: co 4 gia tri: c, d, e, f
#-----------------------------------------

convert_row4:	
	beq 	$t3, 0x18, case_c		# 0x18 -> phim c
	beq 	$t3, 0x28, case_d		# 0x28 -> phim d	
	beq 	$t3, 0x48, case_e		# 0x48 -> phim e
	beq 	$t3, 0xffffff88, case_f		# 0xffffff88 -> phim f
	
#------------------------------
#Truong hop phim c (phep nhan)
#------------------------------
case_c:	
	addi 	$a3, $zero, 3
	addi 	$s0, $s0, 1          	#s0 = 1 -> toan tu duoc nhap vao
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 3		#s3 = 3 -> phep nhan
	
	j set_first_number        	#chuyen den ham chuyen 2 byte dang hien tren 2 led thanh so de tinh toan 
	
#-----------------------------
#Truong hop phim d (phep chia)
#----------------------------
case_d:
	addi 	$a3, $zero, 4
	addi 	$s0, $s0, 1		#s0 = 1 -> toan tu duoc nhap vao
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 4		#s3 = 4 -> phep chia lay phan nguyen
	j 	set_first_number

#------------------------------
#Truong hop phim e (phep %)
#------------------------------
case_e:	
	addi 	$a3, $zero, 5
	addi 	$s0, $s0, 1          	#s0 = 1 -> toan tu duoc nhap vao
	bne 	$s3, 0, set_next_operator
	addi 	$s3, $zero, 5		#s3 = 5 -> chia lay phan du
	j 	set_first_number        #chuyen den ham chuyen 2 byte dang hien tren 2 led thanh so de tinh toan 
	

#-----------------------------------
#Tinh so dau hien thi tren den led
#-----------------------------------
set_first_number:      
	addi 	$s4, $t9, 0
	li 	$t9, 0
	j 	done

#-----------------------------
#Truong hop phim f (=)
#----------------------------
case_f: 
	addi $s5, $t9, 0
	

#-------------------------------------------------
#Tinh so thu hai hien thi tren den led trong 2 so
#-------------------------------------------------
set_second_number:  
	beq 	$s3, 1, phep_cong	# s3 = 1 -> cong
	beq 	$s3, 2, phep_tru	# s3 = 2 -> tru
	beq 	$s3, 3, phep_nhan	# s3 = 3 -> nhan
	beq 	$s3, 4, phep_chia	# s3 = 4 -> chia
	beq	$s3, 5, phep_lay_du	# s3 = 5 -> lay du

phep_cong:
	add 	$s6, $s5, $s4
	li 	$s3, 0
	li 	$t9, 0 
	j 	in_phep_cong
	nop     		

#-------------------------------------------------
# In ra dinh dang: a + b = c \n
#-------------------------------------------------	
in_phep_cong:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '+'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		#reset $s5
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	nop
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	#Lay 2 gia tri cuoi cua ket qua 
	j show_result_in_led	#Hien thi ket qua tren led
	nop

phep_tru:
	sub 	$s6, $s4, $s5   
	li 	$s3, 0
	li 	$t9, 0 
	j 	in_phep_tru
	nop
	
#-------------------------------
#In ra dinh dang: a - b = c \n
#-------------------------------
in_phep_tru:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '-'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		#reset $s5
	
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6		    	#Lay 2 gia tri cuoi cua ket qua 
	j 	show_result_in_led	#Hien thi ket qua tren led
	nop

phep_nhan:
	mul 	$s6, $s4, $s5    
	li 	$s3, 0
	li 	$t9, 0 
	j 	in_phep_nhan
	nop
	
#-------------------------------------
#In ra dinh dang: a*b = c \n
#-------------------------------------
in_phep_nhan:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '*'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		#reset $s5
	
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	#Lay 2 chu so sau cung cua ket qua in ra
	j show_result_in_led    #Hien thi ket qua tren led
	nop

phep_chia:
	beq 	$s5, 0, chia_0	# kiem tra xem so chia co phai bang 0 hay khong 
	li 	$s3, 0
	div 	$s4, $s5   	    
	mflo 	$s6
	mfhi 	$s7
	li 	$t9, 0 
	j 	in_phep_chia
	nop

#---------------------------------
# Neu $s5 = 0 in ra: "Khong the chia cho so 0 \n"
#-------------------------------
chia_0: 
	li 	$v0, 55
	la 	$a0, mess1
	li 	$a1, 0
	syscall
	j 	reset_led

in_phep_chia:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '/'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		#reset $s5
	
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
		
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6		    	#Lay 2 gia tri cuoi cua ket qua 
	j 	show_result_in_led	#Hien thi ket qua tren led
	nop


phep_lay_du:
	beq 	$s5, 0, chia_lay_du_0	# kiem tra xem so chia co phai bang 0 hay khong 
	li 	$s3, 0
	div 	$s4, $s5   	    
	mflo 	$s7
	mfhi 	$s6
	li 	$t9, 0 
	j 	in_phep_lay_du
	nop

#---------------------------------
# Neu $s5 = 0 in ra: "Khong the chia cho so 0 \n"
#-------------------------------
chia_lay_du_0: 
	li 	$v0, 55
	la 	$a0, mess1
	li 	$a1, 0
	syscall
	j 	reset_led

in_phep_lay_du:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '%'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
		
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6		    	#Lay 2 gia tri cuoi cua ket qua 
	j 	show_result_in_led	#Hien thi ket qua tren led
	nop

#--------------------------------
#Hien thi ket qua tren den led
#So 'ab'
# Den trai = a = ab div 10
# Den phai = b = ab mod 10
#--------------------------------
show_result_in_led:
	li 	$t8, 10			# Gia tri trung gian = 10
	div 	$s6, $t8    		# $s6 = a
	mflo 	$t7        		# $t7 = result
	jal 	check    		#chuyen den ham chuyen t7 thanh bit hien thi len led

        sb 	$t4, 0($t0)  		# hien thi len led trai
     	add 	$sp, $sp, 4
	sb 	$t7, 0($sp)		#day gia tri bit nay vao stack
	add 	$sp, $sp, 4
	sb 	$t4, 0($sp)    		#day bit nay vao stack
	add 	$s2, $t7, $zero   	#s1 = gia tri bit led phai     
	
	mfhi 	$t7       	#t7 = remainder
	jal 	check    	#convert t7 thanh bit hien thi len led
        sb 	$t4, 0($t5)  	#hien thi len led phai 
       	add 	$sp, $sp, 4
	sb 	$t7, 0($sp)	# day gia tri bit nay vao stack
	add 	$sp, $sp, 4
	sb 	$t4, 0($sp)    	# day bit nay vao stack
	add 	$s1, $t7, $zero	# s1 = gia tri bit led phai
        j 	reset_led     	# ham reset lai led
           
check:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp)
        beq 	$t7, 0, check_0		# t7 = 0 -> Hien thi so 0 tren thanh led
        beq 	$t7, 1, check_1	   	# t7 = 1 -> Hien thi so 1 tren thanh led
        beq 	$t7, 2, check_2		# t7 = 2 -> Hien thi so 2 tren thanh led
        beq 	$t7, 3, check_3		# t7 = 3 -> Hien thi so 3 tren thanh led
        beq 	$t7, 4, check_4		# t7 = 4 -> Hien thi so 4 tren thanh led
        beq 	$t7, 5, check_5		# t7 = 5 -> Hien thi so 5 tren thanh led
        beq 	$t7, 6, check_6		# t7 = 6 -> Hien thi so 6 tren thanh led
        beq 	$t7, 7, check_7		# t7 = 7 -> Hien thi so 7 tren thanh led
        beq 	$t7, 8, check_8		# t7 = 8 -> Hien thi so 8 tren thanh led
        beq 	$t7, 9, check_9		# t7 = 9 -> Hien thi so 9 tren thanh led
        
#----------------------------------------------
#Chuyen gia tri thanh bit hien tren thanh led
#----------------------------------------------
check_0:	
	lb 	$t4, zero    
	j 	finish_check
check_1:
	lb 	$t4, one
	j 	finish_check
check_2:
	lb 	$t4, two
	j 	finish_check
check_3:
	lb 	$t4, three
	j	finish_check
check_4:
	lb 	$t4, four
	j 	finish_check
check_5:
	lb 	$t4, five
	j 	finish_check
check_6:
	lb 	$t4, six
	j 	finish_check
check_7:
	lb 	$t4, seven
	j 	finish_check
check_8:
	lb 	$t4, eight
	j 	finish_check
check_9:
	lb 	$t4, nine
	j 	finish_check	

finish_check:
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, -4
	jr 	$ra

update_tg:			
	 mul 	$t9, $t9, 10
	 add 	$t9, $t9, $t7

#-------------------------------------
# Hoan thanh xong 1 so -> reset_led
#-------------------------------------
done:
	beq $s0,1,reset_led   # s0 = 1 -> toan tu -> chuyen den ham reset led
	nop

#-------------------------------------
#ham hien thi bit len led ben trai
#-------------------------------------
load_to_left_led: 
	lb 	$t6, 0($sp)       #load bit hien thi led tu stack
	add 	$sp, $sp, -4
	lb 	$t8, 0($sp)       #load gia tri cua bit nay
	add 	$sp, $sp, -4      
	add 	$s2, $t8, $zero   #s2 = gia tri bit led trai
	sb 	$t6, 0($t0)       # hien thi len led trai

#-------------------------------------
#ham hien thi bit len led ben phai
#-------------------------------------
load_to_right_led:	
	sb 	$t4, 0($t5)       # hien thi bit len led phai
	add 	$sp, $sp,4
	sb 	$t7, 0($sp)	  #day gia tri bit nay vao stack
	add 	$sp, $sp,4
	sb 	$t4, 0($sp)       #day bit nay vao stack
	add 	$s1, $t7, $zero   #s1 = gia tri bit led phai
	j 	finish            

reset_led:
	li 	$s0, 0           #s0 = 0 -> doi nhap so tiep theo trong 2 so
        li 	$t8, 0
	addi 	$sp, $sp, 4
        sb 	$t8, 0($sp)
        lb 	$t6, zero        # day bit zero vao stack
	addi 	$sp, $sp, 4
        sb 	$t6, 0($sp)
finish:
	j 	return
	nop

#-----------------------------------------------------------------
#-----------------------------------------------------------------	
return:
	la 	$a3, Loop1
	mtc0 	$a3, $14
	eret

set_next_operator:
#-------------------------------------------------
#tinh so thu 2 
#-------------------------------------------------
set_second_number1: 
	addi 	$s5, $t9, 0
	beq 	$s3, 1, phep_cong_1         	#s3 = 1 -> phep cong
	beq 	$s3, 2, phep_tru_1		#s3 = 2 -> phep tru
	beq 	$s3, 3, phep_nhan_1		#s3 = 3 -> phep nhan
	beq 	$s3, 4, phep_chia_1		#s3 = 4 -> phep chia 
	beq	$s3, 5, phep_lay_du_1		#s3 = 5 -> phep lay du

phep_cong_1:
	add 	$s6, $s5, $s4
	li 	$s3, 0
	li 	$t9, 0 
	j 	in_phep_cong_1
	nop     		

#-------------------------------------------------
# In ra dinh dang: a + b = c \n
#-------------------------------------------------	
in_phep_cong_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '+'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		#reset $s5
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	nop
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	#Lay 2 gia tri cuoi cua ket qua 
	j show_result_in_led_1	#Hien thi ket qua tren led
	nop

phep_tru_1:
	sub 	$s6, $s4, $s5   
	li 	$s3, 0
	li 	$t9, 0 
	j 	in_phep_tru_1
	nop
	
#-------------------------------
#In ra dinh dang: a - b = c \n
#-------------------------------
in_phep_tru_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $45
	
	li 	$v0, 11
	li 	$a0, '-'
	syscall
	li 	$s5, 0		#reset $s5
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 55
	li 	$a0, '\n'
	syscall
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	#Lay 2 gia tri cuoi cua ket qua 
	j show_result_in_led_1	#Hien thi ket qua tren led
	nop

phep_nhan_1:
	mul 	$s6, $s4, $s5    
	li 	$s3, 0
	li 	$t9, 0 
	j 	in_phep_nhan_1
	nop
	
#-------------------------------------
#In ra dinh dang: a*b = c \n
#-------------------------------------
in_phep_nhan_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '*'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		#reset $s5
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	    	#Lay 2 chu so sau cung cua ket qua in ra
	j show_result_in_led_1    #Hien thi ket qua tren led
	nop

phep_chia_1:
	beq 	$s5, 0, chia_01	# kiem tra xem so chia co phai bang 0 hay khong 
	li 	$s3, 0
	div 	$s4, $s5   	    # s6=s4/s5
	mflo 	$s6
	mfhi 	$s7
	li 	$t9, 0 
	j 	in_phep_chia_1
	nop

#---------------------------------
# Neu $s5 = 0 in ra: "Khong the chia cho so 0 \n"
#-------------------------------
chia_01: 
	li 	$v0, 55
	la 	$a0, mess1
	li 	$a1, 0
	syscall
	j 	reset_led1

in_phep_chia_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '/'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s5, 0		#reset $s5
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6	   	#Lay 2 chu so sau cung cua ket qua in ra
	j show_result_in_led_1  #Hien thi ket qua tren led
	nop

phep_lay_du_1:
	beq 	$s5, 0, chia_lay_du_01	# kiem tra xem so chia co phai bang 0 hay khong 
	li 	$s3, 0
	div 	$s4, $s5   	    
	mflo 	$s7
	mfhi 	$s6
	li 	$t9, 0 
	j 	in_phep_lay_du_1
	nop

#---------------------------------
# Neu $s5 = 0 in ra: "Khong the chia cho so 0 \n"
#-------------------------------
chia_lay_du_01: 
	li 	$v0, 55
	la 	$a0, mess1
	li 	$a1, 0
	syscall
	j 	reset_led1

in_phep_lay_du_1:
	li 	$v0, 1
	move 	$a0, $s4
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '%'
	syscall
	
	li 	$v0, 1
	move 	$a0, $s5
	syscall
	li 	$s4, 0		#reset $s4
	
	li 	$v0, 11
	li 	$a0, '='
	syscall
	
	li 	$v0, 1
	move 	$a0, $s6
	syscall
	
		
	li 	$v0, 11
	li 	$a0, '\n'
	syscall
	
	li 	$s7, 100
	div 	$s6, $s7
	mfhi 	$s6		    	#Lay 2 gia tri cuoi cua ket qua 
	j 	show_result_in_led_1	#Hien thi ket qua tren led
	nop

#--------------------------------
#Hien thi ket qua tren den led
#So 'ab'
# Den trai = a = ab div 10
# Den phai = b = ab mod 10
#--------------------------------
show_result_in_led_1:
	li 	$t8, 10		# Gia tri trung gian = 10
	div 	$s6, $t8    	# $s6 = a
	mflo 	$t7        	# $t7 = result
	jal 	check_l1    	#chuyen den ham chuyen t7 thanh bit hien thi len led
	
        sb 	$t4, 0($t0)  	# hien thi len led trai
     	add 	$sp, $sp, 4
	sb 	$t7, 0($sp)	#day gia tri bit nay vao stack
	add 	$sp, $sp, 4
	sb 	$t4, 0($sp)       	#day bit nay vao stack
	add 	$s2, $t7, $zero   	#s1 = gia tri bit led phai     

	mfhi 	$t7       	#t7= remainder
	jal 	check_l1    	#convert t7 thanh bit hien thi len led
        sb 	$t4, 0($t5)  	#hien thi len led phai 
       	add 	$sp, $sp, 4
	sb 	$t7, 0($sp)	# day gia tri bit nay vao stack
	add 	$sp, $sp, 4	
	sb 	$t4, 0($sp)     	# day bit nay vao stack
	add 	$s1, $t7, $zero   	# s1 = gia tri bit led phai
        j 	reset_led1     		# ham reset lai led
 
             
check_l1:
	addi 	$sp, $sp, 4
        sw 	$ra, 0($sp)
        beq 	$t7, 0, check_01		# t7 = 0 -> Hien thi so 0 tren thanh led
        beq 	$t7, 1, check_11	   	# t7 = 1 -> Hien thi so 1 tren thanh led
        beq 	$t7, 2, check_21		# t7 = 2 -> Hien thi so 2 tren thanh led
        beq 	$t7, 3, check_31		# t7 = 3 -> Hien thi so 3 tren thanh led
        beq 	$t7, 4, check_41		# t7 = 4 -> Hien thi so 4 tren thanh led
        beq 	$t7, 5, check_51		# t7 = 5 -> Hien thi so 5 tren thanh led
        beq 	$t7, 6, check_61		# t7 = 6 -> Hien thi so 6 tren thanh led
        beq 	$t7, 7, check_71		# t7 = 7 -> Hien thi so 7 tren thanh led
        beq 	$t7, 8, check_81		# t7 = 8 -> Hien thi so 8 tren thanh led
        beq 	$t7, 9, check_91		# t7 = 9 -> Hien thi so 9 tren thanh led
        
#----------------------------------------------
#Chuyen gia tri thanh bit hien tren thanh led
#----------------------------------------------
check_01:	
	lb 	$t4, zero    
	j 	finish_check_1
check_11:
	lb 	$t4, one
	j 	finish_check_1
check_21:
	lb 	$t4, two
	j 	finish_check_1
check_31:
	lb 	$t4, three
	j	finish_check_1
check_41:
	lb 	$t4, four
	j 	finish_check_1
check_51:
	lb 	$t4, five
	j 	finish_check_1
check_61:
	lb 	$t4, six
	j 	finish_check_1
check_71:
	lb 	$t4, seven
	j 	finish_check_1
check_81:
	lb 	$t4, eight
	j 	finish_check_1
check_91:
	lb 	$t4, nine
	j 	finish_check_1


finish_check_1:
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, -4
	jr 	$ra

done_1:
	beq $s0,1,reset_led1   # s0 = 1 -> toan tu -> chuyen den ham reset led
	nop

reset_led1:
	li 	$s0, 0           #s0 = 0 -> doi nhap so tiep theo trong 2 so
        li 	$t8, 0
	addi 	$sp, $sp, 4
        sb 	$t8, 0($sp)
        lb 	$t6, zero        # day bit zero vao stack
	addi 	$sp, $sp, 4
        sb 	$t6, 0($sp)
        
	beq 	$a3, 1, set_add
	nop
	
	beq 	$a3, 2, set_sub
	nop
	
	beq 	$a3, 3, set_mul
	nop
	
	beq 	$a3, 4, set_div
	nop
	
	beq	$a3, 5, set_mod
	nop
	
set_add: 
	addi 	$s3, $zero, 1
	j 	finish1
	nop
	
set_sub: 
	addi 	$s3, $zero, 2
	j 	finish1
	nop
	
set_mul: 
	addi 	$s3, $zero, 3
	j  	finish1
	nop
	
set_div: 
	addi 	$s3, $zero, 4
	j 	finish1
	nop

set_mod:
	addi	$s3, $zero, 5
	j	finish1
	nop
        
finish1:
	j return_1
	nop

#-----------------------------------------------------------
#-----------------------------------------------------------	
return_1:
	la $a3, Khoi_tao
	mtc0 $a3, $14
	eret
