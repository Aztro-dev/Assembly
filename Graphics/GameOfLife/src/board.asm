%define SCREEN_HEIGHT 800
%define SCREEN_HEIGHT 800

%define CELL_NUMBER 50
%define CELL_SIZE SCREEN_WIDTH / CELL_NUMBER

%define MOUSE_LEFT 0
%define MOUSE_RIGHT 1

%include "src/utils.asm"

extern DrawRectangle
extern IsMouseButtonDown
extern GetMousePosition
extern GetWindowPosition
extern IsCursorOnScreen

section .text
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
  ret
global draw_board
draw_board:
  mov r10, 0x0
  .outer_loop:
    cmp r10, CELL_NUMBER
    jge .exit
    mov r11, 0x0
    .inner_loop:
      cmp r11, CELL_NUMBER
      jge .exit_inner_loop
      
      mov r9, CELL_SIZE 

      mov rax, r10
      mul r9
      mov rdi, rax ; xPos

      mov rax, r11
      mul r9
      mov rsi, rax ; yPos
      
      mov rax, r10
      mov r9, CELL_NUMBER
      mul r9
      
	    mov  rdx, CELL_SIZE
	    mov  rcx, CELL_SIZE
	    mov  r8, qword[cell_color]
	    test byte[board + rax + r11], 0x1
	    ; if board_color & 0x1 == 0, board_color = black
	    cmovz r8, qword[background_color]

	    push r10
	    push r11
	    call DrawRectangle
	    pop r11
	    pop r10

	    inc r11
	    jmp .inner_loop
	  .exit_inner_loop:
	  inc r10
	  jmp .outer_loop
  .exit:
	ret

populate_board:
  call IsCursorOnScreen
  test rax, 0x1
  jz .exit

  mov rdi, MOUSE_LEFT
  call IsMouseButtonDown
  test rax, 0x1
  jz .check_right
  mov bl, 0x1 ; SET
  jmp .skip_check
  .check_right:
  mov rdi, MOUSE_RIGHT
  call IsMouseButtonDown
  test rax, 0x1
  jz .exit
  mov bl, 0x0 ; CLEAR
  .skip_check:
  
  ; Output is stored in xmm0
  call GetMousePosition
  mov dword[temp], CELL_SIZE
  mov dword[temp + 4], CELL_SIZE

  ; cell size to float
  movq xmm1, qword[temp]
  cvtdq2ps xmm1, xmm1
  ; mouse_pos / vec2::splat(cell_size)
  divps xmm0, xmm1
  ; (int)(mouse_pos / vec2::splat(cell_size)) 
  cvttps2dq xmm0, xmm0
  ; Store the position in the array
  movq qword[temp], xmm0

  xor rax, rax
  mov eax, dword[temp]
  mov ecx, dword[temp + 4]
  mov r8, CELL_NUMBER
  mul r8
  add eax, ecx
  mov byte[board + rax], bl
  .exit:
  ret

global clear_board
clear_board:
  mov rax, 0x0
  .loop:
    cmp rax, CELL_NUMBER * CELL_NUMBER
    jge .exit
    mov byte[board + rax], 0x0
    inc rax
    jmp .loop
  
  .exit:
  ret
section .data
  board times(CELL_NUMBER * CELL_NUMBER) db 0x0
  temp_board times(CELL_NUMBER * CELL_NUMBER) db 0x0
  temp times (4) dd 0x0

section .rodata
  cell_color dq 0xFFFFFFFF
  background_color dq 0x00000000
