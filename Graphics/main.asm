%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600
%define MAX_FPS 200

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
extern  DrawFPS
extern  SetTargetFPS
extern  GetFrameTime

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

	call move_circle

	xor rdi, rdi
	xor rsi, rsi

	mov   edi, dword[position]; xPos
	mov   esi, dword[position + 4]; yPos
	movss xmm0, [radius]; Radius
	mov   rdx, qword[color]; Opaque
	call  DrawCircle

	call EndDrawing
	jmp  .draw_loop

.exit_draw_loop:
	call CloseWindow
	mov  rdi, 0
	call _exit
	ret

move_circle:
	xor rdi, rdi
	xor rsi, rsi

	mov edi, dword[position]; xPos
	mov esi, dword[position + 4]; yPos

	movsx rcx, dword[velocity]; xVel
	movsx rdx, dword[velocity + 4]; yVel

	add rdi, rcx; xPos += xVel
	add rsi, rdx; yPos += yVel

	movss xmm0, [radius]

	;Convert  With Truncation Scalar Single Precision Floating-Point Value to Integer
	cvttss2si r8, xmm0; r8 = (int)radius

.x_checks:
	cmp rdi, r8
	jle .flip_x_vel

	mov r9, SCREEN_WIDTH
	sub r9, r8
	cmp rdi, r9
	jge .flip_x_vel
	jmp .y_checks

.flip_x_vel:
	neg rcx

.y_checks:
	cmp rsi, r8
	jle .flip_y_vel

	mov r9, SCREEN_HEIGHT
	sub r9, r8
	cmp rsi, r9
	jge .flip_y_vel
	jmp .exit

.flip_y_vel:
	neg rdx

.exit:
	mov dword[velocity], ecx; xVel
	mov dword[velocity + 4], edx; yVel

	mov dword[position], edi; xPos
	mov dword[position + 4], esi; yPos
	ret

	; Returns the velocities (in rcx and rdx) but multiplied by delta time

	section .data

	position dd 0x100, 0x100
	velocity dd 10, -10

	radius dd 10.0

	color dq 0xFF00FFFF

	title db "ASM graphics", 0x0
	print_doubles db "%f, %f", 0x0a
