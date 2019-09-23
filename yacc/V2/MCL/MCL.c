#include "MCL.h"
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>


matrix* init__ma(int r,int c)
{
    matrix *m = (matrix*)malloc(sizeof(matrix));
    m->col_n=c;
    m->row_n=r;
    m->mat=(int**)calloc(r,sizeof(int*));
    int i;
    for(i=0;i<r;i++)
        m->mat[i]=(int*)calloc(c,sizeof(int));
    return m;
}

matrix* init_ma(int r,int c, int *arr)
{
    matrix *m = init__ma(r,c);
    int i,j,max=arr[0];
    arr=arr+1;
    for (i=0;i<m->row_n;i++)
        for (j=0;j<m->col_n;j++)
        {
            if((i*m->col_n+j)<max)
                m->mat[i][j]=arr[i*m->col_n+j];
            else
                return m;
        }
    return m;
}

matrix* matrix_muI(matrix* m,int x)
{
    int i,j;
    matrix* ret=init__ma(m->row_n,m->col_n);
    for(i=0;i<m->row_n;i++)
        for(j=0;j<m->col_n;j++)
            ret->mat[i][j]=x*m->mat[i][j];
    return ret;
}

matrix* matrix_copy(matrix*m)
{
    return matrix_muI(m,1);
}

matrix* matrix_diI(matrix* m,int x)
{
    int i,j;
    matrix* ret=init__ma(m->row_n,m->col_n);
    for(i=0;i<m->row_n;i++)
        for(j=0;j<m->col_n;j++)
            ret->mat[i][j]=(int)((double)m->mat[i][j]/x);
    return ret;
}

matrix* matrix_mu(matrix* a,matrix* b)
{
    if(a->col_n!=b->row_n)
        return NULL;
    int i,j,k;
    matrix *ret=init__ma(a->row_n,b->col_n);
    for(i=0;i<ret->col_n;i++)
        for(j=0;j<ret->row_n;j++)
            for(k=0;k<a->col_n;k++)
                ret->mat[i][j]+=a->mat[i][k]*b->mat[k][j];
    return ret;
}

matrix* matrix_add_red(matrix* a,matrix* b,int val)
{
    if(a->row_n!=b->row_n||a->col_n!=b->col_n)
        return NULL;
    int i,j;
    matrix* ret = init__ma(a->row_n,a->col_n);
    for(i=0;i<ret->row_n;i++)
        for(j=0;j<ret->col_n;j++)
            ret->mat[i][j]=a->mat[i][j]+val*b->mat[i][j];
    return ret;
}

matrix* matrix_add(matrix* a,matrix* b)
{
    return matrix_add_red(a,b,1);
}

matrix* matrix_red(matrix* a,matrix* b)
{
    return matrix_add_red(a,b,-1);
}

void del_ma(matrix *m)
{
    int i;
    for(i=0;i<m->row_n;i++)
        free(m->mat[i]);
    free(m->mat);
    free(m);
}

void print_ma(matrix *m)
{
    int i,j;
    printf(" matrix [%d x %d] = \n",m->row_n,m->col_n);
    for(i=0;i<m->row_n;i++)
    {
        if(i==0)
            printf("[");
        else
            printf(" ");
        for(j=0;j<m->col_n;j++)
        {
            printf("%8d",m->mat[i][j]);
        }
        if(i==m->row_n-1)
            printf("]");
        printf("\n");
    }
}

