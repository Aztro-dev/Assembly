.global _main
.align 2

_main:
  mov x0, 0          // STDIN (file descriptor 0)
  adr x1, input      // buffer address
  mov x2, 10         // input size (number of bytes to read)
  mov x16, 3 // syscall number for read (macOS)
  svc 0

  mov x0, 1          // STDOUT (file descriptor 1)
  adr x1, input      // buffer address
  mov x2, 10         // output size (number of bytes to write)
  mov x16, 4// syscall number for write (macOS)
  svc 0

  mov x0, 0          // Exit code 0
  mov x16, 1 // syscall number for exit (macOS)
  svc 0              // make syscall

.align 4
input:
  .space 10          // Allocate 10 bytes for the input buffer
