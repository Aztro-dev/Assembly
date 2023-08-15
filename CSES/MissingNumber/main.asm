section .text
    global _start

; length_of_rsi(rsi pointer_to_arr) -> rdx
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
    push rdi
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    syscall
    pop rdi
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

; atoi(rsi input) -> rcx
atoi_rcx:
    mov rsi, input
    call atoi ; atoi(rsi input) -> rdx
    mov rcx, rdx ; store value of atoi
    mov rdi,input+18 ; end of buff
    mov rsi,rdi ; rsi = rdi
    std ; rsi--, rdi--
    mov rax, 10
    stosb ; al = [rsi]
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

; get_digits(rsi number) -> r8 digits
get_digits:
    xor r8, r8
    mov r9, rsi
    .loop:
        cmp byte [r9], '0'
        jl .exit
        cmp byte [r9], '9'
        jg .exit
        inc r9 ; next byte
        inc r8 ; increment counter
    .exit:
    xor r9, r9
    ret
    
; bytes_in_line(rsi number) -> r8 bytes
bytes_in_line:
    xor r8, r8
    mov r9, rsi
    .loop:
        cmp byte [rsi], 0x0a ; newline
        je .exit
        cmp byte [rsi], 0x0 ; null
        je .exit
        inc rsi ; next byte
        inc r8 ; increment counter
    .exit:
    mov rsi, r9
    ret


; sum_of_all(rcx n) -> rdx rax output
sum_of_all:
    mov rax, rcx ; rax is one of the registers multiplied
    mov r8, rcx ; r8 is one of the registers multiplied
    mul r8 ; n^2, result is stored in rdx, rax (128 bits)

    add rax, rcx ; n^2 + n
    xor rdx, rdx; Dividend, 0
    ; division is calculated by dividing as if rdx is concatenated with rax
    
    mov r8, 0x2 ; Divide by two 
    div r8 ; Divide rdx rax by r8 and return result in rax, with remainder rdx
    ret



; missing_number(rcx n, rdx rax sum_of_all, rsi input) -> rax output
missing_number:
    mov rbx, rcx
    .loop:
        cmp rbx, 1
        je .exit
        dec rbx ; run 1 - n times
        
        call atoi_rcx
        sub rax,rcx

        ; get_digits(rsi input) -> r8 digits
        call get_digits
        add rsi, r8 ; skip digits
        inc rsi ; skip space
        
        jmp .loop
        
    .exit:
    ret
    

_start:
    mov rsi, input ; address of input
    mov rdx, 19 ; input size
    call read

    ; atoi_rcx(rsi pointer_to_ascii) -> rcx output
    call atoi_rcx
    mov qword [n], rcx ; store n


    push rsi ; store rsi

    mov rsi, input ; address of input
    ; get_digits(rsi number) -> r8 digits
    call get_digits

    mov rsi, input ; address of input
    add rsi, r8 ; mov rsi by digits
    inc rsi ; account for newline

    mov qword [second_line], rsi

    pop rsi ; restore rsi

    mov rcx, qword [n]

    ; sum_of_all(rcx n) -> rdx rax output
    call sum_of_all

    ; missing_number(rcx n, rdx rax sum_of_all) -> rcx output
    call missing_number
    
    mov rax, rcx
    
    ; itoa(rax integer) -> 
    call itoa
    sub rsi,rdi
    mov rdx,rsi
    mov rsi,rdi
    inc rdx
    ; call print
    
    mov rax, 60 ; exit
    mov rdi, 0
    syscall

section .bss ; block starting symbol
input: resb 19
n: resq 1
second_line: resq 1
