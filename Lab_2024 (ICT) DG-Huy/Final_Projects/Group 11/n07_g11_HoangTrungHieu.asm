# Hoang Trung Hieu 20226039 
# Subject 7: check MIPS instruction syntax 

.data
# ----------------------------------------------------------------------------- # 
# Opcode library							        # 
# Rule: each opcode has length of 8 byte, seperated by type and syntax          # 
# ----------------------------------------------------------------------------- # 

# Opcode Library:
opcodeLibrary:    .asciiz "add,1   sub,1   addu,1  subu,1  mul,1   and,1   or,1    nor,1   xor,1   slt,1   addi,2  addiu,2 andi,2  ori,2   sll,2   srl,2   slti,2  sltiu,2 mult,3  div,3   move,3  lw,4    sw,4    lb,4    sb,4    lbu,4   lhu,4   ll,4    sh,4    lui,5   li,5    la,6    mfhi,7  mflo,7  jr,7    beq,8   bne,8   j,9     jal,9   "


buffer:         .space          100
opcode:         .space          10

# Mess
Message:  	                .asciiz 	"Enter string: "
correct_opcode_prompt:          .asciiz         "\nCorrect opcode: "
end_prompt:                     .asciiz         "\nCorrect syntax."
not_valid_register_prompt:      .asciiz         "\nInvalid register syntax."
not_valid_number_prompt:        .asciiz         "\nNot valid number."
not_valid_address_prompt:       .asciiz         "\nNot valid address"
valid_syntax_prompt:            .asciiz         "\nCorrect MIPS syntax."
continue_prompt:                .asciiz         "\nContinue? (1. Yes 0. No): "
missing_prompt:                 .asciiz         "\nMissing operand"

# Syntax error mess:
missing_comma_prompt: .asciiz "\nSyntax error: missing colon."
invalid_opcode_prompt: .asciiz "\nOpcode is invalid or doesn't exist."
too_many_variable_prompt: .asciiz "\nSyntax has too many variables."


# Registers library #
# each register has 8 bytes in registLibrary
registerLibrary: .asciiz "$zero   $at     $v0     $v1     $a0     $a1     $a2     $a3     $t0     $t1     $t2     $t3     $t4     $t5     $t6     $t7     $s0     $s1     $s2     $s3     $s4     $s5     $s6     $s7     $t8     $t9     $k0     $k1     $gp     $sp     $fp     $ra     $0      $1      $2      $3      $4      $5      $6      $7      $8      $9      $10     $11     $12     $13     $14     $15     $16     $17     $18     $19     $20     $21     $22     $21     $22     $23     $24     $25     $26     $27     $28     $29     $30     $31     $0      "

# $s0 is the address of input string
# $a0 is used for traversing input string
# $s1 is the address of opcode
# $a1 is used for traversing opcode
# $s2 is the address of opcodeLibrary
# $a2 is used for traversing opcodeLibrary
# $s3 is the address of registerLibrary
# $a3 is used for traversing registerLibrary


.text
main:
        la $a0, Message    	                		# print Message
        li $v0, 4
        syscall

read_data:
        li $v0, 8      	                        
        la $a0, buffer  	                        
        li $a1, 100      	                        
        syscall
        move $s0, $a0  		                		# store address of input string into $s0

        jal clear_whitespace					# jump to clear_whitespace function
        
read_opcode:
        la $a1, opcode	                        		# $a1 is used for incrementing opcode character position
        la $s1, opcode                            		# $s1 = address of opcode
loop_read_opcode: 
        lb $t1, 0($a0)                             		# $t1 = current character in opcode
        beq $t1, ' ', check_opcode                  		# if a whitespace is found then check 
        beq $t1, '\n', missing_               			# if a newline character is found then the string is missing operands
        sb $t1, 0($a1)                             		# store current character into opcode
        addi $a0, $a0, 1                             		# continue checking next character
        addi $a1, $a1, 1                            		# increment current address of opcode
        j loop_read_opcode                        
        

# ----------------------------------------------------------------------------- #
check_opcode:
        move $a1, $s1                                		# $a1 = $s1 = address of opcode
        move $s0, $a0                                		# $s0 points to the character after opcode 

        la $s2, opcodeLibrary                    		# $s2 = address of opcodeLibrary
        jal check

        j invalid_opcode					# jump to target
