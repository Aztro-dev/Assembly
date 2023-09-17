#include <cstdint>
#include <stdio.h>

extern "C" char *itoa(int64_t input);

int main() {
  int64_t input = 1234;
  char *result = itoa(input);
  printf("%s\n", result);
  return 0;
}
