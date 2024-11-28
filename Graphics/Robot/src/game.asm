struc robot_struc
  .model: resq 1 ; Model type
  .position: resd 3 ; Vector3 (3 floats)
  .heading: resd 1 ; float
endstruc

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
  mov rdi, qword[robot + robot_struc.model]
  mov edx, dword[scale]
  mov r8d, dword[tint]
  movaps xmm0, [zeroes]
  call DrawModel

  ; mov rdx, dword[robot + robot_struc.heading]
  ; mov r8, 
  
  ret

section .rodata
align 16
zeroes dd 0.0, 0.0, 0.0, 0.0
