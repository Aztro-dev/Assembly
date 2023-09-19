#include <iostream>
#include <cstdint>
using namespace std;

int asm_func(uint64_t num){
register uint64_t arg2 asm("rdi") = num;
__asm__(
        "mov rax, 7\n\t"
        "add rax, rdi\n\t"
        "ret"
        );
return 0;
}

int main(){
  int a = asm_func(12);
  cout << a << endl;
  return 0;
}
