section .data
align 16
sound resq 0x0

section .text
global init_sound
init_sound:
  push rbp
  mov rbp, rsp

  call InitAudioDevice

  lea rdi, [sound]
  mov rsi, sound_file
  call LoadSound

  leave
  ret

global un_init_sound
un_init_sound:
  push rbp
  mov rbp, rsp

  mov rdi, sound
  call UnloadSound

  call CloseAudioDevice

  leave
  ret

global play_sound
play_sound:
  push rbp
  mov rbp, rsp

  mov rdi, [sound]
  call PlaySound

  leave
  ret

section .rodata
sound_file db "resources/simon_beep.wav", 0x0

