%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define INPUT_BUF_SIZE 2_000_000
%define OUTPUT_BUF_SIZE 20

section .bss
input_buffer resb INPUT_BUF_SIZE
output_buffer resb OUTPUT_BUF_SIZE
alignb 32
number_buffer resd 200_000

section .text
solve:
    call atoi
    mov r15, rax
    xor r14, r14
    xor r13, r13
    .atoi_loop:
        cmp r14, r15
        jge .exit_atoi_loop
        call atoi
        mov dword[number_buffer + r14 * 4], eax
        add r13, rax ; sum

        inc r14
        jmp .atoi_loop
    .exit_atoi_loop:

    xor r14, r14
    shl r15, 0x2 ; multiply by 4 because there are 4 bytes for every dword
    add r15, 4 * 8 ; in case we do a lil oopsy
    vpxor ymm0, ymm0, ymm0 ; max arr
    .calc_loop:
        cmp r14, r15
        jg .exit_calc_loop 
        vmovdqa ymm1, [number_buffer + r14]
        vpmaxud ymm0, ymm0, ymm1

        ; skip 4 bytes, 8 times
        add r14, 4 * 8
        jmp .calc_loop
    .exit_calc_loop:
    vextracti128 xmm1, ymm0, 1 ; xmm1 = higher 128 bits of ymm0
    ; xmm0 already has the lower 128 bits of ymm0

    vpmaxud xmm0, xmm0, xmm1 ; xmm0 = max (lower 128, higher 128)
    ; leaves 4 values left to combine

    vpshufd xmm1, xmm0, 0b10110001 ; xmm1 = xmm0[0b10, 0b11, 0b00, 0b01] = xmm0[2, 3, 0, 1]
    vpmaxud xmm0, xmm0, xmm1 ; xmm0 = [max (3, 2), max(2, 3), max(1, 0), max(0, 1) ]
    ; leaves 2 values left to combine

    vpshufd xmm1, xmm0, 0b01001110 ; xmm1 = xmm0[0b01, 0b00, 0b11, 0b10] = xmm0[1, 0, 3, 2]
    vpmaxud xmm0, xmm0, xmm1 ; exercise for the reader
    ; max stored in all slots

    movd eax, xmm0
    shl rax, 1 ; multiply by 2
    
    ; sum > max * 2 ?
    cmp r13, rax
    ; sum : max * 2
    cmovg rax, r13
    call write_uint64
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
    lea rax, [rax + rax * 4]
    lea rax, [2 * rax - 48]
    ; rax += character
    add rax, rcx

    jmp .loop
    .end:
    ret
write_uint64:
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
    ret
