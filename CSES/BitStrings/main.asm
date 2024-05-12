%define SYS_READ 0x0
%define SYS_WRITE 0x1
%define STDIN 0x0
%define STDOUT 0x1
%define MODULO 1000000007
section .data
input_buffer times (20) db 0x0
number_buffer times (20) db 0x0

section .text
global  _start

_start:
	call read_int

	mov r9, MODULO
	mov r8, rax
	mov rax, 0x1

.loop:
	cmp r8, 0x0
	jl  .exit
	dec r8
	xor rdx, rdx
	shl rax, 0x1
	div r9
	mov rax, rdx
	jmp .loop

.exit:
	mov  rdi, rax
	call print_int

	mov rax, 60; Exit
	xor rdi, rdi; Exit code 0
	syscall

read_int:
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, input_buffer
	mov rdx, 20
	syscall
	xor rax, rax; rax = output
	mov r8, 10; Base 10

.loop:
	cmp byte[rsi], 0x0
	je  .exit
	cmp byte[rsi], 0x0a
	je  .exit

	mul r8

	movzx rbx, byte[rsi]
	sub   rbx, 48; '0' - 48 = 0
	add   rax, rbx
	inc   rsi
	jmp   .loop

.exit:
	ret

print_int:
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
