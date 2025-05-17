%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define BUF_SIZE 50000001

section .bss
input_buffer resb BUF_SIZE
output_buffer resb BUF_SIZE
fd resq 1
temp1 resq 4

section .text
solve:
    call atoi
    mov r15, rax
    mov r14, rax
    mov r13, 0
    mov r12, 0
    .testcases:
        %assign i 0
        %rep 4
            ; rax = x, rbx = y
            call atoi
            cmp rax, 0
            cmove rax, r12
            mov rbx, rax 
            call atoi
            pinsrd xmm0, eax, i
            pinsrd xmm1, ebx, i
        %assign i i+1
        %endrep
        .skip:

        vpmaxud xmm2, xmm0, xmm1 ; xmm2 = max(xmm0, xmm1)
        vmovdqa xmm3, xmm2 ; xmm3 = xmm2

        vpmovzxdq ymm0, xmm0 ; ymm0 = zero-extended xmm0
        vpmovzxdq ymm1, xmm1 ; ymm1 = zero-extended xmm1
        vpmovzxdq ymm2, xmm2 ; ymm2 = zero-extended xmm2
        vpmovzxdq ymm3, xmm3 ; ymm3 = zero-extended xmm3

        vpsubq ymm3, ymm3, ymm15 ; ymm3 -= 1
        vpmuldq ymm3, ymm2, ymm3 ; ymm3 = xmm2 * xmm3 = max * (max - 1)
        vpaddq ymm3, ymm3, ymm15 ; ymm3 += 1

        vpsubq ymm4, ymm0, ymm1 ; ymm4 = x - y
        vpsubq ymm5, ymm1, ymm0 ; ymm5 = y - x
        
        vpand ymm2, ymm15

        vpcmpeqq ymm6, ymm2, ymm15 ; ymm6 = mask: 0xFFFFFFFF where (max & 1 == 1)
        
        vpand ymm4, ymm4, ymm6 ; (x - y) for (max & 1 == 1)
        vpandn ymm5, ymm6, ymm5 ; (y - x) for (max & 1 == 0)
        
        vpor ymm0, ymm4, ymm5 ; final = both x - y and y - x in their correct spots
        vpaddq ymm3, ymm3, ymm0 ; mid += final;
        
        vmovupd [temp1], ymm3
        %assign i 0
        %rep 4
            dec r15
            cmp r15, 0
            jl .exit_testcases
            
            mov rax, qword [temp1 + 8 * i]
            call write_uint64
            call write_newline
        %assign i i+1
        %endrep
    jmp .testcases
    .exit_testcases:
    ret

global _start
_start:
    mov rax, SYS_OPEN
    mov rdi, input
    xor rsi, rsi
    xor rdx, rdx
    syscall
    mov [fd], rax

    mov r8, input_buffer
    mov r9, output_buffer
    
    mov rax, SYS_READ
    mov rdi, [fd]
    mov rsi, r8
    mov rdx, BUF_SIZE
    syscall

    vmovups xmm15, [xmm_ones]
    vmovupd ymm15, [ymm_ones]

    ; Length of output buffer
    xor r11, r11

    call solve

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, output_buffer
    mov rdx, r11
    syscall

    mov rax, SYS_CLOSE
    mov rdi, [fd]
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
input db "input.in", 0x0
xmm_ones db 1, 1, 1, 1
ymm_ones dq 1, 1, 1, 1
