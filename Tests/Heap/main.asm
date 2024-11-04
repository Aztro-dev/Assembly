%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_BRK 12
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define BUF_SIZE 2000

section .bss
input_buffer resb BUF_SIZE
output_buffer resb BUF_SIZE
struc node
    data resq 1
    parent resq 1
    left resq 1
    right resq 1
endstruc

heap resq 1
input_array resq 1
heap_len resq 1

section .text
solve:
    call atoi
    mov qword[heap_len], rax

    mov rdi, rax
    call malloc

    mov qword[heap], rax
    mov r14, qword[heap]
    xor r13, r13
    mov r12, qword[heap_len]
    .loop:
        cmp r13, r12
        jge .exit_loop
        call atoi
        
        mov qword[r14 + 8 * r13], rax
        
        inc r13
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
    mov rdx, BUF_SIZE
    syscall

    call solve

    call output_heap

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

write_newline:
    mov byte [r9], 0x0a
    inc r9
    inc r11
    ret
    
output_heap:
    mov rbx, 0x0
    mov r15, qword[heap_len]
    mov r14, qword[heap]
    .loop:
        cmp rbx, r15
        jge .exit
        mov rax, qword[r14 + 8 * rbx]
        call write_uint64
        inc rbx
        jmp .loop
    .exit:
    call write_newline
    ret
    
malloc:
    push rdi
    mov rax, SYS_BRK
    xor rdi, rdi
    syscall

    pop rdi
    push rax

    shl rdi, 3 ; times 8 bytes (sizeof qword)
    add rdi, rax
    mov rax, SYS_BRK
    syscall

    pop rax
    ret
