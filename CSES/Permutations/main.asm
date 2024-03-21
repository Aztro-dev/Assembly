section .rodata
no_solution: db "NO SOLUTION",0x0a
n_equals_one: db "1", 0x0a
n_equals_four: db "2 4 1 3", 0x0a

section .data
number_buffer: times 20 db 0x0
output_size: dq 0x0

section .text
global  _start

solve:
	cmp rax, 0x1
	jne .not_equals_one
	mov rdi, 0x1
	mov rsi, n_equals_one
	mov rdx, 2
	syscall
	ret

.not_equals_one:
	cmp rax, 0x4
	jne .not_equals_four
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, n_equals_four
	mov rdx, 8
	syscall
	ret

.not_equals_four:
	cmp rax, 0x4
	jge .exists_solution
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, no_solution
	mov rdx, 12
	syscall
	ret

.exists_solution:
	mov r8, rax; temp_n
	and r8b, 0xFE; reset last digit

.while_temp_is_positive:
	cmp  r8, 0x0
	jle  .exit_while_temp_is_positive
	mov  rdi, r8
	call append_output
	sub  r8, 0x2
	jmp  .while_temp_is_positive

.exit_while_temp_is_positive:
	mov r8, rax
	bt  rax, 0; Move least significant bit of rax to carry flag
	jc  .while_temp_is_positive; Jump if carry
	dec r8

.while_temp_is_positive_again:
	cmp  r8, 0x0
	jle  .exit
	mov  rdi, r8
	call append_output
	sub  r8, 0x2
	jmp  .while_temp_is_positive_again

.exit:

	ret

	; input number is in rdi

append_output:
	push rax
	push r8
	call itoa
	pop  r8

	mov rax, 12; sys_brk
	mov r12, qword[output_size]
	lea rdi, [output + r12 + rdx + 1]; Allocate extra bytes for the new number
	syscall

	lea rdi, [output + r12]

.add_digit_loop:
	cmp r9, 0x0
	je  .exit_add_digit_loop
	mov al, byte [rsi]

	mov byte [rdi], al
	inc rdi
	inc rsi
	dec r9

	jmp .add_digit_loop

.exit_add_digit_loop:
	inc rdi
	mov byte[rdi], ' '; Add a space at the end
	mov rax, qword [output_size]
	add rax, rdx
	inc rax
	mov qword[output_size], rax

	pop rax

	ret

_start:
	;   sys_brk(0)
	mov rax, 12
	xor rdi, rdi
	syscall
	mov qword[output], rax

	call read_int

	call solve

	mov rax, 60
	mov rdi, 0
	syscall

itoa:
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
	lea rsi, [number_buffer + 20]
	sub rsi, r9
	mov rdx, r9

	ret

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
	mov rdi, 0x0; STDIN
	mov rsi, number_buffer
	mov rdx, 0x1; One character at a time

.read_loop:
	xor rax, rax; READ syscall
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

section .bss

output:
	resq 1
