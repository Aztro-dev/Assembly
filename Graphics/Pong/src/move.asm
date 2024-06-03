%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 600
%define PADDLE_WIDTH SCREEN_HEIGHT / 80
%define PADDLE_HEIGHT SCREEN_HEIGHT / 8
%define BALL_RADIUS 8

extern CheckCollisionCircleRec

section .text
global move_paddle
move_paddle:
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
	mov qword[ball_velocities], 0x0
	.return:
	ret
check_for_hit:
	; https://stackoverflow.com/a/402010
	movq xmm0, qword[ball_position]
	movq xmm1, qword[paddle_positions + rdi] ; Offset = the paddle we want to check
	psubd xmm0, xmm1
	pabsd xmm0, xmm0
	movdqu [temp], xmm0
	cmp dword[temp], PADDLE_WIDTH / 2 + BALL_RADIUS
	jg .return_false
	cmp dword[temp + 4], PADDLE_HEIGHT / 2 + BALL_RADIUS
	jg .return_false
	cmp dword[temp], PADDLE_WIDTH / 2
	jle .return_true
	cmp dword[temp + 4], PADDLE_HEIGHT / 2
	;jle .return_true
	jmp .return_false
	mov eax, dword[temp + 4]
	mov dword[temp + 8], eax ; For the multiply that is coming later
	movdqu xmm0, [temp]
	mov dword[temp], PADDLE_WIDTH / 2
       	mov dword[temp + 4],PADDLE_HEIGHT / 2
	psubd xmm0, [temp]
	pmuldq xmm0, xmm0
	vpmovqd xmm0, xmm0 ; quadword to dword
	movdqu [temp], xmm0
	mov eax, dword[temp]
	add eax, dword[temp + 4]
	cmp eax, BALL_RADIUS * BALL_RADIUS
	;jle .return_true
	
	.return_false:
	xor rax, rax
	ret
	.return_true:
	mov rax, 0x1
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
