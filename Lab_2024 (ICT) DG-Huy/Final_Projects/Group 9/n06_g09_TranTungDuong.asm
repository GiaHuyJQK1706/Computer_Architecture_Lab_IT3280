.data
CharPtr: 	.word  0 
BytePtr: 	.word  0 
WordPtr: 	.word  0 
CharPtr1:	.word 	0	# asciiz
CharPtr2:	.word 	0	# asciiz
ArrayPtr:	.word 	0	# 1D array pointer
Array2dPtr:	.word	0	# 2D array pointer
text1:		.asciiz	"\n\n1. 1-dimensional array\n"
text2:		.asciiz	"2. Copy two characters pointers\n"
text3:		.asciiz	"3. 2-dimensional array\n"
text4:		.asciiz	"4. Free Memory\n"
text5:		.asciiz	"5. Exit\n"
text0.1:	.asciiz "Array Size: "
text0.2:	.asciiz "Element size (1-Byte or 4-Byte): "
textinput:	.asciiz "\nEnter Elements: "
text1.1:	.asciiz	"Pointer Value: "
text1.2:	.asciiz	"\nPointer Address: "
text1.3:	.asciiz "\nTotal Memory Allocated: "
text2.1:	.asciiz "String limit: "
text2.2:	.asciiz "\nEntered String: "
text2.3:	.asciiz	"\nCopied String: "
text3.1:	.asciiz	"\nRows: "
text3.2:	.asciiz	"\nCollumn: "
text3.3:	.asciiz	"\n1. getArray[i][j]\n"
text3.4:	.asciiz	"2. setArray[i][j]\n"
text3.5:	.asciiz	"3. Return\n"
text3.01:	.asciiz	"i = "
text3.02:	.asciiz	"j = "
text3.03:	.asciiz	"Element value = "
text4.1:	.asciiz	"Memory Freed.\n"
select:		.asciiz	"Select "
errortext:	.asciiz	"\nInvalid.\n"

.kdata
# Pointer variable contains the address of free memory space
Sys_TheTopOfFree:	.word 	1
# Memory space used to allocate to pointers
Sys_MyFreeSpace:

.text
# Initialize memory to dynamic allocation
	jal	SysInitMem
# Display menu
	menu:
	li	$v0, 4
	la	$a0, text1
	syscall
	la	$a0, text2
	syscall
	la	$a0, text3
	syscall
	la	$a0, text4
	syscall
	la	$a0, text5
	syscall
	la	$a0, select
	syscall
	li	$v0, 5
	syscall
case_1:	
	bne	$v0, 1, case_2
	li	$v0, 4
	la	$a0, text0.1
	syscall
	li	$v0, 5
	syscall
	bltz	$v0, error
	move	$a1, $v0
	li	$v0, 4
	la	$a0, text0.2
	syscall
	li	$v0, 5
	syscall
is1:	beq	$v0, 1, ready  
is4:	beq	$v0, 4, ready
	j	error
ready:	move	$a2, $v0
	la	$a0, ArrayPtr
	jal	malloc
	move	$t0, $v0
	li	$v0, 4
	la	$a0, textinput
	syscall
	move	$a0, $t0
	add	$t0, $0, $0
input_loop:
	beq	$t0, $a1, input_end
	li	$v0, 5
	syscall
	bne	$a2, 1, byte_4
byte_1:
	sb	$v0, 0($a0)
	addi	$a0, $a0, 1
	addi	$t0, $t0, 1
	j	input_loop
byte_4:	
	sw	$v0, 0($a0)
	addi	$a0, $a0, 4
	addi	$t0, $t0, 1
	j	input_loop
input_end:
	li	$v0, 4
	la	$a0, text1.1
	syscall
	la	$a0, ArrayPtr
	jal	getValue
	move	$a0, $v0
	li	$v0, 1
	syscall
	li	$v0, 4
	la	$a0, text1.2
	syscall
	la	$a0, ArrayPtr
	jal	getAddress
	move	$a0, $v0
	li	$v0, 1
	syscall
	li	$v0, 4
	la	$a0, text1.3
	syscall
	jal	memoryCalculate
	move	$a0, $v0
	li	$v0, 1
	syscall
	j	menu
case_2:
	bne	$v0, 2, case_3
	li	$v0, 4
	la	$a0, text2.1
	syscall
	li	$v0, 5
	syscall
	move	$a1, $v0
	addi	$a2, $0, 1
	la	$a0, CharPtr1
	jal	malloc
	move	$s0, $v0
	la	$a0, CharPtr2
	jal	malloc
	move	$s1, $v0
	li	$v0, 4
	la	$a0, text2.2
	syscall
	move	$a0, $s0
	li	$v0, 8
	syscall
	move	$a1, $s1
	jal	strcpy
	li	$v0, 4
	la	$a0, text2.3
	syscall
	move	$a0, $s1
	syscall
	j	menu
