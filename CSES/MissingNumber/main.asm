section .data
    msg db "Input N: " ; len(msg) = 9
    end_message db 0x0a, "end message" ; newline and "end message"
    end_message_len dq 0xc ; len(end_message) = 12
section .text
    global _start

; len_of_rsi(rsi pointer_to_arr) -> rdx
; moves the length of the arr stored in rsi into rdx
length_of_rsi:
    push rsi ; Will use rsi as a pointer, so we need to save it first
    xor rdx, rdx
    .length_loop:
        inc rdx ; increment output (length)
        cmp byte [rsi], 0x0 ; make sure current byte isn't null
        je .end_length_loop ; if current byte is null, exit
        inc rsi ; move along in pointer
        jmp .length_loop ; loop (duh)
    
    .end_length_loop:
    pop rsi ; restore rsi
    ret
    
; print(rsi pointer_to_string, rdx buffer_size)
print:
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    syscall
    ret
    
; read(rsi destination, rdx destination_length)
read:
    xor rax, rax ; read
    xor rdi, rdi ; stdin
    syscall
    ret
; atoi (rsi pointer_to_ascii) -> rdx
atoi:   xor rax,rax ; rax = 0
        xor rdx,rdx ; rdx = 0
        lodsb ; load byte at address RSI into AL.
        cmp al,'-' ; 
        sete bl ; bl = negative flag
        jne .lpv ; jump to .lpv if positive
.lp:    lodsb ; load byte at address RSI into AL
.lpv:   sub al,'0' ; turns al into number
        jl .end ; if sign flag != overflow flag, jump to .end
        imul rdx,10 ; rdx *= 10
        add rdx,rax ; rdx += rax
        jmp .lp ; load byte at address RSI into AL
.end:   test bl,bl ; bl & bl
        jz .p ; if bl is zero, return
        neg rdx ; rdx = -rdx
        ; xchg rax, rdx
.p      ret


itoa:   std ; rsi--, rdi--
        mov r9,10 ; base 10
        bt rax,63 ; cp bit 63 (most significant, handles negatives) in rax to carry flag
        setc bl ; if carry flag is set, set bl to 1 (negative sign)
        jnc .lp 
        neg rax
.lp:    xor rdx,rdx
        div r9
        xchg rax,rdx
        add rax,'0'
        stosb
        xchg rax,rdx
        test rax,rax
        jnz .lp
        test bl,bl
        jz .p
        mov al,'-'
        stosb
.p:     cld
        inc rdi
        ret

atoi_rcx:
    mov rsi, buff
    call atoi ; atoi(rsi input) -> rdx
    mov rcx, rdx ; store value of atoi
    mov rdi,buff+18 ; end of buff
    mov rsi,rdi ; rsi = rdi
    std ; rsi--, rdi--
    mov rax, 10
    stosb ; al = [rsi]
    ret

; split_newline(rsi pointer) -> rsi after_newline
split_newline:
    xor r8, r8
    .loop:
        cmp byte [rsi], 0x0a ; newline
        je .exit
        inc r8
        inc rsi
        jmp .loop
    sub rsi, r8
    dec rsi
    .exit:
    inc rsi
    ret

; split_space(rsi pointer) -> rsi after_space
split_space:
    xor r8, r8
    .loop:
        cmp byte [rsi], 0x20 ; space
        je .exit
        inc r8
        inc rsi
        jmp .loop
    sub rsi, r8
    dec rsi
    .exit:
    inc rsi
    ret


; sum_of_all(rcx n) -> r8 output
sum_of_all:
    mov rax, rcx
    mov r8, rcx
    mul r8
    ret



; missing_number(rcx n, r8 sum_of_all, rsi input) -> rcx output
missing_number:
    .loop:
        cmp rcx, 1
        je .exit
        dec rcx ; run 1 - n times

        
        
        jmp .loop

        
    .exit:
    ret




    
    

_start:
    mov rsi, msg ; pointer to message
    mov rdx, 9 ; len of msg
    call print ; print(rsi pointer_to_string, rdx buffer_size)
    
    
    mov rsi, buff ; address of buffer
    mov rdx, 19 ; buffer size
    call read

    ; atoi_rcx(rsi pointer_to_ascii) -> rcx output
    call atoi_rcx
    mov qword [n], rcx

    ; sum_of_all(rcx n) -> r8 output
    call sum_of_all

    ; missing_number(rcx n, r8 sum_of_all) -> rcx output
    call missing_number
    
    mov rax, rcx
    
    ; itoa(rax integer) -> 
    call itoa
    sub rsi,rdi
    mov rdx,rsi
    mov rsi,rdi
    inc rdx
    call print

    
    
    mov rsi, end_message
    mov rdx, [end_message_len]
    call print
    
    mov rax, 60 ; exit
    mov rdi, 0
    syscall

section .bss ; block starting symbol
buff: resb 19
n: resb 8
