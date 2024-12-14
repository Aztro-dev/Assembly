%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define BUF_SIZE 2000000

section .bss
input_buffer resb BUF_SIZE
output_buffer resb BUF_SIZE
array resd 200000 ; Max amount of numbers
temp_array resd 200000 ; Max amount of numbers
array_len resq 0x1
count resd 1 << 15

section .text
solve:
    call atoi
    mov r12, rax
    mov qword[array_len], r12
    xor r13, r13

    .loop:
        cmp r13, r12
        jge .exit_loop

        call atoi
        mov dword[array + 4 * r13], eax

        inc r13
        jmp .loop

    .exit_loop:

    call radix_sort

    mov r12, qword[array_len]
    xor r13, r13

    mov rax, 0x1
    
    .print_loop:
        cmp r13, r12
        je .exit_print_loop

        mov edi, dword[array + 4 * r13]
        mov esi, dword[array + 4 * r13 + 4]
        cmp edi, esi
        je .continue

        inc rax

        .continue:
        inc r13
        jmp .print_loop

    .exit_print_loop:

    call write_uint64
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

    ; Length of output buffer
    xor r11, r11

    call solve

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
    lea rax, [rax + rax * 4 - 48]        
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

    test rax, rax
    jnz .div ; keep pushing to stack for rest of number

    ; Add bytes created to r11 (length of output buffer)
    add r11, rbp
    sub r11, rsp

    ; copy stack string to buffer
    ; we do this to not have to keep track
    ; of the current position in the buffer
    .loop:
    mov cl, byte [rsp]
    inc rsp

    mov byte [r9], cl
    inc r9

    cmp rsp, rbp
    jl .loop

    mov byte[r9], 0x20 ; space
    inc r9
    inc r11

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

get_max:
    mov eax, dword[array]
    mov rbx, 0x1
    .loop:
        cmp rbx, qword[array_len]
        jge .exit
        cmp dword[array + 4 * rbx], eax
        jl .continue
        mov eax, dword[array + 4 * rbx]
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
        mov eax, dword[array + 4 * r10]
        div rcx
        mov r15, 10
        xor rdx, rdx
        div r15
        inc dword[count + 4 * rdx]

        inc r10
        jmp .count_loop
    .exit_count_loop:

    mov r10, 0x1
    .mutate_count_loop:
        cmp r10, 10
        jge .exit_mutate_count_loop
        
        mov eax, dword[count + 4 * r10 - 4]
        add dword[count + 4 * r10], eax
        
        inc r10
        jmp .mutate_count_loop
    .exit_mutate_count_loop:
    mov r10, qword [array_len]
    dec r10
    .output_loop:
        cmp r10, 0x0
        jl .exit_output_loop

        xor rdx, rdx
        mov eax, dword[array + 4 * r10]
        div rcx
        mov r15, 10
        xor rdx, rdx
        div r15

        mov r15d, dword[count + 4 * rdx]
        mov r14d, dword[array + 4 * r10]
        mov dword [temp_array + r15 * 4 - 4], r14d

        dec dword[count + 4 * rdx]

        dec r10
        jmp .output_loop
    .exit_output_loop:

    xor r10, r10
    .copy_output_loop:
        cmp r10, qword[array_len]
        jge .exit_copy_output_loop

        mov r15d, dword[temp_array + 4 * r10]
        mov dword[array + 4 * r10], r15d

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
