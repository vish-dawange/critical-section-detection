%{
#include<stdio.h>
#include "y.tab.h"

int line_counter = 1;
int q_flag = 0;
%}
%x COMMENT SINGLE PREPROCESSOR D_QOUTE
%%

int|float|char|double|long|short|signed|void|unsigned {strcpy(yylval.arg,yytext); return TYPE;}
extern|static|typedef  {strcpy(yylval.arg,yytext); return ACCESS;}
struct|union|enum  {strcpy(yylval.arg,yytext); return U_STRUCT;}
pthread_create  return PTHREAD_CREATE;
sem_wait	return SEM_WAIT;
sem_post	return SEM_POST;
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
\"  {

                BEGIN D_QOUTE;

    }
"/*"            {BEGIN COMMENT;}
"//"            {BEGIN SINGLE;}
"#"		{BEGIN PREPROCESSOR;}

<D_QOUTE>\"  { BEGIN 0;}
<D_QOUTE>[.\n]*   {}

<COMMENT>.       {
                         printf("%s",yytext);
                       }
<COMMENT>[\n]          { line_counter++;}
<COMMENT>"*/"          {        BEGIN 0;
                       }
<SINGLE>.*             {
                         printf("%s",yytext);
                       }
<SINGLE>\n             {line_counter++; BEGIN 0;}

<PREPROCESSOR>\n	{line_counter++; BEGIN 0;}
[ \t]  ;

\n  { line_counter++; }
. { yylval.any_arg=yytext[0];printf("-%c-",yytext[0]);}

%%

int yywrap()
{
        return 1;
}

int yyerror()
{
        printf("\nError...:%s \t Line no:%d",yytext,line_counter);
}
