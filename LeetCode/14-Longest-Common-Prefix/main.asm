section .data
    strs db "flower", 0x0, "flow", 0x0, "flight", 0x0
    strs_len equ $ - strs

section .text

; string longestCommonPrefix(vector<string>& strs)
longestCommonPrefix:
    xor rax, rax
    xor r8, r8 ; Index for all strings
    ;mov r8, 0x0 ; Index for all strings
    .loop:
        mov rsi, strs
        add rsi, r8
        mov ah, byte [rsi]
        cmp ah, 0x0
        je .exit
        
        mov rcx, r8 ; Iterator starts at index
        .check_next_string:
            cmp rcx, strs_len
            jge .after_check_next_string
            
            .while_not_next_string:
                inc rcx
                mov al, byte [strs + rcx]
                cmp al, 0x0
                jne .while_not_next_string
            inc rcx
            mov al, byte [strs + r8 + rcx]
            cmp al, ah ;If the current character is not equal to desired character
            jne .exit
            
            jmp .check_next_string
        .after_check_next_string:
        inc r8
        jmp .loop
    .exit:
    mov rax, r8
    ret    


global _start

_start:
    ; Returns length of prefix
    call longestCommonPrefix
    
    mov rdx, rax ; length of prefix
    mov rax, 0x1 ; Write()
    mov rdi, 0x1 ; STDOUT
    mov rsi, strs
    syscall
    
    mov rax, 60
    mov rdi, 0
    syscall