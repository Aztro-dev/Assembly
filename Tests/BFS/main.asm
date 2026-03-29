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
    ; Calculate max index
    mov rax, rdx
    imul rsi
    mov r13, rax ; r13 = N * M
    ; rax = i
    xor rax, rax
    ; Stores real current index in order to ignore whitespace when parsing
    xor rcx, rcx
    ; Store start and end
    xor r14, r14
    xor r15, r15

    .init_board_parse:
        ; Exit if we have gone past the max index allowed
        cmp rcx, r13
        jge .init_board_exit_parse

        mov bl, byte[rdi + rax]

        ; If the character is less than ASCII hashtag, we skip
        cmp bl, '#'
        jl .init_board_continue

        ; Store start point in r14
        cmp bl, 'A'
        cmove r14, rcx

        ; Store end point in r15
        cmp bl, 'B'
        cmove r15, rcx

        ; Copy byte over to board
        mov byte[board + rcx], bl
        inc rcx

        .init_board_continue:
        inc rax
        jmp .init_board_parse
    .init_board_exit_parse:
    ; Store the start and end for the board in da pointers
    mov dword[board_start], r14d
    mov dword[board_end], r15d
    mov rax, board
    ret

global get_start
; Returns: board_start
get_start:
    mov eax, dword[board_start]
    ret

global get_end
; Returns: board_end
get_end:
    mov eax, dword[board_end]
    ret

global bfs
bfs:
    ret
