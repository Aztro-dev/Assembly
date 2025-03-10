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

	; Comments and whitespace will not be included
