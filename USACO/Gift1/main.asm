section .data
input_file: db "gift1.in", 0x0
output_file: db "gift1.out", 0x0
write_file_mode: dq 0400 ; write access to owner of the file

section .bss
input_buffer: resb 14

input_file_descriptor: resq 1
output_file_descriptor: resq 1

section .text
extern  _scanf
extern  _printf
global  _start

solve:

	ret

_start:
	mov      rax, 0x02; open
	mov      rdi, input_file
	xor      rsi, rsi; no idea what int flags do
	xor      rdx, rdx; no idea what umode_t mode does
	syscall; call open and return file descriptor in rax
	mov      qword [input_file_descriptor], rax; store file descriptor for later use

	mov      rax, 0x55; creat()
	mov      rdi, output_file
	mov      rsi, qword [write_file_mode]
	syscall; file descriptor stored in rax
	mov      qword [output_file_descriptor], rax

	call solve

	mov      rax, 0x3; close file
	mov      rdi, qword [input_file_descriptor]; so the kernel knows what file to close (input_file_descriptor)
	syscall; close file

	mov rax, 60; exit
	xor rdi, rdi; err_code 0
	syscall
	ret
