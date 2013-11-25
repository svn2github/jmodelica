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
#include "jmi_log.h"

#define nbr_allocated_iterations 30


int jmi_dae_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, jmi_block_solver_kind_t solver, int index) {
    jmi_block_residual_t* b;
    int flag;
    flag = jmi_new_block_residual(&b,jmi, solver, F, dF, n, n_nr, jacobian_variability, index);
    jmi->dae_block_residuals[index] = b;
    return flag;
}

int jmi_dae_init_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, jmi_block_solver_kind_t solver, int index) {
    jmi_block_residual_t* b;
    int flag;
    flag = jmi_new_block_residual(&b,jmi, solver, F, dF, n, n_nr, jacobian_variability, index);
    jmi->dae_init_block_residuals[index] = b;
    return flag;
}

int jmi_block_residual(void* b, double* x, double* residual, int mode) {
    jmi_block_residual_t* block = (jmi_block_residual_t*)b;
    return block->F(block->jmi, x, residual, mode);
}

int jmi_block_dir_der(void* b, jmi_real_t* x, jmi_real_t* dx,jmi_real_t* residual, jmi_real_t* dRes, int mode) {
    jmi_block_residual_t* block = (jmi_block_residual_t*)b;
    jmi_t* jmi = block->jmi;
    jmi_real_t* store_dz = jmi->dz[0]; 
    int i, ef;
    jmi->dz[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];
    jmi->dz_active_variables[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];

    for (i=0;i<jmi->n_v;i++) {
        jmi->dz_active_variables[0][i] = 0;
    }

    ef = block->dF(block->jmi,x,dx,residual,dRes,mode);
    jmi->dz_active_variables[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];
    jmi->dz[0] = store_dz;
    return ef;
}

int jmi_block_check_discrete_variables_change(void* b, double* x) {
    jmi_block_residual_t* block = (jmi_block_residual_t*)b;
    jmi_t* jmi = block->jmi;

    jmi_real_t* sw_current = jmi_get_sw(jmi);
    jmi_real_t* sw_new = &block->sw_old[block->event_iter+1];
    int ef;

    block->F(jmi,x,NULL,JMI_BLOCK_WRITE_BACK);

    ef = jmi_evaluate_switches(jmi,sw_new,block->mode_sw);
    return ef || jmi_compare_switches(sw_current,sw_new,block->n_sw);
}

int jmi_block_log_discrete_variables(void* b, jmi_log_node_t node) {
    jmi_block_residual_t* block = (jmi_block_residual_t*)b;
    jmi_t* jmi = block->jmi;
    jmi_real_t* switches = jmi_get_sw(jmi);
    int nbr_bool = jmi->n_boolean_d;
    jmi_real_t* booleans = jmi_get_boolean_d(jmi);
    jmi_log_reals(jmi->log, node, logInfo, "switches", switches, block->n_sw);
    jmi_log_reals(jmi->log, node, logInfo, "booleans", booleans, nbr_bool);
    return 0;
}

