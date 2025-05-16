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

void solve() {
  long x, y;
  // Weird input
  cin >> y >> x;
  if (y > x) {
    long area = (y - 1) * (y - 1);
    if (y & 1) {
      area += x;
    } else {
      area += 2 * y - x;
    }
    cout << area << endl;
  } else {
    long area = (x - 1) * (x - 1);
    if (x & 1) {
      area += 2 * x - y;
    } else {
      area += y;
    }
    cout << area << endl;
  }
}

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie(0);

  freopen("input.in", "r", stdin);
  // freopen("x.out", "w", stdout);

  int t; // testcases
  cin >> t;

  for (int i = 0; i < t; i++) {
    solve();
  }

  return 0;
}
