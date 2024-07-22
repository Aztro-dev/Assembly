%define SIMULATION_SPEED MAX_FPS / 3 ; 3 times per second

%macro plot_pixel 3
  mov r8b, %1; TYPE

  xor rbx, rbx
  mov bl, %2 ; POS_X

  xor rax, rax
  mov al, %3 ; POS_Y
  mov r9, 10 ; Offset
  mul r9
  
  mov byte[board + rax + rbx], r8b

%endmacro

section .text
global move_piece
move_piece:
  mov r10, qword[timer]
  cmp r10, SIMULATION_SPEED
  jl .exit
  mov r10, 0x0

  cmp byte[curr_piece], 0x0
  je .exit

  plot_pixel 0x0, byte[curr_piece + 1], byte[curr_piece + 2] ; clear prev
  inc byte[curr_piece + 2]
  cmp byte[curr_piece + 2], 20
  jl .skip_reset
  mov byte[curr_piece + 2], 0x0
  .skip_reset:
  plot_pixel byte[curr_piece], byte[curr_piece + 1], byte[curr_piece + 2] ; clear prev
  
  .exit:
  inc r10
  mov qword[timer], r10
  ret

section .data
; curr_piece: TYPE, POS_X, POS_Y, ROTATION
curr_piece db 0x1, 0x0, 0x0, 0x0
timer dq 0x0
