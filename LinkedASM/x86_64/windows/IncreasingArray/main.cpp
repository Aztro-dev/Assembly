#include <stdio.h>
#include <cstdint>
#include <cstdlib>

extern "C" uint64_t increasing_array(int len, int* nums); 

int main(){
  int n;
  scanf("%d", &n);
  int* nums = (int*)malloc(n * sizeof(int));
  for(int i = 0; i < n; i++){
    scanf("%d", &nums[i]);
  }
  uint64_t result = increasing_array(n, nums);
  printf("%ld\n", result);

  free(nums);
  return 0;
}
