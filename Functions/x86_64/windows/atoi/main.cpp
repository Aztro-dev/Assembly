#include <stdio.h>
#include <cstdint>
#include <cstdlib>

extern "C" int64_t atoi_asm(const char* s);

int main(){
  const char* s = "1234";
  int64_t result = atoi_asm(s);
  printf("%lld\n", result);
  return 0;
}
