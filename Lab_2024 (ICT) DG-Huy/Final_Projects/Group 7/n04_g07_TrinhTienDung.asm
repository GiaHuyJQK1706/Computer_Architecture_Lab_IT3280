# Mars Bot
.eqv HEADING 0xffff8010 # Integer: An angle between 0 and 359
.eqv MOVING 0xffff8050 # Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 # Boolean (0 or non-0): whether or not to leave a track
.eqv WHEREX 0xffff8030 # Integer: Current x-location of MarsBot
.eqv WHEREY 0xffff8040 # Integer: Current y-location of MarsBot
#Key Matrix
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014

.data
# postscript when 0 is pressed: DCE
postscript0: .word 90,0,3000,180,0,3000,180,1,5800,80,1,500,70,1,500,60,1,500,50,1,500,40,1,500,30,1,500,20,1,500,10,1,500,0,1,500,350,1,500,340,1,500,330,1,500,320,1,500,310,1,500,300,1,500,290,1,500,280,1,500,90,0,7000,270,1,500,260,1,500,250,1,500,240,1,500,230,1,500,220,1,500,210,1,500,200,1,500,190,1,500,180,1,500,170,1,500,160,1,500,150,1,500,140,1,500,130,1,500,120,1,500,110,1,500,100,1,500,90,1,500,90,0,5000,270,1,3000,0,1,5800,90,1,3000,180,0,2900,270,1,3000,27,0,6620
end0: .word
# postscript when 4 is pressed
postscript4: .word 90,0,6000,180,0,3000,270,1,500,260,1,500,250,1,500,240,1,500,230,1,500,220,1,500,210,1,500,200,1,500,190,1,500,180,1,500,170,1,500,160,1,500,150,1,500,140,1,500,130,1,500,120,1,500,110,1,500,100,1,500,90,1,500,80,1,500,70,1,500,60,1,500,50,1,500,40,1,500,30,1,500,20,1,500,10,1,500,0,1,500,350,1,500,340,1,500,330,1,500,320,1,500,310,1,500,300,1,500,290,1,500,280,1,500,270,1,500,45,0,4100
end4: .word
# postscript when 8 is pressed
postscript8: .word 90,0,6000,180,0,3000,270,1,1500,240,1,1500,210,1,1500,180,1,1500,150,1,1500,120,1,1500,90,1,1500,60,1,1500,30,1,1500,0,1,1500,330,1,1500,300,1,1500,45,0,4100
end8: .word

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# MAIN Procedure
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.text
main:
#---------------------------------------------------------
# Enable interrupts you expect
#---------------------------------------------------------
# Enable the interrupt of Keyboard matrix 4x4 of Digital Lab Sim
li $t1, IN_ADDRESS_HEXA_KEYBOARD
li $t3, 0x80 # bit 7 = 1 to enable
sb $t3, 0($t1)
#---------------------------------------------------------
# No-end loop
#---------------------------------------------------------
Loop: 
nop
nop
addi $v0, $zero, 32
li $a0, 200
syscall
nop
nop
b Loop # Wait for interrupt
end_main:
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
#-------------------------------------------------------
# SAVE the current REG FILE to stack
#-------------------------------------------------------
IntSR: addi $sp,$sp,4 # Save $at because we may change it later
sw $at,0($sp)
addi $sp,$sp,4 # Save $sp because we may change it later
sw $v0,0($sp)
addi $sp,$sp,4 # Save $a0 because we may change it later
sw $a0,0($sp)
addi $sp,$sp,4 # Save $t1 because we may change it later
sw $t1,0($sp)
addi $sp,$sp,4 # Save $t3 because we may change it later
sw $t3,0($sp)
#--------------------------------------------------------
# Processing
#--------------------------------------------------------
get_key:
li $t1, IN_ADDRESS_HEXA_KEYBOARD
li $t3, 0x81 # check row 1 and re-enable bit 7
sb $t3, 0($t1) # must reassign expected row
li $t1, OUT_ADDRESS_HEXA_KEYBOARD
lb $a0, 0($t1)
bne $a0, 0x0, key_pressed

li $t1, IN_ADDRESS_HEXA_KEYBOARD
li $t3, 0x82 # check row 2 and re-enable bit 7
sb $t3, 0($t1) # must reassign expected row
li $t1, OUT_ADDRESS_HEXA_KEYBOARD
lb $a0, 0($t1)
bne $a0, 0x0, key_pressed

li $t1, IN_ADDRESS_HEXA_KEYBOARD
li $t3, 0x84 # check row 3 and re-enable bit 7
sb $t3, 0($t1) # must reassign expected row
li $t1, OUT_ADDRESS_HEXA_KEYBOARD
lb $a0, 0($t1)
bne $a0, 0x0, key_pressed

key_pressed:
beq $a0, 0x11, key_0 # 0 is pressed
beq $a0, 0x12, key_4 # 4 is pressed
beq $a0, 0x14, key_8 # 8 is pressed
j end_script
key_0:
la $a2, postscript0 # start address of postscript
la $a1, end0 # end address of postscript
j MarsBot_Draw
key_4:
la $a2, postscript4 # start address of postscript
la $a1, end4 # end address of postscript
j MarsBot_Draw
key_8:
la $a2, postscript8 # start address of postscript
la $a1, end8 # end address of postscript
j MarsBot_Draw

MarsBot_Draw: # draw mars bot
read_script: # read postscript
beq $a2, $a1, end_script
read_angle:
lw $a0, 0($a2) # load angle to $a0
jal ROTATE 
addi $a2, $a2, 4 # go to next parameter of postscript
read_cut_uncut: # cut if 1, uncut if 0
lw $s0, 0($a2)
beq $s0, $0, read_duration
jal TRACK # track if parameter is 1
read_duration: 
jal GO
addi $a2, $a2, 4 # go to next parameter of postscript
lw $a0, 0($a2) # load duration to $a0
addi $v0,$zero,32 # Keep running by sleeping 
syscall
jal UNTRACK 
addi $a2, $a2, 4 # go to next parameter of postscript
j read_script # jump back to loop

end_script:
jal STOP

#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc
addi $at, $at, 4 # $at = $at + 4 (next instruction)
mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at
#--------------------------------------------------------
# RESTORE the REG FILE from STACK
#--------------------------------------------------------
restore:lw $t3, 0($sp) # Restore the registers from stack
addi $sp,$sp,-4
lw $t1, 0($sp) # Restore the registers from stack
addi $sp,$sp,-4
lw $a0, 0($sp) # Restore the registers from stack
addi $sp,$sp,-4
lw $v0, 0($sp) # Restore the registers from stack
addi $sp,$sp,-4
lw $at, 0($sp) # Restore the registers from stack
addi $sp,$sp,-4
return: eret # Return from exception




GO: li $at, MOVING # change MOVING port
addi $k0, $zero,1 # to logic 1,
sb $k0, 0($at) # to start running
jr $ra

STOP: li $at, MOVING # change MOVING port to 0
sb $zero, 0($at) # to stop
jr $ra

TRACK: li $at, LEAVETRACK # change LEAVETRACK port
addi $k0, $zero,1 # to logic 1,
sb $k0, 0($at) # to start tracking
jr $ra

UNTRACK:li $at, LEAVETRACK # change LEAVETRACK port to 0
sb $zero, 0($at) # to stop drawing tail
jr $ra

ROTATE: li $at, HEADING # change HEADING port
sw $a0, 0($at) # to rotate robot
jr $ra
