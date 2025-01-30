.set INPUT_PIN,         468
.set LOOP_ITERATIONS,   10 
.set DELAY_TIME,        500 # in msecs

.set SYS_OPEN_AT,   56
.set SYS_CLOSE,     57
.set SYS_READ,      63
.set SYS_NANOSLEEP, 101

.set O_RDONLY, 0b00
.set O_WRONLY, 0b01
.set O_RDWR,   0b10

.set STDIN,  0
.set STDOUT, 1
.set STDERR, 2

.section .text
.globl _start
_start:
    jal ra, gpio

    # a0 has exit status from gpio
    addi a7, zero, 93 # _NR_sys_exit
    ecall # invoke system call

.loop:
    j .loop # in case exit syscall fails ...

gpio:
    addi s7, zero, -1 # for error checking

    addi a7, zero, SYS_OPEN_AT
    lui a1, %hi(export_path)
    addi a1, a1, %lo(export_path)
    addi a2, zero, O_WRONLY # umode_t

    ecall # call OPEN_AT syscall

    beq a0, s7, gpio.error

    add s0, zero, a0 # store file descriptor

    addi a7, zero, SYS_WRITE
    # a0 = file descriptor
    lui a1, %hi(export_pin_str)
    addi a1, a1, %lo(export_pin_str)
    addi a2, zero, %lo(export_pin_str_size)

    ecall

    beq a0, s7, gpio.error

    addi a7, zero, SYS_CLOSE
    add a0, zero, s0

    ecall

    beq a0, s7, gpio.error

    addi a7, zero, SYS_OPEN_AT
    lui a1, %hi(direction_path)
    addi a1, a1, %lo(direction_path)
    addi a2, zero, O_WRONLY # umode_t

    ecall # call OPEN_AT syscall

    beq a0, s7, gpio.error

    add s0, zero, a0 # store file descriptor

    addi a7, zero, SYS_WRITE
    # a0 = file descriptor
    lui a1, %hi(direction_str)
    addi a1, a1, %lo(direction_str)
    addi a2, zero, %lo(direction_str_size)

    ecall

    beq a0, s7, gpio.error

    addi a7, zero, SYS_CLOSE
    add a0, zero, s0

    ecall

    beq a0, s7, gpio.error

    addi a7, zero, SYS_OPEN_AT
    lui a1, %hi(value_path)
    addi a1, a1, %lo(value_path)
    addi a2, zero, O_RDONLY # umode_t

    ecall # call OPEN_AT syscall

    beq a0, s7, gpio.error

    add s0, zero, a0 # store file descriptor

    addi s1, zero, 0 # iterator
    addi s2, zero, LOOP_ITERATIONS

    gpio.loop:
    bge s1, s2, gpio.exit_loop
    addi s1, s1, 1

    lui a1, %hi(value_str)
    addi a1, a1, %lo(value_str)

    lb t0, 0(a1)

    xori t0, t0, 1 # toggle

    sb t0, 0(a1)

    addi a7, zero, SYS_WRITE
    add a0, zero, s0 # file descriptor
    lui a1, %hi(value_str)
    addi a1, a1, %lo(value_str)
    addi a2, zero, %lo(value_str_size)

    ecall

    beq a0, s7, gpio.error

    addi sp, sp, -16  # allocate 16 bytes on stack
    sw   ra, 12(sp)   # store return address on stack

    addi a0, zero, DELAY_TIME
    jal ra, nanosleep

    lw   ra, 12(sp)  # load return address from stack
    addi sp, sp, 16  # restore stack pointer

    j gpio.loop

    gpio.exit_loop:

    addi a7, zero, SYS_CLOSE
    add a0, zero, s0

    addi a7, zero, SYS_OPEN_AT
    lui a1, %hi(unexport_path)
    addi a1, a1, %lo(unexport_path)
    addi a2, zero, O_WRONLY # umode_t

    ecall # call OPEN_AT syscall

    beq a0, s7, gpio.error

    add s0, zero, a0 # store file descriptor

    addi a7, zero, SYS_WRITE
    # a0 = file descriptor
    lui a1, %hi(unexport_pin_str)
    addi a1, a1, %lo(unexport_pin_str)
    addi a2, zero, %lo(unexport_pin_str_size)

    ecall

    beq a0, s7, gpio.error

    addi a7, zero, SYS_CLOSE
    add a0, zero, s0

    add a0, zero, zero
    jalr zero, ra, 0 # return

    gpio.error:
    addi a0, zero, -1
    jalr zero, ra, 0 # return

nanosleep:
    addi t0, zero, 1000 # for division (msec / 1000)
    # for division (msec / 1000) * 1000000
    lui t1, %hi(1000000)
    addi t1, t1, %lo(1000000)

    add t2, zero, a0 # msec

    divu t3, t2, t0 # t3 = sec
    
    remu t4, t2, t0 # t4 = msec % 1000
    mul t4, t4, t1 # t4 = t4 * 1000000

    lui t5, %hi(ts)
    addi t5, t5, %lo(ts)

    sd t3, 0(t5) # timespec.tv_sec = t3 (aka sec)
    
    lui t5, %hi(ts + 8)
    addi t5, t5, %lo(ts + 8)

    sd t4, 0(t5) # timespec.tv_nsec = t4 (aka nsec)

    nanosleep.loop:
        addi a7, zero, SYS_NANOSLEEP
        lui a0, %hi(ts)
        addi a0, a0, %lo(ts)
        add a1, zero, a0
        ecall # a0 = res

        beq a0, zero, nanosleep.exit_loop

        j nanosleep.loop

    nanosleep.exit_loop:

    jalr zero, ra, 0 # return

.section .data
.align 8
export_path: .asciz "/sys/class/gpio/export"
export_pin_str: .ascii "468"
export_pin_str_size = . - export_pin_str

direction_path: .asciz "/sys/class/gpio/gpio468/direction"
direction_str: .ascii "out"
direction_str_size = . - direction_str

value_path: .asciz "/sys/class/gpio/gpio468/value"
value_str: .ascii "0"
value_str_size = . - value_str

unexport_path: .asciz "/sys/class/gpio/unexport"
unexport_pin_str: .ascii "468"
unexport_pin_str_size = . - unexport_pin_str

.struct 0
timespec:
timespec.tv_sec:
.space 8
timespec.tv_nsec:
.space 8
timespec.size = . - timespec

.section .bss
ts: .space(timespec.size)