jmi_block_solver_status_t jmi_block_update_discrete_variables(void* b, int* non_reals_changed_flag) {
    jmi_block_residual_t* block = (jmi_block_residual_t*)b;
    jmi_t* jmi = block->jmi;
    double cur_time = jmi_get_t(jmi)[0];
    jmi_log_t* log = jmi->log;

    jmi_real_t* switches = jmi_get_sw(jmi);
    int nbr_bool = jmi->n_boolean_d;
    jmi_real_t* booleans = jmi_get_boolean_d(jmi);
    int iter = block->event_iter;

    jmi_real_t* sw_last = &block->sw_old[block->event_iter*block->n_sw];
    jmi_real_t* bool_last = &block->bool_old[block->event_iter*nbr_bool];

    int mode_sw = block->mode_sw, ef;
    *non_reals_changed_flag = 1;

    /* Store the old switches */
    memcpy(sw_last, switches, block->n_sw*sizeof(jmi_real_t));
    memcpy(bool_last, booleans, nbr_bool*sizeof(jmi_real_t));

    ef = jmi_evaluate_switches(jmi,switches,mode_sw);

    if (ef) {
        jmi_log_fmt(log, jmi_log_get_current_node(log), logError, "Error evaluating switches <block:%d, iter:%d> at <t:%E>",
            block->index, iter, cur_time);
        return jmi_block_solver_status_err_event_eval;
    }
    ef = block->F(jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
    if (ef) {
        jmi_log_fmt(log, jmi_log_get_current_node(log), logError, "Error updating discrete variables <block:%d, iter:%d> at <t:%E>",
             block->index, iter, cur_time);
        return jmi_block_solver_status_err_f_eval;
    }

    /* Check for consistency */
    if (jmi_compare_switches(sw_last,switches,block->n_sw) && jmi_compare_switches(bool_last,booleans,nbr_bool)){
        *non_reals_changed_flag = 0;
    }
    else {
        /* Check for infinite loop */
        /* if(iter >= nbr_allocated_iterations/2 && jmi_check_infinite_loop(sw_last,switches,block->n_sw,iter)){ */
        if(jmi_check_infinite_loop(block->sw_old,switches,block->n_sw,iter)){
            jmi_log_fmt(log, jmi_log_get_current_node(log), logError, "Detected infinite loop in fixed point iteration at <t:%g>", cur_time);
            block->event_iter = 0;
            return jmi_block_solver_status_inf_event_loop;
        }
        if(iter >= nbr_allocated_iterations){
            jmi_log_fmt(log, jmi_log_get_current_node(log), logError, "Failed to converge during switches iteration due to too many iterations at <t:%E>", cur_time);
            block->event_iter = 0;
            return jmi_block_solver_status_event_non_converge;
        }

        block->event_iter++;
    }

    /* jmi_log_reals(jmi->log, jmi_log_get_current_node(log), logInfo, "switches", switches, block->n_sw);
    jmi_log_reals(jmi->log, jmi_log_get_current_node(log), logInfo, "booleans", booleans, jmi->n_boolean_d); */

    return jmi_block_solver_status_success;
}


int jmi_new_block_residual(jmi_block_residual_t** block, jmi_t* jmi, jmi_block_solver_kind_t solver, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int jacobian_variability, int index){
    jmi_block_residual_t* b = (jmi_block_residual_t*)calloc(1,sizeof(jmi_block_residual_t));
    /* int i;*/
    int flag = 0;
    if(!b) return -1;
    *block = b;

    b->jacobian_variability = jacobian_variability;
    b->jmi = jmi;
    b->options = &(jmi->options.block_solver_options);
    b->F = F;
    b->dF = dF;
    b->n = n;
    b->n_nr = n_nr;
    b->index = index ;
    b->x = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    /*
        b->x_nr - doesn't seem to be used anywhere
    if (n_nr>0) {
        b->x_nr = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    }
    */
    b->bool_old = 0; /* TODO: check if allocation can be done here*/
    b->sw_old = 0;

        b->dx = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->dv = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->res = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->dres = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->jac = (jmi_real_t*)calloc(n*n,sizeof(jmi_real_t));
    b->ipiv = (int*)calloc(2*n+1,sizeof(int));
    b->init = 1;
      
    b->min = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->max = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->nominal = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->initial = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->value_references = (jmi_int_t*)calloc(n,sizeof(jmi_int_t));
    b->message_buffer = (char*)calloc(n*500+2000,sizeof(char));

    b->options->id = index;
    b->options->solver = solver;
    b->options->jacobian_variability = (jmi_block_solver_jac_variability_t)jacobian_variability;

    jmi_new_block_solver(
        & b->block_solver,
        &jmi->jmi_callbacks,
        jmi->log,
        jmi_block_residual,
        dF ? jmi_block_dir_der:0,
        jmi_block_check_discrete_variables_change,
        jmi_block_update_discrete_variables,
        jmi_block_log_discrete_variables,
        n,
        b->options,
        b);



    switch(solver) {
    case JMI_SIMPLE_NEWTON_SOLVER:
    case JMI_KINSOL_SOLVER: {
        b->evaluate_jacobian = jmi_kinsol_solver_evaluate_jacobian;
    }
        break;

    case JMI_LINEAR_SOLVER: {
        b->evaluate_jacobian = jmi_linear_solver_evaluate_jacobian;
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
    jmi_int_t nF0,nF1,nFp,nR0;
    jmi_int_t nF,nR;

    c0 = clock();

    jmi->block_level++;
    block->event_iter = 0;
    if(block->init) {
        int nbr_bool = jmi->n_boolean_d;
        /* get the number of switches to handle */
        if (jmi->atInitial == JMI_TRUE){
            jmi_init_get_sizes(jmi,&nF0,&nF1,&nFp,&nR0);
            block->n_sw = nR0;
            block->mode_sw = 0; /* INITIALIZE MODE */
        }
        else{
            jmi_dae_get_sizes(jmi, &nF, &nR);
            block->n_sw = nR;
            block->mode_sw = 1; /* NOT INITIALIZE MODE */
        }
        block->sw_old = (double*)calloc( (nbr_allocated_iterations +1)*block->n_sw, sizeof(double));
        block->bool_old= (double*)calloc( (nbr_allocated_iterations +1)*nbr_bool, sizeof(double));

    }
    ef = jmi_block_solver_solve(block->block_solver,jmi_get_t(jmi)[0],
        ((jmi->atInitial == JMI_TRUE || jmi->atEvent == JMI_TRUE)) && (jmi->block_level == 1));

    jmi->block_level--;

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

jmi_int_t jmi_check_infinite_loop(jmi_real_t* sw_old,jmi_real_t *sw, jmi_int_t nR, jmi_int_t iter){
    jmi_int_t i,infinite_loop = 0;
    
    for(i=0;i<iter;i++){
        if(jmi_compare_switches(&sw_old[i*nR],sw,nR)){
            infinite_loop = 1;
            break;
        }
    }
    if (infinite_loop){
        return 1;
    }else{
        return 0;
    }
}

int jmi_block_jacobian_fd(jmi_block_residual_t* b, jmi_real_t* x, jmi_real_t delta_rel, jmi_real_t delta_abs) {
    int i,j;
    jmi_real_t delta = 0.;
    int n = b->n;
    jmi_real_t* fp;
    jmi_real_t* fn;
    int flag = 0;
    
    fp = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    fn = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));

    for (i=0;i<n;i++) {
        if (x[i]<0) {
            delta = (x[i] - delta_abs)*delta_rel;
        } else {
            delta = (x[i] + delta_abs)*delta_rel;
        }
        x[i] = x[i] + delta;

        /* evaluate the residual to get positive side */
        flag |= b->F(b->jmi,x,fp,JMI_BLOCK_EVALUATE);

        x[i] = x[i] - 2.*delta;

        /* evaluate the residual to get negative side */
        flag |= b->F(b->jmi,x,fn,JMI_BLOCK_EVALUATE);

        x[i] = x[i] - delta;

        for (j=0;j<n;j++) {
            b->jac[i*n + j] = (fp[j] - fn[j])/2./delta;
            printf("%12.12e\n",b->jac[i*n + j]);
        }
    }

    free(fp);
    free(fn);
    return flag;
}


int jmi_delete_block_residual(jmi_block_residual_t* b){
    jmi_delete_block_solver(&b->block_solver);
    free(b->x);
/*    if (b->n_nr>0) {
        free(b->x_nr);
    } */
    free(b->dx);
    free(b->dv);
    free(b->res);
    free(b->dres);
    free(b->bool_old);
    free(b->sw_old);
    free(b->jac);
    free(b->ipiv);
    free(b->min);
    free(b->max);
    free(b->nominal);
    free(b->message_buffer);
    free(b->initial);
    free(b->value_references);
    /* clean up the solver.*/

    /*Deallocate struct */
    free(b);
    return 0;
}

int jmi_ode_unsolved_block_dir_der(jmi_t *jmi, jmi_block_residual_t *current_block){
    int i;
    char trans;
    int INFO;
    int n_x;
    /* int nrhs = 1; */
    int ef;

    INFO = 0;
    n_x = current_block->n;
    
    /* We now assume that the block is solved, so first we retrieve the
           solution of the equation system - put it into current_block->x 
    */

    for (i=0;i<n_x;i++) {
        current_block->dx[i] = 0;
    }

    ef = current_block->dF(jmi, current_block->x, current_block->dx,current_block->res, current_block->dv, JMI_BLOCK_INITIALIZE);

    /* Now we evaluate the system matrix of the linear system. */
    if (!current_block->jmi->cached_block_jacobians==1) {
        jmi_real_t* store_dz = jmi->dz[0]; 
        jmi->dz_active_index++;
        jmi->dz[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];
        jmi->dz_active_variables[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];

        for (i=0;i<jmi->n_v;i++) {
            jmi->dz_active_variables[0][i] = 0;
        }
        /* Evaluate Jacobian */
        current_block->evaluate_jacobian(current_block, current_block->jac);
        jmi->dz_active_index--;
        jmi->dz_active_variables[0] = jmi->dz_active_variables_buf[jmi->dz_active_index];
        jmi->dz[0] = store_dz;
        /* Factorize Jacobian */
        dgetrf_(&n_x, &n_x, current_block->jac, &n_x, current_block->ipiv, &INFO);
    }

    /* Evaluate the right hand side of the linear system we would like to solve. This is
           done by evaluating the AD function with a seed vector dv (corresponding to
           inputs and states - which are known) and the entries of dz (corresponding
           to states and derivatives) that have already been solved. The seeding
           vector is set internally in the block function. Note that both dv and dz are
           stored in the vector jmi-dz. The output argument is
           current_block->dv, where the right hand side is stored. */
    ef |= current_block->dF(jmi, current_block->x, current_block->dx,current_block->res, current_block->dv, JMI_BLOCK_EVALUATE_INACTIVE);

    /* Perform a back-solve */
    trans = 'N'; /* No transposition */
    i = 1; /* One rhs to solve for */
    dgetrs_(&trans, &n_x, &i, current_block->jac, &n_x, current_block->ipiv, current_block->dv, &n_x, &INFO);

    /* Write back results into the global dz vector. */
    ef |= current_block->dF(jmi, current_block->x, current_block->dx, current_block->res, current_block->dv, JMI_BLOCK_WRITE_BACK);
    
    return ef;
}

int jmi_kinsol_solver_evaluate_jacobian(jmi_block_residual_t* block, jmi_real_t* jacobian) {
    int i,j;
    int n_x;
    int ef;
    n_x = block->n;

    /* TODO: for nested blocks it is necessary to cache jacobians (since dF leads to jac
       calculation in every sub-block. Therefore ->jmi->cached_block_jacobians
       Probably needs to be done on per-block basis and nested blocks should have access
       to the parent blocks.
       The code does not propagate errors.
    */
    for(i = 0; i < n_x; i++){
        block->dx[i] = 1;
        ef |= block->dF(block->jmi,block->x,block->dx,block->res,block->dres,JMI_BLOCK_EVALUATE);
        for(j = 0; j < n_x; j++){
            jacobian[i*n_x+j] = block->dres[j];
        }
        block->dx[i] = 0;
    }

    return 0;
}

int jmi_linear_solver_evaluate_jacobian(jmi_block_residual_t* block, jmi_real_t* jacobian) {
    /* jmi_linear_solver_t* solver = block->solver; */
    jmi_t * jmi = block->jmi;
    int i;
    /* TODO: This code does not propagate errors.*/
    block->F(jmi,NULL,jacobian,JMI_BLOCK_EVALUATE_JACOBIAN);
    for (i=0;i<block->n*block->n;i++) {
        jacobian[i] = -jacobian[i];
    }
    return 0;
}
