.section .text
.globl _start
_start:
    lui a0, 0x12345
    addi a0, zero, 0x678

    
    lui  a1, %hi(number_buffer)
    addi a1, a1, %lo(number_buffer)

    addi a0, zero, 1 # STDOUT

    lui  a1, %hi(number_buffer)
    addi a1, a1, %lo(number_buffer)

    addi a7, zero, 64 # _NR_sys_write
    ecall # invoke system call

    addi a0, zero, 0 # exit status
    addi a7, zero, 93 # _NR_sys_exit
    ecall # invoke system call

.loop:
    j .loop # in case exit syscall fails ...

itoa:
    

.section .data
# 20 bytes initialized to 0
number_buffer: .fill 20, 1, 0
