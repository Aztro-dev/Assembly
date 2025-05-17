%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define BUF_SIZE 50000001

section .bss
input_buffer resb BUF_SIZE
output_buffer resb BUF_SIZE
fd resq 1

section .text
solve:
    call atoi
    mov r15, rax
    .testcases:
        cmp r15, 0x0
        jle .exit_testcases
        dec r15

        ; rax = x, rbx = y
        call atoi
        mov rbx, rax 
        call atoi

        cmp rbx, rax
        jg .y_gt_x
            mov r12, rax
            dec rax
            mul rax
            xchg r12, rax
            test rax, 0x1
            jz .x_even
                shl rax, 1
                add r12, rax
                sub r12, rbx
                mov rax, r12
                ; call write_uint64
                ; call write_newline
            jmp .testcases
            .x_even:
                add r12, rbx
                mov rax, r12
                ; call write_uint64
                ; call write_newline
            jmp .testcases
        .y_gt_x:
            mov r12, rax
            mov rax, rbx
            dec rax
            mul rax
            xchg r12, rax
            test rbx, 0x1
            jnz .y_odd
                shl rbx, 1
                add r12, rbx
                sub r12, rax
                mov rax, r12
                ; call write_uint64
                ; call write_newline
            jmp .testcases
            .y_odd:
                add r12, rax
                mov rax, r12
                ; call write_uint64
                ; call write_newline
            jmp .testcases
    .exit_testcases:
    ret

global _start
_start:
    mov rax, SYS_OPEN
    mov rdi, input
    xor rsi, rsi
    xor rdx, rdx
    syscall
    mov [fd], rax
    
    mov r8, input_buffer
    mov r9, output_buffer
    
    mov rax, SYS_READ
    mov rdi, [fd]
    mov rsi, r8
    mov rdx, BUF_SIZE
    syscall

    ; Length of output buffer
    xor r11, r11

    call solve

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, output_buffer
    mov rdx, r11
    syscall

    mov rax, SYS_CLOSE
    mov rdi, [fd]

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret

atoi:
    xor rax, rax
    .loop:
    movzx rcx, byte [r8]
    inc r8

    cmp cl, 0x30
    jl .end
    
    ; rax = 10 * rax - '0'
    shl rax, 1		
    lea rax, [rax + rax * 4 - 48]        
    ; rax += character
    add rax, rcx

    jmp .loop
    .end:
    ret
write_uint64:
    push rax
    push rbp
    push rcx
    push rdx

    mov rcx, 10
    mov rbp, rsp
    .div:
    xor rdx, rdx
    div rcx
    add rdx, 0x30 ; num % 10 + '0'

    dec rsp
    mov byte [rsp], dl ; push character to stack

    test rax, rax
    jnz .div ; keep pushing to stack for rest of number

    ; Add bytes created to r11 (length of output buffer)
    add r11, rbp
    sub r11, rsp

    ; copy stack string to buffer
    ; we do this to not have to keep track
    ; of the current position in the buffer
    .loop:
    mov cl, byte [rsp]
    inc rsp

    mov byte [r9], cl
    inc r9

    cmp rsp, rbp
    jl .loop

    mov byte[r9], 0x20 ; space
    inc r9
    inc r11

    pop rdx
    pop rcx
    pop rbp
    pop rax
    ret

write_newline:
    mov byte [r9], 0x0a
    inc r9
    inc r11
    ret

section .rodata:
input db "input.in"
