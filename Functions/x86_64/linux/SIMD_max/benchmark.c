#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NUMBERS_LEN 100000000

extern uint32_t uint32_max(uint32_t *arr);
extern uint32_t avx2_uint32_max(uint32_t *arr);
void randomize_array(uint32_t *arr);

int main() {
  uint32_t *arr = (uint32_t *)malloc(sizeof(uint32_t) * NUMBERS_LEN);
  randomize_array(arr);

  float start_time = (float)clock() / CLOCKS_PER_SEC;

  uint32_t max = uint32_max(arr);

  float end_time = (float)clock() / CLOCKS_PER_SEC;

  float scalar_time = end_time - start_time;

  printf("Scalar uint32 max: %d\nTime elapsed: %f\n\n", max, scalar_time);

  start_time = (float)clock() / CLOCKS_PER_SEC;

  max = avx2_uint32_max(arr);

  end_time = (float)clock() / CLOCKS_PER_SEC;

  float vector_time = end_time - start_time;

  printf("AVX2 uint32 max: %d\nTime elapsed: %f\n\n", max, vector_time);

  printf("Speedup: %fx\n", scalar_time / vector_time);
  return 0;
}

void randomize_array(uint32_t *arr) {
  srandom(time(NULL));
  for (int i = 0; i < NUMBERS_LEN; i++) {
    arr[i] = random();
  }
}
