%define SYS_EXIT 60
%define SYS_WRITE 1
%define STDOUT 1

%macro print_str 2
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, %1
  mov rdx, %2
  syscall
%endmacro

section .rodata
msg db "Macros", 0x0
msg_len equ $ - msg

section .text
global _start

_start:
  print_str msg, msg_len

  mov rax, SYS_EXIT
  mov rdi, 0x0 ; No errors
  syscall
