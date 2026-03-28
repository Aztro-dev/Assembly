#include <stdio.h>

extern char *init_board(char *board_input, int N, int M);
extern void bfs();

int main() {
  char *board_input = "########\n#.A #... #\n#.##.#B #\n#...... #\n########";
  int N = 5, M = 8;
  char *board_filtered = init_board(board_input, 5, 8);
  for (int i = 0; i < N; i++) {
    for (int ii = 0; ii < M; ii++) {
      printf("%c", board_filtered[i * N + ii]);
    }
    printf("\n");
  }
  bfs();

  return 0;
}
