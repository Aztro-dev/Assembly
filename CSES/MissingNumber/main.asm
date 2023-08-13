section .data
    msg db "Hello world!", 0x0a
    

section .text
    global _start

; ascii_to_integer(rsi ascii)
ascii_to_integer:
    xor rax,rax ; rax = 0
    xor rdx,rdx ; rdx = 0
    lodsb ; load byte at address RSI into AL.
    sub al, '0' ; ascii to integer
    
    loopy:
        call print_buff
        cmp al, 
    
    ret
    
print_buff:
    mov rax, 1 ; write
    mov rdi, 1 ; stdout
    mov rsi, buff ; pointer to buffer
    mov rdx, buff ; pointer to buffer
    add rdx, 1 ; pointer arithmetic
    mov byte [rdx], 0x0a ; newline
    mov rdx, 18 ; len of buffer
    syscall
    ret

_start:
    xor rax, rax ; read
    xor rdi, rdi ; stdin
    mov rsi, buff ; address of buffer

    mov rdx, 18 ; buffer size
    syscall
    
    mov rsi, buff ; store buff in rax
    
    call ascii_to_integer
    
    
    mov rax, 60 ; exit
    mov rdi, 0
    syscall

section .bss ; block starting symbol
buff: resb 19
