default REL

%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_BRK 12
%define SYS_EXIT 60

%define STDIN 0
%define STDOUT 1

%define INPUT_BUF_SIZE 4_000_000
%define OUTPUT_BUF_SIZE 4_000_000

section .bss
input_buffer resb INPUT_BUF_SIZE
output_buffer resb OUTPUT_BUF_SIZE

; DSU structure
struc DSU
    ; Pointer to the array of elements
    .elements: resq 1
    ; Size of each individual element
    .element_size: resq 1
    ; Length of elements array
    .elements_len: resq 1
endstruc

section .data
dsu: istruc DSU
    ; Initialize pointer of elements to nullptr
    at DSU.elements, dq 0x0
    ; Initialize size of each element to be sizeof(uint64_t) aka 8 bytes
    at DSU.element_size, dq 0x8
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
  mov rsi, 0x8 ; Use qwords as default even tho ints work because I'm a lazy bum
  push rax
  call DSU_init
  pop rax

  ; rax = connected_cities
  ; rcx = biggest connection
  mov rcx, 1
  .loop:
    ; while roads-- > 0
    cmp rbx, 0x0
    jle .exit_loop
    dec rbx

    ; r13 = city_a - 1
    ; r14 = city_b - 1
    push rax
      call atoi
      mov r13, rax
      dec r13
      call atoi
      mov r14, rax
      dec r14
    pop rax

    ; if (dsu.unite(city_a, city_b))
    mov rdi, r13
    mov rsi, r14
    push rax
    push rbx
    push rcx
    call DSU_unite
    pop rcx
    pop rbx
    test rax, rax
    ; Man I sure do hope that `pop` doesn't change any flags
    pop rax
    jz .no_union
      ; connected_cities--;
      dec rax
      mov r14, rcx ; biggest_connection
      ; dsu.size(city_a)
      mov rdi, r13
      push rax
      push rbx
        call DSU_find_size
        ; biggest_connection = max(biggest_connection, dsu.size(city_a))
        cmp rax, r14
        cmovg rcx, rax
      pop rbx
      pop rax
    .no_union:

    push rax
    push rbx
    push rcx
      ; printf("%d %d\n", connected_cities, biggest_connection);
      mov rax, rax
      call write_uint64
      mov rax, rcx
      call write_uint64
      call write_newline
    pop rcx
    pop rbx
    pop rax

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
    .loop:
    movzx r10, byte [r8]
    inc r8

    cmp r10b, 0x30
    jl .end
    
    ; rax = 10 * rax - '0'
    shl rax, 1		
    lea rax, [rax + rax * 4 - 48]        
    ; rax += character
    add rax, r10

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

; rdi: number of elements
; rsi: sizeof(element)
DSU_init:
    ; Initialize length and sizeof(element)
    mov qword[dsu + DSU.elements_len], rdi
    mov qword[dsu + DSU.element_size], rsi

    ; number of elems * sizeof(elem) = number of bytes of array
    mov rax, rdi
    xor rdx, rdx
    mul rsi
    ; rdi = sizeof array
    mov rdi, rax
    ; Allocate rdi bytes on heap and return pointer in rax
    call malloc_bytes
    ; Store pointer to array at dsu.elements
    mov qword[dsu + DSU.elements], rax

    ; rcx is the count for the loop
    xor rcx, rcx
    ; rax is pointing to the start of the array
    .DSU_init_loop:
        cmp rcx, qword[dsu + DSU.elements_len]
        jge .exit_DSU_init_loop

        ; Make all elements representatives
        mov qword[rax], -1
        ; Increment pointer by length of an element
        add rax, qword[dsu + DSU.element_size]
        
        inc rcx
        jmp .DSU_init_loop
    .exit_DSU_init_loop:
    ret

; rdi: element index
; returns: size of subgraph that the element points to
DSU_find_size:
    ; Call find to get the representative of the subgraph
    call DSU_find
    ; rax = rax * sizeof(element)
    ; aka rax = index in bytes
    imul rax, qword[dsu + DSU.element_size]
    ; rax = ptr to elements[index]
    add rax, qword[dsu + DSU.elements]
    ; rax = elements[index]
    mov rax, qword[rax]
    ; rax = -rax
    ; This is because we store the size in negatives for the representative
    neg rax
    ret

; rdi: index to element
; returns "representative" for DSU subgraph
DSU_find:
    ; rsi = index to element
    mov rsi, rdi
    ; index * sizeof(element) = byte_index
    mov rax, rdi
    xor rdx, rdx
    mul qword[dsu + DSU.element_size]
    ; rdi = index_bytes
    mov rdi, rax

    mov rax, qword[dsu + DSU.elements]
    ; rbx = elements[index]
    mov rbx, qword[rax + rdi]

    cmp rbx, 0x0
    ; If negative, do base case
    ; If positive, recurse to find representative
    jge .DSU_find_recurse
    .DSU_find_base_case:
        ; Return current element index
        mov rax, rsi
        ret
    .DSU_find_recurse:
        ; Push elements pointer and element byte index
        push rax
        push rdi
        ; rdi = elements[index]
        mov rdi, rbx
        ; find(elements[index])
        call DSU_find
        ; Pop elements pointer and element byte index
        pop rdi
        pop rbx

        ; elements[index] = find(elements[index])
        mov qword[rbx + rdi], rax
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
    ; rdi = ptr to elements[rax]
    ; rsi = ptr to elements[rbx]
    mov rdi, rax
    ; rdi = first index but in bytes
    imul rdi, qword[dsu + DSU.element_size]
    ; elements[rax]
    mov r15, qword[dsu + DSU.elements]
    add rdi, r15

    mov rsi, rbx
    ; rsi = second index but in bytes
    imul rsi, qword[dsu + DSU.element_size]
    ; elements[rbx]
    mov r15, qword[dsu + DSU.elements]
    add rsi, r15

    ; r15 = elements[second]
    mov r15, qword[rsi]
    ; Make sure that the "first" element is the representative with the largest subtree (most negative)
    cmp qword[rdi], r15
    jle .unite_no_swap
    ; elements[rax] <=> elements[rbx]
    xchg rdi, rsi
    ; rax <=> rbx
    xchg rax, rbx
    .unite_no_swap:
    ; r15 = elements[second]
    ; We do this again incase second has swapped
    mov r15, qword[rsi]
    ; elements[index1] += elements[index2]
    add qword[rdi], r15
    ; elements[index2] = index1
    mov qword[rsi], rax

    ; return true to indicate that a union occurred
    mov rax, 0x1
    ret

; rdi: size of memory created in bytes
; return address: pointer to start of new memory
malloc_bytes:
    push r11
    push rcx
    push rdi
    ; Find top of heap
    mov rax, SYS_BRK
    xor rdi, rdi
    syscall
    pop rdi

    push rax
      ; top of heap += number of bytes
      add rdi, rax
      mov rax, SYS_BRK
      syscall
    pop rax

    pop rcx
    pop r11
    ret


