section .data
    haystack db "sadbutsad"
    haystack_len equ $ - haystack
    needle db "sad"
    needle_len equ $ - needle
    number_buffer db 20 dup(0x0)


section .text

; isEqualString(string str1)
isEqualString:
    push r8
    xor r8, r8 ; Index
    .loop:
        cmp r8, needle_len
        je .exit_true

        mov ah, byte [rdi]
        mov al, byte [needle + r8]
        cmp ah, al
        jne .exit_false
        inc rdi
        inc r8
        jmp .loop

    .exit_false:
    pop r8
    xor rax, rax
    ret

    .exit_true:
    pop r8
    mov rax, 0x1
    ret

; int strStr(string haystack, string needle) {
strStr:
    xor r8, r8 ; haystack index
    mov rdi, haystack
    
    .loop:
        cmp r8, haystack_len - needle_len + 1
        jge .not_found
        
        call isEqualString
        cmp rax, 0x1 ; If true
        je .exit
        
        inc rdi
        inc r8
        jmp .loop

    .not_found:
        mov rax, -1
        ret
    .exit:
        mov rax, r8
        ret


global _start

_start:
    ; Returns the index of the position
    call strStr

    .exit:
    mov rax, 60
    mov rdi, 0
    syscall
