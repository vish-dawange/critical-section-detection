#include <stdio.h>

#define SIZE_VAR 30
#define SIZE_FUNC 30
#define NUM_PAR 30
#define SIZE_TYPE 20
#define SIZE_TABLE 50

typedef struct global_symbol
{
    int index;
    char access[SIZE_VAR];
    char sym_name[SIZE_VAR];
    char type[SIZE_TYPE];
    int line_number;
}global_symbol;

typedef struct parameter
{
    int func_index;
    char type[SIZE_TYPE];
    char par_name[SIZE_VAR];
}parameter;

typedef struct symbol_table
{
    int func_index;
    char sym_name[SIZE_VAR];
    char access[SIZE_VAR];
    char type[SIZE_TYPE];
    int line_number;
}symbol_table;

typedef struct func_def
{
    int index;
    int line_number;
    char func_name[SIZE_FUNC];
    char return_type[SIZE_TYPE];
    int no_of_parameter;
    int no_of_symbols;

}func_def;

typedef struct thread_info
{
    int index;
    char thread_obj[SIZE_TYPE];
    char func_name[SIZE_TYPE];
    char thread_attr[SIZE_TYPE];
    char func_arg[SIZE_TYPE];
    char parent_thread[SIZE_TYPE];
}thread_info;


typedef struct function_def_log
{
    int index,function_index;
    char variable[SIZE_TYPE],type[SIZE_TYPE];
}function_def_log;
