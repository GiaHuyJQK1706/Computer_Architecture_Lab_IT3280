.data
CharPtr: .word  0 # Pointer variable, type of asciiz
CharPtr1: .word  0 # Pointer variable, type of asciiz
CharPtr2: .word 0 # Pointer variable, type of asciiz
BytePtr: .word  0 # Pointer variable, type of Byte
WordPtr: .word  0 # Pointer variable, type of Word
ArrayPtr: .word 0 # Pointer variable, point to Array A

#--------------Text display------------------
CharPtrDis: .asciiz "CharPtr\n"
BytePtrDis: .asciiz "BytePtr\n"
WordPtrDis: .asciiz "WordPtr\n"
Enterdata: .asciiz "Enter your data \n"
ValueChar: .asciiz "The value of Char pointer: " 
ValueByte: .asciiz "The value of Byte pointer: " 
ValueWord: .asciiz "The value of Word pointer: " 
AddrChar: .asciiz "Address of Char pointer: "
AddrByte: .asciiz "Address of Byte pointer: "
AddrWord: .asciiz "Address of Word pointer: "
StrLen: .asciiz "Enter the length of the source string: "
InputStr: .asciiz "Enter the source string: "
CpyStr: .asciiz "The copied string: "
Allocated: .asciiz "Memory Allocated: "
InputRow: .asciiz "\nA[i][j]\nEnter the number of rows: "
InputCol: .asciiz "Enter the number of columns j: "
SetAij: .asciiz "\nSet A[i][j]\n"
GetAij: .asciiz "\nGet A[i][j]\n"
Inputi: .asciiz "Enter i: "
Inputj:	.asciiz "Enter j: "
Continue: .asciiz "Continue?"
Result: .asciiz "A[i][j] = "
Mem_Allocated: .asciiz "The amount of allocated memory (byte): "
#---------------------------------------------

.kdata
Sys_TheTopOfFree: .word  1
Sys_MyFreeSpace: 
.text	
#Initiate memory to dynamic allocation
	
	jal  	SysInitMem 
	li 	$s7,0
#-------Task 1: Fix the Word address error-------
#$a1: number of elements
#$a2: size of each elements
	
	la $a0,CharPtrDis
	li $v0,4
	syscall
	la  	$a0, CharPtr	#Allocate CharPtr
	addi	$a1, $zero, 3
	addi	$a2, $zero, 4	#set to 4 instead of 1	
	jal	malloc 
	jal	InputData
	
	la $a0,BytePtrDis
	li $v0,4
	syscall
	la	$a0, BytePtr	#Allocate ByePtr
	addi	$a1, $zero, 2
	addi	$a2, $zero, 4	#set to 4 instead of 1	
	jal	malloc 
	jal	InputData
	
	la $a0,WordPtrDis
	li $v0,4
	syscall
	la  	$a0, WordPtr	#Allocate WordPtr
	addi 	$a1, $zero, 1
	addi 	$a2, $zero, 4
	jal  	malloc 
	jal	InputData
 	j 	PtrValue
#-----------------------------------------------
SysInitMem:  
	la	$t9, Sys_TheTopOfFree
	la	$t7, Sys_MyFreeSpace
	sw	$t7, 0($t9)
	jr   	$ra

malloc:   
	la   	$t9, Sys_TheTopOfFree   
	lw  	$t8, 0($t9)	#Get the address of the free memory
	sw	$t8, 0($a0)	#Store it in the pointer
	addi	$v0, $t8, 0	#Which is also the return value
 	mul	$t7, $a1,$a2	#Calculate the size of allocation
 	add	$t6, $t8, $t7	#Update the address of free memory 
 	sw	$t6, 0($t9)	#Save to Sys_TheTopOfFree 
 	jr   $ra

InputData: 
	li	$s3, 0	#counter
	la	$a0, Enterdata
	li	$v0, 4
	syscall
	Loopl:
	li 	$v0, 5
	syscall
	sw	$v0, 0($t8)	#save input data into free memory
	addi	$t8, $t8, 4	#move to the next free memory
	addi	$s3, $s3, 1	#count++
	beq 	$s3, $a1, Loop1_end	#count = number of elements then end
	j	Loopl
	Loop1_end:
	jr	$ra
	
#------Task 2: Get the value of the pointer------
PtrValue:
	la	$a0, CharPtr
	lw	$t8, 0($a0)
	lw	$t5, 0($t8)	
	la 	$a0, ValueChar
	li 	$v0, 56
	move	$a1, $t5
	syscall
	
	la	$a0, BytePtr
	lw	$t8, 0($a0)
	lw	$t5, 0($t8)
	la 	$a0, ValueByte
	li 	$v0, 56
	move	$a1, $t5
	syscall
	
	la	$a0, WordPtr
	lw	$t8, 0($a0)
	lw	$t5, 0($t8)
	la 	$a0, ValueWord
	li 	$v0, 56
	move	$a1, $t5
	syscall
#-------------------------------------------------

#------Task 3: Get the address of the pointer------
	la	$a0, CharPtr
	lw	$t8, 0($a0)
	la 	$a0, AddrChar
	li 	$v0, 56
	move	$a1, $t8
	syscall
	
	la	$a0, BytePtr
	lw	$t8, 0($a0)
	la 	$a0, AddrByte
	li 	$v0, 56
	move	$a1, $t8
	syscall
	
	la	$a0, WordPtr
	lw	$t8, 0($a0)
	la 	$a0, AddrWord
	li 	$v0, 56
	move	$a1, $t8
	syscall
#--------------------------------------------------

#-----------Task 4: Copy 2 CharPtr-----------
	li $v0,4
	la $a0, StrLen
	syscall
	li $v0,5
	syscall		#Enter string length
	
	move $a1,$v0
	addi $a2,$0,1
	la $a0, CharPtr1	#source
	jal malloc
	move $s0,$v0	#Address of the source pointer
	
	la $a1, CharPtr2	#target
	jal malloc
	move $s1,$v0	#Address of the target pointer
	
	la $a0,InputStr
	li $v0,4
	syscall
	
	move $a0,$s0	#$a0 =  address source string
	li $v0,8
	syscall 	#Input string into the source pointer
	move $a1,$s1	#$a1 = address target string
	
strcpy:
	add $t0,$a0,$0	#Initiate $t0 first character of source string
	add $t1,$a1,$0	#Initiate $t1 first character of target string
	addi $t2,$0,1	#Initiate $t2 as a character != '\0' to start the loop

cpyLoop:
	beq $t2,0,cpyLoop_end	#End the loop if the latest copied char is '\0'
	lb $t2, 0($t0)
	sb $t2, 0($t1)
	addi $t0,$t0,1
	addi $t1,$t1,1
	j cpyLoop
cpyLoop_end:
	la $a0,CpyStr
	li $v0,4
	syscall
	move $a0,$s1
	syscall
#--------------------------------------------

#------Task 6: Calculate allocated memory-----
	la $t0, Sys_MyFreeSpace	# Lay dia chi dau tien duoc cap phat
	la $t1, Sys_TheTopOfFree	# Lay dia chi luu dia chi dau tien con trong
	lw $t2, 0($t1)		# Lay dia chi dau tien con trong
	sub $t3, $t2, $t0		# Tru hai dia chi cho nhau
	
	la $a0,Allocated
	li $v0,4
	syscall
	move $a0,$t3
	li $v0,1
	syscall
#-----------------------------------------

#----------Task 5: Free the allocated-----
	jal SysInitMem
	nop
#-----------------------------------------
#------------Task 7: Malloc2-------------
	jal   SysInitMem
	la   $a0, ArrayPtr
	#ham nhap so dong i
	la	$a0, InputRow
	li	$v0, 4
	syscall
	li	$v0, 5
	syscall
	move 	$a1, $v0	#so dong
	
	#Ham nhap so cot j
	la	$a0, InputCol
	li	$v0, 4
	syscall
	li	$v0, 5
	syscall
	move 	$a2, $v0	#so cot
	addi	$a3, $zero, 4
	jal malloc2
	j	Task8
	
	malloc2:
	la   	$t9, Sys_TheTopOfFree   
	lw  	$t8, 0($t9)	#Lay dia chi dau tien con trong
	sw	$t8, 0($a0)	#Cat dia chi do vao bien con tro
	addi	$v0, $t8, 0	#Dong thoi laket qua tra ve cua ham
 	mul	$t7, $a1,$a2	#Tinh kich thuoc cua mang can cap phat
 	mul	$t5, $t7, $a3
 	add	$t6, $t8, $t5	#Tinh dia chi dau tien controng 
 	sw	$t6, 0($t9)	#Luu tro lai dia chi dau tien do vao bien Sys_TheTopOfFree 
 	jr   $ra

#--------Task 8: Get/Set A[i][j]---------
Task8:
	#Ham set
	NhapDulieu1: 
	la  	$t8, Sys_MyFreeSpace
	la	$a0, SetAij
	li	$v0, 4
	syscall
	#Nhap hang i
	la	$a0, Inputi
	li	$v0, 4
	syscall
	laptimi:
	li 	$v0, 5
	syscall
	slt	$s4, $v0, $a1
	bne	$s4, $0, hetlaptimi
	j	laptimi
	hetlaptimi:
	move	$s1, $v0	#hang i luu vao s1

	#Nhap cot j
	la	$a0, Inputj
	li	$v0, 4
	syscall
	laptimj:
	li 	$v0, 5
	syscall
	slt	$s4, $v0, $a2
	bne	$s4, $0, hetlaptimj
	j	laptimj
	hetlaptimj:
	move	$s2, $v0	#cot j luu vao s2
	
	la	$a0, Result
	li	$v0, 4
	syscall
	li 	$v0, 5
	syscall
	mul	$s3, $s1, $a2
	add	$s3, $s3, $s2
	mul	$s3, $s3, $a3
	add	$t8, $t8, $s3
	sw	$v0, 0($t8)

	la	$a0, Continue
	li	$v0, 50
	syscall
	beq	$a0, $0, NhapDulieu1
	j	XuatDulieu
	
	XuatDulieu: 	#ham get

	la	$a0, GetAij
	li	$v0, 4
	syscall
	la  	$t8, Sys_MyFreeSpace
	#Nhap hang i
	la	$a0, Inputi
	li	$v0, 4
	syscall
	laptimi1:
	li 	$v0, 5
	syscall
	slt	$s4, $v0, $a1
	bne	$s4, $0, hetlaptimi1
	j	laptimi1
	hetlaptimi1:
	move	$s1, $v0	#hang i luu vao s1

	#Nhap cot j
	la	$a0, Inputj
	li	$v0, 4
	syscall
	laptimj1:
	li 	$v0, 5
	syscall
	slt	$s4, $v0, $a2
	bne	$s4, $0, hetlaptimj1
	j	laptimj1
	hetlaptimj1:
	move	$s2, $v0	#cot j luu vao s2
	
	la	$a0, Result
	li	$v0, 4
	syscall
	mul	$s3, $s1, $a2
	add	$s3, $s3, $s2
	mul	$s3, $s3, $a3
	add	$t8, $t8, $s3
	lw	$a0, 0($t8)
	li	$v0, 1
	syscall
	la	$a0, Continue
	li	$v0, 50
	syscall
	beq	$a0, $0, XuatDulieu
	j	exit
exit:
