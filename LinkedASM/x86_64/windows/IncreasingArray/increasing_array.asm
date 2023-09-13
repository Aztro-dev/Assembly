section .note.GNU-stack

section .text
global  increasing_array

	; increasing_array(ecx length, rdx nums)

increasing_array:
	xor rax, rax; output = 0
	cmp ecx, 0x1; if length == 1
	jle .exit; return

	mov rsi, rdx
	xor rdx, rdx
	xor rbx, rbx

	mov ebx, dword [rsi]; prev_num = rsi[0]
	add rsi, 4; next dword
	mov edx, dword [rsi]; curr_num = rsi[1]

.loop:
	cmp ecx, 0x1; if (ecx <= 1)
	jle .exit; return
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
