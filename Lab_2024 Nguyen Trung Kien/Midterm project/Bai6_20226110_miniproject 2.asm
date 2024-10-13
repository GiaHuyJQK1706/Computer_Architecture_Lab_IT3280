.data
    array: .space 400       # Khai báo mảng có thể chứa tối đa 100 phần tử số nguyên (400 bytes)
    size_of_array: .word 0     # Biến lưu kích thước của mảng
    newline: .asciiz "\n"   # Chuỗi dùng để xuống dòng mới
    space: .asciiz " "	    # Chuỗi dùng để in dấu cách 
    cmd1:  .asciiz "Nhap so luong phan tu n (n<=100) cua day : "  # Chuỗi nhắc nhập số lượng phần tử n
    cmd2:  .asciiz "Nhap so thu "    # Chuỗi nhắc nhập giá trị cho phần tử thứ n
    cmd3:  .asciiz ": "              # Chuỗi kết thúc nhắc nhập, theo sau số thứ tự
    cmd4:  .asciiz "Tich lon nhat cua mot cap phan tu lien ke la: "   # Chuỗi thông báo kết quả
    cmd5:  .asciiz "Hai phan tu lien ke do la: "              # Chuỗi thông báo kết quả
    cmd6:       .asciiz "Loi dau vao: Vuot qua kich thuoc mang"            # Chuỗi thông báo lỗi khi nhập sai
.text
main:
    # Nhập số lượng phần tử của mảng từ bàn phím
    # Yêu cầu người dùng nhập số lượng phần tử n, không quá 30
    li $v0, 4
    la $a0, cmd1
    syscall
    
    li $v0, 5               # Thiết lập syscall để nhập số nguyên
    syscall                 # Yêu cầu hệ điều hành thực hiện nhập số

    # Kiểm tra nếu n > 100 thì báo lỗi
    bgt $v0, 100, warning

    move $t0, $v0           # Lưu số lượng phần tử vào $t0
    sw $t0, size_of_array      # Lưu kích thước mảng vào biến size_of_array trong bộ nhớ

    # Nhập các phần tử của mảng từ bàn phím
    la $t1, array           # Lấy địa chỉ bắt đầu của mảng
    li $t2, 0               # Khởi tạo biến đếm lặp

input_loop:
    bge $t2, $t0, finding # Kiểm tra nếu đã nhập đủ số phần tử thì chuyển đến phần tính toán
    
    li $v0, 4                    # In ra "Nhap so thu"
    la $a0, cmd2                  
    syscall

    li $v0, 1                    # In chỉ số phần tử
    addi $a0, $t2, 1		
    syscall
    
    li $v0, 4                    # In ra ": "
    la $a0, cmd3
    syscall
    
    li $v0, 5               # Thiết lập syscall để nhập số nguyên
    syscall                 # Yêu cầu hệ điều hành thực hiện nhập số
    sw $v0, ($t1)           # Lưu giá trị nhập vào mảng
    addi $t1, $t1, 4        # Di chuyển con trỏ đến phần tử tiếp theo trong mảng
    addi $t2, $t2, 1        # Tăng biến đếm lặp
    j input_loop            # Quay lại đầu vòng lặp để tiếp tục nhập phần tử tiếp theo

finding:
    lw $t3, size_of_array      # Lấy kích thước của mảng
    addi $t4, $t3, -1       # Thiết lập giới hạn duyệt mảng (kích thước mảng - 1 vì duyệt cặp liên kề)
    la $t6, array           # Lấy địa chỉ bắt đầu của mảng
    li $t2, 0               # Khởi tạo lại biến đếm để duyệt mảng
    li $a1, 0               # Khởi tạo giá trị max_product là 0

finding_loop:
    bge $t2, $t4, print_result # Kiểm tra nếu đã duyệt hết mảng thì chuyển đến in kết quả
    lw $t7, ($t6)              # Load giá trị của phần tử hiện tại vào $t7
    lw $t8, 4($t6)             # Load giá trị của phần tử kế tiếp vào $t8
    mul $t9, $t7, $t8          # Tính tích của hai phần tử liên tiếp
    bgt $t9, $a1, update_max # Nếu tích mới lớn hơn giá trị lớn nhất hiện tại thì cập nhật
    j next_iteration            # Nếu không, chuyển sang lần lặp tiếp theo

update_max:
    move $a2, $t7               # Cập nhật phần tử đầu của cặp có tích lớn nhất
    move $a3, $t8               # Cập nhật phần tử thứ hai của cặp có tích lớn nhất
    move $a1, $t9               # Cập nhật giá trị tích lớn nhất

next_iteration:
    addi $t6, $t6, 4            # Di chuyển con trỏ đến phần tử tiếp theo của mảng
    addi $t2, $t2, 1            # Tăng biến đếm lặp
    j finding_loop            # Quay lại đầu vòng lặp để tiếp tục tính toán

warning:
    # Xuất thông báo lỗi nếu n > 100
    li $v0, 4
    la $a0, cmd6
    syscall
    j end_program
    
print_result:
    li $v0, 4			#In chuỗi thông báo
    la $a0, cmd4
    syscall

    li $v0, 1                   # Thiết lập syscall để in số nguyên
    move $a0, $a1               # Chuyển giá trị tích lớn nhất vào $a0 để in
    syscall                     # In giá trị tích lớn nhất
    
    li $v0, 4                   # Thiết lập syscall để in chuỗi
    la $a0, newline             # Chuẩn bị chuỗi xuống dòng để in
    syscall                     # In xuống dòng
    
    li $v0, 4			#In chuỗi thông báo
    la $a0, cmd5
    syscall
    
    li $v0, 1                   # Thiết lập syscall để in số nguyên
    move $a0, $a2               # Chuyển phần tử đầu tiên của cặp vào $a0 để in
    syscall                     # In phần tử đầu tiên của cặp
    
    li $v0, 4                   # Thiết lập syscall để in chuỗi
    la $a0, space             # Chuẩn bị chuỗi xuống dòng để in
    syscall                     # In xuống dòng
    
    li $v0, 1                   # Thiết lập syscall để in số nguyên
    move $a0, $a3               # Chuyển phần tử thứ hai của cặp vào $a0 để in
    syscall                     # In phần tử thứ hai của cặp

end_program:
    # Kết thúc chương trình
    li $v0, 10
    syscall
