%define SYS_READ  0
%define SYS_WRITE 1
%define SYS_BRK   12
%define SYS_EXIT  60

%define STDIN  0
%define STDOUT 1
%define STDERR 2

%include "src/elf.asm"
%include "src/file.asm"

section .text
global _start
_start:
  mov rdi, [rsp + 2 * 0x8] ; argv[1]
  call open_file

  mov qword[file_fd], rax

  ; Get starting address for later SYS_BRK
  mov rax, SYS_BRK
  mov rdi, 0 ; null
  syscall
  mov qword[buf], rax

  mov rdi, qword[file_fd]
  call get_file_size

  mov qword[buf_size], rax

  ; Allocate enough memory for the buffer
  mov rax, SYS_BRK
  mov rdi, qword[buf]
  add rdi, qword[buf_size]
  syscall

  mov rax, SYS_READ
  mov rdi, qword[file_fd]
  mov rsi, qword[buf]
  mov rdx, qword[buf_size]
  syscall

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, qword[buf]
  mov rdx, qword[buf_size]
  syscall

  mov rax, SYS_CLOSE
  mov rdi, qword[file_fd]
  syscall

  mov rax, SYS_EXIT
  mov rdi, 0x0
  syscall

section .rodata

section .bss
file_fd: resq 1

buf: resq 1
buf_size: resq 1
