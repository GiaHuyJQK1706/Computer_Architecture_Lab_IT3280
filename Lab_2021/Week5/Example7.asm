.data
	Message: .space 100 # Buffer 100 byte chua chuoi ki tu can 
.text
 	li $v0, 8
 	la $a0, Message
 	li $a1, 100
 	syscall 