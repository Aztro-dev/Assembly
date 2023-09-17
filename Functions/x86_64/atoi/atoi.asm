section .note.GNU-stack

section .text

extern strlen

global atoi_asm

atoi_asm:
	;    int64_t atoi(const char* buffer)
	call strlen ; length stored in rax
	imul 0x4 ; length of string * 4 (int size)

		
	ret
