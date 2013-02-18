%{
#include<stdio.h>
#include<string.h>
#include "common.h"

extern int line_counter; // input program line counter
int flag=0; // check for block entries
int global_index=0, func_index=0, symbol_index=0, par_index=0; //table index
char data_type[20]; // c data type
char access[20]; // access specifier (static,extern,typedef,etc.)

global_symbol gsym_tab[50]; // Global variable Entries
func_def func_tab[50]; // user defined function entries

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

start: 	stmnt start |
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
						global_index++;
					}
				} 
	//preprocess_stmnt
	;

//preprocess_stmnt:	HASH any {printf("matched hash...");}
//			;

// pattern match for variable declaration
declarative_stmnt:	type var_list 
			;

// pattern match for one or more varibles
var_list:	variable COMMA {global_index++;} var_list|
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
			}
			else // Local variable entry
			{
				func_tab[func_index-1].sym_tab[symbol_index].index = symbol_index;
				strcpy(func_tab[func_index-1].sym_tab[symbol_index].sym_name,$1);
				strcpy(func_tab[func_index-1].sym_tab[symbol_index].type,data_type);
				func_tab[func_index-1].sym_tab[symbol_index].line_number = line_counter;
				printf("\n\n\t Local variables\n index: %d \t type: %s \t name: %s \t line_number: %d",func_tab[func_index-1].sym_tab[symbol_index].index,func_tab[func_index-1].sym_tab[symbol_index].type,func_tab[func_index-1].sym_tab[symbol_index].sym_name,func_tab[func_index-1].sym_tab[symbol_index].line_number);
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
			}
			else // Local variable entry with default value
			{
				func_tab[func_index-1].sym_tab[symbol_index].index = symbol_index;
				strcpy(func_tab[func_index-1].sym_tab[symbol_index].sym_name,$1);
				strcpy(func_tab[func_index-1].sym_tab[symbol_index].type,data_type);
				func_tab[func_index-1].sym_tab[symbol_index].line_number = line_counter;
				printf("\n\n\t Local variables\n index: %d \t type: %s \t name: %s \t line_number: %d",func_tab[func_index-1].sym_tab[symbol_index].index,func_tab[func_index-1].sym_tab[symbol_index].type,func_tab[func_index-1].sym_tab[symbol_index].sym_name,func_tab[func_index-1].sym_tab[symbol_index].line_number);
				symbol_index++;
			}
		    } EQUAL_TO operand;

// pattern match for function statement
func_stmnt: func_prototype {
				// Make entry function into func_table
				printf("\n Correct Function Declaration");
				
				func_tab[func_index].index=func_index;
				func_tab[func_index].line_number = line_counter;
				func_tab[func_index].no_of_parameter = par_index + 1;
				func_tab[func_index].no_of_symbols = symbol_index + 1;
				printf("\n\n\tFunction Table\n \tIndex \t line_number \t name \t return_type \t no_of_par \t No_of_sym");
				printf("\n\t %d \t %d \t %s \t %s \t %d \t %d",func_tab[func_index].index,func_tab[func_index].line_number,func_tab[func_index].func_name,func_tab[func_index].return_type,func_tab[func_index].no_of_parameter,func_tab[func_index].no_of_symbols);				
				func_index++;
				par_index = 0;
				symbol_index = 0;
			    } block 
	;

// pattern match for function prototype
func_prototype: type VAR {
				// pattern match return type and function name
				strcpy(func_tab[func_index].return_type,data_type);
				strcpy(func_tab[func_index].func_name,$2);
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
							func_tab[func_index].par[par_index].index=par_index;
							strcpy(func_tab[func_index].par[par_index].type,data_type);
							strcpy(func_tab[func_index].par[par_index].par_name,$3);
							printf("\n\n\t Function Parameter\n index: %d \t type: %s \t name: %s",func_tab[func_index].par[par_index].index,func_tab[func_index].par[par_index].type,func_tab[func_index].par[par_index].par_name);
						     }
		;

// pattern match for block entry
block:	OPEN_CBR {flag=1;} code CLOSE_CBR {flag=0;}|
	OPEN_CBR CLOSE_CBR
	;

// pattern match for other c code
code:	any code|
	any
	;

any: 	stmnt|
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


int main()
{
	yyin=fopen("sample.c","r");
	yyparse();
	return 0;
}
