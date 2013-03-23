#include<stdio.h>
#include<pthread.h>
#include<sys/types.h>
#include<unistd.h>
#define foo 1
int x;

void *f1() {
    int p=0;

    while(1) {
	//sem_wait(&n);
	x=0;
	printf("\nThread A writes:%d",x);
	x++;

	//sem_post(&n);
	sleep(1);
    }
    printf("P:%d",p);
}

void *f2() {
    int l;
    while(1) {
	// sem_wait(&n);
	printf("\nThread B writes:%d",x);
	x++;
	// sem_post(&n);
	sleep(1);
    }
    printf("L:%d",l);
}

int main() {
    void *status;
    pthread_t thread1, thread2;
    // printf("%d",foo);
    // return 0;
    pthread_create(&thread1,NULL,f1,NULL);
    pthread_create(&thread2,NULL,f2,NULL);
    pthread_join(thread2,&status);
    pthread_join(thread1,&status);
    return 0;
}
