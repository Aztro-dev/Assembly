.text:
.globl _repetitions
.align 4

// uint64_t repetitions(uint32_t length, char *str);
_repetitions:
  mov x3, #1 // Max count
  cmp x1, #1 // If length is one
  bet .loop_exit // Return one

  mov x4, #1 // Curr count
  
  
  .loop_exit:
  ret
