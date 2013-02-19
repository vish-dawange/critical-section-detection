%{
#include<stdio.h>
#include<string.h>
#include "common.h"

extern int line_counter; // input program line counter
int flag=0; // check for block entries
int global_index=0, func_index=0, symbol_index = 0, par_index=0; //table index
char data_type[20]; // c data type
char access[20]; // access specifier (static,extern,typedef,etc.)
int in_func_flag=0,in_func_stmt_flag=0;
global_symbol gsym_tab[50]; // Global variable Entries
func_def func_tab[50]; // user defined function entries
symbol_table sym_tab[50];
parameter par[50];
int global_func_index=0,par_func=0;
%}

%union
{
 char arg[10];
 char any_arg;
}

%token MAIN OPEN_BR CLOSE_BR OPEN_CBR CLOSE_CBR OPEN_SBR CLOSE_SBR STAR COMMA SEMI EQUAL_TO 
%token <arg>  VAR NUM ACCESS TYPE 
%token <any_arg> ANYTHING

%%

start: 	stmnt start {printf("\n corrrect program with multiple statements");}|
	stmnt {printf("\n Correct program");}
	;

// Process c statements
stmnt: 	func_stmnt |
	declarative_stmnt SEMI 	{	
					// Check for local/global variable
					if(flag==1) printf("\n Local Variable"); 
					else 
					{
						printf("\n Correct Global Declaration");
					}
				} 
	//preprocess_stmnt
	;

//preprocess_stmnt:	HASH any {printf("matched hash...");}
//			;

// pattern match for variable declaration
declarative_stmnt:	type var_list {printf("\ncorrect variable declaration");}
			;

// pattern match for one or more varibles
var_list:	variable COMMA var_list|
		variable
		;

// make entry of variable based on block entries or global entries
variable:	VAR {
			if(flag==0) // Global variable entry
			{
				gsym_tab[global_index].line_number = line_counter;
				gsym_tab[global_index].index = global_index;
				strcpy(gsym_tab[global_index].sym_name,$1);
				strcpy(gsym_tab[global_index].access,access);
				strcpy(gsym_tab[global_index].type,data_type);
				printf("\n Access of %s is %s \n line number: %d \nData type:%s",gsym_tab[global_index].sym_name,gsym_tab[global_index].access,gsym_tab[global_index].line_number,gsym_tab[global_index].type);
				global_index++;
			}
			else // Local variable entry
			{
				
				sym_tab[symbol_index].func_index = func_index-1;
				strcpy(sym_tab[symbol_index].sym_name,$1);
				strcpy(sym_tab[symbol_index].type,data_type);
				sym_tab[symbol_index].line_number = line_counter;
				
				symbol_index++; 
			}
		    }|
		VAR {
			if(flag==0) // Global variable entry with default value
			{
				gsym_tab[global_index].line_number = line_counter;
				gsym_tab[global_index].index = global_index;
				strcpy(gsym_tab[global_index].sym_name,$1);
				strcpy(gsym_tab[global_index].access,access);
				strcpy(gsym_tab[global_index].type,data_type);
				printf("\n Access of %s is %s \n line number: %d \n data type:%s",gsym_tab[global_index].sym_name,gsym_tab[global_index].access,gsym_tab[global_index].line_number,gsym_tab[global_index].type);
				global_index++;
			}
			else // Local variable entry with default value
			{
				sym_tab[symbol_index].func_index = func_index-1;
				
				strcpy(sym_tab[symbol_index].sym_name,$1);
				strcpy(sym_tab[symbol_index].type,data_type);
				sym_tab[symbol_index].line_number = line_counter;
				symbol_index++;
			}
		    } EQUAL_TO operand;

// pattern match for function statement
func_stmnt: func_prototype {
				
				// Make entry function into func_table
				printf("\n Correct Function Declaration");
				
				func_tab[global_func_index].index=global_func_index;
				func_tab[global_func_index].line_number = line_counter;
				func_tab[global_func_index].no_of_parameter = par_index + 1;
				
				global_func_index++;
				printf("\n********** global_func_index %d",global_func_index);
				
			    } block 
	;

