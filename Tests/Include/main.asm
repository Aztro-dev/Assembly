%include "include.asm"

section .text
global  _start

_start:
	call print_include

	mov rax, 60
	mov rdi, 0
	syscall
