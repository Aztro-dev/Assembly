#include <cstdint>
#include <cstdlib>
#include <stdio.h>

extern "C" int64_t atoi_asm(const char *s);

int main() {
  const char *s = "1234567";
  printf("%s\n", s);
  int64_t result = atoi_asm(s);
  printf("%lld\n", result);
  return 0;
}
