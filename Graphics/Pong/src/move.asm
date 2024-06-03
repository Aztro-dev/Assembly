
%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600

section .text
global move_paddle
move_paddle:
	mov dword[paddle_positions], 0x0
	mov dword[paddle_positions + 0x4], 0x0
	ret

global move_ball
move_ball:
	movq xmm0, qword [ball_position]
	movq xmm1, qword [ball_velocities]
	paddd xmm0, xmm1
	movdqu [ball_position], xmm0

	cmp dword[ball_position], SCREEN_WIDTH - 8 ; ball_radius
	jl .check_x_min
	neg dword[ball_velocities]
	.check_x_min:
	cmp dword[ball_position], 8 ; ball_radius
	jg .check_y_max
	neg dword[ball_velocities]
	.check_y_max:
	cmp dword[ball_position + 4], SCREEN_HEIGHT - 8 ; ball_radius
	jl .check_y_min
	neg dword[ball_velocities + 4]
	.check_y_min:
	cmp dword[ball_position + 4], 8 ; ball_radius
	jg .exit
	neg dword[ball_velocities + 4]
	.exit:
	ret

section .data

paddle_positions dd 0x0, 0x0
ball_position dd SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0x0, 0x0
ball_radius dd 8.0
ball_velocities dd 1, 1

color dq 0xFFFFFFFF
