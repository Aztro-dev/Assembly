%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60
 
%define STDIN 0
%define STDOUT 1
 
%define BUF_SIZE 2000000
 
section .bss
input_buffer resb BUF_SIZE
output_buffer resb BUF_SIZE
 
section .text
solve:
    call atoi
    ; rax = n
    mov rcx, rax
    ; Sum of all natural numbers up to n: n(n + 1) / 2
    mov r10, rax
    inc r10
    mul r10
    shr rax, 1
    mov rdx, rax
    .loop:
        cmp rcx, 0x1
        jle .exit_loop
        dec rcx
        call atoi
        sub rdx, rax
        jmp .loop
    .exit_loop:
    mov rax, rdx
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
 
    call write_uint64
    xor rdx, rdx
    mov r9, output_buffer
    .loop:
        cmp byte[r9], 0x0
        je .exit_loop
        inc rdx
        inc r9
        jmp .loop
    .exit_loop:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, output_buffer
    syscall
 
    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret
 
atoi:
    push rcx
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
    pop rcx
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
 
    pop rdx
    pop rcx
    pop rbp
    pop rax
    ret
 
write_newline:
    mov byte [r9], 0x0a
    inc r9
    ret
