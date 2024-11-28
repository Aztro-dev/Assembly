; Debug tools

%define SYS_WRITE 0x1
%define STDOUT 0x1

%ifidn  __OUTPUT_FORMAT__, elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif

%macro  multipush 1-* 
  %rep  %0 
  	push    %1 
  %rotate 1 
  %endrep 
%endmacro

%macro  multipop 1-* 
  %rep  %0 
  %rotate -1 
  	pop    %1 
  %endrep 
%endmacro

; Conditional Call (ccallcc)
%macro ccall 2
	j%-1 %%skip
	call %2
	%%skip:
%endmacro

%macro  clear 1-* 
  %rep  %0 
  	xor %1, %1
  %rotate 1 
  %endrep 
%endmacro

section .text
extern printf

global print_formatted
; rax = num_args
; rdi = formatted_string
; rsi-r9 = args
; xmm0-xmm7 = args
print_formatted:
	push rbp; creates stack frame

	call  printf

	pop rbp; realigns stack
	ret
	
clear_number_buffer:
	push rsi
	push rcx
	mov  rcx, 20; 20 characters
	mov  rsi, number_buffer

.clear_loop:
	mov byte [rsi], 0x0; Clear byte
	inc rsi
	cmp rcx, 0x0; See if rcx is 0
	je  .exit_loop
	dec rcx
	jmp .clear_loop

.exit_loop:
	pop rcx
	pop rsi
	ret

global print_int
; rdi input
print_int:
	push rax
	push rsi
	push rdx
	mov  r8, 10; Base 10

	cmp rdi, 0x0
	jne .not_zero
	mov byte[number_buffer + 20], '0'
	mov r9, 0x1
	jmp .exit_loop

	.not_zero:

	mov rax, rdi
	mov rsi, number_buffer
	add rsi, 19; Last digit of buffer
	mov r9, 0x0; Size

.loop:
	cmp rax, 0x0
	jle .exit_loop
	xor rdx, rdx
	div r8
	add dl, 48; To ASCII num
	mov byte [rsi], dl
	dec rsi
	inc r9
	jmp .loop

.exit_loop:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, [number_buffer + 20]
	sub rsi, r9
	mov rdx, r9
	syscall

	call print_newline

	pop rdx
	pop rsi
	pop rdx

	call clear_number_buffer

	ret

global print_newline
print_newline:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, newline
	mov rdx, 0x1
	syscall
	ret

global print_string
print_string:
	mov rdx, rsi
	mov rsi, rdi
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	syscall
	ret

; rdi = seed
; https://stackoverflow.com/a/1026370
rand:
	mov r9, rdi
  call GetTime ; Result stored in xmm0
  cvttpd2dq xmm1, xmm0
  cvtdq2pd xmm1, xmm0
  subps xmm0, xmm1 ; We only care about the decimal
  cvttpd2dq xmm0, xmm0
  movq rax, xmm0

  xor rdx, rdx
  div r9 ; passed in by user
  mov rax, rdx ; remainder
	ret

section .data
number_buffer db 20 dup(0x0)
newline db 0x0a
