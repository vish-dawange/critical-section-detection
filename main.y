/****************************************************************************************
 *	Yacc file contains grammar constructed by combining tokens defined in		*
 *	lex file.									*
 *											*
 *	Grammar contains four important things: Declarative statement, function		*
 *	statement, user definition and preprocessors. Declarative statements		*
 *	will handle all global and local declarations. function statements handles	*
 *	user-defined function blocks. User definitions will be ignored. Preprocessors	*
 *	will help to extract user defined headers and user-defined headers will be	*
 *	as input to parser.								*
 *											*
 *	Useless code will be ignored by the grammar.					*
*****************************************************************************************/

%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include "util.c"
%}

%union
{
 char arg[50];
 char any_arg;
}

//define tokens which will help to match patterns
%token MAIN OPEN_BR CLOSE_BR OPEN_CBR CLOSE_CBR OPEN_SBR CLOSE_SBR STAR COMMA SEMI EQUAL_TO PTHREAD_CREATE ADDRESS SEM_WAIT SEM_POST U_STRUCT POINTER_ACCESS THREAD_LIB MUTEX_LOCK MUTEX_UNLOCK PTHREAD_JOIN
%token <arg>  VAR NUM ACCESS TYPE PREPRO
%token <any_arg> ANYTHING
%type <arg> par_val1 par_val2 thread_creation sem_var mutex_var
%nonassoc high_priority
%%

/* Start of Grammar with recursive statement */
start:	stmnt start |
	stmnt
	;

// Process C statements (Grammar-1)
stmnt:	PREPRO { process_header($1); } |
	user_defination |
	declarative_stmnt SEMI |
	func_stmnt
	;


// Process user defined strutures like struct, enum, union
user_defination:	user_def_type1 SEMI {struct_flag = 0;} |
			user_def_type1 multi_var SEMI {struct_flag = 0;} |
			user_def_type2 SEMI {struct_flag = 0;} |
			user_def_type2 multi_var SEMI {struct_flag = 0;} |
			U_STRUCT {struct_flag = 1;} block multi_var SEMI {struct_flag = 0;} |
			ACCESS U_STRUCT {struct_flag = 1;} block multi_var SEMI {struct_flag = 0;} //|
			;

// Process : struct/union/enum struct_name {/* declarations */}
user_def_type1 :	u_struct {struct_flag = 1;} block
			;

// Process : typedef struct/union/enum struct_name {/* declarations */}
user_def_type2 :	ACCESS U_STRUCT VAR {struct_flag = 1;} block
			;

// Process : struct/union/enum struct_name
u_struct :              U_STRUCT VAR { strcpy(data_type,$2);}
			;

// Process variable declarations at end of structure block
multi_var:	VAR |
		VAR COMMA multi_var
		;


// pattern match for variable declaration
declarative_stmnt:	type var_list |//{printf("\ncorrect variable declaration...");} |
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
				//printf("\n Correct type \t line No. :%d",line_counter);
			   } |
		{strcpy(data_type," ");} type_def {
							strcpy(access,"Default");
							//printf("\n Correct type \t line No. :%d",line_counter);
						   }

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
		variable_type1 |
		variable_type2 |
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
func_stmnt:	func_prototype SEMI {par_index = par_index - par_counter;} |//printf("\n Correct Function prototype Declaration");} |
		func_prototype {

				// Make entry function into func_table
				//printf("\n Correct Function Declaration");

				func_tab[global_func_index].index = global_func_index;
				func_tab[global_func_index].line_number = line_counter;
				func_tab[global_func_index].no_of_parameter = par_counter;

				global_func_index++;

			    } block
	;


// pattern match for function prototype
func_prototype: type VAR {
				// pattern match return type and function name
				strcpy(func_tab[global_func_index].return_type,data_type);
				strcpy(func_tab[global_func_index].func_name,$2);
				//printf("\n Correct Function prototype");
				par_counter = 0;
		} bracket //{printf("\n Correct Function prototype");}
		;

