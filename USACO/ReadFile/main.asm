struc kernel_timespec
tv_sec: resq 1
tv_nsec: resq 1
endstruc

section .text
global  _start

_start:
	mov rax, 35; nanosleep
	mov rdi, qword [request]
	mov rsi, qword [remaining]
	syscall

	mov     rax, 60; exit(
	xor     rdi, rdi; err_code: 0
	syscall ; )

	section .data:

request:
	istruc kernel_timespec
	at     tv_sec, dq 0x5
	at     tv_nsec, dq 100
	iend

remaining:
	istruc kernel_timespec
	iend
