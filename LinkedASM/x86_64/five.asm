section .text
global  five

five:
	push rbp
	mov  rbp, rsp
	mov  eax, 5
	pop  rbp
	ret
