#include <sys/types.h>
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

struct abcd
{
 int abds;
 int flag;
}abcd;

int X;
//U_TYPE abc;
struct abcd a132;
int Y = 4;
int *xyz[];
void* function12(int j,int i);
void* function1()
{
	int X;
	{
		extern int X;

		while(1)
		{

			X = 0; // write
			printf("After thread ID A	writes to X, X = %d\n and Y = %d\n", X, Y);
			X++;

			sleep(1);
		}


	}
	printf("Value Of X: %d",X);
}
void* function2()
{
    while(1)
	{
	    sem_wait(&n);
	    X++; Y++;
	    sem_post(&n);
	    printf("After thread ID B	reads from X, X = %d\n",	X);
	    sleep(1);

	}
}

int add()
{
    int X;
    {
	extern int X;
	X++;
    }
    X++;
}

int main()
{
    void* status;
    pthread_t thread1, thread2;
    add();
    pthread_create(&thread1, NULL, function1, NULL);
    pthread_create(&thread2, NULL, function2, NULL);
}
