#Laboratory Exercise 5, Home Assignment 3
.data
	string: .space 50
	Message1: .asciiz "Nhap xau: "
	Message2: .asciiz "Do dai xau la: "
.text
main:
get_string: # TODO
get_length: 	la $a0,string # $a0 = address(string[0])
		add $t0,$zero,$zero # $t0 = i = 0
check_char: 	add $t1,$a0,$t0 # $t1 = $a0 + $t0
 		# = address(string[i]) 
  		lb $t2, 0($t1) # $t2 = string[i]
		beq $t2, $zero, end_of_str # is null char? 
 		addi $t0, $t0, 1 # $t0 = $t0 + 1 -> i = i + 1
 		j check_char
end_of_str: 
end_of_get_length:
print_length: # TODO