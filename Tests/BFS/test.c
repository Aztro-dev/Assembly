#include <stdint.h>
#include <stdio.h>

extern char *init_board(char *board_input, int N, int M);
extern void bfs();
extern int32_t get_start();
extern int32_t get_end();

/* input:
########
#.A#...#
#.##.#B#
#......#
########
*/

int main() {
  char *board_input = "########\n#.A#...#\n#.##.#B#\n#......#\n########";
  int N = 5, M = 8;
  char *board_filtered = init_board(board_input, N, M);
  for (int i = 0; i < N; i++) {
    for (int ii = 0; ii < M; ii++) {
      printf("%c", board_filtered[i * M + ii]);
    }
    printf("\n");
  }

  int32_t start = get_start();
  int32_t end = get_end();
  printf("Start: %d\n", start & 0xFFFF);
  printf("End: %d\n", end & 0xFFFF);

  bfs();

  return 0;
}
