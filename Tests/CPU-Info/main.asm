%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1

section .text
global _start

_start:
  mov rax, 0x0
  cpuid

  mov dword[string], ebx
  mov dword[string + 0x4], ecx
  mov dword[string + 0x8], edx
  mov byte [string + 0x0c], 0x0a 

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, string
  mov rdx, 13
  syscall
  
  mov rax, SYS_EXIT
  xor rdi, rdi
  syscall
  ret

section .bss
string resb 13
