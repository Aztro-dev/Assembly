section .text

; string argumentsLength(...args)
argumentsLength:
    mov rax, rax
    ret    


global _start

_start:
    ; Returns length of arguments
    call argumentsLength
    
    mov rdi, rax
    mov rax, 60
    syscall
