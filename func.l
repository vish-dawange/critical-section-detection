%{
#include<stdio.h>
#include "y.tab.h"

int line_counter = 0;

%}
%x COMMENT SINGLE PREPROCESSOR
%%

int|float|char|double|long|short|signed|void|unsigned {strcpy(yylval.arg,yytext); return TYPE;}
extern|static|typedef  {strcpy(yylval.arg,yytext); return ACCESS;}
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
"/*"           	{BEGIN COMMENT;}
"//"           	{BEGIN SINGLE;}
"#"		{BEGIN PREPROCESSOR;}
<COMMENT>[.|\n]*       {
                         printf("\n%s",yytext);         
                       }
<COMMENT>"*/"          {        BEGIN 0;
                       }  
<SINGLE>.*             {
                         printf("\n%s",yytext);         
                       }
<SINGLE>\n             {BEGIN 0;}

<PREPROCESSOR>\n	{BEGIN 0;}
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
