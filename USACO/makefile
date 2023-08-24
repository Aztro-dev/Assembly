compile:
	@nasm -f elf64 ReadFile/main.asm
	@ld ReadFile/main.o -o ReadFile/main
	@rm -f ReadFile/main.o
	@nasm -f elf64 Ride/main.asm
	@ld Ride/main.o -o Ride/main
	@rm -f Ride/main.o
	@echo "Compilation Done"

clean:
	@rm -f ReadFile/main
	@rm -f Ride/main
	@echo "Cleaned"
