section .note.GNU-stack; so gcc doesn't complain

section .text
global  increasing_array

	; increasing_array(ecx length, rdx nums)

increasing_array:
	xor rax, rax; output = 0
	cmp ecx, 0x1; if length == 1
	jle .exit; return

	mov rsi, rdx; Store the pointer to the numbers in rsi
	xor rbx, rbx; we need to clear the high part of rbx
	xor rdx, rdx; We need to clear the high part of rdx

	mov ebx, dword [rsi]; int prev_num = rsi[0]
	add rsi, 4; next dword
	mov edx, dword [rsi]; int curr_num = rsi[1]

.loop:
	cmp ecx, 0x1; if (ecx <= 1)
	jl  .exit; return
	dec ecx; ecx--

	cmp edx, ebx; if(edx <= ebx)
	jle .continue

	mov r8, rbx; temp val
	sub r8, rdx; rsi[i - 1] - rsi[i]
	add rax, r8; sum += rsi[i - 1] - rsi[i]
	mov dword [rsi], ebx; rsi[i] = rsi[i - 1]

.continue:
	mov ebx, edx; prev_num = curr_num
	add rsi, 4; next dword
	mov edx, dword[rsi]; curr_num = nums[i]
	jmp .loop

.exit:
	ret
