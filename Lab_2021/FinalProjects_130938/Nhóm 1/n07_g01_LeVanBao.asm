#member :
#Le van Bao      20205057
#Dang Quang Dat  20205064
#Bai 7: Chuong trinh kiem tra cu phap lenh mips
#Thuc hien : Le Van bao
.data
	mess_input: .asciiz "Nhap lenh: "
	mess_error: .asciiz "Loi cu phap!\n"
	mess_not_found: .asciiz "Khong tim duoc lenh nay!\n"
	mess_correct: .asciiz "\nLenh vua nhap dung voi cu phap\n"
	mess_opcode: .asciiz "Opcode: "
	mess_operand: .asciiz "Toan hang: "
	mess_valid: .asciiz "hop le.\n"
	mess_continue: .asciiz "Ban muon tiep tuc chuong trinh?(0.Yes/1.No)"
	command: .space 100
	opcode: .space 10
	token: .space 20
	number: .space 15
	label: .space 30
	# quy luat cua CommandData: opcode co do dai = 5 byte
	# moi lenh co 3 toan hang va chi co 4 loai la: thanh ghi = 1, hang so nguyen =2, dinh danh = 3 hoac khong co = 0.
	CommandData: .asciiz "or***1111;xor**1111;lui**1201;jr***1001;jal**3002;addi*1121;add**1111;sub**1111;ori**1121;and**1111;beq**1132;bne**1132;j****3002;nop**0001;"
	CharData: .asciiz "1234567890qwertyuiopasdfghjklmnbvcxzQWERTYUIOPASDFGHJKLZXCVBNM_`~[]{}\|;':<>/?,.!@#$%^&*(()+-="
	TokenData: .asciiz "$zero $at   $v0   $v1   $a0   $a1   $a2   $a3   $t0   $t1   $t2   $t3   $t4   $t5   $t6   $t7   $s0   $s1   $s2   $s3   $s4   $s5   $s6   $s7   $t8   $t9   $k0   $k1   $gp   $sp   $fp   $ra   $0    $1    $2    $3    $4    $5    $7    $8    $9    $10   $11   $12   $13   $14   $15   $16   $17   $18   $19   $20   $21   $22   $21   $22   $23   $24   $25   $26   $27   $28   $29   $30   $31   "

.text
# nhap lenh tu ban phim
enter_input:
	li $v0, 4
	la $a0, mess_input
	syscall
	li $v0, 8
	la $a0, command 
	li $a1, 100
	syscall
	
main:
	li $t2, 0 #i
#doc opcode tu du lieu dau vao
Read_Opcode:
	la $a1, opcode
	add $t3, $a0, $t2
	add $t4, $a1, $t2
	lb $t1, 0($t3)
	sb $t1, 0($t4)
	beq $t1, ' ', done # gap ki tu ' ' thi luu vao opcode
	beq $t1, 0, done
	addi $t2, $t2, 1
	j Read_Opcode
done:
	li $t7,-10
	la $a2, CommandData
	
#xu li opcode
Processing_Opcode:
	li $t1, 0 # i
	li $t2, 0 # j
	addi $t7,$t7,10
	add $t1,$t1,$t7
	#so sanh opcode
	Compare_Opcode:
	add $t3, $a2, $t1 # t3 la con tro cua CommandData
	lb $s0, 0($t3)
	beq $s0, 0, notFound # khong tim thay opcode trong CommandData
	beq $s0, '*', Check_Opcode # gap ki tu  '*' -> kiem tra dau cach
	add $t4, $a1, $t2
	lb $s1, 0($t4)
	bne $s0,$s1,Processing_Opcode # so sanh ki tu
	addi $t1,$t1,1 # i+=1
	addi $t2,$t2,1 # j+=1
	j Compare_Opcode
	
	Check_Opcode:
	add $t4, $a1, $t2
	lb $s1, 0($t4)
	bne $s1, ' ', Check_error
	End_Opcode:
	add $t9,$t9,$t2 # t9 la vi tri opcode
	li $v0, 4
	la $a0, mess_opcode 
	syscall
	li $v0, 4
	la $a0, opcode
	syscall
	li $v0, 4
	la $a0, mess_valid
	syscall
	j Read_operand_1
	# check '\n'
	Check_error: 
	bne $s1, 10, notFound
	j End_Opcode
	
