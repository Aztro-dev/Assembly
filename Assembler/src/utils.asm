section .text
global concat_str
; rdi = firststr
; rsi = secondstr
; output str in rax
concat_str:

	ret
global concat_str_nomalloc
; rdi = firststr (big enough for rsi)
; rsi = secondstr
; rax = new length; the str pointed to in rdi is modified
concat_str_nomalloc:
  push rdi
  push rsi
  ; Moves pointer to the first null byte of rdi
  .move_to_end:
    cmp byte[rdi], 0x0
    je .copy_loop
    inc rdi
    jmp .move_to_end

  .copy_loop:
    cmp byte[rsi], 0x0
    je .exit
    mov al, byte[rsi]
    mov byte[rdi], al
    inc rdi
    inc rsi

    jmp .copy_loop
  
  .exit:
  mov rax, rdi
  pop rsi
  pop rdi
  sub rax, rdi
  ret
