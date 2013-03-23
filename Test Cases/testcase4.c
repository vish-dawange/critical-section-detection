/*
C Program for function within functio(Declaration and Call) and shadowing of a variable
*/

#include<stdio.h>
#include<stdlib.h>

void foo();
int i=10;
int main()
{
  int i=9;
  i+=i;
  printf("\n%d\n",i);
  foo();
  return 0;
}

void foo()
{
  printf("\nInside foo() function\n");
  void inside_foo();
  inside_foo();
  printf("\nAgain Inside foo() function\n");
}

void inside_foo()
{
  printf("\nInside inside_foo() function\n");
}
