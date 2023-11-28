section .data
    uint64_buffer db 20 dup(0x0) ; 20 Digits in uint64_t

section .text
global read_int

clear_uint64_buffer:
    push rsi
    push rcx
    mov rcx, 20 ; 20 characters
    mov rsi, uint64_buffer
    .clear_loop:
        mov byte [rsi], 0x0 ; Clear byte
        inc rsi
        cmp rcx, 0x0 ; See if rcx is 0
        je .exit_loop
        dec rcx
        jmp .clear_loop
    .exit_loop:
    pop rcx
    pop rsi
    ret

atoi:
    mov rax, 0              ; Set initial total to 0
     
    .convert:
        movzx rsi, byte [rdi]   ; Get the current character
        test rsi, rsi           ; Check for \0
        je .done
        
        cmp rsi, 48             ; Anything less than 0 is invalid
        jl .error
        
        cmp rsi, 57             ; Anything greater than 9 is invalid
        jg .error
         
        sub rsi, 48             ; Convert from ASCII to decimal 
        imul rax, 10            ; Multiply total by 10
        add rax, rsi            ; Add current digit to total
        
        inc rdi                 ; Get the address of the next character
        jmp .convert
    
    .error:
        mov rax, -1             ; Return -1 on error
     
    .done:
        ret                     ; Return total or error code

; read_int(rdi fd) -> rax output
read_int:
    mov rdi, 0x0 ; STDIN
    mov rsi, uint64_buffer
    mov rdx, 0x1 ; One character at a time
    .read_loop:
        xor rax, rax ; READ syscall
        syscall
        cmp byte [rsi], 0x0 ; Null character
        je .exit_read_loop
        cmp byte [rsi], 0x0a ; newline
        je .exit_read_loop
        sub rsi, 20
        cmp rsi, uint64_buffer
        je .exit_read_loop
        add rsi, 21 ; Reset to previous value and increment
        jmp .read_loop
    .exit_read_loop:
    mov rax, 0x1 ; WRITE
    mov rdi, 0x1 ; STDOUT
    mov rsi, uint64_buffer
    mov rdx, 20 ; Size of uint64_buffer
    syscall
    mov rdi, uint64_buffer
    call atoi
    call clear_uint64_buffer
    ret
