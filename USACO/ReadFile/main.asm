section .data
input_file: db "input.in", 0x0

section .text
global  _start

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
	mov rdx, 0x10; input_buffer length (16)
	syscall

	mov rax, 0x1; write
	mov rdi, 0x1; stdout
	mov rsi, input_buffer
	mov rdx, 0xE; input_buffer length (16)
	syscall

	mov     rax, 0x3; close file
	mov     rdi, qword [file_descriptor]; so the kernel knows what file to close (file_descriptor)
	syscall ; close file

	mov rax, 60; exit
	xor rdi, rdi; err_code 0
	syscall

	section .bss
	input_buffer: resb 16
	file_descriptor: resq 1
