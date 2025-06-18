%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDOUT 1

section .data
brand db 48 dup(0) ; 48 bytes = 3 * 16-byte cpuid results

section .text
    global _start

_start:
    mov rdi, brand

    mov eax, 0x80000002
    call cpuid_to_mem

    mov eax, 0x80000003
    call cpuid_to_mem

    mov eax, 0x80000004
    call cpuid_to_mem

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, brand ; buffer
    mov edx, 48 ; length
    syscall

    mov eax, SYS_EXIT
    xor edi, edi
    syscall

cpuid_to_mem:
    push rbx
    push rcx
    push rdx

    cpuid
    mov dword [rdi], eax
    mov dword [rdi+4], ebx
    mov dword [rdi+8], ecx
    mov dword [rdi+12], edx
    add rdi, 16

    pop rdx
    pop rcx
    pop rbx
    ret
