%{
#include<stdio.h>
#include<string.h>
#include "common.h"
#include "Cbrace_stack.h"

#define INFINITY 65535

extern int line_counter; // input program line counter
int flag = 0; // check for block entries
int global_index = 0, func_index = 0, symbol_index = 0, par_index = 0, global_func_index = 0, par_func = 0, thread_index = 0, log_index=0, semphr_index = 0, cs_index = 0, thread_log_index = 0; //table index
char data_type[20]; // c data type
char access[20]; // access specifier (static,extern,typedef,etc.)
int in_func_flag = 0,in_func_stmt_flag = 0, ignore_flag = 0, local_found = 0, cs_detect = 0, extern_flag = 0, struct_flag = 0, thread_lib_flag = 0;
global_symbol gsym_tab[50]; // Global variable Entries
func_def func_tab[50]; // user defined function entries
symbol_table sym_tab[50]; // Symbol table Object
parameter par_tab[50]; // parameter table object
thread_info thread_tab[50]; // thread table object
func_def_log log_tab[50]; // log table object
semaphore_def sem_tab[50]; // semaphore table object
critical_section cs_tab[50]; // critical_section table object
thread_log thread_log_tab[50]; // thread log table object
int i;
int par_counter = 0;
void get_symbol(char []); // make entries into global and local variables

int release_value = INFINITY; // index of curly brace which should be pop from stack
stack_brace cbr_stack; // Stack for handling equal curly braces



%}

%union
{
 char arg[20];
 char any_arg;
}

//define tokens which will help to match patterns
%token MAIN OPEN_BR CLOSE_BR OPEN_CBR CLOSE_CBR OPEN_SBR CLOSE_SBR STAR COMMA SEMI EQUAL_TO PTHREAD_CREATE ADDRESS SEM_WAIT SEM_POST U_STRUCT POINTER_ACCESS THREAD_LIB
%token <arg>  VAR NUM ACCESS TYPE
%token <any_arg> ANYTHING
%type <arg> par_val1 par_val2 thread_creation sem_var
%nonassoc high_priority
%%

// Start of Grammar with recursive statement
start:	stmnt start {printf("\n corrrect program with multiple statements");}|
	stmnt {printf("\n Correct program");}
	;

// Process c statements
stmnt:	user_defination |	
	declarative_stmnt SEMI	{
					// Check for local/global variable
					if (flag == 1) printf("\n Local Variable");
					else
					{
						printf("\n Correct Global Declaration");
					}
				} |
	func_stmnt //|
	//thread_lib
	;

// Process user defined strutures like struct, enum, union
user_defination:	user_def_type1 SEMI {struct_flag = 0;} |
			user_def_type1 multi_var SEMI {struct_flag = 0;} |
			user_def_type2 SEMI {struct_flag = 0;} |
			user_def_type2 multi_var SEMI {struct_flag = 0;} |
			U_STRUCT {struct_flag = 1;} block multi_var SEMI {struct_flag = 0;} |
			ACCESS U_STRUCT {struct_flag = 1;} block multi_var SEMI {struct_flag = 0;} //|
			;

// Process : struct/union/enum struct_name {/* declaration */}
user_def_type1 :	u_struct {struct_flag = 1;} block
			;

// Process : typedef struct/union/enum struct_name {/* declaration */}
user_def_type2 :	ACCESS U_STRUCT {struct_flag = 1;} VAR block
			;

// Process : struct/union/enum struct_name
u_struct :              U_STRUCT VAR { strcpy(data_type,$2);}
			;

// Process variable declarations at end of structure block
multi_var:	VAR |
		VAR COMMA multi_var
		;


// pattern match for variable declaration
declarative_stmnt:	type var_list {printf("\ncorrect variable declaration...");} |
			utype_declaration |
			THREAD_LIB {thread_lib_flag = 1;} var_list {thread_lib_flag = 0;}
			;

// pattern match for c data type
type:	ACCESS {
		strcpy(access,$1);
		strcpy(data_type," ");
		if ( strcmp(access, "extern") == 0)
			{
				extern_flag = 1;
				release_value = cbr_stack.top;
			}
		} type_def {
				printf("\n Correct type \t line No. :%d",line_counter);
			   } |
		{strcpy(data_type," ");} type_def {
							strcpy(access,"Default");
							printf("\n Correct type \t line No. :%d",line_counter);
						   }/* |
		ACCESS {
		strcpy(access,$1);
		strcpy(data_type," ");
		if ( strcmp(access, "extern") == 0)
			{
				extern_flag = 1;
				release_value = cbr_stack.top;
			}
		} VAR {
				strcpy(data_type,$3);
				printf("\n Correct type \t line No. :%d",line_counter);
			   }|
		VAR {
			strcpy(access,"Default");
			strcpy(data_type,$1);
			printf("\n Correct type \t line No. :%d",line_counter);
		    }*/
	;

