
*** CRITICAL SECTION DETECTION ***

This repository contains code which help to detect critical section 
in C program. 


Primarily it is in lexical analysing stage which separates token 
in C program and generates different tables like symbol table, function
table, etc.

*** HOW TO RUN

1) Run lex file func.l
   - $ lex func.l
2) Run yacc file func.y
   - $ yacc func.y
3) $ gcc lex.yy.c y.tab.c
4) $ ./a.out