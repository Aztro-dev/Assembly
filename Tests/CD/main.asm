%define SYS_OUT 0x1
%define STDOUT 0x1
%define SYS_CHDIR 0x50
%define SYS_GETCWD 0x4F
section .data
argc    dq 1
argv    dq 1
buffer  times (100) db 0x0

section .text
global  _start

_start:
	pop rdi
	mov qword[argc], rdi
	pop rdi
	mov qword[argv], rdi
	lea rsi, [rdi]

.loop:
	mov ah, byte[rsi]
	cmp ah, 0x0
	je  .exit_loop
	cmp ah, ' '
	je  .exit_loop
	inc rsi
	jmp .loop

.exit_loop:
	inc rsi

	mov rax, SYS_CHDIR
	mov rdi, rsi
	syscall

	mov rax, SYS_GETCWD
	mov rdi, buffer
	mov rsi, 100
	syscall

	mov rax, SYS_OUT
	mov rdi, STDOUT
	mov rsi, buffer
	mov rdx, 100
	syscall

	mov rax, 60
	mov rdi, 0x0
	syscall
