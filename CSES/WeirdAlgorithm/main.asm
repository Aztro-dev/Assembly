section .text
global _start

; read(rsi buff, rdx size)
read:
  xor rax, rax ; Read
  xor rdi, rdi ; Stdin
  syscall
  ret

_start:
  mov rsi, buff
  mov rdx, 3
  ; read(rsi buff, rdx size)
  call read

  mov rax, 60 ; exit
  mov rdi, 0
  syscall

section .bss
buff: resb 0x13 ; 19 in decimal
