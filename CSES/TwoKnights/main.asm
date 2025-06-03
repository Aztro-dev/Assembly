%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define INPUT_BUF_SIZE 6
%define OUTPUT_BUF_SIZE 200_000

section .bss
input_buffer resb INPUT_BUF_SIZE
output_buffer resb OUTPUT_BUF_SIZE

section .text
solve:
    call atoi
    mov r15, rax
    mov r14, 0x1
    .loop:
        cmp r14, r15
        jg .exit_loop
        xor rdx, rdx
        mov rax, r14
        mul rax ; rdx:rax = k * k
        mov rbx, rax
        dec rbx ; rbx = k * k - 1
        mul rbx ; rdx:rax = k * k * (k * k - 1)
        shr rax, 0x1 ; divide by 2
        mov rcx, rax ; store this value

        xor rdx, rdx
        mov rax, r14
        dec rax ; k - 1
        mov rbx, r14
        sub rbx, 0x2 ; k - 2
        mul rbx ; rdx:rax = (k - 1) * (k - 2)
        shl rax, 0x2 ; multiply by 4

        sub rcx, rax
        mov rax, rcx
        call write_uint64
        call write_newline

        inc r14

        jmp .loop
    .exit_loop:
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

    ; Length of output buffer
    xor r11, r11

    call solve

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
