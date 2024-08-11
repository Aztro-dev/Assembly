%define SIMULATION_SPEED MAX_FPS / 7 ; 7 times per second

%define KEY_SPACE 32
%define KEY_RIGHT 262
%define KEY_LEFT 263
%define KEY_DOWN 264

%define I_PIECE 0x1
%define O_PIECE 0x2
%define T_PIECE 0x3
%define S_PIECE 0x4
%define Z_PIECE 0x5
%define L_PIECE 0x6
%define J_PIECE 0x7

%define NONE  0x0
%define UP    0x1
%define DOWN  0x2
%define LEFT  0x4
%define RIGHT 0x8

%include "src/bag.asm"

extern IsKeyPressed
extern GetFrameTime

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

%macro plot_piece 1-* 
  %assign x 0
  %assign y 0
  %rep  %0 
    %if %1 & UP
      sub sil, 0x1
      %assign y y-1
    %endif
    %if %1 & DOWN
      add sil, 0x1
      %assign y y+1
    %endif
    %if %1 & LEFT
      sub dil, 0x1
      %assign x x-1
    %endif
    %if %1 & RIGHT
      add dil, 0x1
      %assign x x+1
    %endif
    plot_pixel r8b, dil, sil
  %rotate 1 
  %endrep 
  sub dil, x
  sub sil, y
%endmacro

%macro test_pixels 1-*
  xor rbx, rbx
  mov rcx, 0x1
  %assign x 0
  %assign y 0
  %rep  %0 
    %if %1 & UP
      dec sil
      %assign y y-1
    %endif
    %if %1 & DOWN
      inc sil
      %assign y y+1
    %endif
    %if %1 & LEFT
      dec dil
      %assign x x-1
    %endif
    %if %1 & RIGHT
      inc dil
      %assign x x+1
    %endif
    xor rax, rax
    inc sil
    mov al, sil ; POS_Y
    mov r9, 10 ; Offset
    mul r9
    dec rsi

    mov al, byte[board + rax + rdi]
    test al, al
    cmovnz rbx, rcx
  %rotate 1 
  %endrep 
  sub dil, x
  sub sil, y
  test rbx, rbx
%endmacro

%macro debug_test_pixels 1-*
  xor rbx, rbx
  mov rcx, 0x1
  %assign x 0
  %assign y 0
  %rep  %0 
    %if %1 & UP
      dec sil
      %assign y y-1
    %endif
    %if %1 & DOWN
      inc sil
      %assign y y+1
    %endif
    %if %1 & LEFT
      dec dil
      %assign x x-1
    %endif
    %if %1 & RIGHT
      inc dil
      %assign x x+1
    %endif
    xor rax, rax
    inc sil
    mov al, sil ; POS_Y
    mov r9, 10 ; Offset
    mul r9
    dec rsi
    
    mov r8, rax
    mov al, byte[board + r8 + rdi]
    test al, al
    cmovnz rbx, rcx
    mov al, 0x2
    mov byte[board + r8 + rdi], al
  %rotate 1 
  %endrep 
  sub dil, x
  sub sil, y
  test rbx, rbx
%endmacro

%macro compare_under_pixel 1-* 
  %rep  %0 
    %if %1 & UP
      dec sil
    %endif
    %if %1 & DOWN
      inc sil
    %endif
    %if %1 & LEFT
      dec dil
    %endif
    %if %1 & RIGHT
      inc dil
    %endif
  %rotate 1 
  %endrep 
  xor rax, rax
  inc sil
  mov al, sil ; POS_Y
  mov r9, 10 ; Offset
  mul r9
  mov r9, rax
  dec rsi

  xor r10, r10
  mov r10b, dil

  mov al, byte[board + r9 + r10]
  test al, al
%endmacro

