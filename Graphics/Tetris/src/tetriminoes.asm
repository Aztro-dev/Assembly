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

%macro  plot_pixel_direction 1-* 
  %rep  %0 
    %if %1 = UP
      sub sil, 0x1
    %endif
    %if %1 = DOWN
      add sil, 0x1
    %endif
    %if %1 = LEFT
      sub dil, 0x1
    %endif
    %if %1 = RIGHT
      add dil, 0x1
    %endif
  %rotate 1 
  %endrep 
  plot_pixel r8b, dil, sil
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


  mov r8b, 0x0 ; clear prev
  cmp byte[curr_piece], I_PIECE
  jne .check_o_piece
  cmp sil, 19
  jge .reset
  plot_pixel_direction NONE
  plot_pixel_direction RIGHT
  plot_pixel_direction RIGHT
  plot_pixel_direction RIGHT
  sub dil, 0x3
  inc sil
  mov r8b, byte[curr_piece]
  add dil, byte[piece_movement]
  mov byte[piece_movement], 0x0
  plot_pixel_direction NONE
  plot_pixel_direction RIGHT
  plot_pixel_direction RIGHT
  plot_pixel_direction RIGHT
  sub dil, 0x3
  jmp .exit_checks
  .check_o_piece:
  cmp byte[curr_piece], O_PIECE
  jne .check_t_piece
  cmp sil, 18
  jge .reset
  plot_pixel_direction NONE
  plot_pixel_direction RIGHT
  plot_pixel_direction DOWN
  plot_pixel_direction LEFT
  add dil, byte[piece_movement]
  mov byte[piece_movement], 0x0
  mov r8b, byte[curr_piece]
  plot_pixel_direction NONE
  plot_pixel_direction RIGHT
  plot_pixel_direction DOWN
  plot_pixel_direction LEFT
  dec sil ; So we don't go too far
  jmp .exit_checks
  .check_t_piece:
  cmp byte[curr_piece], T_PIECE
  jne .check_s_piece
  cmp sil, 18
  jge .reset
  plot_pixel_direction NONE
  plot_pixel_direction RIGHT
  plot_pixel_direction RIGHT
  plot_pixel_direction LEFT, DOWN
  dec dil
  add dil, byte[piece_movement]
  mov byte[piece_movement], 0x0
  mov r8b, byte[curr_piece]
  plot_pixel_direction NONE
  plot_pixel_direction RIGHT
  plot_pixel_direction RIGHT
  plot_pixel_direction LEFT, DOWN
  dec dil
  dec sil
  jmp .exit_checks
  .check_s_piece:
  cmp byte[curr_piece], S_PIECE
  jne .check_z_piece
  cmp sil, 18
  jge .reset
  plot_pixel_direction NONE
  plot_pixel_direction RIGHT
  plot_pixel_direction LEFT, DOWN
  plot_pixel_direction LEFT
  inc dil
  add dil, byte[piece_movement]
  mov byte[piece_movement], 0x0
  mov r8b, byte[curr_piece]
  plot_pixel_direction NONE
  plot_pixel_direction RIGHT
  plot_pixel_direction LEFT, DOWN
  plot_pixel_direction LEFT
  inc dil
  dec sil
  jmp .exit_checks
  .check_z_piece:
  cmp byte[curr_piece], Z_PIECE
  jne .check_l_piece
  cmp sil, 18
  jge .reset
  plot_pixel_direction NONE
  plot_pixel_direction LEFT
  plot_pixel_direction RIGHT, DOWN
  plot_pixel_direction RIGHT
  dec dil
  add dil, byte[piece_movement]
  mov byte[piece_movement], 0x0
  mov r8b, byte[curr_piece]
  plot_pixel_direction NONE
  plot_pixel_direction LEFT
  plot_pixel_direction RIGHT, DOWN
  plot_pixel_direction RIGHT
  dec dil
  dec sil
  jmp .exit_checks
  .check_l_piece:
  cmp byte[curr_piece], L_PIECE
  jne .j_piece
  cmp sil, 17
  jge .reset
  plot_pixel_direction LEFT
  plot_pixel_direction DOWN
  plot_pixel_direction DOWN
  plot_pixel_direction RIGHT
  sub sil, 0x1
  add dil, byte[piece_movement]
  mov r9b, 0x9
  cmp dil, 9
  cmova di, r9w
  mov r9b, 0x1
  cmp dil, 0x1
  cmovb di, r9w
  mov byte[piece_movement], 0x0
  mov r8b, byte[curr_piece]
  plot_pixel_direction LEFT
  plot_pixel_direction DOWN
  plot_pixel_direction DOWN
  plot_pixel_direction RIGHT
  sub sil, 0x2
  jmp .exit_checks
  .j_piece:
  cmp sil, 17
  jge .reset
  plot_pixel_direction NONE
  plot_pixel_direction DOWN
  plot_pixel_direction DOWN
  plot_pixel_direction LEFT
  inc dil
  sub sil, 0x1
  add dil, byte[piece_movement]
  mov r9b, 0x9
  cmp dil, 9
  cmova di, r9w
  mov r9b, 0x1
  cmp dil, 1
  cmovb di, r9w
  mov byte[piece_movement], 0x0
  mov r8b, byte[curr_piece]
  plot_pixel_direction NONE
  plot_pixel_direction DOWN
  plot_pixel_direction DOWN
  plot_pixel_direction LEFT
  inc dil
  sub sil, 0x2

  .exit_checks:
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
curr_piece db L_PIECE, 0x3, 0x0, 0x0
piece_list db I_PIECE, O_PIECE, T_PIECE, S_PIECE, Z_PIECE, L_PIECE, J_PIECE
piece_movement db 0x0
bag times(7) db 0x0
timer dq 0x0

section .rodata
