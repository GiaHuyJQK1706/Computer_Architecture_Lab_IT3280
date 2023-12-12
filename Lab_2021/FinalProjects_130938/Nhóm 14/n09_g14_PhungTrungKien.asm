.data
    #(21+21+21+1)x16 = 1024
    String: .asciiz "                                           *************       \n**************                            *3333333333333*      \n*222222222222222*                         *33333********       \n*22222******222222*                       *33333*              \n*22222*      *22222*                      *33333********       \n*22222*       *22222*      *************  *3333333333333*      \n*22222*       *22222*    **11111*****111* *33333********       \n*22222*       *22222*  **1111**       **  *33333*              \n*22222*      *222222*  *1111*             *33333********       \n*22222*******222222*  *11111*             *3333333333333*      \n*2222222222222222*    *11111*              *************       \n***************       *11111*                                  \n     ---               *1111**                                 \n   / o o \\              *1111****   *****                      \n   \\   > /               **111111***111*                       \n    -----                  ***********    dce.hust.edu.vn      \n" 
    # "                                           *************       \n"
    # "**************                            *3333333333333*      \n"
    # "*222222222222222*                         *33333********       \n"
    # "*22222******222222*                       *33333*              \n"
    # "*22222*      *22222*                      *33333********       \n"
    # "*22222*       *22222*      *************  *3333333333333*      \n"
    # "*22222*       *22222*    **11111*****111* *33333********       \n"
    # "*22222*       *22222*  **1111**       **  *33333*              \n"
    # "*22222*      *222222*  *1111*             *33333********       \n"
    # "*22222*******222222*  *11111*             *3333333333333*      \n"
    # "*2222222222222222*    *11111*              *************       \n"
    # "***************       *11111*                                  \n"
    # "     ---               *1111**                                 \n"
    # "   / o o \\              *1111****   *****                      \n"
    # "   \\   > /               **111111***111*                       \n"
    # "    -----                  ***********    dce.hust.edu.vn      \n"           
    M:.asciiz "\n\n\n=============================MENU===========================\n|1. Hien thi hinh anh tren giao dien                       |\n|2. Hien thi hinh anh chi con lai vien, khong co mau o giua|\n|3. Hien thi hinh anh sau khi hoan doi vi tri              |\n|4. Nhap tu ban phim ki tu mau cho chu D, C, E roi hien thi|\n|(Nhap exit de thoat chuong trinh)                         |\n============================================================\n\n\n"
    Mess: .asciiz "\nNhap 3 ky tu tuong ung voi 3 mau moi lan luot cua D,C,E\n\n\n"
################################### Su dung lai code bai 2 Tuan 10(2) De tao Menu ###################################################
.eqv KEY_CODE 0xFFFF0004 # ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 # =1 if has a new keycode ?
 # Auto clear after lw
.eqv DISPLAY_CODE 0xFFFF000C # ASCII code to show, 1 byte
.eqv DISPLAY_READY 0xFFFF0008 # =1 if the display has already to do
 # Auto clear after sw
.text
 li $k0, KEY_CODE
 li $k1, KEY_READY
 
 li $s0, DISPLAY_CODE
 li $s1, DISPLAY_READY
#4 ky tu gan nhat
     li $s2, 0
     li $s3, 0
     li $s4, 0
     li $s5, 0
Menu:
    li $v0, 4
    la $a0, M
    syscall
loop: nop
WaitForKey: lw $t1, 0($k1) # $t1 = [$k1] = KEY_READY
 beq $t1, $zero, WaitForKey # if $t1 == 0 then Polling
ReadKey: lw $t0, 0($k0) # $t0 = [$k0] = KEY_CODE
WaitForDis: lw $t2, 0($s1) # $t2 = [$s1] = DISPLAY_READY
 beq $t2, $zero, WaitForDis # if $t2 == 0 then Polling 
#Luu 4 ky tu gan nhat
    addi $s5, $s4, 0
    addi $s4, $s3, 0
    addi $s3, $s2, 0
    addi $s2, $t0, 0
#Thoat chuong trinh khi 4 ky tu tao thanh chu exit
    bne $s5, 101, Encrypt
    bne $s4, 120, Encrypt
    bne $s3, 105, Encrypt
    bne $s2, 116, Encrypt
    j exit
 
Encrypt: 
    beq $t0, 49, f1
    beq $t0, 50, f2
    beq $t0, 51, f3
    beq $t0, 52, f4
    j ShowKey
    
ShowKey: 
    sw $t0, 0($s0) # show key
     nop 
    j loop
################################### Chuc nang so 1 ###################################################
f1:
    li $v0, 4
    la $a0, String
    syscall
    j Menu
################################### Chuc nang so 2 ###################################################
f2:    
    addi $s6, $zero, 0
    la $s7, String        # $s7 la dia chi cua String
