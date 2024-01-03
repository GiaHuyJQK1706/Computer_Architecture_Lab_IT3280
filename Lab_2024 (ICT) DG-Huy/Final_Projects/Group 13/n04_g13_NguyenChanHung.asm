.eqv HEADING 0xffff8010
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv MOVING 0xffff8050 # Boolean: whether or not to move
.eqv LEAVETRACK 0xffff8020 # Boolean (0 or non-0):
# whether or not to leave a track
.eqv WHEREX 0xffff8030
.eqv WHEREY 0xffff8040

.data
dce: .word 90,0,2000,180,1,7000,60,1,2631,30,1,1443,0,1,1000,-30,1,1443,-60,1,2631,90,0,8000,-100,1,2682,-170,1,2066,170,1,2066,100,1,2682,90,0,2000,0,1,5000,90,1,3000,180,0,2500,-90,1,3000,180,0,2500,90,1,3000
nch: .word 180,1,5000,0,0,5000,149,1,5700,0,1,5000,90,0,6000,-100,1,2682,-170,1,2066,170,1,2066,100,1,2682,90,0,2000,0,1,5000,180,0,2500,90,1,3000,0,1,2500,180,1,5000
number: .word 180,0,5000,0,1,5000,90,0,2000,90,1,3000,180,1,2500,-90,1,3000,180,1,2500,90,1,3000,90,0,2000,90,1,3000,0,1,5000,-90,1,3000,180,0,2500,90,1,3000

.text
main: 	
li $t1, IN_ADDRESS_HEXA_KEYBOARD
li $t3, 0x80 # bit 7 = 1 to enable
sb $t3, 0($t1)

Loop: 
sleep: addi $v0,$zero,32
li $a0,300 # sleep 300 ms
syscall
nop # WARNING: nop is mandatory here.
b Loop # Loop
end_main:
li $v0,10
syscall

.ktext 0x80000180

li $s5,18
li $s6,14
li $s7,13

jal GO 
jal UNTRACK
li $a0,180
jal ROTATE
li $v0,32
li $a0,2000
syscall
li $a0,90
jal ROTATE
li $v0,32
li $a0,2000
syscall
jal STOP

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
row1:li $t1, IN_ADDRESS_HEXA_KEYBOARD
li $t3, 0x81 # check row 1
sb $t3, 0($t1) # must reassign expected row
li $t1, OUT_ADDRESS_HEXA_KEYBOARD
lb $a0, 0($t1)
beq $a0,0x00000011,cut_DCE_lbl
row2: li $t1, IN_ADDRESS_HEXA_KEYBOARD
li $t3, 0x82 # check row 1
sb $t3, 0($t1) # must reassign expected row
li $t1, OUT_ADDRESS_HEXA_KEYBOARD
lb $a0, 0($t1)
beq $a0,0x00000012,cut_NCH_lbl
row3: li $t1, IN_ADDRESS_HEXA_KEYBOARD
li $t3, 0x84 # check row 1
sb $t3, 0($t1) # must reassign expected row
li $t1, OUT_ADDRESS_HEXA_KEYBOARD
lb $a0, 0($t1)
beq $a0,0x00000014,cut_123_lbl
j next_pc

cut_DCE_lbl:
add $a0,$s5,$zero
la $a1,dce
jal cut
j next_pc
cut_NCH_lbl:
add $a0,$s6,$zero
la $a1,nch
jal cut
j next_pc
cut_123_lbl:
add $a0,$s7,$zero
la $a1,number
jal cut
next_pc:mfc0 $at, $14 # $at <= Coproc0.$14 = Coproc0.epc
addi $at, $at, 4 # $at = $at + 4 (next instruction)
mtc0 $at, $14 # Coproc0.$14 = Coproc0.epc <= $at
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

cut:
addi $s4,$a0,0 # total no. instructions
li $t0,0  # number of instructions
li $t8,0  # index of dce
la $t1,($a1)  # $t1 = addr(dce[0])
jal GO
loop_cut:
bgt $t0,$s4,end_loop_cut
mul $t2,$t8,4
add $t3,$t1,$t2  # $t3 = addr(dce[i])
lw $s0,($t3) # $s0 = ANGLE
addi $t8,$t8,1
mul $t2,$t8,4
add $t3,$t1,$t2  # $t3 = addr(dce[i+1])
lw $s1,($t3) # #s1 = CUT/UNCUT
addi $t8,$t8,1
mul $t2,$t8,4
add $t3,$t1,$t2  # $t3 = addr(dce[i+2])
lw $s2,($t3) # #s2 = DURATION
add $a0,$s0,$zero
jal ROTATE
beq $s1,1,toggle_track
j toggle_untrack
toggle_track:
jal TRACK
j sleep_command
toggle_untrack:
jal UNTRACK
sleep_command:
li $v0,32
add $a0,$s2,$zero
syscall
continue:
addi $t0,$t0,1
addi $t8,$t8,1
jal UNTRACK
j loop_cut
end_loop_cut:
jal STOP
jr $ra