section .text
global move_piece
move_piece:
  mov rdi, KEY_SPACE
  call IsKeyPressed
  test rax, 0x1
  jnz .skip_time_check

  mov rdi, KEY_DOWN
  call IsKeyDown

  mov r10, qword[timer]

  test rax, 0x1
  jz .normal_time
  cmp r10, SIMULATION_SPEED / 4
  jl .exit
  jmp .skip_time_check

  .normal_time:
  cmp r10, SIMULATION_SPEED
  jl .exit

  .skip_time_check:
  mov r10, 0x0

  cmp byte[curr_piece], 0x0
  ; If there's no current piece, pull from the bag
  ccall e, pull_from_bag

  xor rdi, rdi
  xor rsi, rsi
  mov dil, byte[curr_piece + 1] ; X_POS
  mov sil, byte[curr_piece + 2] ; Y_POS
  
  .drop_piece:
  call drop_piece
  push rax

  .clear_piece:
  mov r8b, 0x0 ; clear prev
  call draw_piece

  pop rax
  inc sil

  test rax, 0x1
  jnz .skip_hard_drop_check
  push rdi
  mov rdi, KEY_SPACE
  call IsKeyPressed
  pop rdi
  test rax, 0x1
  jnz .drop_piece
  .skip_hard_drop_check:
  push rax
  mov r8b, byte[curr_piece]

  .move_piece:
  add dil, byte[piece_movement]
  cmp byte[curr_piece], I_PIECE
  je .move_i_piece
  cmp byte[curr_piece], O_PIECE
  je .move_o_piece
  cmp byte[curr_piece], T_PIECE
  je .move_t_piece
  cmp byte[curr_piece], S_PIECE
  je .move_s_piece
  cmp byte[curr_piece], Z_PIECE
  je .move_z_piece
  cmp byte[curr_piece], L_PIECE
  je .move_l_piece
  cmp byte[curr_piece], J_PIECE
  je .move_j_piece
  jmp .exit_movements

  .move_i_piece:
  cmp dil, 10 - 3
  jge .undo_move
  cmp dil, -1
  jle .undo_move
  test_pixels NONE
  jnz .undo_move
  add dil, 0x2
  test_pixels RIGHT
  sub dil, 0x2
  test rbx, rbx
  jnz .undo_move
  jmp .exit_movements

  .move_o_piece:
  cmp dil, 10 - 2
  jge .undo_move
  cmp dil, -2
  jle .undo_move
  test_pixels RIGHT, UP, DOWN + RIGHT, UP 
  jnz .undo_move
  jmp .exit_movements

  .move_t_piece:
  cmp dil, 10 - 2
  jge .undo_move
  cmp dil, -1
  jle .undo_move
  test_pixels UP, UP + RIGHT
  jnz .undo_move
  add dil, 0x2
  test_pixels UP, UP + LEFT
  sub dil, 0x2
  test rbx, rbx
  jnz .undo_move
  jmp .exit_movements

  .move_s_piece:
  cmp dil, 10 - 2
  jge .undo_move
  cmp dil, -1
  jle .undo_move
  test_pixels NONE, UP + RIGHT
  jnz .undo_move
  test_pixels RIGHT, UP + RIGHT
  jnz .undo_move
  jmp .exit_movements

  .move_z_piece:
  cmp dil, 10 - 2
  jge .undo_move
  cmp dil, -1
  jle .undo_move
  test_pixels UP + RIGHT, UP + LEFT
  jnz .undo_move
  inc dil
  test_pixels UP + RIGHT, UP + LEFT
  dec dil
  test rbx, rbx
  jnz .undo_move
  jmp .exit_movements

  .move_l_piece:
  cmp dil, 10 -2
  jge .undo_move
  cmp dil, -1
  jle .undo_move
  test_pixels UP, DOWN
  jnz .undo_move
  ; "DOWN + RIGHT" is a pixel inside the tetrimino.
  ; It's just there so that we can reach the other end of the tetrimino.
  test_pixels UP, DOWN + RIGHT, RIGHT
  jnz .undo_move
  jmp .exit_movements

  .move_j_piece:
  cmp dil, 10 - 2
  jge .undo_move
  cmp dil, -1
  jle .undo_move
  ; "UP" and "RIGHT" are pixels inside the tetrimino.
  ; They're just there so that we can reach the other end of the tetrimino.
  test_pixels RIGHT, LEFT, RIGHT, UP + RIGHT 
  jnz .undo_move
  add dil, 0x2
  test_pixels NONE, UP
  sub dil, 0x2
  test rbx, rbx
  jnz .undo_move
  jmp .exit_movements

  .undo_move:
  sub dil, byte[piece_movement]

  .exit_movements:
  mov byte[piece_movement], 0x0
  
  .draw_piece:
  call draw_piece

  mov byte[curr_piece + 1], dil
  mov byte[curr_piece + 2], sil

  pop rax
  test rax, 0x1
  jnz .reset
  jmp .exit

  .reset:
  call pull_from_bag
  jmp .exit

  .exit:
  inc r10
  mov qword[timer], r10

  mov rdi, KEY_LEFT
  call IsKeyPressed
  test rax, rax
  jz .check_right_key
  mov byte[piece_movement], -0x1
  jmp .exit_key_checks
  .check_right_key:
  mov rdi, KEY_RIGHT
  call IsKeyPressed
  test rax, rax
  jz .exit_key_checks
  mov byte[piece_movement], 0x1
  .exit_key_checks:

  ret

