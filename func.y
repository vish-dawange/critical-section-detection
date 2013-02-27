%{
#include<stdio.h>
#include<string.h>
#include "common.h"

extern int line_counter; // input program line counter
int flag = 0; // check for block entries
int global_index = 0, func_index = 0, symbol_index = 0, par_index = 0, global_func_index = 0, par_func = 0, thread_index = 0, log_index=0, semphr_index = 0, cs_index = 0; //table index
char data_type[20]; // c data type
char access[20]; // access specifier (static,extern,typedef,etc.)
int in_func_flag = 0,in_func_stmt_flag = 0, ignore_flag = 0, local_found = 0, cs_detect = 0;
global_symbol gsym_tab[50]; // Global variable Entries
func_def func_tab[50]; // user defined function entries
symbol_table sym_tab[50]; // Symbol table Object
parameter par_tab[50]; // parameter table object
thread_info thread_tab[50]; // thread table object
func_def_log log_tab[50]; // log table object
semaphore_def sem_tab[50]; // semaphore table object
critical_section cs_tab[50]; // critical_section table object
int i;
void get_symbol(char []); // make entries into global and local variables

%}

%union
{
 char arg[20];
 char any_arg;
}

//define tokens which will help to match patterns
%token MAIN OPEN_BR CLOSE_BR OPEN_CBR CLOSE_CBR OPEN_SBR CLOSE_SBR STAR COMMA SEMI EQUAL_TO PTHREAD_CREATE ADDRESS SEM_WAIT SEM_POST
%token <arg>  VAR NUM ACCESS TYPE
%token <any_arg> ANYTHING
%type <arg> par_val1 par_val2 thread_creation sem_var
%%

// Start of Grammar with recursive statement
start:	stmnt start {printf("\n corrrect program with multiple statements");}|
	stmnt {printf("\n Correct program");}
	;

// Process c statements
stmnt:	func_stmnt |
	declarative_stmnt SEMI	{
					// Check for local/global variable
					if (flag == 1) printf("\n Local Variable");
					else
					{
						printf("\n Correct Global Declaration");
					}
				} //|
	//ignore_code //|
	//func_declare_stmnt
	;

func_declare_stmnt:	type VAR bracket SEMI {printf("\n Function declaration correct");}
		;

ignore_code:	ANYTHING |
		operand |
		{ignore_flag = 1;} block |
		OPEN_BR |
		CLOSE_BR|
		OPEN_SBR|
		CLOSE_SBR|
		STAR |
		COMMA |
		SEMI |
		EQUAL_TO
		TYPE |
		ACCESS|
		type VAR bracket SEMI
		;



// pattern match for variable declaration
declarative_stmnt:	type var_list {printf("\ncorrect variable declaration");}
			;

// pattern match for one or more varibles
var_list:	variable COMMA var_list|
		variable
		;

// make entry of variable based on block entries or global entries
variable:	VAR { get_symbol($1); } |
		VAR { get_symbol($1); }	 EQUAL_TO operand |
		VAR array { get_symbol($1); } |
		VAR array EQUAL_TO operand { get_symbol($1); }
		;

// pattern match for function statement
func_stmnt: func_prototype {

				// Make entry function into func_table
				printf("\n Correct Function Declaration");

				func_tab[global_func_index].index = global_func_index;
				func_tab[global_func_index].line_number = line_counter;
				func_tab[global_func_index].no_of_parameter = par_index + 1;

				global_func_index++;

			    } block
	;


// pattern match for function prototype
func_prototype: type VAR {
				// pattern match return type and function name
				strcpy(func_tab[global_func_index].return_type,data_type);
				strcpy(func_tab[global_func_index].func_name,$2);
			} bracket {printf("\n Correct Function prototype");} |
		type VAR {
				// pattern match return type and function name
				strcpy(func_tab[global_func_index].return_type,data_type);
				strcpy(func_tab[global_func_index].func_name,$2);
			} bracket {printf("\n Correct Function prototype");}
		;

