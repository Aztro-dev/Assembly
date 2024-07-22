%define CELL_NUMBER 3
%define CELL_SIZE SCREEN_WIDTH / CELL_NUMBER

%ifidn  __OUTPUT_FORMAT__, elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif


section .data
  board times(CELL_NUMBER * CELL_NUMBER) db 0x0
  temp_board times(CELL_NUMBER * CELL_NUMBER) db 0x0
  temp times (4) dd 0x0

section .rodata
  cell_color dq 0xFFFFFFFF
  background_color dq 0x00000000

section .text
global set_board
set_board:
  lea rsi, [board]
  .loop:
    cmp rsi, board + CELL_NUMBER * CELL_NUMBER
    jge .exit
    mov al, byte[rdi]
    mov byte[rsi], al
    inc rsi
    inc rdi
    jmp .loop
  .exit:
  ret

global get_board
get_board:
  lea rax, [board]
  ret

global count_surrounding_cells
; rdi = x_pos, rsi = y_pos
count_surrounding_cells:
  xor rax, rax ; al = count
  ; int i = x_pos - 1
  mov r8, rdi
  sub r8, CELL_NUMBER
  ; for(i; i <= x_pos + 1; i++){
  .x_loop:
    mov r10, rdi ; r10 = temp
    add r10, CELL_NUMBER 
    cmp r8, r10
    jg .exit
    ; int ii = y_pos - 1
    mov r9, rsi
    dec r9
    ; for(ii; ii <= y_pos + 1; ii++){
    .y_loop:
      mov r10, rsi ; r10 = temp
      inc r10
      cmp r9, r10
      jg .exit_y_loop

      ; if (i == x_pos && ii == y_pos) continue
      cmp r8, rdi
      jne .check_min_coords
      cmp r9, rsi
      je .continue
      
      ; if (i < 0 || ii < 0) continue
      .check_min_coords:
      cmp r8, 0x0
      jl .continue
      cmp r9, 0x0
      jl .continue
  
      ; if (i >= CELL_NUMBER * CELL_NUMBER || ii >= CELL_NUMBER) continue
      .check_max_coords:
      cmp r8, CELL_NUMBER * CELL_NUMBER
      jge .continue
      cmp r9, CELL_NUMBER
      jge .continue
      
      add al, byte[board + r8 + r9]
      .continue:
      inc r9
      jmp .y_loop
    .exit_y_loop:
    add r8, CELL_NUMBER
    jmp .x_loop
  
  .exit:
  ret

global run_game
run_game:
  xor rdi, rdi
  xor rsi, rsi
  .outer_loop:
    cmp rdi, CELL_NUMBER * CELL_NUMBER 
    jge .exit
    xor rsi, rsi
    .inner_loop:
    cmp rsi, CELL_NUMBER
    jge .exit_inner_loop

    call count_surrounding_cells

    mov r9, rdi
    add r9, rsi

    cmp rax, 0x3 ; If there are 3 living cells around, then the current cell is alive
    jne .skip_three_check
    mov byte[temp_board + rdi + rsi], 0x1
    jmp .continue
    .skip_three_check:

    cmp rax, 0x2
    jne .continue
    cmp byte[board + rdi + rsi], 0x1
    jne .continue
    mov byte[temp_board + rdi + rsi], 0x1

    .continue:
    inc rsi
    jmp .inner_loop

    .exit_inner_loop:
    add rdi, CELL_NUMBER
    jmp .outer_loop
  .exit:

  xor rdi, rdi
  .loop:
    cmp rdi, CELL_NUMBER * CELL_NUMBER
    jge .exit_loop
    mov al, byte[temp_board + rdi]
    mov byte[board + rdi], al
    mov byte[temp_board + rdi], 0x0 ; Clear it after use
    inc rdi
    jmp .loop
  .exit_loop:
  lea rax, [board]
  
  ret
