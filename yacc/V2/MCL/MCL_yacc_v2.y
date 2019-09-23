%{
	
	#include "MCL.h"
	#include <cstdio>
	#include <cstdlib>
	#include <cstring>
	#include <unordered_map>
	#include <string>
	using namespace std;
	using namespace __gnu_cxx;
	//define type:
		extern "C"
	{
		void yyerror (char *s);
		extern int yylex(void);
		extern FILE *yyin;  

	}

	#define NONE 0
	#define INT  1
	#define MAT  2
	#define ARR  3		//array not a type in language, just use to init matrix

	#define TYPE(ID)	(ID->type>0?ID->type:-ID->type)
	#define TEMP(ID)	(ID->t>0)
	#define INTV(ID)	(ID->val)
	#define MATV(ID)	(ID->var)

	struct ID_V
	{
		ID_V(int type,char* id=NULL,int v=0, matrix *m=NULL,int temp=0);
		~ID_V();
		int type;
		char *id;
		int val;
		int t;
		matrix *var;
	} ;

	typedef unordered_map<string,ID_V*> STable;
	typedef pair<string,ID_V*> Pair;
	STable *stable;

	ID_V *temp_[1024]={0};

	matrix* ma_init(int r,int c,int*arr);
	matrix* ma_init(ID_V* r,ID_V* c,int*arr);
	matrix* ma_mui(matrix* a, int x);
	matrix* ma_dii(matrix* a, int x);
	matrix* ma_mu(matrix* a,matrix* b);
	matrix* ma_add(matrix* a,matrix* b);
	matrix* ma_red(matrix* a,matrix* b);

	ID_V * add (ID_V* a, ID_V* b);
	ID_V * red (ID_V* a, ID_V* b);
	ID_V * mut (ID_V* a, ID_V* b);
	ID_V * dvi (ID_V* a, ID_V* b);
	ID_V * rev (ID_V* a);

	ID_V * symbolVal (char * id);
	void updateSymbolVal(char * id, ID_V* temp);
	void updateSymbolVal (ID_V* idv,ID_V* src);
	void newSymbolVal(char * id, int type, ID_V* temp);

	ID_V * temp_val(int type, int val,matrix *v);
	void type_check(ID_V*a,ID_V*b);
	void type_check(int a,ID_V*b);

	void printv(ID_V* v);
	
	int getIntInMatrix(char* src,ID_V* r, ID_V* c);
	void setIntInMatrix(char* src,ID_V* r, ID_V* c,ID_V* ne);

	void clean();
	void mat_inited(ID_V* v);

%}

%union {int num; char* id; matrix* Ma; int* arr;struct ID_V* value; }
%start line
%token print
%token exit_command

%token Int
%token Matrix

%token <num> number
%token <Ma>	matr
%token <id> identifier
%token <arr> array


%type  <value> exp exp1 term 
%type  <id>  assignment_list assignment init_i init_m init_list init_li init_lm

%%

line:				   assignment_list ';' 								{ ; }
					|  init_list ';'									{ ; }
					|  exit_command ';' 								{ clean();exit(EXIT_SUCCESS); }
					|  print exp ';' 									{ printv($2); }
					|  line assignment_list ';' 						{ ; }
					|  line init_list ';'								{ ; }
					|  line print exp ';' 								{ printv($3); }
					|  line exit_command ';'							{ clean();exit(EXIT_SUCCESS); }
;

init_list:			   Matrix init_lm									{ ; }
					|  Int	init_li										{ ; }
;

init_lm:			   init_m											{ ; }
					|  init_m ',' init_lm								{ ; }
;

init_m:				   identifier										{ newSymbolVal($1,MAT,temp_val(MAT,0,0));free($1); }
					|  identifier '=' exp								{ newSymbolVal($1,MAT,$3);free($1); }
					|  identifier '[' exp ',' exp ']' '=' array			{ newSymbolVal($1,MAT,temp_val(MAT,0,ma_init($3,$5,$8)));free($1); }
;

init_li:			   init_i											{ ; }
					|  init_i ',' init_li								{ ; }
;

init_i:				   identifier										{ newSymbolVal($1,INT,temp_val(INT,0,0));free($1); }
					|  identifier '=' exp								{ newSymbolVal($1,INT,$3);free($1); }
;

assignment_list:	   assignment										{ ; }
					|  assignment ',' assignment_list					{ ; }
;

