%define MAX_FPS 200

%include "src/constants.asm"
%include "src/utils.asm"
%include "src/sound.asm"
%include "src/game.asm"

section .text
global  _start
extern  _exit

_start:
	mov  rdi, SCREEN_WIDTH
	mov  rsi, SCREEN_HEIGHT
	mov  rdx, title
	call InitWindow

	mov  rdi, MAX_FPS
	call SetTargetFPS

	call init_sound
	
.draw_loop:
	call WindowShouldClose
	test rax, rax
	jnz  .exit_draw_loop
	call BeginDrawing

	mov  rdi, 0xFF181818
	call ClearBackground

	call draw_board

	call run_game

	mov  rdi, 10
	mov  rsi, 10
	call DrawFPS

	call EndDrawing
	jmp  .draw_loop

.exit_draw_loop:
	call un_init_sound

	call CloseWindow
	mov  rdi, 0
	call _exit
	ret

section .rodata
title db "Simon", 0x0
