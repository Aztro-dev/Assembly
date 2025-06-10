%ifndef SYSCALLS
%define SYSCALLS
  %define SYS_READ  0
  %define SYS_WRITE 1
  %define SYS_OPEN  2
  %define SYS_CLOSE 3
  %define SYS_LSEEK 8
  %define SYS_BRK   12
  %define SYS_EXIT  60
  %define SYS_CREAT 85

  %define STDIN  0
  %define STDOUT 1
  %define STDERR 2
%endif
