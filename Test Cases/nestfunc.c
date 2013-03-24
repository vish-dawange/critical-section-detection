#include<stdio.h>
#include<pthread.h>

int x = 0;
void *foo()
{
    	//x = 1;
	printf("\nValue of x in ():%d",x);
	printf("pthread");
	bar();
}
void bar()
{
	x = 2;
	printf("\nValue of x in ():%d",x);
	//foo();
	foo_bar();
}
void foo_bar()
{
	x = 3;
	printf("\nValue of x in r():%d",x);
	//bar();
		
}

void *func1()
{
	x++;
}

int main()
{
		
		pthread_create(&thread1,NULL,foo,NULL);
		pthread_create(&thread1,NULL,func1,NULL);		
			//foo_bar();
		//foo();
		return 0;
}
