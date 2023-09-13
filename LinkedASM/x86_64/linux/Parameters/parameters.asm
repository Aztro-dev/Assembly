section .note.GNU-stack

section .text
global  parameters

parameters:
	add rdi, rsi; a + b
	add rdi, rdx; rdi + c
	add rdi, rcx; rdi + d
	mov rax, rdi; store result in rax to return
	ret ; return rax
