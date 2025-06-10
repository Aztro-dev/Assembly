%include "src/constants.asm"

section .text
global _start
_start:
  mov rdi, [rsp + 2 * 0x8] ; argv[1]
  extern open_file
  call open_file

  mov qword[file_fd], rax

  ; Get starting address for later SYS_BRK
  mov rax, SYS_BRK
  mov rdi, 0 ; null
  syscall
  mov qword[buf], rax

  mov rdi, qword[file_fd]
  extern get_file_size
  call get_file_size

  mov qword[buf_size], rax

  ; Allocate enough memory for the buffer
  mov rax, SYS_BRK
  mov rdi, qword[buf]
  add rdi, qword[buf_size]
  syscall

  mov rax, SYS_READ
  mov rdi, qword[file_fd]
  mov rsi, qword[buf]
  mov rdx, qword[buf_size]
  syscall

  mov rax, SYS_CLOSE
  mov rdi, qword[file_fd]
  syscall

  mov rdi, file_path
  extern create_file
  call create_file

  mov qword[file_fd], rax

  ; rdi = file descriptor of file
  mov rdi, rax
  mov rax, SYS_WRITE
  mov rsi, qword[buf]
  mov rdx, qword[buf_size]
  syscall

  mov rax, SYS_CLOSE
  mov rdi, qword[file_fd]
  syscall

  mov rax, SYS_EXIT
  mov rdi, 0x0
  syscall

section .rodata
file_path: db "./a.out", 0x0

section .bss
file_fd: resq 1

buf: resq 1
buf_size: resq 1
