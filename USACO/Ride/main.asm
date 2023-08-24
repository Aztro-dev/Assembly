section .data
input_file: db "ride.in", 0x0

go:
	db "GO", 0x0

stay:
	db "STAY", 0x0

	section .text
	global  _start

	; input text should be stored in input_buffer

solve:
	xor rax, rax; reset rax
	xor rdx, rdx; reset rdx
	mov rsi, input_buffer; beginning of input
	mov al, byte[rsi]; store byte at rsi into al
	inc rsi; go to next byte
	sub al, 64; 'A' is 1, 'B' is 2, etc.
	mov r8, rax; r8 is the total for the first group

.first_loop:
	mov al, byte[rsi]; store byte at rsi into al
	inc rsi; go to next byte
	cmp al, 0xa; if newline, stop progressing
	je  .exit_first
	sub al, 64; 'A' is 1, 'B' is 2, etc.
	mul r8; multiply total by rax (al)
	mov r8, rax
	xor rax, rax
	jmp .first_loop

.exit_first:
	mov al, byte[rsi]; store byte at rsi into al
	inc rsi
	sub al, 64; 'A' is 1, 'B' is 2, etc.
	mov r9, rax; r9 is the total of the second group

.second_loop:
	mov al, byte[rsi]; store byte at rsi into al
	inc rsi; go to next byte
	cmp al, 0xa; if newline, stop progressing
	je  .exit_second
	sub al, 64; 'A' is 1, 'B' is 2, etc.
	mul r9; multiply total by rax (al)
	mov r9, rax
	xor rax, rax
	jmp .second_loop

.exit_second:
	mov r10, 47; to find the modulo
	xor rdx, rdx
	mov rax, r8; first group
	div r10; modulo stored in rdx
	mov r8, rdx; store modulo back in r8

	xor rdx, rdx
	mov rax, r9; second group
	div r10; modulo stored in rdx
	mov r9, rdx; store modulo back in r9

	mov rax, 0x1; write
	mov rdi, 0x1; stdout

	cmp r8, r9
	je  .go

.stay:
	mov rsi, stay; stay buffer
	mov rdx, 0x5; length of stay
	syscall
	jmp .exit

.go:
	mov rsi, go; stay buffer
	mov rdx, 0x3; length of stay
	syscall

.exit:
	ret

_start:
	mov     rax, 0x02; open
	mov     rdi, input_file
	xor     rsi, rsi; no idea what int flags do
	xor     rdx, rdx; no idea what umode_t mode does
	syscall ; call open and return file descriptor in rax
	mov     qword [file_descriptor], rax; store file descriptor for later use

	mov rdi, qword [file_descriptor]; file descriptor
	xor rax, rax; read
	mov rsi, input_buffer; buffer
	mov rdx, 0xE; input_buffer length (14)
	syscall

	;    input text should be stored in input_buffer
	call solve

	mov     rax, 0x3; close file
	mov     rdi, qword [file_descriptor]; so the kernel knows what file to close (file_descriptor)
	syscall ; close file

	mov rax, 60; exit
	xor rdi, rdi; err_code 0
	syscall

	section .bss
	input_buffer: resb 14
	file_descriptor: resq 1
