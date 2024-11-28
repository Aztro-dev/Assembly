struc robot_struc
  .model: resq 1 ; Model type
  .position: resq 1 ; Vector3 (3 floats)
  .heading: resd 1 ; float
endstruc

section .rodata
scale dd 1.0
tint dd WHITE

section .bss
robot resb robot_struc_size

section .text
global run_game
run_game:
  ret

global draw_objects
draw_objects:
  mov rdi, qword[robot + robot_struc.model]
  mov rsi, qword[robot + robot_struc.position]
  xor rdx, rdx
  mov edx, dword[scale]

  ; mov rdx, dword[robot + robot_struc.heading]
  ; mov r8, 
  
  ret
