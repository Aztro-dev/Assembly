#include <cstdint>
#include <stdio.h>

extern "C" uint64_t five();

int main() {
  uint64_t result = five();
  printf("%lld\n", result);
  return 0;
}
