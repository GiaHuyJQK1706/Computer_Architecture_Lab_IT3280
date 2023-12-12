# Program File: HelloWorld.asm
# Author: Pham Huy Canh
# Print "Hello World" to the console

.text
main:
	li $v0, 4
	la $a0, message
	syscall
	
	li $v0, 10
	syscall
.data
	message: .asciiz "Hello World"