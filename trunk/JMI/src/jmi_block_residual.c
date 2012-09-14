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

/*
 * jmi_block_residual.c contains functions that work with jmi_block_residual_t
 * This code can be compiled either with C or a C++ compiler.
 */

#include <time.h>
#include <assert.h>

#include "jmi.h"
#include "jmi_block_residual.h"
#include "jmi_simple_newton.h"
#include "jmi_kinsol_solver.h"
#include "jmi_linear_solver.h"


int jmi_dae_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, jmi_block_solvers_t solver, int index) {
	jmi_block_residual_t* b;
	int flag;
	flag = jmi_new_block_residual(&b,jmi, solver, F, dF, n, n_nr, jacobian_variability, index);
	jmi->dae_block_residuals[index] = b;
	return flag;
}

int jmi_dae_init_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, jmi_block_solvers_t solver, int index) {
	jmi_block_residual_t* b;
	int flag;
	flag = jmi_new_block_residual(&b,jmi, solver, F, dF, n, n_nr, jacobian_variability, index);
	jmi->dae_init_block_residuals[index] = b;
	return flag;
}

int jmi_new_block_residual(jmi_block_residual_t** block, jmi_t* jmi, jmi_block_solvers_t solver, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, int index){
	jmi_block_residual_t* b = (jmi_block_residual_t*)calloc(1,sizeof(jmi_block_residual_t));
	/* int i; */
	int flag = 0;
    if(!b) return -1;
	*block = b;

	b->jacobian_variability = jacobian_variability;
	b->jmi = jmi;
	b->F = F;
	b->dF = dF;
	b->n = n;
	b->n_nr = n_nr;
	b->index = index ;
	b->x = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
   
	if (n_nr>0) {
		b->x_nr = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
	}
	b->dx = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
	b->dv = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
	b->res = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
	b->dres = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
	b->jac = (jmi_real_t*)calloc(n*n,sizeof(jmi_real_t));
	b->ipiv = (int*)calloc(n,sizeof(int));
	b->init = 1;
      
	b->min = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
	b->max = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
	b->nominal = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->initial = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));

    switch(solver) {
    case JMI_KINSOL_SOLVER: {
        jmi_kinsol_solver_t* solver;    
        flag = jmi_kinsol_solver_new(&solver, b);
        b->solver = solver;
        b->solve = jmi_kinsol_solver_solve;
        b->evaluate_jacobian = jmi_kinsol_solver_evaluate_jacobian;
        b->evaluate_jacobian_factorization = jmi_kinsol_solver_evaluate_jacobian_factorization;
        b->delete_solver = jmi_kinsol_solver_delete;
    }
        break;
        
    case JMI_SIMPLE_NEWTON_SOLVER: {
        b->solver = 0;
        b->solve = jmi_simple_newton_solve;
        b->delete_solver = jmi_simple_newton_delete;
    }
        break;

    case JMI_LINEAR_SOLVER: {
        jmi_linear_solver_t* solver;
    	flag = jmi_linear_solver_new(&solver, b);
    	b->solver = solver;
        b->solve = jmi_linear_solver_solve;
        b->evaluate_jacobian = jmi_linear_solver_evaluate_jacobian;
        b->evaluate_jacobian_factorization = jmi_linear_solver_evaluate_jacobian_factorization;
        b->delete_solver = jmi_linear_solver_delete;
    }
        break;

    default:
        assert(0);
    }

	return flag;
}

