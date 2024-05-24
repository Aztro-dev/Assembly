%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600
%define PADDLE_WIDTH SCREEN_WIDTH / 80
%define PADDLE_HEIGHT SCREEN_HEIGHT / 8
%define MAX_FPS 200

section .text
global  _start
extern  _exit
extern  InitWindow
extern  WindowShouldClose
extern  CloseWindow
extern  BeginDrawing
extern  EndDrawing
extern  ClearBackground

extern DrawRectangle
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

	mov  edi, SCREEN_WIDTH - 3 * PADDLE_WIDTH; xPos
	mov  esi, dword[positions + 4]; yPos
	mov  edx, PADDLE_WIDTH
	mov  ecx, PADDLE_HEIGHT
	mov  r8, qword[color]; Opaque
	call DrawRectangle

	mov  edi, 2 * PADDLE_WIDTH; xPos
	mov  esi, dword[positions]; yPos
	mov  edx, PADDLE_WIDTH
	mov  ecx, PADDLE_HEIGHT
	mov  r8, qword[color]; Opaque
	call DrawRectangle

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

move_paddle:
	mov dword[positions], 0x0
	mov dword[positions + 0x4], 0x0
	ret

section .data

positions dd 0x0, 0x0

color dq 0xFFFFFFFF

title db "Pong", 0x0
