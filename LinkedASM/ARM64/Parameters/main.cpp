#include <cstdint>
#include <stdio.h>

extern "C" uint64_t parameters();

int main() {
  uint64_t result = parameters();
  printf("%lld\n", result);
  return 0;
}
