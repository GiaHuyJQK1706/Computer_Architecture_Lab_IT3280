.data
        command: .space 150
	opcode: .space 15
	token: .space 25
	number: .space 20
	ident: .space 50 
	Nhap: .asciiz "Nhap vao mot lenh hop ngu: "
	hopLe1: .asciiz "Opcode: "
	hopLe2: .asciiz "Toan hang: "
	hopLe3: .asciiz "Hop le.\n"
	lamlai: .asciiz "Ban muon thuc hien lai?(0.Dong y/1.De sau)"
	lenhloi: .asciiz "Lenh hop ngu khong hop le. Loi cu phap!\n"
	lenhloi1: .asciiz "Khong tim duoc khuon dang lenh nay!\n"
	ketthuc: .asciiz "\nHoan thanh! Lenh phu hop voi cu phap!\n"
	# Quy luat cua libray: opcode co do dai = 5 byte
	# moi lenh co 3 toan hang va chi co 4 loai la: thanh ghi = 1, hang so nguyen =2, dinh danh = 3 hoac khong co = 0.
	khuondang: .asciiz "beq**123;or***111;xor**111;lui**120;jr***100;jal**300;addi*112;add**111;sub**111;ori**112;and**111;beq**113;bne**113;j****300;nop**000;"
	charGroup: .asciiz "qwertyuiopasdfghjklmnbvcxzQWERTYUIOPASDFGHJKLZXCVBNM0123456789_"
	tenthanhghi: .asciiz "$zero $at   $v0   $v1   $a0   $a1   $a2   $a3   $t0   $t1   $t2   $t3   $t4   $t5   $t6   $t7   $s0   $s1   $s2   $s3   $s4   $s5   $s6   $s7   $t8   $t9   $k0   $k1   $gp   $sp   $fp   $ra   $0    $1    $2    $3    $4    $5    $7    $8    $9    $10   $11   $12   $13   $14   $15   $16   $17   $18   $19   $20   $21   $22   $21   $22   $23   $24   $25   $26   $27   $28   $29   $30   $31   "

.text

readData: # Doc lenh nhap vao tu ban phim
	li $v0, 4
	la $a0, Nhap
	syscall
	li $v0, 8
	la $a0, command # chua dia chi cua lenh nhap vao
	li $a1, 100
	syscall
#main
	li $t2, 0 # i
readOpcode:
	la $a1, opcode # luu cac ki tu doc duoc vao opcode
	add $t3, $a0, $t2 # dich bit
	add $t4, $a1, $t2
	lb $t1, 0($t3) # doc tung ki tu cua command
	sb $t1, 0($t4)
	beq $t1, 32, done # gap ki tu ' ' -> luu ki tu nay vao opcode de xu ly
	beq $t1, 0, done # ket thuc chuoi command
	addi $t2, $t2, 1
	j readOpcode
	
#<--xu ly opcode-->
done:
	li $t7,-9
	la $a2, khuondang
xuLyOpcode:
	li $t1, 0 # i
	li $t2, 0 # j
	addi $t7,$t7,9 # buoc nhay = 9 de den vi tri opcode trong library
	add $t1,$t1,$t7 # cong buoc nhay
	
	compare:
	add $t3, $a2, $t1 # t3 tro thanh con tro cua library
	lb $s0, 0($t3)
	beq $s0, 0, notFound # khong tim thay opcode nao trong library
	beq $s0, 42, check # gap ki tu '*' -> check xem opcode co giong nhau tiep ko?.
	add $t4, $a1, $t2
	lb $s1, 0($t4)
	bne $s0,$s1,xuLyOpcode # so sanh 2 ki tu. dung thi so sanh tiep, sai thi nhay den phan tu chua khuon danh lenh tiep theo.
	addi $t1,$t1,1 # i+=1
	addi $t2,$t2,1 # j+=1
	j compare
	
	check:
	add $t4, $a1, $t2
	lb $s1, 0($t4)
	bne $s1, 32, check2 # neu ki tu tiep theo khong phai ' ' => lenh khong hop le. chi co doan dau giong.
	checkContinue:
	add $t9,$t9,$t2 # t9 = luu vi tri de xu ly token trong command
	li $v0, 4
	la $a0, hopLe1 # opcode hop le
	syscall
	li $v0, 4
	la $a0, opcode
	syscall
	li $v0, 4
	la $a0, hopLe3
	syscall
	j readToanHang1
	
	check2: # neu ki tu tiep theo khong phai '\n' => lenh khong hop le. chi co doan dau giong.
	bne $s1, 10, notFound
	j checkContinue
	
# <!--ket thuc xu ly opcode -->

#<--xu li toan hang-->

