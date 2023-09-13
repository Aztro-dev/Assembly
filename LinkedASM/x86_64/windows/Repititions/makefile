compile:
	@nasm -f win64 repetitions.asm
	@g++ main.cpp -o main -masm=intel repetitions.obj
	@rm -f repetitions.obj

clean:
	@rm -f repetitions.obj
	@rm -f main.exe
