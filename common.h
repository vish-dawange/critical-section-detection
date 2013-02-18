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
    int index;
    char type[SIZE_TYPE];
    char par_name[SIZE_VAR];
}parameter;

typedef struct symbol_table
{
    int index;
    char sym_name[SIZE_VAR];
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
    parameter par[NUM_PAR];
    int no_of_symbols;
    symbol_table sym_tab[SIZE_TABLE];
}func_def;
