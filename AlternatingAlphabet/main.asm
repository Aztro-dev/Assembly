mov ah, 0x0e
mov al, 'A'
int 0x10


loop:
  inc al
  cmp al, 91
  jg uppercase
  jmp lowercase

final_part_of_loop:
  int 0x10
  jmp loop


uppercase:
  sub al, 32
  cmp al, 'Z' + 1
  je exit
  jmp final_part_of_loop

lowercase:
  add al, 32
  cmp al, 'z' + 1
  je exit
  jmp final_part_of_loop

exit:
  jmp $
times 510 - ($ - $$) db 0
db 0x55, 0xaa
