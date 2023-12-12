# Author: Vu Thanh Trung
# Creation date: 19/07/2022

.data

# ----------------------------------------------------------------------------- #
#		Opcode library							#
#               Rule: each opcode has length of 8 byte, seperated by type and   #
#               syntax                                                          #
# ----------------------------------------------------------------------------- #

# Opcode Library:
opcdLibrary:    .asciiz         "add,1   sub,1   addu,1  subu,1  mul,1   and,1   or,1    nor,1   xor,1   slt,1   addi,2  addiu,2 andi,2  ori,2   sll,2   srl,2   slti,2  sltiu,2 mult,3  div,3   move,3  lw,4    sw,4    lb,4    sb,4    lbu,4   lhu,4   ll,4    sh,4    lui,5   li,5    la,6    mfhi,7  mflo,7  jr,7    beq,8   bne,8   j,9     jal,9   "


buffer:         .space          100
opcode:         .space          10

# Prompts
border:                         .asciiz         "\n# ----------------------------------------------------------------------------- #\n"
start_mes:                      .asciiz         "\n             Opcode Checker\n"
Message:  	                .asciiz 	"Enter string: "
correct_opcode_prompt:          .asciiz         "\nCorrect opcode: "
end_prompt:                     .asciiz         "\nCorrect syntax."
not_valid_register_prompt:      .asciiz         "\nInvalid register syntax."
not_valid_number_prompt:        .asciiz         "\nNot valid number."
not_valid_address_prompt:       .asciiz         "\nNot valid address"
valid_syntax_prompt:            .asciiz         "\nCorrect MIPS syntax."
continue_prompt:                .asciiz         "\nContinue? (1. Yes 0. No): "
missing_prompt:                 .asciiz         "\nThieu toan hang"

# Syntax error prompts:
missing_colon_prompt:   .asciiz         "\nSyntax error: missing colon."
invalid_opcode_prompt:  .asciiz         "\nOpcode is invalid/doesn't exist."
too_many_variable_prompt:.asciiz        "\nSyntax has too many variables."


# Registers library #
tokenRegisters: .asciiz         "$zero   $at     $v0     $v1     $a0     $a1     $a2     $a3     $t0     $t1     $t2     $t3     $t4     $t5     $t6     $t7     $s0     $s1     $s2     $s3     $s4     $s5     $s6     $s7     $t8     $t9     $k0     $k1     $gp     $sp     $fp     $ra     $0      $1      $2      $3      $4      $5      $6      $7      $8      $9      $10     $11     $12     $13     $14     $15     $16     $17     $18     $19     $20     $21     $22     $21     $22     $23     $24     $25     $26     $27     $28     $29     $30     $31     $0      "






.text
main:
        jal     start

read_data:
# ----------------------------------------------------------------------------- #
#		Read data							#
# ----------------------------------------------------------------------------- #
        li	$v0, 8      	                        # take in input
        la 	$a0, buffer  	                        # load byte space into address
        li	$a1, 100      	                        # allot the byte space for string
        syscall
        move 	$s0, $a0  		                # save string to $s0
# ----------------------------------------------------------------------------- #
#		Registers used:                                                	#
#               $s0, $a0: string's address                                      #
# ----------------------------------------------------------------------------- #



clear_whitespace:
# ----------------------------------------------------------------------------- #
#		Clear whitespace before opcode					#
#               Registers used: $t1, $a0, $s0, $ra                              #
#               $s0, $a0: string's address                                      #
# ----------------------------------------------------------------------------- #
        jal     check_whitespace
        


# ----------------------------------------------------------------------------- #
#		Read and store opcode   					#
# ----------------------------------------------------------------------------- #
read_opcode:
        la 	        $a1, opcode	                        # luu cac ki tu doc duoc vao opcode
        la              $s1, opcode                             # luu dia chi opcode vao tep thanh ghi $s1
