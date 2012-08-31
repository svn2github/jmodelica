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

#include "jmi.h"
/*#include "fmi.h"*/
#include "jmi_linear_solver.h"
#include "jmi_block_residual.h"
#include "jmi_util.h"

int jmi_linear_solver_new(jmi_linear_solver_t** solver_ptr, jmi_block_residual_t* block) {
    jmi_linear_solver_t* solver= (jmi_linear_solver_t*)calloc(1,sizeof(jmi_linear_solver_t));
    jmi_t* jmi = block->jmi;
    int i = 0;
    int j = 0;
    int n_x = block->n;
    int info = 0;
    
    if (!solver) return -1;
    
    /* Initialize work vectors.*/
	solver->factorization = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
	solver->ipiv = (int*)calloc(n_x,sizeof(int));

    *solver_ptr = solver;
    return info==0? 0: -1;
}

int jmi_linear_solver_solve(jmi_block_residual_t * block){
	int n_x = block->n;
	int info;
    int i;
    int j;
    char trans;
    jmi_linear_solver_t* solver = block->solver;
    jmi_t * jmi = block->jmi;

    /* If needed, reevaluate and factorize Jacobian */
    if (solver->cached_jacobian != 1) {

    	/*printf("** Computing factorization in jmi_linear_solver_solve for block %d\n",block->index);*/
    	block->F(jmi,NULL,solver->factorization,JMI_BLOCK_EVALUATE_JACOBIAN);
/*    	printf("Jacobian: \n");
    	for (i=0;i<n_x;i++) {
    		for (j=0;j<n_x;j++) {
    			printf("%e, ", solver->factorization[i + j*n_x]);
    		}
    		printf("\n");
    	}*/
    	dgetrf_(&n_x, &n_x, solver->factorization, &n_x, solver->ipiv, &info);
    	/*printf("Factorization: \n");
    	for (i=0;i<n_x;i++) {
    		for (j=0;j<n_x;j++) {
    			printf("%e, ", solver->factorization[i + j*n_x]);
    		}
    		printf("\n");
    	}*/

    	if (block->jacobian_variability == JMI_CONSTANT_VARIABILITY ||
	         block->jacobian_variability == JMI_PARAMETER_VARIABILITY) {
    		solver->cached_jacobian = 1;
    	}

    }

    /* Compute right hand side */
	for (i=0;i<n_x;i++) {
		block->x[i] = 0.;
	}
	block->F(block->jmi,block->x, block->res, JMI_BLOCK_EVALUATE);

	/* Do back-solve */
	trans = 'N'; /* No transposition */
	i = 1; /* One rhs to solve for */
	dgetrs_(&trans, &n_x, &i, solver->factorization, &n_x, solver->ipiv, block->res, &n_x, &info);

    /* Write solution back to model */
	block->F(block->jmi,block->res, NULL, JMI_BLOCK_WRITE_BACK);

    return info==0? 0: -1;
}

void jmi_linear_solver_delete(jmi_block_residual_t* block) {
    jmi_linear_solver_t* solver = block->solver;
    free(solver->ipiv);
    free(solver->factorization);
    free(solver);
    block->solver = 0;
}
