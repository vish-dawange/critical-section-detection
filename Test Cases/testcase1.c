/*C Program Containing Macro and Nested Data Types*/

#include<stdio.h>
#include<stdlib.h>

#define ADD(x) x + x //MACRO DEF

int main()
{
  long double i=2.3331;
  long long j=4.33223;
  ADD(i);
  printf("%Le\n",i);
  printf("\n%lld\n\n",j);
  return 0;
}
