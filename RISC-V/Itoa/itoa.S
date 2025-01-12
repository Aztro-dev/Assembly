.section .text
.globl _start
_start:
    # 0xBC614E = 12345678
    lui a0, 0xBC6
    addi a0, a0, 0x14E
    
    lui  a1, %hi(number_buffer)
    addi a1, a1, %lo(number_buffer)

    jal itoa

    add a2, zero, a0 # length of the number in ASCII

    addi a0, zero, 1 # STDOUT

    addi a7, zero, 64 # _NR_sys_write
    ecall # invoke system call

    addi a0, zero, 0 # exit status
    addi a7, zero, 93 # _NR_sys_exit
    ecall # invoke system call

.loop:
    j .loop # in case exit syscall fails ...

itoa:
    add t0, zero, a0 # t0 = a0
    addi t1, zero, 10 # t1 = 10 (for divisions)

    addi a1, a1, 20 # a1 = number_buffer + number_buffer_len
    add t3, zero, a1 # t3 = pointer

    addi t2, zero, 0x0a # newline
    sb t2, 0(t3)

    addi t3, t3, -1

    .itoa_loop:
        beq t0, zero, .exit_itoa_loop

        remu t2, t0, t1 # t2 = t0 % 10

        addi t2, t2, 48 # t2 = t2 + '0'
        
        sb t2, 0(t3) # a1[index] = t2

        divu t0, t0, t1 # t0 /= 10
        addi t3, t3, -1
        j .itoa_loop

    .exit_itoa_loop:
    # a0 = a1 - t3 + 1. This effectively returns the size of the string
    sub a0, a1, t3
    addi a0, a0, 1

    add a1, zero, t3
    jalr zero, ra, 0 # return

.section .data
# 20 bytes initialized to 0
number_buffer: .fill 20, 1, 0
