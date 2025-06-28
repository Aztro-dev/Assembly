section .text
global fast_solve
fast_solve:
    mov rbx, 0x1 ; for n / 2
    .loop:
        cmp rdi, 0x1
        jle .exit_loop

        lea rsi, [rdi + 2 * rdi + 1]

        test rdi, 0x1
        shrx rdi, rdi, rbx
        cmovnz rdi, rsi

        jmp .loop
    .exit_loop:
    ret

global slow_solve
slow_solve:
    mov rax, rdi
    mov rdx, 1
    cmp rax, rdx
    je .end
 
    .weird:
        mov rsi, rax
        
        xor rdx, rdx
        mov rcx, 2
        div rcx
 
        test rdx, rdx
        jnz .odd
        .even:
        mov rdx, 1
        cmp rax, rdx
        je .end
        jmp .weird
        .odd:
        mov rax, rsi
        imul rax, 3
        add rax, 1
        jmp .weird
 
    .end:
    ret
