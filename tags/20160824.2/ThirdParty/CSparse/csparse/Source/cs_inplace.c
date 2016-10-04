#include "cs.h"

int cs_add_inplace( const cs *A, const cs *B, cs *C, double alpha, double beta, csi* w, double *x)
/*
    Computes alpha*A+beta*B and store the result in C. C need to be
    allocated with the correct size and dimensions outside of this 
    method.
    
    csi* w and double* x are work vectors of size B->m.
    
    This function is a minor modification of the method cs_add by
    Timothy A. Davis from the package CSparse (LGPL).
*/
{
    int p, j, nz = 0, m, n;
    csi *Cp, *Ci;
    double *Cx ;
    
    /* Check inputs */
    if (!A || !B || !C || !w || !x) return -1;
    if (!CS_CSC (A) || !CS_CSC (B) || !CS_CSC (C)) return -1;
    if (A->x == NULL || B->x == NULL || C->x == NULL) return -1;
    
    m = A->m ; n = B->n ;
    Cp = C->p ; Ci = C->i ; Cx = C->x ;
    
    /* Clear w */
    /* for (j = 0; j < m; j++) { w[j] = 0; } */
    memset(w, 0, m*sizeof(csi));
    
    for (j = 0 ; j < n ; j++) {
        Cp [j] = nz ;			/* column j of C starts here */
        nz = cs_scatter (A, j, alpha, w, x, j+1, C, nz) ;   /* alpha*A(:,j)*/
        nz = cs_scatter (B, j, beta, w, x, j+1, C, nz) ;    /* beta*B(:,j) */
        for (p = Cp [j] ; p < nz ; p++) Cx [p] = x [Ci [p]] ;
    }
    Cp [n] = nz ;			/* finalize the last column of C */

    return 0;
}

int cs_multiply_inplace (const cs *A, const cs *B, cs *C, csi *w, double *x)
/*
    Computes A*B and store the result in C. C need to be
    allocated with the correct size and dimensions outside of this 
    method.
    
    csi* w and double* x are work vectors of size B->m.
    
    This function is a minor modification of the method cs_multiply by
    Timothy A. Davis from the package CSparse (LGPL).
*/
{
    int p, j, nz = 0, m, n;
    csi *Cp, *Ci, *Bp, *Bi;
    double *Bx, *Cx ;

    if (!A || !B || !C || !w || !x) return -1;
    if (!CS_CSC (A) || !CS_CSC (B) || !CS_CSC (C)) return -1;
    if (A->x == NULL || B->x == NULL || C->x == NULL) return -1;
    
    m = A->m ;
    n = B->n ; Bp = B->p ; Bi = B->i ; Bx = B->x ;
    Cp = C->p;

    /* Clear w */
    /* for (j = 0; j < m; j++) { w[j] = 0; } */
    memset(w, 0, m*sizeof(csi));

    for (j = 0 ; j < n ; j++) {
        Ci = C->i ; Cx = C->x ;		/* C may have been reallocated */
        Cp [j] = nz ;			/* column j of C starts here */
        for (p = Bp [j] ; p < Bp [j+1] ; p++) {
            nz = cs_scatter (A, Bi [p], Bx [p], w, x, j+1, C, nz) ;
        }
        for (p = Cp [j] ; p < nz ; p++) Cx [p] = x [Ci [p]] ;
    }
    Cp [n] = nz ;			/* finalize the last column of C */
    
    return 0;
}


/* solve Gx=b(:,k), where G is either upper (lo=0) or lower (lo=1) triangular */
int cs_spsolve_inplace (cs *G, const cs *B, csi k, csi *xi, csi top, double *x)
/*
 * xi size n-1-top xi[0...n-1-top]=Reach(B(:,k))
 * x size m
 */
{
    csi j, J, p, q, px, n, *Gp, *Gi, *Bp, *Bi ;
    double *Gx, *Bx ;
    if (!CS_CSC (G) || !CS_CSC (B) || !xi || !x) return -1;
    Gp = G->p ; Gi = G->i ; Gx = G->x ; n = G->n ;
    Bp = B->p ; Bi = B->i ; Bx = B->x ;

    for (p = 0 ; p < n-top ; p++) x [xi [p]] = 0 ;    /* clear x */
    for (p = Bp [k] ; p < Bp [k+1] ; p++) x [Bi [p]] = Bx [p] ; /* scatter B */
    for (px = 0 ; px < n-top ; px++)
    {
        j = xi [px] ;           /* x(j) is nonzero */
        J = j ;                 /* j maps to col J of G */
        if (J < 0) continue ;   /* column J is empty */
        x [j] /= Gx [Gp [J]];   /* x(j) /= G(j,j) */
        p = Gp [J]+1;           /* lo: L(j,j) 1st entry */
        q = Gp [J+1];           /* up: U(j,j) last entry */
        for ( ; p < q ; p++) {
            x [Gi [p]] -= Gx [p] * x [j] ;          /* x(i) -= G(i,j) * x(j) */
        }
    }
    return 0;
}
