%define SYS_WRITE 1
%define SYS_FORK 57
%define SYS_EXIT 60

%define STDOUT 1

section .text
global _start

_start:
  mov rax, SYS_FORK
  syscall

  cmp rax, 0x0
  jne .child
  
  .parent:
  xor rcx, rcx
  .parent_loop:
    cmp rcx, 0x7FFFFFFF
    jge .exit_parent_loop
    inc rcx
    jmp .parent_loop
  .exit_parent_loop:
  mov rsi, parent_message
  mov rdx, parent_message_len
  
  jmp .exit
  .child:
  xor rcx, rcx
  .child_loop:
    cmp rcx, 0x7FFFFFFF
    jge .exit_child_loop
    inc rcx
    jmp .child_loop
  .exit_child_loop:
  mov rsi, child_message
  mov rdx, child_message_len

  .exit:
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  syscall

  mov rax, SYS_EXIT
  xor rdi, rdi
  syscall
  ret

section .data
parent_message db "This is the parent!", 0x0a
parent_message_len equ $ - parent_message
child_message db "This is the child!", 0x0a
child_message_len equ $ - child_message
