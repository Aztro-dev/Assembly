section .data
sound times(2 + 2 + 1 + 1 + 1 + 1) dd 0x0

section .text
global init_sound
init_sound:
  ret

section .rodata
sound_file db "resources/simon_beep.wav", 0x0

