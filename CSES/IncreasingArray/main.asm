section .data

space:
	db " "

	section .text
	global  _start

	; read(rsi input, rdx size)

read:
	xor rax, rax; Read
	xor rdi, rdi; Stdin
	syscall
	ret

	; print(rsi buff, rdx length)

print:
	mov rax, 1; write
	mov rdi, 1; stdout
	syscall
	ret

	; atoi (rsi pointer_to_ascii) -> rdx

atoi:
	xor   rax, rax; rax = 0
	xor   rdx, rdx; rdx = 0
	lodsb ; load byte at address RSI into AL.
	cmp   al, '-'
	sete  bl; bl = negative flag
	jne   .lpv; jump to .lpv if positive

.lp:
	lodsb ; load byte at address RSI into AL

.lpv:
	sub  al, '0'; turns al into number
	jl   .end; if sign flag != overflow flag, jump to .end
	imul rdx, 10; rdx *= 10
	add  rdx, rax; rdx += rax
	jmp  .lp; load byte at address RSI into AL

.end:
	test bl, bl; bl & bl
	jz   .p; if bl is zero, return
	neg  rdx; rdx = -rdx
	;    xchg rax, rdx

.p:
	ret

	; itoa(rax integer) -> rsi output

itoa:
	std  ; rsi -= 1, rdi -= 1
	mov  r9, 10; r9 will be our base (base 10)
	bt   rax, 63; copy bit 63 (most significant, handles negatives) from rax to carry flag
	setc bl; if carry flag is set, set bl to 1 (negative sign)
	jnc  .lp; if carry flag isn't set, jump to .lp
	neg  rax; if carry flag is set, negate the number

.lp:
	xor   rdx, rdx; reset rdx
	div   r9; rax / r9 -> rax output, rdx remainder
	xchg  rax, rdx; swap rax and rdx
	add   rax, '0'; rax is now the remainder, which is turned into an ascii integer
	stosb ; load byte at rsi into al
	xchg  rax, rdx; rax is now the result of the first division, and rdx is now the ?
	test  rax, rax; if rax is zero
	jnz   .lp; if rax isn't zero, jump to .lp (loop), this ensures we have another digit to process
	test  bl, bl; if bl is zero (sign or no sign)
	jz    .p; if number is positive, jump to .p (exit)
	mov   al, '-'; if number is NOT positive (negative), add a negative sign
	stosb ; load byte at rsi into al

.p:
	cld ; clear direction flag (Turns off automatic rsi increments whenever calling a string function (like stosb))
	inc rdi
	ret

	; print_itoa(rsi buff, rax input) -> void

print_itoa:
	call itoa
	sub  rsi, rdi
	mov  rdx, rsi
	mov  rsi, rdi
	;    print(rsi buff, rdx length)
	call print

print_space:
	mov  rsi, space
	mov  rdx, 0x1; length of one
	call print

	; atoi(rsi input) -> rcx

atoi_rcx:
	mov   rsi, input
	call  atoi; atoi(rsi input) -> rdx
	mov   rcx, rdx; store value of atoi
	mov   rdi, input+18; end of buff
	mov   rsi, rdi; rsi = rdi
	std   ; rsi--, rdi--
	mov   rax, 10
	stosb ; al = [rsi]
	ret

malloc:
	;   malloc(rdi n) -> rax ptr_to_array
	mov rax, 0xC; 12 in decimal (brk)
	syscall
	ret

IncreasingArray:
	;   IncreasingArray() -> rax output
	xor r8, r8; current number
	xor r9, r9; previous number

	xor rax, rax; set rax to zero for the output
	cmp rcx, 0x1; If there is only one number, then we don't need to do anything
	je  .exit

	xor r11, r11; iterator i
	mov rsi, arr; rsi is the pointer to the array

	.set_arr_loop: ; for(int i = 0; i < n; i++){
	cmp r11, rcx; See if i is less than n
	jge .after_set_arr_loop
	inc r11; i++

	;    atoi_rcx(rsi input) -> rcx output
	call atoi_rcx
	mov

	jmp .set_arr_loop

.after_set_arr_loop:
	xor rax, rax; reset rax
	mov rcx, qword [n]; restore n back into rcx
	mov rsi, arr; Go back to the start of the array

.exit:
	ret

_start:
	mov  rsi, n_str
	mov  rdx, 19
	;    read(rsi input, rdx size)
	call read

	;    atoi_rcx(rsi input) -> rcx output
	call atoi_rcx

	mov qword[n], rcx

	mov  rdi, rcx
	call malloc; output ptr stored in rax
	mov  arr, rax; arr now points to the start of the array

	;    IncreasingArray() -> rax output
	call IncreasingArray

	;    print_itoa(rax input)
	call print_itoa; print the output of IncreasingArray

	mov rax, 60; exit
	mov rdi, 0
	syscall

	section .bss

n_str:
	resb 0x13; 19 in decimal

n:
	resq 0x1; 1 in decimal

arr:
	resq 0x0; pointer to array
