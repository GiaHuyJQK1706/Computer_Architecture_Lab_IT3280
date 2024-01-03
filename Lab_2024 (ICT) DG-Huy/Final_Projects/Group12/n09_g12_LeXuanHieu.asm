#+++++++++++Assembly Language and Computer Architecture Lab+++++++++++
# 			Le Xuan Hieu - 20215201   		        #
# Student of ICT, SOICT, Hanoi University of Science and Technology  #
#  Task 9: Drawing shape using ASCII characters                      #
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.data

	line1:  .asciiz "                                            ************* \n"
	line2:  .asciiz "**************                             *3333333333333*\n"
	line3:  .asciiz "*222222222222222*                          *33333******** \n"
	line4:  .asciiz "*22222******222222*                        *33333*        \n"
	line5:  .asciiz "*22222*      *22222*                       *33333******** \n"
	line6:  .asciiz "*22222*        *22222*     *************   *3333333333333*\n"
	line7:  .asciiz "*22222*        *22222*   **11111*****111*  *33333******** \n"
	line8:  .asciiz "*22222*        *22222*  **1111**      **   *33333*        \n"
	line9:  .asciiz "*22222*       *222222*  *1111*             *33333******** \n"
	line10: .asciiz "*22222*******222222*   *11111*             *3333333333333*\n"
	line11: .asciiz "*2222222222222222*     *11111*              ************* \n"
	line12: .asciiz "***************        *11111*                            \n"
	line13: .asciiz "      ---               *1111**                           \n"
	line14: .asciiz "    / o o \\              *1111****   *****                \n"
	line15: .asciiz "    \\   > /               **111111***111*                 \n"
	line16: .asciiz "     -----                  ***********    dce.hust.edu.vn\n" #60 chars per row
	#22 42 58              
	Message0: 		.asciiz "------------Menu----------\n"
	Message1:		.asciiz"1. Print with color\n"
	Message2:		.asciiz"2. Print without color\n"
	Message3:		.asciiz"3. Change order\n"
	Message4:		.asciiz"4. Change color\n"
	Message5:		.asciiz"5. Exit\n"
	Message6:		.asciiz"Enter choice: "
	Message4.1:		.asciiz"Enter color for D(0->9): "
	Message4.2:		.asciiz"Enter color for C(0->9): "
	Message4.3:		.asciiz"Enter color for E(0->9): "
.text
main:
init:
	li $s0, '2' #s0: curr D color
	li $s1, '1' #s1: curr C color
	li $s2, '3' #s2: curr E color
menu:
	la $a0, Message0	# nhap menu
	li $v0, 4
	syscall
	
	la $a0, Message1	
	li $v0, 4
	syscall
	la $a0, Message2	
	li $v0, 4
	syscall
	la $a0, Message3	
	li $v0, 4
	syscall
	la $a0, Message4	
	li $v0, 4
	syscall
	la $a0, Message5
	li $v0, 4
	syscall
	la $a0, Message6	
	li $v0, 4
	syscall
	
	li $v0, 5   #v0: choice
	syscall
	
	li $t0, 1
	li $t1, 2
	li $t2, 3
	li $t3, 4
	li $t4, 5
	beq $v0, $t0, menu1
	beq $v0, $t1, menu2
	beq $v0, $t2, menu3
	beq $v0, $t3, menu4
	beq $v0, $t4, end_main
	j main
#---------------------------------------------------------	
menu1:	
	li $t0, 0 #i=0
	li $t1, 16 #max	=16
	
	la $a0,line1
loop1:		
	beq $t0, $t1, menu #already visited all rows
	li $v0, 4
	syscall
		
	addi $a0, $a0, 60 #move to next row
	addi $t0, $t0, 1
	j loop1
#---------------------------------------------------------		
menu2:
	li $t0, 0 #i=0
	li $t1, 16 #max	=16
	
	la $t2,line1 #t2: pointer to character, starting at first character of line1
outer_loop2:
	beq $t0, $t1, menu #i=16 -> main
	li $t3, 0 #j=0
	li $t4, 60 #max=60
inner_loop2:
	beq $t3, $t4, continue_outer_loop2 #j=60 -> continue_outer_loop2
	lb $t5, 0($t2) #t5: cur char
	blt $t5, '0', print_char2
	bgt $t5, '9', print_char2
	li $t5, ' ' #if char is digit, replace it with blank space
