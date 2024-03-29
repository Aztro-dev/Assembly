section .data
number_buffer db 20 dup(0x0)
newline db 0x0a

section .text
global  _start

clear_number_buffer:
	push rsi
	push rcx
	mov  rcx, 20; 20 characters
	mov  rsi, number_buffer

.clear_loop:
	mov byte [rsi], 0x0; Clear byte
	inc rsi
	cmp rcx, 0x0; See if rcx is 0
	je  .exit_loop
	dec rcx
	jmp .clear_loop

.exit_loop:
	pop rcx
	pop rsi
	ret

	; print_uint64(rdi num) -> void

print_uint64:
	push rax
	push rsi
	push rdx
	mov  r8, 10; Base 10

	mov rax, rdi
	mov rsi, number_buffer
	add rsi, 19; Last digit of buffer
	mov r9, 0x0; Size

.loop:
	cmp rax, 0x0
	jle .exit_loop
	xor rdx, rdx
	div r8
	add dl, 48; To ASCII num
	mov byte [rsi], dl
	dec rsi
	inc r9
	jmp .loop

.exit_loop:
	mov rax, 0x1
	mov rdi, 0x1
	lea rsi, [number_buffer + 20]
	sub rsi, r9
	mov rdx, r9
	syscall

	pop rdx
	pop rsi
	pop rdx

	ret

	; print_int64(rdi num) -> void

print_int64:
	push rax
	push rsi
	push rdx

	mov r8, 10; Base 10

	mov rax, rdi
	mov rsi, number_buffer
	add rsi, 19; Last digit of buffer
	bt  rax, 63; Sign bit
	jz  .loop
	mov byte [number_buffer], '-'
	dec rsi
	neg rax

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
	mov rax, 0x01; Write
	mov rdi, 0x01; STDOUT
	mov rsi, number_buffer
	mov rdx, 20
	syscall

	pop rdx
	pop rsi
	pop rax
	ret

_start:
	mov  rax, 0x01
	mov  rdi, 0xFF
	mov  rsi, number_buffer
	call print_uint64
	mov  rdi, 0x01
	mov  rdx, 20
	syscall

	mov rax, 0x01
	mov rdi, 0x01
	mov rsi, newline
	mov rdx, 0x01
	syscall

	call clear_number_buffer

	mov  rax, 0x01
	mov  rdi, -55
	mov  rsi, number_buffer
	call print_int64
	mov  rdi, 0x01
	mov  rdx, 20
	syscall

	mov rax, 60
	mov rdi, 0
	syscall
