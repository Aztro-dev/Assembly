section .rodata
msg     db "To what number?", 0x0a
msg_len equ 16

section .data
brk_first_location db 0x0
number_buffer db 20 dup(0x0)
newline db 0x0a
n       dq 0x30

section .text
global  _start

	; prime_sieve(rdi arr) -> num primes

prime_sieve:
	xor r8, r8; Count
	mov rcx, 0x2; Iterator

.loop:
	mov rax, rcx
	mul rax
	cmp rax, qword[n]
	jg  .exit_loop
	lea rbx, [rdi + rcx]
	cmp byte[rbx], 0x1
	jne .skip_inner_loop
	mov r9, rax

.set_next_primes:
	cmp r9, qword [n]
	jg  .skip_inner_loop
	lea rbx, [rdi + r9]
	mov byte [rbx], 0
	add r9, rcx
	jmp .set_next_primes

.skip_inner_loop:
	inc rcx
	jmp .loop

.exit_loop:
	mov rcx, 0x1

.count_loop:
	cmp  rcx, qword [n]
	jg   .exit
	inc  rcx
	lea  rbx, [rdi + rcx]
	cmp  byte[rbx], 1
	jne  .count_loop
	push rdi
	mov  rdi, rcx
	call print_uint64
	pop  rdi
	;    inc r8
	jmp  .count_loop

.exit:
	ret

_start:
	mov rax, 0x1; write
	mov rdi, 0x1; STDOUT
	mov rsi, msg
	mov rdx, msg_len
	syscall

	call read_int
	mov  qword[n], rax

	push rbp
	mov  rbp, rsp

	;   sys_brk()
	mov rax, 12
	mov rdi, 0
	syscall

	mov qword[primeArray], rax

	mov     rdi, rax
	add     rdi, qword[n]; current breakpoint
	mov     rax, 12
	syscall ; current breakpoint += n

	mov rdi, [primeArray]
	mov rcx, qword [n]

.fill_prime_array:
	test rcx, rcx
	jz   .exit_fill_prime_array
	dec  rcx
	mov  byte[rdi], 1; Set to true
	inc  rdi
	jmp  .fill_prime_array

.exit_fill_prime_array:
	mov  rdi, qword[primeArray]
	call prime_sieve

	; mov  rdi, rax
	; call print_uint64

	mov rax, 60
	mov rdi, 0
	syscall

	ret

clear_number_buffer:
	mov rcx, 20; size of number_buffer

.loop:
	test rcx, rcx
	jz   .exit
	dec  rcx
	lea  rdi, [number_buffer + rcx]
	mov  byte[rdi], 0x0
	jmp  .loop

.exit:
	ret

print_uint64:
	push rax
	push rcx
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
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, number_buffer
	mov rdx, 20
	syscall

	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, newline
	mov rdx, 1
	syscall

	pop rdx
	pop rsi
	pop rcx
	pop rax
	ret

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
section    .bss
primeArray resq 1