bracket:	OPEN_BR par CLOSE_BR |
		OPEN_BR CLOSE_BR
		;

// pattern match for c data type
type:	ACCESS {
		strcpy(access,$1);
		strcpy(data_type," ");
		} type_def {
				printf("\n Correct type");
			   }|
		{strcpy(data_type," ");} type_def {
							strcpy(access,"Default");
							printf("\n Correct type");
						   }
	;

//pattern match for combinations of data types
type_def:TYPE {strcat(data_type,$1); strcat(data_type," ");} type_def |
	 TYPE {strcat(data_type,$1); strcat(data_type," ");} pointer |
	 TYPE {strcat(data_type,$1); strcat(data_type," ");} array |
	 TYPE {strcat(data_type,$1); strcat(data_type," ");} pointer array |
	 TYPE {strcat(data_type,$1);}
	 ;

// pattern match for pointer
pointer: STAR pointer|
	 STAR
	 ;

// pattern match for array
array:	OPEN_SBR operand CLOSE_SBR |
	OPEN_SBR CLOSE_SBR array |
	OPEN_SBR CLOSE_SBR
	;

operand:NUM|VAR
	;

// pattern match for function parameters
par:	parameter COMMA par|
	parameter
	;

// pattern match for parameter entry
parameter:	{strcpy(data_type,"");} type_def VAR {
							par_tab[par_index].func_index = global_func_index;
							strcpy(par_tab[par_index].type,data_type);
							strcpy(par_tab[par_index].par_name,$3);
							printf("\n\t\t %s \t %s \t %d",par_tab[par_index].par_name,par_tab[par_index].type,par_tab[par_index].func_index);
							par_index++;
						     }
		//| type_def
		;

// pattern match for block entry
block:	OPEN_CBR
		{
			if (flag)
			{
				in_func_flag = 1;
				par_func = func_index;

			}
			func_index = global_func_index;
			flag = 1;
		}
	code CLOSE_CBR
		{
			if (!in_func_flag)
				flag = 0;
			else
			{
				in_func_flag = 0;
				func_index = par_func;
			}
		}|
	OPEN_CBR CLOSE_CBR
	;

// pattern match for other c code
code:	any code|
	any
	;

any:	stmnt |
	ANYTHING |
	NUM |
	VAR {
		local_found = 0;
		for(i = 0;i < symbol_index; i++)
		{
			if (sym_tab[i].func_index == global_func_index - 1 && strcmp(sym_tab[i].sym_name,$1) == 0)
			{
				local_found = 1;
				log_tab[log_index].index = log_index;
				log_tab[log_index].line_number = line_counter;
				log_tab[log_index].func_index = global_func_index - 1;
				strcpy(log_tab[log_index].sym_name,$1);
				strcpy(log_tab[log_index].type,"Local");
				printf("\nGlobal_func_index :%d",global_func_index-1);
				printf("\n\t %5d %15s %15s %15s %15d",log_index,func_tab[log_tab[log_index].func_index].func_name,log_tab[log_index].sym_name,log_tab[log_index].type,log_tab[log_index].line_number);
				log_index++;
			}
		}

		if (!local_found)
		{
			for(i = 0;i < global_index; i++)
			{
				if (strcmp(gsym_tab[i].sym_name,$1) == 0)
				{
					log_tab[log_index].index = log_index;
					log_tab[log_index].line_number = line_counter;
					log_tab[log_index].func_index = global_func_index - 1;
					strcpy(log_tab[log_index].sym_name,$1);
					strcpy(log_tab[log_index].type,"Global");
					printf("\nGlobal_func_index :%d",global_func_index-1);
					printf("\n\t %5d %15s %15s %15s %15d",log_index,func_tab[log_tab[log_index].func_index].func_name,log_tab[log_index].sym_name,log_tab[log_index].type,log_tab[log_index].line_number);
					log_index++;
				}
			}
		}
    printf("\n Variable: %s-",$1);
	    }|
	block |
	OPEN_BR |
	CLOSE_BR|
	OPEN_SBR|
	CLOSE_SBR|
	STAR |
	COMMA |
	SEMI |
	EQUAL_TO |
	thread_creation |
	PTHREAD_CREATE |
	ADDRESS |
	SEM_WAIT OPEN_BR sem_var {	sem_tab[semphr_index].index = semphr_index;
					sem_tab[semphr_index].sem_wait_point = line_counter;
					strcpy(sem_tab[semphr_index].sem_obj,$3);
					semphr_index++;
				} CLOSE_BR SEMI |
	SEM_POST OPEN_BR sem_var {
					for(i = 0; i < semphr_index; i++)
						if (strcmp(sem_tab[i].sem_obj,$3) == 0)
							sem_tab[i].sem_post_point = line_counter;
				} CLOSE_BR SEMI
	;

