%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_BRK 12
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define BUF_SIZE 200000

section .bss
input_buffer resb BUF_SIZE
output_buffer resb BUF_SIZE

section .text
solve:
    ret

global _start
_start:
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, input_buffer
    mov rdx, BUF_SIZE
    syscall

    call solve

    mov rdi, rax
    call write_uint64

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret

atoi:
    xor rax, rax
    .loop:
    movzx rcx, byte [rdi]
    add rdif 1

    cmp cl, 0x30
    jl .end
    
    ; rax = 10 * rax - '0'
    shl rax, 1		
    lea rax, [rax+rax*4-48]        
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
    add rdx, 0x30

    sub rsp, 1
    mov byte [rsp], dl

    test rax, rax
    jnz .div

    .loop:
    mov cl, byte [rsp]
    add rsp, 1

    mov byte [r9], cl
    add r9, 1

    cmp rsp, rbp
    jl .loop

    mov byte[r9], 0x20
    add r9, 1

    pop rdx
    pop rcx
    pop rbp
    pop rax
    ret

write_newline:
    mov byte [r9], 0x0a
    add r9, 1
    ret
