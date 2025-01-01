.section .text
.globl _start
_start:
    addi a0, zero, 0 # STDIN

    lui  a1, %hi(msg)
    addi a1, a1, %lo(msg)

    addi a2, zero, 100 # max buffer size
    addi a7, zero, 63 # _NR_sys_read
    ecall # invoke system call

    add a2, zero, a0 # bytes to print = bytes inputted

    addi a0, zero, 1 # STDOUT

    lui  a1, %hi(msg)
    addi a1, a1, %lo(msg)

    addi a7, zero, 64 # _NR_sys_write
    ecall # invoke system call

    addi a0, zero, 0 # exit status
    addi a7, zero, 93 # _NR_sys_exit
    ecall # invoke system call

.loop:
    j .loop # in case exit syscall fails ...

.section .data
# 100 bytes initialized to 0
msg: .fill 100, 1, 0
