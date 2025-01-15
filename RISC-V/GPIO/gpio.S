.set LED_PIN, 509

.section .text
.globl _start
_start:
    call gpio

    # a0 has exit status from gpio
    addi a7, zero, 93 # _NR_sys_exit
    ecall # invoke system call

.loop:
    j .loop # in case exit syscall fails ...

gpio:
    addi a0, zero, 430 # fsopen

    lui  a1, %hi(gpio_path)
    addi a1, a1, %lo(gpio_path)

    ori a2, a2, 01 # O_WRONLY

    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    add s0, zero, a0 # Store file descriptor

    addi a0, zero, 64 # write
    add a1, zero, s0  # file descriptor

    lui a2, %hi(gpio_pin_str)
    addi a2, a2, %lo(gpio_pin_str)

    addi a3, zero, 4 # Length of gpio_pin_str

    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    addi a0, zero, 57 # close
    add a1, zero, s0
    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    addi a0, zero, 430 # fsopen

    lui a1, %hi(new_gpio_path)
    addi a1, a1, %lo(new_gpio_path)

    ori a2, a2, 01 # O_WRONLY

    addi a3, zero, 33 # new_gpio_path length

    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    add s0, zero, a0 # store file descriptor

    addi a0, zero, 64 # write
    add a1, zero, s0 # file descriptor

    lui a2, %hi(out)
    addi a2, a2, %lo(out)

    addi a3, zero, 3 #out length

    ecall #invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    addi a0, zero, 57 # close
    add a1, zero, s0
    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    addi a0, zero, 430 # fsopen

    lui a1, %hi(value_gpio_path)
    addi a1, a1, %lo(value_gpio_path)

    ori a2, a2, 01 # O_WRONLY

    addi a3, zero, 24 # value length

    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    add s0, zero, a0 # store file descriptor

    addi a0, zero, 64 # write
    add a1, zero, s0 # file descriptor

    lui a2, %hi(one)
    addi a2, a2, %lo(one)

    addi a3, zero, 2 # gpio pin str length

    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    addi a0, zero, 57 # close
    add a1, zero, s0
    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error


    addi a0, zero, 430 # fsopen

    lui a1, %hi(unexport_gpio_path)
    addi a1, a1, %lo(unexport_gpio_path)

    ori a2, a2, 01 # O_WRONLY

    addi a3, zero, 24 # unexport length

    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    add s0, zero, a0 # store file descriptor

    addi a0, zero, 64 # write
    add a1, zero, s0 # file descriptor

    lui a2, %hi(gpio_pin_str)
    addi a2, a2, %lo(gpio_pin_str)

    addi a3, zero, 4 # gpio pin str length

    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    addi a0, zero, 57 # close
    add a1, zero, s0
    ecall # invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    ecall #invoke system call

    addi t0, zero, -1
    beq a0, t0, .error

    add a0, zero, zero
    jalr zero, ra, 0 # return

    .error:
    addi a0, zero, 1
    jalr zero, ra, 0 # return

.section .data
# gpio_path
gpio_path: .asciz "/sys/class/gpio/export"
.fill 256 - 23, 1, 0
gpio_pin_str: .asciz "509"
new_gpio_path: .asciz "/sys/class/gpio/gpio509/direction"
.fill 256 - 34, 1, 0
out: .asciz "out"
unexport_gpio_path: .asciz "/sys/class/gpio/unexport"
.fill 256 - 25, 1, 0
value_gpio_path: .asciz "/sys/class/gpio509/value"
.fill 256 - 25, 1, 0
one: .asciz "0"
