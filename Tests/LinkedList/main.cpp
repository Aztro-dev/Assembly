#include <cstdint>
#include <stdio.h>

struct LinkedList {
  int64_t data;
  struct LinkedList *next;
};

extern "C" void populate_linked_list(struct LinkedList *l);

int main() {
  struct LinkedList linked_list = {0, nullptr};
  populate_linked_list(&linked_list);
  printf("%lld, %#08X", linked_list.data, linked_list.next);
}