readToanHang1:
	# xac dinh kieu toan hang trong library
	# t7 dang chua vi tri khuon dang lenh trong library
	li $t1, 0
	addi $t7, $t7, 5 # chuyen den vi tri toan hang 1 trong library
	add $t1, $a2, $t7 # a2 chua dia chi library
	lb $s0, 0($t1)
	addi $s0,$s0,-48 # chuyen tu char -> int
	li $t8, 1 # thanh ghi = 1
	beq $s0, $t8, checkTokenReg
	li $t8, 2 # hang so nguyen = 2
	beq $s0, $t8, checkHSN
	li $t8, 3 # dinh danh = 3
	beq $s0, $t8, checkIdent
	li $t8, 0 # khong co toan hang = 0
	beq $s0, $t8, checkNT
	j end
	
#<--check Token Register-->
checkTokenReg:
	la $a0, command
	la $a1, token # luu ten thanh ghi vao token de so sanh
	li $t1, 0
	li $t2, -1
	addi $t1, $t9, 0
	readToken:
		addi $t1, $t1, 1 # i
		addi $t2, $t2, 1 # j
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vi tri toan hang tiep theo trong command
		beq $s0, 35, compare1 # gap dau '# '
		beq $s0, 32, checkTokenReg # gap dau ' '
		beq $s0, 44, readTokenDone # gap dau ','
		beq $s0, 0, readTokenDone # gap ki tu ket thuc
		sb $s0, 0($t4)
		j readToken
	
	readTokenDone:
		sb $s0, 0($t4) # luu them ',' vao de compare
		li $t1, -1 # i
		li $t2, -1 # j
		li $t4, 0
		li $t5, 0
		add $t2, $t2, $k1
		la $a1, token
		la $a2, tenthanhghi
		j compareToken

compareToken:
	addi $t1,$t1,1
	addi $t2,$t2,1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, end
	add $t5, $a2, $t2
	lb $s1, 0($t5)
	beq $s1, 0, notFound
	beq $s1, 32, checkLengthToken
	bne $s0,$s1, jump
	j compareToken
	
	checkLengthToken:
		beq $s0, 44, compare1
		beq $s0, 10, compare1
		j compare2
	jump:
		addi $k1,$k1,6
		j readTokenDone
	compare1:
		la $a0, hopLe2 # opcode hop le
		syscall
		li $v0, 4
		la $a0, token
		syscall
		li $v0, 4
		la $a0, hopLe3
		syscall
		addi $v1, $v1, 1 # dem so toan hang da doc.
		li $k1, 0 # reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		j end
	compare2:
		j notFound
#<!--ket thuc check Token Register-->

#<--check toan hang la hang so nguyen-->
checkHSN: # kiem tra co phai hang so nguyen hay ko
	la $a0, command
	la $a1, number # luu day chu so vao number de so sanh tung chu so co thuoc vao numberGroup hay khong.
	li $t1, 0
	li $t2, -1
	addi $t1, $t9, 0
	readNumber:
		addi $t1, $t1, 1 # i
		addi $t2, $t2, 1 # j
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vi tri toan hang tiep theo trong command
		beq $s0, 35, compareNum1 # gap dau '# '
		beq $s0, 32, checkHSN # gap dau ' '
		beq $s0, 44, readNumberDone # gap dau ','
		beq $s0, 0, readNumberDone # gap ki tu ket thuc
		sb $s0, 0($t4)
		j readNumber
	readNumberDone:
		sb $s0, 0($t4) # luu them ',' vao de compare
		li $t1, -1 # i
		li $t4, 0
		la $a1, number
		j compareNumber
compareNumber:
	addi $t1, $t1, 1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, end
	beq $s0, 45, compareNumber # bo dau '-'
	beq $s0, 10, compareNum1
	beq $s0, 44, compareNum1
	li $t2, 48
	li $t3, 57
	slt $t5, $s0, $t2
	bne $t5, $zero, compareNum2
	slt $t5, $t3, $s0
	bne $t5, $zero, compareNum2
	j compareNumber

	compareNum1:
		la $a0, hopLe2
		syscall
		li $v0, 4
		la $a0, number
		syscall
		li $v0, 4
		la $a0, hopLe3
		syscall
		addi $v1, $v1, 1 # dem so toan hang da doc.
		li $k1, 0 # reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		j end
	compareNum2:
		j notFound
#<!--ket thuc check toan hang la hang so nguyen-->