//pattern match for combinations of data types
type_def:	TYPE {strcat(data_type,$1); strcat(data_type," ");} type_def |
	 	TYPE {strcat(data_type,$1); strcat(data_type," ");} pointer |
	 	TYPE {strcat(data_type,$1); strcat(data_type," ");} array |
	 	//TYPE {strcat(data_type,$1); strcat(data_type," ");} type_def array |
	 	TYPE {strcat(data_type,$1);}
	 	;

// pattern match for pointer
pointer: STAR pointer|
	 STAR
	 ;

// pattern match for array
array:	array_type1 |
	array_type1 array |
	array_type2 |
	array_type2 array 
	;

// process: [ VAR/NUM ]
array_type1:	OPEN_SBR operand CLOSE_SBR
		;

// process: [ ]
array_type2:	OPEN_SBR CLOSE_SBR
		;

// process Numbers or symbols
operand:	NUM | VAR
		;

// pattern match for one or more varibles
var_list:	variable COMMA var_list |
		variable
		;

// process structure declarations
utype_declaration:	u_struct var_list |
			ACCESS u_struct {
						strcpy(access,$1);
						strcpy(data_type," ");
						if ( strcmp(access, "extern") == 0)
						{
							extern_flag = 1;
							release_value = cbr_stack.top;
						}
					} var_list
			;


// make entry of variable based on block entries or global entries
variable:	VAR { get_symbol($1); } |
		//VAR { get_symbol($1); } EQUAL_TO NUM |
		variable_type1 assign_expr |
		variable_type2 assign_expr |
		VAR array { get_symbol($1); } |		
		array VAR { get_symbol($2); } EQUAL_TO assign_expr |
		//array VAR { get_symbol($2); } EQUAL_TO block |
		pointer VAR { get_symbol($2); } EQUAL_TO assign_expr |
		pointer VAR { get_symbol($2); } 
		;

// process var_name =
variable_type1:	VAR { get_symbol($1); }	 EQUAL_TO
		;

// process var_name [] =
variable_type2:	VAR array EQUAL_TO { get_symbol($1); }
		;

// process assignment operation
assign_expr:	OPEN_CBR assign_expr | CLOSE_CBR assign_expr |  CLOSE_CBR |
		any_expr assign_expr |
		any_expr
		;
		
// pattern match for function statement
func_stmnt:	func_prototype SEMI {par_index = par_index - par_counter; printf("\n Correct Function prototype Declaration");} |
		func_prototype {

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
				printf("\n Correct Function prototype");
		} bracket {printf("\n Correct Function prototype");}
		;

// process function parameters
bracket:	OPEN_BR { par_counter = 0;} par CLOSE_BR |
		OPEN_BR CLOSE_BR
		;


// pattern match for function parameters
par:	parameter COMMA par|
	parameter
	;

// pattern match for parameter entry
parameter:	parameter_type1 |
		parameter_type1 array |
		utype_par
		//{strcpy(data_type,"");} type
		;

// process: data_type var_name
parameter_type1:	parameter_type2 VAR	{
							par_tab[par_index].func_index = global_func_index;
							strcpy(par_tab[par_index].type,data_type);
							strcpy(par_tab[par_index].par_name,$2);
							printf("\n\t\t %s \t %s \t %d",par_tab[par_index].par_name,par_tab[par_index].type,par_tab[par_index].func_index);
							par_index++;
							par_counter++;
						} |
			parameter_type2
			;

// process built in data types
parameter_type2:	{strcpy(data_type,"");} type
	;

// process structure parameters to the function
utype_par:      utype_par_type1 |
		utype_par_type1 array |		
		u_struct array VAR |
		u_struct pointer VAR
		;

// process struct/union/enum struct_name var_name
utype_par_type1:	u_struct VAR
			;

