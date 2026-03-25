%define SYS_BRK 12
default REL

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
unite:
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
