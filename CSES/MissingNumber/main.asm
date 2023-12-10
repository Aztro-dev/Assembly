section .data
uint64_buffer db 20 dup(0x0) ; 20 Digits in uint64_t

n dq 1

section .text
global  _start

solve:
	call read_int
	mov  qword [n], rax
	mov  r9, rax
	;    Sum of all natural numbers: n(n + 1) / 2
	mov  r8, rax
	inc  r8
	mul  r8
	sar  rax, 0x1
	mov  qword[n], rax

.loop:
	dec r9
	cmp r9, 0x0
	je  .exit_loop

	call read_int
	sub  qword[n], rax

	jmp .loop

.exit_loop:
	mov rdi, qword [n]

	ret

_start:
	call solve

	call print_uint64

	mov rax, 60; exit
	xor rdi, rdi; Error code 0
	syscall
	ret

clear_uint64_buffer:
	push rsi
	push rcx
	mov  rcx, 20; 20 characters
	mov  rsi, uint64_buffer

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
	call clear_uint64_buffer

	mov r8, 10; Base 10

	mov rax, rdi
	mov rsi, uint64_buffer
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

	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, uint64_buffer
	mov rdx, 20
	syscall

	pop rdx
	pop rsi
	pop rax
	ret

atoi:
	mov rax, 0; Set initial total to 0

.convert:
	movzx rsi, byte [rdi]; Get the current character
	test  rsi, rsi; Check for \0
	je    .done

	cmp rsi, 48; Anything less than 0 is invalid
	jl  .error

	cmp rsi, 57; Anything greater than 9 is invalid
	jg  .error

	sub  rsi, 48; Convert from ASCII to decimal
	imul rax, 10; Multiply total by 10
	add  rax, rsi; Add current digit to total

	inc rdi; Get the address of the next character
	jmp .convert

.error:
	mov rax, -1; Return -1 on error

.done:
	ret ; Return total or error code

read_int:
	mov rdi, 0x0; STDIN
	mov rsi, uint64_buffer
	mov rdx, 0x1; One character at a time

.read_loop:
	xor rax, rax; READ syscall
	syscall
	mov al, byte [rsi]
	cmp al, 0x0; Null character
	je  .exit_read_loop
	cmp al, 0x0a; newline
	je  .exit_read_loop
	cmp al, 0x20; Space
	je  .exit_read_loop
	sub rsi, 20
	cmp rsi, uint64_buffer
	je  .exit_read_loop
	add rsi, 21; Reset to previous value and increment
	jmp .read_loop

.exit_read_loop:
	mov  byte [rsi], 0x0; Reset last bit
	mov  rdi, uint64_buffer
	call atoi
	ret
