section .rodata
msg     db "Hello world!", 0ah
n       dq 0x30

section .data
brk_first_location db 0x0
number_buffer db 20 dup(0x0)
newline db 0x0a

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

section    .bss
primeArray resq 1
