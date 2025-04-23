.set SYS_CLOSE,     57
.set SYS_READ,      63
.set SYS_WRITE,     64
.set SYS_EXIT,      93

.set O_RDONLY, 0b00
.set O_WRONLY, 0b01
.set O_RDWR,   0b10

.set STDIN,  0
.set STDOUT, 1
.set STDERR, 2

.section .text
.globl _start
_start:
    addi a0, zero, STDIN 

    lui  a1, %hi(input)
    addi a1, a1, %lo(input)

    addi a2, zero, 100 # max buffer size
    addi a7, zero, SYS_READ
    ecall # invoke system call

    jal atoi

    addi a0, zero, 0 # exit status
    addi a7, zero, SYS_EXIT # _NR_sys_exit
    ecall # invoke system call

.loop:
    j .loop # in case exit syscall fails ...

atoi:
    # a0 contains bytes to be read
    lui t0, %hi(input)
    addi t0, t0, %lo(input) # pointer

    add t1, t0, a0 # ending memory address

    atoi.loop:
        bge t0, t1, atoi.exit_loop

        lb t2, 0(t0)

        addi t3, zero, 1

        blt t2, t3, atoi.exit_loop

        addi t0, t0, 0x1
        j atoi.loop
    atoi.exit_loop:

    add a2, zero, a0 # bytes to print = bytes inputted

    addi a0, zero, STDOUT

    lui  a1, %hi(input)
    addi a1, a1, %lo(input)

    addi a7, zero, SYS_WRITE # _NR_sys_write
    ecall # invoke system call

    jalr zero, ra, 0 

.section .data
# 100 bytes initialized to 0
input: .fill 100, 1, 0
