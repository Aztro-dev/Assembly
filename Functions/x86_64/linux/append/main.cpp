#include <cstdint>
#include <cstdlib>
#include <stdio.h>

extern "C" char *append_asm(const char* str1, const char* str2);

int main() {
  const char* str1 = "Test";
  const char* str2 = "ing\n";
  char* result = append_asm(str1, str2);
  printf("%s", result);
  return 0;
}
