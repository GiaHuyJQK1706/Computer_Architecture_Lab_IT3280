#Author : Vo Ta Hoan
.data 
	command: .asciiz "\n\nNhap vao mot dong lenh hop ngu: "
	continueMessage: .asciiz "Ban muon tiep tuc chuong trinh?(0.Yes/1.No)"
	errMessage: .asciiz "\n!!!Lenh hop ngu khong hop le. Loi cu phap!!!\n"
	NF: .asciiz " :Khong hop le!\n"
	endMess: .asciiz "\nHoan thanh! Lenh vua nhap vao phu hop voi cu phap!\n\n"
	msg_Opcode: .asciiz "\nOpcode: "
	msg_ToanHang: .asciiz "Toan hang: "
	msg_HopLe: .asciiz " hop le.\n"
	input: .space 100
	token: .space 20
	# quy luat cua library: opcode co do dai = 5 byte
	# moi lenh co 3 toan hang va chi co 4 loai la: thanh ghi = 1, hang so nguyen =2, dinh danh = 3 hoac khong co = 0.
	library: .asciiz "or***111;xor**111;lui**120;jr***100;jal**300;addi*112;add**111;sub**111;ori**112;and**111;beq**113;bne**113;j****300;nop**000;"
	charGroup: .asciiz "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
	tokenRegisters: .asciiz "$zero ;$at   ;$v0   ;$v1   ;$a0   ;$a1   ;$a2   ;$a3   ;$t0   ;$t1   ;$t2   ;$t3   ;$t4   ;$t5   ;$t6   ;$t7   ;$s0   ;$s1   ;$s2   ;$s3   ;$s4   ;$s5   ;$s6   ;$s7   ;$t8   ;$t9   ;$k0   ;$k1   ;$gp   ;$sp   ;$fp   ;$ra   ;$0    ;$1    ;$2    ;$3    ;$4    ;$5    ;$7    ;$8    ;$9    ;$10   ;$11   ;$12   ;$13   ;$14   ;$15   ;$16   ;$17   ;$18   ;$19   ;$20   ;$21   ;$22   ;$21   ;$22   ;$23   ;$24   ;$25   ;$26   ;$27   ;$28   ;$29   ;$30   ;$31   ;"
	
	#$k0=libraryIndex
	#$k1=inputIndex
	#$s4= checkOpcode
	#$s5=checkToanHang1
	#$t7= buocNhay
	
.text
	j readData	


#<--kiem tra opcode co dung hay khong ? dung: checkOpcode=1 sai : checkOpcode =0-->	
checkOpcodeFunc:   
#thanh ghi a2 : library
#thanh ghi a1: token
#$s4:checkOpcode 
xuLyOpcode: 
	li $k0, 0 		# libraryIndex
	li $k1, 0 		# inputIndex
	li $s5, 0		# check = 0
	addi $t7, $t7, 9 	# buoc nhay = 9 de den vi tri opcode trong library
	add  $k0, $k0, $t7 	# cong buoc nhay
	
	compare:
		add $t3, $a2, $k0 	# t3 tro thanh con tro cua library
		lb  $s0, 0($t3)
		beq $s0, 0, notFound 	# khong tim thay opcode nao trong library
		beq $s0, '*', check 	# gap ki tu '*' -> check xem opcode co giong nhau tiep ko?.
		add $t4, $a1, $k1 
		lb  $s1, 0($t4)	# s1= opcode[inputindex]
		bne $s0, $s1,xuLyOpcode # so sanh 2 ki tu. dung thi so sanh tiep, sai thi nhay den phan tu chua khuon dang lenh tiep theo.
		addi $k0, $k0, 1 	# i+=1
		addi $k1, $k1, 1 	# j+=1
		j compare
	check:
		lb $s1, 1($t4) 	#kiem tra ki tu cuoi cung co phai = '\0'
		beq $s1, '\0' ,check2 # neu ki tu tiep theo khong phai '\0' => lenh khong hop le. chi co doan dau giong.
		li $s5, 0 		# checkOpcode = 0 lenh khong hop le
		j endCheckOpcodeFunc
	check2:
		li $s5,1		# checkOpcode = 1 lenh hop le
endCheckOpcodeFunc:
		jr $ra	
#<-- Ket thuc kiem tra Opcode -->

				
#<-- kiem tra Toan Hang Rong dung hay sai ? dung : check =1 , sai : check =0 -->				
checkNTFunc: 
# $a1 : token
# $s5 : check 
	add $t1, $a1, 0 
	lb  $t2, 0($t1) 	#t2=token[0]
	bne $t2,'\0',emptyToken # if(token[0]== '\0') check = 1; else check = 0;
	li $s5, 1 		#check = 1 toan hang hop le
	j endCheckNTFunc
	emptyToken: 
		li $s5, 0 		#check = 0 toan hang khong hop le
