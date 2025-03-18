%ifndef IDENTIFIER
%define IDENTIFIER 0
%endif

%ifndef KEYWORDS
%define KEYWORDS  1

%define LUI     0
%define AUIPC   1

%define JAL     2
%define JALR    3

%define BEQ     4
%define BNE     5
%define BLT     6
%define BLTU    7
%define BGT     8
%define BGTU    9

%define LB      10
%define LBU     11
%define LH      12
%define LHU     13
%define LW      14
%define LWU     15
%define LD      16

%define SB      17
%define SH      18
%define SW      19
%define SP      20

%define ADD     20
%define ADDI    21
%define ADDW    22
%define ADDIW   23
%define SUB     24
%define SLL     25
%define SLLI    26
%define SRL     27
%define SRLI    28
%define SRA     29
%define SRAI    30
%define AND     31
%define ANDI    32
%define XOR     33
%define XORI    34
%define OR      35
%define ORI     36

%define SLT     38
%define SLTU    39
%define SLTI    40
%define SLTIU   41

%define FENCE   42
%define FENCE.I 43
%endif

%ifndef SEPARATOR
%define SEPARATOR 2
%endif

%ifndef OPERATOR
%define OPERATOR  3
%endif

%ifndef LITERAL
%define LITERAL   4
%endif

%ifndef ENDLINE
%define ENDLINE   5
%endif

%ifndef EOF
%define EOF       6
%endif

struc token
  .contents   resq 1 ; "*", "func", ".", etc.
  .token_type resb 1 ; Identifier, Keyword, Separator, etc.
  .padding    resb 3
endstruc

%define SYS_READ  0
%define SYS_WRITE 1
%define SYS_OPEN  2
%define SYS_CLOSE 3
%define SYS_BRK   12
%define SYS_EXIT  60

%define STDIN  0
%define STDOUT 1
%define STDERR 2

extern concat_str_nomalloc
extern malloc

section .text
global  print_tokens

print_tokens:
  mov rdi, 1000 ; elements
  mov rsi, 1    ; bytes per element
  call malloc
  mov qword[token_output], rax

  mov rsi, qword[tokens]
  mov rdx, qword[token_output]
  .loop:
    cmp qword[rsi + token.token_type], EOF
    je .exit_loop ; end of array

    mov rax, qword[rsi + token.contents]
    mov rdi, qword[rsi + token.token_type]
    add rsi, token_size

    .check_identifier:
    cmp rdi, IDENTIFIER
    jne .check_keyword

    mov rdi, identifier
    push rsi
    mov rsi, rdx
    call concat_str_nomalloc
    pop rsi
    
    jmp .add_contents

    .check_keyword:

    .add_contents:
    mov byte[rdx], ','
    inc rdx

    mov r8, rax
    .contents_loop:
      cmp byte[r8], 0x0
      je .exit_contents_loop

      mov bl, byte[r8]
      mov byte[rdx], bl

      inc rdx
      inc r8
      jmp .contents_loop
    
    .exit_contents_loop:
    
    mov byte[rdx], 0x0a ; newline
    inc rdx
    jmp .loop
  .exit_loop:
  mov r15, qword[token_output]
  sub r15, rdx

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, rdx
  mov rdx, r15
  syscall
  ret

section .bss
; A string representing the tokens and their contents
token_output resq 1
; An array of `token` structs
tokens  resq 1

section .rodata
identifier  db "identifier", 0x0
identifier_len equ $ - identifier
keyword     db "keyword", 0x0
keyword_len equ $ - keyword
separator   db "separator", 0x0
separator_len equ $ - separator
operator    db "operator", 0x0
operator_len equ $ - operator
literal     db "literal", 0x0
literal_len equ $ - literal
endline     db "endline", 0x0
endline_len equ $ - endline
eof         db "EOF", 0x0
eof_len equ $ - eof