#<--check Indent-->
checkIdent:
	la $a0, command
	la $a1, ident # luu ten thanh ghi vao indent de so sanh
	li $t1, 0
	li $t2, -1
	addi $t1, $t9, 0
	readIndent:
		addi $t1, $t1, 1 # i
		addi $t2, $t2, 1 # j
		add $t3, $a0, $t1
		add $t4, $a1, $t2
		lb $s0, 0($t3)
		add $t9, $zero, $t1 # vi tri toan hang tiep theo trong command
		beq $s0, 35, compareIdent1 # gap dau '# '
		beq $s0, 32, checkIdent # gap dau ' '
		beq $s0, 44, readIdentDone # gap dau ','
		beq $s0, 0, readIdentDone # gap ki tu ket thuc
		sb $s0, 0($t4)
		j readIndent
	readIdentDone:
		sb $s0, 0($t4) # luu them ',' vao de compare
		loopj:
		li $t1, -1 # i
		li $t2, -1 # j
		li $t4, 0
		li $t5, 0
		add $t1, $t1, $k1
		la $a1, ident
		la $a2, charGroup
		j compareIdent
compareIdent:
	addi $t1,$t1,1
	add $t4, $a1, $t1
	lb $s0, 0($t4)
	beq $s0, 0, end
	beq $s0, 10, compareIdent1
	beq $s0, 44, compareIdent1
	loop:
	addi $t2,$t2,1
	add $t5, $a2, $t2
	lb $s1, 0($t5)
	beq $s1, 0, compareIdent2
	beq $s0, $s1, jumpIdent # so sanh ki tu tiep theo trong ident
	j loop # tiep tuc so sanh ki tu tiep theo trong charGroup
	
	jumpIdent:
		addi $k1,$k1,1
		j loopj
		
	compareIdent1:
		la $a0, hopLe2 # opcode hop le
		syscall
		li $v0, 4
		la $a0, ident
		syscall
		li $v0, 4
		la $a0, hopLe3
		syscall
		addi $v1, $v1, 1 # dem so toan hang da doc.
		li $k1, 0 # reset buoc nhay
		beq $v1, 1, readToanHang2
		beq $v1, 2, readToanHang3
		j end
	compareIdent2:
		j notFound
#<!--ket thuc check Indent-->

#<--kiem tra khong co toan hang-->
checkNT:
	la $a0, command
	li $t1, 0
	li $t2, 0
	addi $t1, $t9, 0
	add $t2, $a0, $t1
	lb $s0, 0($t2)
	addi $v1, $v1, 1 # dem so toan hang da doc.
	li $k1, 0 # reset buoc nhay
	beq $v1, 1, readToanHang2
	beq $v1, 2, readToanHang3
#<!--ket thuc kiem tra khong co toan hang-->

#<--check Token Register 2-->
readToanHang2:
	# xac dinh kieu toan hang trong khuondang
	# t7 dang chua vi tri khuon dang lenh trong khuondang
	li $t1, 0
	la $a2,khuondang
	addi $t7, $t7, 1 # chuyen den vi tri toan hang 2 trong kuondang
	add $t1, $a2, $t7 # a2 chua dia chi library
	lb $s0, 0($t1)
	addi $s0,$s0,-48 # chuyen tu char -> int
	li $t8, 1 # thanh ghi = 1
	beq $s0, $t8, checkTokenReg
	li $t8, 2 # hang so nguyen = 2
	beq $s0, $t8, checkHSN
	li $t8, 3 # dinh danh = 3
	beq $s0, $t8, checkIdent
	li $t8, 0 # khong co toan hang = 0
	beq $s0, $t8, checkNT
	j end
#<!--ket thuc check Token Register 2-->

#<--check Token Register 3-->
readToanHang3:
	# xac dinh kieu toan hang trong khuondang
	# t7 dang chua vi tri khuon dang lenh trong khuondang
	li $t1, 0
	la $a2, khuondang
	addi $t7, $t7, 1 # chuyen den vi tri toan hang 3 trong khuondang
	add $t1, $a2, $t7 # a2 chua dia chi khuondang
	lb $s0, 0($t1)
	addi $s0,$s0,-48 # chuyen tu char -> int
	li $t8, 1 # thanh ghi = 1
	beq $s0, $t8, checkTokenReg
	li $t8, 2 # hang so nguyen = 2
	beq $s0, $t8, checkHSN
	li $t8, 3 # dinh danh = 3
	beq $s0, $t8, checkIdent
	li $t8, 0 # khong co toan hang = 0
	beq $s0, $t8, checkNT
	j end
#<!--ket thuc check Token Register 3-->
#<--check Token Register 3-->
continue: # lap lai chuong trinh.
	li $v0, 4
	la $a0, lamlai
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
	j readData
notFound:
	li $v0, 4
	la $a0, lenhloi1
	syscall
	j TheEnd
error:
	li $v0, 4
	la $a0, lenhloi
	syscall
	j TheEnd
end:
	li $v0, 4
	la $a0, ketthuc
	syscall
	j continue
TheEnd:
