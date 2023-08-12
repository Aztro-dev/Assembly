; %ifndef plot_pixel
; %define plot_pixel

; plot_pixel(cx position, bl color)
plot_pixel:
  mov di, cx ; Load Destination Index register with ax value (the coords to put the pixel)
  mov dx, bx ; Set the color
  mov [es:di],dx ; Write pixel
  ret
; %endif
