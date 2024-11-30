section .bss
model resq 2

section .text
global init_models
init_models:
  push rbp
  mov rbp, rsp
  
  lea rax, [model]
  mov qword[robot + robot_struc.model], rax

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
