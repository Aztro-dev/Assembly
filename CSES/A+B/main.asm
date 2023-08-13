
        section .text
        global _start
atoi:   xor rax,rax ; rax = 0
        xor rdx,rdx ; rdx = 0
        lodsb ; load byte at address RSI into AL.
        cmp al,'-' ; 
        sete bl ; bl = 1 if al = '-', else bl = 0
        jne .lpv ; jump to .lpv if bl == 0
.lp:    lodsb
.lpv:   sub al,'0' ; al -= 48, 0x30, 0b00110000
        jl .end ; if sign flag != overflow flag, jump to .end
        imul rdx,10 ;rdx *= 10
        add rdx,rax ; rdx += rax
        jmp .lp ; load byte at address RSI into AL
.end:   test bl,bl ; bl & bl
        jz .p ; if bl is zero, return
        neg rdx ; rdx = -rdx
.p      ret
itoa:   std ; set direction flag to 1 (down)
        mov r9,10
        bt rax,63
        setc bl
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
_start: xor rax,rax
        xor rdi,rdi
        mov rsi,buff
        mov rdx,100
        syscall
        mov rsi,buff
        lodsb
        mov rsi,buff
        call atoi
        mov rcx,rdx
        call atoi
        add rcx,rdx
        mov rdi,buff+99
        mov rsi,rdi
        std
        mov rax,10
        stosb
        mov rax,rcx
        call itoa
        sub rsi,rdi
        mov rdx,rsi
        mov rsi,rdi
        inc rdx
        mov rax,1
        mov rdi,rax
        syscall
        mov rax,60
        xor rdi,rdi
        syscall
        section .bss
buff:   resb 100
