compile:
	nasm -f elf64 game.asm -o game.o
	gcc -o main main.c game.o -no-pie
	rm game.o
