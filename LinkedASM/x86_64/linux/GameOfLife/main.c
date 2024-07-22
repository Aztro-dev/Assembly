#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int64_t count_surrounding_cells(int x, int y);
extern uint8_t *run_game();
extern void set_board(bool *board);
extern bool *get_board();

#define CELL_NUMBER 3

void print_board(bool *board) {
  for (int i = 0; i < 3; i++) {
    for (int ii = 0; ii < 3; ii++) {
      printf("%d", board[i * 3 + ii]);
    }
    printf("\n");
  }
}

bool *custom_run_game() {
  bool *temp_board = (bool *)malloc(sizeof(bool) * CELL_NUMBER * CELL_NUMBER);
  for (int i = 0; i < CELL_NUMBER; i++) {
    for (int ii = 0; ii < CELL_NUMBER; ii++) {
      int neighbours = count_surrounding_cells(i * CELL_NUMBER, ii);
      if (neighbours == 3) {
        temp_board[i * CELL_NUMBER + ii] = 1;
      } else if (get_board()[i * CELL_NUMBER + ii] == 1 && neighbours == 2) {
        temp_board[i * CELL_NUMBER + ii] = 1;
      } else {
        temp_board[i * CELL_NUMBER + ii] = 0;
      }
    }
  }

  return temp_board;
}

int main() {
  bool *board = (bool *)malloc(sizeof(bool) * CELL_NUMBER * CELL_NUMBER);
  board[1] = true;
  board[3] = true;
  board[4] = true;
  board[5] = true;
  set_board(board);

  uint8_t *bruh = run_game();
  print_board((bool *)bruh);

  /* board = custom_run_game(); */
  /* print_board(board); */

  return 0;
}
