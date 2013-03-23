/* Title : Program for handling of global variable and local variable in multi-threaded program.
************************************************************************************************	
A) Programs contains following things:
1) This program contains global variables,local variables and POSIX threads.
2) POSIX threads are going to execute userdefined functions.
************************************************************************************************
B) Input is given to cscheck tool which parses into following format
(Expected Output for this program.)
1) To display global and local symbol's entries.
2) To display Thread's entries and the functions name that are going to execute by threads
************************************************************************************************  
*/
#include<stdio.h>
#include<pthread.h>
#include<stdlib.h>
//declaration of global variable.
int index;

void * insert_into_array(void *); // declaration of function that executed by threads.

/* Definition of insert into function */
void *insert_into_array(void *array_ptr)
{
	//local variable declaration for this function
	int *temp_ptr,temp_value;
	void *temp;
	temp_ptr = (int *) array_ptr;
	//generating some random value that inserted into array.	
	temp_value = rand() % 100;	
	//generating some random value for index variable 	
	index = rand() % 5;
	temp_ptr[index] = temp_value; //assign value to array
	return array_ptr;
}

/* Declaration of main function */
int main()
{
	int array[5]; //local variable declaration 
	pthread_t thread1,thread2;// declaration of POSIX thread variable.		
	//thread1 is executing insert_into_array function by passing array as an argument to it.	
	pthread_create ( &thread1 , NULL , insert_into_array ,(void *)&array);
    	pthread_join ( thread1 , ( void * )&array);
	return 0;
}
