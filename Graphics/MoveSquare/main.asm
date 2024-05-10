%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600
%define RECTANGLE_WIDTH 20
%define RECTANGLE_HEIGHT 20
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
extern GetMouseX
extern GetMouseY
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

	mov  rdi, 10
	mov  rsi, 10
	call DrawFPS

	call GetMouseX
	sub  eax, RECTANGLE_WIDTH / 2
	mov  dword[position], eax
	call GetMouseY
	sub  eax, RECTANGLE_HEIGHT / 2
	mov  dword[position + 4], eax

	mov  edi, dword[position]; xPos
	mov  esi, dword[position + 4]; yPos
	mov  edx, RECTANGLE_WIDTH
	mov  ecx, RECTANGLE_HEIGHT
	mov  r8, qword[color]; Opaque
	call DrawRectangle

	call EndDrawing
	jmp  .draw_loop

.exit_draw_loop:
	call CloseWindow
	mov  rdi, 0
	call _exit
	ret

section .data

position dd 0x0, 0x0

color dq 0xFF00FFFF

title db "Move square", 0x0
