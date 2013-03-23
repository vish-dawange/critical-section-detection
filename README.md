
*** CRITICAL SECTION DETECTION ***

This repository contains code which help to detect critical section 
in multithreaded C programs. 


Tool focuses on detecting bugs which are notoriously difficult to find.
Basic idea for detecting critical region is to parse C source code. And
based on the information extracted from C file tool will generate output 
and will provide suggestions for adding synchronization mechanism.

*** OPTIONS ***

		-h 	 --help prints the usage for tool executable and exits.
		-a 	 prints all tables with critical section(if any).
		-g 	 prints global variable table 
		-f 	 prints function table containing information about user defined functions.
		-L 	 prints log information of variables used in funtions.
		-l 	 printf local variable table.
		-t 	 prints thread tablecontaining thread entries.
		-c 	 prints critical section(if any)
		-p 	 prints paarameter table containing all parameters defined in user defined functions.
		-s 	 prints semaphore table.
		-m 	 prints mutex table.
		-C 	 prints Critical Section Region.
		-T 	 prints function call trace.

*** HOW TO RUN ***

1) Run lex file main.l
   - $ lex main.l
   
2) Run yacc file main.y	
   - $ yacc main.y

3) $ gcc lex.yy.c y.tab.c -o cscheck.out

4) $ ./cscheck.out -a sample_file.c