#xu li toan hang
Read_operand_1:
	# xac dinh kieu toan hang trong CommanData
	# t7 dang chua vi tri khuon dang lenh trong CommanData
	li $t1, 0
	addi $t7, $t7, 5
	add $t1, $a2, $t7 # a2 chua dia chi CommandData
	lb $s0, 0($t1)
	addi $s0,$s0,-48 #char -> int
	li $t8, 1
	beq $s0, $t8, Check_Token_Register
	li $t8, 2
	beq $s0, $t8, Check_Integer
	li $t8, 3
	beq $s0, $t8, Check_Label
	li $t8, 0
	beq $s0, $t8, Check_Null_Token
	j end
	
#check token
Check_Token_Register:
	la $a0, command
	la $a1, token
	li $t1, 0
	li $t2, -1
	addi $t1, $t9, 0
	Read_Token:
		addi $t1, $t1, 1 # i
		addi $t2, $t2, 1 # j
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vi tri toan hang sau opcode trong command
		beq $s0, ',',Read_Token_Done 
		beq $s0, 0,Read_Token_Done
		sb $s0, 0($t4)
		j Read_Token
	
	Read_Token_Done:
		sb $s0, 0($t4) # luu ',' de compare
		li $t1, -1 # i
		li $t2, -1 # j
		li $t4, 0
		li $t5, 0
		add $t2, $t2, $k1
		la $a1, token
		la $a2, TokenData
		j Compare_Token

Compare_Token:
	addi $t1,$t1,1
	addi $t2,$t2,1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, end
	add $t5, $a2, $t2
	lb $s1, 0($t5)
	beq $s1, 0, notFound
	beq $s1, 32, Check_End_Token
	bne $s0,$s1, jump
	j Compare_Token
	
	Check_End_Token:
		beq $s0, 44, End_Token
		beq $s0, 10, End_Token
		j Token_error
	jump:
		addi $k1,$k1,6
		j Read_Token_Done
	End_Token:
		la $a0, mess_operand 
		syscall
		li $v0, 4
		la $a0, token
		syscall
		li $v0, 4
		la $a0, mess_valid
		syscall
		addi $v1, $v1, 1 # so toan hang da xu li
		li $k1, 0 # reset buoc nhay
		beq $v1, 1, Read_Operand_2
		beq $v1, 2, Read_Operand_3
		j end
	Token_error:
		j notFound

#hang so nguyen
Check_Integer: 
	la $a0, command
	la $a1, number 
	li $t1, 0
	li $t2, -1
	addi $t1, $t9, 0
	Read_Number:
		addi $t1, $t1, 1 # i
		addi $t2, $t2, 1 # j
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vi tri toan hang theo trong command
		beq $s0, 44, Read_Number_Done # gap dau ','
		beq $s0, 0, Read_Number_Done 
		sb $s0, 0($t4)
		j Read_Number
	Read_Number_Done:
		sb $s0, 0($t4) # luu ',' de compare
		li $t1, -1 # i
		li $t4, 0
		la $a1, number
		j Compare_Number
Compare_Number:
	addi $t1, $t1, 1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, end
	beq $s0, 45, Compare_Number # bo dau '-'
	beq $s0, 10, End_Compare_Number
	beq $s0, 44, End_Compare_Number
	li $t2, 48
	li $t3, 57
	slt $t5, $s0, $t2
	bne $t5, $zero, Number_Error
	slt $t5, $t3, $s0
	bne $t5, $zero, Number_Error
	j Compare_Number

	End_Compare_Number:
		la $a0, mess_operand
		syscall
		li $v0, 4
		la $a0, number
		syscall
		li $v0, 4
		la $a0, mess_valid
		syscall
		addi $v1, $v1, 1 # so toan hang da xu li
		li $k1, 0 # reset buoc nhay
		beq $v1, 1, Read_Operand_2
		beq $v1, 2, Read_Operand_3
		j end
	Number_Error:
		j notFound

