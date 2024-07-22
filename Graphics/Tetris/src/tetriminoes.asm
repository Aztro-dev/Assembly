%define SIMULATION_SPEED MAX_FPS / 50 ; 50 times per second
%define KEY_RIGHT 262
%define KEY_LEFT 263

%define I_PIECE 0x1
%define O_PIECE 0x2
%define T_PIECE 0x3
%define S_PIECE 0x4
%define Z_PIECE 0x5
%define L_PIECE 0x6
%define J_PIECE 0x7

extern IsKeyDown
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

section .text
global move_piece
move_piece:
  mov r10, qword[timer]
  cmp r10, SIMULATION_SPEED
  jl .exit
  mov r10, 0x0

  ; If there isn't a current piece
  cmp byte[curr_piece], 0x0
  je .exit
  xor rdi, rdi
  xor rsi, rsi
  mov dil, byte[curr_piece + 1] ; X_POS
  mov sil, byte[curr_piece + 2] ; Y_POS

  cmp sil, 18
  jl .skip_reset
  .place:
  call pull_from_bag
  jmp .exit
  .skip_reset:
  cmp byte[curr_piece], I_PIECE
  jne .check_o_piece
  plot_pixel 0x0, dil, sil ; clear prev
  inc dil
  plot_pixel 0x0, dil, sil ; clear prev
  inc dil
  plot_pixel 0x0, dil, sil ; clear prev
  inc dil
  plot_pixel 0x0, dil, sil ; clear prev
  sub dil, 0x3
  inc sil
  plot_pixel byte[curr_piece], dil, sil 
  inc dil
  plot_pixel byte[curr_piece], dil, sil 
  inc dil
  plot_pixel byte[curr_piece], dil, sil 
  inc dil
  plot_pixel byte[curr_piece], dil, sil 
  sub dil, 0x3
  jmp .exit_checks
  .check_o_piece:
  cmp byte[curr_piece], O_PIECE
  jne .check_t_piece
  plot_pixel 0x0, dil, sil ; clear prev
  inc dil
  plot_pixel 0x0, dil, sil ; clear prev
  inc sil
  plot_pixel 0x0, dil, sil ; clear prev
  dec dil
  plot_pixel 0x0, dil, sil ; clear prev
  dec sil
  inc sil
  plot_pixel byte[curr_piece], dil, sil 
  inc dil
  plot_pixel byte[curr_piece], dil, sil 
  inc sil
  plot_pixel byte[curr_piece], dil, sil 
  dec dil
  plot_pixel byte[curr_piece], dil, sil 
  dec sil
  jmp .exit_checks
  .check_t_piece:
  cmp byte[curr_piece], T_PIECE
  jne .exit_checks
  plot_pixel 0x0, dil, sil ; clear prev
  inc dil
  plot_pixel 0x0, dil, sil ; clear prev
  inc dil
  plot_pixel 0x0, dil, sil ; clear prev
  dec dil
  inc sil
  plot_pixel 0x0, dil, sil ; clear prev
  dec dil
  dec sil
  inc sil
  plot_pixel byte[curr_piece], dil, sil 
  inc dil
  plot_pixel byte[curr_piece], dil, sil 
  inc dil
  plot_pixel byte[curr_piece], dil, sil 
  dec dil
  inc sil
  plot_pixel byte[curr_piece], dil, sil 
  dec dil
  dec sil
  jmp .exit_checks

  .exit_checks:
  mov byte[curr_piece + 1], dil
  mov byte[curr_piece + 2], sil

  .exit:
  inc r10
  mov qword[timer], r10
  ret

create_bag:
  xor r8, r8 ; iterator
  .loop:
    cmp r8, 7
    jge .exit_loop
    
    ; int random = rand() % (7 - i);
    call rand
    mov r9, 0x7
    sub r9, r8
    xor rdx, rdx
    div r9
    mov rax, rdx ; random = rax

    ; bag[i] = piece_list[random]
    mov al, byte[piece_list + rax]
    mov byte[bag + r8], al

    ; int temp = piece_list[random]
    mov r9b, byte[piece_list + rax]
    mov rcx, 6
    sub rcx, r8
    mov bl, byte[piece_list + rcx]
    ; piece_list[random] = piece_list[6 - i];
    mov byte[piece_list + rax], bl
    ; piece_list[6 - i] = temp;
    mov byte[piece_list + rcx], al

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
curr_piece db I_PIECE, 0x0, 0x3, 0x0
piece_list db I_PIECE, O_PIECE, T_PIECE, S_PIECE, Z_PIECE, L_PIECE, J_PIECE
bag times(7) db 0x1
timer dq 0x0

section .rodata
