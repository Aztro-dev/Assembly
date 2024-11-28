section .rodata
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

  lea rdi, qword[robot + robot_struc.model]
  mov rdx, [tint]
  movaps xmm0, [zeroes]
  movss xmm1, [scale]
  ; call DrawModel

  leave
  ret

section .rodata
align 16
zeroes dd 0.0, 0.0, 0.0, 0.0
