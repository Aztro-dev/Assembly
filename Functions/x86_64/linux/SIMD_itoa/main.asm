%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1

section .bss
output_buffer resq 4

section .rodata
; a / 10 = (a * 0xCCCCCCCD) >> 35
magic10    dq 0xCCCCCCCD, 0xCCCCCCCD, 0xCCCCCCCD, 0xCCCCCCCD
shift_amt  dq 35, 35, 35, 35

ascii_zero dd 0x30303030, 0x30303030

section .text
; input num1 in rdi
; input num2 in rsi
; input num3 in rdx
; input num4 in rcx
; output string in rax
; output length in rdi
avx2_int32_itoa:
    ; move from general purpose registers to ymm register
    movq xmm0, rdi ; num1
    movq xmm1, rdx ; num3
    pinsrq xmm0, rsi, 1 ; num2
    pinsrq xmm1, rcx, 1 ; num4
    vinserti128 ymm0, ymm0, ymm1, 1

    vpaddq ymm0, ymm0, [ascii_zero]
    
    ; For division by 10
    vmovdqu ymm15, [magic10]
    vmovdqu ymm14, [shift_amt]

    mov rax, output_buffer
    ret
