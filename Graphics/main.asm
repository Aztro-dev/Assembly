section .text
global  _start
extern  printf
extern  _exit
extern  InitWindow
extern  WindowShouldClose
extern  CloseWindow
extern  BeginDrawing
extern  EndDrawing
extern  ClearBackground
extern  DrawCircle

_start:
	mov  rdi, 800
	mov  rsi, 600
	mov  rdx, title
	call InitWindow

.again:
	call WindowShouldClose
	test rax, rax
	jnz  .over
	call BeginDrawing

	mov  rdi, 0xFF181818
	call ClearBackground

	mov   rdi, 0x100; xPos
	mov   rsi, 0x100; yPos
	movss xmm0, [radius]; Radius
	mov   rdx, qword[color]; Opaque
	call  DrawCircle

	call EndDrawing
	jmp  .again

.over:
	call CloseWindow
	mov  rdi, 0
	call _exit
	ret

section .data

radius:
	dd 100.0

color:
	dq 0xFF00FFFF

title:
	db "ASM graphics", 0x0
