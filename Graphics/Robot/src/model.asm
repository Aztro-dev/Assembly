section .text
global init_models
init_models:
  push rbp
  mov rbp, rsp

  mov rax, SYS_BRK
  xor rdi, rdi
  syscall
  
  mov qword[robot + robot_struc.model], rax

  mov rdi, rax
  add rdi, 0x8 ; reserve a QWORD of memory for the model pointer
  mov rax, SYS_BRK
  syscall

  mov rsi, model_path
  mov rdi, qword[robot + robot_struc.model]
  call LoadModel

  leave
  ret

unload_models:
  push rbp
  mov rbp, rsp

  mov rdi, qword[robot + robot_struc.model]
  call UnloadModel

  leave
  ret

section .rodata
model_path db "resources/robot.glb", 0x0
