compile:
	@nasm -f win64 main.asm
	@gcc main.obj -o main -Wall -Werror
	@rm -f main.obj

clean:
	@rm -f main.obj
	@rm -f main.exe
