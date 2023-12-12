# Project 7: Chuong trinh kiem tra cu phap lenh Mips 
#-----------------------------------------------------------

.data
	menu_mess:       .asciiz "\n----- MENU ------\n1. Kiem tra cu phap lenh\n2. Thoat \nChon: "
	menu_error_mess: .asciiz "\nNhap sai, vui long nhap lai!\n"
	input_mess:      .asciiz "\nNhap vao lenh Mips: "
	
	opcode_mess: 	.asciiz "Opcode: "
	toanHang_mess: 	.asciiz "Toan hang: "
	hopLe_mess: 	.asciiz " - hop le.\n"
	error_mess: 	.asciiz "\nLenh hop ngu khong hop le, sai khuon dang lenh !\n"
	completed_mess: .asciiz "\nLenh hop ngu chinh xac !\n"
	command:  	.space 100	# Luu cau lenh
	opcode:   	.space 30	# Luu ma lenh, vi du: add, and,...
	ident:    	.space 30	# nhan | hoac number
	token:    	.space 30	# cac thanh ghi, vi du: $zero, $at,...
	
	# Cau truc cua library:
	# opcode (7) - operation (3)
	# Trong so luong operation: 1 - thanh ghi; 2 - hang so nguyen; 3 - dinh danh (ident); 4 - imm($rs); 0 - khong co 
	library:	.asciiz "add****111;sub****111;addi***112;addu***111;addiu**112;subu***111;mfc0***110;mult***110;multu**110;div****110;mfhi***100;mflo***100;and****111;or*****111;andi***112;ori****112;sll****112;srl****112;lw*****140;sw*****140;lbu****140;sb*****140;lui****120;beq****113;bne****113;slt****111;slti***112;sltiu**112;j******300;jal****300;jr*****100;nop****000"
	numberGroup: 	.asciiz "0123456789-"
	characterGroup: .asciiz "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
	# Moi thanh ghi cach nhau 6 byte
	tokenRegisters: .asciiz "$zero $at   $v0   $v1   $a0   $a1   $a2   $a3   $t0   $t1   $t2   $t3   $t4   $t5   $t6   $t7   $s0   $s1   $s2   $s3   $s4   $s5   $s6   $s7   $t8   $t9   $k0   $k1   $gp   $sp   $fp   $ra   $0    $1    $2    $3    $4    $5    $6    $7    $8    $9    $10   $11   $12   $13   $14   $15   $16   $17   $18   $19   $20   $21   $22   $21   $22   $23   $24   $25   $26   $27   $28   $29   $30   $31   "

.text
main:
# ----- MENU -----
m_menu_start:
	li $v0, 4
	la $a0, menu_mess
	syscall
	
	# Read number input menu
	li $v0, 5
	syscall
	
	beq $v0, 2, end_main		# 2: ket thuc
	beq $v0, 1, m_menu_end		# 1: thuc hien kiem tra
	
	li $v0, 4
	la $a0, menu_error_mess	 	# Nhap sai
	syscall
	
	j m_menu_start
m_menu_end:

# ----- READ INPUT ----- 
m_input:
	jal  input
	nop

# ----- START CHECK ----- 

m_check:
	jal check
	nop
	
	j m_menu_start
	
end_main:
	li $v0, 10
	syscall
	
#-----------------------------------------------------------
# 1. @input: Nhap vao lenh Mips tu ban phim
#-----------------------------------------------------------
input:
	li $v0, 4
	la $a0, input_mess 
	syscall
	
	li $v0, 8
	la $a0, command
	li $a1, 100
	syscall

	jr $ra

