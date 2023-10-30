section .data
input_file db "gift1.in", 0x0
output_file db "gift1.out", 0x0
write_file_mode dq 0400 ; write access to owner of the file
newline db 0xA

section .bss
integer_buffer resb 19 ; To store a 64-bit integer
integer_buffer_len equ $ - integer_buffer
name_buffer resb 14
name_buffer_len equ $ - name_buffer
input_name resb 14

bank_array resq 10 ; each person should have a bank account, and there is a max of 10 people
names_array times 10 resb 14 ; each person has a name, and there is a max of 10 people

np resq 1
input_file_descriptor resq 1
output_file_descriptor resq 1

section .text
global  _start

atoi:
	push rbx; if you are going to use rbx you must preserve it by pushing it onto the stack

	;~  Address is passed in rdi
	mov rbx, 10; to multiply by
	xor rax, rax; to use as "result so far"
	xor rcx, rcx; our character/digit (high bits zero)

.top:
	mov cl, byte [rdi]; get a character
	add rdi, 1; get ready for the next one
	cmp cl, 0; end of string?
	je  .done
	cmp cl, '0'
	jb  .invalid
	cmp cl, '9'
	ja  .invalid
	sub cl, '0'; or 48 or 30h
	;   now that we know we have a valid digit...
	;   multiply "result so far" by 10
	mul rbx
	jc  .overflow; ?
	;   and add in the new digit
	add rax, rcx
	jmp .top
	; I'm not going to do anything different for overflow or invalid
	; just return what we've got

.overflow:
.invalid:
.done:
	pop rbx; restore rbx to its original value
	ret ; number is in rax

	; void print_itoa(rdi n)

print_itoa:
	;   Clear these two registers for division
	mov rax, rdi; rax = n
	xor rdx, rdx

	xor r9, r9; Digits count

	mov r10, 10; Divison by 10

	mov rsi, integer_buffer; To put the integer in
	cmp rdi, 0
	jge .loop
	;   Integer should be negative after this point and before positive
	mov byte [rsi], '-'
	;   Back to positive numbers
	neg rax

	inc rsi
	inc r9

.loop:
	test rax, rax
	jz   .print
	xor  rdx, rdx; reset quotient
	div  r10; next digit stored in rdx
	add  rdx, 48; digit + 48 = digit in ascii
	mov  byte[rsi], dl; digit stored into next byte
	inc  rsi; Next byte
	inc  r9; Length

	jmp .loop

.print:
	mov rax, 0x1; Write
	mov rdi, [output_file_descriptor]; Da file
	mov rsi, [integer_buffer]
	mov rdx, r9; Length
	syscall
	ret

solve:
	xor rax, rax; Read
	mov rdi, [input_file_descriptor]; Da file
	mov rsi, integer_buffer
	mov rdx, 0x1

.read_np_loop:
	xor     rax, rax; Read because read() returns a number
	syscall ; Read in one byte
	cmp     byte [rsi], 0xA; Compare rsi to newline
	je      .exit_read_np_loop
	inc     rsi
	jmp     .read_np_loop

.exit_read_np_loop:
	mov  rdi, integer_buffer
	call atoi; Output stored in rax
	mov  qword [np], rax; Store the number into np

	mov r10, rax; rcx will be the name counter

	mov r8, rsp; Make sure not to lose track of rsp!

	xor r12, r12; person index

.read_names_loop:
	cmp r10, 0
	jle .exit_read_names_loop
	dec r10

	xor r9, r9; Store length of name

	mov rdi, [input_file_descriptor]; Da file
	mov rsi, input_name
	mov rdx, 0x1

.read_name:
	xor rax, rax; Read
	syscall
	cmp byte [rsi], 0xA; Check if at newline
	je  .exit_read_name
	inc rsi; Next byte in input_name
	inc r9; Increase length of string
	jmp .read_name

.exit_read_name:
	inc r12; person index

	mov rsi, bank_array
	add rsi, r12; index into ith person's bank account
	mov qword [rsi], r12

	jmp .read_names_loop

.exit_read_names_loop:
	mov rsp, r8; Restore rsp

	mov r13, bank_array
	mov rdi, qword [bank_array]

.print_bank_accounts:
	test r12, r12
	jz   .exit_print_bank_accounts
	dec  r12

	call print_itoa; void print_itoa(rdi n)
	add  r13, 0x8; Next qword
	mov  rdi, qword [r13]

	jmp .print_bank_accounts

.exit_print_bank_accounts:
	ret

_start:
	mov      rax, 0x02; open
	mov      rdi, input_file
	xor      rsi, rsi; no idea what int flags do
	xor      rdx, rdx; no idea what umode_t mode does
	syscall; call open and return file descriptor in rax
	mov      qword [input_file_descriptor], rax; store file descriptor for later use

	mov qword [output_file_descriptor], 1; STDOUT
	;   mov      rax, 0x55; creat()
	;   mov      rdi, output_file
	;   mov      rsi, qword [write_file_mode]
	;   syscall; file descriptor stored in rax
	;   mov      qword [output_file_descriptor], rax

	call solve

	; mov      rax, 0x3; close file
	; mov      rdi, qword [input_file_descriptor]; so the kernel knows what file to close (input_file_descriptor)
	; syscall; close file

	mov rax, 60; exit
	xor rdi, rdi; err_code 0
	syscall
	ret
