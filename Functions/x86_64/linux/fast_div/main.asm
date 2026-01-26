%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1

section .bss
output: resb 20 ; output for printing

section .text
global _start
_start:
    call fast_div
    call write_uint64

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, output
    mov rdx, 20
    syscall

global  fast_div
; Divide by 101 fast
fast_div:
	;   shift = width + floor(log_2(divisor))
	;   shift = 32 + floor(log_2(101))
	;   shift = 38
	;   magic = ceil(2^s / divisor)
	;   magic = ceil(2^38 / 101)
	;   magic = ceil(2721563435.089109)
	;   magic = 2721563436
	mov rax, 0xA237C32C
	mov rdi, 12345678 ; dummy number
	; n / d approx = n * magic / 2^s
	mul rdi
	shr rax, 38
	ret

write_uint64:
    mov r9, output
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
    mov rsp, rbp
    ret
