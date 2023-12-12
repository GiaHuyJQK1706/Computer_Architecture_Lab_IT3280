.data
	A: .word -2, 6, -1, 3, -2
.text
main: 	la $a0,A
 	li $a1,5
 	j mspfx
 	nop
continue:
lock: 	j lock
 	nop
end_of_main:
#-----------------------------------------------------------------
#Procedure mspfx
# @brief find the maximum-sum prefix in a list of integers
# @param[in] a0 the base address of this list(A) need to be processed
# @param[in] a1 the number of elements in list(A) 
# @param[out] v0 the length of sub-array of A in which max sum reachs.
# @param[out] v1 the max sum of a certain sub-array
#-----------------------------------------------------------------
#Procedure mspfx
#function: find the maximum-sum prefix in a list of integers
#the base address of this list(A) in $a0 and the number of
#elements is stored in a1
mspfx: 	addi $v0,$zero,0 #initialize length in $v0 to 0
 	addi $v1,$zero,0 #initialize max sum in $v1to 0
 	addi $t0,$zero,0 #initialize index i in $t0 to 0
 	addi $t1,$zero,0 #initialize running sum in $t1 to 0
loop: 	add $t2,$t0,$t0 #put 2i in $t2
 	add $t2,$t2,$t2 #put 4i in $t2
	add $t3,$t2,$a0 #put 4i+A (address of A[i]) in $t3
	lw $t4,0($t3) #load A[i] from mem(t3) into $t4
	add $t1,$t1,$t4 #add A[i] to running sum in $t1
	slt $t5,$v1,$t1 #set $t5 to 1 if max sum < new sum
	bne $t5,$zero,mdfy #if max sum is less, modify results
	j test #done?
mdfy: 	addi $v0,$t0,1 #new max-sum prefix has length i+1
	addi $v1,$t1,0 #new max sum is the running sum
test: 	addi $t0,$t0,1 #advance the index i
	slt $t5,$t0,$a1 #set $t5 to 1 if i<n
	bne $t5,$zero,loop #repeat if i<n
done: 	j continue
mspfx_end:
