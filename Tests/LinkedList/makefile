compile:
	@nasm -f win64 linked_list.asm -o linked_list.obj
	@gcc main.cpp linked_list.obj -o main
	@rm -f linked_list.obj
clean:
	@rm -f main.exe
	@rm -f linked_list.obj
