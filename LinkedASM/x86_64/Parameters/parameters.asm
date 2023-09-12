section .text
global  parameters

parameters:
	add rcx, rdx; a + b
	add rcx, r8; (a + b) + c
	add rcx, r9; (a + b) + (c + d)
	mov rax, rcx; store result in rax to return
	ret ; return rax
