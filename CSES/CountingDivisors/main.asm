%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define INPUT_BUF_SIZE 1_000_000
%define OUTPUT_BUF_SIZE 1_000_000

%define MAX_NUM 1_000_001
%define MAX_NUM_SQRT 1_001

section .bss
input_buffer resb INPUT_BUF_SIZE
output_buffer resb OUTPUT_BUF_SIZE
nums resd MAX_NUM

section .text
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

    mov rdi, nums
    mov rax, 0x2 ; fill with 2s
    mov rcx, MAX_NUM ; MAX_NUM times
    rep stosd ; do the filling cuh

    mov dword[nums], 0x0
    mov dword[nums + 4], 0x1

    mov rax, 0x2
    mov rbx, MAX_NUM_SQRT
    .init_loop:
        cmp rax, rbx
        jge .exit_init_loop
        mov rcx, rax
        imul rcx, rcx ; start = i * i
        inc dword[nums + 4 * rcx] ; nums[start]++
        
        add rcx, rax ; int j = start + i
        .inner_init_loop:
        cmp rcx, MAX_NUM ; if (j < MAX_NUM) break;
        jge .exit_inner_init_loop

        add dword[nums + 4 * rcx], 0x2
        
        add rcx, rax ; j += i
        jmp .inner_init_loop
        .exit_inner_init_loop:

        inc rax
        jmp .init_loop
    .exit_init_loop:

    call atoi
    mov r15, rax

    .data_loop:
        cmp r15, 0
        jle .exit_data_loop
        dec r15

        call atoi
        mov eax, dword[nums + 4 * rax]
        call write_uint64
        call write_newline
        jmp .data_loop
    .exit_data_loop:

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
