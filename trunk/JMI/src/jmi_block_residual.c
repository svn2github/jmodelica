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


int jmi_dae_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int index) {
	jmi_block_residual_t* b;
	int flag;
	flag = jmi_new_block_residual(&b,jmi, JMI_KINSOL, F,dF,n,n_nr,index);
	jmi->dae_block_residuals[index] = b;
	return flag;
}

int jmi_dae_init_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int index) {
	jmi_block_residual_t* b;
	int flag;
	flag = jmi_new_block_residual(&b,jmi, JMI_KINSOL, F,dF,n,n_nr,index);
	jmi->dae_init_block_residuals[index] = b;
	return flag;
}

int jmi_new_block_residual(jmi_block_residual_t** block, jmi_t* jmi, jmi_block_solvers_t solver, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int index){
	jmi_block_residual_t* b = (jmi_block_residual_t*)calloc(1,sizeof(jmi_block_residual_t));
    int flag = 0;
    if(!b) return -1;
	*block = b;
	
	int i;

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

	b->F(jmi,b->min,b->res,JMI_BLOCK_MIN);
	b->F(jmi,b->max,b->res,JMI_BLOCK_MAX);
	b->F(jmi,b->nominal,b->res,JMI_BLOCK_NOMINAL);

    switch(solver) {
    case JMI_KINSOL: {
        jmi_kinsol_solver_t* solver;    
        flag = jmi_kinsol_new(&solver, b);
        b->solver = solver;
        b->solve = jmi_kinsol_solve;
        b->delete_solver = jmi_kinsol_delete;
    }
        break;
        
    case JMI_SIMPLE_NEWTON: {
        b->solver = 0;
        b->solve = jmi_simple_newton_solve;
        b->delete_solver = jmi_simple_newton_delete;
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
        /* Initialize the work vector */
		block->F(jmi,block->x,block->res,JMI_BLOCK_INITIALIZE);
        block->init = 0;
    }
    /*
     * A proper local even iteration should problably be done here.
     * Right now event handling at top level will iterate.
     */
    
    if (jmi->atEvent != 0) {
        block->F(jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
    }
    
    ef = block->solve(block);

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
    for(i = 0; i < n_x; i++){
    	current_block->dx[i] = 1;
    	ef |= current_block->dF(current_block->jmi,current_block->x,current_block->dx,current_block->res,current_block->dres,JMI_BLOCK_EVALUATE);
    	for(j = 0; j < n_x; j++){
  			current_block->jac[i*n_x+j] = current_block->dres[j];
    	}
    	current_block->dx[i] = 0;
  	}

    /* Solve linear equation system to get dz_i for the block */
 	dgesv_( &n_x, &nrhs, current_block->jac, &n_x, current_block->ipiv, current_block->dv, &n_x, &INFO );	
    /* Write back results into the global dz vector. */
  	ef |= current_block->dF(jmi, current_block->x, current_block->dx, current_block->res, current_block->dv, JMI_BLOCK_WRITE_BACK);

  	return ef;
}