# ----------------------------------------------------------------------------- #




# ----------------------------------------------------------------------------- #
check:
        move $a2, $s2                        			# a2 pointer to beginning of library
loop_check: 
        lb $t2, 0($a2)	 	        			# load each character from library
        beq $t2, ',', evaluation1           			# if encountered colon, evaluate whether it is correct
        lb $t1, 0($a1)	 	        			# load each character from  input opcode
        beq $t2, 0, jump_                   			# if current character in the opcodeLibrary is \0 then we have checked all possible opcodes in the Library -> no valid input opcode
        bne $t1, $t2, next_opcode	        		# character mismatch
        addi $a1, $a1, 1                     			# next character
        addi $a2, $a2, 1
        j loop_check


evaluation1:
        lb $t1, 0($a1)		       	 			# load current character of opcode 
        beq $t1, 0, opcode_done					# if current character of opcode is null then it has matched an opcode in opcodeLibrary
        j next_opcode						# else continue checking opcode in opcodeLibrary
        
next_opcode:
        addi $s2, $s2, 8                     			# increment $s2 by 8 because each opcode has 8 bytes in opcodeLibrary
        move $a2, $s2						# update $a2
        move $a1, $s1						# reset running index of opcode
        j loop_check                      			# continue looping to check for next opcode
# ----------------------------------------------------------------------------- #



# ----------------------------------------------------------------------------- #
opcode_done:        
        jal             correct_opcode				# print correct opcode

        addi            $a2, $a2, 1
        lb		$t2, 0($a2)                     	# Load syntax type in $t2

        jal             clear_whitespace			# point $s0 to next valid character after opcode
        

        addi            $t2, $t2, -48                   	# Minus value of $t2 by 48 to get the interger value
        
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
        j		ending					# jump to ending
# ----------------------------------------------------------------------------- #


        
        
        


# clear whitespace until the first valid character
# ----------------------------------------------------------------------------- #
clear_whitespace:
        move            $a0, $s0                                # load $a0 as the address of input string
        lb 	        $t1, 0($a0)                             # read first character
        beq             $t1, ' ', loop_whitespace               # if first character is a whitespace then delete
        beq             $t1, 9, loop_whitespace               	# if first character is a tab then delete
        jr              $ra                                     # in this case first character is neither a whitespace or a tab so we jump back
loop_whitespace:
        lb 	        $t1, 0($a0)                             # read current character
        beq 	        $t1, ' ', whitespace_found         	# if this character is a whitespace then increment address of input string by 1
        beq             $t1, 9, whitespace_found           	# if this character is a tab then increment address of input string by 1
        move 	        $s0, $a0		                # there is no more invalid character here so update the address
        jr		$ra				        # then jump back
whitespace_found:
        addi            $a0, $a0, 1                             # increment address of input string by 1 to delete invalid character
        j		loop_whitespace			        # continue looping
# ----------------------------------------------------------------------------- #





# check if current character is a comma 
# ----------------------------------------------------------------------------- #
check_comma:

        move            $a0, $s0                                # update $a0 = $s0
        lb 	        $t1, 0($a0)                             # get the current character
        bne 	        $t1, ',', missing_comma                 # if current character is != comma then invalid syntax
        jr		$ra				        
# ----------------------------------------------------------------------------- #



# clear gap in instruction and check for comma
# ----------------------------------------------------------------------------- #
check_gap:

        addi $sp, $sp, 4
        sw $ra, 0($sp)						# store $ra
        
        jal clear_whitespace
        jal check_comma
        addi $a0, $a0, 1                                     	# Point to character/whitespace after colon
        move $s0, $a0
        jal clear_whitespace
        
        lw $ra, 0($sp)
        addi $sp, $sp, -4					# restore $ra
        
        jr $ra
# ----------------------------------------------------------------------------- #




jump_:
        jr      $ra


# All types of instructions
# ----------------------------------------------------------------------------- #
OPCODE_TYPES:
Type_1:
# ----------------------------------------------------------------------------- #
#       Format: xyz $1, $2, $3                                                  #
# ----------------------------------------------------------------------------- #
        jal reg_check
        
        jal check_gap
        
        jal reg_check
        
        jal check_gap
        
        jal reg_check
        
        jal check_end

