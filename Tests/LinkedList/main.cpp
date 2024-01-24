#include <cstdint>
#include <cstdlib>
#include <stdio.h>

struct LinkedList {
  int64_t data;
  struct LinkedList *next;
};

extern "C" void populate_linked_list(struct LinkedList *l,
                                     struct LinkedList *next);

int main() {
  LinkedList linked_list = {0, nullptr};
  LinkedList *next_linked_list = (LinkedList *)malloc(1 * sizeof(LinkedList));
  populate_linked_list(&linked_list, next_linked_list);
  printf(
      "linked_list.data: %lld, linked_list.next: 0x%08X, actual_next: 0x%08X\n",
      linked_list.data, linked_list.next, next_linked_list);
}
