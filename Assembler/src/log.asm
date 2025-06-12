%include "src/constants.asm"

section .text
global write_err
write_err:
  mov r8, rsi
  add r8, 8

  sub rsp, rsi  ; sizeof buffer
  sub rsp, 8    ; sizeof control sequence characters

  ; color red
  mov byte[rsp], 0x1b
  mov byte[rsp + 1], '['
  mov byte[rsp + 2], '3'
  mov byte[rsp + 3], '1'
  mov byte[rsp + 4], 'm'

  mov r9, 0
  mov r10, rsp
  add r10, 5
  .copy_str_loop:
    cmp r9, rsi
    jae .exit_copy_str_loop
    mov al, byte[rdi + r9]
    mov byte[r10 + r9], al

    inc r9
    jmp .copy_str_loop
  .exit_copy_str_loop:

  mov byte[rsp + rsi + 4], 0x1b
  mov byte[rsp + rsi + 5], '['
  mov byte[rsp + rsi + 6], '0'
  mov byte[rsp + rsi + 7], 'm'

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, rsp
  mov rdx, r8
  syscall

  add rsp, r8

  ret

global write_log

section .rodata
red_text: db 0x1b, "[31m"
clear_color_text: db 0x1b, "[0m"
