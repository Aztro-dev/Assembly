#include <iostream>
#include <cstdint>

extern "C" uint64_t parameters(uint64_t a, uint64_t b, uint64_t c, uint64_t d);

int main(){
  uint64_t a, b, c, d;
  std::cin >> a >> b >> c >> d;
  uint64_t result = parameters(a, b, c, d);
  std::cout << result << std::endl;
  return 0;
}
