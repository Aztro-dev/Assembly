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

section .rodata
; For each iteration of the loop, we evaluate at i, then i + 1, then i + 2, and then i + 3.
init_array dq 0x0, 0x1, 0x2, 0x3
; Useful for incrementing/decrementing lel
ones dq 0x1, 0x1, 0x1, 0x1
; For the first iteration skip
consts_1 db "0", 0x0a
consts_2 db "0", 0x0a, "6", 0x0a
consts_3 db "0", 0x0a, "6", 0x0a, "28", 0x0a, 0x0

section .text
write_consts:
    .check_consts_1:
    cmp r13, 0x1
    jne .check_consts_2
    mov ax, word[consts_1]
    mov word[r9], ax
    add r9, 0x2
    add r11, 0x2
    ret
    .check_consts_2:
    cmp r13, 0x2
    jne .check_consts_3
    mov eax, dword[consts_2]
    mov dword[r9], eax
    add r9, 0x4
    add r11, 0x4
    ret
    .check_consts_3:
    cmp r13, 0x3
    jne .exit
    mov rax, qword[consts_3]
    mov qword[r9], rax
    add r9, 0x7
    add r11, 0x7
    .exit:
    ret

solve:
    ; init SIMD registers beforehand
    vmovupd ymm15, [init_array]
    vmovupd ymm14, [ones]

    call atoi
    mov r15, rax
    mov r14, 0x1 ; starting index (k)
    
    ; We need to evaluate 4 ints at a time, so here we make the numbers a multiple of 4
    mov r13, r15
    and r13, 0x3
    call write_consts
    add r14, r13
    
    .loop:
        cmp r14, r15
        jg .exit_loop

        movq xmm0, r14 ; move k into xmm0
        vpbroadcastq ymm0, xmm0 ; "splat" i to all ymm0 slots
        vpaddq ymm0, ymm15 ; ymm0 += [0, 1, 2, 3]

        vpmuldq ymm1, ymm0, ymm0 ; ymm1 = k * k
        vpsubq ymm2, ymm1, ymm14 ; ymm2 = k * k - 1

        ; The lower 128 bits of ymm0 is in xmm0, so we are simply getting those 2 values
        pextrq rax, xmm0, 0
        call write_uint64
        call write_newline
        pextrq rax, xmm0, 1
        call write_uint64
        call write_newline

        ; Get upper 128 bits of ymm0
        vextracti128 xmm0, ymm0, 1
        pextrq rax, xmm0, 0
        call write_uint64
        call write_newline
        pextrq rax, xmm0, 1
        call write_uint64
        call write_newline

        add r14, 0x4
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

section .rodata:
xmm_ones db 1, 1, 1, 1
ymm_ones dq 1, 1, 1, 1
