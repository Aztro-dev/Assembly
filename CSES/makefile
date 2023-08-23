compile:
	@nasm -f elf64 MissingNumber/main.asm
	@ld MissingNumber/main.o -o MissingNumber/main
	@rm -f MissingNumber/main.o
	@nasm -f elf64 A+B/main.asm
	@ld A+B/main.o -o A+B/main
	@rm -f A+B/main.o
	@nasm -f elf64 WeirdAlgorithm/main.asm
	@ld WeirdAlgorithm/main.o -o WeirdAlgorithm/main
	@rm -f WeirdAlgorithm/main.o