loop_read_opcode: 
        lb 	        $t1, 0($a0)                             # doc tung ki tu cua opcode
        beq 	        $t1, ' ', check_opcode                  # gap ki tu ' ' -> luu ki tu nay vao opcode de xu ly
        beq 	        $t1, '\n', missing_               # gap ki tu ' ' -> luu ki tu nay vao opcode de xu ly
        sb 	        $t1, 0($a1)                             # luu lai vao opcode address
        addi 	        $a0, $a0, 1                             # chay con tro ve ky tu tiep theo
        addi	        $a1, $a1, 1                             # chay con tro o opcode sang vi tri byte tiep
        j		loop_read_opcode                        # loop cho den khi het
# ----------------------------------------------------------------------------- #
#		Registers used:                                                	#
#               $s0, $a0: string's address                                      #
#               $s1: opcode's address, $a1: at the end of the string            #
# ----------------------------------------------------------------------------- #


check_opcode:
# ----------------------------------------------------------------------------- #
#		Check opcode's validity  					#
# ----------------------------------------------------------------------------- #
        move            $a1, $s1                                # Bring back $a1 to the beginning
        move            $s0, $a0                                # Push pointer s0 to new space

# Check library if there is matching syntax #


        la              $s2, opcdLibrary                    
        jal             check

        j		invalid_opcode			# jump to target



check:
        move            $a2, $s2                        # a2 pointer to beginning of library
loop_check: 
        lb		$t2, 0($a2)		        # load each character from library
        beq             $t2, ',', evaluation1           # if encountered colon, evaluate whether it is correct
        lb		$t1, 0($a1)		        # load each character from opcode
        beq             $t2, 0, jump_                   # if encountered /0 then not found valid opcode
        bne		$t1, $t2, next_opcode	        # character mismatch
        addi            $a1, $a1, 1                     # next character
        addi            $a2, $a2, 1
        j               loop_check


evaluation1:
        lb		$t1, 0($a1)		        # load each character from opcode
        beq             $t1, 0, opcode_done
        j		next_opcode			# jump to $ra
        

next_opcode:
        addi            $s2, $s2, 8                     # Each opcode has length of 8 byte, thus moving to next opcode
        move            $a2, $s2
        move            $a1, $s1
        j               loop_check                      # Keep looping

opcode_done:
# ----------------------------------------------------------------------------- #
#		Registers used:                                                	#
#               $s0, $a0: string's address                                      #
#               $s1: opcode's address, $a1: at the end of the string            #
# ----------------------------------------------------------------------------- #
        
        jal             correct_opcode

        addi            $a2, $a2, 1
        lb		$t2, 0($a2)                     # Load syntax type in $t2

        jal             check_whitespace
        

        addi            $t2, $t2, -48                   # Store type (-48 to change to int)
        
        beq             $t2, 1, Type_1
        beq             $t2, 2, Type_2
        beq             $t2, 3, Type_3
        beq             $t2, 4, Type_4
        beq             $t2, 5, Type_5
        beq             $t2, 6, Type_6
        beq             $t2, 7, Type_7
        beq             $t2, 8, Type_8
        beq             $t2, 9, Type_9


end:
        j		ending				# jump to ending
        


##################################################################################################

##################################################################################################

##################################################################################################



check_whitespace:
# ----------------------------------------------------------------------------- #
#		Read white space before code					#
# ----------------------------------------------------------------------------- #
        move            $a0, $s0                                # Dong bo con tro $a0 voi $s0
        lb 	        $t1, 0($a0)                             # Doc tung ki tu cua command
        beq             $t1, ' ', loop_whitespace               # Loop de tru het dau cach
        beq             $t1, 9, loop_whitespace               # Loop de tru het dau cach
        jr              $ra                                     # Trong truong hop khong phai, quay tro ve chuong trinh chinh
loop_whitespace:
        lb 	        $t1, 0($a0)                             # Doc tung ki tu cua command
        beq 	        $t1, ' ', check_whitespace_pass         # Khi gap dau cach thi tiep tuc doc
        beq             $t1, 9, check_whitespace_pass               # Loop de tru het dau cach
        # addi            $a0, $a0, 1                             # Dich $a0 di 1 ky tu
        move 	        $s0, $a0		                # Cho dia chi moi cho s0 la ky tu dau tien cua word
        jr		$ra				        # jump to $ra
