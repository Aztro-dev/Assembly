#include <iostream>
#include <string>
using namespace std;

extern "C" int repetitions(int len, char* input);

int main(){
  string input;
  cin >> input;
  int result = repetitions(input.length(), &input[0]);
  cout << result << endl;
  return 0;
}