Type_2:
# ----------------------------------------------------------------------------- #
#       Format: xyz $1, $2, 10000                                               #
# ----------------------------------------------------------------------------- #
        jal reg_check
        
        jal check_gap
        
        jal reg_check
        
        jal check_gap
        
        jal num_check
        
        jal check_end

Type_3:
# ----------------------------------------------------------------------------- #
#       Format: mult $2,$3                                                      #
# ----------------------------------------------------------------------------- #
        jal reg_check
        
        jal check_gap
        
        jal reg_check
        
        jal check_end

Type_4:
# ----------------------------------------------------------------------------- #
#       Format: lw $1, 100($2)                                                  #
# ----------------------------------------------------------------------------- #
        jal reg_check
        
        jal check_gap
        
        jal address_check
        
        jal check_end

Type_5:
# ----------------------------------------------------------------------------- #
#       Format: lui $1, 100                                                     #
# ----------------------------------------------------------------------------- #
        jal reg_check
        
        jal check_gap
        
        jal num_check
        
        jal check_end

Type_6:
# ----------------------------------------------------------------------------- #
#       Format: la $1, label                                                    #
# ----------------------------------------------------------------------------- #
        jal reg_check
        
        jal check_gap
        
        jal label_check
        
        beq $s7, 1, check_end					# case label is character and syntax is correct
        
        jal num_check						# case label is numerical value
        
        jal check_end

Type_7:
# ----------------------------------------------------------------------------- #
#       Format mfhi $2                                                          #
# ----------------------------------------------------------------------------- #
        jal reg_check
        
        jal check_end

Type_8:
# ----------------------------------------------------------------------------- #
#       Format: beq $1, $2, label or beq $1,$2,100                              #
# ----------------------------------------------------------------------------- #
        jal reg_check
        
        jal check_gap
        
        jal reg_check
        
        jal check_gap
        
        jal label_check
        
        beq $s7, 1, check_end					# case label is character and syntax is correct
        
        jal num_check						# case label is numerical value 

        jal     check_end

Type_9:
# ----------------------------------------------------------------------------- #
#       Format j 1000 ; j label                                                 #
# ----------------------------------------------------------------------------- #
        jal     label_check
        
        beq     $s7, 1, check_end
        
        jal     num_check


        jal     check_end

# End of instruction types
# ----------------------------------------------------------------------------- #



# All syntax checking functions:
# ----------------------------------------------------------------------------- #


# check whether input string has ended or not
# ----------------------------------------------------------------------------- #
check_end: 
     	jal clear_whitespace
        lb $t5, 0($s0)
        beq $t5, '\n', valid_syntax
        beq $t5, '\0', valid_syntax	
        beq $t5,  '#', valid_syntax
        j too_many_variable					# not valid
# ----------------------------------------------------------------------------- #




# Check whether string is register or not 
# ----------------------------------------------------------------------------- #
reg_check:  
        la $s3, registerLibrary
        move $a3, $s3                        			# a3 points to beginning of register library
        move $a0, $s0

loop_reg_check:
        lb $t3, 0($a3)		        			# load each character from library
        lb $t0, 0($a0)		        			# load each character from input string
        beq $t3, ' ', evaluation2           			# if encountered space, evaluate whether it is correct
        beq $t3, 0, not_valid_register      			# if encountered \0 then we have checked every registers inside registerLibrary
        bne $t0, $t3, next_reg	        			# character mismatch
        addi $a0, $a0, 1                     			# next character
        addi $a3, $a3, 1
        j loop_reg_check
evaluation2:
        lb $t0, 0($a0)
        beq $t0, ',', found_reg                 		# Correct register
        beq $t0, ' ', found_reg                 		# Correct register
        beq $t0, 0, found_reg                   		# Correct register
        beq $t0, '\n', found_reg                   		# Correct register
        j next_reg						# jump to next_register
next_reg:
        addi $s3, $s3, 8                     			# Move to next register
        move $a3, $s3
        move $a0, $s0
        j loop_reg_check					# check again
found_reg:
        move $s0, $a0                        			# move pointer forward
        j jump_							# jump to jump_
# ----------------------------------------------------------------------------- #