int jmi_solve_block_residual(jmi_block_residual_t * block) {
    int ef;    
    clock_t c0,c1; /*timers*/
    jmi_t* jmi = block->jmi;
    c0 = clock();
    if(block->init) {
        int i;
        /* Initialize the work vectors */
        for(i=0; i < block->n; ++i) {
            block->nominal[i] = 1.0;
            block->max[i] = BIG_REAL;
            block->min[i] = -block->max[i];
        }
        block->F(jmi,block->nominal,block->res,JMI_BLOCK_NOMINAL);
        block->F(jmi,block->min,block->res,JMI_BLOCK_MIN);
        block->F(jmi,block->max,block->res,JMI_BLOCK_MAX);
        block->F(jmi,block->initial,block->res,JMI_BLOCK_INITIALIZE);
        /* if the nominal is outside min-max -> fix it! */
        for(i=0; i < block->n; ++i) {
            realtype maxi = block->max[i];
            realtype mini = block->min[i];
            realtype nomi = block->nominal[i];
            realtype initi = block->initial[i];
            booleantype hasSpecificMax = (maxi != BIG_REAL);
            booleantype hasSpecificMin = (mini != -BIG_REAL);
            booleantype nominalOk = TRUE;
            if((nomi > maxi) || (nomi < mini))
                nominalOk = FALSE;

            if(!nominalOk) {
                /* fix the nominal value to be inside the allowed range */
                if((initi > mini) && (initi < maxi) && (initi != 0.0)) {
                    block->nominal[i] = initi;
                }
                else if(hasSpecificMax && hasSpecificMin) {
                    block->nominal[i] = (maxi + mini) / 2;
                    if(    (maxi * mini < 0) 
                        && (fabs(block->nominal[i]) < 1e-2*maxi ))
                        /* in case of the almost symmetric range take 1% of max */
                        block->nominal[i] = 1e-2*maxi;
                }
                else if(hasSpecificMin)
                    block->nominal[i] = 
                            (mini == 0.0) ? 
                                1.0: 
                                (mini > 0)?
                                    mini * (1+UNIT_ROUNDOFF):
                                    mini * (1-UNIT_ROUNDOFF);
                else {
                    block->nominal[i] = 
                            (maxi == 0.0) ? 
                                -1.0: 
                                (maxi > 0)? 
                                    maxi * (1-UNIT_ROUNDOFF):
                                    maxi * (1+UNIT_ROUNDOFF);
                }
            }
            block->x[i] = initi;
        }
        
    }
    /*
     * A proper local even iteration should problably be done here.
     * Right now event handling at top level will iterate.
     */
    
    if (jmi->atEvent != 0) {
        block->F(jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
    }
    
    ef = block->solve(block);

    if(block->init) {
        /* 
            This needs to be done after "solve" so that block 
            can finalize initialization at the first step.
        */
        block->init = 0;
    }
    c1 = clock();
    /* Make information available for logger */
    block->nb_calls++;
	block->time_spent += ((double)(c1-c0))/(CLOCKS_PER_SEC);
    return ef;
}

int jmi_delete_block_residual(jmi_block_residual_t* b){
	free(b->x);
	if (b->n_nr>0) {
		free(b->x_nr);
	}
	free(b->dx);
	free(b->dv);
	free(b->res);
	free(b->dres);
	free(b->jac);
	free(b->ipiv);
	free(b->min);
	free(b->max);
	free(b->nominal);
	/* clean up the solver.*/
    b->delete_solver(b);

    /*Deallocate struct */
	free(b);
	return 0;
}

int jmi_ode_unsolved_block_dir_der(jmi_t *jmi, jmi_block_residual_t *current_block){
	int i;
	int j;
    char trans;
	int INFO;
	int n_x;
	int nrhs;
    int ef;
	nrhs = 1;
	INFO = 0;
  	n_x = current_block->n;
  	
	/* We now assume that the block is solved, so first we retrieve the
           solution of the equation system - put it into current_block->x 
	*/

  	for (i=0;i<n_x;i++) {
  		current_block->dx[i] = 0;
  	}

  	ef = current_block->dF(jmi, current_block->x, current_block->dx,current_block->res, current_block->dv, JMI_BLOCK_INITIALIZE);

	/* Evaluate the right hand side of the linear system we would like to solve. This is
           done by evaluating the AD function with a seed vector dv (corresponding to
           inputs and states - which are known) and the entries of dz (corresponding
           to states and derivatives) that have already been solved. The seeding
           vector is set internally in the block function. Note that both dv and dz are
           stored in the vector jmi-dz. The output argument is
           current_block->dv, where the right hand side is stored. */
  	ef |= current_block->dF(jmi, current_block->x, current_block->dx,current_block->res, current_block->dv, JMI_BLOCK_EVALUATE_INACTIVE);

    /* Now we evaluate the system matrix of the linear system. */
  	if (!current_block->jmi->cached_block_jacobians==1) {
  		/* Evaluate Jacobian */
  		current_block->evaluate_jacobian(current_block, current_block->jac);
  		/* Factorize Jacobian */
  		dgetrf_(&n_x, &n_x, current_block->jac, &n_x, current_block->ipiv, &INFO);
  	}

	trans = 'N'; /* No transposition */
	i = 1; /* One rhs to solve for */

	/* Perform a back-solve */
	dgetrs_(&trans, &n_x, &i, current_block->jac, &n_x, current_block->ipiv, current_block->dv, &n_x, &INFO);

	/* Write back results into the global dz vector. */
  	ef |= current_block->dF(jmi, current_block->x, current_block->dx, current_block->res, current_block->dv, JMI_BLOCK_WRITE_BACK);

  	return ef;
}