sem_var :	ADDRESS	VAR { strcpy($$,$2); }
// |
//		ADDRESS VAR { strcpy($$,$2); } OPEN_SBR VAR CLOSE_SBR
	;

// pattern match for pthread_create
thread_creation : PTHREAD_CREATE OPEN_BR ADDRESS VAR COMMA par_val1 COMMA VAR { printf("\n thread object %s pointing to function %s",$4,$8);
										thread_tab[thread_index].index = thread_index;
										strcpy(thread_tab[thread_index].thread_obj, $4);
										strcpy(thread_tab[thread_index].func_name,$8);
										strcpy(thread_tab[thread_index].parent_thread,func_tab[func_index-1].func_name);

									} COMMA  par_val2 CLOSE_BR  {printf("\ncorrect thread...."); thread_index++;}
		;

par_val1 : ADDRESS VAR {printf("\n Thread attribute: %s",$2);
			strcpy(thread_tab[thread_index].thread_attr,$2);
			} | VAR { strcpy(thread_tab[thread_index].thread_attr,$1); }
	;

par_val2:  VAR {printf("\n Thread function parameter : %s",$1); strcpy(thread_tab[thread_index].func_arg,$1);}
	|
	OPEN_BR type CLOSE_BR ADDRESS VAR {printf("\n Thread function parameter : %s",$5); strcpy(thread_tab[thread_index].func_arg,$5);}
	;

%%

extern FILE *yyin;


void get_symbol(char var[10])
{
    if(flag==0) // Global variable entry
	{
	    gsym_tab[global_index].line_number = line_counter;
	    gsym_tab[global_index].index = global_index;
	    strcpy(gsym_tab[global_index].sym_name,var);
	    strcpy(gsym_tab[global_index].access,access);
	    strcpy(gsym_tab[global_index].type,data_type);
	    printf("\n Access of %s is %s \n line number: %d \nData type:%s",gsym_tab[global_index].sym_name,gsym_tab[global_index].access,gsym_tab[global_index].line_number,gsym_tab[global_index].type);
	    global_index++;
	}
    else // Local variable entry
	{

	    sym_tab[symbol_index].func_index = func_index-1;
	    sym_tab[symbol_index].index = symbol_index;
	    strcpy(sym_tab[symbol_index].access,access);
	    strcpy(sym_tab[symbol_index].sym_name,var);
	    strcpy(sym_tab[symbol_index].type,data_type);
	    sym_tab[symbol_index].line_number = line_counter;

	    symbol_index++;
	}

}

void display_global_variables()
{
	int i;
	if (global_index != 0)
	{
		printf("\n\n\t\t Symbol Table contains Global entries\n");
		printf("\n\t %5s %15s %15s %15s %15s","INDEX","ACCESS","NAME","TYPE","LINE");
		for(i = 0; i < global_index; i++)
			printf("\n\t %5d %15s %15s %15s %15d",gsym_tab[i].index,gsym_tab[i].access,gsym_tab[i].sym_name,gsym_tab[i].type,gsym_tab[i].line_number);
	}

}

