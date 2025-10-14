%define O_RDONLY 0
%define O_DIRECTORY 1 << 21

%define SYS_OPEN 2
%define SYS_CLOSE 3
%define SYS_EXIT 60
%define SYS_GETDENTS64 217

%define BUF_SIZE 4096

section .rodata
file_name db ".", 0x0

section .bss
fd resq 1

section .text
; rdi: file descriptor
read_dir:
  push rbp
  mov rbp, rsp
  sub rsp, BUF_SIZE

  mov rax, SYS_GETDENTS64
  ; rdi has the file descriptor from the open syscall in main
  mov rsi, rsp
  add rsi, BUF_SIZE

  mov rdx, BUF_SIZE
  syscall

  add rsp, BUF_SIZE
  pop rbp
  ret
global _start
_start:
  mov rax, SYS_OPEN
  mov rdi, file_name
  mov rsi, O_RDONLY 
  or rsi, O_DIRECTORY
  xor rdx, rdx
  syscall

  mov [fd], rax
  mov rdi, rax
  call read_dir
  
  mov rax, SYS_CLOSE
  mov rdi, [fd]
  syscall
  
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall
  ret
