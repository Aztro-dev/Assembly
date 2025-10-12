#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>

#define BUF_SIZE 4096

struct linux_dirent64 {
  int64_t d_ino;     // inode number
  int64_t d_off;     // offset but not really
  uint16_t d_reclen; // size of the direntry
  uint8_t d_type;    // file type
  char d_name[];     // filename (null-terminated)
};

void read_dir(int fd) {
  char entries_buffer[BUF_SIZE];
  size_t bytes_read = syscall(SYS_getdents64, fd, entries_buffer, BUF_SIZE);

  if (bytes_read == -1) {
    printf("Error getting the entries buffer\n");
    exit(1);
  }

  int iter = 0;
  for (int i = 0; i < bytes_read;) {
    struct linux_dirent64 *dir_entry = (struct linux_dirent64 *)(entries_buffer + i);
    printf("%s\n", dir_entry->d_name);
    i += dir_entry->d_reclen;
  }
}

int main(int argc, char *argv[]) {
  if (argc == 1) {
    int fd = open(".", O_RDONLY | O_DIRECTORY);

    read_dir(fd);

    close(fd);
  } else {
    for (int i = 1; i < argc; i++) {
      int fd = open(argv[i], O_RDONLY | O_DIRECTORY);

      read_dir(fd);

      close(fd);
    }
  }
  return 0;
}
