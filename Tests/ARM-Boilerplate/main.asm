; x0-x2 - parameters to linux function services
; x16 - linux function number
;
.global _main             ; Provide program starting address to linker
.align 2

; Setup the parameters to print hello world
; and then call Linux to do it.

_main:
  mov x0, #1     ; 1 = stdout
  adr x1, helloworld ; string to print
  mov x2, #13     ; length of our string
  mov x16, #4     ; MacOS write system call
  svc #0     ; Call linux to output the string

; Setup the parameters to exit the program
; and then call Linux to do it.

  mov     x0, #0      ; Use 0 return code
  mov     x16, #1     ; Service command code 1 terminates this program
  svc     #0           ; Call MacOS to terminate the program

helloworld:      .ascii  "Hello World!\n"
