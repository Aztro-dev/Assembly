%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_BRK 12
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

section .bss
input_array resq 1
input_buffer resq 1
n resw 1

section .text
solve:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, input_buffer
	movzx rdx, word[n]
	sal rdx, 4
	syscall

	xor rax, rax ; rax = sum

	ret

global _start
_start:
	mov rax, SYS_BRK
	xor rdi, rdi
	syscall

	mov qword[input_array], rax
	
	; rax = n
	call read_int
	mov [n], ax

	mov rdi, qword[input_array]
	sal rax, 2 ; times 4 
	add rdi, rax
	mov rax, SYS_BRK
	syscall
	
	mov qword[input_buffer], rax
	movzx rdi, word[n]
	sal rax, 4 ; times 4 
	add rdi, rax
	mov rax, SYS_BRK
	syscall

	movzx rdi, word[n]
	call read_ints

	call solve
	mov rdi, rax

	call print_number

	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall


section .data
number_buffer db 20 dup(0x0)

section .text
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

	; print_number(rdi num) -> void

print_number:
	push rax
	push rsi
	push rdx

	test rdi, rdi
	jnz .skip_zero

	mov byte[number_buffer + 19], '0'
	mov r9, 0x1
	jmp .exit_loop

	.skip_zero:
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
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, [number_buffer + 20]
	mov byte[rsi], 0x0a
	sub rsi, r9
	mov rdx, r9
	inc rdx
	syscall

	pop rdx
	pop rsi
	pop rdx

	ret

atoi:
	mov rax, 0; Set initial total to 0

.convert:
	movzx rsi, byte [rdi]; Get the current character
	test  rsi, rsi; Check for \0
	je    .done

	cmp rsi, 0x0a; newline
	je  .done

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

	; read_int(rdi fd) -> rax output
read_int:
	mov rax, SYS_READ
	mov rdi, STDOUT
	mov rsi, number_buffer
	mov rdx, 0x1 ; one character at a time

.read_loop:
	mov rax, SYS_READ
	syscall
	cmp byte [rsi], 0x0; Null character
	je  .exit_read_loop
	cmp byte [rsi], 0x0a; newline
	je  .exit_read_loop
	sub rsi, 20
	cmp rsi, number_buffer
	je  .exit_read_loop
	add rsi, 21; Reset to previous value and increment
	jmp .read_loop

.exit_read_loop:
	mov  rdi, number_buffer
	call atoi
	call clear_number_buffer
	ret

read_ints:
	mov rdx, rdi; amount of numbers
	sal rdx, 4 ; read 4 characters for every number
	mov rax, SYS_READ
	mov rdi, STDIN; STDIN
	mov rsi, input_buffer
	syscall

	.outer_read_loop:
		test r9, r9
		jz .exit
		.read_loop:
			cmp byte [rsi], 0x0; Null character
			je  .exit_read_loop
			cmp byte [rsi], 0x0a; newline
			je  .exit_read_loop
			sub rsi, 16
			cmp rsi, input_buffer
			je  .exit_read_loop
			add rsi, 17; Reset to previous value and increment
			jmp .read_loop

		.exit_read_loop:
			mov  rdi, input_buffer
			call atoi
			call clear_input_buffer
		jmp .outer_read_loop
	.exit:
	ret
