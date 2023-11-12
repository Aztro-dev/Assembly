section .bss

n:
	resb 14

	section .text
	global  _start

_start:
	xor rax, rax; READ
	xor rdi, rdi; STDIN
	mov rsi, n; numbers
	mov rdx, 0x1; 1 character at a time
	mov r8, 0x1; Character count
	syscall

.read_n:
	cmp byte [rsi], 0x0a; Newline
	je  .exit_read_n
	inc rsi; Next byte in n
	inc r8
	mov rdx, 0x1
	syscall
	jmp .read_n

.exit_read_n:
	mov rax, 0x1; WRITE
	mov rdi, 0x1; STDOUT
	mov rsi, n; Thing we just inputted :|
	mov rdx, r8
	syscall

	mov rax, 60; exit
	xor rdi, rdi; Error code 0
	syscall
	ret
