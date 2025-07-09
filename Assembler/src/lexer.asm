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

%define ADD     21
%define ADDI    22
%define ADDW    23
%define ADDIW   24
%define SUB     25
%define SLL     26
%define SLLI    27
%define SRL     28
%define SRLI    29
%define SRA     30
%define SRAI    31
%define AND     32
%define ANDI    33
%define XOR     34
%define XORI    35
%define OR      36
%define ORI     37

%define SLT     38
%define SLTU    39
%define SLTI    40
%define SLTIU   41

%define FENCE   42
%define FENCE_I 43

%define NOT_KEYWORD 255
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

%include "src/constants.asm"

extern concat_str_nomalloc
extern malloc

section .rodata
keyword_ids db LUI, AUIPC, \
    JAL, JALR, \
    BEQ, BNE, BLT, BLTU, BGT, BGTU, \
    LB, LBU, LH, LHU, LW, LWU, LD, \
    SB, SH, SW, SP, \
    ADD, ADDI, ADDW, ADDIW, \
    SUB, SLL, SLLI, SRL, SRLI, SRA, SRAI, \
    AND, ANDI, XOR, XORI, OR, ORI, \
    SLT, SLTU, SLTI, SLTIU, \
    FENCE, FENCE_I
keyword_ids_len equ $ - keyword_ids

%define KEYWORD_COUNT keyword_ids_len

%macro keyword_entry 2
  kw_%1 db %2, 0x0
%endmacro

%macro keyword_pointer 1
  dq kw_%1
%endmacro

%macro keyword_table 1-*
  ; We put two underscores to avoid naming conflicts
  %assign __i 0
  %rep %0
    keyword_entry __i, %1
    %assign __i __i + 1
    %rotate 1
  %endrep

  keywords:
  %assign __i 0
  %rep %0
    keyword_pointer __i
    %assign __i __i + 1
  %endrep
  ; To find the end of the array
  dq 0x0
%endmacro

keyword_table "1", "2", "3", "4", "5"

section .text
global matches_keyword
; rdi: pointer to input string
; rsi: size of the input string (bytes)
; rax: keyword returned OR -1 (255) if error 
matches_keyword:
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, kw_0
  mov rdx, 2
  syscall
  ret

global parse_tokens
; rdi: pointer to input buffer
; rsi: size of the input buffer (bytes)
; rax: pointer to token buffer (output)
parse_tokens:
  xor rcx, rcx
  .loop:
    cmp rcx, rsi
    jl .exit_loop
    
    
    
    inc rcx
    jmp .loop
  .exit_loop:
  ret

global  print_tokens

; rdi: pointer to token buffer
print_tokens:
  push rdi

  mov rdi, 1000
  mov rsi, identifier_len ; max possible bytes per element
  call malloc
  mov qword[token_output], rax

  pop rsi

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
    jmp .add_contents

    .check_keyword:
    cmp rdi, KEYWORDS
    jne .check_separator
    mov rdi, keyword
    jmp .add_contents

    .check_separator:
    cmp rdi, SEPARATOR
    jne .check_operator
    mov rdi, separator
    jmp .add_contents

    .check_operator:
    cmp rdi, OPERATOR
    jne .check_literal
    mov rdi, operator
    jmp .add_contents

    .check_literal:
    cmp rdi, LITERAL
    jne .check_endline
    mov rdi, literal
    jmp .add_contents

    .check_endline:
    cmp rdi, ENDLINE
    jne .check_eof
    mov rdi, endline
    jmp .add_contents

    .check_eof:
    cmp rdi, EOF
    jne .error
    mov rdi, eof
    jmp .add_contents

    .add_contents:
    push rsi
    mov rsi, rdx
    xchg rsi, rdi
    call concat_str_nomalloc
    add rdx, rax
    pop rsi

    mov byte[rdx], ','
    inc rdx

    mov byte[rdx], 0x0a ; newline
    inc rdx
    jmp .loop
  .exit_loop:
  mov r15, rdx
  sub r15, qword[token_output]

  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, qword[token_output]
  mov rdx, r15
  syscall

  cmp rax, 0
  jl .error
  ret

  .error:
  mov rdi, token_error
  mov rsi, token_error_len
  extern write_err
  call write_err

  mov rax, SYS_EXIT
  mov rdi, -1
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
token_error db "There was an error while parsing the tokens", 0x0a, 0x0
token_error_len equ $ - token_error

