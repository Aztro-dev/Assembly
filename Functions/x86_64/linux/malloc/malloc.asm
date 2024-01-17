section .note.GNU-stack

section .text

extern strlen

global malloc_asm

	; void* malloc_asm(usize_t bytes)

malloc_asm:
	push rdi
	mov  rax, 12; brk()
	mov  rdi, 0
	syscall

	;   mov qword[brk_moment], rax
	pop rdi
	add rdi, rax
	mov rax, 12; brk()
	syscall
	ret

	; section .bss
	; brk_moment: resq 1
