%{
#include<stdio.h>
#include "y.tab.h"

int line_counter = 0;

%}

%%

int|float|char|double|long|short|signed|void|unsigned {strcpy(yylval.arg,yytext); return TYPE;}
extern|static|far|near|typedef  {strcpy(yylval.arg,yytext); return ACCESS;}
[0-9]+?[\.]?[0-9]*       {strcpy(yylval.arg,yytext); return NUM;}
[a-zA-Z][a-zA-Z0-9]*     {strcpy(yylval.arg,yytext); return VAR;}
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

[ \t]  ;
\n  { line_counter++; }
. { yylval.any_arg=yytext[0];printf("-%c-",yytext[0]); return ANYTHING;}

%%

int yywrap()
{
	return 1;
}

int yyerror()
{
	printf("\nError...");
}
