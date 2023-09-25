#include <stdio.h>

int test(int a, int b, int c) { return a + b + c; }

int main(void) {
  int result = test(100, 200, 300);
  printf("%d\n", result);
  return 0;
}