#check ten ham
Check_Label:
	la $a0, command
	la $a1, label
	li $t1, 0
	li $t2, -1
	addi $t1, $t9, 0
	Read_Label:
		addi $t1, $t1, 1 # i
		addi $t2, $t2, 1 # j
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vij tri tiep theo trong command
		beq $s0, 44, Read_Label_Done # gap dau ','
		beq $s0, 0, Read_Label_Done 
		sb $s0, 0($t4)
		j Read_Label
	Read_Label_Done:
		sb $s0, 0($t4) # luu ',' de compare
		loopj:
		li $t1, -1 # i
		li $t2, -1 # j
		li $t4, 0
		li $t5, 0
		add $t1, $t1, $k1
		la $a1, label
		la $a2, CharData
		j Compare_Label
Compare_Label:
	addi $t1,$t1,1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, end
	beq $s0, 10, End_Compare_Label
	beq $s0, 44, End_Compare_Label
	loop:
	addi $t2,$t2,1
	add $t5, $a2, $t2
	lb $s1, 0($t5)
	beq $s1, 0, Error_Label
	beq $s0, $s1, jumpIdent # so sanh ki tu tiep theo trong label
	j loop # tiep tuc so sanh ki tu tiep theo theo trong CharData
	
	jumpIdent:
		addi $k1,$k1,1
		j loopj
		
	End_Compare_Label:
		la $a0, mess_operand 
		syscall
		li $v0, 4
		la $a0, label
		syscall
		li $v0, 4
		la $a0, mess_valid
		syscall
		addi $v1, $v1, 1 #so toan hang da xu li
		li $k1, 0 # reset buoc nhay
		beq $v1, 1, Read_Operand_2
		beq $v1, 2, Read_Operand_3
		j end
	Error_Label:
		j notFound

#kiem tra khong co toan hang
Check_Null_Token:
	la $a0, command
	li $t1, 0
	li $t2, 0
	addi $t1, $t9, 0
	add $t2, $a0, $t1
	lb $s0, 0($t2)
	addi $v1, $v1, 1 #so toan hang da xu li
	li $k1, 0 # reset b??c nh?y
	beq $v1, 1, Read_Operand_2
	beq $v1, 2, Read_Operand_3
#<--check Token Register 2-->
Read_Operand_2:
	# xac dinh kieu toan hang trong CommanData
	# t7 dang chua vi tri khuon dang lenh trong CommanData
	li $t1, 0
	la $a2, CommandData
	addi $t7, $t7, 1 # chuyen den vi tri toan hang 2 trong CommandData
	add $t1, $a2, $t7 # a2 chua dia chi CommandData
	lb $s0, 0($t1)
	addi $s0,$s0,-48 # chuyen tu char -> int
	li $t8, 1 # thanh ghi = 1
	beq $s0, $t8, Check_Token_Register
	li $t8, 2 # hang so nguyen = 2
	beq $s0, $t8, Check_Integer
	li $t8, 3 # dinh danh = 3
	beq $s0, $t8, Check_Label
	li $t8, 0 # khong co toan hang = 0
	beq $s0, $t8, Check_Null_Token
	j end

Read_Operand_3:
	# xac dinh kieu toan hang trong CommanData
	# t7 dang chua vi tri khuon dang lenh trong CommanData
	li $t1, 0
	la $a2, CommandData
	addi $t7, $t7, 1
	add $t1, $a2, $t7 
	lb $s0, 0($t1)
	addi $s0,$s0,-48 #char -> int
	li $t8, 1 
	beq $s0, $t8, Check_Token_Register
	li $t8, 2 
	beq $s0, $t8, Check_Integer
	li $t8, 3 
	beq $s0, $t8, Check_Label
	li $t8, 0 
	beq $s0, $t8, Check_Null_Token
	j end
continue: # lap lai chuong trinh.
	li $v0, 4
	la $a0, mess_continue
	syscall
	li $v0, 5
	syscall
	add $t0, $v0, $zero
	beq $t0, $zero, resetAll
	j TheEnd
resetAll:
	li $v0, 0 
	li $v1, 0
	li $a0, 0 
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	li $k0, 0
	li $k1, 0
	j enter_input
notFound:
	li $v0, 4
	la $a0, mess_not_found
	syscall
	j TheEnd
error:
	li $v0, 4
	la $a0, mess_error
	syscall
	j TheEnd
end:
	li $v0, 4
	la $a0, mess_correct
	syscall
	j continue
TheEnd:
	li $v0,10
	syscall
