%define SQUARE_WIDTH SCREEN_WIDTH / 2
%define SQUARE_HEIGHT SCREEN_HEIGHT / 2

section .data
moves times (255) db 0x0
move_length db 0x0

section .text
global run_game
run_game:
  call pick_square
  xor r15, r15
  mov r15b, byte[move_length]
  inc r15
  mov byte[moves + r15], al
  mov byte[move_length], r15b
  ret

pick_square:
  mov rax, 0x1
  ret

global draw_board
draw_board:
  mov rdi, 0x0
  mov rsi, 0x0
  mov rdx, SQUARE_WIDTH
  mov rcx, SQUARE_HEIGHT
  mov r8, YELLOW
  call DrawRectangle
  mov rdi, SQUARE_WIDTH
  mov rsi, 0x0
  mov rdx, SQUARE_WIDTH
  mov rcx, SQUARE_HEIGHT
  mov r8, BLUE
  call DrawRectangle
  mov rdi, 0x0
  mov rsi, SQUARE_HEIGHT
  mov rdx, SQUARE_WIDTH
  mov rcx, SQUARE_HEIGHT
  mov r8, RED
  call DrawRectangle
  mov rdi, SQUARE_WIDTH
  mov rsi, SQUARE_HEIGHT
  mov rdx, SQUARE_WIDTH
  mov rcx, SQUARE_HEIGHT
  mov r8, GREEN
  call DrawRectangle

  mov rdi, 0x0
  mov rsi, 0x0
  mov rdx, SQUARE_WIDTH
  mov rcx, SQUARE_HEIGHT
  mov r8, BLACK
  call DrawRectangleLines
  mov rdi, SQUARE_WIDTH - 1
  mov rsi, 0x0
  mov rdx, SQUARE_WIDTH + 1
  mov rcx, SQUARE_HEIGHT
  mov r8, BLACK
  call DrawRectangleLines
  mov rdi, 0x0
  mov rsi, SQUARE_HEIGHT
  mov rdx, SQUARE_WIDTH
  mov rcx, SQUARE_HEIGHT
  mov r8, BLACK
  call DrawRectangleLines
  mov rdi, SQUARE_WIDTH - 1
  mov rsi, SQUARE_HEIGHT
  mov rdx, SQUARE_WIDTH + 1
  mov rcx, SQUARE_HEIGHT
  mov r8, BLACK
  call DrawRectangleLines
  ret

section .rodata
  border_thickness dd 2.0
