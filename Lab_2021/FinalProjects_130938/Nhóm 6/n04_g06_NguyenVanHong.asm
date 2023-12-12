.data
#  an nut numpad 0 thuc hien gia cong DCE 
postscript1: .asciiz "90,0,2000;180,0,3000;180,1,5790;80,1,500;70,1,500;60,1,500;50,1,500;40,1,500;30,1,500;20,1,500;10,1,500;0,1,500;350,1,500;340,1,500;330,1,500;320,1,500;310,1,500;300,1,500;290,1,500;280,1,490;90,0,7000;270,1,500;260,1,500;250,1,500;240,1,500;230,1,500;220,1,500;210,1,500;200,1,500;190,1,500;180,1,500;170,1,500;160,1,500;150,1,500;140,1,500;130,1,500;120,1,500;110,1,500;100,1,500;90,1,1000;90,0,5000;270,1,3000;0,1,5800;90,1,3000;180,0,2900;270,1,3000;90,0,3000;"
#  an nut numpad 4 thuc hien gia cong VAN
postscript2: .asciiz "90,0,2000;180,0,2000;160,1,5321;20,1,5321;90,0,2500;200,1,5321;20,0,2341;90,1,2039;340,1,3300;160,0,3300;160,1,2500;90,0,1500;0,1,5300;150,1,5474;0,1,5300;90,0,3000;"
#  an nut numpad 8 thuc hien gia cong HONG
postscript3: .asciiz "90,0,2000;180,0,2000;180,1,6000;0,0,3000;90,1,3500;0,1,3000;180,1,6000;90,0,5000;80,1,500;70,1,500;60,1,500;50,1,500;40,1,500;30,1,500;20,1,500;10,1,500;0,1,500;350,1,500;340,1,500;330,1,500;320,1,500;310,1,500;300,1,500;290,1,500;280,1,500;270,1,500;260,1,500;250,1,500;240,1,500;230,1,500;220,1,500;210,1,500;200,1,500;190,1,500;180,1,500;170,1,500;160,1,500;150,1,500;140,1,500;130,1,500;120,1,500;110,1,500;100,1,500;90,1,500;90,0,5000;0,1,6000;150,1,6228;0,1,6000;90,0,5000;270,1,500;260,1,500;250,1,500;240,1,500;230,1,500;220,1,500;210,1,500;200,1,500;190,1,500;180,1,500;170,1,500;160,1,500;150,1,500;140,1,500;130,1,500;120,1,500;110,1,500;100,1,500;90,1,1000;0,1,2500;270,1,2000;90,0,5000;"

.eqv HEADING 0xffff8010   		# xac dinh goc 
.eqv MOVING 0xffff8050  		# co di chuyen hay khong
.eqv LEAVETRACK 0xffff8020 	# co tao vet (luu vet) hay k:
.eqv WHEREX 0xffff8030  		# vi tri x hien tai cua MarsBot
.eqv WHEREY 0xffff8040  		# vi tri y hien tai MarsBot
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014		# doc dia chi  
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012		# kiem tra xem no o hang ( cot ) nao

.text
# xu ly tren keymatrix
	li $t3, IN_ADRESS_HEXA_KEYBOARD
	li $t4, OUT_ADRESS_HEXA_KEYBOARD
polling: 
	li $t5, 0x01 					# check hang 1
	sb $t5, 0($t3) 					# must reassign expected row 
	lb $a0, 0($t4)  					# $a0 = read scan code of key button 
	bne $a0, 0x11, NOT_NUMPAD_0 	# if not numpad 0
	la $a1, postscript1				# a1 = address of postsciprt 1
	j START
	
	NOT_NUMPAD_0:
	li $t5, 0x02  					# check hang 2
	sb $t5, 0($t3) 					# must reassign expected row
	lb $a0, 0($t4)  					# read scan code of key button 
	bne $a0, 0x12, NOT_NUMPAD_4  # if not numpad 4
	la $a1, postscript2				# a1 = address of postsciprt 2
	j START
	
	NOT_NUMPAD_4:
	li $t5, 0X04 					# check hang 3
	sb $t5, 0($t3)  					# must reassign expected row
	lb $a0, 0($t4) 					# read scan code of key button 
	bne $a0, 0x14, COME_BACK 	# if not numpad 8
	la $a1, postscript3				# a1 = address of postsciprt 3
	j START
 COME_BACK: j polling 			# neu numpad 0, 4, 8 khong duoc chon -> quay lai doc tiep 



