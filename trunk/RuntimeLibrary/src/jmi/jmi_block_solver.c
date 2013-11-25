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
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "jmi_log.h"
#include "jmi_simple_newton.h"
#include "jmi_kinsol_solver.h"
#include "jmi_linear_solver.h"
#include "jmi_block_solver_impl.h"

/**
 * \brief Allocate the internal structure for the block solver.
 */
int jmi_new_block_solver(jmi_block_solver_t** block_solver_ptr, 
                           jmi_callbacks_t* cb, 
                           jmi_log_t* log,                          
                           jmi_block_solver_residual_func_t F, 
                           jmi_block_solver_dir_der_func_t dF,
                           jmi_block_solver_check_discrete_variables_change_func_t check_discrete_variables_change,
                           jmi_block_solver_update_discrete_variables_func_t update_discrete_variables,
                           jmi_block_solver_log_discrete_variables log_discrete_variables,
                           int n,                            
                           jmi_block_solver_options_t* options,
                           void* problem_data){
    jmi_block_solver_t* block_solver = (jmi_block_solver_t*)calloc(1, sizeof(jmi_block_solver_t));
    if(!block_solver) {
        jmi_log_comment(log, logError, "Coupld not allocate memory for block solver");
        return 1;
    }
    *block_solver_ptr = block_solver;

    block_solver->problem_data = problem_data;
    block_solver->callbacks = cb;
    block_solver->options = options;
    block_solver->log = log;
    block_solver->id = options->id;

    block_solver->n = n;                         /**< \brief The number of iteration variables */
    block_solver->x = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));                 /**< \brief Work vector for the real iteration variables */

    block_solver->dx=(jmi_real_t*)calloc(n,sizeof(jmi_real_t));;                /**< \brief Work vector for the seed vector */

     block_solver->res = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    block_solver->dres = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    block_solver->jac  = (jmi_real_t*)calloc(n*n,sizeof(jmi_real_t));
    block_solver->ipiv = (int*)calloc(2*n+1,sizeof(int));
    block_solver->init = 1;
      
    block_solver->min = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    block_solver->max = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    block_solver->nominal = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    block_solver->initial = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    block_solver->value_references = (jmi_int_t*)calloc(n,sizeof(jmi_int_t));
#if 0
    block_solver->message_buffer = (char*)calloc(n*500+2000,sizeof(char));
#else
    block_solver->message_buffer = 0;
#endif
    
    block_solver->jacobian_variability = options->jacobian_variability;

    block_solver->cur_time = 0;
    switch(options->solver) {
        case JMI_KINSOL_SOLVER: {
            jmi_kinsol_solver_t* solver;    
            jmi_kinsol_solver_new(&solver, block_solver);
            block_solver->solver = solver;
            block_solver->solve = jmi_kinsol_solver_solve;
            block_solver->delete_solver = jmi_kinsol_solver_delete;
        }
        break;

        case JMI_SIMPLE_NEWTON_SOLVER: {
            block_solver->solver = 0;
            block_solver->solve = jmi_simple_newton_solve;
            block_solver->delete_solver = jmi_simple_newton_delete;
        }
        break;

        case JMI_LINEAR_SOLVER: {
            jmi_linear_solver_t* solver;
            jmi_linear_solver_new(&solver, block_solver);
            block_solver->solver = solver;
            block_solver->solve = jmi_linear_solver_solve;
            block_solver->delete_solver = jmi_linear_solver_delete;
        }
        break;

    default:
        assert(0);
    }
    
    block_solver->init = 1;

    block_solver->F = F;
    block_solver->dF =dF;
    block_solver->check_discrete_variables_change = check_discrete_variables_change;
    block_solver->update_discrete_variables = update_discrete_variables;
    block_solver->log_discrete_variables = log_discrete_variables;

    block_solver->nb_calls = 0;                    /**< \brief Nb of times the block has been solved */
    block_solver->nb_iters = 0;                     /**< \breif Total nb if iterations of non-linear solver */
    block_solver->nb_jevals  = 0;
    block_solver->nb_fevals = 0;
    block_solver->time_spent  = 0;             /**< \brief Total time spent in non-linear solver */
    block_solver->message_buffer = 0 ; /**< \brief Message buffer used for debugging purposes */
    return 0;
}

