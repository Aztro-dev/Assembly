compile: main.asm
	@nasm -f elf64 main.asm -o main.o
	@ld main.o -o main -g
	@rm -f main.o

simd: simd.asm
	@nasm -f elf64 simd.asm -o simd.o
	@ld simd.o -o main -g
	@rm -f simd.o

clean:
	@rm -f main.o
	@rm -f main
	@rm -f simd.o
