section .data
message: db "Include", 0x0a, 0x0
message_len: equ $ - message

section .text
%ifndef PRINT_INCLUDE
%define PRINT_INCLUDE
global print_include

print_include:
  mov rax, 0x1 ; Write
  mov rdi, 0x1 ; STDOUT
  mov rsi, message
  mov rdx, message_len
  syscall
  
  ret
%endif
