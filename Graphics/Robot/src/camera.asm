section .bss
camera resb Camera3d_size

section .text
global init_camera
init_camera:
  movaps xmm0, [starting_position]
  movups [camera + Camera3d.position], xmm0
  movaps xmm1, [target]
  movups [camera + Camera3d.target], xmm1
  movaps xmm2, [up]
  movups [camera + Camera3d.up], xmm2

  mov r15d, dword[fovy]
  mov dword[camera + Camera3d.fovy], r15d

  mov r15d, dword[projection]
  mov dword[camera + Camera3d.projection], r15d

  ret

section .rodata
align 16
starting_position dd 10.0, 10.0, 10.0,  0.0 ; alignment purposes
target            dd 0.0, 0.0, 0.0,     0.0 ; alignment purposes
up                dd 0.0, 1.0, 0.0,     0.0 ; alignment purposes
fovy              dd 90.0
projection        dd 0x0
