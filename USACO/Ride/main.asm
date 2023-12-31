section .data
input_file: db "ride.in", 0x0
output_file: db "ride.out", 0x0
write_file_mode: dq 0400 ; write access to owner of the file

go:
	db "GO"

stay:
	db "STAY"

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
	mov rax, 0x1; write
	mov rdi, qword [output_file_descriptor]; Write to file
	mov rsi, stay
	mov rdx, 0x4; stay length (4)
	syscall
	jmp .exit

.go:
	mov rax, 0x1; write
	mov rdi, qword [output_file_descriptor]; Write to file
	mov rsi, go
	mov rdx, 0x2; go length (2)
	syscall
	syscall

.exit:
	ret

_start:
	mov     rax, 0x02; open
	mov     rdi, input_file
	xor     rsi, rsi; no idea what int flags do
	xor     rdx, rdx; no idea what umode_t mode does
	syscall ; call open and return file descriptor in rax
	mov     qword [input_file_descriptor], rax; store file descriptor for later use

	mov rdi, qword [input_file_descriptor]; file descriptor
	xor rax, rax; read
	mov rsi, input_buffer; buffer
	mov rdx, 0xE; input_buffer length (14)
	syscall

	mov     rax, 0x55; creat()
	mov     rdi, output_file
	mov     rsi, qword [write_file_mode]
	syscall ; file descriptor stored in rax
	mov     qword [output_file_descriptor], rax

	;    input text should be stored in input_buffer
	call solve

	mov     rax, 0x3; close file
	mov     rdi, qword [input_file_descriptor]; so the kernel knows what file to close (input_file_descriptor)
	syscall ; close file

	mov rax, 60; exit
	xor rdi, rdi; err_code 0
	syscall

	section .bss
	input_buffer: resb 14
	input_file_descriptor: resq 1
	output_file_descriptor: resq 1
