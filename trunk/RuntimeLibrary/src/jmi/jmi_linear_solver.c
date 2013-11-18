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
    
    if (!solver) return -1;
    
    /* Initialize work vectors.*/
    solver->factorization = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->jacobian = (jmi_real_t*)calloc(n_x*n_x,sizeof(jmi_real_t));
    solver->rScale = (double*)calloc(n_x,sizeof(double));
    solver->cScale = (double*)calloc(n_x,sizeof(double));
    solver->equed = 'N';
    solver->ipiv = (int*)calloc(n_x,sizeof(int));

    *solver_ptr = solver;
    return info==0? 0: -1;
}

int jmi_linear_solver_solve(jmi_block_solver_t * block){
    int n_x = block->n;
    int info;
    int i;
/*    int j; */
    char trans;
    jmi_linear_solver_t* solver = block->solver;
    
    /* If needed, reevaluate and factorize Jacobian */
    if (solver->cached_jacobian != 1) {

        /*printf("** Computing factorization in jmi_linear_solver_solve for block %d\n",block->id);*/
          /*
             TODO: this code should be merged with the code used in kinsol interface module.
             A regularization strategy for simple cases singular jac should be introduced.
          */
        info = block->F(block->problem_data,NULL,solver->factorization,JMI_BLOCK_EVALUATE_JACOBIAN);
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

/*      printf("Jacobian: \n");
        for (i=0;i<n_x;i++) {
            for (j=0;j<n_x;j++) {
                printf("%e, ", solver->factorization[i + j*n_x]);
            }
            printf("\n");
        }*/
        dgetrf_(&n_x, &n_x, solver->factorization, &n_x, solver->ipiv, &info);
        if(info) {
            if(block->init) {
                jmi_log_node(block->log, logError, "Error", "Singular Jacobian detected for <block: %d>", 
                             block->id);
            }
            else {
                jmi_log_node(block->log, logWarning, "Warning", "Singular Jacobian detected for <block: %d>", 
                             block->id);
            }
            return -1;
        }
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
    /* Compute right hand side at initial x*/
    /* TESTING ONLY! setting x to zero leads to invalid arguments to the function in case of bounds */
    /*for (i=0;i<n_x;i++) {
        block->x[i] = 0.; 
    } */
 
    info = block->F(block->problem_data,block->initial, block->res, JMI_BLOCK_EVALUATE);
    if(info) {
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
 
    /* Do back-solve */
    trans = 'N'; /* No transposition */
    i = 1; /* One rhs to solve for */
    dgetrs_(&trans, &n_x, &i, solver->factorization, &n_x, solver->ipiv, block->res, &n_x, &info);

    if(info) {
        /* can only be "bad param" -> internal error */
        jmi_log_node(block->log, logError, "Error", "Internal error when solving <block: %d>", block->id);
        return -1;
    }
    if((solver->equed == 'C') || (solver->equed == 'B')) {
        for (i=0;i<n_x;i++) {
             block->x[i] = block->initial[i] + block->res[i] * solver->cScale[i];
        }
    }
    else {
        for (i=0;i<n_x;i++) {
            block->x[i] = block->initial[i] + block->res[i] ;
        }
    }
        
    /* Write solution back to model */
    block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);

    return info==0? 0: -1;
}

void jmi_linear_solver_delete(jmi_block_solver_t* block) {
    jmi_linear_solver_t* solver = block->solver;
    free(solver->ipiv);
    free(solver->factorization);
    free(solver->jacobian);
    free(solver->rScale);
    free(solver->cScale);
    free(solver);
    block->solver = 0;
}

