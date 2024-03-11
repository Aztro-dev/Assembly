section .data
number_buffer times 20 db 0 ; 20 Digits in uint64_t
dummy_n       dq 0x0
n       dq 0x0

section .text
global  _start

solve:
	;   if(nums.size() == 1){ return 0; }
	mov rax, qword[n]
	cmp rax, 0x1
	jg  .not_length_of_one
	xor rax, rax
	ret

.not_length_of_one:
	xor rax, rax; sum
	mov r8, 0x1; i

	;   Reset high parts of registers
	;   Because movzx doesnt work apparently
	xor rbx, rbx
	xor rcx, rcx

	; for(int i = 1; i < nums.size(); i++)

.loop:
	cmp r8, qword[n]
	je  .exit_loop

	;nums[i]
	lea rdi, [arr + 4*r8]
	mov ebx, dword [rdi]
	;   nums[i - 1]
	lea rdi, [arr + 4*r8 - 4]
	mov ecx, dword [rdi]

	;   if (nums[i] < nums[i - 1])
	cmp ebx, ecx
	jg  .continue

	add rax, rcx; sum += nums[i - 1]
	sub rax, rbx; sum -= nums[i]
	lea rdi, [arr + 4*r8]
	mov dword [rdi], ecx; nums[i] = nums[i - 1]

.continue:
	inc r8
	jmp .loop

.exit_loop:
	ret

_start:
	call read_int
	mov  qword [n], rax

	;   brk(0)
	mov rax, 12
	mov rdi, 0
	syscall

	mov qword[arr], rax

	;   brk(brk(0) + n * 4)
	mov rax, qword[n]
	mov r8, 0x4
	mul r8
	mov rdi, rax
	add rdi, qword[arr]
	mov rax, 12
	syscall

	mov r8, qword [n]
	mov rdi, arr

.populate_array_loop:
	test r8, r8
	jz   .exit_populate_array_loop

	push rdi
	call read_int
	pop  rdi

	mov dword[rdi], eax
	add rdi, 0x4; Next int

	dec r8
	jmp .populate_array_loop

.exit_populate_array_loop:
	call solve

	mov  rdi, rax
	call print_uint64

	mov rax, 60; Exit
	mov rdi, 0x0; Exit Code 0
	syscall

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

	cmp rsi, '0'; Anything less than 0 is invalid
	jl  .error

	cmp rsi, '9'; Anything greater than 9 is invalid
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

print_uint64:
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
	pop rax

	ret

section .bss
arr     resq 1
