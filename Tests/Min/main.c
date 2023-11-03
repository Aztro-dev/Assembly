#include <stdio.h>

extern long long int asm_min(long long int num1, long long int num2);

int main(void) {
  long long int result = asm_min(2, 5);
  printf("%lld\n", result);
  return 0;
}
