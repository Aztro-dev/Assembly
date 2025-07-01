// Copyright 2024 David Perez Castellanos
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
using namespace std;

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie(0);

  // freopen("input.in", "r", stdin);
  // freopen("x.out", "w", stdout);

  int t; // testcases
  cin >> t;

  uint64_t max = 0;
  uint64_t sum = 0;
  uint64_t temp;
  for (int i = 0; i < t; i++) {
    cin >> temp;
    sum += temp;
    if (max < temp) {
      max = temp;
    }
  }
  if (2 * max > sum) {
    cout << 2 * max << endl;
  } else {
    cout << sum << endl;
  }

  return 0;
}
