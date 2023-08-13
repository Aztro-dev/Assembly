section .text
global _start
_start:
  mov rax, 65
  mov rax, 69
  mov rbx, 65
  mov rbx, 69

  mov rax, 60 ; exit
  mov rdi, 0
  syscall ; exit