#-----------------------------------------------------------
# 2. @check: Kiem tra cau lenh
# - Buoc 1: Kiem tra opcode (add, and, or,...) ten lenh
# - Buoc 2: Kiem tra Operand lan luot cac operand (Toan hang)
# - Giua 2 toan hang can kiem tra xem co dau ',' hay khong.
# $s7: Luu index cua command
# $s3: Vi tri cua tung toan hang trong Library
#-----------------------------------------------------------
check:
	# Luu $ra de tro ve main
	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	
	addi $s7, $zero, 0		# Thanh ghi $s7 luu index cua command
	
	# START CHECK OPCODE
	jal check_opcode
	nop
	
	# START CHECK OPERAND 1
	li  $s3, 7			# Vi tri operand trong Library
	jal check_operand
	nop
	
	# START CHECK OPERAND 2		# Neu khong co dau ',' ngan cach giua operand_1 va operand_2 => FALSE
	li  $s3, 8			# Vi tri operand trong Library
	add $t0, $s5, $s3
	lb  $t0, 0($t0)
	beq $t0, 48, check_none		# Kiem tra neu operand = 0 -> ket thuc; ky tu 0 trong ASCII
	
	la   $a0, command
	add  $t0, $a0, $s7 		# tro toi vi tri tiep tuc cua command
	lb   $t1, 0($t0)        
	bne  $t1, 44, not_found		# Dau ','
	add  $s7, $s7, 1
	
	jal check_operand
	nop
	
	# START CHECK OPERAND 3		# Neu khong co dau ',' ngan cach giua operand_1 va operand_2 => FALSE
	li  $s3, 9			# Vi tri operand trong Library
	add $t0, $s5, $s3
	lb  $t0, 0($t0)
	beq $t0, 48, check_none		# Kiem tra neu operand = 0 -> ket thuc; ky tu 0 trong ASCII
	
	la   $a0, command
	add  $t0, $a0, $s7 		# tro toi vi tri tiep tuc cua command
	lb   $t1, 0($t0)        
	bne  $t1, 44, not_found		# Dau ','
	add  $s7, $s7, 1
	
	jal check_operand
	nop
	
	# KIEM TRA KY TU THUA
	j check_none
	
	# Tra lai $ra de tro ve main
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra

#-----------------------------------------------------------
# 2.1 @check_opcode: Kiem tra cau lenh
# - Buoc 1: Lay cac opcode trong command da nhap 
#           Xoa cac dau cach thua phia truoc
# - Buoc 2: So sanh voi trong bo tu dien xem co opcode do khong
# 	    - Neu khong co ket thuc va quay lai menu
#	    - Meu co, luu lai dia chi opcode trong library va tiep tuc kiem tra 
# $a0: command
# $a1: opcode
# $s7: index of command
# $t9: index of opcode
#-----------------------------------------------------------
check_opcode:
	la  $a0, command				# Dia chi cua command
	la  $a1, opcode					# Dia chi cua opcode
	li  $t0, 0
	
remove_space_command:					# Xoa cac dau cach phia truoc lenh
	add $t1, $a0, $t0
	lb  $t2, 0($t1)
	bne $t2, 32, end_remove_space_command		# Neu khong phai ' ' -> Ket thuc
	addi $t0, $t0, 1
	j remove_space_command	
end_remove_space_command:	

	li  $t9, 0					# index for opcode
	li  $s6, 0					# so luong cac ki tu cua opcode = 0
read_opcode:
	add $t1, $a0, $t0				# Dich bit cua command
	add $t2, $a1, $t9				# Dich bit cua opcode
	lb  $t3, 0($t1)
	
	beq $t3, 32, read_opcode_done  			# Neu co dau cach ' ' ket thuc read opcode
	beq $t3, 10, read_opcode_done			# Neu dau '\n' ket thuc read opcode
	beq $t3, 0,  read_opcode_done			# Ket thuc chuoi

	sb  $t3, 0($t2)
	addi $t9, $t9, 1
	addi $t0, $t0, 1
	j read_opcode
read_opcode_done:	
	
	addi $s6, $t9, 0				# $s6: So luong ki tu cua opcode
	add $s7, $s7, $t0				# luu index cua command
	la $a2, library
	li $t0, -11
	