check_whitespace_pass:
        addi            $a0, $a0, 1                             # Dich $a0 di 1 ky tu
        j		loop_whitespace			        # jump to check_whitespace
# ----------------------------------------------------------------------------- #
#		Registers used: $t1, $a0, $s0, $ra				#
#               Pointer will point at next character                            #
# ----------------------------------------------------------------------------- #



check_colon:
# ----------------------------------------------------------------------------- #
#		Read colon					                #
# ----------------------------------------------------------------------------- #
        move            $a0, $s0                                # Dong bo con tro $a0 voi $s0
        lb 	        $t1, 0($a0)                             # Doc tung ki tu cua command 
        bne 	        $t1, ',', missing_colon                  # Khi gap dau cach thi tiep tuc doc
        jr		$ra				        # jump to $ra
# ----------------------------------------------------------------------------- #
#		Registers used: $t1, $a0, $s0, $ra				#
#               Pointer will be at the colon                                     #
# ----------------------------------------------------------------------------- #



check_gap:
# ----------------------------------------------------------------------------- #
#		Check gap between code  					#
# ----------------------------------------------------------------------------- #
        move      $t4, $ra
        jal     check_whitespace
        jal	check_colon
        addi    $a0, $a0, 1                                     # Point to character/whitespace after colon
        move    $s0, $a0
        jal     check_whitespace
        move    $ra, $t4
        jr      $ra
# ----------------------------------------------------------------------------- #
#		Registers used: $t1, $a0, $s0, $ra				#
# ----------------------------------------------------------------------------- #



jump_:
        jr      $ra

OPCODE_TYPES:
Type_1:
# ----------------------------------------------------------------------------- #
#       Format xyz      $1, $2, $3                                                   #
# ----------------------------------------------------------------------------- #
# Ari1Library_:         .asciiz         "add,    sub,    addu,   subu,   mul;    " # Format add $1, $2, $3
# Log1Library_:         .asciiz         "and,    or,     nor,    xor;    " # Format and and $1, $2, $3 // 
# Com1Library_:         .asciiz         "slt;    " # Format slt $1,$2,$3
        # move	$a0, $s0               # Load and print string asking for string
        # li 	$v0, 4
        # syscall
        jal     reg_check
        jal     check_gap
        jal     reg_check
        jal     check_gap
        jal     reg_check
        jal     check_end

Type_2:
# ----------------------------------------------------------------------------- #
#       Format xyz $1, $2, 10000                                                #
# ----------------------------------------------------------------------------- #
# Ari2Library_:         .asciiz         "addi,   addiu;  " # Format addi $1,$2,100
# Log2Library_:         .asciiz         "andi,   ori,    sll,    srl;    " # Format or andi $1,$2,
# Com2Library:    .asciiz         "slti,   sltiu;  " # Format slti $1, $2, 100
        jal     reg_check
        jal     check_gap
        jal     reg_check
        jal     check_gap
        jal     num_check
        jal     check_end

Type_3:
# ----------------------------------------------------------------------------- #
#       Format mult $2,$3                                                       #
# ----------------------------------------------------------------------------- #
# Ari3Library:    .asciiz         "mult,   div;    " # Format mult $2,$3 //
# Dat5Library:    .asciiz         "move;   " # Format move $1, $2
        jal     reg_check
        jal     check_gap
        jal     reg_check
        jal     check_end

Type_4:
# ----------------------------------------------------------------------------- #
#       Format lw $1, 100($2)                                                   #
# ----------------------------------------------------------------------------- #
# Dat1Library:    .asciiz         "lw,     sw,     lb,     sb,     lbu,    lhu,    ll,     sh;     " # Format lw $1, 100($2) //
        jal     reg_check
        jal     check_gap
        jal     address_check
        jal     check_end

Type_5:
# ----------------------------------------------------------------------------- #
#       Format lui $1, 100                                                      #
# ----------------------------------------------------------------------------- #
# Dat2Library:    .asciiz         "lui,    li;     " # Format lui $1, 100 //
        jal     reg_check
        jal     check_gap
        jal     num_check
        jal     check_end

