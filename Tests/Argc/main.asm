section .data
argc    dq 0x01
number_buffer db 20 dup(0x0)
newline db 0x0a

section .text
global  _start

_start:
	pop  rdi
	call print_uint64

	mov rax, 60; Exit
	mov rdi, 0x0; Success
	syscall

	; print_uint64(rdi num) -> void

print_uint64:
	push rax
	push rsi
	push rdx

	mov r8, 10; Base 10

	mov rax, rdi
	mov rsi, number_buffer
	add rsi, 19; Last digit of buffer

.loop:
	cmp rax, 0x0
	jle .exit_loop
	xor rdx, rdx
	div r8
	add dl, 48; To ASCII num
	mov byte [rsi], dl
	dec rsi
	jmp .loop

.exit_loop:

	mov rax, 0x1; Write
	mov rdi, 0x1; STDOUT
	mov rsi, number_buffer
	mov rdx, 20
	syscall

	pop rdx
	pop rsi
	pop rax
	ret
