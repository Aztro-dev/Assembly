section .data
default_number: db " 12345678901234567890"

section .text
global _start

; read(rsi input, rdx size)
read:
  xor rax, rax ; Read
  xor rdi, rdi ; Stdin
  syscall
  ret
  
; print(rsi buff, rdx length)
print:
    mov r10, rax
    mov r11, rdi
    
    mov rax, 1 ; Write
    mov rdi, 1 ; Stdout
    syscall
    
    mov rax, r10
    mov rdi, r11
    ret

; atoi (rsi pointer_to_ascii) -> rdx
atoi:   xor rax,rax ; rax = 0
        xor rdx,rdx ; rdx = 0
        lodsb ; load byte at address RSI into AL.
        cmp al,'-' ; 
        sete bl ; bl = negative flag
        jne .lpv ; jump to .lpv if positive
.lp:    lodsb ; load byte at address RSI into AL
.lpv:   sub al,'0' ; turns al into number
        jl .end ; if sign flag != overflow flag, jump to .end
        imul rdx,10 ; rdx *= 10
        add rdx,rax ; rdx += rax
        jmp .lp ; load byte at address RSI into AL
.end:   test bl,bl ; bl & bl
        jz .p ; if bl is zero, return
        neg rdx ; rdx = -rdx
        ; xchg rax, rdx
.p      ret

; itoa(rax integer) -> rsi output
itoa:   std ; rsi -= 1, rdi -= 1
        mov r9,10 ; r9 will be our base (base 10)
        bt rax,63 ; copy bit 63 (most significant, handles negatives) from rax to carry flag
        setc bl ; if carry flag is set, set bl to 1 (negative sign)
        jnc .lp ; if carry flag isn't set, jump to .lp
        neg rax ; if carry flag is set, negate the number
.lp:    xor rdx,rdx ; reset rdx
        div r9 ; rax / r9 -> rax output, rdx remainder
        xchg rax,rdx ; swap rax and rdx
        add rax,'0' ; rax is now the remainder, which is turned into an ascii integer
        stosb ; load byte at rsi into al
        xchg rax,rdx ; rax is now the result of the first division, and rdx is now the ?
        test rax,rax ; if rax is zero
        jnz .lp ; if rax isn't zero, jump to .lp (loop), this ensures we have another digit to process
        test bl,bl ; if bl is zero (sign or no sign)
        jz .p ; if number is positive, jump to .p (exit)
        mov al,'-' ; if number is NOT positive (negative), add a negative sign
        stosb ; load byte at rsi into al
.p:     cld ; clear direction flag (Turns off automatic rsi increments whenever calling a string function (like stosb))
        inc rdi ; 
        ret

; atoi(rsi input) -> rcx
atoi_rcx:
    mov rsi, input
    call atoi ; atoi(rsi input) -> rdx
    mov rcx, rdx ; store value of atoi
    mov rdi,input+18 ; end of buff
    mov rsi,rdi ; rsi = rdi
    std ; rsi--, rdi--
    mov rax, 10
    stosb ; al = [rsi]
    ret

; handle_num_print(rax n)
handle_num_print:
  ; itoa(rax integer) -> rsi output
  call itoa
  
  inc rsi
  mov [new_number_buffer], rsi
  dec rsi
  
  mov byte [rsi], 0x20 ; Space (32 in decimal)
  mov rdx, 0x14 ; size of new_number_buffer, 20 bytes
  call print
  ret

; weird_algorithm(rax input) -> void
weird_algorithm:
  mov r8, 0x2 ; divide by 2
  mov r9, 0x3 ; multiply by 3
  cmp rax, 0x1 ; if n is already one, exit

  je .exit
  xor rdx, rdx ; reset rdx for division
  .loop:
    test rax, 0x1 ; rax & 1 (testing for odd/even)
    jz .even
    jnz .odd
    .even:
      div r8 ; rdx:rax / r8 = rax, r8 = 2
      ; handle_num_print(rax n)
      call handle_num_print
      cmp rax, 0x1 ; check if n is done now
      je .exit ; loop is done
      jmp .loop ; loop if not done
    .odd:
      mul r9 ; rax * r9 = rdx:rax, r9 = 3
      inc rax ; n + 1 part in problem description
      call handle_num_print
      cmp rax, 0x1 ; check if n is done now
      je .exit ; loop is done
      jmp .loop ; loop if not done
  .exit:
    ret

_start:
  mov rsi, input
  mov rdx, 19
  ; read(rsi input, rdx size)
  call read

  call print

  ; atoi_rcx(rsi input) -> rcx output
  call atoi_rcx
  
  mov rax, rcx ; for use in print_itoa
  
  ; weird_algorithm(rax input) -> void
  call weird_algorithm


  mov rax, 60 ; exit
  mov rdi, 0
  syscall

section .bss
input: resb 0x13 ; 19 in decimal
new_number_buffer: resb 0x14 ; 20 in decimal
