%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define BUF_SIZE 2000

section .bss
input_buffer resb BUF_SIZE
output_buffer resb BUF_SIZE
array resq 20
array_len resq 1
temp_array resq 20
count resq 10

section .text
get_max:
    mov rax, qword[array]
    mov rbx, 0x1
    .loop:
        cmp rbx, qword[array_len]
        jge .exit
        cmp qword[array + 8 * rbx], rax
        jl .continue
        mov rax, qword[array + 8 * rbx]
        .continue:
        inc rbx
        jmp .loop
    .exit:
    ret

count_sort:
    xor r10, r10
    .count_loop:
        cmp r10, qword[array_len]
        jge .exit_count_loop
        
        xor rdx, rdx
        mov rax, qword[array + 8 * r10]
        div rcx
        mov r15, 10
        xor rdx, rdx
        div r15
        inc qword[count + 8 * rdx]

        inc r10
        jmp .count_loop
    .exit_count_loop:

    mov r10, 0x1
    .mutate_count_loop:
        cmp r10, 10
        jge .exit_mutate_count_loop
        
        mov rax, qword[count + 8 * r10 - 8]
        add qword[count + 8 * r10], rax
        
        inc r10
        jmp .mutate_count_loop
    .exit_mutate_count_loop:
    mov r10, [array_len]
    dec r10
    .output_loop:
        cmp r10, 0x0
        jl .exit_output_loop

        xor rdx, rdx
        mov rax, qword[array + 8 * r10]
        div rcx
        mov r15, 10
        xor rdx, rdx
        div r15

        mov r15, qword[count + 8 * rdx]
        mov r14, qword[array + 8 * r10]
        mov qword [temp_array + r15 * 8 - 8], r14        

        dec qword[count + 8 * rdx]

        dec r10
        jmp .output_loop
    .exit_output_loop:

    xor r10, r10
    .copy_output_loop:
        cmp r10, qword[array_len]
        jge .exit_copy_output_loop

        mov r15, qword[temp_array + 8 * r10]
        mov qword[array + 8 * r10], r15

        inc r10
        jmp .copy_output_loop
    .exit_copy_output_loop:
    
    ret

radix_sort:
    call get_max
    mov rbx, rax

    mov rcx, 0x1
    .loop:
        cmp rbx, rcx
        jl .exit

        call count_sort

        ; multiply exponent by 10
        shl rcx, 0x1
        lea rcx, [rcx + 4 * rcx]
        jmp .loop

    .exit:
    ret

global _start
_start:
    mov r8, input_buffer
    mov r9, output_buffer
    
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, r8
    mov rdx, BUF_SIZE
    syscall

    call atoi

    mov qword [array_len], rax

    call input_array

    call radix_sort
    
    call output_array

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, output_buffer
    mov rdx, r11
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0x0
    syscall
    ret

atoi:
    xor rax, rax
    .loop:
    movzx rcx, byte [r8]
    inc r8

    cmp cl, 0x30
    jl .end
    
    ; rax = 10 * rax - '0'
    shl rax, 1		
    lea rax, [rax + rax * 4 -48]        
    ; rax += character
    add rax, rcx

    jmp .loop
    .end:
    ret
write_uint64:
    push rax
    push rbp
    push rcx
    push rdx

    mov rcx, 10
    mov rbp, rsp
    .div:
    xor rdx, rdx
    div rcx
    add rdx, 0x30 ; num % 10 + '0'

    dec rsp
    mov byte [rsp], dl ; push character to stack

    ; Add bytes created to r11 (length of output buffer)
    add r11, rbp
    sub r11, rsp

    test rax, rax
    jnz .div ; keep pushing to stack for rest of number

    ; copy stack string to buffer
    ; we do this to not have to keep track
    ; of the current position in the buffer
    .loop:
    mov cl, byte [rsp]
    inc rsp

    mov byte [r9], cl
    inc r9

    inc r11

    cmp rsp, rbp
    jl .loop

    mov byte[r9], 0x20 ; space
    inc r9

    pop rdx
    pop rcx
    pop rbp
    pop rax
    ret

write_newline:
    mov byte [r9], 0x0a
    inc r9
    inc r11
    ret
    
input_array:
    mov rbx, 0x0
    .loop:
        cmp rbx, qword[array_len]
        jge .exit
        call atoi
        mov qword[array + 8 * rbx], rax
        inc rbx
        jmp .loop
    .exit:
    ret

output_array:
    mov rbx, 0x0
    .loop:
        cmp rbx, qword[array_len]
        jge .exit
        mov rax, qword[array + 8 * rbx]
        call write_uint64
        inc rbx
        jmp .loop
    .exit:
    ret
