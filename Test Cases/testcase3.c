/* C program for macro and globally declared multi-dimentional array. */

#include<stdio.h>
#include<stdlib.h>

#define MAX 2

//Function Prototype
void initialize();
void display();

//GLOBAL DECLARATION
int matrix1[MAX][MAX];
int main()
{

   initialize();
   display();
   return 0;
}
int matrix1[MAX][MAX];

void  initialize()
{
int i,j;
  for(i=0; i<MAX; i++)
    for(j=0; j<MAX; j++)
      matrix1[i][j] = 0 ;
}

void display()
{
   int i,j;
   for(i=0; i<MAX; i++)
     {
       for(j=0; j<MAX; j++)
         {
           printf("%d\t",matrix1[i][j]);
         }
       printf("\n");
     }
}
