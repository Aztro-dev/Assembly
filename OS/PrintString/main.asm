[org 0x7c00]
mov ah, 0x0e
mov bx, variableName

print_str:
  mov al, [bx]
  cmp al, 0
  je end
  int 0x10
  inc bx
  jmp print_str


variableName:
  db "Stringy String", 0

end:
  jmp $
times 510 - ($ - $$) db 0
dw 0xaa55
