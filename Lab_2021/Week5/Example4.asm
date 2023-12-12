.data
	Message: .asciiz "Bo mon \nKy thuat May tinh:"
	Address: .asciiz " Phong 502, B1"
.text
 	li $v0, 59
 	la $a0, Message
 	la $a1, Address 
 	syscall 