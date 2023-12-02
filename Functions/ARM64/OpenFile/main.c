// #include <stdio.h>
#include <unistd.h>

int main(void) {

  write(0x01, "Test\n", 5);
  // FILE *f = fopen("open_file.asm", "r");
  // char file_buffer[1024] = {0};
  // size_t status = fread(file_buffer, 1, 1024, f);
  // printf("%s", file_buffer);
  return 0;
}