Type_6:
# ----------------------------------------------------------------------------- #
#       Format la $1,label                                                      #
# ----------------------------------------------------------------------------- #
# Dat3Library:    .asciiz         "la;     " # Format la $1,label //
        jal     reg_check
        jal     check_gap
        jal     label_check
        jal     check_end

Type_7:
# ----------------------------------------------------------------------------- #
#       Format mfhi $2                                                          #
# ----------------------------------------------------------------------------- #
# Dat4Library:    .asciiz         "mfhi,   mflo;   " # Format mfhi $2
# Jum2Library:    .asciiz         "jr;     " # Format jr $1
        jal     reg_check
        jal     check_end

Type_8:
# ----------------------------------------------------------------------------- #
#       Format beq $1, $2, label beq $1,$2,100                                  #
# ----------------------------------------------------------------------------- #
# Con1Library:    .asciiz         "beq,    bne;    " # Format beq $1,$2,100 ; beq $1, $2, label
        jal     reg_check
        jal     check_gap
        jal     reg_check
        jal     check_gap
        jal     label_check
        beq     $s7, 1, check_end
        jal     num_check

end_type8:
        jal     check_end

Type_9:
# ----------------------------------------------------------------------------- #
#       Format j 1000 ; j label                                                 #
# ----------------------------------------------------------------------------- #
# Jum1Library:    .asciiz         "j,      jal;    " # Format j 1000 ; j label
        jal     label_check
        beq     $s7, 1, check_end
        jal     num_check

end_type9:
        jal     check_end


