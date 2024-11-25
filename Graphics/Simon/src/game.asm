%define SQUARE_WIDTH SCREEN_WIDTH / 2
%define SQUARE_HEIGHT SCREEN_HEIGHT / 2

section .data
moves times (255) db 0x0
move_length dq 0x0
most_recent_click db 0x5

section .text
global run_game
run_game:
  cmp qword[move_length], 255
  jmp .continue
  ; jl .continue
  mov rax, 0x0 ; num args
  mov rdi, win_string
  call print_formatted
  .after_print:
  
	mov  rdi, 0
	call _exit
	ret

  .continue:
  call get_clicked_square
  cmp rax, 0x5
  je .exit

  call pick_square

  .exit:
  cmp byte[most_recent_click], 0x5
  je .exit_but_for_real_this_time

  call highlight_click

  .exit_but_for_real_this_time:
  ret

get_clicked_square:
  mov rdi, MOUSE_BUTTON_LEFT
  call IsMouseButtonPressed
  test rax, rax
  jnz .continue
  mov rax, 0x5
  ret

  .continue:
  call GetMouseX
  xor rdx, rdx
  mov r15, SQUARE_WIDTH
  div r15

  mov r14, rax

  call GetMouseY
  xor rdx, rdx
  mov r15, SQUARE_HEIGHT
  div r15

  sal rax, 0x1
  add rax, r14

  mov byte[most_recent_click], al
  ret

highlight_click:
  mov rdi, MOUSE_BUTTON_LEFT
  call IsMouseButtonReleased
  test rax, rax
  jz .continue

  mov byte[most_recent_click], 0x5
  ret
  .continue:

  xor rax, rax
  mov al, byte[most_recent_click]
  and al, 0x1

  mov r15, SQUARE_WIDTH
  mul r15
  mov rdi, rax

  xor rax, rax
  mov al, byte[most_recent_click]
  sar rax, 0x1

  mov r15, SQUARE_HEIGHT
  mul r15
  mov rsi, rax

  mov rdx, SQUARE_WIDTH
  mov rcx, SQUARE_HEIGHT
  mov r8, WHITE
  call DrawRectangle
  ret

pick_square:
  mov rdi, 0x4 ; restrict to 4 possible values
  call rand

  mov r15, qword[move_length]
  inc r15
  mov byte[moves + r15], al
  mov qword[move_length], r15

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
win_string db "You won!", 0x0a, 0x0
int_string db "%d", 0x0a, 0x0
