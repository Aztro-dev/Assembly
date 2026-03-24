%define SYS_BRK 12

; DSU structure
struc DSU
    ; Pointer to the array of elements
    .elements: resq 1
    ; Size of each individual element
    .element_size: resq 1
    ; Length of elements array
    .elements_len: resq 1
end struc

section .data
dsu: istruc DSU
    ; Initialize pointer of elements to nullptr
    at .elements: dq 0x0
    ; Initialize size of each element to be sizeof(int) aka 4 bytes
    at .element_size: dq 0x4
    ; Initializes length of array to 0 for now
    at .elements_len: dq 0x0
iend

section .text
; rdi: number of elements
; rsi: sizeof(element)
DSU_init:
    ; Initialize length and sizeof(element)
    mov qword[dsu + DSU.elements_len], rdi
    mov qword[dsu + DSU.element_size], rsi

    ; number of elems * sizeof(elem) = number of bytes of array
    mov rax, rdi
    xor rdx
    mul rsi
    ; rdi = sizeof array
    mov rdi, rax
    ; Allocate rdi bytes on heap and return pointer in rax
    call malloc
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

; rdi: size of memory created in bytes
; return address: pointer to start of new memory
malloc_bytes:
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
    ret
