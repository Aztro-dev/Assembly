%define SYS_READ  0
%define SYS_WRITE 1
%define SYS_BRK   12
%define SYS_EXIT  60

%define STDIN  0
%define STDOUT 1
%define STDERR 2

; 8x8 board 
%define BOARD_SIZE (8 * 8) / 8 ; / 8 is because we are packing bits

section .bss
board resb BOARD_SIZE
board_output_buffer resb BOARD_SIZE * 8

section .rodata
board_bit_mask db 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01, \
                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, \
                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, \
                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                  
ones times(32) db 0x1
char_zeroes times(32) db 48

section .text
global _start

_start:
    call populate_board

    call print_board
    
    mov rax, 60
    mov rdi, 0
    syscall

print_board:
    xor rcx, rcx
    mov rsi, board_output_buffer
    vmovdqu ymm1, [board_bit_mask]
    vmovdqu ymm2, [ones]
    vmovdqu ymm3, [char_zeroes]
    vpxor ymm4, ymm4
    .loop:
        cmp rcx, BOARD_SIZE
        jge .exit_loop
        
        xor rax, rax
        mov al, byte[board + rcx]
        vmovd xmm0, eax
        vpbroadcastb ymm0, xmm0
        vpand ymm0, ymm0, ymm1

        ; if ymm0[i] > 0 => 0xFF, else => 0x00
        vpcmpgtb ymm0, ymm0, ymm4
        vpand ymm0, ymm0, ymm2

        vpaddb ymm0, ymm3

        movq [rsi], xmm0
        add rsi, 0x8
        mov byte[rsi], 0x0a ; newline
        inc rsi
        
        inc rcx
        jmp .loop
    .exit_loop:
    
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, board_output_buffer
    mov rdx, BOARD_SIZE * 9 - 1
    syscall
    ret

populate_board:
    mov rdi, board
    xor rcx, rcx
    .loop:
        cmp rcx, BOARD_SIZE
        jge .exit_loop

        rdrand rax
        mov qword[board], rax

        add rcx, 8
        jmp .loop
    .exit_loop:
    ret
