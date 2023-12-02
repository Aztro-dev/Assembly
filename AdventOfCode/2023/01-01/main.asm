section .data
file_name db "x.in", 0x0
file_name_len equ $ - file_name
number_buffer db 20 dup(0x0)
newline db 0x0a

section   .bss
file_descriptor resq 0x1 ; To store the file descriptor for the "x.in" file
character resb 0x1; Buffer to read one character at a time
first_digit resq 0x1
curr_digit resq 0x1 ; For solve loop
section   .text
global    _start

	; solve(void) -> r8 num

solve:
	xor r8, r8 ; output

	xor rax, rax; Read
	mov rdi, qword [file_descriptor]; read from file
	mov rsi, character
	mov rdx, 0x1; One character at a time
	.all_lines_loop:
		xor rax, rax
		mov rdx, 0x1; One character at a time
		syscall
		cmp byte [rsi], 0x0a ; If we get a double newline then we're done
		je .exit_all_lines_loop
		mov byte [curr_digit], 0x0 
		mov byte [first_digit], 0x0 
		.line_loop:
			sub byte[rsi], 48 ; To number
			mov al, byte [rsi] ; curr digit
			cmp al, 0x9 ; 9 > curr_byte?
			jg .not_num
			cmp al, 0x0 ; 0 < curr_byte?
			jl .not_num
			mov al, byte [rsi] ; curr digit
			; We are at this point if we found a character with a digit
			cmp byte [first_digit], 0x0 ; If first_digit isn't set
			jne .set_curr_digit
			; We are at this point if first_digit isn't set
			mov byte [first_digit], al ; Set first_digit to curr_digit
			.set_curr_digit:
				mov byte [curr_digit], al
				

			.not_num: ; aka skip
			
			xor rax, rax
			mov rdx, 0x1; One character at a time
			syscall ; Result stored in character
			cmp byte [rsi], 0x0a ; If newline, exit line_loop
			je .exit_line_loop
			
			jmp .line_loop

		.exit_line_loop:
		xor rax, rax ; clear higher bits
		mov al, byte [first_digit] ; First digit
		mov r9, 10 ; Shift one digit place
		mul r9 ; rdx:rax = rax * 10
		add al, byte [curr_digit]
		add r8, rax ; Add number to output
		jmp .all_lines_loop
	
	.exit_all_lines_loop:
	ret

_start:
	mov     rax, 0x02; Open
	mov     rdi, file_name
	xor     rsi, rsi; No flags
	xor     rdx, rdx; umode_t = 0
	syscall ; FD stored in rax
	mov     qword [file_descriptor], rax

	;    solve(void) -> r8 num
	call solve

	; xor r8, r8
	; mov r8b, byte [curr_digit]
	mov  rdi, r8; num
	;    print_unit64_t(rdi num) -> void
	call print_uint64_t

	mov rax, 60
	mov rdi, 0
	syscall

	; print_uint64_t(rdi num) -> void

print_uint64_t:
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
	mov rax, 0x1; Read
	mov rdi, 0x1; STDOUT
	mov rsi, number_buffer
	mov rdx, 20; 20 characters max
	syscall

	pop rdx
	pop rsi
	pop rax
	ret
