#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <set>
#include <string>
#include <vector>
using namespace std;

const uint64_t MOD = 1000000007;

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie(0);

  int n; // testcases
  cin >> n;

  constexpr uint32_t MAX_NUM = 1000001;
  constexpr uint32_t MAX_NUM_SQRT = 1001;

  uint32_t nums[MAX_NUM] = {0};
  std::fill_n(nums, MAX_NUM, 2);
  nums[1] = 1;

  for (uint32_t i = 2; i < MAX_NUM_SQRT; i++) {
    uint32_t start = i * i;
    nums[start]++;
    for (uint32_t j = start + i; j < MAX_NUM; j += i) {
      nums[j] += 2;
    }
  }

  while (n--) {
    uint32_t x;
    cin >> x;
    cout << nums[x] << "\n";
  }
  return 0;
}
