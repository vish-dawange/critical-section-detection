// Sample.c

/* This program is simple C code used to test
   parser. This program currently does not contain
   any thread entries. It is just used to evaluate
   other important entries like global/local symbols,
   user defined functions, etc.
*/

#include<stdio.h>
#define max 10

static unsigned int global_1=10.5,Global_2=10;
extern int Global_3;

typedef struct test_struct
{
	int struct_var1;
	char struct_var2;
}test_struct;



int abcd()
{
    extern long int * Local_1;
    int Local_2 = 0;
    if(1)
	{
	    printf("\n Inside");
	}

    else
	{
	    printf("\n out");
	}

    printf("\n %d\n",a*b);

    int add(int par_1)
	{
	    int Local_3, Local_4, Local_5;
	}


    int sub(int par_2)
	{
	    static int Local_6;
	}


  return 0;
}

