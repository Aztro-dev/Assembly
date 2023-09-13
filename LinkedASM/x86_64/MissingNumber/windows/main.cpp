#include <stdio.h>
#include <cstdint>

extern "C" uint64_t missing_number(uint64_t a, uint64_t* nums);

int main(){
  uint64_t a;
  scanf("%lld", &a);
  uint64_t* nums = new uint64_t[a - 1];
  for(uint64_t i = 0; i < a - 1; i++){
    scanf("%lld", &nums[i]);
  }
  uint64_t result = missing_number(a, nums);
  printf("%lld", result);
  return 0;
}
