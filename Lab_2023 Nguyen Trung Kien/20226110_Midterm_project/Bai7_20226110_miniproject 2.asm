.data
array_1:    .space 120           # Khởi tạo không gian cho 30 số nguyên (120 bytes)
newline:    .asciiz "\n"                     # Chuỗi chứa ký tự xuống dòng
cmd1:       .asciiz "Nhap so luong phan tu n (n<=30) cua day :  "  # Chuỗi nhắc nhập số lượng phần tử n
cmd2:       .asciiz "Nhap so thu "           # Chuỗi nhắc nhập giá trị cho phần tử thứ n
cmd3:       .asciiz ": "                     # Chuỗi kết thúc nhắc nhập, theo sau số thứ tự
cmd4:       .asciiz "Loi dau vao: Vuot qua kich thuoc mang"            # Chuỗi thông báo lỗi khi nhập sai
n:          .word 0                          # Biến lưu trữ số lượng phần tử n
space:      .asciiz " "                      # Chuỗi chứa ký tự khoảng trắng dùng để in giá trị

.text
main:
    # Yêu cầu người dùng nhập số lượng phần tử n, không quá 30
    li $v0, 4
    la $a0, cmd1
    syscall

    # Đọc giá trị n từ bàn phím 
    li $v0, 5
    syscall

    # Kiểm tra nếu n > 30 thì báo lỗi
    bgt $v0, 30, warning

    # Lưu giá trị n vừa nhập vào biến n
    sw $v0, n

    # Khởi tạo các biến để nhập các phần tử của mảng
    move $t2, $v0                 # $t2 lưu giá trị n
    addi $t2, $t2, 1              # $t2 = n + 1 để sử dụng trong điều kiện vòng lặp
    li $t1, 1                     # $t1 là biến đếm, bắt đầu từ 1
    li $t0, 0                     # $t0 là chỉ số mảng, bắt đầu từ 0

while_input:
    # Lặp cho đến khi nhập đủ n phần tử
    beq $t1, $t2, sorting          # Kiểm tra điều kiện thoát khỏi vòng lặp
    li $v0, 4                    # In ra "Nhap so thu"
    la $a0, cmd2                  
    syscall

    li $v0, 1                    # In chỉ số phần tử
    move $a0, $t1
    syscall

    li $v0, 4                    # In ra ": "
    la $a0, cmd3
    syscall

    li $v0, 5                    # Đọc giá trị nhập vào
    syscall

    sw $v0, array_1($t0)         # Lưu giá trị từ $s0 vào mảng tại địa chỉ $t0
    addi $t0, $t0, 4             # Di chuyển đến vị trí tiếp theo trong mảng
    addi $t1, $t1, 1             # Tăng chỉ số phần tử
    j while_input                      # Lặp lại

sorting:
    # Sắp xếp mảng (Thuật toán thao tác với 2 con trỏ (cụ thể trong báo cáo) để sắp xếp số dương và giữ nguyên vị trí số âm)
    lw $t2, n                   # Lấy số phần tử là n
    mul $t2, $t2, 4             # Đổi n thành byte
    li $t1, 0                   # Khởi tạo biến đếm cho vòng lặp ngoài

loop1:
    beq $t1, $t2, print         # Kiểm tra điều kiện thoát vòng lặp ngoài
    add $t3, $t1, 4             # Khởi tạo biến đếm cho vòng lặp trong

loop2:
    beq $t3, $t2, inci          # Kiểm tra điều kiện thoát vòng lặp trong
    lw $s0, array_1($t3)        # Lấy giá trị phần tử kế tiếp
    lw $s1, array_1($t1)        # Lấy giá trị phần tử hiện tại
    ble $s0, $s1, checking_1        # So sánh và nhảy nếu thứ tự đúng
    j skip

checking_1:
    bgt $s0, 0, checking_2          # Kiểm tra nếu số dương
    j skip

checking_2:
    bgt $s1, 0, swaping            # Kiểm tra nếu số dương, nhảy đến đổi chỗ
    j skip

swaping:
    sw $s0, array_1($t1)        # Đổi chỗ hai phần tử
    sw $s1, array_1($t3)        

skip:
    addi $t3, $t3, 4            # Tăng chỉ số biến đếm trong
    j loop2                     # Tiếp tục vòng lặp trong

inci:
    addi $t1, $t1, 4            # Tăng chỉ số biến đếm ngoài
    j loop1                      # Tiếp tục vòng lặp ngoài

print:
    # In mảng đã sắp xếp
    li $t0, 0
    li $t1, 0
    lw $t2, n

print_loop:
    beq $t1, $t2, end_program          # Kiểm tra nếu đã in hết mảng thì thoát
    li $v0, 1
    lw $a0, array_1($t0)        # Lấy giá trị từ mảng tại vị trí $t0
    syscall                     # In giá trị phần tử
    li $v0, 4
    la $a0, space
    syscall                     # In một khoảng trắng
    addi $t0, $t0, 4            # Chuyển đến phần tử tiếp theo trong mảng
    addi $t1, $t1, 1            # Tăng bộ đếm
    j print_loop                # Lặp lại cho đến khi in hết mảng

warning:
    # Xuất thông báo lỗi nếu n > 30
    li $v0, 4
    la $a0, cmd4
    syscall

end_program:
    # Kết thúc chương trình
    li $v0, 10
    syscall