void jmi_delete_block_solver(jmi_block_solver_t** block_solver_ptr) {
    jmi_block_solver_t* block_solver = * block_solver_ptr;
    * block_solver_ptr = 0;
    if(!block_solver) return;
    block_solver->delete_solver(block_solver);

    free(block_solver->x);

    free(block_solver->dx);

    free(block_solver->res);
    free(block_solver->dres);
    free(block_solver->jac);
    free(block_solver->ipiv);
      
    free(block_solver->min);
    free(block_solver->max);
    free(block_solver->nominal);
    free(block_solver->initial);
    free(block_solver->value_references);
    free(block_solver->message_buffer);
    free(block_solver);

}


static void compute_reduced_step(jmi_real_t h, jmi_real_t* x_new, jmi_real_t* x, jmi_real_t* x_target, jmi_int_t size){
    int i;
    for (i=0;i<size;i++){
        x_target[i] = x[i]+(h)*(x_new[i]-x[i]);
    }
}

static jmi_real_t compute_minimal_step(jmi_block_solver_t* block_solver, jmi_real_t* x, jmi_real_t* x_new, jmi_real_t tolerance){
    jmi_real_t a = 0.0;
    jmi_real_t b = 1.0;
    jmi_real_t h;
    jmi_real_t *x_temp;
    int non_reals_not_changed;
    
    x_temp = (jmi_real_t*)calloc(block_solver->n, sizeof(jmi_real_t));
    
    while (1){
        h = (b-a)/2.0;
        
        compute_reduced_step(a+h,x_new,x,x_temp,block_solver->n);
        
        /* block_solver->F(block_solver->problem_data,x_temp,NULL,JMI_BLOCK_WRITE_BACK); */
        
        non_reals_not_changed = block_solver->check_discrete_variables_change(block_solver->problem_data, x_temp);
               
        if (non_reals_not_changed){
            a = a+h;
        }else{
            b = b-h;
        }
        if ( b-a < tolerance){
            break;
        }
    }
    
    free(x_temp);
    
    return b;
}


