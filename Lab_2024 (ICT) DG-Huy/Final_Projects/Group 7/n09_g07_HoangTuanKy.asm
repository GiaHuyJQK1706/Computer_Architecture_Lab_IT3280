.data
line1: .asciiz  "                                              *************       \n"
line2: .asciiz  " **************                              *3333333333333*      \n"
line3: .asciiz  " *222222222222222*                           *33333********       \n"
line4: .asciiz  " *22222******222222*                         *33333*              \n"
line5: .asciiz  " *22222*      *22222*                        *33333********       \n"
line6: .asciiz  " *22222*       *22222*        *************  *3333333333333*      \n"
line7: .asciiz  " *22222*       *22222*      **11111*****111* *33333********       \n"
line8: .asciiz  " *22222*       *22222*    **1111**       **  *33333*              \n"
line9: .asciiz  " *22222*      *222222*    *1111*             *33333********       \n"
line10: .asciiz " *22222*******222222*    *11111*             *3333333333333*      \n"
line11: .asciiz " *2222222222222222*      *11111*              *************       \n"
line12: .asciiz " ***************         *11111*                                  \n"
line13: .asciiz "      ---                 *1111**                                 \n"
line14: .asciiz "    / o o \\                *1111****   *****                      \n"
line15: .asciiz "    \\   > /                 **111111***111*                       \n"
line16: .asciiz "     -----                    ***********      dce.hust.edu.vn    \n"

menu_message: .asciiz "\n\n ----MENU----\n 1. Show picture.\n 2. Show picture with only border.\n 3. Change the order.\n 4. Enter new color number and update.\n 5. Exit.\n Enter your choice: "
error_message: "Input must be a integer from 1 to 5"

input_d_color: .asciiz "Enter color for D (integer from 0-9):"
input_c_color: .asciiz "Enter color for C (integer from 0-9):"
input_e_color: .asciiz "Enter color for E (integer from 0-9):"



.text
menu:
 li $v0,4
 la $a0,menu_message
 syscall

 li $v0,5
 syscall
 
 beq $v0,1,menu_func1
 beq $v0,2,menu_func2
 beq $v0,3,menu_func3
 beq $v0,4,menu_func4
 beq $v0,5,exit
 
 li $v0,4
 la $a0,error_message
 syscall
 j menu
exit:
 li $v0,10
 syscall
#Function1 
menu_func1:
 jal print
 j menu
#Function2
menu_func2:
 li $t0,16
 li $t1,68
 li $t2,0
 li $t3,0
 la $s0,line1
loop_row:
 beq $t3,$t0,end_loop_row
 li $t2,0
loop_column:
 beq $t2,$t1,end_loop_column
 lb $a1,0($s0)
 addi $s0,$s0,1
 bgt $a1,57,print_char
 blt $a1,48,print_char
 li $a1,32
print_char:
 li $v0, 11  	
 move $a0,$a1
 syscall
 addi $t2,$t2,1
 j loop_column
end_loop_column:
 addi $t3,$t3,1
 j loop_row
end_loop_row:
 j menu
#Function3
menu_func3:
 li $t9,0
func3:
 li $t0,12
 li $t1,22
 li $t2,1
 li $t3,1
 la $a0,line1
 add $a0,$a0,68
change_order_row_loop:
 beq $t2,$t0,end_change_order_row_loop
 li $t3,1
change_order_column_loop:
 beq $t3,$t1,end_change_order_column_loop
 add $a1,$a0,$t3 
 lb $s1,0($a1) #char in d 
 sub $a2,$a1,24
 lb $s2,0($a2) #char in e
 add $a3,$a1,294
 lb $s3,0($a3) #char in c
 sb $s2,0($a1)
 sb $s1,0($a2)
 addi $t3,$t3,1
 j change_order_column_loop
end_change_order_column_loop:
 addi $a0,$a0,68
 addi $t2,$t2,1
 j change_order_row_loop
end_change_order_row_loop:
 bne $t9,0,end_func3
 jal print
 li $t9,1
 j func3
end_func3:
 j menu
#Function 4
menu_func4:
input_d_co:
 li $v0,4
 la $a0,input_d_color
 syscall
 li $v0,5
 syscall
 bgt $v0,9,input_d_co
 blt $v0,0,input_d_co
 addi $t4,$v0,48 # d color
input_c_co:
 li $v0,4
 la $a0,input_c_color
 syscall
 li $v0,5
 syscall
 bgt $v0,9,input_c_co
 blt $v0,0,input_c_co
 addi $t5,$v0,48
input_e_co:
 li $v0,4
 la $a0,input_e_color
 syscall
 li $v0,5
 syscall
 bgt $v0,9,input_e_co
 blt $v0,0,input_e_co
 addi $t6,$v0,48
change_color:
 li $t0,12
 li $t1,22
 li $t2,1
 li $t3,1
 la $a0,line1
 addi $a0,$a0,68
change_color_row_loop:
 beq $t2,$t0,end_change_color_row_loop
 li $t3,1
change_color_column_loop:
 beq $t3,$t1,end_change_color_column_loop
 add $a1,$a0,$t3 
 lb $s1,0($a1) #char in d
 move $t8,$t4
 jal modifycolor
 sb $s1,0($a1)
  
 sub $a2,$a1,24
 lb $s1,0($a2) #char in e
 move $t8,$t6
 jal modifycolor
 sb $s1,0($a2)
 
 add $a3,$a1,294
 lb $s1,0($a3) #char in c
 move $t8,$t5
 jal modifycolor
 sb $s1,0($a3)
 
 addi $t3,$t3,1
 j change_color_column_loop
end_change_color_column_loop:
 addi $a0,$a0,68
 addi $t2,$t2,1
 j change_color_row_loop
end_change_color_row_loop:
 jal print
 j menu
 
modifycolor:
 bgt $s1,57,end_modify
 blt $s1,48,end_modify
 move $s1,$t8
end_modify:
 jr $ra

print:
 li $t0,16
 li $t1,0
 la $a0,line1
print_loop:
 beq $t1,$t0,end_print_loop
 li $v0,4
 syscall
 addi $a0,$a0,68
 addi $t1,$t1,1
 j print_loop
end_print_loop:
 jr $ra

 
 
