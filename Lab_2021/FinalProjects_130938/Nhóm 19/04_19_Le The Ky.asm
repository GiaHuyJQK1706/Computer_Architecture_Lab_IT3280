.eqv	HEADING		0xffff8010	# Integer: An angle between 0 and 359
.eqv	MOVING		0xffff8050	# Boolean: whether MarsBot move or not
.eqv	LEAVETRACK	0xffff8020	# Boolean (0 or non-0): whether MarsBot leave a track or not
.eqv	IN_ADDRESS_HEXA_KEYBOARD	0xFFFF0012
.eqv	OUT_ADDRESS_HEXA_KEYBOARD	0xFFFF0014

.data
ptr1:	.word	0	# Pointer to the data of postscript 1
ptr2:	.word	0	# Pointer to the data of postscript 2
ptr3:	.word	0	# Pointer to the data of postscript 3
ps1:	.asciiz	"90,0,5000,180,0,8000,180,1,10000,75,1,3000,50,1,1500,25,1,1500,360,1,3000,350,1,1500,330,1,1500,310,1,1500,270,1,2700,90,0,14000,270,1,4000,200,1,5000,160,1,5000,90,1,4000,90,0,3000,90,1,4000,270,0,4000,360,1,9500,90,1,4000,270,0,4000,180,0,4750,90,1,4000"
#-----------------------------------------------------------
# Press 0 in Key Matrix to choose postscript 1 : draw 'DCE' 
#-----------------------------------------------------------
ps2:	.asciiz	"90,0,5000,180,0,8000,180,1,5000,90,1,10000,360,1,5000,270,0,5000,180,1,15000,90,0,15000,360,0,3000,360,1,8000,135,1,4000,45,1,4000,180,1,8000,90,0,2000,90,1,4000,360,1,8000,270,0,4000,180,1,8000"
#-----------------------------------------------------------
# Press 4 in Key Matrix to choose postscript 2 : draw 'MU' 
#-----------------------------------------------------------
ps3:	.asciiz	"90,0,10000,180,0,8000,90,1,10000,270,0,5000,360,1,1000,180,0,2000,270,1,4000,180,1,1000,90,1,8000,360,1,1000,270,1,4000,180,0,2000,270,1,5000,180,1,3000,360,0,3000,90,0,5000,90,1,5000,180,1,4000,270,1,1000,90,0,1000,360,0,4000,270,0,5000,180,0,1000,90,1,4000,180,1,1000,270,1,8000,360,1,1000,90,1,4000,90,0,10000"
#-----------------------------------------------------------
# Press 8 in Key Matrix to choose postscript 3 : draw 'takai' 
#-----------------------------------------------------------

.kdata
initptr:	.word	0	# Pointer to initialize the postscript data array
firstaddress:	.word		# The first address of the array 

.text
main:
       
setup:
	jal	initialize

	la	$a0, ps1
	jal	store_data
	la	$t0, ptr1
	sw	$v0, 0($t0)
	
	la	$a0, ps2
	jal	store_data
	la	$t0, ptr2
	sw	$v0, 0($t0)
	
	la	$a0, ps3
	jal	store_data
	la	$t0, ptr3
	sw	$v0, 0($t0)

main_loop:
	jal	press
	nop
	j	main_loop
	
end_main:

initialize:
	la	$t0, initptr
	la	$t1, firstaddress
	sw	$t1, 0($t0)
	jr	$ra

store_data:
	la	$t0, initptr
	lw	$v0, 0($t0)
	add	$t0, $0, $v0
	add	$t1, $0, $a0
script_read_loop:
	add	$t2, $0, $0
number_read_loop:
	lbu	$t3, 0($t1)
	beq	$t3, ',', number_read_end
	beq	$t3, '\0', script_read_end
	subi	$t3, $t3, '0'
	mul	$t2, $t2, 10
	add	$t2, $t2, $t3
	addi	$t1, $t1, 1
	j	number_read_loop
number_read_end:
	sw	$t2, 0($t0)
	addi	$t0, $t0, 4
	addi	$t1, $t1, 1
	j	script_read_loop
script_read_end:
	sw	$t2, 0($t0)
	sw	$0, 4($t0)
	sw	$0, 8($t0)
	sw	$0, 12($t0)
	addi	$t0, $t0, 16
	la	$t1, initptr
	sw	$t0, 0($t1)
	jr	$ra

press:
	li	$t0, IN_ADDRESS_HEXA_KEYBOARD
	li	$t1, OUT_ADDRESS_HEXA_KEYBOARD
reset_button:
	lb	$t3, 0($t1)
	bne	$t3, 0, finish
case_0:
	addi	$t2, $0, 0x01
	sb	$t2, 0($t0)
	lb	$t3, 0($t1)
	bne	$t3, 0x11, case_4
	la	$t0, ptr1
	lw	$a3, 0($t0)
	j	start
case_4:
	addi	$t2, $0, 0x02
	sb	$t2, 0($t0)
	lb	$t3, 0($t1)
	bne	$t3, 0x12, case_8
	la	$t0, ptr2
	lw	$a3, 0($t0)
	j	start
case_8:
	addi	$t2, $0, 0x04
	sb	$t2, 0($t0)
	lb	$t3, 0($t1)
	bne	$t3, 0x14, finish
	la	$t0, ptr3
	lw	$a3, 0($t0)
	j	start
finish:
	jr	$ra	
	
start:
	addi	$t3, $0, 1
	addi	$v0, $0, 32
draw_loop:
	lw	$a1, 0($a3)
	lw	$a2, 4($a3)
	lw	$a0, 8($a3)
	li	$t1, HEADING
	li	$t2, LEAVETRACK
	sw	$a1, 0($t1)
	sw	$a2, 0($t2)
	or	$t0, $a1, $a2
	or	$t0, $t0, $a0
	beq	$t0, 0, draw_end
	li	$t0, MOVING
	sw	$t3, 0($t0)
	syscall
	sw	$0, 0($t0)
	sw	$0, 0($t2)
	addi	$a3, $a3, 12
	j	draw_loop
draw_end:
	j	finish
