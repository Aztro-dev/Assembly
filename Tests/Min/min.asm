section .text
global asm_min

; rax min(rdi num1, rsi num2);
asm_min:
  mov rax, rcx
  sub rax, rdx
  ; abs(x) = (x ^ y) - y
  ; y = x >> 63
  mov rbx, rax
  shr rbx, 63
  xor rax, rbx
  sub rax, rbx
  add rax, rdx
  ret
