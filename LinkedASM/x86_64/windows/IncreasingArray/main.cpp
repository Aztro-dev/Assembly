#include <stdio.h>
#include <cstdint>

extern "C" uint64_t increasing_array(int len, int* nums); 

int main(){
  int n;
  scanf("%d", &n);
  int* nums = new int(n);
  for(int i = 0; i < n; i++){
    scanf("%d", &nums[i]);
  }
  uint64_t result = increasing_array(n, nums);
  printf("%lld\n", result);
  return 0;
}
