#include <cstdint>
#include <cstdlib>
#include <stdio.h>

extern "C" void *malloc_asm(size_t bytes);

int main() {
  int n;
  printf("How many ints do you want to allocate? ");
  scanf("%d", &n);
  int *m = (int *)malloc_asm(n * sizeof(int));
  for (int i = 0; i < n; i++) {
    printf("%d\n", m[i]);
  }
  return 0;
}
