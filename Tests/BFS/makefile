compile: test.c main.asm
	gcc -c test.c -o test.o
	nasm -f elf64 main.asm -o main.o
	gcc test.o main.o -o main
	@rm -f test.o
	@rm -f main.o

clean:
	@rm -f test.o
	@rm -f main.o
	@rm -f main
