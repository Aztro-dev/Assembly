%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1

section .text
global _start

_start:
  mov rax, 0x0
  cpuid

  mov dword[string], ebx
  mov dword[string + 0x4], edx
  mov dword[string], ecx

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, string
  mov rdx, 12
  syscall

  
  mov rax, SYS_EXIT
  xor rdi, rdi
  ret

section .bss
string resd 3
