%define SYS_EXIT 60
%define SYS_WRITE 1
%define STDOUT 1

%macro println 1
  jmp %%p_str
%%msg db %1, 0x0a
%%p_str:
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, %%msg
  mov rdx, %%p_str - %%msg
  syscall
%endmacro

section .rodata

section .text
global _start

_start:
  println "Println macro"

  mov rax, SYS_EXIT
  mov rdi, 0x0 ; No errors
  syscall