# xu li tren marsbot
START:
	jal GO 	
	
READ_POSTCRIPT: 
	addi $t0, $zero, 0 				# $t0 luu gia tri rotate
	addi $t1, $zero, 0 				# $t1 luu gia tri time
	
READ_ROTATE: 					# doc goc quay 
								# $t6 = i = 0 , i la chi so duyet mang xau
 	add $t7, $a1, $t6 				# dich bit
	lb $t5, 0($t7)  					# doc cac ki tu cua pscript
	beq $t5, 0, END_PROGRAM 		# n?u  là kí t? r?ng thì ket thuc doc pscript
 	beq $t5, 44, READ_TRACK 		# gap dau "," chuyen den READ_TRACK 
 	mul $t0, $t0, 10 				# $t0 = $t0 * 10
 	addi $t5, $t5, -48 				# $t5 = $t5 - 48 -> $t5 = ma ASCII -48 = gia tri ki tu can tim 
 	add $t0, $t0, $t5  				# $t0 = $t0 + $t5
 	addi $t6, $t6, 1 				# tang so bit can dich chuyen len 1
 	j READ_ROTATE 				# quay lai doc tiep den khi nao gap ','

READ_TRACK:
 	add $a0, $zero, $t0     			# Marsbot quay $t0 ?? và di chuy?n
	jal ROTATE        

 	addi $t6, $t6, 1 				# $t6 = $t6 + 1 -> tang so bit can dich chuyen len 1
 	add $t7, $a1, $t6 				# $t7= $a1 + $t6 =  postscript[0] + i = address of postscript[i], dich bit
	lb $t9, 0($t7) 					# t9  (1 OR 0)
 	addi $t9, $t9, -48				# $t9 = $t9 - 48 -> $t5 = ma ASCII -48 = gia tri ki tu can tim 
 	addi $t6, $t6, 1 				# $t6 = $t6 + 1 -> tang so bit can dich chuyen len 1
READ_TIME: 						# doc thoi gian chuyen dong.
	addi $t6, $t6, 1 				# $t6 = $t6 + 1 -> tang so bit can dich chuyen len 1
 	add $t7, $a1, $t6 				# $t7= $a1 + $t6 =  postscript[0] + i = address of postscript[i]
	lb $t5, 0($t7)  					# $t5= value at $t7 = postscript[i], doc cac ki tu cua pscript
	beq $t5, 59, CONTINUE 			# gap dau ";" chuyen den cau truc moi 
	mul $t1, $t1, 10				# $t1 = $t1 * 10
 	addi $t5, $t5, -48				# $t5 = $t5 - 48 -> $t5 = ma ASCII -48 = gia tri ki tu can tim
 	add $t1, $t1, $t5				# $t1 = $t1 + $t5
 	j READ_TIME 					# quay lai doc tiep den khi gap dau ','

CONTINUE:
   	addi $v0,$zero,32 				# Tiep tuc chay sau $t1 ms
 	add $a0, $zero, $t1     			# $a0 = $t1
 	beq $t9, $zero, NON_CUT 		# Neu bang 1 thì cat , neu bang  0 thì không cat
 	jal UNTRACK					# Gi? nguyên TRACK c?	
	jal TRACK					# v? TRACK m?i
	j READ_NEXT_PHASE
NON_CUT:
	jal UNTRACK					# Giu nguyen TRACK cu
	
READ_NEXT_PHASE:
	syscall
 	addi $t6, $t6, 1 				# tang so bit can dich chuyen len 1, bo qua dau ';'
 	j READ_POSTCRIPT			# quay lai doc tiep postscript
 	

 	
GO: 
 	li $at, MOVING 
 	addi $k0, $zero,1 
 	sb $k0, 0($at) 
 	jr $ra

STOP: 
	li $at, MOVING 
 	sb $zero, 0($at)
 	jr $ra

TRACK: 
	li $at, LEAVETRACK 
 	addi $k0, $zero,1 
	sb $k0, 0($at) 
 	jr $ra

UNTRACK:
	li $at, LEAVETRACK 
 	sb $zero, 0($at) 
 	jr $ra

ROTATE: 
	li $at, HEADING 
 	sw $a0, 0($at) 
 	jr $ra
 	
END_PROGRAM:
	jal STOP
	li $v0, 10
	syscall
	j polling

	
