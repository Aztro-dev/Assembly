%define SIMULATION_SPEED MAX_FPS / 7 ; 7 times per second
%define KEY_RIGHT 262
%define KEY_LEFT 263

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
  mov r10, qword[timer]
  cmp r10, SIMULATION_SPEED
  jl .exit
  mov r10, 0x0

  cmp byte[curr_piece], 0x0
  jne .skip_bag_pull
  call pull_from_bag
  .skip_bag_pull:

  xor rdi, rdi
  xor rsi, rsi
  mov dil, byte[curr_piece + 1] ; X_POS
  mov sil, byte[curr_piece + 2] ; Y_POS
  
  .clear_piece:
  mov r8b, 0x0 ; clear prev
  cmp byte[curr_piece], I_PIECE
  je .clear_i_piece
  cmp byte[curr_piece], O_PIECE
  je .clear_o_piece
  cmp byte[curr_piece], T_PIECE
  je .clear_t_piece
  cmp byte[curr_piece], S_PIECE
  je .clear_s_piece
  cmp byte[curr_piece], Z_PIECE
  je .clear_z_piece
  cmp byte[curr_piece], L_PIECE
  je .clear_l_piece
  cmp byte[curr_piece], J_PIECE
  je .clear_j_piece

  .clear_i_piece:
  cmp sil, 19
  jge .reset
  test_pixels NONE, RIGHT, RIGHT, RIGHT
  jnz .reset
  plot_piece NONE, RIGHT, RIGHT, RIGHT
  jmp .exit_clears

  .clear_o_piece:
  cmp sil, 18
  jge .reset
  test_pixels DOWN + RIGHT, RIGHT
  jnz .reset
  plot_piece RIGHT, RIGHT, DOWN, LEFT
  jmp .exit_clears

  .clear_t_piece:
  cmp sil, 19
  jge .reset
  test_pixels NONE, RIGHT, RIGHT
  jnz .reset
  plot_piece NONE, RIGHT, RIGHT, LEFT + UP
  jmp .exit_clears

  .clear_s_piece:
  cmp sil, 19
  jge .reset
  test_pixels NONE, RIGHT, UP + RIGHT
  jnz .reset
  plot_piece NONE, RIGHT, UP, RIGHT
  jmp .exit_clears

  .clear_z_piece:
  cmp sil, 19
  jge .reset
  test_pixels UP, DOWN + RIGHT, RIGHT
  jnz .reset
  plot_piece RIGHT, RIGHT, UP + LEFT, LEFT
  jmp .exit_clears

  .clear_l_piece:
  cmp sil, 19
  jge .reset
  test_pixels DOWN, RIGHT, RIGHT
  jnz .reset
  plot_piece NONE, DOWN, RIGHT, RIGHT
  jmp .exit_clears

  .clear_j_piece:
  cmp sil, 19
  jge .reset
  test_pixels DOWN, RIGHT, RIGHT
  jnz .reset
  plot_piece DOWN, RIGHT, RIGHT, UP
  jmp .exit_clears

  .exit_clears:
  inc sil
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
  jmp .exit_draws

  .draw_o_piece:
  plot_piece RIGHT, RIGHT, DOWN, LEFT
  jmp .exit_draws

  .draw_t_piece:
  plot_piece NONE, RIGHT, RIGHT, LEFT + UP
  jmp .exit_draws

  .draw_s_piece:
  plot_piece NONE, RIGHT, UP, RIGHT
  jmp .exit_draws

  .draw_z_piece:
  plot_piece RIGHT, RIGHT, UP + LEFT, LEFT
  jmp .exit_draws

  .draw_l_piece:
  plot_piece NONE, DOWN, RIGHT, RIGHT
  jmp .exit_draws

  .draw_j_piece:
  plot_piece DOWN, RIGHT, RIGHT, UP
  jmp .exit_draws

  .exit_draws:
  mov byte[curr_piece + 1], dil
  mov byte[curr_piece + 2], sil
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

create_bag:
  xor r8, r8 ; iterator
  .loop:
    cmp r8, 7
    jge .exit_loop
    
    ; int random = rand() % (7 - i);
    call rand
    .after_rand:
    mov r9, 0x7
    sub r9, r8
    xor rdx, rdx
    div r9
    mov rax, rdx ; random = rax
    ; bag[i] = piece_list[random]
    mov bl, byte[piece_list + rax]
    mov byte[bag + r8], bl

    ; piece_list[random] = piece_list[6 - i];
    mov rcx, 6
    sub rcx, r8
    mov dl, byte[piece_list + rcx]
    mov byte[piece_list + rax], dl
    ; piece_list[6 - i] = temp;
    mov byte[piece_list + rcx], bl

    inc r8
    jmp .loop
  .exit_loop:
  ret

pull_from_bag:
  cmp byte[bag + 0x6], 0x0
  jne .skip_bag_reset
  call create_bag
  .skip_bag_reset:
  
  mov r9, 0x0
  .next_bag_piece_loop:
    cmp byte[bag + r9], 0x0
    jne .exit_next_bag_piece_loop
    inc r9
    jmp .next_bag_piece_loop
  .exit_next_bag_piece_loop:
  mov al, byte[bag + r9]
  mov byte[bag + r9], 0x0
  mov byte[curr_piece], al
  mov byte[curr_piece + 1], 0x3
  mov byte[curr_piece + 2], 0x0
  ret

section .data
; curr_piece: TYPE, POS_X, POS_Y, ROTATION
curr_piece db NONE, 0x3, 0x0, 0x0
piece_list db I_PIECE, O_PIECE, T_PIECE, S_PIECE, Z_PIECE, L_PIECE, J_PIECE
piece_movement db 0x0
bag times(7) db 0x0
timer dq 0x0

section .rodata
