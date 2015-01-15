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
#include "jmi_brent_solver.h"
#include "jmi_linear_solver.h"
#include "jmi_minpack_solver.h"
#include "jmi_block_solver_impl.h"


const double jmi_block_solver_canari = 3.14159;

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
        jmi_log_comment(log, logError, "Could not allocate memory for block solver");
        return 1;
    }
    *block_solver_ptr = block_solver;
    block_solver->canari = jmi_block_solver_canari;
    block_solver->problem_data = problem_data;
    block_solver->callbacks = cb;
    block_solver->options = options;
    block_solver->log = log;
    block_solver->label = options->label;

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
            /* Cannot do this here since options are not set yet */
            /*
            if( (n == 1) 
                && block_solver->options->use_Brent_in_1d_flag
                &&  (block_solver->options->experimental_mode & jmi_block_solver_experimental_Brent) ) {
                jmi_brent_solver_t* solver;
                jmi_brent_solver_new(&solver, block_solver);
                block_solver->solver = solver;
                block_solver->solve = jmi_brent_solver_solve;
                block_solver->delete_solver = jmi_brent_solver_delete;
            }
            else 
            */
            {
                jmi_kinsol_solver_t* solver;
                jmi_kinsol_solver_new(&solver, block_solver);
                block_solver->solver = solver;
                block_solver->solve = jmi_kinsol_solver_solve;
                block_solver->delete_solver = jmi_kinsol_solver_delete;
            }
        }
        break;
        
        case JMI_MINPACK_SOLVER: {
            jmi_minpack_solver_t* solver;    
            jmi_minpack_solver_new(&solver, block_solver);
            block_solver->solver = solver;
            block_solver->solve = jmi_minpack_solver_solve;
            block_solver->delete_solver = jmi_minpack_solver_delete;
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
    block_solver->at_event = 1;

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
#ifdef JMI_PROFILE_RUNTIME 
	block_solver->parent_block = 0;
	block_solver->time_df = 0;
	block_solver->time_f = 0;
	block_solver->time_in_brent = 0;
	block_solver->is_init_block = -1;
#endif
    block_solver->message_buffer = 0 ; /**< \brief Message buffer used for debugging purposes */
    return 0;
}

