/* simple program using array to show critical section*/
//header declaration
#include<stdio.h>
#include<unistd.h>
#include<pthread.h>
#include<stdlib.h>
#include<sys/types.h>

int index;//it is used for inserting array
void *insert_into_array( void* abc );
int main() 
{
  int array[5];
  pthread_t thread1,thread2;
  pthread_create ( &thread1 , NULL , insert_into_array ,(void *)&array);
  
  pthread_create ( &thread2  , NULL , insert_into_array ,(void *)&array);
  pthread_join ( thread1 , ( void * )&array);
  pthread_join(thread2,  ( void * )&array);
  return 0;
} 

void *insert_into_array( void *arr_ptr)
{
//sem_wait(&n);
  int *temp_ptr, temp_value;
  //  pid_t thr_id;
  temp_ptr = ( int *) arr_ptr;
  //  thr_id = gettid();
  temp_value = rand() % 100;//creating random value for insertion into array
  index = rand() % 5;//inserting at random index;
  //  printf("\n By %d thread ",thr_id);
  printf("\n %d value should be at %d index", temp_value , index);
  temp_ptr[index] = temp_value;
  sleep( rand() % 4 );// it sleeps for random value(between 0 to 4)
  printf("\n %d ",temp_ptr[index]);
//sem_post(&n);
  return arr_ptr;
}