case_3:
	bne	$v0, 3, case_4
	li	$v0, 4
	la	$a0, text3.1
	syscall
	li	$v0, 5
	syscall
	move	$a1, $v0
	li	$v0, 4
	la	$a0, text3.2
	syscall
	li	$v0, 5
	syscall
	move	$a2, $v0
	la	$a0, Array2dPtr
	jal	malloc2
	move	$t0, $v0
	li	$v0, 4
	la	$a0, textinput
	syscall
	move	$a0, $t0
	add	$t0, $0, $0
	move	$t1, $a1
	mul	$a1, $a1, $a2
input_loop2:
	beq	$t0, $a1, input_end2
	li	$v0, 5
	syscall
	sw	$v0, 0($a0)
	addi	$a0, $a0, 4
	addi	$t0, $t0, 1
	j	input_loop2
input_end2:
	move	$a1, $t1	
menu3:
	li	$v0, 4
	la	$a0, text3.3
	syscall
	la	$a0, text3.4
	syscall
	la	$a0, text3.5
	syscall
	la	$a0, select
	syscall
	li	$v0, 5
	syscall
case_31:
	bne	$v0, 1, case_32
	li	$v0, 4
	la	$a0, text3.01
	syscall
	li	$v0, 5
	syscall
	move	$s0, $v0
	li	$v0, 4
	la	$a0, text3.02
	syscall
	li	$v0, 5
	syscall
	move	$s1, $v0
	la	$t0, Array2dPtr
	lw	$a0, 0($t0)
	jal	getArray
	move	$s2, $v0
	li	$v0, 4
	la	$a0, text3.03
	syscall
	li	$v0, 1
	move	$a0, $s2
	syscall
	j	menu3
case_32:
 	bne	$v0, 2, case_33
 	li	$v0, 4
	la	$a0, text3.01
	syscall
	li	$v0, 5
	syscall
	move	$s0, $v0
	li	$v0, 4
	la	$a0, text3.02
	syscall
	li	$v0, 5
	syscall
	move	$s1, $v0
	move	$s2, $v0
	li	$v0, 4
	la	$a0, textinput
	syscall
	li	$v0, 5
	syscall
	la	$t0, Array2dPtr
	lw	$a0, 0($t0)
	jal	setArray
	j	menu3
case_33:
	bne	$v0, 3, error
	j	menu
case_4:
	bne	$v0, 4, case_5
	jal	free
	li	$v0, 4
	la	$a0, text4.1
	syscall
	li	$v0, 4
	la	$a0, text1.3
	syscall
	jal	memoryCalculate
	move	$a0, $v0
	li	$v0, 1
	syscall	
	j	menu
case_5:
	bne	$v0, 5, error
	li $v0, 10  
    	syscall
error:
	li	$v0, 4
	la	$a0, errortext
	syscall
	j	menu
#------------------------------------------
# Initialize memory to dynamic allocation
# @param	none
# @detail	Mark the start position of memory which is usable
#------------------------------------------
SysInitMem: 
	la	$t9, Sys_TheTopOfFree	
	la	$t7, Sys_MyFreeSpace	 
	sw	$t7, 0($t9)	
	jr	$ra
#------------------------------------------
# Function used for dynamic allocation to the pointer
# @param	[in/out]	$a0: Address of the pointer need allocation
# When the function is complete, the address of allocated memory will be stored in the pointer
# @param	[in]		$a1: Number of elements
# @param	[in]		$a2: Size of one element, in byte
# @return			$v0: Address of the allocated memory
#------------------------------------------
malloc:  
	la	$t9, Sys_TheTopOfFree
	lw	$t8, 0($t9)		# Get the address of the free memory
	bne	$a2, 4, initialize	# If the initializing array has a Word type, check if the starting address satisfy the rule
	andi	$t0, $t8, 0x03		# Reminder of address divided by 4
	beq	$t0, 0, initialize	# If remainder = 0, initialize
	addi	$t8, $t8, 4		# If not 0, move to the next address divisible by 4
	subu	$t8, $t8, $t0
initialize:	
	sw	$t8, 0($a0)	# Store it in the pointer
	addi	$v0, $t8, 0	# Which is also the return value
	mul	$t7, $a1,$a2	# Calculate the size of allocation
	add	$t6, $t8, $t7	# Update the address of free memory 
	sw	$t6, 0($t9)	# Save to Sys_TheTopOfFree
	jr	$ra
