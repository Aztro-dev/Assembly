section .note.GNU-stack

section .text
global  repetitions

	; int repetitions(ecx length, rdx* string)

repetitions:
	mov eax, 0x1; max_count
	cmp ecx, 0x1
	je  .loop_exit

	mov ebx, 0x1; curr_count
	mov rsi, rdx
	mov dh, byte[rsi]; store prev_char
	inc rsi; next byte
	mov dl, byte[rsi]; curr_char

.loop:
	;   while(true)
	cmp ecx, 0x1; if (i <= 1)
	jle .loop_exit; return
	dec ecx; i--

	cmp dh, dl; if(prev_char == curr_char)
	je  .equal
	jmp .not_equal

.equal:
	inc   ebx; curr_count++
	cmp   eax, ebx; if(eax < ebx)
	cmovl eax, ebx; eax = ebx
	mov   dh, byte[rsi]; prev_char = *rsi
	inc   rsi; next byte
	mov   dl, byte[rsi]; curr_char = *rsi
	jmp   .loop

.not_equal:
	cmp   eax, ebx; if(eax < ebx)
	cmovl eax, ebx; eax = ebx
	mov   ebx, 0x1; reset ebx
	mov   dh, byte[rsi]; prev_char = *rsi
	inc   rsi; next byte
	mov   dl, byte[rsi]; curr_char = *rsi
	jmp   .loop

.loop_exit:
	ret
