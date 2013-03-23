#include <stdio.h>
#include <pthread.h>

struct student
{
    int rollno;
    char s_name[30];
    int marks;
}student;

struct student s1 = {1,"Mayur",60};
struct student s2 = {2,"Shala",65};

void add_sports(void *);
void add_extra_activity(void *);


int main ()
{
    pthread_t thread1,thread2,thread3,thread4;

    pthread_create(&thread1, NULL, add_sports, (void *)&s1);

    sleep(3);

    pthread_create(&thread2, NULL, add_extra_activity, (void *)&s2);

    sleep(3);

    pthread_create(&thread3, NULL, add_sports, (void *)&s1);

    sleep(3);

    pthread_create(&thread4, NULL, add_extra_activity, (void *)&s2);

    return 0;
}

void add_sports(void *data)
{
    extern struct student s1 = (struct student  *)&data;
    s1.marks = s1.marks + 10;
}


void add_extra_activity(void *data)
{
    extern struct student s2 = (struct student  *)&data;
    s2.marks = s2.marks + 10;
}