check_opcode_inlib:
	addi $t0, $t0, 11				# Buoc nhay bang 10 de nhay den tung Instruction
	li $t1, 0 					# i = 0
	li $t2, 0					# j = 0
	add $t1, $t1, $t0				# Cong buoc nhay
	
	compare_opcode:
		add $t3, $a2, $t1			# t3 tro thanh vi tri tro den dau cua tung Instruction
		lb  $t4, 0($t3)
		beq $t4, 0, not_found
		beq $t4, 42, check_len_opcode		# Neu gap ky tu `*` => Kiem tra do dai 
		add $t5, $a1, $t2			# Load opcode
		lb  $t6, 0($t5)
		bne $t4, $t6, check_opcode_inlib	# So sanh 2 ki tu, neu khong bang nhau thi tinh den Instruction tiep theo.
		addi $t1, $t1, 1			# i = i + 1
		addi $t2, $t2, 1			# j = j + 1
		j compare_opcode
	check_len_opcode:
		bne $t2, $s6, check_opcode_inlib
end_check_opcode_inlib:

	add $s5, $t0, $a2				# Luu lai vi tri Instruction trong Library.
	
	# ----- In thong tin ra man hinh -----
	li $v0, 4
	la $a0, opcode_mess
	syscall
	
	la $a3, opcode
	li $t0, 0
	print_opcode:
		beq $t0, $t9, end_print_opcode
		add $t1, $a3, $t0
		lb  $t2, 0($t1)
		li $v0, 11
		add $a0, $t2, $zero
		syscall 
		addi $t0, $t0, 1
		j print_opcode
	end_print_opcode:
	
	li $v0, 4
	la $a0, hopLe_mess
	syscall
	
	jr $ra 
	
	
#-----------------------------------------------------------
# 2.2 @check_operand: 
# $a0: command.
# $s7: Luu index cua command.
# $s5: vi tri cua instruction trong library.
# $t9: Gia tri cua toan hang trong Library.
#-----------------------------------------------------------
	
check_operand:
	# Luu $ra de tro ve check_operand
	addi $sp, $sp, -4
	sw   $ra, 0($sp)

	add $t9, $s5, $s3			# Tro toi operand trong Library
	lb  $t9, 0($t9)
	addi $t9, $t9, -48			# Char -> Number
	
	la  $a0, command
	add $t0, $a0, $s7
	
	li $t1, 0					# i = 0
	space_remove:				# Xoa cac khoang trang thua
		add $t2, $t0, $t1
		lb  $t2, 0($t2)			# Lay ky tu tiep theo
		bne $t2, 32, end_space_remove	# Ky tu ' ' 
		addi $t1, $t1, 1		# i = i + 1	
		j space_remove
	end_space_remove:
	
	add $s7, $s7, $t1			# Cap nhat lai index command
	
	li $s2, 0				# Tat kich hoat check number_register
	li $t8, 0				# Khong co
	beq $t8, $t9, check_none
	li $t8, 1				# Thanh ghi
	beq $t8, $t9, go_register
	li $t8, 2				# So hang nguyen
	beq $t8, $t9, go_number
	li $t8, 3				# Ident
	beq $t8, $t9, go_ident
	li $t8, 4				# Check number & register
	beq $t8, $t9, go_number_register		
	
end_check_operand:
	# Tra lai $ra de tro ve check_operand
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra

#-----------------------------------------------------------
#  jal toi cac ham check de kiem tra
#-----------------------------------------------------------
	go_register:				# Check register
		jal check_register
		nop
	j end_check_operand
	
	go_number:				# Check number
		la $a2, numberGroup
		jal check_ident
		nop
	j end_check_operand
	
	go_ident:				# Check Ident
		la $a2, characterGroup
		jal check_ident
		nop
	j end_check_operand
	
	go_number_register:			# Check number-register
		jal check_number_register
		nop
	j end_check_operand
	
#-----------------------------------------------------------
#  @check_none: Kiem tra xem con ky tu nao o cuoi khong
#-----------------------------------------------------------
check_none:
	la $a0, command
	add $t0, $a0, $s7
				
	lb $t1, 0($t0)
			
	beq $t1, 10, none_ok	# Ky tu '\n'
	beq $t1, 0, none_ok	# Ket thuc chuoi
	
	j not_found
		
none_ok:	
	li $v0, 4
	la $a0, completed_mess
	syscall
	j m_menu_start
	
