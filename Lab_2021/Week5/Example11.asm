.data
	Message: .asciiz "Ban la SV Ky thuat May tinh?"
.text
	li $v0, 50
	la $a0, Message
	syscall 