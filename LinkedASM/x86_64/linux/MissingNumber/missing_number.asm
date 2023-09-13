section .note.GNU-stack

section .text
global  missing_number

;uint64_t missing_number(rdi a, rsi nums)

missing_number:
	mov  rcx, rsi; store rsi
	call sum_of_all; rax = sum of all numbers
	mov  rsi, rcx; restore rsi

.loop:
	cmp rdi, 0x1
	jle .exit_loop; if (rdi < 0x1) break

	sub rax, qword [rsi]
	add rsi, 0x8; Next index (64 bits)

	dec rdi; rdi--
	jmp .loop

.exit_loop:
	ret

;uint64_t sum_of_all(rcx num)

sum_of_all:
	xor rdx, rdx
	;n(n+1)/2
	mov rax, rcx; rax = n
	inc rax; rax = n + 1
	mul rcx; rcx * rax = n(n + 1)
	shr rax, 0x1; rax / 2 = n(n + 1) / 2
	ret