#-----------------------------------------------------------
# @check_register: Kiem tra xem register co hop le hay khong
# $a0: command (vi tri luu command)
# $a1: token (vi tri luu thanh ghi)
# $a2: tokenRegisters
# $s7: Luu index cua command
# $t9: index cua token
#-----------------------------------------------------------

check_register:
	la $a0, command
	la $a1, token
	la $a2, tokenRegisters
	add $t0, $a0, $s7				# Tro den vi tri cac instruction
	
	li $t1, 0					# i = 0
	li $t9, 0					# index cua token
	
read_token_register:
	add $t2, $t0, $t1				# command
	add $t3, $a1, $t1				# token
	lb $t4, 0($t2)
		
	beq $t4, 41, end_read_token			# Gap ky tu ')'
	beq $t4, 44, end_read_token			# Gap ky tu ' , '
	beq $t4, 10, end_read_token			# Gap ky tu '\n'
	beq $t4, 0, end_read_token			# Ket thuc
		
	addi $t1, $t1, 1
	beq $t4, 32, read_token_register		 # Neu gap dau ' ' thi tiep tuc 
		
	sb $t4, 0($t3)
	addi $t9, $t9, 1
	j read_token_register
		
end_read_token:
	add $s7, $s7, $t1				# Cap nhat lai gia tri index
		
	li $t0, -6
compare_token_register:
	addi $t0, $t0, 6				# Buoc nhay bang 6 de nhay den tung Register
	
	li $t1, 0 					# i = 0
	li $t2, 0					# j = 0
	
	add $t1, $t1, $t0				# Cong buoc nhay
	
	compare_reg:
		add $t3, $a2, $t1			# t3 tro thanh vi tri tro den dau cua tung Register
		lb  $t4, 0($t3)
		beq $t4, 0, not_found
		beq $t4, 32, check_len_reg		# Neu gap ky tu ` ` => Kiem tra do dai 
	
		add $t5, $a1, $t2			# Load token
		lb  $t6, 0($t5)
	
		bne $t4, $t6, compare_token_register	# So sanh 2 ki tu, neu khong bang nhau thi tinh den Register tiep theo.
		addi $t1, $t1, 1			# i = i + 1
		addi $t2, $t2, 1			# j = j + 1
		j compare_reg
	
	check_len_reg:
		bne $t2, $t9, compare_token_register	# Neu do dai khong bang nhau di den register tiep theo
		
end_compare_token_register:
	
	# >>>>>>>>> In thong tin ra man hinh <<<<<<<<<<
	beq $s2, 1, on_token_number_register
	li $v0, 4
	la $a0, toanHang_mess
	syscall
	
	la $a3, token
	li $t0, 0
	print_token_register:
		beq $t0, $t9, end_print_token_register
		add $t1, $a3, $t0
		lb  $t2, 0($t1)
		li $v0, 11
		add $a0, $t2, $zero
		syscall 
		addi $t0, $t0, 1
		j print_token_register
	end_print_token_register:
	
	li $v0, 4
	la $a0, hopLe_mess
	syscall
	jr $ra
	
on_token_number_register:

	la $a3, token
	li $t0, 0
	print_on_token_register:
		beq $t0, $t9, end_print_on_token_register
		add $t1, $a3, $t0
		lb  $t2, 0($t1)
		li $v0, 11
		add $a0, $t2, $zero
		syscall 
		addi $t0, $t0, 1
		j print_on_token_register
	end_print_on_token_register:
	
	li $v0, 11
	li $a0, 41
	syscall 
	li $v0, 4
	la $a0, hopLe_mess
	syscall
	jr $ra

#-----------------------------------------------------------
# @check_ident: Kiem tra ident (label) HOAC number
# $a0: command (vi tri luu command)
# $a1: ident (vi tri luu ident)
# $a2: characterGroup | numberGroup
# $s7: luu index cua command
# $t9: index cua ident
#-----------------------------------------------------------
check_ident:
	la $a0, command
	la $a1, ident
	
	add $t0, $a0, $s7			# Tro den vi tri cac instruction
	
	li $t1, 0				# i = 0
	li $t9, 0				# index cua ident
	
