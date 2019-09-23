/* lex scanner for MCL language */

%{
  extern "C"
  {
    int yywrap(void);
    int yylex(void);
  }
  #include <cstdio>
  #include <cstring>
  #include <string>
  #include <cmath>
  #include <cstdlib>
  #include "MCL.h"
  #include "y.tab.h"
  int *arrayy(char*text);
%}

DIGIT    [0-9]
ID       (_)?[a-zA-Z][a-zA-Z0-9]*
array    "{"" "*[0-9]+(" "*","" "*[0-9]+)*" "*"}"

Type     int|matrix
Space    [ \t\n\r]+

Operators "+"|"-"|"*"|"/"|"="

Punctuations "("|")"|"["|"]"|","|";"


Comments \/\*([^*\"]*|\".*\"|\*+[^/]|\")*((\*\/)|(\*\*\/))|\/\/[^\n]*
%%
"print"    {return print;}
"end"      {return exit_command;}

{DIGIT}+    {
            yylval.num=atoi(yytext);
            return number;
            }/*integer*/

{Type}      {
            return yytext[0]=='i'? Int:Matrix;
            }


{array}     {
                yylval.arr=arrayy(yytext);
                return array;
            }
            
{ID}       {
                yylval.id=strdup(yytext);
                return identifier;
            }

{Comments}      ;

{Operators} {
                return yytext[0];
            }


{Space}         ;
{Punctuations}  {return yytext[0];}


.           {printf( "Unrecognized character: %s\n", yytext );exit(-1);}

%%
int yywrap (void) {return 1;}


int *arrayy(char*text)
{
    int*a=(int*)calloc(1024,sizeof(int));
    char* st=&text[1];
    int i,max=strlen(text);
    for(i=1;i<max;i++)
    {
        if(text[i]>='0'&&text[i]<='9') continue;
        else 
        {
            if(text[i]==' ') continue;
            text[i]=0;
            a[0]++;
            a[a[0]]=atoi(st);
            st=&text[i+1];
            if(text[i]==']') break;
        }
    }
    return a;
}