int jmi_block_solver_solve(jmi_block_solver_t * block_solver, double cur_time, int handle_discrete_changes) {
    int ef;
    clock_t c0,c1; /*timers*/
    jmi_log_t* log = block_solver->log;
    /* jmi_callbacks_t* cb = block_solver->callbacks; */
    jmi_block_solver_options_t* options = block_solver->options;
    jmi_real_t* x_new;
    jmi_real_t* x;
    jmi_int_t converged;
    jmi_real_t h;

    c0 = clock();
    block_solver->cur_time = cur_time;

    if(block_solver->init) {
        int i;
        jmi_real_t* real_vrs = (jmi_real_t*)calloc(block_solver->n,sizeof(jmi_real_t));
        /* Initialize the work vectors */
        for(i=0; i < block_solver->n; ++i) {
            if(options->iteration_variable_scaling_mode == jmi_iter_var_scaling_heuristics) {
                block_solver->nominal[i] = BIG_REAL;
            }
            else {
                block_solver->nominal[i] = 1.0;
            }
            block_solver->max[i] = BIG_REAL;
            block_solver->min[i] = -block_solver->max[i];
        }
        if(options->iteration_variable_scaling_mode != jmi_iter_var_scaling_none) {
            block_solver->F(block_solver->problem_data,block_solver->nominal,block_solver->res,JMI_BLOCK_NOMINAL);
        }
        block_solver->F(block_solver->problem_data,block_solver->min,block_solver->res,JMI_BLOCK_MIN);
        block_solver->F(block_solver->problem_data,block_solver->max,block_solver->res,JMI_BLOCK_MAX);
        block_solver->F(block_solver->problem_data,block_solver->initial,block_solver->res,JMI_BLOCK_INITIALIZE);
        block_solver->F(block_solver->problem_data,real_vrs,block_solver->res,JMI_BLOCK_VALUE_REFERENCE);

        for (i=0;i<block_solver->n;i++) {
            block_solver->value_references[i] = (int)real_vrs[i];
        }
        
        
        /* if the nominal is outside min-max -> fix it! */
        for(i=0; i < block_solver->n; ++i) {
            realtype maxi = block_solver->max[i];
            realtype mini = block_solver->min[i];
            realtype nomi = block_solver->nominal[i];
            realtype initi = block_solver->initial[i];
            booleantype hasSpecificMax = (maxi != BIG_REAL);
            booleantype hasSpecificMin = (mini != -BIG_REAL);
            booleantype nominalOk = TRUE;
            
            if(nomi == BIG_REAL) {
                nominalOk = FALSE; /* no nominal set and heuristics is activated */
            } else if((nomi > maxi) || (nomi < mini)) { /* nominal outside min-max */
                jmi_log_node(block_solver->log, logWarning, "Warning",
                    "Nominal value is outside min-max range for the iteration variable."
                    , block_solver->id, i);
            }
            
            if(!nominalOk) {
                /* fix the nominal value to be inside the allowed range */
                if((initi > mini) && (initi < maxi) && (initi != 0.0)) {
                    block_solver->nominal[i] = initi;
                }
                else if(hasSpecificMax && hasSpecificMin) {
                    nomi = (maxi + mini) / 2;
                    if( /* min&max have different sign */
                            (maxi * mini < 0) && 
                            /* almost symmetric range */
                            (fabs(nomi) < 1e-2*maxi ))
                        /* take 1% of max  */
                        nomi = 1e-2*maxi;

                     block_solver->nominal[i] = nomi;
                }
                else if(hasSpecificMin)
                    block_solver->nominal[i] = 
                            (mini == 0.0) ? 
                                1.0: 
                                (mini > 0)?
                                    mini * (1+UNIT_ROUNDOFF):
                                    mini * (1-UNIT_ROUNDOFF);
                else if (hasSpecificMax){
                    block_solver->nominal[i] = 
                            (maxi == 0.0) ? 
                                -1.0: 
                                (maxi > 0)? 
                                    maxi * (1-UNIT_ROUNDOFF):
                                    maxi * (1+UNIT_ROUNDOFF);
                }
                else
                    /* take 1.0 as default*/
                    block_solver->nominal[i] = 1.0;
            }
            if(block_solver->nominal[i] < 0) /* according to spec negative nominal is fine but solver expects positive.*/
                block_solver->nominal[i] = -block_solver->nominal[i];
            block_solver->x[i] = initi;
        }
        free(real_vrs);
        /*        block_solver->F(block_solver->jmi,block_solver->x, block_solver->res, JMI_BLOCK_EVALUATE); */
    }
    
    if (handle_discrete_changes) {
        int iter;
        jmi_log_node_t top_node = jmi_log_enter_fmt(log, logInfo, "BlockEventIterations",
                                      "Starting block (local) event iteration at <t:%E> in <block:%d>",
                                      cur_time, block_solver->id);
       
        jmi_log_reals(log, top_node, logInfo, "ivs", block_solver->x, block_solver->n);

        if(block_solver->log_discrete_variables)
            block_solver->log_discrete_variables(block_solver->problem_data,top_node);

        converged = 0;
        ef = 0;
        if(options->experimental_mode & jmi_block_solver_experimental_converge_switches_first) {
            while(1) {
                jmi_log_node_t iter_node;
                int non_reals_changed_flag;
    
                iter = 1;

                iter_node = jmi_log_enter_fmt(log, logInfo, "SwitchIteration", "Local iteration <iter:%d> at <t:%E>",
                                              iter, cur_time);
                
                /* Evaluate the block to update dependent variables if any */
                ef = block_solver->F(block_solver->problem_data,block_solver->x,block_solver->res,JMI_BLOCK_EVALUATE);

                if(ef != 0) {
                    jmi_log_fmt(log, iter_node, logError, "Problem calling residual function <block:%d, iter:%d> at <t:%E>",
                                block_solver->id, iter, cur_time);
                    jmi_log_leave(log, iter_node);
                    break;
                }
                
                /* jmi_update_non_reals(jmi_block_residual_t* block, int* non_reals_changed_flag) */
                ef =  block_solver->update_discrete_variables(block_solver->problem_data, &non_reals_changed_flag);
                if(ef != 0) { 
                    switch(ef) {
                        case jmi_block_solver_status_err_event_eval:
                            jmi_log_fmt(log, iter_node, logError, "Error evaluating switches <block:%d, iter:%d> at <t:%E>",
                                block_solver->id, iter, cur_time);
                            break;
                        case jmi_block_solver_status_err_f_eval:
                            jmi_log_fmt(log, iter_node, logError, "Error updating discrete variables <block:%d, iter:%d> at <t:%E>",
                                block_solver->id, iter, cur_time);
                            break;
                        case jmi_block_solver_status_inf_event_loop:
                            jmi_log_fmt(log, iter_node, logError, "Detected infinite loop in fixed point iteration at <t:%g>", cur_time);
                            break;
                        case jmi_block_solver_status_event_non_converge:
                            jmi_log_fmt(log, iter_node, logError, "Failed to converge during switches iteration due to too many iterations at <t:%E>", cur_time);
                            break;
                        default:
                            break;
                    };
                    jmi_log_leave(log, iter_node); 
                    break; 
                }
                
                block_solver->log_discrete_variables(block_solver->problem_data,top_node);
                if(!non_reals_changed_flag) {
                    jmi_log_fmt(log, iter_node, logInfo, "Found consistent switched state before solving at <t:%g>",
                                cur_time);
                    break;
                }
                jmi_log_leave(log, iter_node);
            }
        }
        
        iter = 0;
        while (1){
            jmi_log_node_t iter_node;
            int non_reals_changed_flag;

            iter += 1;

            iter_node = jmi_log_enter_fmt(log, logInfo, "BlockIteration", "Local iteration <iter:%d> at <t:%E>",
                                          iter, cur_time);
            /* Solve block */
            ef = block_solver->solve(block_solver); 
            if(block_solver->init) {
            /* 
                This needs to be done after "solve" so that block 
                can finalize initialization at the first step.
            */
                block_solver->init = 0;
            }

            if (ef!=0){ jmi_log_leave(log, iter_node); break; }
            
            ef = block_solver->update_discrete_variables(block_solver->problem_data, &non_reals_changed_flag);
            
            jmi_log_reals(log, iter_node, logInfo, "ivs", block_solver->x, block_solver->n);
            if(block_solver->log_discrete_variables)
                block_solver->log_discrete_variables(block_solver->problem_data, iter_node);

            if(ef != 0) { 
                jmi_log_fmt(log, iter_node, logError, "Error in discrete variables update"
                            "<block:%d, iter:%d> at <t:%E>", block_solver->id, iter, cur_time);
                jmi_log_leave(log, iter_node); 
                break; 
            }
            
            if(!non_reals_changed_flag) {
                jmi_log_fmt(log, iter_node, logInfo, "Found consistent solution using fixed point iteration at "
                            "<t:%E>", cur_time);

                converged = 1;
                jmi_log_leave(log, iter_node);
                break;
            }

            jmi_log_leave(log, iter_node);
        }
        
        /* ENHANCED FIXED POINT ITERATION */
        if (converged==0 && (ef==0 || ef==jmi_block_solver_status_event_non_converge || ef==jmi_block_solver_status_inf_event_loop) && block_solver->check_discrete_variables_change){
            int non_reals_changed_flag;
            jmi_log_node_t ebi_node = jmi_log_enter_fmt(log, logInfo, "EnhancedBlockIterations",
                "Starting enhanced block iteration at <t:%E>", cur_time);

            x_new = (jmi_real_t*)calloc(block_solver->n, sizeof(jmi_real_t));
            x = (jmi_real_t*)calloc(block_solver->n, sizeof(jmi_real_t));            
            memcpy(x,block_solver->x,block_solver->n*sizeof(jmi_real_t));

            /* Solve block */
            ef = block_solver->solve(block_solver);

            memcpy(x_new,block_solver->x,block_solver->n*sizeof(jmi_real_t));

            ef = block_solver->update_discrete_variables(block_solver->problem_data, &non_reals_changed_flag);

            iter = 0;
            while (1 && ef==0){

                jmi_log_node_t iter_node = jmi_log_enter_fmt(log, logInfo, "BlockIteration", 
                    "Enhanced block iteration <iter:%d> at <t:%g>",
                    iter, cur_time);

                iter += 1;

                h = compute_minimal_step(block_solver, x, x_new, 1e-4);
                compute_reduced_step(h,x_new,x,x,block_solver->n);

                block_solver->F(block_solver->problem_data,x,NULL,JMI_BLOCK_WRITE_BACK);

                ef = block_solver->update_discrete_variables(block_solver->problem_data, &non_reals_changed_flag);

                if(ef != 0) { 
                    switch(ef) {
                    case jmi_block_solver_status_err_event_eval:
                        jmi_log_fmt(log, iter_node, logError, "Error evaluating switches <block:%d, iter:%d> at <t:%E>",
                            block_solver->id, iter, cur_time);
                        break;
                    case jmi_block_solver_status_err_f_eval:
                        jmi_log_fmt(log, iter_node, logError, "Error updating discrete variables <block:%d, iter:%d> at <t:%E>",
                            block_solver->id, iter, cur_time);
                        break;
                    case jmi_block_solver_status_inf_event_loop:
                        jmi_log_fmt(log, iter_node, logError, "Detected infinite loop in fixed point iteration at <t:%g>", cur_time);
                        break;
                    case jmi_block_solver_status_event_non_converge:
                        jmi_log_fmt(log, iter_node, logError, "Failed to converge during switches iteration due to too many iterations at <t:%E>", cur_time);
                        break;
                    default:
                        break;
                    };
                    break;
                }

                ef = block_solver->solve(block_solver); 

                if (ef!=0){ jmi_log_leave(log, iter_node); break; }

                memcpy(x_new, block_solver->x, block_solver->n*sizeof(jmi_real_t));

                jmi_log_reals(log, iter_node, logInfo, "ivs", block_solver->x, block_solver->n);
                block_solver->log_discrete_variables(block_solver->problem_data, iter_node);

                non_reals_changed_flag = block_solver->check_discrete_variables_change(block_solver->problem_data, x_new);

                /* Check for consistency */
                if (non_reals_changed_flag){
                    jmi_log_fmt(log, iter_node, logInfo, "Found consistent solution using enhanced fixed point iteration at "
                        "<t:%E>", cur_time);
                    converged = 1;
                    jmi_log_leave(log, iter_node);
                    break;
                }

                jmi_log_leave(log, iter_node);
            }

            free(x_new);
            free(x);

            jmi_log_leave(log, ebi_node);
        }
        
        if(converged==0){
            jmi_log_fmt(log, top_node, logError, "Failed to find a consistent solution in event iteration at <t:%g>",
                        cur_time);
            ef = 1; /* Return flag */
        }
        jmi_log_leave(log, top_node);
    }
    else{
        ef = block_solver->solve(block_solver);
    }

    if(block_solver->init) {
        /* 
        This needs to be done after "solve" so that block 
        can finalize initialization at the first step.
        */
        block_solver->init = 0;
    }
    
    c1 = clock();
    /* Make information available for logger */
    block_solver->nb_calls++;
    block_solver->time_spent += ((double)(c1-c0))/(CLOCKS_PER_SEC);
    return ef;
}

void jmi_block_solver_init_default_options(jmi_block_solver_options_t* bsop) {
    bsop->res_tol = 1e-6;
    /* Default Kinsol tolerance (machine precision pwr 1/3)  -> 1e-6 */
    /* We use tighter:  1e-12 */
    bsop->min_tol = 1e-12;       /**< \brief Minimum tolerance for the equation block solver */
    bsop->max_iter = 100;

    bsop->enforce_bounds_flag = 1;  /**< \brief Enforce min-max bounds on variables in the equation blocks*/
    bsop->use_jacobian_equilibration_flag = 0; 
    bsop->use_Brent_in_1d_flag = 0;            /**< \brief If Brent search should be used to improve accuracy in solution of 1D non-linear equations */

    bsop->block_jacobian_check = 0;
    bsop->block_jacobian_check_tol = 1e-6;

    bsop->residual_equation_scaling_mode = jmi_residual_scaling_auto;  
    bsop->iteration_variable_scaling_mode = jmi_iter_var_scaling_nominal;
    bsop->rescale_each_step_flag = 0;
    bsop->rescale_after_singular_jac_flag = 0;
    bsop->check_jac_cond_flag = 0;  /**< \brief NLE solver should check Jacobian condition number and log it. */
    bsop->experimental_mode = 0;
    bsop->solver = JMI_KINSOL_SOLVER;
    bsop->jacobian_variability = JMI_CONTINUOUS_VARIABILITY;
    bsop->id = 0;
}
