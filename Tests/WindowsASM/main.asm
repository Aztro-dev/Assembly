section .text
global  main
extern  ExitProcess
extern  printf
extern  scanf

main:
	push rbp ; align stack
	mov rcx, input_fmt_str ; format string
	mov rdx, input ; input pointer
	call scanf

	push rbp; use 8 bytes of stack space in order to align the stack
	mov  rcx, format_str; format string (first arg)
	mov  rdx, qword[input]; Integer to print (second arg)
	mov  al, 0; magic for varargs (0 = no magic; prevents crash)
	call printf
	;    ExitProcess(0)
	mov  rcx, 0
	call ExitProcess
	ret

section .data
format_str: db "bruh: %d", 0x0a, 0 ; "bruh: %d\n\0"
input_fmt_str: db "Input: %lld", 0x0a, 0 ; "Input: %lld\n\0"

section .bss ; variables
input: resq 1 ; uint64_t
