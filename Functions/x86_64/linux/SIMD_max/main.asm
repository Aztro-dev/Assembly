%define VERIFICATION 0 ; Used to verify the output

%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1

%define NUMBERS_LEN 1000000

section .bss
numbers resd 4 * NUMBERS_LEN

section .data
output_buffer times(20) db '0'

section .text
; input nums in rdi
; output num in rax
avx2_uint32_max:
    vmovdqu ymm0, [rdi]
    mov rcx, 0x0
    .loop:
        cmp rcx, NUMBERS_LEN
        jge .exit_loop
        vpmaxud ymm0, [rdi + rcx * 4]
        inc rcx
        jmp .loop
    
    .exit_loop:
    vextracti128 xmm1, ymm0, 1 ; xmm1 = higher 128 bits of ymm0
    ; xmm0 already has the lower 128 bits of ymm0

    vpmaxud xmm0, xmm0, xmm1 ; xmm0 = max (lower 128, higher 128)
    ; leaves 4 values left to combine

    vpshufd xmm1, xmm0, 0b10110001 ; xmm1 = xmm0[0b10, 0b11, 0b00, 0b01] = xmm0[2, 3, 0, 1]
    vpmaxud xmm0, xmm0, xmm1 ; xmm0 = [max (3, 2), max(2, 3), max(1, 0), max(0, 1) ]
    ; leaves 2 values left to combine

    vpshufd xmm1, xmm0, 0b01001110 ; xmm1 = xmm0[0b01, 0b00, 0b11, 0b10] = xmm0[1, 0, 3, 2]
    vpmaxud xmm0, xmm0, xmm1 ; exercise for the reader
    ; max stored in all slots

    movd eax, xmm0
    ret

global _start
_start:
    call generate_rand

    mov rdi, numbers
    call avx2_uint32_max
    
    %if VERIFICATION
        push rax
        call print_newline
        pop rdi
    %else
        mov rdi, rax
    %endif

    .before_print:

    call print_uint64

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret

generate_rand:
    lea rax, [numbers + 4 * NUMBERS_LEN - 4]
    .loop:
        cmp rax, numbers
        jl .exit_loop
        rdrand ebx

        %if VERIFICATION
            push rax
            push rbx
            mov rdi, rbx
            call print_uint64
            call print_newline
            pop rbx
            pop rax
        %endif

        mov dword[rax], ebx
        sub rax, 0x4
        jmp .loop
    .exit_loop:
    ret

print_uint64:
	push rax
	push rsi
	push rdx
	mov  r8, 10; Base 10

	mov rax, rdi
	mov rsi, output_buffer
	add rsi, 19; Last digit of buffer
	mov r9, 0x0; Size

.loop:
	cmp rax, 0x0
	jle .exit_loop
	xor rdx, rdx
	div r8
	add dl, 48; To ASCII num
	mov byte [rsi], dl
	dec rsi
	inc r9
	jmp .loop

.exit_loop:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, [output_buffer + 20]
	sub rsi, r9
	mov rdx, r9
	syscall

	pop rdx
	pop rsi
	pop rax

	ret

print_newline:
    sub rsp, 0x1
    mov byte[rsp], 0x0a ; newline

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 0x1
    syscall

    add rsp, 0x1
    ret