loop_f2:
    beq $s6, 1024, Menu      # In ra toan bo 1024 ky tu
    lb $t3, 0($s7)        # $t3 luu gia tri cua tung phan tu trong String
    
    bge $t3, 58, print_f2     # Tu (0-9) trong bang ma ascii tu 48-58
    bge $t3, 48, Chuso_f2
    j print_f2    
Chuso_f2:
    addi $t3, $zero, 32     # space trong ascii la 32
print_f2:     
    li $v0, 11         # In tung ki tu
    addi $a0, $t3, 0
    syscall
    
    addi $s6, $s6, 1    # s6 += 1
    addi $s7, $s7, 1    # s7 += 1
    j loop_f2    
################################### Chuc nang so 3 ###################################################
f3:
    # (21+21+21+1)x16
    # DCE -> ECD
    # [ (+42) In 21 -> (-42) In 21 -> (-42) In 21 -> (+42) In 1 ] x 16
    addi $s6, $zero, 0
    la $s7, String        # $s7 la dia chi cua String

loop_f3:
    beq $s6, 16, Menu
    addi $s6, $s6, 1
    # (+42) In 21
    addi $s7, $s7, 42
    jal in_21
    # (-42) In 21
    addi $s7, $s7, -42
    jal in_21
    # (-42) In 21
    addi $s7, $s7, -42
    jal in_21
    # (+42) In 1    
    addi $s7, $s7, +42
        lb $t3, 0($s7)        # $t3 luu gia tri cua tung phan tu trong String
        li $v0, 11         # In tung ki tu
        addi $a0, $t3, 0
        syscall
        addi $s7, $s7, 1    # s7 += 1        
    j loop_f3
    
#In 21
in_21:
    addi $t4, $zero, 0
    loop_2_f3:
        lb $t3, 0($s7)        # $t3 luu gia tri cua tung phan tu trong String
        li $v0, 11         # In tung ki tu
        addi $a0, $t3, 0
        syscall
            
        addi $s7, $s7, 1    # s7 += 1
        addi $t4, $t4, 1    # t4 += 1
        bne $t4, 21, loop_2_f3
    jr $ra
        

################################### Chuc nang so 4 ###################################################
f4:
    li $v0, 4
    la $a0, Mess
    syscall
    
    la $s7, String        # $s7 la dia chi cua String
    addi $t5, $t5, 0
    loop_input_f4:
    #loop: 
        nop
        WaitForKey2: lw $t1, 0($k1) # $t1 = [$k1] = KEY_READY
        beq $t1, $zero, WaitForKey2 # if $t1 == 0 then Polling
        ReadKey2: lw $t0, 0($k0) # $t0 = [$k0] = KEY_CODE
        WaitForDis2: lw $t2, 0($s1) # $t2 = [$s1] = DISPLAY_READY
        beq $t2, $zero, WaitForDis2 # if $t2 == 0 then Polling 
        #Luu 4 ky tu gan nhat
        addi $s5, $s4, 0
        addi $s4, $s3, 0
        addi $s3, $s2, 0
        addi $s2, $t0, 0
    
        addi $t5, $t5, 1    # t5 += 1
        bne $t5, 3, loop_input_f4
    
    addi $t6, $t6, 0
    loop_print_f4:
        addi $t7, $s4, 0    # Mau cua chu D
        jal in_21_f4
        addi $t7, $s3, 0    # Mau cua chu C
        jal in_21_f4
        addi $t7, $s2, 0    # Mau cua chu E
        jal in_21_f4
        # In \n
        lb $t3, 0($s7)        # $t3 luu gia tri cua tung phan tu trong String
        li $v0, 11         # In tung ki tu
        addi $a0, $t3, 0
        syscall
        addi $s7, $s7, 1    # s7 += 1
        
        addi $t6, $t6, 1    # t6 += 1
        bne $t6, 16, loop_print_f4
        
    #FREE
    li $s2, 0
     li $s3, 0
     li $s4, 0
     li $s5, 0
     li $t0, 0
    j Menu    
    
    
    in_21_f4:
        addi $t4, $zero, 0
        loop_2_f4:
            lb $t3, 0($s7)        # $t3 luu gia tri cua tung phan tu trong String

            bge $t3, 58, print_f4     # Tu (0-9) trong bang ma ascii tu 48-58
            bge $t3, 48, Chuso_f4
            j print_f4    
        Chuso_f4:
            addi $t3, $t7, 0     # Mau tuong ung
        print_f4:
            li $v0, 11         # In tung ki tu
            addi $a0, $t3, 0
            syscall
            
            addi $s7, $s7, 1    # s7 += 1
            addi $t4, $t4, 1    # t4 += 1
            bne $t4, 21, loop_2_f4
        jr $ra
    
exit:
