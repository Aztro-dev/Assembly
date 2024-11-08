section .data
s db "hello", 0x0
s_len equ $ - s

section .text

; scoreOfString(string s)
scoreOfString:
    xor rax, rax
    xor rcx, rcx
    mov r15, s_len
    dec r15
    .loop:
        cmp r15, 0x1
        jl .exit_loop

        mov bl, byte[rdi + r15]
        mov cl, byte[rdi + r15 - 1]
        sub cl, bl
        add rax, rcx

        dec r15
        jmp .loop
    .exit_loop:
    ret

global _start

_start:
    call scoreOfString

    mov rdi, rax
    mov rax, 60
    syscall
