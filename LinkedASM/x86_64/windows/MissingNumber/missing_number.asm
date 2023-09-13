section .note.GNU-stack

section .text
global  missing_number

;uint64_t missing_number(rcx a, rdx nums)

missing_number:
	mov  rsi, rdx; store rdx
	call sum_of_all; rax = sum of all numbers
	mov  rdx, rsi; restore rdx

.loop:
	cmp rcx, 0x1
	jle .exit_loop; if (rcx < 0x1) break

	sub rax, qword [rdx]
	add rdx, 0x8; Next index (64 bits)

	dec rcx; rcx--
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
