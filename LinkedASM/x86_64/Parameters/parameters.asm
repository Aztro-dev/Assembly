section .text
global  parameters

parameters:
	add rax, rdx; a + b
	add rax, r8; (a + b) + c
	add rax, r9; (a + b) + (c + d)
	ret ; return rax
