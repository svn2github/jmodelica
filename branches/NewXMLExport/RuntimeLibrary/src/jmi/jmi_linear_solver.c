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

#include "string.h"

#include "jmi_linear_solver.h"
#include "jmi_block_solver_impl.h"
#include "jmi_log.h"

int jmi_linear_solver_new(jmi_linear_solver_t** solver_ptr, jmi_block_solver_t* block) {
    jmi_linear_solver_t* solver= (jmi_linear_solver_t*)calloc(1,sizeof(jmi_linear_solver_t));
/*    jmi_t* jmi = block->jmi;
    int i = 0;
    int j = 0; */
    int n_x = block->n;
    int info = 0;
    int i;
    
    if (!solver) return -1;
    
    /* Initialize work vectors.*/
    solver->factorization = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->jacobian = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->jacobian_temp = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->singular_values = (jmi_real_t*)calloc(n_x,sizeof(jmi_real_t));
    solver->rScale = (double*)calloc(n_x,sizeof(double));
    solver->cScale = (double*)calloc(n_x,sizeof(double));
    solver->equed = 'N';
    solver->ipiv = (int*)calloc(n_x,sizeof(int));
    
    solver->singular_jacobian = 0;
    solver->iwork = 5*n_x;
    solver->rwork = (double*)calloc(solver->iwork,sizeof(double));
    solver->zero_vector = (double*)calloc(n_x,sizeof(double));

    for (i=0; i<n_x; i++) {
        solver->zero_vector[i] = 0.0;
    }

    *solver_ptr = solver;
    return info==0? 0: -1;
}

