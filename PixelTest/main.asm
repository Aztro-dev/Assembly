mov ax,13h
int 10h

mov cx, 0x7D0A ; Initial position
mov bl, 0 ; Initial color

pixel_loop:
  mov ax,0A000h
  mov es,ax
  mov ax, 320 ; 0 will put it in top left corner. To put it in top right corner load with 320, in the middle of the screen 32010.  
  mov di,ax             
  mov dl,bl
  mov [es:di],dx
  int 10h
  mov ax,0A000h
  mov es,ax
  mov ax, 0x0D0A ; 0 will put it in top left corner. To put it in top right corner load with 320, in the middle of the screen 32010.
  mov di,ax ; load Destination Index register with ax value (the coords to put the pixel)
  mov dl,bl
  mov [es:di],dx
  int 10h
  inc bx
  jmp pixel_loop


jmp $
times 510 - ($ - $$) db 0
dw 0xaa55

