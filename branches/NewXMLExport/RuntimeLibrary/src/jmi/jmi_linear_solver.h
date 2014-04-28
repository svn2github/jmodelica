 /*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

/** \file jmi_linear_solver.h
 *  \brief A linear solver based on LAPACK.
 */

#ifndef _JMI_LINEAR_SOLVER_H
#define _JMI_LINEAR_SOLVER_H

#include "jmi_block_solver.h"

/* Lapack function */
extern void dgetrf_(int* M, int* N, double* A, int* LDA, int* IPIV, int* INFO );
extern void dgetrs_(char* TRANS, int* N, int* NRHS, double* A, int* LDA, int* IPIV, double* B, int* LDB, int* INFO);
extern void dgelss_(int* M, int* N, int* NRHS, double* A, int* LDA, double* B, int* LDB,double* S,double* RCOND,int* RANK,double* WORK,int* LWORK, int* INFO);
extern void dgels_(char* TRANS, int* M, int* N, int* NRHS,double* A,int* LDA, double* B,int* LDB,double* WORK,int* LWORK,int* INFO );
extern int dgeequ_(int *m, int *n, double *a, int * lda, double *r__, double *c__, double *rowcnd, double 
    *colcnd, double *amax, int *info);

extern int dlaqge_(int *m, int *n, double *a, int * lda, double *r__, double *c__, double *rowcnd, double 
    *colcnd, double *amax, char *equed);

typedef struct jmi_linear_solver_t jmi_linear_solver_t;

int jmi_linear_solver_new(jmi_linear_solver_t** solver, jmi_block_solver_t* block);

int jmi_linear_solver_solve(jmi_block_solver_t* block);

int jmi_linear_solver_evaluate_jacobian(jmi_block_solver_t* block, jmi_real_t* jacobian);

int jmi_linear_solver_evaluate_jacobian_factorization(jmi_block_solver_t* block, jmi_real_t* factorization);

void jmi_linear_solver_delete(jmi_block_solver_t* block);

struct jmi_linear_solver_t {
    int* ipiv;                     /**< \brief Work vector needed for dgesv */
    jmi_real_t* factorization;      /**< \brief Matrix for storing the Jacobian factorization */
    jmi_real_t* jacobian;         /**< \brief Matrix for storing the Jacobian */
    jmi_real_t* jacobian_temp;         /**< \brief Matrix for storing the Jacobian */
    jmi_real_t* singular_values;  /**< \brief Vector for the singular values of the Jacobian */
    double* rScale;               /**< \brief Row scaling of the Jacobian matrix */
    double* cScale;               /**< \brief Column scaling of the Jacobian matrix */
    char equed;                    /**< \brief If scaling of the Jacobian matrix used ('N' - no scaling, 'R' - rows, 'C' - cols, 'B' - both */
    int cached_jacobian;          /**< \brief This flag indicates weather the Jacobian needs to be refactorized */
    int singular_jacobian;   /**< \brief Indicates if the Jacobian is singular or not */
    int iwork;
    double* zero_vector;
    jmi_real_t* rwork;
};

#endif /* _JMI_LINEAR_SOLVER_H */