// process function parameters
bracket:	OPEN_BR  par CLOSE_BR |
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
							get_parameter($2);
						} |
			parameter_type2
			;

// process built in data types
parameter_type2:	{strcpy(data_type,"");} type
	;

// process structure parameters to the function
utype_par:      utype_par_type1 |
		utype_par_type1 array |
		u_struct array VAR {get_parameter($3);} |
		u_struct pointer VAR {get_parameter($3);}
		;

// process struct/union/enum struct_name var_name
utype_par_type1:	u_struct VAR {get_parameter($2);}
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
		get_log_entry($1);
		//printf("\n Variable: %s:",$1);
	    }|
	any_type1 |
	CLOSE_BR|
	OPEN_SBR|
	CLOSE_SBR|
	any_type1 type CLOSE_BR |
	any_type1 u_struct pointer CLOSE_BR |
	STAR |
	COMMA |
	SEMI |
	POINTER_ACCESS |
	EQUAL_TO |
	thread_creation |
	thread_join |
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
				} CLOSE_BR SEMI  |
	MUTEX_LOCK OPEN_BR mutex_var	{
						mutex_tab[mutex_index].index = mutex_index;
						mutex_tab[mutex_index].mutex_lock_point = line_counter;
						strcpy(mutex_tab[mutex_index].mutex_obj,$3);
						mutex_index++;
					} CLOSE_BR SEMI |
	MUTEX_UNLOCK OPEN_BR mutex_var	{
						for (i = 0; i < mutex_index; i++)
							if (strcmp(mutex_tab[i].mutex_obj,$3) == 0)
								mutex_tab[i].mutex_unlock_point = line_counter;
					} CLOSE_BR SEMI
	;

any_type1:	OPEN_BR
		;

// process any code that will appear in assignment expression
any_expr:
	NUM |
	VAR {
		get_log_entry($1);
    //printf("\n Variable: %s:",$1);
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
	thread_join |
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
				} CLOSE_BR SEMI |
	MUTEX_LOCK OPEN_BR mutex_var	{
						mutex_tab[mutex_index].index = mutex_index;
						mutex_tab[mutex_index].mutex_lock_point = line_counter;
						strcpy(mutex_tab[mutex_index].mutex_obj,$3);
						mutex_index++;
					} CLOSE_BR SEMI |
	MUTEX_UNLOCK OPEN_BR mutex_var	{
						for (i = 0; i < mutex_index; i++)
							if (strcmp(mutex_tab[i].mutex_obj,$3) == 0)
								mutex_tab[i].mutex_unlock_point = line_counter;
					} CLOSE_BR SEMI
	;

// process semaphore parameters
sem_var:	ADDRESS	VAR { strcpy($$,$2); } |
		VAR { strcpy($$,$1); }
// |
//		ADDRESS VAR { strcpy($$,$2); } OPEN_SBR VAR CLOSE_SBR
		;

// process mutex parameters
mutex_var:	ADDRESS	VAR { strcpy($$,$2); } |
		VAR { strcpy($$,$1); }
		;

// pattern match for pthread_create
thread_creation : thread_creation_type1 COMMA par_val1 COMMA VAR {		//printf(" pointing to function %s",$5);
										thread_tab[thread_index].index = thread_index;

										strcpy(thread_tab[thread_index].func_name,$5);
										strcpy(thread_tab[thread_index].parent_thread,func_tab[func_index-1].func_name);

									} COMMA  par_val2 CLOSE_BR  {printf("\ncorrect thread....line_number:%d",line_counter);
													thread_index++;} |
		thread_creation_type1 array COMMA par_val1 COMMA VAR { //printf(" pointing to function %s",$6);
										thread_tab[thread_index].index = thread_index;

										strcpy(thread_tab[thread_index].func_name,$6);
										strcpy(thread_tab[thread_index].parent_thread,func_tab[func_index-1].func_name);

									} COMMA  par_val2 CLOSE_BR  {printf("\ncorrect thread....line_number:%d",line_counter);
													thread_index++;}
		;

