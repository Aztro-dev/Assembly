default REL

%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_FSTAT 5
%define SYS_MMAP 9
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1
%define PROT_READ 1
%define MAP_PRIVATE 2

%define OUTPUT_BUF_SIZE 3_000_000

section .bss
output_buffer resb OUTPUT_BUF_SIZE

%macro ATOI 1
    xor %1, %1
    %%skip_whitespace:
    movzx r10, byte [r8]
    inc r8
    ; skip spaces and tabs and stuff
    cmp r10b, 0x30
    jl %%skip_whitespace

    %%loop:
    ; rax = 10 * rax - '0'
    lea %1, [%1 + %1 * 4]        
    ; rax += character - '0'
    lea %1, [%1 * 2 + r10 - '0']

    movzx r10, byte [r8]
    inc r8
    cmp r10b, 0x30
    jge %%loop
%endmacro

section .data
align 2
; lookup table for fast itoa
lut100:
    %assign i 0
    %rep 100
        %assign tens (i / 10) + '0' ; tens digit
        %assign ones (i % 10) + '0' ; ones digit
        db tens, ones ; write those jawns
        %assign i i+1
    %endrep

section .text
solve:
  mov rax, 0x55AA
  ret


global _start
_start:
    ; Use FSTAT to get file size
    mov rax, SYS_FSTAT
    mov rdi, STDIN
    mov rsi, stat_struct
    syscall

    ; File size is at 6 bytes offset of stat struct
    mov rsi, qword[stat_struct + 48]
    mov rax, SYS_MMAP
    xor rdi, rdi
    mov rdx, PROT_READ ; prot
    mov r10, MAP_PRIVATE ; flags
    mov r8, STDIN ; fd = 0
    xor r9, r9 ; offset = 0
    syscall

    mov r8, rax
    mov r9, output_buffer

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

write_uint32:
    push rax
    push rbp
    push rcx
    push rdx
    push r8

    mov rbp, rsp
    ; 16 byte playspace thingy
    sub rsp, 16
    ; point to end of buffer skull emoji
    lea r8, [rbp]

    .div100:
    mov r10, rax

    ; super duper fast divide new and improved
    ; divide by 100
    imul rax, rax, 1374389535 
    shr rax, 37
    ; This part is to find trhe remainder
    mov rcx, rax          
    imul rcx, rcx, 100
    sub r10, rcx
    
    ; lookup table my beloved (get 2 characters at the same time)
    mov dx, word [lut100 + r10 * 2]
    sub r8, 2
    mov word [r8], dx
    
    test rax, rax
    jnz .div100

    ; Make sure leading zeroes don't affect anything pls
    cmp byte [r8], '0'
    jne .no_leading_zero
    inc r8
    .no_leading_zero:

    ; branchless string copy
    mov r10, rbp
    sub r10, r8
    mov rax, [r8]            
    mov [r9], rax            
    mov ax, [r8 + 8]         
    mov [r9 + 8], ax

    add r9, r10

    ; update final size so we print the right number of chars
    lea r11, [r11 + r10]

    mov rsp, rbp
    pop r8
    pop rdx
    pop rcx
    pop rbp
    pop rax
    ret
