section .data
num     dq 3.1415926535
msg     db "Num: %.11f", 0xa, 0

%ifidn  __OUTPUT_FORMAT__, elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif

section .text
extern  printf
global  start

start:
	push rbp; creates stack frame

	mov   rax, 1
	mov   rdi, msg
	movsd xmm0, [num]; move scalar double (a double precision float)
	call  printf

	pop rbp; realigns stack
	ret
