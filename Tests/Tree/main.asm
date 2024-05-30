%define VALUE_LENGTH 10
section .data
struc node
    .val resb VALUE_LENGTH
    .left resq 1
    .right resq 1
endstruc
tree istruc node
    at node.val, db "Hello"
    at node.left, dq 0
    at node.right, dq 0
iend
section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    lea rsi, [tree + node.val]
    mov rdx, VALUE_LENGTH
    syscall
    
    mov rax, 60
    mov rdi, 0
    syscall