draw_piece:
  cmp byte[curr_piece], I_PIECE
  je .draw_i_piece
  cmp byte[curr_piece], O_PIECE
  je .draw_o_piece
  cmp byte[curr_piece], T_PIECE
  je .draw_t_piece
  cmp byte[curr_piece], S_PIECE
  je .draw_s_piece
  cmp byte[curr_piece], Z_PIECE
  je .draw_z_piece
  cmp byte[curr_piece], L_PIECE
  je .draw_l_piece
  cmp byte[curr_piece], J_PIECE
  je .draw_j_piece

  .draw_i_piece:
  plot_piece NONE, RIGHT, RIGHT, RIGHT
  jmp .exit

  .draw_o_piece:
  plot_piece RIGHT, RIGHT, DOWN, LEFT
  jmp .exit

  .draw_t_piece:
  plot_piece NONE, RIGHT, RIGHT, LEFT + UP
  jmp .exit

  .draw_s_piece:
  plot_piece NONE, RIGHT, UP, RIGHT
  jmp .exit

  .draw_z_piece:
  plot_piece RIGHT, RIGHT, UP + LEFT, LEFT
  jmp .exit

  .draw_l_piece:
  plot_piece NONE, DOWN, RIGHT, RIGHT
  jmp .exit

  .draw_j_piece:
  plot_piece DOWN, RIGHT, RIGHT, UP
  jmp .exit

  .exit:
  ret

drop_piece:
  cmp byte[curr_piece], I_PIECE
  je .drop_i_piece
  cmp byte[curr_piece], O_PIECE
  je .drop_o_piece
  cmp byte[curr_piece], T_PIECE
  je .drop_t_piece
  cmp byte[curr_piece], S_PIECE
  je .drop_s_piece
  cmp byte[curr_piece], Z_PIECE
  je .drop_z_piece
  cmp byte[curr_piece], L_PIECE
  je .drop_l_piece
  cmp byte[curr_piece], J_PIECE
  je .drop_j_piece

  .drop_i_piece:
  cmp sil, 19
  jge .reset
  test_pixels NONE, RIGHT, RIGHT, RIGHT
  jnz .reset
  jmp .exit_drops

  .drop_o_piece:
  cmp sil, 18
  jge .reset
  test_pixels DOWN + RIGHT, RIGHT
  jnz .reset
  jmp .exit_drops

  .drop_t_piece:
  cmp sil, 19
  jge .reset
  test_pixels NONE, RIGHT, RIGHT
  jnz .reset
  jmp .exit_drops

  .drop_s_piece:
  cmp sil, 19
  jge .reset
  test_pixels NONE, RIGHT, UP + RIGHT
  jnz .reset
  jmp .exit_drops

  .drop_z_piece:
  cmp sil, 19
  jge .reset
  test_pixels UP, DOWN + RIGHT, RIGHT
  jnz .reset
  jmp .exit_drops

  .drop_l_piece:
  cmp sil, 19
  jge .reset
  test_pixels DOWN, RIGHT, RIGHT
  jnz .reset
  jmp .exit_drops

  .drop_j_piece:
  cmp sil, 19
  jge .reset
  test_pixels DOWN, RIGHT, RIGHT
  jnz .reset
  jmp .exit_drops

  .reset:
  or rax, 0x1
  dec sil
  ret

  .exit_drops:
  xor rax, rax
  ret

section .data
piece_movement db 0x0
timer dq 0x0
