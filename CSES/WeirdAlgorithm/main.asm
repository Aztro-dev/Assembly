section .text
global _start

_start:
  mov rax, 60 ; exit
  mov rdi, 0
  syscall
