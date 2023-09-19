section .text
global  main
extern  ExitProcess

main:
	;    ExitProcess(0)
	mov  rcx, 0
	call ExitProcess
	ret