void display_function()
{
	int i;
	if (global_func_index != 0)
	{
		printf("\n\n\t\t Function Table contains User defined functions\n");
		printf("\n\t %5s %15s %15s %15s %15s","INDEX","LINE","NAME","RET_TYPE","PARMTRS");
		for(i = 0; i < global_func_index; i++)
			printf("\n\t %5d %15d %15s %15s %15d ",func_tab[i].index,func_tab[i].line_number,func_tab[i].func_name,func_tab[i].return_type,func_tab[i].no_of_parameter);
	}
}

display_local_variables()
{
	int i;
	if (symbol_index != 0)
	{
		printf("\n\n\t\t Symbol Table contains Local Variables \n");
		printf("\n\t %5s %15s %15s %15s %15s %15s","INDEX","ACCESS","NAME","TYPE","FUNC_INDEX","LINE");
		for(i = 0;i < symbol_index; i++)
			printf("\n\t %5d %15s %15s %15s %15d %15d",i,sym_tab[i].access,sym_tab[i].sym_name,sym_tab[i].type,sym_tab[i].func_index,sym_tab[i].line_number);
	}
}

void display_func_paramtr()
{
	int i;
	if(par_index != 0)
	{
		printf("\n\n\t\t Symbol Table contains Parameters of function \n");
		printf("\n\t %5s %15s %15s %15s","INDEX","NAME","TYPE","FUNC_INDEX");
		for(i = 0;i < par_index; i++)
			printf("\n\t %5d %15s %15s %15d",i,par_tab[i].par_name,par_tab[i].type,par_tab[i].func_index);
	}
}

void display_thread()
{
	int i;
	if (thread_index != 0)
	{
		printf("\n\n\t\t Thread Table \n");
		printf("\n\t %5s %15s %15s %15s %15s %15s %15s","INDEX","THREAD_OBJ","FUNCTION_NAME","FUNC_INDEX","THREAD_ATTR","FUNC_ARG","PARENT_THREAD");
		for(i = 0;i < thread_index; i++)
			printf("\n\t %5d %15s %15s %15d %15s %15s %15s",i,thread_tab[i].thread_obj,thread_tab[i].func_name,thread_tab[i].func_index,thread_tab[i].thread_attr,thread_tab[i].func_arg,thread_tab[i].parent_thread);
	}
}

void display_log()
{
	int i;
	if (log_index != 0)
	{
		printf("\n\n\t\t Log Table \n");
		printf("\n\t %5s %15s %15s %15s %15s %15s","INDEX","FUNCTION_NAME","SYMBOL","TYPE","LINE_NUMBER","THREAD_FUNC");
		for(i = 0;i < log_index; i++)
			printf("\n\t %5d %15s %15s %15s %15d %15d",i,func_tab[log_tab[i].func_index].func_name,log_tab[i].sym_name,log_tab[i].type,log_tab[i].line_number, log_tab[i].thread_func);
	}
}

void display_semaphr()
{
	int i;
	if (semphr_index != 0)
	{
		printf("\n\n\t\t Semaphore Table \n");
		printf("\n\t %5s %15s %15s %15s","INDEX","SEM_OBJECT","WAIT_POINT","POST_POINT");
		for(i = 0;i < semphr_index; i++)
			printf("\n\t %5d %15s %15d %15d",i,sem_tab[i].sem_obj,sem_tab[i].sem_wait_point,sem_tab[i].sem_post_point);
	}
}

void assign_func_index()
{
	int i, j;

	for (i = 0; i < thread_index; i++)
		for (j = 0; j < global_func_index; j++)
			if (strcmp(thread_tab[i].func_name,func_tab[j].func_name) == 0)
			{
				thread_tab[i].func_index = func_tab[j].index;
				break;
			}
}


