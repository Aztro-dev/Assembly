read_key:
  mov ah, 0
  int 0x16 ; Wait for keyboard input
  cmp ah, 0x1c ; See if ah is enter
  je print_end ; Stop doin stuff if we pressed enter
  jmp print_char ; Otherwise print the character
   
print_char:
  mov ah, 0x0e ; Print
  int 0x10
  jmp read_key

print_end:
  mov ah, 0x0e
  mov al, 0x0a ; newline
  int 0x10
  mov bx, end_str + 0x7c00
  jmp real_print_end

real_print_end:
  mov al, [bx]
  cmp al, 0
  je end
  int 0x10
  inc bx
  jmp real_print_end

end_str:
  db "End", 0

end:
  jmp $


times 510 - ($ - $$) db 0
dw 0xaa55

