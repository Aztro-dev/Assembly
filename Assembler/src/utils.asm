%include "src/constants.asm"

section .text
global concat_str
; rdi = firststr
; rsi = secondstr
; output str in rax
concat_str:
  ; Find length of firststr
  xor r8, r8 ; length
  .firststr_len_loop:
    cmp byte[rdi + r8], 0x0
    je .exit_firststr_len_loop

    inc r8

    jmp .firststr_len_loop

  .exit_firststr_len_loop:
  ; Find length of secondstr
  xor r9, r9 ; length
  .secondstr_len_loop:
    cmp byte[rsi + r9], 0x0
    je .exit_secondstr_len_loop

    inc r9

    jmp .secondstr_len_loop

  .exit_secondstr_len_loop:
  ; Malloc firststr length + secondstr length + 1 (because we still need the null byte)
  add r8, r9
  inc r8
  push rdi
  push rsi

  mov rdi, r8 ; num elements
  mov rsi, 1  ; each element is 1 byte
  call malloc

  pop rsi
  pop rdi

  xor r8, r8
  .append_firststr:
    cmp byte[rdi + r8], 0x0
    je .exit_append_firststr

    mov bl, byte[rdi + r8]
    mov byte[rax + r8], bl

    inc r8

    jmp .append_firststr

  .exit_append_firststr:
  xor r9, r9
  add rax, r8

  .append_secondstr:
    cmp byte[rsi + r9], 0x0
    je .exit_append_secondstr

    mov bl, byte[rsi + r9]
    mov byte[rax + r9], bl

    inc r9
    jmp .append_secondstr

  .exit_append_secondstr:
  sub rax, r8
  ; return malloc address
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

global malloc
; rdi = amount of elements
; rsi = number of bytes per element (sizeof element)
; output rax = pointer to allocated data
malloc:
  mov rax, rdi
  mul rsi
  mov r8, rax

  mov rax, SYS_BRK
  mov rdi, 0x0
  syscall
  push rax ; top of the heap (currently)

  mov rdi, rax
  add rdi, r8
  mov rax, SYS_BRK
  syscall
  
  pop rax
  ret