void check_thread_entry()
{
	int i, j;

	for (i = 0; i < log_index; i++)
		for(j = 0; j < thread_index; j++)
			if (log_tab[i].func_index == thread_tab[j].func_index)
			{
				log_tab[i].thread_func = 1;
				break;
			}

}

// Function detects critical region
void cs_check()
{
    int i, j, k;

	for (i = 0; i < log_index; i++)
	{
		cs_detect = 0;
		// loop used to handle proper locks
		for (k = 0; k < semphr_index; k++)
		    if (sem_tab[k].sem_wait_point <= log_tab[i].line_number && sem_tab[k].sem_post_point >= log_tab[i].line_number)
			    break;
		if (k != semphr_index)
		    continue;

		if ( (log_tab[i].thread_func) && strcmp(log_tab[i].type,"Global") == 0)
		{
			for (j= i + 1; j < log_index; j++)
			{
				if ( (log_tab[j].thread_func) && log_tab[i].func_index != log_tab[j].func_index  && strcmp(log_tab[j].type,"Global") == 0 && strcmp(log_tab[i].sym_name,log_tab[j].sym_name) == 0)
				{
				    for (k = 0; k < semphr_index; k++)
					if (sem_tab[k].sem_wait_point <= log_tab[j].line_number && sem_tab[k].sem_post_point >= log_tab[j].line_number)
					    break;

				    if (k != semphr_index)
					continue;
				    cs_detect = 1;
				    for (k = 0;k < cs_index; k++)
					{
					    if (log_tab[j].line_number == cs_tab[k].critical_location && strcmp(log_tab[j].sym_name,cs_tab[k].critical_obj) == 0)
						break;
					}
				    if (k == cs_index)
					{

					    cs_tab[cs_index].index = cs_index;
					    strcpy(cs_tab[cs_index].critical_obj, log_tab[j].sym_name);
					    cs_tab[cs_index].thread_func_index = log_tab[j].func_index;
					    cs_tab[cs_index].critical_location = log_tab[j].line_number;
					    cs_index++;
					}

				}
			}
			if (cs_detect)
			{
			    for (k = 0;k < cs_index; k++)
				{
				    if (log_tab[i].line_number == cs_tab[k].critical_location && strcmp(log_tab[j].sym_name,cs_tab[k].critical_obj) == 0)
					break;
				}
			    if (k == cs_index)
				{
				    cs_tab[cs_index].index = cs_index;
				    strcpy(cs_tab[cs_index].critical_obj, log_tab[i].sym_name);
				    cs_tab[cs_index].thread_func_index = log_tab[i].func_index;
				    cs_tab[cs_index].critical_location = log_tab[i].line_number;
				    cs_index++;
				}
			}
		}
	}

}


void display_critical_section()
{
	int i;
	if (cs_index != 0)
	{
		printf("\n\n\t\t Critical Section Detected \n");
		//	printf("\n\t %5s %15s %15s %15s","INDEX","CRITICAL_OBJECT","THREAD_FUNC_INDEX","CRITICAL_LOCATION");
		for(i = 0;i < cs_index; i++)
		    printf("\n\t INDEX: %d \n\t Shared Object: %s \n\t Thread Function Index:  %d \n\t Thread Function: %s \n\t Critical Location:  %d \n\n",i,cs_tab[i].critical_obj,cs_tab[i].thread_func_index,thread_tab[cs_tab[i].thread_func_index].func_name,cs_tab[i].critical_location);
	}
	else
		printf("\n\n NO CRITICAL SECTION DETECTED");
}

int main()
{
	yyin=fopen("thread_sample.c","r");
	yyparse();
	display_global_variables();
	display_function();
	display_local_variables();
	display_func_paramtr();
	assign_func_index();
	check_thread_entry();
	display_thread();
	display_log();
	display_semaphr();
	cs_check();
	display_critical_section();
	return 0;
}
