# ----------------------------------------- #
# Final Project - Computer Architecture Lab #
# Author: Pham Huy Canh - 20194490          #
# Postscript CNC Marsbot                    #
# ----------------------------------------- #


# -------------- KEY MATRIX --------------- #
.eqv IN_ADRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv OUT_ADRESS_HEXA_KEYBOARD 	0xFFFF0014
# ----------------------------------------- #


# -------------- MARS BOT ----------------- #
	.eqv HEADING 	0xffff8010
	.eqv LEAVETRACK 0xffff8020
	.eqv WHEREX 	0xffff8030
	.eqv WHEREY 	0xffff8040
	.eqv MOVING 	0xffff8050	
# ----------------------------------------- #


.data
	# DCE
	postscript1: .asciiz "135,0,5000,180,1,9600,70,1,2000,45,1,2000,15,1,2000,0,1,1500,345,1,2000,315,1,2000,290,1,2040,90,0,9000,265,1,3000,190,1,4500,170,1,4500,95,1,3000,90,0,5000,270,1,3000,0,1,9500,90,1,3000,180,0,4800,270,1,3000,90,0,5000"
	# HUY
	postscript2: .asciiz "135,0,5000,180,1,8600,90,0,4600,0,1,8600,180,0,4300,270,1,4600,90,0,6000,0,0,4310,180,1,6100,170,1,470,160,1,470,150,1,470,140,1,470,130,1,470,120,1,470,110,1,470,100,1,470,90,1,20,80,1,470,70,1,470,60,1,470,50,1,470,40,1,470,30,1,470,20,1,470,10,1,470,0,1,6100,90,0,1500,150,1,5000,30,1,5000,210,0,5000,180,1,4300,180,0,3000"
	# CANH
	postscript3: .asciiz "120,0,7000,320,1,470,310,1,470,300,1,470,290,1,470,280,1,470,270,1,470,260,1,470,250,1,470,240,1,470,230,1,470,220,1,470,210,1,470,200,1,470,190,1,470,180,1,3600,170,1,470,160,1,470,150,1,470,140,1,470,130,1,470,120,1,470,110,1,470,100,1,470,90,1,470,80,1,470,70,1,470,60,1,470,50,1,470,40,1,470,90,0,1500,180,0,1150,16,1,8800,164,1,8800,344,0,3770,270,1,2800,90,0,5200,180,0,3700,0,1,8380,150,1,9700,0,1,8380,90,0,1500,180,1,8380,90,0,4900,0,1,8380,180,0,4190,270,1,4900,90,0,7000"
	message: .asciiz "Ban co muon tiep tuc khong\n"


.text
# ---------------------- KEY MATRIX ----------------------- #
		li	$t1, IN_ADRESS_HEXA_KEYBOARD
		li 	$t2, OUT_ADRESS_HEXA_KEYBOARD

key0: 		li 	$t3, 0x01			
		sb 	$t3, 0($t1)
		lb 	$a0, 0($t2)
		bne 	$a0, 0x11, key4
		la 	$a1, postscript1
		j	mars_bot
key4:		li 	$t3, 0x02
		sb 	$t3, 0($t1)
		lb 	$a0, 0($t2)
		bne 	$a0, 0x12, key8
		la 	$a1, postscript2
		j 	mars_bot
key8:		li 	$t3, 0X04
		sb 	$t3, 0($t1)
		lb 	$a0, 0($t2)
		bne 	$a0, 0x14, key0
		la 	$a1, postscript3
		j 	mars_bot
# --------------------------------------------------------- #	
	
		
# ---------------------- MARS BOT ------------------------- #
mars_bot:	jal GO
read_postscript:li	$t0, 0			
next_num:	li	$a0, 0			
next_char:	lb	$s0, 0($a1)		 
		addi	$a1, $a1, 1		
		beq	$s0, 0, check
		beq	$s0, 44, check
		addi	$s0, $s0, -48		
		mul	$a0, $a0, 10		
		add	$a0, $a0, $s0		
		j	next_char
		
check:		addi	$t0, $t0, 1 		
number1:	bne	$t0, 1, number2
		jal	ROTATE
		j	next_num
		
number2:	bne	$t0, 2, CNC
		move	$t5, $a0		
		j	next_num

CNC:		beq 	$t5, $zero, no_cut
cut: 		jal 	UNTRACK
		jal 	TRACK
 		j	tsugi
 		
no_cut:		jal 	UNTRACK

tsugi:		li	$v0, 32
		syscall
		beq	$s0, 0, END
 		j 	read_postscript

GO:  		li 	$at, MOVING
 		addi 	$k0, $zero,1 
 		sb 	$k0, 0($at) 						
 		jr 	$ra
 		
STOP: 		li 	$at, MOVING 
 		sb 	$zero, 0($at)
 		jr 	$ra
 		
TRACK: 		li 	$at, LEAVETRACK	 
		addi 	$k0, $zero,1 
		sb 	$k0, 0($at)
 		jr 	$ra
 		
UNTRACK:	li 	$at, LEAVETRACK
 		sb 	$zero, 0($at) 
 		jr 	$ra
 		
ROTATE: 	li 	$at, HEADING 
 		sw 	$a0, 0($at)
 		jr	$ra
 	
END:		jal 	STOP
		li 	$v0, 10
		syscall
# --------------------------------------------------------- #	