// pattern match for block entry
block:	OPEN_CBR
		{
			push_cbr(&cbr_stack);
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
			if (release_value == cbr_stack.top)
			{
				extern_flag = 0;
				release_value = INFINITY;
			}
			pop_cbr(&cbr_stack);
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
code:	block | block code |
	stmnt | stmnt code |  any code |
	any
	;

// process any code that will appear in function blocks
any:
	NUM |
	VAR {
		local_found = 0;
		for(i = 0;i < symbol_index; i++)
		{
			if (sym_tab[i].func_index == global_func_index - 1 && strcmp(sym_tab[i].sym_name,$1) == 0 && (!extern_flag))
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
    		printf("\n Variable: %s:",$1);
	    }|
	OPEN_BR |
	CLOSE_BR|
	OPEN_SBR|
	CLOSE_SBR|
	OPEN_BR type CLOSE_BR |
	OPEN_BR u_struct pointer CLOSE_BR |
	STAR |
	COMMA |
	SEMI |
	POINTER_ACCESS |
	EQUAL_TO |
	thread_creation |
	//PTHREAD_CREATE |
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


// process any code that will appear in assignment expression
any_expr:
	NUM |
	VAR {
		local_found = 0;
		for(i = 0;i < symbol_index; i++)
		{
			if (sym_tab[i].func_index == global_func_index - 1 && strcmp(sym_tab[i].sym_name,$1) == 0 && (!extern_flag))
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
    printf("\n Variable: %s:",$1);
	    }|
	//block |
	OPEN_BR |
	CLOSE_BR|
	OPEN_SBR|
	CLOSE_SBR|
	STAR |
	COMMA |
	TYPE |
	U_STRUCT |
	POINTER_ACCESS |
	EQUAL_TO |
	thread_creation |
	//PTHREAD_CREATE |
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

// process semaphore parameters
sem_var :	ADDRESS	VAR { strcpy($$,$2); } |
		VAR { strcpy($$,$1); }
// |
//		ADDRESS VAR { strcpy($$,$2); } OPEN_SBR VAR CLOSE_SBR
	;

// pattern match for pthread_create
thread_creation : thread_creation_type1 COMMA par_val1 COMMA VAR { printf(" pointing to function %s",$5);
										thread_tab[thread_index].index = thread_index;
										
										strcpy(thread_tab[thread_index].func_name,$5);
										strcpy(thread_tab[thread_index].parent_thread,func_tab[func_index-1].func_name);

									} COMMA  par_val2 CLOSE_BR  {printf("\ncorrect thread...."); thread_index++;} |
		thread_creation_type1 array COMMA par_val1 COMMA VAR { printf(" pointing to function %s",$6);
										thread_tab[thread_index].index = thread_index;
										
										strcpy(thread_tab[thread_index].func_name,$6);
										strcpy(thread_tab[thread_index].parent_thread,func_tab[func_index-1].func_name);

									} COMMA  par_val2 CLOSE_BR  {printf("\ncorrect thread...."); thread_index++;}
		;

// process: pthread_create ( & thread_object )
thread_creation_type1:	PTHREAD_CREATE OPEN_BR ADDRESS VAR {	printf("\n thread object %s ",$4);
						strcpy(thread_tab[thread_index].thread_obj, $4);
					   }
			;

par_val1: 	ADDRESS VAR	{	
					printf("\n Thread attribute: %s",$2);
					strcpy(thread_tab[thread_index].thread_attr,$2);
				} | 
		VAR { strcpy(thread_tab[thread_index].thread_attr,$1); }
		;

par_val2:	VAR {printf("\n Thread function parameter : %s",$1); strcpy(thread_tab[thread_index].func_arg,$1);} |
		par_val2_type1 VAR {printf("\n Thread function parameter : %s",$2); strcpy(thread_tab[thread_index].func_arg,$2);} |
		par_val2_type1 ADDRESS VAR {printf("\n Thread function parameter : %s",$3); strcpy(thread_tab[thread_index].func_arg,$3);}
		;

par_val2_type1:	OPEN_BR type CLOSE_BR
		;
/*
thread_lib:	THREAD_T thread_var_list |
		THREAD_T thread_var_list
		;

thread_var_list:	thread_variable COMMA thread_var_list |
			thread_variable
			;

thread_variable:	VAR |
			//VAR { get_symbol($1); } EQUAL_TO NUM |
			thread_variable_type1 assign_expr |
			thread_variable_type2 assign_expr |
			VAR array |		
			array VAR EQUAL_TO assign_expr |
			//array VAR { get_symbol($2); } EQUAL_TO block |
			pointer VAR EQUAL_TO assign_expr |
			pointer VAR  
			;

// process var_name =
thread_variable_type1:	VAR EQUAL_TO
			;

// process var_name [] =
thread_variable_type2:	VAR array EQUAL_TO
			;
*/
%%

extern FILE *yyin;


void get_symbol(char var[10])
{
	if (struct_flag || thread_lib_flag)
		return;
    if(flag == 0 || (flag == 1 && extern_flag == 1)) // Global variable entry
	{
	    if (!extern_flag)
	    {
		gsym_tab[global_index].line_number = line_counter;
		gsym_tab[global_index].index = global_index;
		strcpy(gsym_tab[global_index].sym_name,var);
		strcpy(gsym_tab[global_index].access,access);
		strcpy(gsym_tab[global_index].type,data_type);
		printf("\n Access of %s is %s \n line number: %d \nData type:%s",gsym_tab[global_index].sym_name,gsym_tab[global_index].access,gsym_tab[global_index].line_number,gsym_tab[global_index].type);
		global_index++;
	    //extern_flag = 0;
	   }
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

void check_threads()
{
	int i, j;
	for (i = 0; i < thread_index; i++)
	{
		for(j = 0; j < thread_log_index; j++)
		{
			if (thread_log_tab[j].func_index == thread_tab[i].func_index)	
				break;
		}
		if (j == thread_log_index)
		{
			thread_log_tab[thread_log_index].func_index = thread_tab[i].func_index;
			thread_log_index++;
		}		
		else
			find_log_entries(thread_tab[i].func_index, thread_tab[i].index );
	}
}

void find_log_entries(int func_index, int thread_id)
{
	int i;
	int copy_log_index[50], copy_index = 0;
	

	for(i = 0; i < log_index; i++)
	{
		if (log_tab[i].func_index == func_index)
		{
			copy_log_index[copy_index] = i;
			copy_index++;
		}
	}
	update_log_tab(copy_log_index,copy_index, thread_id);
}

void update_log_tab(int copy_log_index[], int copy_index, int thread_id)
{
	int i;
	for (i = 0; i < copy_index; i++)
	{
		log_tab[log_index] = log_tab[copy_log_index[i]];
		log_tab[log_index].thread_index = thread_id;
		log_index++;
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
	else
		printf("\n\n No global variables entry found for given input.");

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
	else
		printf("\n\n No user-defined functions entry found for given input.");
}

void display_local_variables()
{
	int i;
	if (symbol_index != 0)
	{
		printf("\n\n\t\t Symbol Table contains Local Variables \n");
		printf("\n\t %5s %15s %15s %15s %15s %15s","INDEX","ACCESS","NAME","TYPE","FUNC_INDEX","LINE");
		for(i = 0;i < symbol_index; i++)
			printf("\n\t %5d %15s %15s %15s %15d %15d",i,sym_tab[i].access,sym_tab[i].sym_name,sym_tab[i].type,sym_tab[i].func_index,sym_tab[i].line_number);
	}
	else
		printf("\n\n No local variables entry found for given input.");
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
	else
		printf("\n\n No parameters entry found for given input.");
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
	else
		printf("\n\n No thread entry found for given input.");
}

void display_log()
{
	int i;
	if (log_index != 0)
	{
		printf("\n\n\t\t Log Table \n");
		printf("\n\t %5s %15s %15s %15s %15s %15s %15s","INDEX","FUNCTION_NAME","SYMBOL","TYPE","LINE_NUMBER","THREAD_FUNC","THREAD_INDEX");
		for(i = 0;i < log_index; i++)
			printf("\n\t %5d %15s %15s %15s %15d %15d %15d",i,func_tab[log_tab[i].func_index].func_name,log_tab[i].sym_name,log_tab[i].type,log_tab[i].line_number, log_tab[i].thread_func, log_tab[i].thread_index);
	}
	else
		printf("\n\n No log entry found for given input.");
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
	else
		printf("\n\n No semaphore entry found for given input.");
}

void assign_func_index()
{
	int i, j;

	if (thread_index == 0)
	{
		printf("\n\n NO THREAD FUNCTIONS FOUND!!!");
		exit(0);
	}
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
	{
		for(j = 0; j < thread_index; j++)
		{
			if (log_tab[i].func_index == thread_tab[j].func_index)
				{
					log_tab[i].thread_func = 1;
					log_tab[i].thread_index = thread_tab[j].index;
					break;
				}
		}
		if(j == thread_index)
		{
			log_tab[i].thread_func = 0;
			log_tab[i].thread_index = -1;
		}
	}
}


void create_main_thread()
{
	int i;
	
	for (i = 0; i < global_func_index; i++)
		if (strcmp(func_tab[i].func_name,"main") == 0)
		{
			thread_tab[thread_index].index = thread_index;
			strcpy(thread_tab[thread_index].thread_obj,"main");
			strcpy(thread_tab[thread_index].func_name,"main");
			thread_tab[thread_index].func_index = i;
			strcpy(thread_tab[thread_index].thread_attr,"NULL");
			strcpy(thread_tab[thread_index].func_arg,"NULL");
			strcpy(thread_tab[thread_index].parent_thread,"main");
			thread_index++;
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
				if ( (log_tab[j].thread_func) && log_tab[i].thread_index != log_tab[j].thread_index  && strcmp(log_tab[j].type,"Global") == 0 && strcmp(log_tab[i].sym_name,log_tab[j].sym_name) == 0)
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
			    for (k = 0; k < cs_index; k++)
				{
				    if (log_tab[i].line_number == cs_tab[k].critical_location && strcmp(log_tab[i].sym_name,cs_tab[k].critical_obj) == 0)
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
		printf("\n\n\t\t CRITICAL SECTION DETECTED \n");
		//	printf("\n\t %5s %15s %15s %15s","INDEX","CRITICAL_OBJECT","THREAD_FUNC_INDEX","CRITICAL_LOCATION");
		for(i = 0;i < cs_index; i++)
		    printf("\n\t INDEX: %d \n\t Shared Object: %s \n\t Thread Function Index:  %d \n\t Thread Function: %s \n\t Critical Location:  %d \n\n",i,cs_tab[i].critical_obj,cs_tab[i].thread_func_index,thread_tab[cs_tab[i].thread_func_index].func_name,cs_tab[i].critical_location);
	}
	else
		printf("\n\n NO CRITICAL SECTION DETECTED");
}

void display_help()
{
	printf("\n\n NAME \n\t CRITICAL SECTION DETECTION - An application to automatically detect critical section in multithreaded environment.");
	printf("\n\n DISCRIPTION \n\t To design a GCC extension to identify the critical sections in multithreaded programs that lacks synchronization, which currently is not a feature in GCC (GNU Compiler Collection). The idea behind this technique is that compiler will automatically take care of the critical section by introducing Lock and Unlock function calls in a multithreaded program without involvement of the programmer.");

	printf("\n\n COMMAND LINE OPTIONS \n\t\t -h \t --help prints the usage for tool executable and exits.");	
	printf("\n\t\t -a \t prints all tables with critical section(if any).");
	printf("\n\t\t -g \t prints global variable table ");
	printf("\n\t\t -f \t prints function table containing information about user defined functions.");
	printf("\n\t\t -L \t prints log information of variables used in funtions.");
	printf("\n\t\t -l \t printf local variable table.");
	printf("\n\t\t -t \t prints thread tablecontaining thread entries.");
	printf("\n\t\t -c \t prints critical section(if any)");
	printf("\n\t\t -p \t prints paarameter table containing all parameters defined in user defined functions.");
	printf("\n\t\t -s \t prints semaphore table.");
}

int main(int argc, char *argv[])
{
	if (argc < 3)
	{
		printf("\n\n Error while processing command line!!!");
		return(0);
	}
	yyin=fopen(argv[2],"r");
	yyparse();
	
	
	init_cbr_stack(&cbr_stack); // initialize curlybrace stack

	create_main_thread();
	assign_func_index();
	check_thread_entry();
	check_threads();
	cs_check();
	
	if (strcmp(argv[1],"-a") == 0)
	{
		display_global_variables();
		display_function();
		display_local_variables();
		display_func_paramtr();
	
		display_semaphr();
	
		
		display_thread();
		
		display_log();	
		
		display_critical_section();
	}

	else if (strcmp(argv[1],"-g") == 0)	
		display_global_variables();

	else if (strcmp(argv[1],"-f") == 0)
		display_function();
	
	else if (strcmp(argv[1],"-L") == 0)
		display_log();

	else if (strcmp(argv[1],"-l") == 0)
		display_local_variables();
		
	else if (strcmp(argv[1],"-t") == 0)
		display_thread();

	else if (strcmp(argv[1],"-p") == 0)
		display_func_paramtr();
	
	else if (strcmp(argv[1],"-c") == 0)
		display_critical_section();
	
	else if (strcmp(argv[1],"-s") == 0)
		display_semaphr();

	else if (strcmp(argv[1],"-h") == 0)
		display_help();

	else
		printf("\n\n Error in Input!!!");
	
	return 0;
}