#------------------------------------------
# Get pointer value
# @param	[in]		$a0: Address of the pointer 
# @return			$v0: Value stored in the pointer
#------------------------------------------
getValue:

	lw $v1, 0($a0)   # Load the address of the pointer into $v1
    	# Check the size parameter to determine whether to load a byte or a word
    	beq $a2, 1, loadByte
    	beq $a2, 4, loadWord
    
loadByte:
    	lb $v0, 0($v1)   # Load a byte from the memory address in $v1 into $v0
    	jr $ra

loadWord:
    	lw $v0, 0($v1)   # Load a word (4 bytes) from the memory address in $v1 into $v0
    	jr $ra

#------------------------------------------
# Get pointer address
# @param	[in]		$a0: Contains the address of the current pointer
# @return			$v0: Address of the pointer
#------------------------------------------	
getAddress:
	lw	$v0, 0($a0)	# Get the address of the pointer from $a0
	jr	$ra
#------------------------------------------
# Copy 2 characters pointer
# @param	[in]	$a0: Source character pointer address
# @param	[in]	$a1: Target character pointer address
#------------------------------------------
strcpy:
	add	$t0, $0, $a0	# Initialize $t0 to the start of the source string
	add	$t1, $0, $a1	# Initialize $t1 to the start of the target string
	addi	$t2, $0, 1	# Initialize $t2 to a character other than '\0' to start the loop
copyLoop:
	beq	$t2, 0, copyLoopEnd	# If the character copied in the previous loop was '\0', exit
	lb	$t2, 0($t0)		# Load a character from the source string
	sb	$t2, 0($t1)		# Store the character into the target string
	addi	$t0, $t0, 1		# Move $t0 to the next character in the source string
	addi	$t1, $t1, 1		# Move $t1 to the next character in the target string
	j	copyLoop
copyLoopEnd:
	jr	$ra
#------------------------------------------
# Free allocated memory	
# @param	none
#------------------------------------------
free:
	la $t9, Sys_TheTopOfFree
    	la $t7, Sys_MyFreeSpace
    	sw $t7, 0($t9)
    	jr $ra
#------------------------------------------
# Calculate allocated memory		
# @param	none
# @return	$v0: 
#------------------------------------------	
memoryCalculate:
	la	$t0, Sys_MyFreeSpace	# Load the address of the first allocated memory
	la	$t1, Sys_TheTopOfFree	# Load the address of the top of free memory
	lw	$t2, 0($t1)		
	sub	$v0, $t2, $t0		# Subtract the addresses to calculate the total allocated memory
	jr	$ra
#------------------------------------------
# malloc2 for 2d array	
# @param	[in/out]	$a0: Address of the pointer need allocation
# When the function is complete, the address of allocated memory will be stored in the pointer
# @param	[in]		$a1: Number of rows
# @param	[in]		$a2: Number of collumns
# @return			$v0: Address of the allocated memory
#------------------------------------------	
malloc2:
	addi	$sp, $sp, -12  # Allocate space on the stack to store necessary values
	sw	$ra, 8($sp)    # Save the return address on the stack
	sw	$a1, 4($sp)    # Save the number of rows on the stack
	sw	$a2, 0($sp)	# Save the number of columns on the stack
	mul	$a1, $a1, $a2	# $a1 = number of elements (rows*collumns)
	addi	$a2, $0, 4	# $a2 = 4-byte size of a word element
	jal	malloc		# Convert to 1d array
	lw	$ra, 8($sp)	# Return values to register
	lw	$a1, 4($sp)
	lw	$a2, 0($sp)
	addi	$sp, $sp, 12
	jr	$ra
#------------------------------------------
# get 2d array elements
# @param	[in]		$a0: Array pointer address
# @param	[in]		$a1: Rows number
# @param	[in]		$a2: Collumns number
# @param	[in]		$s0: i
# @param	[in]		$s1: j
# @return			$v0: Element's value
#------------------------------------------	
getArray:
	mul	$t0, $s0, $a2	# Element position: i * collumn number + j
	add	$t0, $t0, $s1
	sll	$t0, $t0, 2	# Multiply by 4 to account for word size
	add	$t0, $t0, $a0	# Add the base address of the array to get the address of the element
	lw	$v0, 0($t0)	# get value
	jr	$ra
#------------------------------------------
# update 2d array elements
# @param	[in]		$a0: Array pointer address
# @param	[in]		$a1: Rows number
# @param	[in]		$a2: Collumns number
# @param	[in]		$s0: i
# @param	[in]		$s1: j
# @param	[in]		$v0: Set value
#------------------------------------------		
setArray:
	mul	$t0, $s0, $a2	
	add	$t0, $t0, $s1
	sll	$t0, $t0, 2	
	add	$t0, $t0, $a0	 
	sw	$v0, 0($t0)	# set value
	jr	$ra
	
