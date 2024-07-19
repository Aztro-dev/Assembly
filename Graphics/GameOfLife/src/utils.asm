; Debug tools

%define SYS_WRITE 0x1
%define STDOUT 0x1

%ifidn  __OUTPUT_FORMAT__, elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif


section .text
extern printf

global print_formatted
; rax = num_args
; rdi = formatted_string
; rsi-r9 = args
; xmm0-xmm7 = args
print_formatted:
	push rbp; creates stack frame

	call  printf

	pop rbp; realigns stack
	ret
	
clear_number_buffer:
	push rsi
	push rcx
	mov  rcx, 20; 20 characters
	mov  rsi, number_buffer

.clear_loop:
	mov byte [rsi], 0x0; Clear byte
	inc rsi
	cmp rcx, 0x0; See if rcx is 0
	je  .exit_loop
	dec rcx
	jmp .clear_loop

.exit_loop:
	pop rcx
	pop rsi
	ret

global print_int
; rdi input
print_int:
	push rax
	push rsi
	push rdx
	mov  r8, 10; Base 10

	mov rax, rdi
	mov rsi, number_buffer
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
	mov rdi, STDOUT
	lea rsi, [number_buffer + 20]
	sub rsi, r9
	mov rdx, r9
	syscall

	call print_newline

	pop rdx
	pop rsi
	pop rdx

	call clear_number_buffer

	ret

global print_newline
print_newline:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, newline
	mov rdx, 0x1
	syscall
	ret

section .data
number_buffer db 20 dup(0x0)
newline db 0x0a
