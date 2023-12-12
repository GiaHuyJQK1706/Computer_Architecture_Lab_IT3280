# Mars bot
.eqv HEADING 0xffff8010 
.eqv MOVING 0xffff8050
.eqv LEAVETRACK 0xffff8020
.eqv WHEREX 0xffff8030
.eqv WHEREY 0xffff8040
# Key matrix
.eqv OUT_ADRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv IN_ADRESS_HEXA_KEYBOARD 0xFFFF0012

.data
# postscript-DCE => numpad 0
# (rotate,time,0=untrack | 1=track;)
pscript1: .asciiz "90,2000,0;180,3000,0;180,5790,1;80,500,1;70,500,1;60,500,1;50,500,1;40,500,1;30,500,1;20,500,1;10,500,1;0,500,1;350,500,1;340,500,1;330,500,1;320,500,1;310,500,1;300,500,1;290,500,1;280,490,1;90,7000,0;270,500,1;260,500,1;250,500,1;240,500,1;230,500,1;220,500,1;210,500,1;200,500,1;190,500,1;180,500,1;170,500,1;160,500,1;150,500,1;140,500,1;130,500,1;120,500,1;110,500,1;100,500,1;90,1000,1;90,5000,0;270,2000,1;0,5800,1;90,2000,1;180,2900,0;270,2000,1;90,3000,0;"


# postscript-DAT => numpad 4
pscript2: .asciiz "90,5000,0;180,3000,0;270,500,1;260,500,1;250,500,1;240,500,1;230,500,1;220,500,1;210,500,1;200,500,1;190,500,1;180,500,1;170,500,1;160,500,1;150,500,1;140,500,1;130,500,1;120,500,1;110,500,1;100,500,1;0,2500,1;270,1000,1;90,2000,1;90,1000,0;"



# postscript-DUY => numpad 8
pscript3: .asciiz "90,4000,0;180,3000,0;90,4000,1;270,2000,1;180,5790,1;90,3000,0;0,5790,1;100,500,1;120,500,1;140,500,1;160,500,1;180,500,1;200,500,1;220,500,1;240,500,1;260,500,1;270,50,1;145,3550,1;90,1000,0;0,5790,0;180,5790,1;90,4000,1;0,5790,1;90,1000,0;180,5790,1;90,4000,1;0,5790,1;270,4000,1;90,5000,0;180,5790,0;0,5790,1;145,6900,1;0,5790,1;90,4000,0;270,500,1;260,500,1;250,500,1;240,500,1;230,500,1;220,500,1;210,500,1;200,500,1;190,500,1;180,500,1;170,500,1;160,500,1;150,500,1;140,500,1;130,500,1;120,500,1;110,500,1;100,500,1;0,2500,1;270,1000,1;90,2000,1;180,1000,0;"



.text
# <--xu ly tren keymatrix-->
	li $t3, IN_ADRESS_HEXA_KEYBOARD
	li $t4, OUT_ADRESS_HEXA_KEYBOARD
	
	
# KEY MAXTRIX
        # $a0 gia tri key dang an
	
# MARBOT	
	# $t0 rotate
	# $t1 time
	# $t5 ki tu hien tai dang doc trong prscrip
	# $a1 dia chi dau tien cua prscrip
	# $t6 vi tri ki tu dang doc trong prscrip
 
	
	
polling: 
	li $t5, 0x01 # row-1 of key matrix
	sb $t5, 0($t3) 
	lb $a0, 0($t4) 
	bne $a0, 0x11, NOT_NUMPAD_0
	la $a1, pscript1
	j START
	NOT_NUMPAD_0:
	li $t5, 0x02 # row-2 of key matrix
	sb $t5, 0($t3)
	lb $a0, 0($t4)
	bne $a0, 0x12, NOT_NUMPAD_4
	la $a1, pscript2
	j START
	NOT_NUMPAD_4:
	li $t5, 0X04 # row-3 of key matrix
	sb $t5, 0($t3)
	lb $a0, 0($t4)
	bne $a0, 0x14, COME_BACK
	la $a1, pscript3
	j START
COME_BACK: j polling # khi cac so 0,4,8 khong duoc chon -> quay lai doc tiep
# <!--end xu ly key matrix-->

# <--xu li mars bot -->
START:
	jal GO
READ_PSCRIPT: 
	addi $t0, $zero, 0 # luu gia tri rotate(goc quay)
	addi $t1, $zero, 0 # luu gia tri time
	
 	READ_ROTATE:
 	add $t7, $a1, $t6 # dich bit
	lb $t5, 0($t7)  # doc cac ki tu cua pscript
	beq $t5, 0, END # ket thuc pscript
 	beq $t5, 44, READ_TIME # gap ki tu ','
 	mul $t0, $t0, 10 
 	addi $t5, $t5, -48 # So 0 co thu tu 48 trong bang ascii.(ki tu doc dc la ma ascii cua ki tu so, nên phai tru di 48)
 	add $t0, $t0, $t5  # cong cac chu so lai voi nhau.
 	addi $t6, $t6, 1 # tang so bit can dich chuyen len 1
 	j READ_ROTATE # quay lai doc tiep den khi gap dau ','
 	
 	READ_TIME: # doc thoi gian chuyen dong.
 
 	addi $t6, $t6, 1
 	add $t7, $a1, $t6 # ($a1 luu dia chi cua pscript)
	lb $t5, 0($t7) 
	beq $t5, 44, READ_TRACK
	mul $t1, $t1, 10
 	addi $t5, $t5, -48
 	add $t1, $t1, $t5
 	j READ_TIME # quay lai doc tiep den khi gap dau ','
 	
 	READ_TRACK:
 	
 	addi $t6, $t6, 1 
 	add $t7, $a1, $t6
	lb $t5, 0($t7) 
 	addi $t5, $t5, -48
 	beq $t5, $zero, CHECK_UNTRACK # 1=track | 0=untrack
 	jal UNTRACK
	jal TRACK
	j INCREAMENT
	
CHECK_UNTRACK:
	jal UNTRACK
INCREAMENT:
        add $a0, $t0, $zero
	jal ROTATE
        
        addi $v0,$zero,32 # Keep mars bot running by sleeping with time=$t1
 	add $a0, $zero, $t1
	syscall
 	addi $t6, $t6, 2 # bo qua dau ';'
 	j READ_PSCRIPT

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
END:
	jal STOP
	li $v0, 10
	syscall
	
# <!--end-->