check_syntax:
        check_end:
        # ----------------------------------------------------------------------------- #
        #		Check whether string has ended or not (space excluded)		#
        # ----------------------------------------------------------------------------- #
                jal     check_whitespace
                lb      $t5, 0($s0)
                beq	$t5, '\n', valid_syntax	#
                beq	$t5, '\0', valid_syntax	# 
                beq     $t5,  '#', valid_syntax
                j       too_many_variable

        reg_check:
        # ----------------------------------------------------------------------------- #
        #		Check whether string is register or not  			#
        # ----------------------------------------------------------------------------- #
                la      $s3, tokenRegisters
                move    $a3, $s3                        # a3 points to beginning of register library
                move    $a0, $s0

                loop_reg_check:
                        lb		$t3, 0($a3)		        # load each character from library
                        lb		$t0, 0($a0)		        # load each character from string
                        beq             $t3, ' ', evaluation2           # if encountered space, evaluate whether it is correct
                        beq             $t3, 0, not_valid_register      # if encountered /0 then not valid register
                        bne		$t0, $t3, next_reg	        # character mismatch
                        addi            $a0, $a0, 1                     # next character
                        addi            $a3, $a3, 1
                        j               loop_reg_check
                evaluation2:
                        lb              $t0, 0($a0)
                        beq             $t0, ',', found_reg                 # Correct register
                        beq             $t0, ' ', found_reg                 # Correct register
                        beq             $t0, 0, found_reg                   # Correct register
                        beq             $t0, '\n', found_reg                   # Correct register
                        j		next_reg			# jump to next_register
                next_reg:
                        addi            $s3, $s3, 8                     # Move to next register token
                        move            $a3, $s3
                        move            $a0, $s0
                        j		loop_reg_check			# jump to loop_reg_check
                found_reg:
                        move            $s0, $a0                        # move pointer forward
                        j		jump_				# jump to jump_
                        
        # ----------------------------------------------------------------------------- #
        #		Registers used:                                                	#
        #               $s0, $a0: string's address (checking register)                  #
        #               $s3, $a3: register's library pointers                           #
        # ----------------------------------------------------------------------------- #

        num_check:
        # ----------------------------------------------------------------------------- #
        #		Check whether string is register or not  			#
        # ----------------------------------------------------------------------------- #
                move            $a0, $s0
                num_check_loop:
                        lb              $t0, 0($a0)
                        beq             $t0, ',', is_num                 # Correct register
                        beq             $t0, ' ', is_num                 # Correct register
                        beq             $t0, 0, is_num                   # Correct register
                        beq             $t0, '\n', is_num               # Correct register
                        bgt		$t0, '9', not_num	        # if $t0 > 9 then target
                        blt		$t0, '0', not_num	        # if $t0 < 0 then target
                        addi            $a0, $a0, 1
                        j		num_check_loop			# jump to num_check_loop
                is_num:
                        move            $s0, $a0
                        j               jump_				# jump to jump_
                not_num:
                        j		not_num_error				# jump to not_num_error
                        
        address_check:
                adnum_check:      
                    
                        num_check_loop2:
                                lb              $t0, 0($a0)
                                beq             $t0, '(', is_num2                # Correct registe
                                bgt		$t0, '9', not_num2	        # if $t0 > 9 then target
                                blt		$t0, '0', not_num2	        # if $t0 < 0 then target
                                addi            $a0, $a0, 1
                                j		num_check_loop2			# jump to num_check_loop
                        is_num2:
                                move            $s0, $a0
                                j               adreg_check				# jump to jump_
                        not_num2:
                        	
                                j		not_valid_address				# jump to not_num_error
                adreg_check:
                        reg_check2:
                        addi	$a0, $a0, 1
                        move	$s0, $a0
        # ----------------------------------------------------------------------------- #
        #		Check whether string is register or not  			#
        # ----------------------------------------------------------------------------- #
                la      $s3, tokenRegisters
                move    $a3, $s3                        # a3 points to beginning of register library
                move    $a0, $s0

                loop_reg_check2:
                        lb		$t3, 0($a3)		        # load each character from library
                        lb		$t0, 0($a0)		        # load each character from string
                        beq             $t3, ' ', evaluation3           # if encountered space, evaluate whether it is correct
                        beq             $t3, 0, not_valid_address2      # if encountered /0 then not valid register
                        bne		$t0, $t3, next_reg2	        # character mismatch
                        addi            $a0, $a0, 1                     # next character
                        addi            $a3, $a3, 1
                        j               loop_reg_check2
                evaluation3:
                        lb              $t0, 0($a0)
                        beq             $t0, ')', found_reg2                 # Correct register
                        j		next_reg2			# jump to next_register
                next_reg2:
                        addi            $s3, $s3, 8                     # Move to next register token
                        move            $a3, $s3
                        move            $a0, $s0
                        j		loop_reg_check2			# jump to loop_reg_check
                not_valid_address2:
                	move	$a0, $t0
                	 li 	$v0, 11
                         syscall
                         j not_valid_address
                found_reg2:
                        addi            $a0, $a0, 1
                        move            $s0, $a0                        # move pointer forward
                        jr		$ra
                        
        # ----------------------------------------------------------------------------- #
        #		Registers used:                                                	#
        #               $s0, $a0: string's address (checking register)                  #
        #               $s3, $a3: register's library pointers                           #
        # ----------------------------------------------------------------------------- #

        label_check:
                move    $a0, $s0

        First_char_check: # Can't be number and can't be underscore:
                        lb 	$t0, ($a0)    		#Load byte from 't0'th position in buffer into $t1
                        blt 	$t0, 'a', not_lower  	#If less than a, exit
                        bgt 	$t0, 'z', not_lower 	#If greater than z, exit
           
                        j		loop_label_check		# It's lower so we jump to 2nd character
                
                not_lower:
                        blt 	$t0, 'A', fail_case  	#If less than A, means not alphabet, failcase
	                bgt 	$t0, 'Z', fail_case	#If greater than Z, means not alphabet, failcase
                        
        loop_label_check: # Can be alphabet, number and underscore

                addi    $a0, $a0, 1                     # Increment
                lb 	$t0, ($a0)    		        #Load byte from 't0'th position in buffer into $t0
                
                beq     $t0, ' ', valid_label           #Correct case
                beq     $t0, '\n', valid_label          #Correct case
                beq 	$t0, 0, valid_label      	#If ends, exit
                        
                        
                        blt 	$t0, 'a', not_lower2  	#If less than a, exit
                        bgt 	$t0, 'z', not_lower2	#If greater than z, exit
                        j	loop_label_check	# if a<= t0 <= z then lowercase character, loop
                        
                not_lower2:
                        bne     $t0, '_', not_underscore        # Self explanatory
                        j	loop_label_check	# if A<= t0 <=Z then uppercase character, loop

                not_underscore:
                        blt 	$t0, 'A', not_upper2  	#If less than A, means not alphabet
	                bgt 	$t0, 'Z', not_upper2	#If greater than Z, means not alphabet
	                j	loop_label_check	# if A<= t0 <=Z then uppercase character, loop

                not_upper2:
                        blt 	$t0, '0', fail_case  	#If less than 0, means not number either, failcase
	                bgt 	$t0, '9', fail_case	#If greater than 9, means not not number either, failcase
	                j	loop_label_check	# if A<= t0 <=Z then uppercase character, loop

                fail_case:
                        move    $a0, $s0                # Reset to before so we check other case (not using label as address but numerical)
                        li      $s7, 0                  # Case checker so we know to check numerical adderess
                        jr	$ra				# jump to jump_
                        
                valid_label:
                        move    $s0, $a0                # Move pointer forward
                        li      $s7, 1                  # Case checker = 1 (valid)
                        jr      $ra
                        
                        