endCheckNTFunc: 
		jr $ra
		
#<-- Ket Thuc kiem tra toan hang rong -->							

																																		
#<-- Kiem tra thanh ghi dung hay sai ? -->
checkTokenRegFunc:
#a1: token
#a3: tokenRegister
	la $a3, tokenRegisters
	li $s5, 0 		#check = 0
	
	li $t7,-7 		# khoi tao buoc nhay = -7 de vao vong lap +7 thi = 0 la gia tri dau tien
	
	xulyToken:
		li $t0, 0 #i
		li $t1, 0 #j
		addi $t7, $t7, 7 	# buoc nhay = 7 de den vi tri tokenRegister
		add  $t0, $t0, $t7 	# cong buoc nhay
	
		compareToken:
			add $t3, $a3, $t0 	# t3 tro thanh con tro cua tokenRegister
			lb  $s0, 0($t3)   	# s0 = tokenRegister[i]
			beq $s0, 0, notFound 	# khong tim thay opcode nao trong library
			beq $s0, ' ', checkToken # gap ki tu ' ' -> check xem co giong nhau tiep ko?.
			add $t4, $a1, $t1
			lb  $s1, 0($t4) 	# s1 = token[j]	
			bne $s0,$s1,xulyToken # so sanh 2 ki tu. dung thi so sanh tiep, sai thi nhay den phan tu chua khuon danh lenh tiep theo.
			addi $t0,$t0, 1 	# i+=1
			addi $t1,$t1, 1 	# j+=1
			j compareToken
		checkToken: 	# check co giong hoan toan hay khong
			lb $s1,1($t4) 	# kiem tra ki tu cuoi cung co phai = '\0'
			beq $s1,'\0', checkToken2
			li  $s5, 0	   	# neu sai check=0	
			j endCheckTokenRegFunc
		checkToken2:
			li $s5, 1	   	# neu sai check=1		
endCheckTokenRegFunc: 	
		jr $ra
#<-- Ket thuc kiem tra thanh ghi -->


		
#<-- Kiem tra hang so nguyen -->
checkHSNFunc:

	li $s5, 0	 # check = 0 
	li $t0, 0	 # i=0
	li $t2, 48
	li $t3, 57	
	
	add $t1, $a1, $t0
        	lb  $s0, 0($t1) 		# s0 = token[i]
        	beq $s0, '\0', endCheckHSNFunc 	# neu token[0] = null thi end function check = 0
	
        	add $t1, $a1, $t0
        	lb  $s0, 0($t1)
        	bne $s0, '-', compareNum 	# neu so am i++ 
        	addi $t0, $t0, 1
       	compareNum: 
       		add $t1, $a1, $t0
        		lb  $s0, 0($t1)
        		beq $s0, '\0', endCompareNum 	# dung lai neu token[i] == '\0'
        		beq $s0, ',', endCompareNum  	# dung lai neu token[i] == ','
        		beq $s0, '\n',endCompareNum  	# dung lai neu token[i] == '\n'
        	# neu 48< token[i] < 57 thi out chuong trinh check = 0
        		slt $t5, $s0, $t2 
		bne $t5, $zero, endCheckHSNFunc
		slt $t5, $t3, $s0
		bne $t5, $zero, endCheckHSNFunc
	
       		addi $t0, $t0, 1 		# i++
       		j compareNum		# quay lai vong while
    	endCompareNum:
    		li $s5, 1			# neu dung het dk check = 1
endCheckHSNFunc:
		jr $ra
#<-- Ket thuc kiem tra hang so nguyen -->	


#<-- Kiem tra Label -->
checkIdentFunc:
	li $s5, 0	# check = 0
	li $t0, 0	# i = 0
	la $a3, charGroup #load ,
	add $t3, $a1, $t0
        	lb  $s0, 0($t3) # s0 = token[i]
        	
        	#ki tu dau khong duoc la so
        	li $s2, 48
        	li $s3, 57
	slt $t5, $s2, $s0 
	slt $t6, $s0, $s3
	and $t5, $t5, $t6 	# token[0] > 48 && token[0] < 57
	bne $t5, $zero, endCheckIdentFunc  # neu la so thi out func check = 0
	
	loop1: 			# duyet tung ki tu trong token
       		add $t3, $a1, $t0 
        		lb  $s0, 0($t3) 		# s0 = token[i]
        		beq $s0, '\0', endLoop1 	# neu token[i] == '\0' thi out vong lap
        		beq $s0, '\n',endLoop1  	# neu token[i] == '\n' thi out vong lap
	
        		li $t1, 0 			# j=0
        		loop2: 		# so sanh trong mang charGroup
        			add $t4, $a3, $t1
        			lb  $s1, 0($t4) 	# s1 =  charGroup[j]
        			beq $s1,'\0', endCheckIdentFunc # neu khong tim thay ki tu cua token trong charGroup -> ket thuc ham check = 0 
        			beq $s0, $s1, endLoop2 #neu tim thay trong charGroup thi chuyen sang ki tu tiep theo
        			addi $t1, $t1, 1	# j++
        			j loop2
        		endLoop2:	
       			addi $t0, $t0, 1 		# i++
       		j loop1
       		
       	endLoop1:	
       		li $s5, 1		# neu dung toan bo ky tu check = 1 
