.section .text
.globl _start
_start:
    addi a0, zero, 1 # stdout

    lui  a1, %hi(msg)
    addi a1, a1, %lo(msg)

    addi a2, zero, 12 # string length
    addi a7, zero, 64 # _NR_sys_write
    ecall # invoke system call

    addi a0, zero, 0 # exit status
    addi a7, zero, 93 # _NR_sys_exit
    ecall # invoke system call

.loop:
    j .loop # in case exit syscall fails ...

.section .rodata
msg:
    .ascii "Hello World\n"
