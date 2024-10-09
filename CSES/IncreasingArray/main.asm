%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_BRK 12
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

section .bss
input_array resq 1
input_buffer resq 1
n resd 1

section .text
solve:
	xor r9, r9
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    mov r10, qword[input_array]
	.loop:
        inc r9
		cmp r9d, dword[n]
		jge .exit
        ;nums[i]
        mov ebx, dword[r10 + 4 * r9]
        
    	;   nums[i - 1]
        mov ecx, dword[r10 + 4 * r9 - 4]

    	;   if (nums[i] < nums[i - 1])
    	cmp ebx, ecx
    	jg  .continue
    
    	add rax, rcx; sum += nums[i - 1]
    	sub rax, rbx; sum -= nums[i]
    	mov dword [r10 + 4 * r9], ecx; nums[i] = nums[i - 1]

        .continue:
		jmp .loop

	.exit:
	ret

global _start
_start:
	mov rax, SYS_BRK
	xor rdi, rdi
	syscall

	mov qword[input_array], rax
	
	; rax = n
	call read_int
	mov dword [n], eax

	mov rdi, qword[input_array]
	sal rax, 2 ; times 4 
	add rdi, rax
	mov rax, SYS_BRK
	syscall
	
	mov qword[input_buffer], rax
    xor rdi, rdi
	mov edi, dword[n]
	sal rax, 4 ; times 16 
	add rdi, rax
	mov rax, SYS_BRK
	syscall

	mov edi, dword[n]
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
	push r9

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

	pop r9
	pop rdx
	pop rsi
	pop rax

	ret

atoi:
    push rdi
    push rsi
	mov rax, 0; Set initial total to 0

.convert:
	movzx rsi, byte [rdi]; Get the current character

	cmp rsi, '0'
	jl  .done

	cmp rsi, '9'
	jg  .done

	sub  rsi, '0' ; Convert from ASCII to decimal
	imul rax, 10; Multiply total by 10
	add  rax, rsi; Add current digit to total

	inc rdi; Get the address of the next character
	jmp .convert

.done:
    pop rsi
    pop rdi
	ret ; Return total or error code

	; read_int() -> rax output
read_int:
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, number_buffer
	mov rdx, 0x1 ; one character at a time

.read_loop:
	mov rax, SYS_READ
	syscall
	cmp byte [rsi], '0'; Null character
	jl  .exit_read_loop
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
	mov rdx, rdi; amount of nums
	sal rdx, 4 ; read 16 characters for every number
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, qword[input_buffer]
	syscall

	xor r9, r9
    mov r10, qword[input_array]

	.outer_read_loop:
		cmp r9d, dword[n]
		jge .exit
		dec rsi
		.read_loop:
			inc rsi
			cmp byte [rsi], '0'
			jl  .read_loop
			cmp byte [rsi], '9'
			jg  .read_loop

		.exit_read_loop:
			mov  rdi, rsi
			call atoi
            mov rdi, rax
            ; call print_number
			mov dword[r10 + 4 * r9], eax
        dec rsi
		.next_num_loop:
			inc rsi
			cmp byte [rsi], '0'
			jl  .exit_next_num_loop
			cmp byte [rsi], '9'
			jg  .exit_next_num_loop
			jmp .next_num_loop
		.exit_next_num_loop:
		inc r9
		jmp .outer_read_loop
	.exit:
	ret
