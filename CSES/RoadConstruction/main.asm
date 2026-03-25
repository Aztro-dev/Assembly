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
stat_struct resb 144; 144 bytes to hold file info from fstat
output_buffer resb OUTPUT_BUF_SIZE
dsu_elements resd 100_000

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
; lookup table for fast atoi
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
  ; get num_cities and num_roads
  ATOI rax
  push rax
  ATOI rax
  ; rax = num_cities, rbx = num_roads
  mov rbx, rax
  pop rax

  ; rdi: number of elements
  ; rsi: sizeof(element)
  mov rdi, rax
  mov rsi, 0x4 ; Use dwords
  push rax
  call DSU_init
  pop rax

  ; r12 = connected_cities
  mov r12, rax
  ; rcx = biggest connection
  mov rcx, 1
  .loop:
    ; while roads-- > 0
    cmp rbx, 0x0
    jle .exit_loop
    dec rbx

    ; r13 = city_a - 1
    ATOI r13
    dec r13

    ; r14 = city_b - 1
    ATOI r14
    dec r14

    ; if (dsu.unite(city_a, city_b))
    mov rdi, r13
    mov rsi, r14
    push rbx
    push rcx
        call DSU_unite
    pop rcx
    pop rbx
    test rax, rax
    jz .no_union
      ; connected_cities--;
      dec r12
      ; biggest_connection = max(biggest_connection, dsu.size(city_a))
      cmp rax, rcx
      cmovg rcx, rax
    .no_union:

    push rbx
    push rcx
      ; printf("%d %d\n", connected_cities, biggest_connection);
      mov rax, r12
      call write_uint32

      ; Add a space
      mov byte [r9], 0x20
      inc r9
      inc r11

      mov rax, rcx
      call write_uint32

      ; write newline
      mov byte [r9], 0x0a
      inc r9
      inc r11
    pop rcx
    pop rbx

    jmp .loop
  .exit_loop:

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

; rdi: number of elements
; rsi: sizeof(element)
DSU_init:
    ; Simpler num copy
    mov rcx, rdi
    lea rdi, [dsu_elements]
    mov eax, -1
    rep stosd
    ret
; rdi: index to element
; returns "representative" for DSU subgraph
DSU_find:
    ; rsi = index to element
    mov rsi, rdi
    ; rbx = elements[index]
    mov ebx, dword[dsu_elements + 4 * rdi]

    cmp ebx, 0x0
    ; If negative, do base case
    ; If positive, recurse to find representative
    jge .DSU_find_recurse
    .DSU_find_base_case:
        ; Return current element index
        mov rax, rsi
        ret
    .DSU_find_recurse:
        ; Push elements pointer and element byte index
        push rdi
        ; rdi = elements[index]
        mov rdi, rbx
        ; find(elements[index])
        call DSU_find
        ; Pop elements pointer and element byte index
        pop rdi

        ; elements[index] = find(elements[index])
        mov dword[dsu_elements + rdi * 4], eax
        ret
    ret

; Performs the "union" operation on the two inputs
; rdi: index of first element
; rsi: index of second element
; Returns whether or not a union occurred
DSU_unite:
    push rsi
    call DSU_find
    pop rsi
    push rax
    mov rdi, rsi
    call DSU_find
    pop rbx
    ; rax = DSU_find(first)
    ; rbx = DSU_find(second)
    cmp rax, rbx
    jne .unite_different_representatives
    ; return false for no union
    xor rax, rax
    ret
    .unite_different_representatives:
    ; r15 = elements[second]
    mov r15d, dword[dsu_elements + rbx * 4]
    ; Make sure that the "first" element is the representative with the largest subtree (most negative)
    cmp dword[dsu_elements + rax * 4], r15d
    jle .unite_no_swap
    ; rax <=> rbx
    xchg rax, rbx
    .unite_no_swap:
    ; r15 = elements[second]
    ; We do this again incase second has swapped
    mov r15d, dword[dsu_elements + rbx * 4]
    ; elements[index1] += elements[index2]
    add dword[dsu_elements + rax * 4], r15d
    ; elements[index2] = index1
    mov dword[dsu_elements + rbx * 4], eax

    ; return size of subgraph to indicate that a union occurred
    mov eax, dword[dsu_elements + rax * 4]
    neg eax
    ret
