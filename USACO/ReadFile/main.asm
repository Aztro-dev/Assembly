section .text
global  _start

_start:
	mov     rax, 60; exit(
	xor     rdi, rdi; err_code: 0
	syscall ; )
