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

	; First paddle
	lea rdi, [paddle_positions + 4]
	mov rax, KEY_S
	mov rbx, KEY_W
	call move_paddles
	; Second paddle
	lea rdi, [paddle_positions + 12]
	mov rax, KEY_DOWN
	mov rbx, KEY_UP
	call move_paddles

	call move_ball
	test rax, 0x1
	je .skip_game_reset
	call reset_game
	.skip_game_reset:

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

reset_game:
	mov dword[paddle_positions], 2 * PADDLE_WIDTH
	mov dword[paddle_positions + 4], SCREEN_HEIGHT / 2 - PADDLE_HEIGHT
	mov dword[paddle_positions + 8], SCREEN_WIDTH - 3 * PADDLE_WIDTH
	mov dword[paddle_positions + 12], SCREEN_HEIGHT / 2 - PADDLE_HEIGHT

	mov dword[ball_position], SCREEN_WIDTH / 2
	mov dword[ball_position + 4], SCREEN_HEIGHT / 2
	mov qword[ball_position + 8], 0x0

	mov dword[ball_velocities], 0x3
	mov dword[ball_velocities + 4], 0x2
	ret

section .data
title db "Pong", 0x0
