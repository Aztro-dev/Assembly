%define SYS_EXIT 60

section .text
global _start
_start:
  mov rax, SYS_EXIT
  mov rdi, 0x0
  syscall
  ret
