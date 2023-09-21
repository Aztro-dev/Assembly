section .text
global  main
extern  ExitProcess
extern  printf

main:
	push rbp; use 8 bytes of stack space in order to align the stack
	mov  rcx, format_str; format string (first arg)
	mov  rdx, 21; Integer to print (second arg)
	mov  al, 0; magic for varargs (0 = no magic; prevents crash)
	call printf
	;    ExitProcess(0)
	mov  rcx, 0
	call ExitProcess
	ret

section .data
format_str: db "bruh: %d", 0x0a, 0 ; "bruh: %d\n\0"
