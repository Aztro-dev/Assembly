%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600

%define PADDLE_WIDTH SCREEN_HEIGHT / 80
%define PADDLE_HEIGHT SCREEN_HEIGHT / 8
%define PADDLE_SPEED SCREEN_HEIGHT / 200

%define BALL_RADIUS 8

%define KEY_DOWN 264
%define KEY_UP 265

extern CheckCollisionCircleRec
extern IsKeyDown

section .text
global move_paddle
move_paddle:
	mov r8d, dword[paddle_positions + 4]
	jmp .exit
	.check_down:
	mov rdi, KEY_DOWN
	call IsKeyDown
	cmp rax, 0x0
	je .check_up
	add r8d, PADDLE_SPEED 
	.check_up:
	mov rdi, KEY_UP
	call IsKeyDown
	cmp rax, 0x0
	je .exit
	sub r8d, PADDLE_SPEED 
	
	.exit:
	mov dword[paddle_positions + 4], r8d
	ret

global move_ball
move_ball:
	movq xmm0, qword [ball_position]
	movq xmm1, qword [ball_velocities]
	paddd xmm0, xmm1
	movdqu [ball_position], xmm0

	cmp dword[ball_position], SCREEN_WIDTH - BALL_RADIUS
	jl .check_x_min
	neg dword[ball_velocities]
	.check_x_min:
	cmp dword[ball_position], BALL_RADIUS
	jg .check_y_max
	neg dword[ball_velocities]
	.check_y_max:
	cmp dword[ball_position + 4], SCREEN_HEIGHT - BALL_RADIUS
	jl .check_y_min
	neg dword[ball_velocities + 4]
	.check_y_min:
	cmp dword[ball_position + 4], BALL_RADIUS
	jg .exit
	neg dword[ball_velocities + 4]
	.exit:
	mov rdi, 0x0 ; First paddle offset
	call check_for_hit
	cmp rax, 0x0
	je .return
	mov qword[ball_velocities], 0x0 ; Stop the ball when colliding
	.return:
	ret
check_for_hit:
	xor rax, rax
	ret
section .data
; Trust me bro
paddle_positions dd 2 * PADDLE_WIDTH, SCREEN_HEIGHT / 2 - PADDLE_HEIGHT, SCREEN_WIDTH - 3 * PADDLE_WIDTH, SCREEN_HEIGHT / 2 - PADDLE_HEIGHT
ball_position dd SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0x0, 0x0
ball_velocities dd 5, 4
temp dd 0x0, 0x0, 0x0, 0x0
section .rodata
ball_radius dd 8.0

color dq 0xFFFFFFFF
