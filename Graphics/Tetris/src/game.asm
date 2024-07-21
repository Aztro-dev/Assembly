%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 1000

%define BOARD_WIDTH SCREEN_WIDTH / 2
%define BOARD_HEIGHT SCREEN_HEIGHT * 80 / 100
%define CELL_SIZE BOARD_WIDTH / 10

%define NO_COLOR 0xFF444444
%define LIGHT_BLUE 0xFFFFFF00
%define YELLOW 0xFF00FFFF

extern DrawRectangle
extern DrawRectangleLines

section .text
global draw_board
  draw_board:
    mov rdi, (SCREEN_WIDTH - BOARD_WIDTH) / 2
    mov rsi, (SCREEN_HEIGHT - BOARD_HEIGHT) / 2
    mov rdx, BOARD_WIDTH
    mov rcx, BOARD_HEIGHT
    mov r8, 0xFF444444
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
    ret

section .data
  ; Tetris board is 10 x 20 cells
  board times (10 * 20) db 0x2
section .rodata
  colors_array dq NO_COLOR, LIGHT_BLUE, YELLOW
