section .rodata
align 16
scale dd 1.0
tint dd WHITE

section .bss
align 16 ; Just in case model loading needs an aligned struct
robot resb robot_struc_size

section .text
global run_game
run_game:
  ret

global draw_objects
draw_objects:
  push rbp
  mov rbp, rsp

  mov rdi, qword[robot + robot_struc.model]
  lea rsi, [zeroes]
  movss xmm0, [scale]
  lea rdx, [tint]
  ; call DrawModel

  movaps xmm0, [zeroes]
  movss xmm1, [scale]
  movss xmm2, [scale]
  movss xmm3, [scale]
  mov r8, WHITE
  mov rdi, WHITE
  call DrawCube

  leave
  ret

section .rodata
align 16
zeroes dd 0.0, 0.0, 0.0, 0.0
