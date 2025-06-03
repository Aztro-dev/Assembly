// Copyright 2024 David Perez Castellanos
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <set>
#include <string>
#include <vector>
using namespace std;

const uint64_t MOD = 1000000007;

void solve(uint64_t k) {
  uint64_t output = (k * k * (k * k - 1)) >> 1;
  output -= 4 * (k - 1) * (k - 2);
  cout << output << "\n";
}

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie(0);

  // freopen("input.in", "r", stdin);
  // freopen("x.out", "w", stdout);

  int t; // testcases
  cin >> t;

  for (uint64_t i = 1; i <= t; i++) {
    solve(i);
  }

  return 0;
}
