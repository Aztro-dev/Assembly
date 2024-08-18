%define BOARD_WIDTH SCREEN_WIDTH / 2
%define BOARD_HEIGHT SCREEN_HEIGHT * 80 / 100
%define CELL_SIZE BOARD_WIDTH / 10

%define KEY_BACKSPACE 259

%include "src/utils.asm"
%include "src/tetriminoes.asm"

section .text
global run_game
run_game:
  mov rdi, KEY_BACKSPACE
  call IsKeyDown
  test rax, 0x1
  jnz .skip
  call handle_hold
  call rotate_piece
  call move_piece
  .skip:
  call draw_bag
  call draw_hold
  ret
  
global draw_board
  draw_board:
    ; Outer border
    mov rdi, (SCREEN_WIDTH - BOARD_WIDTH) / 2 - 1
    mov rsi, (SCREEN_HEIGHT - BOARD_HEIGHT) / 2 - 1
    mov rdx, BOARD_WIDTH + 0x2
    mov rcx, BOARD_HEIGHT + 0x1
    mov r8, BLACK
    call DrawRectangleLines

    xor r9, r9 ; Iterator
    .outer_loop:
      cmp r9, 20 ; Height (cells)
      je .exit
      xor r10, r10 ; Iterator
      .inner_loop:
        cmp r10, 10 ; Width (cells)
        je .exit_inner_loop
        push r9
        push r10

        mov rax, r9
        mov r8, 10 ; Multiply by board width (cells)
        mul r8
        
        xor r8, r8
        mov r8b, byte[board + rax + r10] ; color of the cell
        mov rax, r8
        mov r11, 0x8 ; Multiply by a qword
        mul r11

        mov r8, qword[colors_array + rax]

        mov rax, r10
        mov r11, CELL_SIZE
        mul r11
        mov rdi, rax

        mov rax, r9
        mov r11, CELL_SIZE
        mul r11
        mov rsi, rax

        add rdi, (SCREEN_WIDTH - BOARD_WIDTH) / 2 ;Offset to the board position
        add rsi, (SCREEN_HEIGHT - BOARD_HEIGHT) / 2 ;Offset to the board position
        mov rdx, CELL_SIZE
        mov rcx, CELL_SIZE

        call DrawRectangle
        
        .continue:
        pop r10
        pop r9
        inc r10
        jmp .inner_loop
      .exit_inner_loop:
      
      inc r9
      jmp .outer_loop
    .exit:
    call draw_board_lines
    ret
draw_board_lines:
    xor r9, r9 ; Iterator
    .outer_loop:
      cmp r9, 20 ; Height (cells)
      je .exit
      xor r10, r10 ; Iterator
      .inner_loop:
        cmp r10, 10 ; Width (cells)
        je .exit_inner_loop
        push r9
        push r10

        mov rax, r10
        mov r11, CELL_SIZE
        mul r11
        mov rdi, rax

        mov rax, r9
        mov r11, CELL_SIZE
        mul r11
        mov rsi, rax

        add rdi, (SCREEN_WIDTH - BOARD_WIDTH) / 2 ;Offset to the board position
        add rsi, (SCREEN_HEIGHT - BOARD_HEIGHT) / 2 ;Offset to the board position
        mov rdx, CELL_SIZE
        mov rcx, CELL_SIZE

        mov dword[temp], edi
        mov dword[temp + 4], esi
        mov dword[temp + 8], edx
        mov dword[temp + 12], ecx
        
        movq xmm0, qword[temp]
        cvtdq2ps xmm0, xmm0
        movq xmm1, qword[temp + 8]
        cvtdq2ps xmm1, xmm1

        movss xmm2, dword[border_thickness]
      
        mov rdi, BLACK

        call DrawRectangleLinesEx
        
        .continue:
        pop r10
        pop r9
        inc r10
        jmp .inner_loop
      .exit_inner_loop:
      
      inc r9
      jmp .outer_loop
    .exit:
    ret

section .data
  ; Tetris board is 10 x 20 cells
  board times (20) db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  temp times (4) dd 0x0
section .rodata
  colors_array dq NO_COLOR, LIGHT_BLUE, YELLOW, PURPLE, GREEN, RED, DARK_BLUE, ORANGE
  border_thickness dd 2.0
