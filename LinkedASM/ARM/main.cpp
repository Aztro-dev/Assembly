#include <stdio.h>
#include <cstdint>

extern "C" uint64_t five();

int main(){
  uint64_t result = five();
  printf("%lld", result);
  return 0;
}
