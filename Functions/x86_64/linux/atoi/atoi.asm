section .note.GNU-stack

section .text

extern strlen

global atoi_asm

atoi_asm:
	mov   rdx, 0x1
	;     int64_t atoi(const char* buffer)
	call  strlen; length (in elements) stored in rax
	mov   rcx, rax; rcx will be the iterator
	mov   rsi, rdi
	mov   al, byte[rsi]; result stored in al
	cmp   al, '-'; if number is negative
	cmove r8w, dx; set sign flag to 1
	xor   rdx, rdx; clear rdx (output)

	xor rax, rax; clear rax

.loop:
	cmp rcx, 0x1; while(rcx > 1)
	jle .exit
	dec rcx

	mov al, byte[rsi]; result stored in al
	sub al, '0'; ascii char to int
	add rdx, rax

	inc rsi; next byte

	jmp .loop

.negate:
	neg rax; negate result
	jmp .return

.exit:
	mov rdx, rax
	cmp r8w, 0x1; if sign flag is set
	je  .negate

.return:
	ret
