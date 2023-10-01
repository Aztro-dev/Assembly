section .note.GNU-stack

section .data
input_file: db "gift1.in", 0x0
output_file: db "gift1.out", 0x0
write_file_mode: dq 0400 ; write access to owner of the file

section .text
global  _start

solve:
	ret

_start:
	; mov     rax, 0x02; open
	; mov     rdi, input_file
	; xor     rsi, rsi; no idea what int flags do
	; xor     rdx, rdx; no idea what umode_t mode does
	; syscall; call open and return file descriptor in rax
	; mov     qword [input_file_descriptor], rax; store file descriptor for later use

	; mov rdi, qword [input_file_descriptor]; file descriptor
	; xor rax, rax; read
	; mov rsi, input_buffer; buffer
	; mov rdx, 0xE; input_buffer length (14)
	; syscall

	; mov     rax, 0x55; creat()
	; mov     rdi, output_file
	; mov     rsi, qword [write_file_mode]
	; syscall; file descriptor stored in rax
	; mov     qword [output_file_descriptor], rax

	; ; input text should be stored in input_buffer
	; call solve

	; mov     rax, 0x3; close file
	; mov     rdi, qword [input_file_descriptor]; so the kernel knows what file to close (input_file_descriptor)
	; syscall; close file

	mov rax, 60; exit
	xor rdi, rdi; err_code 0
	syscall

	section .bss
	input_buffer: resb 14
	input_file_descriptor: resq 1
	output_file_descriptor: resq 1
