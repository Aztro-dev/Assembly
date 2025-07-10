// Copyright 2024 David Perez Castellanos
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <map>
using namespace std;

int main() {
  ios_base::sync_with_stdio(false);
  cin.tie(0);

  int n, target;
  cin >> n >> target;
  int arr[n];
  for (int i = 0; i < n; i++) {
    cin >> arr[i];
  }

  map<int, int> indices;
  for (int i = 0; i < n; i++) {
    if (indices.count(target - arr[i])) {
      cout << (i + 1) << " " << indices[target - arr[i]];
      return 0;
    }
    indices[arr[i]] = i + 1;
  }

  cout << "IMPOSSIBLE";

  return 0;
}