# check whether current parameter is a valid number
# ----------------------------------------------------------------------------- #
num_check:
	move $a0, $s0
	
num_check_loop:
        lb $t0, 0($a0)
        beq $t0, ',', is_num                		 	# end of parameter 
        beq $t0, ' ', is_num                 			# end of parameter
        beq $t0, 0, is_num                   			# end of parameter
        beq $t0, '\n', is_num              			# end of parameter
        bgt $t0, '9', not_num	        			# if $t0 > '9' then not a number
        blt $t0, '0', not_num	        			# if $t0 < '0' then not a number
        addi $a0, $a0, 1
        j num_check_loop					# continue checking
        
is_num:
        move $s0, $a0
        j jump_							# jump back
        
not_num:
        j not_num_error						# jump to not_num_error
                        
# ----------------------------------------------------------------------------- #




# check whether address syntax is correct 
# ----------------------------------------------------------------------------- #            
address_check:
adnum_check:      
                    
num_check_loop2:
  	lb $t0, 0($a0)
        beq $t0, '(', is_num2               			# correct syntax for shift amount
        bgt $t0, '9', not_num2	        			# if $t0 > 9 then not a valid number
        blt $t0, '0', not_num2	        			# if $t0 < 0 then not a valid number
        addi $a0, $a0, 1
        j num_check_loop2					# continue checking next character
        
is_num2:
        move $s0, $a0
        j adreg_check						# continue checking for second register
        
not_num2:
        j not_valid_address					
# ----------------------------------------------------------------------------- #
                                


      
# check whether register in address is correct            
# ----------------------------------------------------------------------------- #                        
adreg_check:
reg_check2:
     	addi $a0, $a0, 1
        move $s0, $a0
        la $s3, registerLibrary
        move $a3, $s3                        			# a3 points to beginning of register library
        move $a0, $s0
loop_reg_check2:
        lb $t3, 0($a3)		        			# load each character from registerLibrary
        lb $t0, 0($a0)		        			# load each character from input string
        beq $t3, ' ', evaluation3           			# if encountered space, evaluate whether it is correct
        beq $t3, 0, not_valid_address2      			# if encountered \0 then we have checked all available registers in registerLibrary
        bne $t0, $t3, next_reg2	        			# if current characters are different 
        addi $a0, $a0, 1                     			# continue checking next character
        addi $a3, $a3, 1
        j loop_reg_check2
evaluation3:
        lb $t0, 0($a0)
        beq $t0, ')', found_reg2                 		# correct syntax
        j next_reg2						# else continue checking for next register
next_reg2:
        addi $s3, $s3, 8                     			# Move to next register in registerLibrary
        move $a3, $s3
        move $a0, $s0
        j loop_reg_check2					# continue checking
not_valid_address2:
        j not_valid_address
found_reg2:
        addi $a0, $a0, 1
        move $s0, $a0                        			# move pointer forward
        jr $ra							# jump back
# ----------------------------------------------------------------------------- #                        



# check whether label syntax is correct (for characters)
# ----------------------------------------------------------------------------- #
# output: $s7 = 1 if it is character and syntax is correct
#         $s7 = 0 if it not character and to signal that input label could be in numerical values
# ----------------------------------------------------------------------------- #
label_check:
      	move $a0, $s0

first_char_check: # Can't be number and can't be underscore:
        lb $t0, ($a0)    					# get current character of input string
        blt $t0, 'a', not_lower  				# if less than 'a' then it is not lower case character
        bgt $t0, 'z', not_lower 				# if greater than 'z' then it is not lower case chracter
           
        j loop_label_check					# it's lower so we jump to 2nd character
                
not_lower:
        blt $t0, 'A', fail_case  				# if less than 'A' then not alphabet
	bgt $t0, 'Z', fail_case					# if greater than 'Z' then not alphabet
                        
loop_label_check: # Can be alphabet, number and underscore

        addi $a0, $a0, 1                     			# increment $a0 by 1 to get next character
        lb $t0, ($a0)    		        		# load current character of input string
                
        beq $t0, ' ', valid_label           			# if we are here then all preceeding charactes are valid
        beq $t0, '\n', valid_label          			# if we are here then all preceeding charactes are valid
        beq $t0, 0, valid_label      				# if we are here then all preceeding charactes are valid
                        
                        
        blt $t0, 'a', not_lower2  				# if less than a then it is not lower case character
        bgt $t0, 'z', not_lower2				# if greater than z then it is not lower case character
        j loop_label_check					# else valid, continue to check for next character
                        
