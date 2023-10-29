/*
ID: fabioya1
LANG: C
PROG: gift1
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct person {
  char name[20];
  int money;
};

struct person* find(int count, struct person people[], char name[]) {
  int i;

  for (i = 0; i < count; ++i) {
    if (strcmp(people[i].name, name) == 0) {
      return &people[i];
    }
  }

  return NULL;
}

int main(void) {
    FILE *fin  = fopen("gift1.in", "r");
    FILE *fout = fopen("gift1.out", "w");

    struct person people[10];

    int np, amount, share, left, n, i, j;
    char name[20];

    fscanf(fin, "%d", &np);

    for (i = 0; i < np; ++i) {
      fscanf(fin, "%s", people[i].name); /* same as &people[i].name */
      people[i].money = 0;
    }

    for (i = 0; i < np; ++i) {
      fscanf(fin, "%s", name);
      fscanf(fin, "%d %d", &amount, &n);

      if (n == 0) continue;

      share = amount / n;
      left = amount % n;

      find(np, people, name)->money += left - amount;;

      for (j = 0; j < n; ++j) {
        fscanf(fin, "%s", name);
        find(np, people, name)->money += share;
      }
    }

    for (i = 0; i < np; ++i) {
      fprintf(fout, "%s %d\n", people[i].name, people[i].money);
    }

    exit(0);
}
