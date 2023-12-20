mov ax, 0x13
int 0x10

mov ax, 0xA000
mov es, ax

xor ax, ax ; Counter for frames
xor bx, bx ; Initial color
xor cx, cx ; Top left

space_to_start:
  mov ah, 0x0 ; Read key press
  int 0x16 ; Wait for keyboard input
  cmp ah, 0x39 ; Check to see if spacebar is pressed 
  je pixel_loop
  jmp space_to_start


pixel_loop:
  ; Input: cx is position, bl is color
  ; plot_pixel(cx position, bl color)
  .plot_pixel:
    mov di, cx ; Load Destination Index register with ax value (the coords to put the pixel)
    mov dx, bx ; Set the color
    mov [es:di],dx ; Write pixel

  inc cx ; Increment position

  ; mov bx, cx ; Set color to pixel pos
  add bx, cx ; Change color by pixel position

  ; See if 1024 frames have gone by
  inc ax
  test ax, 64000 ; AND ax and 128
  jnz pixel_loop
  ; Every 1024 frames 
  .clear_screen_on_enter:
    push ax
    xor ax, ax
    mov ah, 0x1 ; Get state of keyboard buffer
    int 0x16 ; Wait for keyboard input
    cmp ah, 0x1c ; See if ah is enter
    jne .end_clear_screen_on_enter ; exit
  ; call .clear_screen
    .clear_screen:
      mov al, 0 ; al gets the color value
      mov ah, al ; Duplicate the color value
      mov bx, 0x0A000 ;
      mov es, bx ; es set to start of VGA
      mov cx, 32000 ; cx set to number of words
      mov di, 0 ; di set to pixel offset 0
      rep stosw ; While cx <> 0 Do
     ; Memory[es:di] := ax
     ; di := di + 2
     ; cx := cx - 1 
   .end_clear_screen_on_enter:
   pop ax
  jmp pixel_loop
  ret


print_end:
  mov ax, 0x0003
  int 0x10
  [org 0x7c00]
  mov ah, 0x0e
  mov bx, end_drawing
  jmp print_str

; bx: pointer to string
print_str:
  mov al, [bx]
  cmp al, 0
  je exit
  int 0x10
  inc bx
  jmp print_str


end_drawing:
  db "Drawing has ended", 0


exit:
  jmp $
times 510 - ($ - $$) db 0
dw 0xaa55

