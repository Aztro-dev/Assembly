#include <chrono>
#include <stdint.h>
#include <stdio.h>
using namespace std;

extern "C" int fast_solve(uint64_t num);
extern "C" int slow_solve(uint64_t num);

#define TRIALS 1e6 - 1

int main() {
  auto start = chrono::high_resolution_clock::now();
  for (uint64_t num = 1; num <= TRIALS; num++) {
    fast_solve(num);
  }
  auto end = chrono::high_resolution_clock::now();
  auto duration = chrono::duration_cast<std::chrono::microseconds>(end - start);
  printf("Execution time: %d microseconds\n", duration.count());
  start = chrono::high_resolution_clock::now();
  for (uint64_t num = 1; num <= TRIALS; num++) {
    slow_solve(num);
  }
  end = chrono::high_resolution_clock::now();
  duration = chrono::duration_cast<std::chrono::microseconds>(end - start);
  printf("Execution time: %d microseconds\n", duration.count());
}