// pattern match for function prototype
func_prototype: type VAR {
				// pattern match return type and function name
				strcpy(func_tab[global_func_index].return_type,data_type);
				strcpy(func_tab[global_func_index].func_name,$2);
			} OPEN_BR par CLOSE_BR {printf("\n Correct Function prototype");}
		;

// pattern match for c data type
type: 	ACCESS {
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
type_def:TYPE type_def |
	 TYPE pointer |
	 TYPE array |
	 TYPE pointer array |
	 TYPE {strcat(data_type,$1);} 
	 ;

// pattern match for pointer
pointer: STAR pointer|
	 STAR
	 ;

// pattern match for array
array: 	OPEN_SBR operand CLOSE_SBR |
	OPEN_SBR CLOSE_SBR array |
	OPEN_SBR CLOSE_SBR
	;

operand:NUM|VAR  
	;

// pattern match for function parameters
par: 	parameter COMMA {par_index++;} par|
     	parameter
	;

// pattern match for parameter entry
parameter:	{strcpy(data_type,"");} type_def VAR {
							par[par_index].func_index=global_func_index;
							strcpy(par[par_index].type,data_type);
							strcpy(par[par_index].par_name,$3);
							printf("\n\t\t %s \t %s \t %d",par[par_index].par_name,par[par_index].type,par[par_index].func_index);	
						     }
		;

// pattern match for block entry
block:	OPEN_CBR
		{
			if(flag)
			{
				in_func_flag=1;
				par_func = func_index;
				
			}	
			func_index = global_func_index;
			flag=1;
		} 
	code CLOSE_CBR 
		{	
			if(!in_func_flag)
				flag=0;
			else
			{
				in_func_flag=0;		
				func_index = par_func;
			}
		}|
	OPEN_CBR CLOSE_CBR
	;

// pattern match for other c code
code:	any code|
	any
	;

any: 	stmnt |
	ANYTHING |
	operand |
	block |
	OPEN_BR |
	CLOSE_BR|
	OPEN_SBR|
	CLOSE_SBR|
	STAR |
	COMMA |
	SEMI |
	EQUAL_TO
	;
%%

extern FILE *yyin;

void display_global_variables()
{
	int i;
	printf("\n\n\t\t Symbol Table contains Global entries\n");
	printf("\n\t INDEX \t ACCESS \t NAME \t TYPE \t LINE");
	for(i = 0; i < global_index; i++)
		printf("\n\t %d \t %s \t %s \t %s \t %d",gsym_tab[i].index,gsym_tab[i].access,gsym_tab[i].sym_name,gsym_tab[i].type,gsym_tab[i].line_number);

}

void display_function()
{
	int i;
	printf("\n\n\t\t Function Table contains User defined functions\n");
	printf("\n\t INDEX \t LINE \t NAME \t RET_TYPE \t PARMTRS \t SYMBOLS");
	for(i = 0; i < global_func_index; i++)
		printf("\n\t %d \t %d \t %s \t %s \t\t %d \t\t %d",func_tab[i].index,func_tab[i].line_number,func_tab[i].func_name,func_tab[i].return_type,func_tab[i].no_of_parameter,func_tab[i].no_of_symbols);
}

display_local_variables()
{
	int j;
	printf("\n\n\t\t Symbol Table contains Local Variables \n");
	printf("\n\t INDEX \t NAME \t TYPE \t FUNC_INDEX \t LINE");
	for(j = 0;j < symbol_index; j++)
		printf("\n\t %d \t %s \t %s \t %d \t%d",j,sym_tab[j].sym_name,sym_tab[j].type,sym_tab[j].func_index,sym_tab[j].line_number);
}

void display_func_paramtr()
{
	int i;
	printf("\n\n\t\t Symbol Table contains Parameters of function \n");
	printf("\n\t INDEX \t NAME \t TYPE \t FUNC_INDEX");
	for(i = 0;i < par_index; i++)
		printf("\n\t %d \t %s \t %s \t %d",i,par[i].par_name,par[i].type,par[i].func_index);	
}

int main()
{
	yyin=fopen("sample.c","r");
	yyparse();
	display_global_variables();
	display_function();
	display_local_variables();
	display_func_paramtr();
	return 0;
}
