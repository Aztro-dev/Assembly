%define SYS_EXIT 60

%include "src/elf.asm"

section .text
global _start
_start:
  mov rax, SYS_EXIT
  mov rdi, 0x0
  syscall
