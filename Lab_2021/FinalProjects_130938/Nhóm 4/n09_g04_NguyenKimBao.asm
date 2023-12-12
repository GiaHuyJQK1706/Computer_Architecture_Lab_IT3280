.data
		       
	String1: .asciiz  "                                             *************        \n"
	String2: .asciiz  "**************                              *3333333333333*       \n"
	String3: .asciiz  "*222222222222222*                           *33333********        \n"
	String4: .asciiz  "*22222******222222*                         *33333*               \n"
	String5: .asciiz  "*22222*      *22222*                        *33333********        \n"
	String6: .asciiz  "*22222*       *22222*        *************  *3333333333333*       \n"
	String7: .asciiz  "*22222*       *22222*      **11111*****111* *33333********        \n"
	String8: .asciiz  "*22222*       *22222*    **1111**       **  *33333*               \n"
	String9: .asciiz  "*22222*      *222222*    *1111*             *33333********        \n"
	String10: .asciiz "*22222*******222222*    *11111*             *3333333333333*       \n"
	String11: .asciiz "*2222222222222222*      *11111*              *************        \n"
	String12: .asciiz "***************         *11111*                                   \n"
	String13: .asciiz "      ---               *1111**                                   \n"
	String14: .asciiz "    / o o \\              *1111****   *****                        \n"
	String15: .asciiz "    \\   > /               **111111***111*                         \n"
	String16: .asciiz "     -----                  ***********     dce.hust.edu.vn       \n"
	Message0: .asciiz "------------PROGRAMMING-----------\n"
	Request1:    .asciiz"1. In ra chu\n"
	Request2:    .asciiz"2. In ra chu khong mau\n"
	Request3:    .asciiz"3. Hoan doi vi tri chu\n"
	Request4:    .asciiz"4. Doi mau chu\n"
	Thoat:       .asciiz"5. Thoat\n"
	Choose:      .asciiz"Choose your option: "
	ChuD:     .asciiz"Nhap mau cho chu D(0->9): "
	ChuC:     .asciiz"Nhap mau cho chu C(0->9): "
	ChuE:     .asciiz"Nhap mau cho chu E(0->9): "
.text
	
	li $t5 50 #t5 mau chu hien tai cua chu D ( Ma ASCII 50 ~ 2)
	li $t6 49 #t6 mau chu hien tai cua chu C ( Ma ASCII 49 ~ 1)
	li $t7 51 #t7 mau chu hien tai cua chu E ( Ma ASCII51 ~ 3)

main:
	la $a0, Message0	
	li $v0, 4
	syscall
	
	la $a0, Request1	
	li $v0, 4
	syscall
	la $a0, Request2	
	li $v0, 4
	syscall
	la $a0, Request3	
	li $v0, 4
	syscall
	la $a0, Request4	
	li $v0, 4
	syscall
	la $a0, Thoat	
	li $v0, 4
	syscall
	la $a0, Choose	
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	Case1menu:
		addi $v1 $0 1
		bne $v0 $v1 Case2menu
		j Menu1
	Case2menu:
		addi $v1 $0 2
		bne $v0 $v1 Case3menu
		j Menu2
	Case3menu:
		addi $v1 $0 3
		bne $v0 $v1 Case4menu
		j Menu3
	Case4menu:
		addi $v1 $0 4
		bne $v0 $v1 Case5menu
		j Menu4
	Case5menu:
		addi $v1 $0 5
		bne $v0 $v1 defaultmenu
		j Exit
	defaultmenu:
		j main
#In chữ ra màn hình 
Menu1:	
	addi $t0, $0, 0	#t0 = 0; biến đếm hàng
	addi $t1, $0, 16	#t1= 16
	
	la $a0,String1
Loop:	beq $t1, $t0, main # if (t1=t0) -> main
	li $v0, 4
	syscall
		
	addi $a0, $a0, 68 # a0 = a0 + 68 (Các string chứa tối đa 68 ký tự -> string tiếp theo)
	addi $t0, $t0, 1  # t0 = t0 + 1
	j Loop

#Bỏ màu của các chữ , chỉ giữ lại viền

Menu2: 	addi $s0, $0, 0	  # s0=0 ; biến đếm hàng
	addi $s1, $0, 16  # s1 = 16 
	la   $s2,String1  #$s2 là địa chỉ của String1
		
Lap:	beq  $s1, $s0, main 	# if (s1 = s0 ) --> main
	addi $t0, $0, 0		# $t0 = 0 ; đếm ký tự của hàng
	addi $t1, $0, 68        # $t1 = 68 ; (Số ký tự tối đa của 1 hàng )
	
In1hang:
	beq $t1, $t0, End  # If (t1 = t0) --> jump End
	lb  $t2, 0($s2)	# load  byte giá trị của phần tử trong s2 vào $t2 ; 
	
	bgt $t2, 47, Label  # Nếu lớn hơn -1 thì nhảy đến Lonhon0 ( 47 ~ -1 )
	j   Tmp
	Label: 	
	    bgt  $t2, 57, Tmp # Nếu lớn hơn 9 thì giữ nguyên ( 57 ~ 9 )  -> jump Tmp -> In ra ký tự
	    addi $t2 $0 0x20  # $t2 = 0x20 -> thay đổi $t2 thành dấu cách
	    j Tmp	
