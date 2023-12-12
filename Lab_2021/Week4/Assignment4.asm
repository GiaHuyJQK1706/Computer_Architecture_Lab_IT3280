#Laboratory Exercise 4, Assignment 4
.text
	li $s0, 0
	li $s1, 0
	li $t0, 0		# Mac dinh t0 = 0 la trang thai khong xay ra Overflow

	addu $t2, $s0, $s1	# Tinh tong s0 va s1 va ket qua neu co bi tran so van ghi vao t2
		
	xor $t1, $s0, $s1	# Neu hai so s0 va s1 cung dau thi t1 > 0, neu hai so khac dau thi t1 < 0
	blez $t1, Exit		# Neu t1 < 0 (Hai so khac dau) thi nhay den Exit
	

	xor $t1, $s1, $t2	# Neu hai so s1 va t2 cung dau thi t1 > 0, neu hai so khac dau thi t1 < 0
	bgez $t1, Exit		# Neu t1 > 0 (Hai so cung dau) thi nhay den Exit
Overflow:
	li $t0, 1		# Overflow xay ra
Exit:































