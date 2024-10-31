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

struc linked_list
    data resq 1
    next resq 1
endstruc

section .data
list:
    istruc linked_list
        at data, dq -1
        at next, dq 0
    iend

section .text
populate_list:
    mov r15, list
    .loop:
        call atoi
        cmp rax, -1
        je .exit_loop
        
        mov qword[r15 + data], rax

        call malloc
        mov qword[r15 + next], rax
        mov r15, rax

        mov qword[r15 + data], 0
        mov qword[r15 + next], 0 ; nullptr
        jmp .loop
    .exit_loop:
    ret

solve:
    call populate_list
    call print_linked_list

    call malloc
    mov r12, rax ; curr
    mov rbx, qword[list + data]
    mov qword[r12 + data], rbx
    mov rbx, qword[list + next]
    mov qword[r12 + next], rbx

    call malloc
    mov r13, rax ; prev

    mov r14, 0x0 ; next

    .loop:
        cmp qword[r12], 0x0
        je .exit_loop
        
        mov r14, qword[r12 + next] ; next = curr->next
        mov qword[r12 + next], r13 ; curr->next = prev

        mov r13, r12 ; prev = curr
        mov r12, r14 ; curr = next
        jmp .loop
        
    .exit_loop: 
    mov rbx, qword[r13 + data]
    mov qword[list + data], rbx
    
    mov rbx, qword[r13 + next]
    mov qword[list + next], rbx
    
    call print_linked_list
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
    mov r12, r8 ; temp
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
    inc r12
    cmp r12, r8
    jne .return
    mov rax, -1
    .return:
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

malloc:
    mov rax, SYS_BRK
    xor rdi, rdi
    syscall

    push rax

    add rax, 16 ; sizeof linked_list
    mov rdi, rax
    mov rax, SYS_BRK
    syscall

    pop rax
    ret

print_linked_list:
    mov r15, list
    .loop:
        cmp qword[r15 + next], 0x0
        je .exit_loop
        
        mov rax, qword[r15 + data]
        call write_uint64
        mov r15, qword[r15 + next]

        jmp .loop
    .exit_loop:
    call write_newline
    ret
