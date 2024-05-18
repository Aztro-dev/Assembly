%define SYS_EXIT 60
section .data
number dd 123.456
format db "%d", 0x0a

section .text
extern printf
global _start
_start:
  push rbp ; Aligns stack 

  movss xmm0, dword[number]
  cvtss2si rsi, xmm0
  mov rax, 0x1
  mov rdi, format
  call printf

  pop rbp

  mov rax, SYS_EXIT
  mov rdi, 0x0
  syscall
