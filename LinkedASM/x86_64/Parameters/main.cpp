#include <stdio.h>
#include <cstdint>

extern "C" uint64_t parameters(uint64_t a, uint64_t b, uint64_t c, uint64_t d);

int main(){
  uint64_t a = 100;
  uint64_t b = 200;
  uint64_t c = 300;
  uint64_t d = 400;
  uint64_t result = parameters(a, b, c, d);
  printf("%lld\n", result);
  return 0;
}
