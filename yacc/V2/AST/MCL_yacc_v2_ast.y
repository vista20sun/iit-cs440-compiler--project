%{
	
	#include "MCL.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	void yyerror (char *s);
	extern FILE *yyin; 


	#define NONE 0
	#define INT  1
	#define MAT  2
	#define ARR  3		//array not a type in language, just use to init matrix


	#define TYPE(ID)	(ID->type)


	AST * add (AST* a, AST* b);
	AST * red  (AST* a, AST* b);
	AST * mut  (AST* a, AST* b);
	AST * dvi  (AST* a, AST* b);

	void type__check(AST*a,AST*b);
	void type_check(int a,AST*b);


%}

%union {int num; char* id; matrix* Ma; int* arr;struct ID_V* value; AST* astnode; }
%start line
%token print
%token exit_command

%token Int
%token Matrix

%token <num> number
%token <Ma>	matr
%token <id> identifier
%token <arr> array

%type <astnode> exp exp1 term assignment_list assignment init_i init_m init_list init_li init_lm

%%

line:				   assignment_list ';' 								{ ; }
					|  init_list ';'									{ ; }
					|  exit_command ';' 								{ ;exit(EXIT_SUCCESS); }
					|  print exp ';' 									{ printf("print\n"); }
					|  line assignment_list ';' 						{ ; }
					|  line init_list ';'								{ ; }
					|  line print exp ';' 								{ printf("print\n"); }
					|  line exit_command ';'							{ ;exit(EXIT_SUCCESS); }
;

init_list:			   Matrix init_lm									{ ; }
					|  Int	init_li										{ ; }
;

init_lm:			   init_m											{ ; }
					|  init_m ',' init_lm								{ ; }
;

init_m:				   identifier										{ print_ast(makenode(_id,$1,NULL,NULL)); }
					|  identifier '=' exp								{ print_ast(makenode(_opt,"=",makenode(_id,$1,NULL,NULL),$3)); }
					|  identifier '[' exp ',' exp ']' '=' array			{ print_ast(makenode(_opt,"=",makenode(_idx,"[]",makenode(_id,$1,NULL,NULL),makenode(_pair,"pair",$3,$5)),makenode(_ARRV,NULL,NULL,NULL))); }
;





init_li:			   init_i											{ ; }
					|  init_i ',' init_li								{ ; }
;

init_i:				   identifier										{ print_ast(makenode(_id,$1,NULL,NULL)); }
					|  identifier '=' exp								{ print_ast(makenode(_opt,"=",makenode(_id,$1,NULL,NULL),$3)); }
;

assignment_list:	   assignment										{ ; }
					|  assignment ',' assignment_list					{ ; }
;

assignment:			   identifier '=' exp 								{ print_ast(makenode(_opt,"=",makenode(_id,$1,NULL,NULL),$3)); }
					|  identifier '[' exp ',' exp ']' '=' exp			{ print_ast(makenode(_opt,"=",makenode(_idx,"[]",makenode(_id,$1,NULL,NULL),makenode(_pair,"pair",$3,$5)),$8)); }
;



exp:				   exp1												{ $$ = $1; }
					|  exp '+' exp1										{ $$ = add($1,$3); }
					|  exp '-' exp1										{ $$ = red($1,$3); }
;

exp1:				   term												{ $$ = $1; }
					|  exp1 '*' term									{ $$ = mut($1,$3); }
					|  exp1 '/' term									{ $$ = dvi($1,$3); }
;

term:				   number											{ $$ = makenode(_INTV,(void *)$1,NULL,NULL); }
					|  matr												{ $$ = makenode(_MATV,NULL,NULL,NULL); }
					|  '(' exp ')'										{ $$ = makenode(_opt,"()",NULL,$2); }
					|  identifier										{ $$ = makenode(_id,$1,NULL,NULL); }
					| '-' term											{ $$ = makenode(_opt,"-",NULL,$2); }
					|  identifier '[' exp ',' exp ']'					{ $$ = makenode(_idx,"[]",$1,makenode(_pair,"pair",$3,$5)); }
;




%%



void yyerror (char *s) {fprintf (stderr, "%s\n", s);}

void type__check(AST*a,AST*b)
{
	if(TYPE(a)==TYPE(b))
		return;
	yyerror("type error");
	exit(-1);
}
void type_check(int a,AST*b)
{
	if(a==TYPE(b))
		return;
	yyerror("type error");
	exit(-1);
}


AST * add (AST* a, AST* b)
{
	return makenode(_opt,"+",a,b);
}
AST * red (AST* a, AST* b)
{
	return makenode(_opt,"-",a,b);
}
AST * mut (AST* a, AST* b)
{
	return makenode(_opt,"*",a,b);
}

AST * dvi (AST* a, AST* b)
{
	return makenode(_opt,"/",a,b);
}

int main (int argc,char** argv) 
{
	if(argc<=1)
		printf("#demo for CS440 project\n#matrix identifier should start with\"_\"\n");
	else
		yyin=fopen(argv[1],"r+");
	return yyparse ();
}

/*
gcc MCL.c y.tab.c lex.yy.c -w
*/
