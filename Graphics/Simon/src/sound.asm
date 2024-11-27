section .bss
; sound resd 2 + 2 + 1 + 1 + 1 + 1 
sound resq 0x1

section .text
global init_sound
init_sound:
  call InitAudioDevice

  mov rdi, sound_file
  call LoadSound
  mov qword[sound], rax
  ret

global un_init_sound
un_init_sound:
  mov rdi, qword[sound]
  call UnloadSound

  call CloseAudioDevice
  ret

global play_sound
play_sound:
  mov rdi, qword[sound]
  call PlaySound
  ret

section .rodata
sound_file db "resources/simon_beep.wav", 0x0

