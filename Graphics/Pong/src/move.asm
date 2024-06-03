%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600
%define PADDLE_WIDTH SCREEN_WIDTH / 80
%define PADDLE_HEIGHT SCREEN_HEIGHT / 8

extern DrawRectangle
section .data

positions dd 0x0, 0x0

color dq 0xFFFFFFFF

section .text
global move_paddle
move_paddle:
	mov dword[positions], 0x0
	mov dword[positions + 0x4], 0x0
	ret

global draw_paddles
draw_paddles:
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
  ret
