section .note.GNU-stack

section .data
struc linked_list
  data resq 1
  next resq 1
endstruc

section .text
global populate_linked_list

; void populate_linked_list(struct linked_list *l);
populate_linked_list:
  mov qword [rcx + data], 0x1
  mov qword [rcx + next], rcx
  ret
