section .data
input_buffer: times 1000000 db 0x0
number_buffer: times 20 db 0x0

section .text
global  _start

solve:
	mov r8, 0x1; Current Max
	mov r9, 0x1; Max
	lea rdi, [input_buffer]
	lea rsi, [input_buffer + 1]

.read_loop:
	cmp byte [rsi], 0x0
	je  .exit_read_loop

	mov ah, byte [rdi]
	mov al, byte [rsi]

	cmp   ah, al
	jne   .skip
	inc   r8
	cmp   r8, r9
	cmovg r9, r8; Max = max(Max, Current Max)
	inc   rdi
	inc   rsi
	jmp   .read_loop

.skip:
	mov r8, 0x1; Current max = 1
	inc rdi
	inc rsi
	jmp .read_loop

.exit_read_loop:
	mov rax, r9
	ret

_start:
	mov rax, 0x0
	mov rdi, 0x0
	mov rsi, input_buffer
	mov rdx, 1000000
	syscall

	call solve

	mov rdi, rax

	call print_uint64

	mov rax, 60
	mov rdi, 0
	syscall

print_uint64:
	mov r8, 10; Base 10

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

	ret
