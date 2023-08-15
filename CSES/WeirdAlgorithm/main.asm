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
    or rax, 1 ; write
    or rdi, 1 ; stdout
    syscall
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

; print_itoa(rax input) -> void
print_itoa:
  call itoa
  sub rsi,rdi
  mov rdx,rsi
  mov rsi,rdi
  inc rdx
  ; print(rsi buff, rdx length)
  call print

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

; weird_algorithm(r8 input) -> void
weird_algorithm:
  mov r9, 0x2 ; for use in dividing by two
  .loop:
    test r8, 1 ; r8 & 1
    jz .even
    jmp .odd

    .even:
      cmp r8, 0x1 ; if current number is one
      je .exit
      xor rdx, rdx
      mov rax, r8 ; dividend
      div r9 ; divide by two
      ; rax is quotient, rdx is remainder
      mov r8, rax
      call print_itoa
      jmp .loop
    .odd:
      cmp r8, 0x1 ; if current number is one
      je .exit
      mov rax, 0x3 ; multiply by 3
      mul r8 ; result stored in rdx:rax
      mov r8, rax ; Result will be 64 bit anyway
      inc r8
      jmp .loop
    
  .exit:
    ret

_start:
  mov rsi, input
  mov rdx, 3
  ; read(rsi input, rdx size)
  call read

  ; atoi_rcx(rsi input) -> rcx output
  call atoi_rcx
  
  mov rax, rcx ; for use in print_itoa

  call print_itoa ; print the first number of the sequence

  mov r8, rax
  
  ; weird_algorithm(r8 input) -> void
  call weird_algorithm

  mov rax, 60 ; exit
  mov rdi, 0
  syscall

section .bss
input: resb 0x13 ; 19 in decimal
