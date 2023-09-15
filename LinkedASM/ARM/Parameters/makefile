compile:
	@gcc -c parameters.asm
	@g++ main.cpp -o main parameters.o
	@rm -f parameters.o

clean:
	@rm -f main
	@rm -f parameters.o
	@rm -f main.s