Tmp: 	li $v0, 11  	# In từng ký tự
	addi $a0 $t2 0  #a0 = $t2  ;
	syscall
	
	addi $s2 $s2 1        # $s2 = $s2 + 1 -> sang ký tự tiếp theo
	addi $t0, $t0, 1      # $t0 = $t0 +1 ; ( $t0 : biến đếm ký tự )
	j In1hang
End:	addi $s0 $s0 1        # $s0 = $s0+1 ; Tăng biến đếm hàng lên 1
	j Lap
#Hoán đổi vị trí DCE - > ECD


Menu3:	addi $s0, $0, 0       # s0=0 ; biến đếm hàng
	addi $s1, $0, 16      # s1 = 16
	la $s2,String1        #$s2 là địa chỉ của String1
Lap2:	beq $s1, $s0, main    #if ($s1 = $s0) --> main
	#Chia string ban đầu thành  3 string nhỏ
	sb $0 21($s2) 
	sb $0 43($s2)
	sb $0 65($s2)
	#Đổi vị trí
	li $v0, 4 
	la $a0 44($s2) #In chữ E
	syscall
	
	li $v0, 4 
	la $a0 22($s2) #In chữ C
	syscall
	
	li $v0, 4 
	la $a0 0($s2) #In chữ D
	syscall
	
	li $v0, 4 
	la $a0 66($s2)  #In ký tự "\n"
	syscall
	#Ghép lại thành String ban đầu 
	addi $t1 $0 0x20  # $t1 = 0x20 -> thay đổi $t1 thành dấu cách
	sb $t1 21($s2)
	sb $t1 43($s2)
	sb $t1 65($s2)
	
	addi $s0 $s0 1
	addi $s2 $s2 68
	j Lap2

#Đổi màu chữ
Menu4: 
NhapmauD:		li 	$v0, 4		
		la 	$a0, ChuD
		syscall
	
		li 	$v0, 5		# Lấy màu của ký tự D
		syscall

		blt	$v0,0, NhapmauD    # if (integer_input < 0 ) --> NhapmauD 
		bgt	$v0,9, NhapmauD    # if (integer_input > 9 ) --> NhapmauD	
		
		addi	$s3 $v0 48  #$s3 = integer_input,Lưu màu chữ D (Mã ASCII của 0 ~ 48)
NhapmauC:		li 	$v0, 4		
		la 	$a0, ChuC
		syscall
	
		li 	$v0, 5		#Lấy màu của ký tự C
		syscall

		blt	$v0, 0, NhapmauC
		bgt	$v0, 9, NhapmauC
				
		addi	$s4  $v0 48	 #$s4 Lưu màu của chữ C
NhapmauE:	          li 	$v0, 4		
		la 	$a0, ChuE
		syscall
	
		li 	$v0, 5		#Lấy màu của ký tự E
		syscall

		blt	$v0, 0, NhapmauE   
		bgt	$v0, 9, NhapmauE
			
		addi	$s5 $v0 48	#$s5 Lưu màu của chữ E
	
	          addi        $s0, $0, 0	  # s0 = 0 ; biến đếm hàng           
	          addi        $s1, $0, 16         # s1 = 16 ;
	          la          $s2,String1	  # $s2 là địa chỉ của String1
	          li          $a1 48                  #giá trị của số 0 
	          li          $a2 57                  #giá trị của số 9

Lapdoimau:	beq         $s1, $s0, updatemau #if (s1 = s0) -> jump updatemau 
		addi        $t0, $0, 0      # $t0 = 0 ; đếm ký tự của hàng
		addi        $t1, $0, 68     # $t1 = 68 ; (Số ký tự tối đa của 1 hàng )
	
In1hangdoimau:
	beq $t1, $t0, Enddoimau
	lb $t2, 0($s2)	 #  load  byte giá trị của phần tử trong s2 vào $t2 ; 
	CheckD: bgt	$t0, 21, CheckC #if (t0>21) -> checkC ;Kiểm tra hết chữ D chưa
	        beq	$t2, $t5, fixD  #if (t2 = t5) -> jump fixD
	        j Tmpdoimau
	CheckC: bgt	$t0, 43, CheckE #Kiểm tra hết chữ C chưa
	        beq	$t2, $t6, fixC
	        j Tmpdoimau
	CheckE: beq	$t2, $t7, fixE
	        j Tmpdoimau
		
fixD: 	sb $s3 0($s2)
	j Tmpdoimau
fixC: 	sb $s4 0($s2)
	j Tmpdoimau
fixE: 	sb $s5 0($s2)
	j Tmpdoimau
Tmpdoimau: 	
	addi $s2 $s2 1 #Sang ký tự tiếp theo
	addi $t0, $t0, 1 # t0 = t0 + 1 ; --> sang ký tự tiếp theo
	j In1hangdoimau
Enddoimau:	
	li $v0, 4  
	addi $a0 $s2 -68 #Trở về đầu hàng sau khi đổi màu
	syscall
	addi $s0 $s0 1 # s0 = s0 + 1 ; -> tăng biến đếm hàng lên 1
	j Lapdoimau
updatemau: 
	move $t5 $s3 #gan gia tri s3 vao t5
	move $t6 $s4 #gan gia tri s4 vao t6
	move $t7 $s5 #gan gia tri s5 vao t7
	j main	
Exit:
