%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600

%define PADDLE_WIDTH SCREEN_HEIGHT / 80
%define PADDLE_HEIGHT SCREEN_HEIGHT / 8
%define PADDLE_SPEED SCREEN_HEIGHT / 200

%define BALL_RADIUS 8

%define KEY_S 83
%define KEY_W 87
%define KEY_DOWN 264
%define KEY_UP 265

; Debug tools
%include "src/utils.asm"

extern IsKeyDown
extern CheckCollisionCircleRec

section .text
global move_paddles
move_paddles:
	mov r8d, dword[rdi]
	push rdi

	.check_down:
	mov edi, eax
	call IsKeyDown
	test rax, 0x1
	je .check_up
	add r8d, PADDLE_SPEED 
	.check_up:
	mov edi, ebx
	call IsKeyDown
	test rax, 0x1
	je .check_too_high
	sub r8d, PADDLE_SPEED 

	.check_too_high:
	cmp r8d, 0x0
	jge .check_too_low
	mov r8d, 0x0
	jmp .exit
	.check_too_low:
	cmp r8d, SCREEN_HEIGHT - PADDLE_HEIGHT
	jle .exit
	mov r8d, SCREEN_HEIGHT - PADDLE_HEIGHT

	.exit:
	pop rdi
	mov dword[rdi], r8d
	ret

global move_ball
move_ball:
	movq xmm0, qword [ball_position]
	movq xmm1, qword [ball_velocities]
	paddd xmm0, xmm1
	movdqu [ball_position], xmm0

	.check_x_max:
	cmp dword[ball_position], SCREEN_WIDTH - BALL_RADIUS
	jl .check_x_min
	mov qword[ball_velocities], 0x0
	mov rax, 0x1
	ret
	.check_x_min:
	cmp dword[ball_position], BALL_RADIUS
	jg .check_y_max
	mov qword[ball_velocities], 0x0
	mov rax, 0x1
	ret
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
	test rax, 0x1
	je .check_other_paddle
	neg dword[ball_velocities]
	jmp .return
	.check_other_paddle:
	mov rdi, 0x8 ; First paddle offset
	call check_for_hit
	test rax, 0x1
	je .return
	neg dword[ball_velocities]

	.return:
	xor rax, rax
	ret
check_for_hit:
	mov dword[temp], PADDLE_WIDTH
	mov dword[temp + 4], PADDLE_HEIGHT

	movq xmm0, qword [ball_position]
	movss xmm1, dword[ball_radius]
	movq xmm2, qword[paddle_positions + rdi]
	movq xmm3, qword[temp]

	cvtdq2ps xmm0, xmm0
	cvtdq2ps xmm2, xmm2
	cvtdq2ps xmm3, xmm3

	call CheckCollisionCircleRec
	and rax, 0x1
	ret
section .data
; Trust me bro
align 2
paddle_positions dd 2 * PADDLE_WIDTH, SCREEN_HEIGHT / 2 - PADDLE_HEIGHT, SCREEN_WIDTH - 3 * PADDLE_WIDTH, SCREEN_HEIGHT / 2 - PADDLE_HEIGHT
ball_position dd SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 0x0, 0x0
ball_velocities dd 3, 2
temp dd 0x0, 0x0, 0x0, 0x0

section .rodata
ball_radius dd 8.0

print_int_message db "%d", 0x0a, 0x0
print_floats_message db "Ball pos: (%.1f, %.1f), Ball radius: %.1fpx, Paddle pos: (%.1f, %.1f)", 0x0a, 0x0

color dq 0xFFFFFFFF
