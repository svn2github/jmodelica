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

#define SMALL 1e-15
#define THRESHOLD 1e-15

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
    solver->dependent_set = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->jacobian_temp = (jmi_real_t*)calloc(2*n_x*n_x,sizeof(jmi_real_t));
    solver->jacobian_extension = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->rhs = (jmi_real_t*)calloc(2*n_x,sizeof(jmi_real_t));
    /* solver->rhs_extension_index = (int*)calloc(n_x,sizeof(int)); */
    solver->singular_values = (jmi_real_t*)calloc(2*n_x,sizeof(jmi_real_t));
    solver->singular_vectors = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->rScale = (double*)calloc(n_x,sizeof(double));
    solver->cScale = (double*)calloc(n_x,sizeof(double));
    solver->equed = 'N';
    solver->ipiv = (int*)calloc(n_x,sizeof(int));
    solver->update_active_set = 1;
    solver->n_extra_rows = 0;
    
    solver->singular_jacobian = 0;
    solver->iwork = 10*n_x;
    solver->rwork = (double*)calloc(solver->iwork,sizeof(double));
    solver->zero_vector = (double*)calloc(n_x,sizeof(double));
    
    solver->dgesdd_lwork = 10*n_x*n_x+4*n_x;
    solver->dgesdd_work  = (double*)calloc(solver->dgesdd_lwork,sizeof(double));
    solver->dgesdd_iwork = (int*)calloc(8*n_x,sizeof(int)); 

    for (i=0; i<n_x; i++) {
        solver->zero_vector[i] = 0.0;
    }

    *solver_ptr = solver;
    return info==0? 0: -1;
}

static int jmi_linear_find_dependent_set(jmi_block_solver_t * block) {
    int i = 0, j = 0, n_x = block->n;
    int nbr_dep = 0, info = 0, rank = 0;
    jmi_real_t test_value = 0; 
    jmi_linear_solver_t* solver = block->solver;
    jmi_log_node_t destnode;
    
    /* Reset the dependent sets */
    for (i = 0; i < n_x; i++) { solver->dependent_set[(n_x-1)*n_x+i] = 0; }
    
    memcpy(solver->jacobian_temp, solver->jacobian, n_x*n_x*sizeof(jmi_real_t));
    /* Compute the null space of A */
    /*
     *       SUBROUTINE DGESDD( JOBZ, M, N, A, LDA, S, U, LDU, VT, LDVT, WORK,
     *                          LWORK, IWORK, INFO )
     */
    dgesdd_("O", &n_x, &n_x, solver->jacobian_temp, &n_x, 
               solver->singular_values, NULL, &n_x, solver->singular_vectors, &n_x,
              solver->dgesdd_work, &solver->dgesdd_lwork, solver->dgesdd_iwork, &info);
              
    if(info != 0) {
        jmi_log_node(block->log, logError, "Error", "DGESDD failed to compute the SVD in <block: %d> with error code <error: %s>", block->label, info);
        return 0;
    }
    
    /* Compute the rank */
    for (i = 0; i < n_x; i++) { if (solver->singular_values[i] > THRESHOLD) { rank += 1; } else { break; } }
    
    /* The matrix seems to be of full rank */
    if (rank >= n_x) {
        return 0;
    }
    
    /* Compute the dependent sets */
    for (i = 0; i < n_x-rank; i++) {
        nbr_dep = 0;
        for (j = 0; j < n_x; j++) {
            test_value = solver->singular_vectors[j*n_x+rank+i];
            if ((test_value >= 0 && test_value > SMALL) || (test_value < 0 && test_value < -SMALL)) {
                solver->dependent_set[i*n_x+nbr_dep] = j;
                nbr_dep++;
            }
        }
        /* An error occurred */
        if (nbr_dep >= n_x) {
            nbr_dep = 0;
        }
        solver->dependent_set[(n_x-1)*n_x+i] = nbr_dep;
    }

    /* Log the dependent sets and the singular vectors.*/
    if((block->callbacks->log_options.log_level >= 5)) {
        destnode = jmi_log_enter_fmt(block->log, logInfo, "LinearSolveDependentSet", 
                                     "Linear solver set calculation invoked for <block:%s>", block->label);
        jmi_log_real_matrix(block->log, destnode, logInfo, "DependentSet", solver->dependent_set, block->n, block->n);
        jmi_log_real_matrix(block->log, destnode, logInfo, "SingularVectors", solver->singular_vectors, block->n, block->n);
        jmi_log_leave(block->log, destnode);
    }
    
    return 0;
}

