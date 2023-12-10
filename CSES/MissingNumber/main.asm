section .data
uint64_buffer db 20 dup(0x0) ; 20 Digits in uint64_t

n dq 1

section .text
global  _start

read_int:
    mov rdi, 0x0 ; STDIN
    mov rsi, uint64_buffer
    mov rdx, 0x1 ; One character at a time
    .read_loop:
        xor rax, rax ; READ syscall
        syscall
        cmp byte [rsi], 0x0 ; Null character
        je .exit_read_loop
        cmp byte [rsi], 0x0a ; newline
        je .exit_read_loop
        sub rsi, 20
        cmp rsi, uint64_buffer
        je .exit_read_loop
        add rsi, 21 ; Reset to previous value and increment
        jmp .read_loop
    .exit_read_loop:
    mov rdi, uint64_buffer
    ret
_start:
	call read_int
	mov qword [n], rax
	ret

	mov rax, 60; exit
	xor rdi, rdi; Error code 0
	syscall
	ret