read_ident:
	add $t2, $t0, $t1			# command
	add $t3, $a1, $t1			# ident
	lb $t4, 0($t2)
		
	beq $t4, 40, end_read_ident		# Gap ky tu '('
	beq $t4, 44, end_read_ident		# Gap ky tu ' , '
	beq $t4, 10, end_read_ident		# Gap ky tu '\n'
	beq $t4, 0, end_read_ident		# Ket thuc
		
	addi $t1, $t1, 1
	beq $t4, 32, read_ident	 		# Neu gap dau ' ' thi tiep tuc 
		
	sb $t4, 0($t3)
	addi $t9, $t9, 1
	j read_ident
		
end_read_ident:
	add $s7, $s7, $t1			# Cap nhat lai gia tri index
	beq $t9, 0, not_found			# Khong co label
	
	#li $v0, 10
	#syscall

	li $t2, 0				# index cho Ident
compare_ident:
	beq  $t2, $t9, end_compare_ident	# ket thuc chuoi
	li   $t1, 0				# index cho characterGroup
	
	add  $t3, $a1, $t2		
	lb   $t3, 0($t3)			# Tung char trong Ident
	
	loop_Group:				# Kiem tra tung ky tu Ident co trong Group hay khong
		add $t4, $a2, $t1
		lb $t4, 0($t4)
		beq $t4, 0, not_found		# Khong co -> Khong tim thay
		beq $t4, $t3, end_loop_Group
		
		addi $t1, $t1, 1
		j loop_Group
		
	end_loop_Group:
	
	addi $t2, $t2, 1
	
	j compare_ident

end_compare_ident:

	beq $s2, 1, on_number_register
	
	# ----- In thong tin ra man hinh -----
	li $v0, 4
	la $a0, toanHang_mess
	syscall
	
	la $a3, ident
	li $t0, 0
	print_ident:
		beq $t0, $t9, end_print_ident
		add $t1, $a3, $t0
		lb  $t2, 0($t1)
		li $v0, 11
		add $a0, $t2, $zero
		syscall 
		addi $t0, $t0, 1
		j print_ident
	end_print_ident:
	
	li $v0, 4
	la $a0, hopLe_mess
	syscall
	jr $ra
	
on_number_register:
	li $v0, 4
	la $a0, toanHang_mess
	syscall

	la $a3, ident
	li $t0, 0
	print_on_ident:
		beq $t0, $t9, end_print_on_ident
		add $t1, $a3, $t0
		lb  $t2, 0($t1)
		li $v0, 11
		add $a0, $t2, $zero
		syscall 
		addi $t0, $t0, 1
		j print_on_ident
	end_print_on_ident:
	
	li $v0, 11
	li $a0, 40
	syscall
	jr $ra

#-----------------------------------------------------------
# @check_number_register: Kiem tra number - ident
# $a0: command (vi tri luu command)
# $s7: luu index cua command
# $s2: Luu kich hoat check number register
#-----------------------------------------------------------

check_number_register:
	# Luu $ra de tro ve
	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	
	li $s2, 1				# Bat kich hoat number_register
	
	# Check number
	la $a2, numberGroup
	jal check_ident
	nop
	
	la $a0, command
	add $t0, $a0, $s7			# Tro den vi tri cac instruction
	lb $t0, 0($t0)
	bne $t0, 40, not_found			# Neu ki tu khong phai la dau '('
	addi $s7, $s7, 1
	
	# Check register
	jal check_register
	nop
	la $a0, command
	add $t0, $a0, $s7			# Tro den vi tri cac instruction
	lb $t0, 0($t0)
	bne $t0, 41, not_found			# Neu ki tu khong phai la dau ')'
	addi $s7, $s7, 1
	
	# Tra lai $ra de tro ve 
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra 

#-----------------------------------------------------------
#  @not_found: Khong tim thay khuon dang lenh
#-----------------------------------------------------------
not_found:
	li $v0, 4
	la $a0, error_mess
	syscall
	j m_menu_start	
	
#-----------------------------------------------------------
#  END
#-----------------------------------------------------------