static int jmi_linear_check_active_variable(jmi_block_solver_t * block, int set, int index) {
    int active = 0, flag = 0;
    jmi_real_t *x  = block->x;
    jmi_real_t val = x[index];
    jmi_real_t eps = ((jmi_block_solver_options_t*)(block->options))->events_epsilon;
    
    x[index] = val+eps+THRESHOLD;
    flag = block->check_discrete_variables_change(block->problem_data, x);
    if (flag == JMI_SWITCHES_CHANGED || flag == JMI_SWITCHES_AND_NON_REALS_CHANGED) { active = 1; }
    
    if (!active) {
        x[index] = val-eps-THRESHOLD;
        flag = block->check_discrete_variables_change(block->problem_data, x);
        if (flag == JMI_SWITCHES_CHANGED || flag == JMI_SWITCHES_AND_NON_REALS_CHANGED) { active = 1; }
    }
    
    x[index] = val;
    
    if (active) {
        jmi_log_node(block->log, logInfo, "ActiveVariable", "Found active iteration variable, number <iv: %I> in <set: %I> from <block: %s>", 
             index, set, block->label);
    }
    
    return active;
}

static int jmi_linear_find_active_set(jmi_block_solver_t * block ) {
    int i = 0, j = 0, k = 0, set = 0, n_x = block->n;
    int active = 0, nbr_active = 0, n_ux = 0;
    jmi_linear_solver_t* solver = block->solver;
    jmi_log_node_t destnode;
    
    if(block->check_discrete_variables_change && solver->update_active_set == 1) {
        
        for (i = 0; i < n_x-1; i++) {
            set = solver->dependent_set[(n_x-1)*n_x+i];
            nbr_active = 0;
            
            if (set > 0) {
                for (k = 0; k < set; k++) {
                    active = jmi_linear_check_active_variable(block, i, (int)solver->dependent_set[i*n_x+k]);
                    
                    if (active) {
                        /* solver->rhs_extension_index[n_ux] = (int)solver->dependent_set[i*n_x+k]; */
                        for (j = 0; j < n_x; j++) {
                            if (j == (int)solver->dependent_set[i*n_x+k]) {
                                solver->jacobian_extension[j*n_x+n_ux] = 1.0;
                            } else {
                                solver->jacobian_extension[j*n_x+n_ux] = 0.0;
                            }
                        }
                        nbr_active++; 
                        n_ux++; 
                    }
                }
                if (nbr_active == set) { n_ux = n_ux-set; };
            }
        }
        solver->n_extra_rows = n_ux;
    }
    
    if (solver->n_extra_rows > 0) {
        for (j = 0; j < n_x; j++) {
            memcpy(&solver->jacobian_temp[j*(n_x+solver->n_extra_rows)], &solver->jacobian[j*n_x], n_x*sizeof(jmi_real_t));
            memcpy(&solver->jacobian_temp[j*(n_x+solver->n_extra_rows)+n_x], &solver->jacobian_extension[j*n_x], solver->n_extra_rows*sizeof(jmi_real_t));
        }
        for (j = 0; j < solver->n_extra_rows; j++) { solver->rhs[n_x+j] = 0.0; };
    }

    /* Log the jacobian.*/
    if((block->callbacks->log_options.log_level >= 5) && solver->n_extra_rows > 0) {
        destnode = jmi_log_enter_fmt(block->log, logInfo, "LinearSolveDependentSet", 
                                     "Linear solver set calculation invoked for <block:%s>", block->label);
        jmi_log_real_matrix(block->log, destnode, logInfo, "ExtendedJacobian", solver->jacobian_temp, block->n+solver->n_extra_rows, block->n);
        jmi_log_reals(block->log, destnode, logInfo, "ExtendedRightHandSide", solver->rhs, block->n+solver->n_extra_rows);
        jmi_log_leave(block->log, destnode);
    }
    
    solver->update_active_set = 0;
    
    return n_x+solver->n_extra_rows;
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
        int j = 0;

        /*printf("** Computing factorization in jmi_linear_solver_solve for block %s\n",block->label);*/
          /*
             TODO: this code should be merged with the code used in kinsol interface module.
             A regularization strategy for simple cases singular jac should be introduced.
          */
        info = block->F(block->problem_data,NULL,solver->jacobian,JMI_BLOCK_EVALUATE_JACOBIAN);
        memcpy(solver->factorization, solver->jacobian, n_x*n_x*sizeof(jmi_real_t));
        if(info) {
            if(block->init) {
                jmi_log_node(block->log, logError, "ErrJac", "Failed in Jacobian calculation for <block: %s>", 
                             block->label);
            }
            else {
                jmi_log_node(block->log, logWarning, "WarnJac", "Failed in Jacobian calculation for <block: %s>", 
                             block->label);
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
        
        /*Check the Jacobian for INF and NANs */
        for (i = 0; i < n_x; i++) {
            for (j = 0; j < n_x; j++) {
                /* Unrecoverable error*/
                if ( solver->jacobian[i*n_x+j] - solver->jacobian[i*n_x+j] != 0) {
                    jmi_log_node(block->log, logError, "NaNOutput", "Not a number in the Jacobian <row: %I> <col: %I> from <block: %s>", 
                            i,j, block->label);
                    return -1;
                }
            }
        }
    }

    /* Log the jacobian.*/
    if((block->callbacks->log_options.log_level >= 5)) {
        destnode = jmi_log_enter_fmt(block->log, logInfo, "LinearSolve", 
                                     "Linear solver invoked for <block:%s>", block->label);
        jmi_log_reals(block->log, destnode, logInfo, "ivs", block->x, block->n);
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
                jmi_log_node(block->log, logError, "SingularJacobianError", "Singular Jacobian detected for <block: %s>", 
                             block->label);
            }
            else {
                jmi_log_node(block->log, logWarning, "SingularJacobian", "Singular Jacobian detected for <block: %s> at <t: %f>", 
                             block->label, block->cur_time);
            }
            /* return -1; */
            solver->singular_jacobian = 1;
            
            if (!block->at_event){
                jmi_linear_find_dependent_set(block);
            } else {
                solver->update_active_set = 1;
            }
        }else{
            solver->singular_jacobian = 0;
        }

        if (block->jacobian_variability == JMI_CONSTANT_VARIABILITY ||
             block->jacobian_variability == JMI_PARAMETER_VARIABILITY) {
            solver->cached_jacobian = 1;
        }

    }
    
    /* Compute right hand side at initial x*/ 
    if (solver->singular_jacobian == 1) {
        /* In case of singular system, use the last point in the calculation of the b-vector */
        info = block->F(block->problem_data,block->x, solver->rhs, JMI_BLOCK_EVALUATE);
    } else {
        info = block->F(block->problem_data,solver->zero_vector, solver->rhs, JMI_BLOCK_EVALUATE);
    }
    if(info) {
        /* Close the LinearSolve log node and generate the Error/Warning node and return. */
        if((block->callbacks->log_options.log_level >= 5)) jmi_log_leave(block->log, destnode);

        if(block->init) {
            jmi_log_node(block->log, logError, "ErrEvalEq", "Failed to evaluate equations in <block: %s>", block->label);
        }
        else {
            jmi_log_node(block->log, logWarning, "WarnEvalEq", "Failed to evaluate equations in <block: %s>", block->label);
        }
        return -1;
    }
    
    /*Check the right hand side for INF and NANs */
    for (i = 0; i < n_x; i++) {
        /* Unrecoverable error*/
        if ( solver->rhs[i] - solver->rhs[i] != 0) {
            jmi_log_node(block->log, logError, "NaNOutput", "Not a number in <rhs: %I> from <block: %s>", 
                         i, block->label);
            return -1;
        }
    }
    
    if((solver->equed == 'R') || (solver->equed == 'B')) {
        for (i=0;i<n_x;i++) {
            solver->rhs[i] *= solver->rScale[i];
        }
    }
    
    if((block->callbacks->log_options.log_level >= 5)) {
        jmi_log_reals(block->log, destnode, logInfo, "b", solver->rhs, block->n);     
    }
 
    /* Do back-solve */
    trans = 'N'; /* No transposition */
    i = 1; /* One rhs to solve for */
      
    if (solver->singular_jacobian == 1){
        /*
         *   DGELSS - compute the minimum norm solution to  a real 
         *   linear least squares problem
         * 
         * SUBROUTINE DGELSS( M, N, NRHS, A, LDA, B, LDB, S, RCOND, RANK,WORK, LWORK, INFO )
         *
         */
        int n_rows = n_x;
        rcond = -1.0;
        
        if (!block->at_event){
            n_rows = jmi_linear_find_active_set(block);
        }
        
        if (n_rows > n_x) {
            dgelss_(&n_rows, &n_x, &i, solver->jacobian_temp, &n_rows, solver->rhs, &n_rows ,solver->singular_values, &rcond, &rank, solver->rwork, &iwork, &info);
        } else {
            memcpy(solver->jacobian_temp, solver->jacobian, n_x*n_x*sizeof(jmi_real_t));
            dgelss_(&n_x, &n_x, &i, solver->jacobian_temp, &n_x, solver->rhs, &n_x ,solver->singular_values, &rcond, &rank, solver->rwork, &iwork, &info);
        }
        
        if(info != 0) {
            jmi_log_node(block->log, logError, "Error", "DGELSS failed to solve the linear system in <block: %d> with error code <error: %s>", block->label, info);
            return -1;
        }
        
        if(block->callbacks->log_options.log_level >= 5){
            jmi_log_node(block->log, logInfo, "Info", "Successfully calculated the minimum norm solution to the linear system in <block: %s>", block->label);
        }
    }else{
        /*
         * DGETRS solves a system of linear equations
         *     A * X = B  or  A' * X = B
         *  with a general N-by-N matrix A using the LU factorization computed
         *  by DGETRF.
         */
        dgetrs_(&trans, &n_x, &i, solver->factorization, &n_x, solver->ipiv, solver->rhs, &n_x, &info);
        
        /* After solving a consistent system, allow for update of the active set */
        solver->update_active_set = 1;
    }
    
    if(info) {
        /* can only be "bad param" -> internal error */
        jmi_log_node(block->log, logError, "Error", "Internal error when solving <block: %d> with <error_code: %s>", block->label, info);
        return -1;
    }
    if((solver->equed == 'C') || (solver->equed == 'B')) {
        if (solver->singular_jacobian == 1) {
            for (i=0;i<n_x;i++) {
                 block->x[i] = block->x[i] + solver->rhs[i] * solver->cScale[i];
            }

        } else {
            for (i=0;i<n_x;i++) {
                 block->x[i] = solver->rhs[i] * solver->cScale[i];
            }
        }
    } else {
        if (solver->singular_jacobian == 1) {
            for (i=0;i<n_x;i++) {
                block->x[i] = block->x[i] + solver->rhs[i];
            }
        } else {
            for (i=0;i<n_x;i++) {
                block->x[i] = solver->rhs[i];
            }
        }
    }
    
    if((block->callbacks->log_options.log_level >= 5)) {
        jmi_log_reals(block->log, destnode, logInfo, "x", solver->rhs, block->n);
        jmi_log_reals(block->log, destnode, logInfo, "ivs", block->x, block->n);
        jmi_log_leave(block->log, destnode);
    }
    
    /* Write solution back to model */
    /* JMI_BLOCK_EVALUATE is used since it is needed for torn linear equation blocks! Might be changed in the future! */
    block->F(block->problem_data,block->x, solver->rhs, JMI_BLOCK_EVALUATE);

    return info==0? 0: -1;
}

void jmi_linear_solver_delete(jmi_block_solver_t* block) {
    jmi_linear_solver_t* solver = block->solver;
    free(solver->ipiv);
    free(solver->factorization);
    free(solver->jacobian);
    free(solver->singular_values);
    free(solver->singular_vectors);
    free(solver->jacobian_extension);
    free(solver->rhs);
    /* free(solver->rhs_extension_index); */
    free(solver->jacobian_temp);
    free(solver->dependent_set);
    free(solver->rScale);
    free(solver->cScale);
    free(solver->rwork);
    free(solver->zero_vector);
    free(solver->dgesdd_work);
    free(solver->dgesdd_iwork);
    free(solver);
    block->solver = 0;
}

