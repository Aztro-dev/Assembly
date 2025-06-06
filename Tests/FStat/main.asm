%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_FSTAT 5
%define SYS_EXIT 60

struc stat
  .pad resb 48
  .size resd 1
endstruc

section .data
number_buffer db 20 dup(0x0)
newline db 0x0a

section .bss
fd resd 1
finfo resq 1

section .text
global _start
_start:
  mov rax, SYS_OPEN
  mov rdi, [rsp + 16] ; argv[1]
  xor rsi, rsi ; O_RDONLY
  xor rcx, rcx
  syscall

  mov qword[fd], rax

  mov rax, SYS_FSTAT
  mov rdi, qword[fd]
  mov rsi, finfo
  syscall

  mov rax, SYS_CLOSE
  mov edi, dword [fd]
  syscall

  mov edi, dword[finfo + stat.size]
  call print_uint64

  mov rax, SYS_EXIT
  xor rdi, rdi
  syscall

; printing stuff:
print_uint64:
	mov  r8, 10; Base 10

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
	mov rax, 0x1
	mov rdi, 0x1
	lea rsi, [number_buffer + 20]
	mov byte [rsi], 0x0a
	sub rsi, r9
	mov rdx, r9
	inc rdx
	syscall

	ret