not_lower2:
        bne $t0, '_', not_underscore        			# if it is not underscore then continue checking 
        j loop_label_check					# else valid, continue to check for next character

not_underscore:
        blt $t0, 'A', not_upper2  				# If less than 'A' then it is not alphabet
	bgt $t0, 'Z', not_upper2				# If greater than 'Z' then it is not alphabet
	j loop_label_check					# else valid, continue to check for next character

not_upper2:
        blt $t0, '0', fail_case  				# if less than 0 then it is not number either
	bgt $t0, '9', fail_case					# if greater than 9 then it is not number either, failcase
	j loop_label_check					# else valid, continue to check for next character

fail_case:
        move $a0, $s0                				# reset to before so we check other case (not using label as address but numerical value instead)
        li $s7, 0                  				# set $s7 = 0 to signal to check for numerical value
        jr $ra							# jump back
                        
valid_label:
        move $s0, $a0                				# Move pointer forward
        li $s7, 1                  				# if label is all characters and correct then set $s7 = 1
        jr $ra
# ----------------------------------------------------------------------------- #
                      

# End of syntax checking functions 
# ----------------------------------------------------------------------------- #



              
# print correct_opcode_prompt and input opcode              
# ----------------------------------------------------------------------------- #
correct_opcode:					
   	la $a0, correct_opcode_prompt
        li $v0, 4
        syscall
        la $a0, opcode
        li $v0, 4
        syscall
        move $a0, $s0                				#  Return $a0
        jr $ra		
# ----------------------------------------------------------------------------- #



                


# All types of error messages when checking syntax:
# ----------------------------------------------------------------------------- #
missing_comma:
        la $a0, missing_comma_prompt               		
        li $v0, 4
        syscall
        j ending				        	
                
invalid_opcode:
        la $a0, invalid_opcode_prompt
        li $v0, 4
        syscall
        j ending				        
        
too_many_variable:
        la $a0, too_many_variable_prompt 
        li $v0, 4
        syscall
        j ending
        
not_valid_register:
        la $a0, not_valid_register_prompt 
        li $v0, 4
        syscall
        j ending
        
not_num_error:
        la $a0, not_valid_number_prompt 
        li $v0, 4
        syscall
        j ending
        
not_valid_address:
        la $a0, not_valid_address_prompt 
        li $v0, 4
        syscall
        j ending
        
missing_:
        la $a0, missing_prompt
        li $v0, 4
        syscall
        j ending
                
# End of error types                
# ----------------------------------------------------------------------------- #



valid_syntax:
        la $a0, valid_syntax_prompt
        li $v0, 4
        syscall
        j ending

ending:
        la $a0, continue_prompt
        li $v0, 4
        syscall 

        li $v0, 5
        syscall 

        beq $v0, 1, resetAll_andContinue			# if user choose to continue
        # else end program

        li $v0, 10
        syscall


resetAll_andContinue:
        
	li $v0, 0 
	li $v1, 0
	jal clean_block						# jump to clean_block
        jal clean_opcode					# jump to clean_block
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


# reset all values stored in previous input string to 0
# ----------------------------------------------------------------------------- #
clean_block:
        li $a0, 0 
        li $a1, 0
        la $s0, buffer						# point $s0 to the address of buffer
loop_block:
        beq $a1, 100, jump_
        sb $a0, 0($s0)
        addi $s0, $s0, 1
        addi $a1, $a1, 1
        j loop_block
# ----------------------------------------------------------------------------- #




# reset all values stored in previous opcode to 0
# ----------------------------------------------------------------------------- #
clean_opcode:
        li $a0, 0 
        li $a1, 0
        la $s1, opcode						# point $s1 to the address of opcode
loop_opcode:
        beq $a1, 10, jump_
        sb  $a0, 0($s1)
        addi $s1, $s1, 1
        addi $a1, $a1, 1
        j loop_opcode
# ----------------------------------------------------------------------------- #






