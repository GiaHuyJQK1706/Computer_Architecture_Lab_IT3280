# Check not pressing. If all rows return $a0 == 0, update {code} = 0.
# If {code} == 0, run `back_to_polling`.

# Check pressing. If pressed && $a0 != $s0, run `update_code`.
# Run `handle_code` to get key's value && switch mode.

# Mode 1: If old {operator} is "=", remove old info. Update {operand}, output new {operand}.
# Mode 2: If old {operator} doesn't change, do nothing.
# Else, update {operator}, update {answer} = {operand}, output old {operand}, remove old {operand}.
# Mode 3: Update {answer} = {answer} {operator} {operand}, update {operator}, update {operand} = {answer}, output new {answer}.

.eqv SEVENSEG_LEFT	0xFFFF0011
.eqv SEVENSEG_RIGHT	0xFFFF0010
.eqv IN_ADDRESS_HEXA_KEYBOARD       0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD      0xFFFF0014
.eqv CODE_0							0x11
.eqv CODE_1							0x21
.eqv CODE_2							0x41
.eqv CODE_3							0x81
.eqv CODE_4							0x12
.eqv CODE_5							0x22
.eqv CODE_6							0x42
.eqv CODE_7							0x82
.eqv CODE_8							0x14
.eqv CODE_9							0x24
.eqv CODE_ADD						0x44
.eqv CODE_SUB						0x84
.eqv CODE_MUL						0x18
.eqv CODE_DIV						0x28
.eqv CODE_MOD						0x48
.eqv CODE_EQL						0x88
.data
NUMS:	.word		0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
.text
main:
    li      $t1,            IN_ADDRESS_HEXA_KEYBOARD
    li      $t2,            OUT_ADDRESS_HEXA_KEYBOARD
init:
    li      $s0,            0                                               # code
    li      $s1,            0                                               # key's value (0 -> 15)
    li      $s2,            0                                               # mode (1, 2, 3)
    li      $s3,            0                                               # operand
    li      $s4,            0                                               # operator
    li      $s5,            0                                               # answer
polling:
check1:
    li      $t3,            0x01                                            # Check 0, 1, 2, 3
    sb      $t3,            0($t1)                                          # Must reassign expected row
    lbu     $a0,            0($t2)                                          # Read scan code of key button
    beq     $a0,            0,                          check2
    bne     $a0,            $s0,                        update_code
    beq     $a0,            $s0,                        back_to_polling
check2:
    li      $t3,            0x02                                            # Check 4, 5, 6, 7
    sb      $t3,            0($t1)                                          # Must reassign expected row
    lbu     $a0,            0($t2)                                          # Read scan code of key button
    beq     $a0,            0,                          check3
    bne     $a0,            $s0,                        update_code
    beq     $a0,            $s0,                        back_to_polling
check3:
    li      $t3,            0x04                                            # Check 8, 9, a, b
    sb      $t3,            0($t1)                                          # Must reassign expected row
    lbu     $a0,            0($t2)                                          # Read scan code of key button
    beq     $a0,            0,                          check4
    bne     $a0,            $s0,                        update_code
    beq     $a0,            $s0,                        back_to_polling
check4:
    li      $t3,            0x08                                            # Check c, d, e, f
    sb      $t3,            0($t1)                                          # Must reassign expected row
    lbu     $a0,            0($t2)                                          # Read scan code of key button
    beq     $a0,            0,                          update_code
    bne     $a0,            $s0,                        update_code
    beq     $a0,            $s0,                        back_to_polling
update_code:
    add     $s0,            $zero,                      $a0
    beq     $s0,            0,                          back_to_polling
    beq     $s0,            CODE_0,                     handle_code_0
    beq     $s0,            CODE_1,                     handle_code_1
    beq     $s0,            CODE_2,                     handle_code_2
    beq     $s0,            CODE_3,                     handle_code_3
    beq     $s0,            CODE_4,                     handle_code_4
    beq     $s0,            CODE_5,                     handle_code_5
    beq     $s0,            CODE_6,                     handle_code_6
    beq     $s0,            CODE_7,                     handle_code_7
    beq     $s0,            CODE_8,                     handle_code_8
    beq     $s0,            CODE_9,                     handle_code_9
    beq     $s0,            CODE_ADD,                   handle_code_add
    beq     $s0,            CODE_SUB,                   handle_code_sub
    beq     $s0,            CODE_MUL,                   handle_code_mul
    beq     $s0,            CODE_DIV,                   handle_code_div
    beq     $s0,            CODE_MOD,                   handle_code_mod
    beq     $s0,            CODE_EQL,                   handle_code_eql
handle_code_0:
    li      $s1,            0
    li      $s2,            1
    j       after_update
handle_code_1:
    li      $s1,            1
    li      $s2,            1
    j       after_update
handle_code_2:
    li      $s1,            2
    li      $s2,            1
    j       after_update
handle_code_3:
    li      $s1,            3
    li      $s2,            1
    j       after_update
handle_code_4:
    li      $s1,            4
    li      $s2,            1
    j       after_update
handle_code_5:
    li      $s1,            5
    li      $s2,            1
    j       after_update
handle_code_6:
    li      $s1,            6
    li      $s2,            1
    j       after_update
handle_code_7:
    li      $s1,            7
    li      $s2,            1
    j       after_update
handle_code_8:
    li      $s1,            8
    li      $s2,            1
    j       after_update
handle_code_9:
    li      $s1,            9
    li      $s2,            1
    j       after_update
handle_code_add:
    li      $s1,            10
    li      $s2,            2
    j       after_update