thread_join:	thread_join_type1 VAR CLOSE_BR |
		thread_join_type1 ADDRESS VAR CLOSE_BR
		;

thread_join_type1:	PTHREAD_JOIN OPEN_BR VAR COMMA { find_join_obj($3); }
			;

// process: pthread_create ( & thread_object )
thread_creation_type1:	PTHREAD_CREATE OPEN_BR ADDRESS VAR	{
									//printf("\n thread object %s ",$4);
									strcpy(thread_tab[thread_index].thread_obj, $4);
									thread_tab[thread_index].line_number = line_counter;
								}
			;

par_val1:	ADDRESS VAR	{
					//printf("\n Thread attribute: %s",$2);
					strcpy(thread_tab[thread_index].thread_attr,$2);
				} |
		VAR { strcpy(thread_tab[thread_index].thread_attr,$1); }
		;

par_val2:	VAR {//printf("\n Thread function parameter : %s",$1);
			strcpy(thread_tab[thread_index].func_arg,$1);} |
		par_val2_type1 VAR {//printf("\n Thread function parameter : %s",$2);
					strcpy(thread_tab[thread_index].func_arg,$2);} |
		par_val2_type1 ADDRESS VAR {//printf("\n Thread function parameter : %s",$3);
						strcpy(thread_tab[thread_index].func_arg,$3);}
		;

par_val2_type1:	OPEN_BR type CLOSE_BR
		;
%%

extern FILE *yyin;



int main(int argc, char *argv[])
{
	char * hdr_source, *source_path, *hdr_element;
	int i;
	char *source_file;

	printf("CRITICAL SECTION DETECTION(V 1.0) \t\t\t\t\t\t\t\t\t\tCRITICAL SECTION DETECTION(V 1.0)");

	if (strcmp(argv[1],"-h") == 0)
	{
		system("clear");
		display_help();
		return(0);
	}

	if (argc < 3)
	{
		printf("\n\n Error while processing command line!!!");
		return(0);
	}


	source_path = hdr_source = hdr_element = (char *)malloc(50 * sizeof(char));
	source_path = argv[2];

	init_cbr_stack(&cbr_stack); // initialize curlybrace stack

	yyin=fopen(argv[2],"r");
	yyparse();
	source_file = (char *)calloc(sizeof(char),strlen(argv[2])+1);
	strcpy(source_file,argv[2]);
	extract_archieve(source_path);

	for (i = 0; i < hdr_index; i++)
	{


		strcpy(hdr_source, source_path);
		hdr_element = headers[i];
		strcat(hdr_source,hdr_element);

		yyin = fopen(hdr_source,"r");
		yyparse();
	}

	
	create_main_thread();
	assign_func_index();
	check_thread_entry();
	check_threads();
	process_func_call();
	cs_check();
	system("clear");

	if (strcmp(argv[1],"-a") == 0)
	{
		display_global_variables();
		display_function();
		display_local_variables();
		getchar();
		display_func_paramtr();
		display_semaphr();
		display_mutex();
		getchar();
		display_thread();

		display_log();

		if(display_critical_section()) {
			create_cs_log();
			add_lock_unlock(source_file,pre_counter);
		}
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
	{
		display_critical_section();
		create_cs_log();
		add_lock_unlock(source_file,pre_counter);
	}
	else if (strcmp(argv[1],"-s") == 0)
		display_semaphr();

	else if (strcmp(argv[1],"-h") == 0)
		display_help();

	else if (strcmp(argv[1],"-m") == 0)
		display_mutex();

	else if (strcmp(argv[1],"-C") == 0)
		add_lock_unlock(argv[2],pre_counter);
	
	else if (strcmp(argv[1],"-T") == 0)
		display_call_trace();
	else
		printf("\n\n Error in Input!!!");

	return 0;
}
