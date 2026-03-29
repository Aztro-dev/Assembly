compile: test.c main.asm
	gcc -c test.c -no-pie -o test.o
	nasm -g -f elf64 main.asm -o main.o
	gcc test.o main.o -no-pie -o main
	@rm -f test.o
	@rm -f main.o

clean:
	@rm -f test.o
	@rm -f main.o
	@rm -f main
