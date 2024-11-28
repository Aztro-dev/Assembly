section .text
global init_models
init_models:
  mov rsi, model_path
  mov rdi, model_path
  call LoadModel
  mov qword[robot + robot_struc.model], rax
  ret

unload_models:
  mov rdi, qword[robot + robot_struc.model]
  call UnloadModel
  ret

section .rodata
model_path db "resources/model.glb", 0x0
