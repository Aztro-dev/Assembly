%define SYS_BRK 12

section .note.GNU-stack

section .text

extern strlen

global append_asm

; char* malloc_asm(const char* str1, const char* str2)

append_asm:
push rsi
push rdi

mov rax, SYS_BRK
mov rdi, 0x0
syscall

mov qword[output_str], rax

; Find length of first string
call strlen
mov r8, rax
mov rdi, rsi
call strlen

add r8, rax
mov rax, qword[output_str]
lea rdi, [rax + r8]
mov rax, SYS_BRK
syscall
mov rdx, r8

; Put the string data into the new location
mov rdi, output_str
pop rsi

.loop:
	mov al, byte[rsi]
	cmp al, 0x0
	je .next_str
	mov byte[rdi], al
	inc rsi
	inc rdi
	jmp .loop
	.next_str:
	pop rsi
	.other_loop:
	mov al, byte[rsi]
	cmp al, 0x0
	je .exit
	mov byte[rdi], al
	inc rsi
	inc rdi
	jmp .other_loop
	.exit:
	mov byte[rdi], 0x0
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, output_str
	mov rdx, 10
	syscall
	ret

; int strlen(const char* str)
strlen:
    xor rcx, rcx
    .loop:
        mov al, byte [rdi]
        cmp al, 0x0
        je .exit
        inc rcx
        jmp .loop

    .exit:
    mov rax, rcx
    ret
section .bss
output_str: resq 1
