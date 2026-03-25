default REL

%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define INPUT_BUF_SIZE 4_000_000
%define OUTPUT_BUF_SIZE 4_000_000

section .bss
input_buffer resb INPUT_BUF_SIZE
output_buffer resb OUTPUT_BUF_SIZE
dsu_elements resd 1_000_000

; DSU structure
struc DSU
    ; Size of each individual element
    .element_size: resq 1
    ; Length of elements array
    .elements_len: resq 1
endstruc

section .data
dsu: istruc DSU
    ; Initialize size of each element to be sizeof(uint32_t) aka 4 bytes
    at DSU.element_size, dq 0x4
    ; Initializes length of array to 0 for now
    at DSU.elements_len, dq 0x0
iend

section .text
solve:
  ; get num_cities and num_roads
  call atoi
  push rax
  call atoi
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
    call atoi
    mov r13, rax
    dec r13

    ; r14 = city_b - 1
    call atoi
    mov r14, rax
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
      mov rax, rcx
      call write_uint32
      call write_newline
    pop rcx
    pop rbx

    jmp .loop
  .exit_loop:

  ret


global _start
_start:
    mov r8, input_buffer
    mov r9, output_buffer
    
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, r8
    mov rdx, INPUT_BUF_SIZE
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
    .skip_whitespace:
    movzx r10, byte [r8]
    inc r8
    ; skip spaces and tabs and stuff
    cmp r10b, 0x30
    jl .skip_whitespace

    .loop:
    ; rax = 10 * rax - '0'
    shl rax, 1		
    lea rax, [rax + rax * 4 - '0']        
    ; rax += character
    add rax, r10

    movzx r10, byte [r8]
    inc r8
    cmp r10b, 0x30
    jge .loop
    ret

write_uint32:
    push rax
    push rbp
    push rcx
    push rdx
    push r8

    mov rbp, rsp
    ; 16 bytes of scratch space on stack
    sub rsp, 16
    lea r8, [rbp]

    .div:
    mov r10d, eax            ; Save original EAX since mul clobbers it

    ; magic super algo for n % 10
    mov  edx, 0xCCCCCCCD
    mul  edx
    shr  edx, 3
    mov  ecx, edx
    lea  edx, [edx*4 + edx]
    add  edx, edx
    mov  eax, r10d
    sub  eax, edx

    mov edx, eax
    mov eax, ecx

    add rdx, 0x30 ; num % 10 + '0'

    dec r8
    mov byte [r8], dl ; push character to stack

    test rax, rax
    jnz .div ; keep pushing to stack for rest of number

    ; Add bytes created to r11 (length of output buffer)
    mov r10, rbp
    sub r10, r8
    add r11, r10

    ; copy stack string to buffer
    ; we do this to not have to keep track
    ; of the current position in the buffer
    ; Copy 8 bytes
    mov rax, qword[r8]
    mov qword [r9], rax
    ; get last 2 bytes just in case
    mov ax, word[r8 + 8]
    mov word [r9 + 8], ax


    ; .loop:
    ; mov cl, byte [r8]
    ; inc r8
    ;
    ; mov byte [r9], cl
    ; inc r9
    ;
    ; cmp r8, rbp
    ; jl .loop

    add r9, r10
    mov byte[r9], 0x20 ; space
    inc r9
    inc r11

    ; Reset taht 16 byte thingymabob
    mov rsp, rbp
    pop r8
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

; rdi: number of elements
; rsi: sizeof(element)
DSU_init:
    ; Initialize length and sizeof(element)
    mov qword[dsu + DSU.elements_len], rdi
    mov qword[dsu + DSU.element_size], rsi

    ; Simpler num copy
    lea rdi, [dsu_elements]
    mov rcx, qword[dsu + DSU.elements_len]
    mov eax, -1
    rep stosd
    ret

; rdi: element index
; returns: size of subgraph that the element points to
DSU_find_size:
    ; Call find to get the representative of the subgraph
    call DSU_find
    ; rax = elements[index]
    mov eax, dword[dsu_elements + rax * 4]
    ; rax = -rax
    ; This is because we store the size in negatives for the representative
    neg eax
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
    xchg rax, rbx
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
