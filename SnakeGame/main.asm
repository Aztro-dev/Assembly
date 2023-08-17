%include "test.asm"

mov ax, 0x13
int 0x10

mov ax, 0xA000
mov es, ax

xor ax, ax ; Counter for frames
mov bx, 0x8002 ; bl is color, bh is square size
xor cx, cx ; Top left

pixel_loop:
  ; call plot_pixel
  call plot_square
  ; inc cx ; Increment position

  ; add bx, cx ; Change color by pixel position

  call clear_screen

  ; See if process has finished
  inc ax
  test ax, 64000 ; AND ax with 64000
  jz pixel_loop
  call terminate_on_enter
  jmp pixel_loop

; plot_square(cx position, bl color, bh size)
plot_square:
  push ax
  push cx
  push dx
  
  xor ax, ax
  
  .outer_loop:
    cmp al, bh
    je .end_of_plot_square ; exit outer_loop if al is done with size
    .inner_loop:
      cmp ah, bh
      je .after_inner_loop ; exit inner_loop if ah is done with size

      call plot_pixel ; plot pixel (duh)
      inc cx ; next pixel

      inc ah ; next inner_loop iteration
      jmp .inner_loop ; loop
    .after_inner_loop:
    mov dx, bx ; temporary
    shr dx, 8 ; move bh to where bl should be
    sub cx, dx ; back to x position
    add cx, 320 ; newline
    xor ah, ah ; reset ah
    inc al ; next outer_loop iteration

    jmp .outer_loop; loop

  .end_of_plot_square:
  pop dx
  pop cx
  pop ax
  ret

; plot_pixel(cx position, bl color)
; plot_pixel:
;   mov di, cx ; Load Destination Index register with ax value (the coords to put the pixel)
;   mov dx, bx ; Set the color
;   mov [es:di],dx ; Write pixel
;   ret

terminate_on_enter:
  xor ax, ax
  mov ah, 0x1 ; Get state of keyboard buffer
  int 0x16 ; Wait for keyboard input
  cmp ah, 0x1c ; See if ah is enter
  je print_end ; exit
  ret

clear_screen:
  push ax
  xor ax, ax
  mov ah, 0x1 ; Get state of keyboard buffer
  int 0x16 ; Wait for keyboard input
  cmp ah, 0x1c ; See if ah is enter
  jne return

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
return: 
  pop ax
  ret

print_end:
  mov ax, 0003h
  int 10h 
  [org 0x7c00]
  mov ah, 0x0e
  mov bx, end_drawing

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

