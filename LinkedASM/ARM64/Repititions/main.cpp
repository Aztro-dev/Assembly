#include <cstdint>
#include <stdio.h>

extern "C" uint64_t repetitions(uint32_t length, char *str);

int main() {
  char *str = "Hello, World!";
  uint64_t result = repetitions(13, str);
  printf("%lld\n", result);
  return 0;
}
