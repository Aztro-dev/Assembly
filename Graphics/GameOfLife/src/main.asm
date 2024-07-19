%define SCREEN_WIDTH 600
%define SCREEN_HEIGHT 600

%define KEY_SPACE 32
%define KEY_ENTER 257
; Uncapped
%define MAX_FPS 200

%include "src/board.asm"

section .text
global  _start
extern  _exit
extern  InitWindow
extern  WindowShouldClose
extern  CloseWindow
extern  BeginDrawing
extern  EndDrawing
extern  ClearBackground
extern  IsKeyPressed

extern DrawFPS
extern SetTargetFPS
extern GetFrameTime

_start:
	mov  rdi, SCREEN_WIDTH
	mov  rsi, SCREEN_HEIGHT
	mov  rdx, title
	call InitWindow

	mov  rdi, MAX_FPS
	call SetTargetFPS
	
	call populate_board

.draw_loop:
	call WindowShouldClose
	test rax, rax
	jnz  .exit_draw_loop
	call BeginDrawing

	mov  rdi, 0xFF181818
	call ClearBackground

	test byte[should_freeze], 0x1
	jz .freeze
	call run_game
	jmp .after_freeze
	.freeze:
	call populate_board
	.after_freeze:

	call draw_board

	mov rdi, KEY_SPACE
	call IsKeyPressed
	test rax, 0x1
	je .skip_freeze
	call freeze_game
	.skip_freeze:

	mov rdi, KEY_ENTER
	call IsKeyPressed
	test rax, 0x1
	je .skip_clear
	call clear_board
	.skip_clear:

	mov  rdi, 10
	mov  rsi, 10
	call DrawFPS

	call EndDrawing
	jmp  .draw_loop

.exit_draw_loop:
	call CloseWindow
	mov  rdi, 0
	call _exit
	ret

freeze_game:
	mov al, byte[should_freeze]
	and al, 0x1
	xor al, 0x1 ; Toggle
	mov byte[should_freeze], al
	ret

section .data
should_freeze db 0x0
title db "Game Of Life", 0x0