prompts:
        start:
                
                la      $a0, border
                li      $v0, 4
                syscall
                la      $a0, start_mes
                li      $v0, 4
                syscall
                la      $a0, border
                li      $v0, 4
                syscall
                la	$a0, Message    	                # Load and print string asking for string
                li 	$v0, 4
                syscall
                jr      $ra

        correct_opcode:
                la      $a0, correct_opcode_prompt
                li      $v0, 4
                syscall
                la      $a0, opcode
                li      $v0, 4
                syscall
                move    $a0, $s0                #  Return $a0
                jr		$ra		

# ----------------------------------------------------------------------------- #
#		Registers used:                                                	#
#               $a0: prompt address                                             #
# ----------------------------------------------------------------------------- #
                


error:
        missing_colon:
                la	$a0, missing_colon_prompt               # Load and print string asking for string
                li 	$v0, 4
                syscall
                j	ending				        # jump to ending
                
        invalid_opcode:
                la      $a0, invalid_opcode_prompt
                li      $v0, 4
                syscall
                j	ending				        # jump to ending
        too_many_variable:
                 move	$a0, $s0               # Load and print string asking for string
                 li 	$v0, 1
                 syscall
              #  j	ending				        # jump to ending
                la      $a0, too_many_variable_prompt 
                li      $v0, 4
                syscall
                j       ending
        not_valid_register:
                la      $a0, not_valid_register_prompt 
                li      $v0, 4
                syscall
                j       ending
        not_num_error:
                la      $a0, not_valid_number_prompt 
                li      $v0, 4
                syscall
                j       ending
        not_valid_address:
                la      $a0, not_valid_address_prompt 
                li      $v0, 4
                syscall
                j       ending
        missing_:
                la      $a0, missing_prompt
                li      $v0, 4
                syscall
                j       ending
valid_syntax:
        la      $a0, valid_syntax_prompt
        li      $v0, 4
        syscall

ending:
        la      $a0, continue_prompt
        li      $v0, 4
        syscall 

        li      $v0, 5
        syscall 

        beq     $v0, 1, resetAll

        li      $v0, 10
        syscall


resetAll:
        
	li $v0, 0 
	li $v1, 0
	jal		clean_block				# jump to clean_block
        jal		clean_opcode				# jump to clean_block
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
        
	j main

clean_block:
        li $a0, 0 
        li $a1, 0
        la      $s0, buffer
loop_block:
        beq		$a1, 100, jump_
        sb              $a0, 0($s0)
        addi            $s0, $s0, 1
        addi            $a1, $a1, 1
        j               loop_block

clean_opcode:
        li $a0, 0 
        li $a1, 0
        la      $s1, opcode
loop_opcode:
        beq		$a1, 10, jump_
        sb              $a0, 0($s1)
        addi            $s1, $s1, 1
        addi            $a1, $a1, 1
        j               loop_opcode