endCheckIdentFunc:
		jr $ra
#<-- ket thuc kiem tra label --> 

readData: # Doc lenh nhap vao tu ban phim
	li $v0, 4
	la $a0, command #in ra man hinh
	syscall
	li $v0, 8	#readString
	la $a0, input # chua dia chi cua lenh nhap vao
	li $a1, 100
	syscall
	
main:	
	
#<--tach opcode tu chuoi input -->
	la $a1, token # luu cac ki tu doc duoc vao token	
readOpcode: 
	add $t3, $a0, $k1 # dich bit
	add $t4, $a1, $k1
	lb $t2, 0($t3) # doc tung ki tu cua input
	sb $t2, 0($t4)
	beq $t2, ' ', done # gap ki tu ' ' -> luu ki tu nay vao opcode de xu ly
	beq $t2, '\0', done # ket thuc chuoi input
	beq $t2, '\n', done	
	addi $k1, $k1, 1
	j readOpcode
	
done:	
	addi  $t2, $0, '\0' 
	sb $t2, 0($t4) # xoa ky tu cuoi trong chuoi opcode ( '\n', ' ')
	
	
	li $t7, -9	   		# khoi tao buoc nhay -9
	la $a2, library 
	jal checkOpcodeFunc 		# kiem tra opcode co dung hay khong ?
	
	beq $s5, 1, checkOpcode 	# neu checkOpcode == 1 thi jump to checkOpcode 
	j notFound		  	# neu checkOpcode != 1 thi jump to notFound	
	checkOpcode:		# in ra man hinh + readToanHang1	
	
	li $v0, 4
	la $a0, msg_Opcode 		# opcode hop le
	syscall
	li $v0, 4
	la $a0, token
	syscall
	li $v0, 4
	la $a0, msg_HopLe
	syscall
	j readToanHang1
	
#<-- Bat dau xu ly toan hang 1 -->
	
readToanHang1:
	
	addi $k1, $k1, 1 	# tang inputIndex + 1 
	
	la $a0, input 
	li $t0, 0	
	li $t1, 0 
newLibraryIndex: 		# tang libraryIndex den ma code cua Opcode trong Library
	addi $t0,$k0, 3	#  3 so bieu dien dang toan hang cua lenh
	add $t3, $a2, $t0
	lb $t2, 0($t3)
	beq $t2, ';', splitTH1
	addi $k0, $k0, 1
	j newLibraryIndex
	
	#while (library[libraryIndex + 3] != ';')
    	#{
       	#libraryIndex++;
    	#}
	
splitTH1:	#split Toan Hang thu 1

	add $t3, $a0, $k1 # dich bit
	add $t4, $a1, $t1
	lb $t2, 0($t3) # doc tung ki tu cua input
	sb $t2, 0($t4)
	beq $t2, ',', doneSplitTH1 
	beq $t2,'\0', doneSplitTH1 
	beq $t2,'\n', doneSplitTH1
	addi $k1, $k1, 1
	addi $t1, $t1, 1
	j splitTH1
doneSplitTH1:
	addi  $t2, $0, '\0'  
	sb $t2, 0($t4) 	# xoa ky tu cuoi trong chuoi token ( '\n', ' ')
	
	add $t4, $a2, $k0
	lb  $s7, 0($t4)
	addi $s7,$s7,-48 	# s7 = library[index -48]
	TH1case0:		
		bne $s7, 0, TH1case1 		
		jal checkNTFunc 	# kiem tra Toan Hang Rong
		j TH1done 			
	TH1case1:	
		bne $s7, 1, TH1case2 					
		jal checkTokenRegFunc # kiem tra Toan Hang co dang Thanh Ghi dung hay sai			
		j TH1done 				
	TH1case2:
		bne $s7, 2, TH1case3 	# kiem tra Toan Hang co dang Hang So Nguyen dung hay sai		
		jal checkHSNFunc 		
		j TH1done				
	TH1case3:
		bne $s7, 3, TH1done 		
		jal checkIdentFunc 	# kiem tra Toan Hang co dang label dung hay sai		
		j TH1done	
	TH1done:   
	               
		beq $s5, 1, checkToanHang1 	# neu check == 1 thi jump to checkToanHang1
		j notFound			# else check != 1 thi jump to notFound
	checkToanHang1:		# in ra man hinh + readToanHang2
		beq $s7, 0, readToanHang2
		li $v0, 4
		la $a0, msg_ToanHang # toanHang hop le
		syscall
		li $v0, 4
		la $a0, token
		syscall
		li $v0, 4
		la $a0, msg_HopLe
		syscall
