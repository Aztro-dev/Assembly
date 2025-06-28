%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define INPUT_BUF_SIZE 6
%define OUTPUT_BUF_SIZE 10_000_000

section .bss
input_buffer resb INPUT_BUF_SIZE
output_buffer resb OUTPUT_BUF_SIZE

section .text
%macro write_uint64 1
    push rbp
    mov rax, %1

    mov rcx, 10
    mov rbp, rsp
    %%div:
    xor rdx, rdx
    div rcx
    add rdx, 0x30 ; num % 10 + '0'

    dec rsp
    mov byte [rsp], dl ; push character to stack

    test rax, rax
    jnz %%div ; keep pushing to stack for rest of number

    ; copy stack string to buffer
    ; we do this to not have to keep track
    ; of the current position in the buffer
    %%loop:
    mov cl, byte [rsp]
    inc rsp

    mov byte [r9], cl
    inc r9

    cmp rsp, rbp
    jl %%loop

    mov byte[r9], 0x20 ; space
    inc r9

    pop rbp
%endmacro

solve:
    call atoi
    write_uint64 rdi
    mov rbx, 0x1 ; for n / 2
    .loop:
        cmp rdi, 0x1
        jle .exit_loop

        lea rsi, [rdi + 2 * rdi + 1]

        test rdi, 0x1
        shrx rdi, rdi, rbx
        cmovnz rdi, rsi

        write_uint64 rdi
        jmp .loop
    .exit_loop:
    dec r9
    ret

global _start
_start:
    mov r8, input_buffer
    mov r9, output_buffer
    
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, r8
    mov rdx, INPUT_BUF_SIZE
    syscall

    call solve

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, output_buffer
    mov rdx, r9
    sub rdx, output_buffer
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret

atoi:
    xor rdi, rdi
    .loop:
    movzx rcx, byte [r8]
    inc r8

    cmp cl, 0x30
    jl .end
    
    ; rax = 10 * rax - '0'
    shl rdi, 1		
    lea rdi, [rdi + rdi * 4 - 48]        
    ; rax += character
    add rdi, rcx

    jmp .loop
    .end:
    ret