assignment:			   identifier '=' exp 								{ updateSymbolVal($1,$3);free($1); }
					|  identifier '[' exp ',' exp ']' '=' exp			{ setIntInMatrix($1,$3,$5,$8);free($1); }
;


exp:				   exp1												{ $$ = $1; }
					|  exp '+' exp1										{ $$ = add($1,$3); }
					|  exp '-' exp1										{ $$ = red($1,$3); }
;

exp1:				   term												{ $$ = $1; }
					|  exp1 '*' term									{ $$ = mut($1,$3); }
					|  exp1 '/' term									{ $$ = dvi($1,$3); }
;

term:				   number											{ $$ = temp_val(INT,$1,0); }
					|  matr												{ $$ = temp_val(MAT,0,$1); }
					|  '(' exp ')'										{ $$ = $2; }
					|  identifier										{ $$ = symbolVal($1);free($1); }
					| '-' term											{ $$ = rev($2); }
					|  identifier '[' exp ',' exp ']'					{ $$ = temp_val(INT,getIntInMatrix($1,$3,$5),0);free($1); }
;




%%

void clean()
{
	for(STable::iterator iter=stable->begin();iter!=stable->end();iter++)
	{
		ID_V*t=iter->second;
		delete t;
	}
	delete stable;
	for(int i=0;i<1024;i++)
	{
		if(temp_[i]!=NULL)
			delete temp_[i];
	}
	printf("end\n");
}

int getIntInMatrix(char* id,ID_V* r, ID_V* c)
{
	ID_V * src=symbolVal(id);
	mat_inited(src);
	type_check(MAT,src);
	type_check(INT,r);
	type_check(INT,c);
	if(INTV(r)>=0&&INTV(c)>=0&&MATV(src)->row_n>INTV(r)&&MATV(src)->col_n>INTV(c))
		return  MATV(src)->mat[INTV(r)][INTV(c)];
	yyerror("Runtime Error: index out of range");
	exit(-1);
}

void setIntInMatrix(char* id,ID_V* r, ID_V* c,ID_V* ne)
{
	ID_V * src=symbolVal(id);
	mat_inited(src);
	type_check(MAT,src);
	type_check(INT,r);
	type_check(INT,c);
	type_check(INT,ne);
	if(INTV(r)>=0&&INTV(c)>=0&&MATV(src)->row_n>INTV(r)&&MATV(src)->col_n>INTV(c))
		MATV(src)->mat[INTV(r)][INTV(c)]=INTV(ne);
	yyerror("Runtime Error: index out of range");
	exit(-1);
}


void printv(ID_V* c)
{
	if(TYPE(c)==INT)
		printf("%d\n",INTV(c));
	else if(TYPE(c)==MAT)
	{
		mat_inited(c);
		print_ma(MATV(c));
	}
	else
	{
		yyerror("can not print");
		exit(-1);
	}
}

matrix* ma_init(ID_V* r,ID_V* c,int*arr)
{
	type_check(INT,r);
	type_check(INT,c);
	return ma_init(INTV(r),INTV(c),arr);
}

matrix* ma_init(int r,int c,int*arr)
{
	matrix* ret=init_ma(r,c,arr);
	free(arr);
	return ret;
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}

void type_check(ID_V*a,ID_V*b)
{
	if(TYPE(a)==TYPE(b))
		return;
	yyerror("type error");
	exit(-1);
}
void type_check(int a,ID_V*b)
{
	if(a==TYPE(b))
		return;
	yyerror("type error");
	exit(-1);
}

ID_V * temp_val(int type, int val,matrix *v)
{
	static int idx=-1;
	idx=(idx+1)%1024;
	if(temp_[idx]!=NULL)
		delete temp_[idx];
	temp_[idx]=new ID_V(type,NULL,val,v,idx);
	return temp_[idx];
}

void newSymbolVal(char * id, int type, ID_V *src)
{
	if(stable->find(string(id))!=stable->end())
	{
		char err[100];
		sprintf(err,"Runtime Error:redefine symbol \"%s\"",id);
		yyerror(err);
		exit(-1);
	}
	type_check(type,src);
		(*stable)[string(id)]=new ID_V(type,id);
	updateSymbolVal(id,src);
}

ID_V * symbolVal(char* id)
{
	string ID(id);
	if(stable->find(ID)==stable->end())
	{
		char err[100];
		sprintf(err,"Runtime Error:symbol \"%s\" not define",id);
		yyerror(err);
		exit(-1);
	}
	return stable->find(ID)->second;
}

