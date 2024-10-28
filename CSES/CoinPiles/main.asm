%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define BUF_SIZE 1000000

section .bss
input_buffer resb BUF_SIZE
output_buffer resb BUF_SIZE

section .text
solve:
    call atoi
    mov r15, rax ; counter for test cases
    mov r12, 0x3 ; for remainder of 3
    .test_case_loop:
        cmp r15, 0x0
        jle .exit_test_case_loop
        dec r15

        call atoi
        mov rbx, rax
        call atoi

        ; if a * 2 < b, then no
        shl rax, 1
        cmp rax, rbx
        jl .no
        
        ; if b * 2 < a, then no 
        shr rax, 1
        shl rbx, 1
        cmp rbx, rax
        jl .no

        shr rbx, 1

        ; if (a + b) % 3 != 0, then no
        mov r13, rax
        xor rdx, rdx
        add rax, rbx
        div r12
        test rdx, rdx
        jnz .no

        .yes:
        mov qword[r9], 0x0a534559 ; "YES\n"
        add r9, 4
        add r11, 4
        jmp .continue

        .no:
        call write_uint64
        mov rax, rbx
        call write_uint64

        mov qword[r9], 0x0a4f4e ; "NO\n"
        add r9, 3
        add r11, 3

        .continue:

        jmp .test_case_loop
    .exit_test_case_loop:
    ret

global _start
_start:
    mov r8, input_buffer
    mov r9, output_buffer
    
    mov rax, SYS_READ
    mov rdi, STDIN
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

    ; Add bytes created to r11 (length of output buffer)
    add r11, rbp
    sub r11, rsp

    test rax, rax
    jnz .div ; keep pushing to stack for rest of number

    ; copy stack string to buffer
    ; we do this to not have to keep track
    ; of the current position in the buffer
    .loop:
    mov cl, byte [rsp]
    inc rsp

    mov byte [r9], cl
    inc r9

    inc r11

    cmp rsp, rbp
    jl .loop

    mov byte[r9], 0x20 ; space
    inc r9

    pop rdx
    pop rcx
    pop rbp
    pop rax
    ret
