compile: main.asm
	@nasm -g -f elf64 main.asm -o main.o
	@ld main.o -o main -g
	@rm -f main.o

run: main
	@./main < test_input.txt

clean:
	@rm -f main.o
	@rm -f main