handle_code_sub:
    li      $s1,            11
    li      $s2,            2
    j       after_update
handle_code_mul:
    li      $s1,            12
    li      $s2,            2
    j       after_update
handle_code_div:
    li      $s1,            13
    li      $s2,            2
    j       after_update
handle_code_mod:
    li      $s1,            14
    li      $s2,            2
    j       after_update
handle_code_eql:
    li      $s1,            15
    li      $s2,            3
    j       after_update
after_update:
    beq     $s2,            1,                          mode1
    beq     $s2,            2,                          mode2
    beq     $s2,            3,                          mode3

# Mode 1: If old {operator} is "=", remove old info. Update {operand}, output new {operand}.
mode1:
    beq     $s4,            15,                         mode1_1
    j       mode1_2
mode1_1:
    li      $s3,            0                                               # Reset
    li      $s4,            0                                               # Reset
    li      $s5,            0                                               # Reset
mode1_2:
    mul     $s3,            $s3,                        10
    add     $s3,            $s3,                        $s1
    add     $a0,            $zero,                      $s3                 # Output {operand}
    li      $v0,            1
    syscall 
    jal     display                                                         # Output {operand} to SEVENSEG
    li      $a0,            '|'                                             # Output delimiter
    li      $v0,            11
    syscall 
    j       sleep

# Mode 2: If old {operator} doesn't change, do nothing.
# Else, update {operator}, update {answer} = {operand}, output old {operand}, remove old {operand}.
mode2:
    beq     $s4,            $s1,                        sleep
    add     $s4,            $zero,                      $s1                 # Update {operator}
    add     $s5,            $zero,                      $s3                 # Update {answer} = {operand}
    add     $a0,            $zero,                      $s3                 # Output {operand}
    li      $v0,            1
    syscall 
    jal     display                                                         # Output {operand} to SEVENSEG
    li      $a0,            '|'                                             # Output delimiter
    li      $v0,            11
    syscall 
    li      $s3,            0                                               # Remove {operand}
    j       sleep

# Mode 3: Update {answer} = {answer} {operator} {operand}, update {operator}, update {operand} = {answer}, output new {answer}.
mode3:
    beq     $s4,            10,                         calc_add
    beq     $s4,            11,                         calc_sub
    beq     $s4,            12,                         calc_mul
    beq     $s4,            13,                         calc_div
    beq     $s4,            14,                         calc_mod
    beq     $s4,            15,                         calc_eql
calc_add:
    add     $s5,            $s5,                        $s3
    j       after_calc
calc_sub:
    sub     $s5,            $s5,                        $s3
    j       after_calc
calc_mul:
    mul     $s5,            $s5,                        $s3
    j       after_calc
calc_div:
    div     $s5,            $s3
    mflo    $s5
    j       after_calc
calc_mod:
    div     $s5,            $s3
    mfhi    $s5
    j       after_calc
calc_eql:
    j       after_calc
after_calc:
    li      $s4,            15                                              # Update {operator} = "="
    add     $s3,            $zero,                      $s5                 # Update {operand} = {answer}
    add     $a0,            $zero,                      $s5                 # Output {answer}
    li      $v0,            1
    syscall 
    jal     display                                                         # Output {answer} to SEVENSEG
    li      $a0,            '|'                                             # Output delimiter
    li      $v0,            11
    syscall 
    j       sleep
sleep:
    li      $a0,            1000                                            # Sleep 1000ms
    li      $v0,            32
    syscall 
back_to_polling:
    j       polling                                                         # Continue polling


# function display:
# param[in]	$a0 interger to display
display:
display_save:
    add     $sp,            $sp,                        -24                 # Expand stack
    sw      $ra,            20($sp)                                         # Save
    sw      $s0,            16($sp)                                         # Save
    sw      $a0,            12($sp)                                         # Save
    sw      $a1,            08($sp)                                         # Save
    sw      $t0,            04($sp)                                         # Save
    sw      $t1,            00($sp)                                         # Save
display_body:
    li      $t0,            10
    add     $t1,            $zero,                      $a0
    div     $t1,            $t0
    mfhi    $a0
    li      $a1,            SEVENSEG_RIGHT
    jal     draw
    mflo    $t1
    div     $t1,            $t0
    mfhi    $a0
    li      $a1,            SEVENSEG_LEFT
    jal     draw
display_load:
    lw      $t1,            00($sp)                                         # Load
    lw      $t0,            04($sp)                                         # Load
    lw      $a1,            08($sp)                                         # Load
    lw      $a0,            12($sp)                                         # Load
    lw      $s0,            16($sp)                                         # Load
    lw      $ra,            20($sp)                                         # Load
    add     $sp,            $sp,                        +24                 # Shrink stack
    jr      $ra

# function draw:
# param[in]	$a0 number to display
# param[in]	$a1 SEVENSEG to display
draw:
draw_save:
    add     $sp,            $sp,                        -12                 # Expand stack
    sw      $ra,            08($sp)                                         # Save
    sw      $t0,            04($sp)                                         # Save
    sw      $t1,            00($sp)                                         # Save
draw_body:
    la      $t0,            NUMS
    sll     $t1,            $a0,                        2                   # i * 4
    add     $t0,            $t0,                        $t1                 # Address(NUMS[i])
    lw      $t0,            0($t0)                                          # NUMS[i]
    sb      $t0,            0($a1)                                          # Draw number
draw_load:
    lw      $t1,            00($sp)                                         # Load
    lw      $t0,            04($sp)                                         # Load
    lw      $ra,            08($sp)                                         # Load
    add     $sp,            $sp,                        +12                 # Shrink stack
    jr      $ra
