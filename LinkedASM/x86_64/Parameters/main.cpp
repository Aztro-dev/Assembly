#include <stdio.h>
#include <cstdint>

extern "C" uint64_t parameters(uint64_t a, uint64_t b);

int main(){
  uint64_t a = 100;
  uint64_t b = 200;
  uint64_t result = parameters(a, b);
  printf("%lld", result);
  return 0;
}
