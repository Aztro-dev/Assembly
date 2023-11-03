section .text
global asm_min



; rax min(rcx num1, rdx num2);
asm_min:
  mov rax, rcx
  sub rax, rdx

  .abs:

;mov bx,ax
;add bx,bx
;sbc bx,bx
;xor ax,bx
;sub ax,bx
mov rbx, rax
add rbx, rbx
sbb rbx, rbx
xor rax, rbx
sub rax, rbx
  
  ; y = x >> 63
  ; abs(x) = (x ^ y) - y
  ; mov rbx, rax
  ; shr rbx, 63
  ; xor rbx, rax
  ; sub rax, rbx

  add rax, rdx
  ret
