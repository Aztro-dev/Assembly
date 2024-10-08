%define SYS_READ 0x0
%define SYS_WRITE 0x1
%define SYS_OPEN 0x2
%define SYS_CLOSE 0x3
%define SYS_EXIT 60
%define STDIN 0x0
%define STDOUT 0x1
%define TAPE_SIZE 30000
%define INPUT_SIZE 4096

section .rodata:
file_name db "hello_world.bf", 0x0

section .data
tape    times TAPE_SIZE db 0x0
input   times INPUT_SIZE db 0x0
file_descriptor dq 1

section .text
global  _start

interpret:
	mov r8, TAPE_SIZE
	sar r8, 1; middle of tape
	lea r9, [input - 1]
	lea rsi, [tape + r8]; Pointer

.loop:
	inc r9
	mov al, byte [r9]
	cmp al, 0x0
	je  .exit_loop

.check_right_arrow:
	cmp al, '>'
	jne .check_left_arrow
	inc rsi; ptr++
	jmp .loop

.check_left_arrow:
	cmp al, '<'
	jne .check_plus
	dec rsi; ptr--
	jmp .loop

.check_plus:
	cmp al, '+'
	jne .check_minus
	mov al, byte[rsi]
	inc al
	mov byte[rsi], al
	jmp .loop

.check_minus:
	cmp al, '-'
	jne .check_dot
	mov al, byte[rsi]
	dec al
	mov byte[rsi], al
	jmp .loop

.check_dot:
	cmp al, '.'
	jne .check_comma
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rdx, 0x1
	syscall
	jmp .loop

.check_comma:
	cmp al, ','
	jne .check_open_bracket
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rdx, 0x1
	syscall
	jmp .loop

.check_open_bracket:
	cmp al, '['
	jne .check_closed_bracket
	mov al, byte[rsi]
	cmp al, 0x0
	jne .loop; Skip if *ptr is not true
	mov rcx, 0x1; loop counter

.open_bracket_loop:
	cmp rcx, 0x0
	jle .loop
	inc r9
	mov al, byte[r9]
	cmp al, '['
	jne .open_bracket_loop_closed_bracket
	inc rcx
	jmp .open_bracket_loop

.open_bracket_loop_closed_bracket:
	cmp al, ']'
	jne .open_bracket_loop
	dec rcx
	jmp .open_bracket_loop

.check_closed_bracket:
	cmp al, ']'
	jne .loop
	mov al, byte[rsi]
	cmp al, 0x0
	je  .loop; Skip if *ptr is true
	mov rcx, 0x1; loop counter

.closed_bracket_loop:
	cmp rcx, 0x0
	jle .loop
	dec r9
	mov al, byte[r9]
	cmp al, '['
	jne .closed_bracket_loop_closed_bracket
	dec rcx
	jmp .closed_bracket_loop

.closed_bracket_loop_closed_bracket:
	cmp al, ']'
	jne .closed_bracket_loop
	inc rcx
	jmp .closed_bracket_loop

.exit_loop:
	ret

_start:
	mov rax, SYS_OPEN
	mov rdi, file_name
	xor rsi, rsi
	xor rdx, rdx
	syscall

	mov qword[file_descriptor], rax

	mov rax, SYS_READ
	mov rdi, qword[file_descriptor]
	mov rsi, input
	mov rdx, INPUT_SIZE
	syscall

	call interpret

	mov rax, SYS_CLOSE
	mov rdi, qword[file_descriptor]
	syscall

	mov rax, SYS_EXIT
	mov rdi, 0
	syscall
