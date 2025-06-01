%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1

%define NUMBERS_LEN 65536

section .bss
numbers resd 4 * NUMBERS_LEN

section .data
output_buffer times(20) db '0'

section .text
; input nums in rdi
; output num in rax
avx2_uint32_max:
    vmovdqu ymm0, [rdi]
    mov rcx, 0x0
    .loop:
        cmp rcx, NUMBERS_LEN
        jge .exit_loop
        vpmaxud ymm0, [rdi + rcx * 4]
        inc rcx
        jmp .loop

    mov rax, 0x1
    ret

global _start
_start:
    call generate_rand

    mov rdi, numbers
    call avx2_uint32_max

    mov rdi, rax
    call print_uint64

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret

generate_rand:
    lea rax, [numbers + 4 * NUMBERS_LEN - 4]
    .loop:
        cmp rax, numbers
        jl .exit_loop
        rdrand ebx
        mov dword[rax], ebx
        sub rax, 0x4
        jmp .loop
    .exit_loop:
    ret

print_uint64:
	push rax
	push rsi
	push rdx
	mov  r8, 10; Base 10

	mov rax, rdi
	mov rsi, output_buffer
	add rsi, 19; Last digit of buffer
	mov r9, 0x0; Size

.loop:
	cmp rax, 0x0
	jle .exit_loop
	xor rdx, rdx
	div r8
	add dl, 48; To ASCII num
	mov byte [rsi], dl
	dec rsi
	inc r9
	jmp .loop

.exit_loop:
	mov rax, SYS_WRITE
	mov rdi, STDIN
	lea rsi, [output_buffer + 20]
	sub rsi, r9
	mov rdx, r9
	syscall

	pop rdx
	pop rsi
	pop rax

	ret
