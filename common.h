/****************************************************************************************
 *	Header contains structures for handling critical section and declarations	*
 *	for genrating tables.								*
 *											*
 *	Structures defined contains the information extracted by the parser.		*
 *	It contains the important parameters of C program which are helpful		*
 *	in finding critical section. Tables generated from structures will		*
 *	contain the information extracted from parser.					*
*****************************************************************************************/


#include <stdio.h>

#define SIZE_VAR 50
#define SIZE_FUNC 30
#define NUM_PAR 30
#define SIZE_TYPE 20
#define SIZE_TABLE 100
#define INFINITY 65535

/* Structure contains information about all global variables. */
typedef struct global_symbol
{
    int index;
    char access[SIZE_VAR];
    char sym_name[SIZE_VAR];
    char type[SIZE_TYPE];
    int line_number;
}global_symbol;

/* Parameter structure has information about the parameters stated
   in user-defined functions. */
typedef struct parameter
{
    int func_index;
    char type[SIZE_TYPE];
    char par_name[SIZE_VAR];
}parameter;

/* symbol_table structure has information about all the local variables
   used in given input (C program). */
typedef struct symbol_table
{
    int index;
    int func_index;
    char sym_name[SIZE_VAR];
    char access[SIZE_VAR];
    char type[SIZE_TYPE];
    int line_number;
}symbol_table;

/* func_def structure has information about user-defined functions */
typedef struct func_def
{
    int index;
    int line_number;
    char func_name[SIZE_FUNC];
    char return_type[SIZE_TYPE];
    int no_of_parameter;
    int no_of_symbols;
}func_def;

/* thread_info structure has information about threads created in
   C program. */
typedef struct thread_info
{
    int index;
    int line_number;
    int pthread_join;
    char thread_obj[SIZE_TYPE];
    char func_name[SIZE_TYPE];
    int func_index;
    char thread_attr[SIZE_TYPE];
    char func_arg[SIZE_TYPE];
    char parent_thread[SIZE_TYPE];
}thread_info;

/* func_def_log structure contains log information about all the
   variables(i.e global/local) used in any user-defined functions. */
typedef struct func_def_log
{
    int index;
    int line_number;
    int func_index;
    int thread_index;
    char sym_name[SIZE_TYPE];
    char type[SIZE_TYPE];
    int thread_func;
}func_def_log;

/* semaphore_def structure has information about semaphores used in
   C program. It keeps the track of sem_wait & sem_post signals. */
typedef struct semaphore_def
{
     int index;
     int sem_wait_point;
     int sem_post_point;
     char sem_obj[SIZE_VAR];
}semaphore_def;

/* mutex_def structure has information about mutex used in C program.
   It keeps track of mutex_lock & mutex_unlock signal calls. */
typedef struct mutex_def
{
     int index;
     int mutex_lock_point;
     int mutex_unlock_point;
     char mutex_obj[SIZE_VAR];
}mutex_def;

/* critical_secrtion structure has information about critical sections detected
   in multithreaded programming. */
typedef struct critical_section
{
    int index;
    char critical_obj[SIZE_VAR];
    int thread_func_index;
    int critical_location;
}critical_section;

/* UD_func_cs structure will contain information about critical section affected
   by user-defined functions which are not thread functions. */
typedef struct UD_func_CS
{
    int index;
    int func_index;
    char critical_obj[SIZE_VAR];
    int parent_thread_index;
    int critical_location;
}UD_func_cs;

/* thread_log structure contains information about thread functions which has
   function index defined for praticular thread. */
typedef struct thread_log
{
    int func_index;
}thread_log;

/* critical_section_unique contains information of actual suspected critical
   region. */
typedef struct critical_section_unique
{
    int index;
    char critical_obj[SIZE_VAR];
    int thread_func_index;
    int min_critical_location;
    int max_critical_location;
}critical_section_unique;

typedef struct func_call_trace
{
    int index;
    int func_index;
    int parent_index;
    char func_name[SIZE_VAR];
    int line_number;
}func_call_trace;

typedef struct call_trace_tree
{
    int index;
    func_call_trace func_call_obj;
    struct call_trace_tree *next;
}call_trace_tree;

extern int line_counter; // input program line counter
extern int pre_counter;
int display_lock = 0;
int flag = 0; // check for block entries

char data_type[SIZE_VAR]; // c data type
char access[SIZE_VAR]; // access specifier (static,extern,typedef,etc.)

/* flag declarations */
int in_func_flag = 0,in_func_stmt_flag = 0, ignore_flag = 0, local_found = 0, cs_detect = 0, extern_flag = 0, struct_flag = 0, thread_lib_flag = 0;

/* headers contains name of headers used in input file */
char *headers[SIZE_VAR];

/* Index variable */
int i;

/* Counter variable for parameters used in user-defined functions */
int par_counter = 0;

/* Index of curly brace which should be pop from stack */
int release_value = INFINITY;

/* Table Index*/
int global_index = 0, func_index = 0, symbol_index = 0, par_index = 0, global_func_index = 0, par_func = 0, thread_index = 0, log_index=0, semphr_index = 0, cs_index = 0, thread_log_index = 0, hdr_index = 0, mutex_index = 0, call_trace_index = 0, trace_tree_index = 0, func_cs_index = 0;

/* Structure object declaration */
global_symbol gsym_tab[SIZE_TABLE]; // Global variable Entries
func_def func_tab[SIZE_TABLE]; // user defined function entries
symbol_table sym_tab[SIZE_TABLE]; // Symbol table Object
parameter par_tab[SIZE_TABLE]; // parameter table object
thread_info thread_tab[SIZE_TABLE]; // thread table object
func_def_log log_tab[SIZE_TABLE]; // log table object
semaphore_def sem_tab[SIZE_TABLE]; // semaphore table object
critical_section cs_tab[SIZE_TABLE]; // critical_section table object
thread_log thread_log_tab[SIZE_TABLE]; // thread log table object
mutex_def mutex_tab[SIZE_TABLE]; // mutex table object
critical_section_unique cs_tab1[SIZE_TABLE]; //critical section table object
func_call_trace call_trace[SIZE_TABLE]; // function call trace object
call_trace_tree *stack_trace[SIZE_TABLE]; //
UD_func_cs func_cs_tab[SIZE_TABLE]; //
