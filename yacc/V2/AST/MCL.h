#ifndef _MATRIX_
#define _MATRIX_

    typedef struct Matrix
    {
        int col_n;
        int row_n;
        int **mat;
    } matrix;

    typedef struct ast
    {
        void* cot;
        int type;
        int var;
        struct ast *l,*r;
        int par;
        int lv;
    } AST;


    matrix* init__ma(int r,int c);
    matrix* init_ma(int r,int c,int*arr);
    matrix* matrix_muI(matrix* m,int x);
    matrix* matrix_diI(matrix* m,int x);
    matrix* matrix_mu(matrix* a,matrix* b);
    matrix* matrix_add(matrix* a,matrix* b);
    matrix* matrix_red(matrix* a,matrix* b);
    matrix* matrix_copy(matrix*m);
    void del_ma(matrix *m);
    void print_ma(matrix *m);

    AST * makenode(int type, void* c_var, AST *l, AST *r);
    void print_ast(AST *root);
    #define _opt 1
	#define _id 2
	#define _INTV 3
	#define _MATV 4
	#define _ARRV 5
    #define _idx 6
    #define _pair 7
    #define _other 0
#endif