int jmi_linear_solver_solve(jmi_block_solver_t * block){
    int n_x = block->n;
    int iwork;
    int rank;
    double rcond;
    int info;
    int i;
	jmi_log_node_t destnode;

    char trans;
    jmi_linear_solver_t* solver = block->solver;
    iwork = solver->iwork;
    
    /* If needed, reevaluate jacobian. */
    if (solver->cached_jacobian != 1) {

        /*printf("** Computing factorization in jmi_linear_solver_solve for block %d\n",block->id);*/
          /*
             TODO: this code should be merged with the code used in kinsol interface module.
             A regularization strategy for simple cases singular jac should be introduced.
          */
        info = block->F(block->problem_data,NULL,solver->jacobian,JMI_BLOCK_EVALUATE_JACOBIAN);
        memcpy(solver->factorization, solver->jacobian, n_x*n_x*sizeof(jmi_real_t));
        if(info) {
            if(block->init) {
                jmi_log_node(block->log, logError, "Error", "Failed in Jacobian calculation for <block: %d>", 
                             block->id);
            }
            else {
                jmi_log_node(block->log, logWarning, "Warning", "Failed in Jacobian calculation for <block: %d>", 
                             block->id);
            }
            return -1;
        }
        if((n_x>1)  && block->options->use_jacobian_equilibration_flag) {
            double rowcnd, colcnd, amax;
            dgeequ_(&n_x, &n_x, solver->factorization, &n_x, solver->rScale, solver->cScale, 
                    &rowcnd, &colcnd, &amax, &info);
            if(info == 0) {
                dlaqge_(&n_x, &n_x, solver->factorization, &n_x, solver->rScale, solver->cScale, 
                        &rowcnd, &colcnd, &amax, &solver->equed);
            }
            else
                solver->equed = 'N';
        }
	}

	/* Log the jacobian.*/
	if((block->callbacks->log_options.log_level >= 5)) {
		destnode = jmi_log_enter_fmt(block->log, logInfo, "LinearSolve", 
                                     "Linear solver invoked for <block:%d>", block->id);
		jmi_log_real_matrix(block->log, destnode, logInfo, "A", solver->jacobian, block->n, block->n);
	}

	/*  If jacobian is reevaluated then factorize Jacobian. */
    if (solver->cached_jacobian != 1) {
        /* Call 
        *  DGETRF computes an LU factorization of a general M-by-N matrix A
        *  using partial pivoting with row interchanges.
        * */
        dgetrf_(&n_x, &n_x, solver->factorization, &n_x, solver->ipiv, &info);
        if(info) {
            if(block->init) {
                jmi_log_node(block->log, logError, "Error", "Singular Jacobian detected for <block: %d>", 
                             block->id);
            }
            else {
                jmi_log_node(block->log, logWarning, "Warning", "Singular Jacobian detected for <block: %d> at <t: %f>", 
                             block->id, block->cur_time);
            }
            /* return -1; */
            solver->singular_jacobian = 1;
        }else{
            solver->singular_jacobian = 0;
        }

        if (block->jacobian_variability == JMI_CONSTANT_VARIABILITY ||
             block->jacobian_variability == JMI_PARAMETER_VARIABILITY) {
            solver->cached_jacobian = 1;
        }

    }
    
    /* Compute right hand side at initial x*/ 
    /* info = block->F(block->problem_data,block->initial, block->res, JMI_BLOCK_EVALUATE); */
    info = block->F(block->problem_data,solver->zero_vector, block->res, JMI_BLOCK_EVALUATE);
    if(info) {
		/* Close the LinearSolve log node and generate the Error/Warning node and return. */
		if((block->callbacks->log_options.log_level >= 5)) jmi_log_leave(block->log, destnode);

        if(block->init) {
            jmi_log_node(block->log, logError, "Error", "Failed to evaluate equations in <block: %d>", block->id);
        }
        else {
            jmi_log_node(block->log, logWarning, "Warning", "Failed to evaluate equations in <block: %d>", block->id);
        }
        return -1;
    }

    
    if((solver->equed == 'R') || (solver->equed == 'B')) {
        for (i=0;i<n_x;i++) {
            block->res[i] *= solver->rScale[i];
        }
    }
    
    if((block->callbacks->log_options.log_level >= 5)) {
        jmi_log_reals(block->log, destnode, logInfo, "initial_guess", block->initial, block->n);
        jmi_log_reals(block->log, destnode, logInfo, "b", block->res, block->n);     
        jmi_log_leave(block->log, destnode);
    }
 
    /* Do back-solve */
    trans = 'N'; /* No transposition */
    i = 1; /* One rhs to solve for */
      
    if (solver->singular_jacobian == 1){
        /*
         *   DGELSS - compute the minimum norm solution to	a real 
         *   linear least squares problem
         * 
         * SUBROUTINE DGELSS( M, N, NRHS, A, LDA, B, LDB, S, RCOND, RANK,WORK, LWORK, INFO )
         *
         */
        rcond = -1.0;
        
        memcpy(solver->jacobian_temp, solver->jacobian, n_x*n_x*sizeof(jmi_real_t));
        dgelss_(&n_x, &n_x, &i, solver->jacobian_temp, &n_x, block->res, &n_x ,solver->singular_values, &rcond, &rank, solver->rwork, &iwork, &info);
        
        if(info != 0) {
            jmi_log_node(block->log, logError, "Error", "DGELSS failed to solve the linear system in <block: %d> with error code <error: %d>", block->id, info);
            return -1;
        }
        
        if(block->callbacks->log_options.log_level >= 5){
            jmi_log_node(block->log, logInfo, "Info", "Successfully calculated the minimum norm solution to the linear system in <block: %d>", block->id);
        }
    }else{
        /*
         * DGETRS solves a system of linear equations
         *     A * X = B  or  A' * X = B
         *  with a general N-by-N matrix A using the LU factorization computed
         *  by DGETRF.
         */
        dgetrs_(&trans, &n_x, &i, solver->factorization, &n_x, solver->ipiv, block->res, &n_x, &info);
    }
    
    if(info) {
        /* can only be "bad param" -> internal error */
        jmi_log_node(block->log, logError, "Error", "Internal error when solving <block: %d> with error code %d", block->id, info);
        return -1;
    }
    if((solver->equed == 'C') || (solver->equed == 'B')) {
        for (i=0;i<n_x;i++) {
             /* block->x[i] = block->initial[i] + block->res[i] * solver->cScale[i]; */
             block->x[i] = block->res[i] * solver->cScale[i];
        }
    }
    else {
        for (i=0;i<n_x;i++) {
            /* block->x[i] = block->initial[i] + block->res[i] ; */
            block->x[i] = block->res[i];
        }
    }
    
    /* Write solution back to model */
    /* JMI_BLOCK_EVALUATE is used since it is needed for torn linear equation blocks! Might be changed in the future! */
    block->F(block->problem_data,block->x, block->res, JMI_BLOCK_EVALUATE);

    return info==0? 0: -1;
}

void jmi_linear_solver_delete(jmi_block_solver_t* block) {
    jmi_linear_solver_t* solver = block->solver;
    free(solver->ipiv);
    free(solver->factorization);
    free(solver->jacobian);
    free(solver->singular_values);
    free(solver->jacobian_temp);
    free(solver->rScale);
    free(solver->cScale);
    free(solver->rwork);
    free(solver->zero_vector);
    free(solver);
    block->solver = 0;
}

