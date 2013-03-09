/*
	program contains stack opration which is used for handling curly brace

	Main purpose of handling curly brace is to identify equal occurence of
	opening and closing curly brace. This would help to identify inner functions
	and can be helpful to identify the enttries of shadowing global variables.
*/

#include <stdio.h>

#define MAX 100
#define MIN 0
#define SIZE_STACK 100

// stack structure
typedef struct stack_brace
{
    int top;
    char brace[SIZE_STACK];
}stack_brace;

// initialize top pointeer of stack
void init_cbr_stack(stack_brace *st)
{
    st->top = -1;
}

// push curly brace into stack
void push_cbr (stack_brace *st)
{
    if (st->top == MAX)
	{
	    printf("\n STACK OVERLFOW (CURLY BRACE)!!!");
	    exit(0);
	}
    st->brace[++st->top] = '{';
}

// pop curly brace from stack
void pop_cbr(stack_brace *st)
{
    if (st->top < MIN)
	{
	    printf("\n Stack Underflow (CERLY BRACE)!!!");
	    exit(0);
	}
    st->top--;
}