#<-- Ket thuc xu ly Toan Hang 1 -->

#<-- Bat dau xu ly toan hang 2 -->
readToanHang2: #tuong tu xu ly Toan Hang 1
	addi $k1, $k1, 1
	addi $k0, $k0, 1 
	la $a1, token # luu cac ki tu doc duoc vao token
	la $a0, input 
	li $t0, 0	
	li $t1, 0
	
	
splitTH2:	

	add $t3, $a0, $k1 # dich bit
	add $t4, $a1, $t1
	lb $t2, 0($t3) # doc tung ki tu cua input
	sb $t2, 0($t4)
	beq $t2, 44, doneSplitTH2 # gap ki tu ',' -> luu ki tu nay vao token de xu ly
	beq $t2, 0, doneSplitTH2 # ket thuc chuoi input
	beq $t2, 10, doneSplitTH2
	addi $k1, $k1, 1
	addi $t1, $t1, 1
	j splitTH2
doneSplitTH2: 
	addi  $t2, $0, '\0' 
	sb $t2, 0($t4)
	
	add $t4, $a2, $k0
	lb  $s7, 0($t4)
	addi $s7,$s7,-48
	TH2case0:		
		bne $s7, 0, TH2case1 		
		jal checkNTFunc 		
		j TH2done 			
	TH2case1:	
		bne $s7, 1, TH2case2 					
		jal checkTokenRegFunc 		
		j TH2done 				
	TH2case2:
		bne $s7, 2, TH2case3 		
		jal checkHSNFunc 		
		j TH2done				
	TH2case3:
		bne $s7, 3, TH2done 		
		jal checkIdentFunc 		
		j TH2done	
	TH2done:  	
		beq $s5, 1, checkToanHang2
		j notFound
	checkToanHang2:
		beq $s7, 0, readToanHang3
		li $v0, 4
		la $a0, msg_ToanHang # opcode hop le
		syscall
		li $v0, 4
		la $a0, token
		syscall
		li $v0, 4
		la $a0, msg_HopLe
		syscall
#<-- Ket Thuc xu ly toan hang 2 -->

#<-- bat dau xu ly toan hang 3 -->
readToanHang3: # tuong tu xu ly nhu toan hang 1,2
	addi $k0, $k0, 1
	addi $k1, $k1, 1 
	la $a1, token # luu cac ki tu doc duoc vao token
	la $a0, input 
	li $t0, 0	
	li $t1, 0

	
splitTH3:	

	add $t3, $a0, $k1 # dich bit
	add $t4, $a1, $t1
	lb $t2, 0($t3) # doc tung ki tu cua input
	sb $t2, 0($t4)
	beq $t2, 44, doneSplitTH3 # gap ki tu ',' -> luu ki tu nay vao token de xu ly
	beq $t2, 0, doneSplitTH3 # ket thuc chuoi input
	beq $t2, 10, doneSplitTH3
	addi $k1, $k1, 1
	addi $t1, $t1, 1
	j splitTH3
doneSplitTH3:
	addi $t2, $0, '\0' 
	sb   $t2, 0($t4)
	
	add  $t4, $a2, $k0
	lb   $s7, 0($t4)
	addi $s7, $s7,-48
	TH3case0:		
		bne $s7, 0, TH3case1 		
		jal checkNTFunc 		
		j TH3done 			
	TH3case1:	
		bne $s7, 1, TH3case2 					
		jal checkTokenRegFunc 		
		j TH3done 				
	TH3case2:
		bne $s7, 2, TH3case3 		
		jal checkHSNFunc 		
		j TH3done				
	TH3case3:
		bne $s7, 3, TH3done 		
		jal checkIdentFunc 		
		j TH3done	
	TH3done:             
		beq $s5, 1, checkToanHang3
		j notFound
	checkToanHang3:
		beq $s7, 0, end
		li $v0, 4
		la $a0, msg_ToanHang # opcode hop le
		syscall
		li $v0, 4
		la $a0, token
		syscall
		li $v0, 4
		la $a0, msg_HopLe
		syscall
		j end

#<-- Ket thuc xu ly toan hang 3

continue: # lap lai chuong trinh.
	li $v0, 4
	la $a0, continueMessage
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
	la $a0, token
	syscall
	
	li $v0, 4
	la $a0, NF
	syscall
	j error
error:
	li $v0, 4
	la $a0, errMessage
	syscall
	j continue
end:
	li $v0, 4
	la $a0, endMess
	syscall
	j continue
TheEnd:
	
