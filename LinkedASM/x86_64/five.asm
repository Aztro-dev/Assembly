section .text
global  five

five:
	push rbp
	mov  rbp, rsp
	mov  rax, 5
	pop  rbp
	ret
