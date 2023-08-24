compile:
	@nasm -f elf64 ReadFile/main.asm
	@ld ReadFile/main.o -o ReadFile/main
	@rm -f ReadFile/main.o
	@nasm -f elf64 Ride/main.asm
	@ld Ride/main.o -o Ride/main
	@rm -f Ride/main.o
	@nasm -f elf64 WriteFile/main.asm
	@ld WriteFile/main.o -o WriteFile/main
	@rm -f WriteFile/main.o
	@echo "Compilation Done"

clean:
	@rm -f ReadFile/main
	@rm -f Ride/main
	@rm -f WriteFile/output.out
	@echo "Cleaned"
