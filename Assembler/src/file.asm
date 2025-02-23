%define SYS_OPEN  2
%define SYS_CLOSE 3
%define SYS_LSEEK 8
%define SYS_CREAT 85

%define SEEK_SET  0
%define SEEK_CUR  1
%define SEEK_END  2

%define O_RDONLY  0o0000 ; file descriptor has read permission
%define O_WRONLY  0o0001 ; file descriptor has write permission
%define O_RDWR    0o0002 ; file descriptor has read and write permission
%define S_IRWXU   0o0700 ; user (file owner) has read, write and execute permission 
%define S_IRUSR   0o0400 ; user has read permission 
%define S_IWUSR   0o0200 ; user has write permission 
%define S_IXUSR   0o0100 ; user has execute permission 
%define S_IRWXG   0o0070 ; group has read, write and execute permission 
%define S_IRGRP   0o0040 ; group has read permission 
%define S_IWGRP   0o0020 ; group has write permission 
%define S_IXGRP   0o0010 ; group has execute permission 
%define S_IRWXO   0o0007 ; others have read, write and execute permission 
%define S_IROTH   0o0004 ; others have read permission 
%define S_IWOTH   0o0002 ; others have write permission 
%define S_IXOTH   0o0001 ; others have execute permission 

section .text
%ifndef FILE_ASM
%define FILE_ASM
global open_file
; file path specified in rdi
; file descriptor returned to rax
open_file:
  mov rax, SYS_OPEN
  ; rdi is the file path
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
  ; rdi is the file path
  mov rsi, 0
  mov rdx, SEEK_END
  syscall

  push rax

  ; Reset file pointer to beginning of file so we can read from it
  mov rax, SYS_LSEEK
  ; rdi is the file path
  mov rsi, 0
  mov rdx, SEEK_SET
  syscall

  pop rax

  ; file size stored in rax in bytes
  ret

global create_file
; file path specified in rdi
; file descriptor returned in rax
create_file:
  mov rax, SYS_CREAT
  ; rdi is file path
  mov rsi, S_IRUSR + S_IRGRP + S_IROTH ; using or symbol looks weird with syntax highlighting
  syscall
  ; file descriptor returned in rax
  ret
%endif
