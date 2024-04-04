%define SYS_READ 0x0
%define STDIN 0x0
%define SYS_WRITE 0x1
%define STDOUT 0x1
%define TAPE_SIZE 30000

section .data
    tape times TAPE_SIZE db 0x0
    input times 1024 db 0x0

section .text
global _start

interpret:
    mov r8, TAPE_SIZE
    sal r8, 1 ; middle of tape
    mov r9, input
    lea rsi, [tape + r8] ; Pointer
    .loop:
        mov al, byte [r9]
        cmp al, 0x0
        je .exit_loop
            cmp al, '>'
            jne .check_left_arrow
            inc rdi ; ptr++
        jmp .loop
        .check_left_arrow:
            cmp al, '<'
            jne .check_plus
            dec rdi ; ptr--
        jmp .loop
        .check_plus:
            cmp al, '+'
            jne .check_minus
            mov ah, byte[rsi]
            inc ah
            mov byte[rsi], ah
        jmp .loop
        .check_minus:
            cmp al, '-'
            jne .check_dot
            mov ah, byte[rsi]
            dec ah
            mov byte[rsi], ah
        jmp .loop
        .check_dot:
            cmp al, '.'
            jne .check_comma
            mov rax, SYS_WRITE
            mov rdi, STDOUT
            mov rdx, 0x1
            syscall
        jmp .loop
        .check_comma:
            cmp al, ','
            jne .check_open_bracket
            mov rax, SYS_READ
            mov rdi, STDIN
            mov rdx, 0x1
            syscall
        jmp .loop
        .check_open_bracket:
            cmp al, '['
            jne .check_closed_bracket
            mov al, byte[rsi]
            cmp al, 0x0
            je .loop ; Skip if *ptr is not true
            mov rcx, 0x1 ; loop counter
            .open_bracket_loop:
                cmp rcx, 0x0
                je .loop
                inc rsi
                mov al, byte[rsi]
                cmp al, '['
                jne .open_bracket_loop_closed_bracket
                inc rcx
            jmp .open_bracket_loop
            .open_bracket_loop_closed_bracket:
                cmp al, ']'
                jne .open_bracket_loop
                dec rcx
            jmp .open_bracket_loop
        .check_closed_bracket:
            cmp al, ']'
            jne .loop
            mov al, byte[rsi]
            cmp al, 0x0
            je .loop ; Skip if *ptr is not true
            mov rcx, 0x1 ; loop counter
            .closed_bracket_loop:
                cmp rcx, 0x0
                je .loop
                inc rsi
                mov al, byte[rsi]
                cmp al, '['
                jne .closed_bracket_loop_closed_bracket
                dec rcx
            jmp .closed_bracket_loop
            .closed_bracket_loop_closed_bracket:
                cmp al, ']'
                jne .closed_bracket_loop
                inc rcx
            jmp .closed_bracket_loop
    .exit_loop:
    ret

_start:
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, input
    mov rdx, 1024
    syscall

    call interpret
    
    mov rax, 60
    mov rdi, 0
    syscall
