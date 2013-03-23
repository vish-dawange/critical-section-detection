%{
#include<stdio.h>
#include "y.tab.h"

int pre_counter = 1;
int line_counter = 1;
int q_flag = 0;
%}
%x COMMENT SINGLE PREPROCESSOR D_QOUTE
%%

int|float|char|double|long|short|signed|void|unsigned {strcpy(yylval.arg,yytext); return TYPE;}
extern|static|typedef|const  {strcpy(yylval.arg,yytext); return ACCESS;}
struct|union|enum  {strcpy(yylval.arg,yytext); return U_STRUCT;}
pthread_create  return PTHREAD_CREATE;
pthread_join	return PTHREAD_JOIN;
sem_wait	return SEM_WAIT;
sem_post	return SEM_POST;
pthread_mutex_lock return MUTEX_LOCK;
pthread_mutex_unlock return MUTEX_UNLOCK;
pthread_t|sem_t|pthread_mutex_t|pthread_attr_t return THREAD_LIB;
[0-9]+?[\.]?[0-9]*       {strcpy(yylval.arg,yytext); return NUM;}
[a-zA-Z_][a-zA-Z0-9_]*     {strcpy(yylval.arg,yytext); return VAR;}
"(" return OPEN_BR;
")" return CLOSE_BR;
"," return COMMA;
"{" return OPEN_CBR;
"}" return CLOSE_CBR;
"[" return OPEN_SBR;
"]" return CLOSE_SBR;
"*" return STAR;
";" return SEMI;
"=" return EQUAL_TO;
"&" return ADDRESS;
"->" return POINTER_ACCESS;
\"  
{ 
	BEGIN D_QOUTE; 
}
"/*"            {BEGIN COMMENT;}
"//"            {BEGIN SINGLE;}
"#"		{BEGIN PREPROCESSOR;}

<D_QOUTE>\"    	
		{ 
			BEGIN 0;
		}
<D_QOUTE>[.\n]*		{}

<COMMENT>.       	;
<COMMENT>[\n]          	{ 	line_counter++;	}
<COMMENT>"*/"          	{       BEGIN 0;	}
<SINGLE>.*             	;
<SINGLE>\n             	{ 	line_counter++; BEGIN 0;}

<PREPROCESSOR>.+	{ 	
				
				BEGIN 0;
				pre_counter++;
				strcpy(yylval.arg,yytext); 
				return PREPRO;
			}

[ \t]  ;

\n  { line_counter++; }
. { yylval.any_arg = yytext[0];  }

%%

int yywrap()
{
        return 1;
}

int yyerror()
{
        printf("\nError...:%s \t Line no:%d",yytext,line_counter);
}
