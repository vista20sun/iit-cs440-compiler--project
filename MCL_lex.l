/* lex scanner for MCL language */

%{
#include <stdio.h>
#include <math.h>
%}

DIGIT    [0-9]
ID       [a-zA-Z][a-zA-Z0-9]*

IFC      _row_|_colum_|_printm_
Type     int|real|matrix
Condition	if|else|return|def|for|Null
Space    [ \t\n\r]+

Operators "+"|"-"|"*"|"/"|"="|"^"
matrixopt ".*"|"./"
boolopt	  "=="|"!="|"&&"|"||"|"<"|">"|"<="|">="

Punctuations "("|")"|"{"|"}"|"["|"]"|":"|","|";"

Comments \/\*([^*\"]*|\".*\"|\*+[^/]|\")*((\*\/)|(\*\*\/))|\/\/[^\n]*
%%

{DIGIT}+    {
            printf( "An integer: %s (%d)\n", yytext, atoi( yytext ) );
            fprintf(yyout,"int %d\n",atoi(yytext));
            }/*integer*/

{DIGIT}+"."{DIGIT}*        {
            printf( "A real: %s (%g)\n", yytext, atof( yytext ) );
            fprintf(yyout,"real %g\n",atof( yytext ));
            }/*real number*/

{Condition}|{Type}       {
            printf( "A keyword: %s\n", yytext );
            fprintf(yyout,"key %s\n",yytext);
            }


{IFC}       {
                printf( "An inner function %s\n",yytext);
                fprintf(yyout,"inner %s\n",yytext);
            }

{ID}        {
                printf( "An identifier: %s\n", yytext );
                fprintf(yyout,"ID %s\n",yytext);
            }

{Comments}  {
                printf( "A comment: %s\n",yytext);
            }

{Operators}|{matrixopt}|{boolopt} {
                printf( "An operator: %s\n", yytext );
                fprintf(yyout,"OPS %s\n",yytext);
            }

{Punctuations}	{
                printf( "A punctuation: %s\n", yytext );
                fprintf(yyout,"punctuation %s\n",yytext);
            }

"{"[^}\n]*"}"

{Space}         printf("Space\n");


.           printf( "Unrecognized character: %s\n", yytext );

%%

int main( int argc, char **argv )
{
    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 )
            yyin = fopen( argv[0], "r" );
    else
            yyin = stdin;
    FILE* fpo=fopen("lexout.txt","w");
    yyout=fpo;
    yylex();
}
