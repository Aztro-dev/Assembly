compile:
	@nasm -f win64 parameters.asm
	@g++ main.cpp -masm=intel parameters.obj -o main

clean:
	@rm -f parameters.obj
	@rm -f main.exe
