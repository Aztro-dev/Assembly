%define NEXT_PIECE_FONT_SIZE 32
%define NEXT_PIECE_CELL_SIZE 18

extern DrawText

section .text

draw_bag:
  mov rdi, next_piece_text
  mov rsi, 4 * SCREEN_WIDTH / 5
  mov rdx, SCREEN_HEIGHT / 7
  mov rcx, NEXT_PIECE_FONT_SIZE
  mov r8, WHITE
  call DrawText

  mov rdi, 4 * SCREEN_WIDTH / 5 
  mov rsi, SCREEN_HEIGHT / 7 + 30
  mov rdx, 100
  mov rcx, 60
  mov r8, WHITE
  call DrawRectangleLines

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

  cmp al, I_PIECE
  je .draw_i_piece
  cmp al, O_PIECE
  je .draw_o_piece
  cmp al, T_PIECE
  je .draw_t_piece
  cmp al, S_PIECE
  je .draw_s_piece
  cmp al, Z_PIECE
  je .draw_z_piece
  cmp al, L_PIECE
  je .draw_l_piece
  cmp al, J_PIECE
  je .draw_j_piece
  jmp .exit

  .draw_i_piece:
  mov rdi, 4 * SCREEN_WIDTH / 5 + 4 * NEXT_PIECE_CELL_SIZE / 5
  mov rsi, SCREEN_HEIGHT / 7 + 3 * NEXT_PIECE_CELL_SIZE
  mov rdx, NEXT_PIECE_CELL_SIZE * 4
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, LIGHT_BLUE
  call DrawRectangle
  jmp .exit

  .draw_o_piece:
  mov rdi, 4 * SCREEN_WIDTH / 5 + 9 * NEXT_PIECE_CELL_SIZE / 5
  mov rsi, SCREEN_HEIGHT / 7 + 9 * NEXT_PIECE_CELL_SIZE / 4
  mov rdx, NEXT_PIECE_CELL_SIZE * 2
  mov rcx, NEXT_PIECE_CELL_SIZE * 2
  mov r8, YELLOW
  call DrawRectangle
  jmp .exit

  .draw_t_piece:
  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5
  mov rsi, SCREEN_HEIGHT / 7 + 3 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE * 3
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, PURPLE
  call DrawRectangle

  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5 + NEXT_PIECE_CELL_SIZE
  mov rsi, SCREEN_HEIGHT / 7 + 2 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, PURPLE
  call DrawRectangle
  jmp .exit

  .draw_s_piece:
  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5
  mov rsi, SCREEN_HEIGHT / 7 + 3 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE * 2
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, GREEN
  call DrawRectangle

  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5 + NEXT_PIECE_CELL_SIZE
  mov rsi, SCREEN_HEIGHT / 7 + 2 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE * 2
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, GREEN
  call DrawRectangle
  jmp .exit

  .draw_z_piece:
  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5
  mov rsi, SCREEN_HEIGHT / 7 + 2 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE * 2
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, RED
  call DrawRectangle

  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5 + NEXT_PIECE_CELL_SIZE
  mov rsi, SCREEN_HEIGHT / 7 + 3 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE * 2
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, RED
  call DrawRectangle
  jmp .exit

  .draw_l_piece:
  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5
  mov rsi, SCREEN_HEIGHT / 7 + 3 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE * 3
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, DARK_BLUE
  call DrawRectangle

  mov rdi, 4 * SCREEN_WIDTH / 5 + NEXT_PIECE_CELL_SIZE / 5 + NEXT_PIECE_CELL_SIZE
  mov rsi, SCREEN_HEIGHT / 7 + 2 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, DARK_BLUE
  call DrawRectangle
  jmp .exit

  .draw_j_piece:
  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5
  mov rsi, SCREEN_HEIGHT / 7 + 3 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE * 3
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, ORANGE
  call DrawRectangle

  mov rdi, 4 * SCREEN_WIDTH / 5 + 6 * NEXT_PIECE_CELL_SIZE / 5 + 2 * NEXT_PIECE_CELL_SIZE
  mov rsi, SCREEN_HEIGHT / 7 + 2 * NEXT_PIECE_CELL_SIZE + NEXT_PIECE_CELL_SIZE / 2
  mov rdx, NEXT_PIECE_CELL_SIZE
  mov rcx, NEXT_PIECE_CELL_SIZE
  mov r8, ORANGE
  call DrawRectangle
  jmp .exit


  .exit:
  
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
bag times(7) db NONE

section .rodata
next_piece_text db "NEXT", 0x0
