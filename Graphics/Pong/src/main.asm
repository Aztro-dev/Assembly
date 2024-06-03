%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600
%define PADDLE_WIDTH SCREEN_WIDTH / 80
%define PADDLE_HEIGHT SCREEN_HEIGHT / 8
%define MAX_FPS 200
%include "src/move.asm"

section .text
global  _start
extern  _exit
extern  InitWindow
extern  WindowShouldClose
extern  CloseWindow
extern  BeginDrawing
extern  EndDrawing
extern  ClearBackground
extern  DrawCircle
extern  DrawRectangle

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

.draw_loop:
	call WindowShouldClose
	test rax, rax
	jnz  .exit_draw_loop
	call BeginDrawing

	mov  rdi, 0xFF181818
	call ClearBackground

	call move_paddle
	call move_ball

	; Start drawing paddles
	mov  edi, dword[paddle_positions]; xPos
	mov  esi, dword[paddle_positions + 4]; yPos
	mov  edx, PADDLE_WIDTH
	mov  ecx, PADDLE_HEIGHT
	mov  r8, qword[color]
	call DrawRectangle

	mov  edi, dword[paddle_positions + 8]; xPos
	mov  esi, dword[paddle_positions + 12]; yPos
	mov  edx, PADDLE_WIDTH
	mov  ecx, PADDLE_HEIGHT
	mov  r8, qword[color]
	call DrawRectangle
	; End drawing paddles

	; Start drawing ball
	mov edi, dword [ball_position]
	mov esi, dword [ball_position + 4]
	movss xmm0, dword [ball_radius]
	mov rdx, qword [color]
	call DrawCircle

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

section .data
title db "Pong", 0x0
