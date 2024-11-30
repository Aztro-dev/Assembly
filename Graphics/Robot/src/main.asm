%define MAX_FPS 200

%include "src/constants.asm"
%include "src/strucs.asm"
%include "src/utils.asm"
%include "src/game.asm"
%include "src/model.asm"
%include "src/camera.asm"

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

  call init_models

  call init_camera
	
.draw_loop:
	call WindowShouldClose
	test rax, rax
	jnz  .exit_draw_loop
	call BeginDrawing

	mov  rdi, 0xFF181818
	call ClearBackground

	mov rdi, camera
	call BeginMode3D

		call draw_objects

	call EndMode3D

	call run_game

	mov  rdi, 10
	mov  rsi, 10
	call DrawFPS

	call EndDrawing
	jmp  .draw_loop

.exit_draw_loop:
	call unload_models

	call CloseWindow
	mov  rdi, 0
	call _exit
	ret

section .rodata
title db "Robot", 0x0