void updateSymbolVal (char* id,ID_V* src)
{
	ID_V * idv=symbolVal(id);
	updateSymbolVal (idv,src);
}
void updateSymbolVal (ID_V* idv,ID_V* src)
{
	type_check(idv,src);
	if(TYPE(idv)==MAT&&src->var)
		idv->var=matrix_copy(src->var);
	else
		idv->val=src->val;
	if(TEMP(src))
	{
		temp_[src->t]=NULL;
		delete src;
	}
}

ID_V * add (ID_V* a, ID_V* b)
{
	type_check(a,b);
	mat_inited(a);
	mat_inited(b);
	if(TYPE(a)==INT)
		return temp_val(INT,INTV(a)+INTV(b),NULL);
	matrix* temp = matrix_add(MATV(a),MATV(b));
	if(temp!=NULL)
		return temp_val(MAT,0,temp);
	yyerror("Runtime Error:dimension miss match");
	exit(-1);
}
ID_V * red (ID_V* a, ID_V* b)
{
	type_check(a,b);
	mat_inited(a);
	mat_inited(b);
	if(TYPE(a)==INT)
		return temp_val(INT,INTV(a)-INTV(b),NULL);
	matrix* temp = matrix_red(MATV(a),MATV(b));
	if(temp!=NULL)
		return temp_val(MAT,0,temp);
	yyerror("Runtime Error:dimension miss match");
	exit(-1);
}
ID_V * mut (ID_V* a, ID_V* b)
{
	mat_inited(a);
	mat_inited(b);
	if(TYPE(a)==INT&&TYPE(b)==INT)
		return temp_val(INT,INTV(a)*INTV(b),NULL);
	matrix* temp=NULL;
	if(TYPE(a)==INT&&TYPE(b)==MAT)
		temp=matrix_muI(MATV(b),INTV(a));
	else if(TYPE(a)==MAT&&TYPE(b)==MAT)
		temp=matrix_mu(MATV(a),MATV(b));
	else
		temp=matrix_muI(MATV(a),INTV(b));
	if(temp!=NULL)
		return temp_val(MAT,0,temp);
	yyerror("Runtime Error:dimension miss match");
	exit(-1);
}
ID_V * rev (ID_V* a)
{
	mat_inited(a);
	if(TYPE(a)==INT)
		return temp_val(INT,-INTV(a),NULL);
	matrix* temp=matrix_muI(MATV(a),-1);
	if(temp!=NULL)
		return temp_val(MAT,0,temp);
	yyerror("Runtime Error");
	exit(-1);
}
ID_V * dvi (ID_V* a, ID_V* b)
{
	mat_inited(a);
	mat_inited(b);
	if(TYPE(a)==INT&&TYPE(b)==INT)
		return temp_val(INT,INTV(a)/INTV(b),NULL);
	if(TYPE(a)==MAT&&TYPE(b)==INT)
	{
		matrix* temp=matrix_diI(MATV(a),INTV(b));
		if(temp!=NULL)
			return temp_val(MAT,0,temp);
		yyerror("Runtime Error:dimension miss match");
		exit(-1);
	}
	if(TYPE(a)==MAT&&TYPE(b)==MAT)
		yyerror("type error: illegal operation \"matrix / matrix\" ");
	if(TYPE(a)==INT&&TYPE(b)==MAT)
		yyerror("type error: illegal operation \"int / matrix\" ");
	exit(-1);
}

void mat_inited(ID_V* v)
{
	if(TYPE(v)!=MAT) return;
	if(MATV(v)) return;
	char err[100];
	sprintf(err,"Runtime Error:use matrix \"%s\" not init",v->id);
	yyerror(err);
	exit(-1);
}

int main (int argc,char** argv) 
{
	if(argc<=1)
		printf("#demo for CS440 project\n");
	else
		yyin=fopen(argv[1],"r+");
	stable=new STable;
	return yyparse ();
}

ID_V::ID_V(int type,char* id,int v, matrix *m,int temp)
{
	this->id=id?strdup(id):NULL;
	this->type=type;
	val=v;
	var=m;
	t=temp;
}


ID_V::~ID_V()
{
	if(id&&type>0)
		free(id);
	if(var&&type==MAT)
		del_ma(var);
}

/*
		g++ -std=c++11 MCL.c MCL.h  lex.yy.c y.tab.c  -o MCL -w
*/