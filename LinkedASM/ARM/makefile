compile:
	nasm -f macho64 five.asm
	g++ main.cpp -o main -masm=intel five.obj

clean:
	@rm -f main
	@rm -f five.o
	@rm -f main.s
