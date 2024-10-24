%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define BUF_SIZE 20000000

section .rodata
no_solution db "NO SOLUTION", 0x0a
no_solution_len equ $ - no_solution
four db "2 4 1 3", 0x0a
four_len equ $ - four

section .bss
input_buffer resb 20
output_buffer resb BUF_SIZE

section .text
solve:
    cmp rax, 1
    jne .skip_one
    call write_uint64
    ret
    .skip_one:
    cmp rax, 4
    jge .skip_no_solution
    call write_no_solution
    .skip_no_solution:

    cmp rax, 4
    jne .skip_four
    call write_four
    .skip_four:

    ; temp_n = n - n & 1
    mov rbx, rax
    and al, 0xFE

    .even_loop:
        cmp rax, 0x0
        jle .exit_even_loop
        call write_uint64
        sub rax, 0x2
        jmp .even_loop

    .exit_even_loop:
    mov rax, rbx
    ; Closest but highest odd number
    dec rax
    or rax, 1

    .odd_loop:
        cmp rax, 0x0
        jle .exit_odd_loop
        call write_uint64
        sub rax, 0x2
        jmp .odd_loop
    .exit_odd_loop:
    ret

global _start
_start:
    mov r8, input_buffer
    mov r9, output_buffer
    
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, r8
    mov rdx, 20
    syscall

    call atoi

    ; Length of output
    xor r11, r11
    
    call solve

    call write_newline

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, output_buffer
    mov rdx, r11
    syscall

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
    lea rax, [rax + rax * 4 -48]        
    ; rax += character
    add rax, rcx

    jmp .loop
    .end:
    ret
write_uint64:
    push rax
    push rbp

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

    ; Increase length of output by number of bytes
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
    
    pop rbp
    pop rax
    ret

write_newline:
    mov byte [r9], 0x0a
    inc r9
    inc r11
    ret

write_no_solution:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, no_solution
    mov rdx, no_solution_len
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret
    
write_four:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, four
    mov rdx, four_len
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret
