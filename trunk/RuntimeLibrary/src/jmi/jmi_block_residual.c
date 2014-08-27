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
#include "jmi_me.h"

#include "jmi_block_solver_impl.h"

#define nbr_allocated_iterations 30


int jmi_dae_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int n_sw, int jacobian_variability, int attribute_variability, jmi_block_solver_kind_t solver, int index, jmi_string_t label, int parent_index) {
    jmi_block_residual_t* b;
    int flag;
    flag = jmi_new_block_residual(&b,jmi, solver, F, dF, n, n_nr, n_sw, jacobian_variability, index, label);
    jmi->dae_block_residuals[index] = b;
    return flag;
}

int jmi_dae_init_add_equation_block(jmi_t* jmi, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int n_sw, int jacobian_variability, int attribute_variability, jmi_block_solver_kind_t solver, int index, jmi_string_t label, int parent_index) {
    jmi_block_residual_t* b;
    int flag;
    flag = jmi_new_block_residual(&b,jmi, solver, F, dF, n, n_nr, n_sw, jacobian_variability, index, label);
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
    jmi_real_t *switches, *non_reals, *pre_switches, *pre_non_reals;
    jmi_real_t* x_cur = (jmi_real_t*)calloc(block->n, sizeof(jmi_real_t));

    /* Get the current value of the iteration variables. */
    block->F(jmi, x_cur, block->res, JMI_BLOCK_INITIALIZE);

    /* Get previous switches and non-reals */
    pre_switches  = &block->sw_old[(block->event_iter - 1)*block->n_sw];
    pre_non_reals = &block->nr_old[(block->event_iter - 1)*block->n_nr];

    /* Evaluate and get the current switches and non-reals */
    block->F(jmi, x, NULL, JMI_BLOCK_WRITE_BACK);
    block->F(jmi, x, block->res, JMI_BLOCK_EVALUATE | JMI_BLOCK_EVALUATE_NON_REALS);
    switches  = &block->sw_old[block->event_iter*block->n_sw];
    non_reals = &block->nr_old[block->event_iter*block->n_nr];
    jmi_block_get_sw_nr(block, switches, non_reals);

    /* Write back the current values of the iteration variables. */
    block->F(jmi, x_cur, NULL, JMI_BLOCK_WRITE_BACK);
    /* Reset the values of the switches and non-reals in the block by evaluating it with the current iteration variables. */
    block->F(jmi, x_cur, block->res, JMI_BLOCK_EVALUATE | JMI_BLOCK_EVALUATE_NON_REALS);
    free(x_cur);
    
    /* Compare current switches and non-reals with their previous values */
    return jmi_compare_switches(switches, pre_switches, block->n_sw) && jmi_compare_switches(non_reals, pre_non_reals, block->n_nr);
}

int jmi_block_log_discrete_variables(void* b, jmi_log_node_t node) {
    jmi_block_residual_t* block = (jmi_block_residual_t*)b;
    jmi_t* jmi = block->jmi;

    jmi_real_t* switches  = &block->sw_old[(block->event_iter)*block->n_sw];
    jmi_real_t* non_reals = &block->nr_old[(block->event_iter)*block->n_nr];

    /* Get the current values of switches and non-reals */
    jmi_block_get_sw_nr(block, switches, non_reals);

    jmi_log_reals(jmi->log, node, logInfo, "active switches", switches, block->n_sw);
    jmi_log_reals(jmi->log, node, logInfo, "non-reals", non_reals, block->n_nr);
    jmi_log_ints(jmi->log, node, logInfo, "valuereference of non-reals", block->nr_vref, block->n_nr);
    return 0;
}

jmi_block_solver_status_t jmi_block_update_discrete_variables(void* b, int* non_reals_changed_flag) {
    jmi_block_residual_t* block = (jmi_block_residual_t*)b;
    jmi_t* jmi = block->jmi;
    double cur_time = jmi_get_t(jmi)[0];
    jmi_log_t* log = jmi->log;
    int iter = block->event_iter;
    int ef;

    jmi_real_t *pre_switches, *pre_non_reals;
    jmi_real_t* switches  = &block->sw_old[iter*block->n_sw];
    jmi_real_t* non_reals = &block->nr_old[iter*block->n_nr];

    *non_reals_changed_flag = 1;
    
    if (iter == 0) {
        /* Use part of the old vector as temporary storage */
        pre_switches  = &block->sw_old[(iter + 1)*block->n_sw];
        pre_non_reals = &block->nr_old[(iter + 1)*block->n_nr];
        
        jmi_block_get_sw_nr(block, pre_switches, pre_non_reals);
    } else {
        pre_switches  = &block->sw_old[(iter - 1)*block->n_sw];
        pre_non_reals = &block->nr_old[(iter - 1)*block->n_nr];
    }

    /* Evaluate switches and non-reals */
    ef = block->F(jmi, block->x, block->res, JMI_BLOCK_EVALUATE | JMI_BLOCK_EVALUATE_NON_REALS);
    if (ef) {
        jmi_log_node(log, logError, "Error", "Error updating discrete variables <block:%s, iter:%I> at <t:%E>",
             block->label, iter, cur_time);
        return jmi_block_solver_status_err_f_eval;
    }

    /* Save the current values of the switches and non-reals */
    jmi_block_get_sw_nr(block, switches, non_reals);
    
    
    /* Log updates, NOTE this should in the future also contain which expressions changed! */
    if (jmi->jmi_callbacks.log_options.log_level >= 5 && (block->n_sw > 0 || block->n_nr > 0)){
        int i;
        jmi_log_node_t node;
        jmi_value_reference type;
    
        node =jmi_log_enter_fmt(jmi->log, logInfo, "BlockUpdateOfDiscreteVariables", 
                            "Block updating of discrete variables");
        for (i=0;i<block->n_sw; i++) {
            if (pre_switches[i] != switches[i]) {
                jmi_log_node(jmi->log, logInfo, "Info", " <switch: %I> <value: %d> ", block->sw_index[i]-jmi->offs_sw, (jmi_int_t)switches[i]);
            }
        }
        for (i=0;i<block->n_nr; i++) {
            if (pre_non_reals[i] != non_reals[i]) {
                type = jmi_get_type_from_value_ref(block->nr_vref[i]);
                
                if (type == JMI_INTEGER) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <integer: #i%d#> <value: %d> ", block->nr_vref[i], (jmi_int_t)non_reals[i]);
                } else if (type == JMI_BOOLEAN) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <boolean: #b%d#> <value: %d> ", block->nr_vref[i], (jmi_int_t)non_reals[i]);
                } else if (type == JMI_REAL) {
                        jmi_log_node(jmi->log, logInfo, "Info", " <real: #r%d#> <value: %E> ", block->nr_vref[i], non_reals[i]);
                }
            }
        }
        jmi_log_leave(jmi->log, node);
    }

    if(iter >= nbr_allocated_iterations) {
        jmi_log_node(log, logWarning, "Warning", "Failed to converge during switches iteration due to too many iterations in <block:%s, iter:%I> at <t:%E>",block->label, iter, cur_time);
        block->event_iter = 0;
        return jmi_block_solver_status_event_non_converge;
    }

    /* If it is not the initial update of switches and non-reals, compare switches and non-reals with their previous values */
    if (iter != 0) {

        /* Check for consistency */
        if (jmi_compare_switches(pre_switches, switches, block->n_sw) && jmi_compare_switches(pre_non_reals, non_reals, block->n_nr)) {
            *non_reals_changed_flag = 0;
        } else {
            /* Check for infinite loop */
            if(jmi_check_infinite_loop(block->sw_old, switches, block->n_sw, iter) && jmi_check_infinite_loop(block->nr_old, non_reals, block->n_nr, iter)) {
                jmi_log_node(log, logInfo, "Info", "Detected infinite loop in fixed point iteration in <block:%s, iter:%I> at <t:%E>",block->label, iter, cur_time);
                block->event_iter = 0;
                return jmi_block_solver_status_inf_event_loop;
            }
        }
    }
    
    block->event_iter++;

    return jmi_block_solver_status_success;
}

int jmi_block_get_sw_nr(jmi_block_residual_t* block, jmi_real_t* switches, jmi_real_t* non_reals) {
    int i;
    jmi_t* jmi = block->jmi;

    for (i = 0; i < block->n_sw; i++) {
        switches[i] = (*(jmi->z))[block->sw_index[i]];
    }
    for (i = 0; i < block->n_nr; i++) {
        non_reals[i] = (*(jmi->z))[block->nr_index[i]];
    }
    return 0;
}

int jmi_new_block_residual(jmi_block_residual_t** block, jmi_t* jmi, jmi_block_solver_kind_t solver, jmi_block_residual_func_t F, jmi_block_dir_der_func_t dF, int n, int n_nr, int n_sw, int jacobian_variability, int index, jmi_string_t label){
    jmi_block_residual_t* b = (jmi_block_residual_t*)calloc(1,sizeof(jmi_block_residual_t));
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
    b->n_sw = n_sw;
    b->index = index;
    b->label = (jmi_string_t) calloc(strlen(label) + 1, sizeof(char));
    strcpy(b->label, label);
    b->x = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    /*
        b->x_nr - doesn't seem to be used anywhere
    if (n_nr>0) {
        b->x_nr = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    }
    */
    b->sw_old = (jmi_real_t*)calloc( (nbr_allocated_iterations +2)*b->n_sw, sizeof(jmi_real_t));
    b->nr_old = (jmi_real_t*)calloc( (nbr_allocated_iterations +2)*b->n_nr, sizeof(jmi_real_t));
    b->sw_index = (jmi_int_t*)calloc(b->n_sw, sizeof(jmi_int_t));
    b->nr_index = (jmi_int_t*)calloc(b->n_nr, sizeof(jmi_int_t));
    b->nr_vref  = (jmi_int_t*)calloc(b->n_nr, sizeof(jmi_int_t));

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

    b->options->label = label;
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
    
    case JMI_MINPACK_SOLVER: {
        b->evaluate_jacobian = jmi_kinsol_solver_evaluate_jacobian;
    }
        break;

    default:
        assert(0);
    }

    return flag;
}


int jmi_solve_block_residual(jmi_block_residual_t * block) {
    int ef, i;
    clock_t c0,c1; /*timers*/
    jmi_t* jmi = block->jmi;
    
    c0 = clock();

    jmi->block_level++;
    block->event_iter = 0;
    if(block->init) {
        /* Get the switch indexes and non-real valuereferences. */
        jmi_real_t* nr_vref_tmp = (jmi_real_t*)calloc(block->n_nr,sizeof(jmi_real_t));
        jmi_real_t* sw_index_tmp = (jmi_real_t*)calloc(block->n_sw,sizeof(jmi_real_t));
        block->F(jmi, nr_vref_tmp, NULL, JMI_BLOCK_NON_REAL_VALUE_REFERENCE);
        block->F(jmi, sw_index_tmp, NULL, JMI_BLOCK_ACTIVE_SWITCH_INDEX);

        for (i = 0; i < block->n_sw; i++) {
            block->sw_index[i] = (jmi_int_t)sw_index_tmp[i];
        }
        for (i = 0; i < block->n_nr; i++) {
            block->nr_vref[i] =  (jmi_int_t)nr_vref_tmp[i];
            /* Get index for non-reals from their valuereference */
            block->nr_index[i] = get_index_from_value_ref(block->nr_vref[i]);
        }
        free(nr_vref_tmp);
        free(sw_index_tmp);
    }

    {
        jmi_log_node_t node = jmi_log_enter_fmt(jmi->log, logInfo, "SolverInvocation",
                                  "Starting solver at <t:%E> in <block:%s> with <nvars:%d> variables",
                                  jmi_get_t(jmi)[0], block->block_solver->label, block->block_solver->n);
        ef = jmi_block_solver_solve(block->block_solver,jmi_get_t(jmi)[0],
                 (jmi->atInitial == JMI_TRUE || jmi->atEvent == JMI_TRUE) &&
                 (jmi->block_level == 1) && (block->n_nr > 0 || block->n_sw > 0));
        jmi_log_leave(jmi->log, node);
    }

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

        x[i] = x[i] + delta;

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
    free(b->label);
    free(b->sw_old);
    free(b->nr_old);
    free(b->sw_index);
    free(b->nr_index);
    free(b->nr_vref);
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
