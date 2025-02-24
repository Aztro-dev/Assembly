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

  %define SB      15
  %define SH      16
  %define SW      17

  %define ADD     18
  %define ADDI    19
  %define SUB     20
  %define SLL     21
  %define SLLI    22
  %define SRL     23
  %define SRLI    24
  %define SRA     25
  %define SRAI    26
  %define AND     27
  %define ANDI    28
  %define XOR     29
  %define XORI    30
  %define OR      31
  %define ORI     32

  %define SLT     33
  %define SLTU    34
  %define SLTI    35
  %define SLTIU   36

  %define FENCE   37
  %define FENCE.I 38
%endif

%ifndef SEPARATOR
%define SEPARATOR 2
%endif

%ifndef OPERATOR
%define OPERATOR  3
%endif

%ifndef LTIERAL
%define LITERAL   4
%endif

; Comments and whitespace will simply not be included
