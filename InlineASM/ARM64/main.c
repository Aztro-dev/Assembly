#include <stdint.h>
#include <stdio.h>

int foo(void) {
  uint64_t joe = 1234, bob = 4321, fred;
  __asm__("  mov %0, %1\n"
          "  add %0, %0, %2\n"
          : "=r"(fred)         // =r means write to fred*/
          : "r"(joe), "r"(bob) /* r means use it as a variable*/
          : "r0"               /* Overwrite */
  );
  return fred;
}

extern uint64_t proc(uint64_t a); /* Prototype */

__asm__(/* Assembly function body */
        "proc:\n"
        "  mov x0, 0x100\n"
        "  ret\n");

int main(void) {
  int output = foo();
  uint64_t proc_output = proc(10);

  printf("foo: %d\n", output);
  printf("proc: %lld\n", proc_output);
  return 0;
}
