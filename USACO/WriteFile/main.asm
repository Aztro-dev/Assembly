section .data
output_file: db "output.out", 0x0

text:
	db "Testing"
	write_file_mode: dq 0400 ; write access to owner of the file

	section .text
	global  _start

_start:
	mov     rax, 0x55; creat()
	mov     rdi, output_file
	mov     rsi, qword [write_file_mode]
	syscall ; file descriptor stored in rax
	mov     qword [file_descriptor], rax

	mov rax, 0x1; write
	mov rdi, qword [file_descriptor]; Write to file
	mov rsi, text
	mov rdx, 0x7; buffer length (7)
	syscall

	mov     rax, 0x3; close file
	mov     rdi, qword [file_descriptor]; so the kernel knows what file to close (file_descriptor)
	syscall ; close file

	mov rax, 60; exit
	xor rdi, rdi; err_code 0
	syscall

	section .bss
	file_descriptor: resq 1
