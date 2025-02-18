%define SYS_OPEN  2
%define SYS_CLOSE 3
%define SYS_LSEEK 8

%define SEEK_SET  0
%define SEEK_CUR  1
%define SEEK_END  2

%define O_RDONLY 00
%define O_WRONLY 01
%define O_RDWR   02

section .text
%ifndef FILE_ASM
%define FILE_ASM
global open_file
; file path specified in rdi
; file descriptor returned to rax
open_file:
  mov rax, SYS_OPEN
  ; rdi
  mov rsi, O_RDONLY
  xor rdx, rdx ; No mode_t
  syscall

  ; file descriptor stored in rax
  ret

global get_file_size
; file path specified in rdi
; file size returned in rax in bytes
get_file_size:
  ; Calculate the offset from the file pointer to the end of the file
  mov rax, SYS_LSEEK
  ; rdi
  mov rsi, 0
  mov rdx, SEEK_END
  syscall

  push rax

  ; Reset file pointer to beginning of file so we can read from it
  mov rax, SYS_LSEEK
  ; rdi
  mov rsi, 0
  mov rdx, SEEK_SET
  syscall

  pop rax

  ; file size stored in rax in bytes
  ret
%endif
