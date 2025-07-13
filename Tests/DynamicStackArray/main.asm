%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

section .rodata
size_prompt db "Size of the array?", 0x0a, 0x0
size_prompt_len equ $ - size_prompt

section .bss
input_buffer resb 20
output_buffer resb 20

section .text
global _start
_start:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, size_prompt
    mov rdx, size_prompt_len
    syscall
    
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, input_buffer
    mov rdx, 20
    syscall

    call atoi

    mov r15, rax ; store size
    sal rax, 2 ; multiply by 4 for the size of a dword (bytes)
    sub rsp, rax
    
    xor r14, r14
    .print_loop:
        cmp r14, r15
        jge .exit_print_loop
        mov eax, [rsp + 4 * r14] ; dword = 4 bytes
        call write_uint64

        inc r14
        jmp .print_loop
    .exit_print_loop:

    mov rax, r15
    sal rax, 2
    add rsp, rax

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret

atoi:
    mov r8, input_buffer
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
    mov r9, output_buffer
    xor r11, r11
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

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, output_buffer
    mov rdx, r11
    syscall

    mov qword[output_buffer], 0x0
    mov qword[output_buffer + 0x8], 0x0
    mov qword[output_buffer + 0x10], 0x0
    mov qword[output_buffer + 0x18], 0x0
    ret
