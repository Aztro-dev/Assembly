%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1

section .bss
output_buffer resq 4

section .data
numbers dd 1, 2, 3, 4

section .rodata
to_char dq '0', '0', '0', '0'

section .text
; input nums in ymm0
; output string in rax
; output length in rdi
avx2_int32_itoa:
    ; move dwords in xmm0 to qwords in ymm0
    vpmovzxdq ymm0, xmm0
    vpaddq ymm0, [to_char]
    vmovdqu [output_buffer], ymm0
    mov rax, output_buffer
    mov rdi, 8 * 4 ; 8 bytes in a 64-bit int, 4 of those ints
    ret

global _start
_start:
    vmovdqu xmm0, [numbers]
    call avx2_int32_itoa

    mov rsi, rax
    mov rdx, rdi
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret
