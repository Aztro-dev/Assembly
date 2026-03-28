default REL

%define BOARD_SIZE 10
%define BFS_WALL '#'

section .bss
; Assuming square board
board: resb (BOARD_SIZE * BOARD_SIZE)
visited: resb (BOARD_SIZE * BOARD_SIZE)
previous_path: resb (BOARD_SIZE * BOARD_SIZE)
; 2 words for each (x, y) pair
; Might change depending on board size
queue: resw (2 * BOARD_SIZE * BOARD_SIZE)
; Start and end positions on the board
board_start: resw 2
board_end: resw 2

section .data
queue_start: dq queue
queue_end: dq queue

section .text
global init_board
; rdi: ptr to input
; rsi: N
; rdx: M
init_board:
    ; rax = i
    xor rax, rax

    .init_board_parse:
        mov bh, ' ' ; Empty 
        mov bl, byte[rdi + rax]
        cmp bl, '#'
        cmove bh, bl
        cmp bl, '#'
        cmove bh, bl
        jmp .init_board_parse
    .init_board_exit_parse:
    mov rax, board
    ret

global bfs
bfs:
    ret