void jmi_delete_block_solver(jmi_block_solver_t** block_solver_ptr) {
    jmi_block_solver_t* block_solver = * block_solver_ptr;
    * block_solver_ptr = 0;
    if(!block_solver) return;

    if(block_solver->canari != jmi_block_solver_canari) {
        /* something is very wrong */
        assert(block_solver->canari == jmi_block_solver_canari);
        return;
    }

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
               
        if (non_reals_not_changed > 0){
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
    block_solver->at_event = handle_discrete_changes;

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
        
        
        /* if the nominal or initial is outside min-max -> fix it! */
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
                                
                /* relax the condition when bounds have the same sign */
                if((maxi >= 0) && (mini >= 0))
                {
                    nomi = fabs(nomi);
                    if(nomi/10 > maxi) {
                        nominalOk = FALSE;
                    }
                    else if (mini/10 > nomi) {
                        nominalOk = FALSE;
                    }
                }
                else if((maxi <= 0) && (mini <= 0))
                {
                    nomi = fabs(nomi);
                    if(nomi/10 > -mini) {
                        nominalOk = FALSE;
                    }
                    else if (-maxi/10 > nomi) {
                        nominalOk = FALSE;                        
                    }
                }
                else {
                    nominalOk = FALSE;
                }
                if(nominalOk == FALSE) {
                      jmi_log_node(block_solver->log, logWarning, "NominalOutOfBounds",
                             "Nominal value <nominal: %g> may be unsuitable given bounds <min: %g> and <max: %g> "
                             "for the iteration variable <iv: #r%d#> in <block: %s>.",
                             nomi, mini, maxi, block_solver->value_references[i], block_solver->label);
                      nominalOk = TRUE; /* only warning given in this case */
                }
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

            if ((initi > maxi) || (initi < mini)) {
                realtype old_initi = initi;
                initi = initi > maxi ? maxi : mini;
                block_solver->initial[i] = initi;
                jmi_log_node(block_solver->log, logWarning, "StartOutOfBounds",
                             "Start value <start: %g> is not between <min: %g> and <max: %g> "
                             "for the iteration variable <iv: #r%d#> in <block: %s>. Clamping to <clamped_start: %g>.",
                             old_initi, mini, maxi, block_solver->value_references[i], block_solver->label, initi);
            }

            if(block_solver->nominal[i] < 0) /* according to spec negative nominal is fine but solver expects positive.*/
                block_solver->nominal[i] = -block_solver->nominal[i];
            block_solver->x[i] = initi;
        }
        free(real_vrs);
        /*        block_solver->F(block_solver->jmi,block_solver->x, block_solver->res, JMI_BLOCK_EVALUATE); */
    }
    
    if (handle_discrete_changes) {
        int iter, non_reals_changed_flag;
        jmi_log_node_t top_node = jmi_log_enter_fmt(log, logInfo, "BlockEventIterations",
                                      "Starting block (local) event iteration at <t:%E> in <block:%s>",
                                      cur_time, block_solver->label);
       
        jmi_log_reals(log, top_node, logInfo, "ivs", block_solver->x, block_solver->n);

        
        
        /* Save the initial values of the discrete variables for the iteration */
        block_solver->update_discrete_variables(block_solver->problem_data, &non_reals_changed_flag);

        if(block_solver->log_discrete_variables)
            block_solver->log_discrete_variables(block_solver->problem_data,top_node);
        
        converged = 0;
        ef = 0;
        iter = 0;
        while (1){
            jmi_log_node_t iter_node;

            iter_node = jmi_log_enter_fmt(log, logInfo, "BlockIteration", "Event iteration <iter:%I> at <t:%E>",
                                          iter, cur_time);

            {
                char message[256];
                sprintf(message, "Event iteration %d", iter+1);
                jmi_log_node(log, logInfo, "Progress", "<source:%s><block:%s><message:%s><kind:%s><iter:%I>",
                             "jmi_block_solver", block_solver->label, message, "BeginEventIteration", iter);
            }

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
                jmi_log_node(log, logInfo, "Info", "Error in discrete variables update: "
                            "<block:%s, iter:%I> at <t:%E>", block_solver->label, iter, cur_time);
                jmi_log_leave(log, iter_node); 
                break; 
            }
            
            if(!non_reals_changed_flag) {
                jmi_log_fmt(log, iter_node, logInfo, "Found consistent solution using fixed point iteration in <block:%s, iter:%I> at <t:%E>",
                            block_solver->label, iter, cur_time);

                converged = 1;
                jmi_log_leave(log, iter_node);
                break;
            }

            jmi_log_leave(log, iter_node);
            iter += 1;
        }
        
        /* ENHANCED FIXED POINT ITERATION */
        if (converged==0 && (ef==0 || ef==jmi_block_solver_status_event_non_converge || ef==jmi_block_solver_status_inf_event_loop) && block_solver->check_discrete_variables_change){
            int non_reals_changed_flag;
            int non_reals_not_changed_flag;
            jmi_log_node_t ebi_node = jmi_log_enter_fmt(log, logInfo, "EnhancedBlockIterations",
                "Starting enhanced event iteration at <t:%E>", cur_time);

            jmi_log_node(log, logInfo, "Progress", "<source:%s><block:%s><message:%s><kind:%s>",
                         "jmi_block_solver", block_solver->label, "Starting enhanced event iterations",
                         "BeginEnhancedEventIterations");

            x_new = (jmi_real_t*)calloc(block_solver->n, sizeof(jmi_real_t));
            x = (jmi_real_t*)calloc(block_solver->n, sizeof(jmi_real_t));            
            memcpy(x,block_solver->x,block_solver->n*sizeof(jmi_real_t));

            /* Save the initial values of the discrete variables for the iteration */
            block_solver->update_discrete_variables(block_solver->problem_data, &non_reals_changed_flag);

            /* Solve block */
            ef = block_solver->solve(block_solver);
            memcpy(x_new,block_solver->x,block_solver->n*sizeof(jmi_real_t));

            /* Write back the current iteration variables, needed for checking discrete variables. */
            block_solver->F(block_solver->problem_data, x, NULL, JMI_BLOCK_WRITE_BACK);

            iter = 0;
            while (1 && ef==0){

                jmi_log_node_t iter_node = jmi_log_enter_fmt(log, logInfo, "BlockIteration", 
                    "Enhanced block iteration <iter:%I> at <t:%g>",
                    iter, cur_time);

                {
                    char message[256];
                    sprintf(message, "Enhanced event iteration %d", iter+1);
                    jmi_log_node(log, logInfo, "Progress", "<source:%s><block:%s><message:%s><kind:%s><iter:%I>",
                                 "jmi_block_solver", block_solver->label, message,
                                 "BeginEnhancedEventIteration", iter);
                }

                h = compute_minimal_step(block_solver, x, x_new, 1e-4);
                compute_reduced_step(h,x_new,x,x,block_solver->n);
                jmi_log_reals(log, iter_node, logInfo, "step", &h, 1);

                block_solver->F(block_solver->problem_data,x,NULL,JMI_BLOCK_WRITE_BACK);

                ef = block_solver->update_discrete_variables(block_solver->problem_data, &non_reals_changed_flag);
                if (non_reals_changed_flag == 0){
                    jmi_log_node(log, logError, "Error", "Error updating discrete variables with the new x <block:%s, iter:%I> at <t:%E>",
                        block_solver->label, iter, cur_time);
                    jmi_log_leave(log, iter_node);
                    break;
                }
                
                if(ef != 0) { 
                    switch(ef) {
                    case jmi_block_solver_status_err_event_eval:
                        jmi_log_node(log, logError, "Error", "Error evaluating switches <block:%s, iter:%I> at <t:%E>",
                            block_solver->label, iter, cur_time);
                        break;
                    case jmi_block_solver_status_err_f_eval:
                        jmi_log_node(log, logError, "Error", "Error updating discrete variables <block:%s, iter:%I> at <t:%E>",
                            block_solver->label, iter, cur_time);
                        break;
                    case jmi_block_solver_status_inf_event_loop:
                        jmi_log_node(log, logError, "Error", "Detected infinite loop in enhanced fixed point iteration in <block:%s, iter:%I> at <t:%E>",
                            block_solver->label, iter, cur_time);
                        break;
                    case jmi_block_solver_status_event_non_converge:
                        jmi_log_node(log, logError, "Error", "Failed to converge during switches iteration due to too many iterations in <block:%s, iter:%I> at <t:%E>",
                            block_solver->label, iter, cur_time);
                        break;
                    default:
                        break;
                    };
                    jmi_log_leave(log, iter_node);
                    break;
                }

                ef = block_solver->solve(block_solver); 
                if (ef!=0){ jmi_log_leave(log, iter_node); break; }

                memcpy(x_new, block_solver->x, block_solver->n*sizeof(jmi_real_t));

                /* Write back the current iteration variables, needed for checking discrete variables. */
                block_solver->F(block_solver->problem_data, x, NULL, JMI_BLOCK_WRITE_BACK);

                /* Log iteration variables and discrete variables. */
                jmi_log_reals(log, iter_node, logInfo, "ivs (old)", x, block_solver->n);
                jmi_log_reals(log, iter_node, logInfo, "ivs (new)", x_new, block_solver->n);
                if(block_solver->log_discrete_variables)
                    block_solver->log_discrete_variables(block_solver->problem_data, iter_node);

                non_reals_not_changed_flag = block_solver->check_discrete_variables_change(block_solver->problem_data, x_new);
                
                if(block_solver->log_discrete_variables)
                    block_solver->log_discrete_variables(block_solver->problem_data, iter_node);

                /* Check for consistency */
                if (non_reals_not_changed_flag > 0){
                    jmi_log_fmt(log, iter_node, logInfo, "Found consistent solution using enhanced fixed point iteration in <block:%s, iter:%I> at <t:%E>",
                        block_solver->label, iter, cur_time);
                    converged = 1;
                    jmi_log_leave(log, iter_node);
                    break;
                }

                jmi_log_leave(log, iter_node);
                iter += 1;                
            }

            free(x_new);
            free(x);

            jmi_log_leave(log, ebi_node);
        }
        
        if(converged==0){
            jmi_log_node(log, logError, "Error", "Failed to find a consistent solution in event iteration in <block:%s, iter:%I> at <t:%E>",
                 block_solver->label, iter, cur_time);
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
    bsop->events_epsilon = 1e-10;
    bsop->step_limit_factor = 10; /** < \brief Step limiting factor */
    bsop->regularization_tolerance = -1;

    bsop->enforce_bounds_flag = 1;  /**< \brief Enforce min-max bounds on variables in the equation blocks*/
    bsop->use_jacobian_equilibration_flag = 0; 
    bsop->use_Brent_in_1d_flag = 0;            /**< \brief If Brent search should be used to improve accuracy in solution of 1D non-linear equations */

    bsop->block_jacobian_check = 0;
    bsop->block_jacobian_check_tol = 1e-6;

    bsop->residual_equation_scaling_mode = jmi_residual_scaling_auto;  

    bsop->min_residual_scaling_factor = 1e-10;
    bsop->max_residual_scaling_factor = 1e10;

    bsop->iteration_variable_scaling_mode = jmi_iter_var_scaling_nominal;
    bsop->rescale_each_step_flag = 0;
    bsop->rescale_after_singular_jac_flag = 0;
    bsop->check_jac_cond_flag = 0;  /**< \brief NLE solver should check Jacobian condition number and log it. */
    bsop->experimental_mode = 0;
    bsop->solver = JMI_KINSOL_SOLVER;
    bsop->jacobian_variability = JMI_CONTINUOUS_VARIABILITY;
    bsop->label = "";
}