print_char2:
	li $v0, 11
	move $a0, $t5
	syscall
continue_inner_loop2:	
	addi $t2, $t2, 1 #move to next char
	addi $t3, $t3, 1 #j=j+1
	j inner_loop2
continue_outer_loop2:
	addi $t0, $t0, 1  #i=i+1
	j outer_loop2
#---------------------------------------------------------		  
menu3:
	li $t0, 0 #i=0
	li $t1, 16 #max	=16
	
	la $t2,line1 #t2: pointer to base address of each row
loop3:
	beq $t0, $t1, menu
	sb $0, 22($t2) #make char 22th as a null seperator
	sb $0, 42($t2) #make char 42th as a null seperator
	sb $0, 58($t2) #make char 58th as a null seperator
	
	li $v0, 4
	addi $a0, $t2, 43
	syscall #print E
	
	li $v0, 11 
	li $a0, ' '
	syscall #print space
	
	li $v0, 4
	addi $a0, $t2, 23
	syscall #print C
	
	li $v0, 11 
	li $a0, ' '
	syscall #print space
	
	li $v0, 4
	add $a0, $t2, $0
	syscall #print D
	
	li $v0, 11
	li $a0, '\n' 
	syscall #print '\n'
	
	#restore
	li $t3, ' '
	sb $t3, 22($t2) 
	sb $t3, 42($t2)
	li $t3, '\n' 
	sb $t3, 58($t2) 
	
	addi $t0, $t0, 1
	addi $t2, $t2, 60 #move to new row
	j loop3
#---------------------------------------------------------		
menu4:
enter_D:
	li $v0, 4
	la $a0, Message4.1
	syscall
	
	li $v0, 5
	syscall
	
	bgt $v0, 9, enter_D
	blt $v0, 0, enter_D
	
	addi $s3, $v0, '0'  #s3: new D color
enter_C:
	li $v0, 4
	la $a0, Message4.2
	syscall
	
	li $v0, 5
	syscall
	
	bgt $v0, 9, enter_C
	blt $v0, 0, enter_C
	
	addi $s4, $v0, '0'  #s4: new C color
enter_E:
	li $v0, 4
	la $a0, Message4.3
	syscall
	
	li $v0, 5
	syscall
	
	bgt $v0, 9, enter_E
	blt $v0, 0, enter_E
	
	addi $s5, $v0, '0'  #s5: new E color
init_menu4:
	li $t0, 0 #i=0
	li $t1, 16 #max	=16
	
	la $t2,line1 #t2: pointer to character, starting at first character of line1
outer_loop4:
	beq $t0, $t1, update_color #i=16 -> menu
	li $t3, 0 #j=0
	li $t4, 60 #max=60
inner_loop4:
	beq $t3, $t4, continue_outer_loop4 #j=60 -> continue_outer_loop2
	lb $t5, 0($t2) #t5: cur char
	blt $t3, 22, check_D  #char 0th -> 21th belong to D
	blt $t3, 42, check_C  #char 22th -> 41th belong to C
	j check_E #remaining belong to E
check_D:
	beq $t5, $s0, update_D  #if char is color, update it
	j print_char4
check_C:
	beq $t5, $s1, update_C #if char is color, update it
	j print_char4
check_E:
	beq $t5, $s2, update_E #if char is color, update it
	j print_char4
update_D:
	sb $s3, 0($t2)  #store new color into memory
	move $t5, $s3  
	j print_char4
update_C:
	sb $s4, 0($t2) #store new color into memory
	move $t5, $s4
	j print_char4
update_E:
	sb $s5, 0($t2) #store new color into memory
	move $t5, $s5
	j print_char4
print_char4:
	li $v0, 11
	move $a0, $t5
	syscall
continue_inner_loop4:	
	addi $t2, $t2, 1 #move to next char
	addi $t3, $t3, 1 #j=j+1
	j inner_loop4
continue_outer_loop4:
	addi $t0, $t0, 1#i=i+1
	j outer_loop4
update_color:
	move $s0, $s3
	move $s1, $s4
	move $s2, $s5
	j menu	
end_main:
	li $v0, 10
	syscall
