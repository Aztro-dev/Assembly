section .data
file_name db "x.in", 0x0
number_buffer db 20 dup(0x0)
newline db 0x0a

section .bss
file_descriptor resq 0x1 ; To store the file descriptor for the "x.in" file
section .text
global  _start

solve:
	ret

_start:
	mov     rax, 0x02; Open
	mov     rdi, file_name
	xor     rsi, rsi; No flags
	xor     rdx, rdx; umode_t = 0
	syscall ; FD stored in rax
	mov     qword [file_descriptor], rax

	;    solve(void) -> r8 num
	call solve

	;    xor r8, r8
	;    mov r8b, byte [curr_digit]
	mov  rdi, r8; num
	;    print_unit64_t(rdi num) -> void
	call print_uint64_t

	mov rax, 60
	mov rdi, 0
	syscall

	; print_uint64_t(rdi num) -> void

print_uint64_t:
	push rax
	push rsi
	push rdx

	mov r8, 10; Base 10

	mov rax, rdi
	mov rsi, number_buffer
	add rsi, 19; Last digit of buffer

.loop:
	cmp rax, 0x0
	jle .exit_loop
	xor rdx, rdx
	div r8
	add dl, 48; To ASCII num
	mov byte [rsi], dl
	dec rsi
	jmp .loop

.exit_loop:
	mov rax, 0x1; Read
	mov rdi, 0x1; STDOUT
	mov rsi, number_buffer
	mov rdx, 20; 20 characters max
	syscall

	pop rdx
	pop rsi
	pop rax
	ret
