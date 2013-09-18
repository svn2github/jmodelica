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
#include "jmi_log.h"


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
    /* int i;*/
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
    b->ipiv = (int*)calloc(2*n+1,sizeof(int));
    b->init = 1;
      
    b->min = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->max = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->nominal = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->initial = (jmi_real_t*)calloc(n,sizeof(jmi_real_t));
    b->value_references = (jmi_int_t*)calloc(n,sizeof(jmi_int_t));
    b->message_buffer = (char*)calloc(n*500+2000,sizeof(char));

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
    int ef,retval;
    clock_t c0,c1; /*timers*/
    jmi_t* jmi = block->jmi;
    jmi_real_t* switches;
    jmi_real_t* sw_old;
    jmi_real_t* x_new;
    jmi_real_t* x;
    jmi_real_t* booleans;
    jmi_real_t* bool_old;
    jmi_int_t nF0,nF1,nFp,nR0;
    jmi_int_t nF,nR,nbr_sw,mode_sw,nbr_bool;
    jmi_int_t iter,converged,nbr_allocated_iterations;
    jmi_real_t h;

    c0 = clock();

    jmi->block_level++;
    
    if(block->init) {
        int i;
        jmi_real_t* real_vrs = (jmi_real_t*)calloc(block->n,sizeof(jmi_real_t));
        /* Initialize the work vectors */
        for(i=0; i < block->n; ++i) {
            if(jmi->options.iteration_variable_scaling_mode == jmi_iter_var_scaling_heuristics) {
                block->nominal[i] = BIG_REAL;
            }
            else {
                block->nominal[i] = 1.0;
            }
            block->max[i] = BIG_REAL;
            block->min[i] = -block->max[i];
        }
        if(jmi->options.iteration_variable_scaling_mode != jmi_iter_var_scaling_none) {
            block->F(jmi,block->nominal,block->res,JMI_BLOCK_NOMINAL);
        }
        block->F(jmi,block->min,block->res,JMI_BLOCK_MIN);
        block->F(jmi,block->max,block->res,JMI_BLOCK_MAX);
        block->F(jmi,block->initial,block->res,JMI_BLOCK_INITIALIZE);
        block->F(jmi,real_vrs,block->res,JMI_BLOCK_VALUE_REFERENCE);

        for (i=0;i<block->n;i++) {
            block->value_references[i] = (int)real_vrs[i];
        }
        
        
        /* if the nominal is outside min-max -> fix it! */
        for(i=0; i < block->n; ++i) {
            realtype maxi = block->max[i];
            realtype mini = block->min[i];
            realtype nomi = block->nominal[i];
            realtype initi = block->initial[i];
            booleantype hasSpecificMax = (maxi != BIG_REAL);
            booleantype hasSpecificMin = (mini != -BIG_REAL);
            booleantype nominalOk = TRUE;
            
            if(nomi == BIG_REAL) {
                nominalOk = FALSE; /* no nominal set and heuristics is activated */
            } else if((nomi > maxi) || (nomi < mini)) { /* nominal outside min-max */
                jmi_log_node(block->jmi->log, logWarning, "Warning",
                    "Nominal value is outside min-max range for the iteration variable."
                    , block->index, i);
            }
            
            if(!nominalOk) {
                /* fix the nominal value to be inside the allowed range */
                if((initi > mini) && (initi < maxi) && (initi != 0.0)) {
                    block->nominal[i] = initi;
                }
                else if(hasSpecificMax && hasSpecificMin) {
                    nomi = (maxi + mini) / 2;
                    if( /* min&max have different sign */
                            (maxi * mini < 0) && 
                            /* almost symmetric range */
                            (fabs(nomi) < 1e-2*maxi ))
                        /* take 1% of max  */
                        nomi = 1e-2*maxi;

                     block->nominal[i] = nomi;
                }
                else if(hasSpecificMin)
                    block->nominal[i] = 
                            (mini == 0.0) ? 
                                1.0: 
                                (mini > 0)?
                                    mini * (1+UNIT_ROUNDOFF):
                                    mini * (1-UNIT_ROUNDOFF);
                else if (hasSpecificMax){
                    block->nominal[i] = 
                            (maxi == 0.0) ? 
                                -1.0: 
                                (maxi > 0)? 
                                    maxi * (1-UNIT_ROUNDOFF):
                                    maxi * (1+UNIT_ROUNDOFF);
                }
                else
                    /* take 1.0 as default*/
                    block->nominal[i] = 1.0;
            }
            block->x[i] = initi;
        }
        free(real_vrs);
        /*        block->F(block->jmi,block->x, block->res, JMI_BLOCK_EVALUATE); */
    }
    
    /*
     * A proper local even iteration should problably be done here.
     * Right now event handling at top level will iterate.
     */
    if (((jmi->atInitial == JMI_TRUE || jmi->atEvent == JMI_TRUE)) && (jmi->block_level == 1)) {
        jmi_log_node_t top_node = jmi_log_enter_fmt(jmi->log, logInfo, "BlockEventIterations",
                                      "Starting block (local) event iteration at <t:%E> in <block:%d>",
                                      jmi_get_t(jmi)[0], block->index);

        /*ITERATION */
        nbr_allocated_iterations = 30;
        switches = jmi_get_sw(jmi); /* Get the switches */
        
        if (jmi->atInitial == JMI_TRUE){
            /* switches = jmi_get_sw_init(jmi); */ /* Get the switches */
            jmi_init_get_sizes(jmi,&nF0,&nF1,&nFp,&nR0);
            nbr_sw = nR0;
            mode_sw = 0; /* INITIALIZE MODE */
        }
        else{
            jmi_dae_get_sizes(jmi, &nF, &nR);
            nbr_sw = nR;
            mode_sw = 1; /* NOT INITIALIZE MODE */
        }
        nbr_bool = jmi->n_boolean_d;
        booleans = jmi_get_boolean_d(jmi);
        
        bool_old = (jmi_real_t*)calloc(nbr_allocated_iterations*nbr_bool, sizeof(jmi_real_t));
        memcpy(bool_old,booleans,nbr_bool*sizeof(jmi_real_t)); /* Store the current booleans */
        
        sw_old = (jmi_real_t*)calloc(nbr_allocated_iterations*nbr_sw, sizeof(jmi_real_t));
        memcpy(sw_old,switches,nbr_sw*sizeof(jmi_real_t)); /* Store the current switches */
        
        jmi_log_reals(jmi->log, top_node, logInfo, "ivs", block->x, block->n);
        jmi_log_reals(jmi->log, top_node, logInfo, "switches", switches, nbr_sw);
        jmi_log_reals(jmi->log, top_node, logInfo, "booleans", booleans, jmi->n_boolean_d);

        iter = 0;
        converged = 0;
        ef = 0;
        if(jmi->options.block_solver_experimental_mode & jmi_block_solver_experimental_converge_switches_first) {
            while(1) {
                jmi_log_node_t iter_node;
                iter += 1;
    
                iter_node = jmi_log_enter_fmt(jmi->log, logInfo, "SwitchIteration", "Local iteration <iter:%d> at <t:%E>",
                                              iter, jmi_get_t(jmi)[0]);
                
                /* Evaluate the block to update dependent variables if any */
                ef = block->F(jmi,block->x,block->res,JMI_BLOCK_EVALUATE);
                if(ef != 0) {
                    jmi_log_fmt(jmi->log, iter_node, logError, "Problem calling residual function <block:%d, iter:%d> at <t:%E>",
                                block->index, iter, jmi_get_t(jmi)[0]);
                    jmi_log_leave(jmi->log, iter_node);
                    break;
                }
                
                
                retval = jmi_evaluate_switches(jmi,switches,mode_sw);
                
                ef = block->F(jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
                if(ef != 0) { jmi_log_leave(jmi->log, iter_node); break; }
                
                jmi_log_reals(jmi->log, iter_node, logInfo, "ivs", block->x, block->n);
                jmi_log_reals(jmi->log, iter_node, logInfo, "switches", switches, nbr_sw);
                jmi_log_reals(jmi->log, iter_node, logInfo, "booleans", booleans, jmi->n_boolean_d);
                
                /* Check for consistency */
                if (jmi_compare_switches(&sw_old[(iter-1)*nbr_sw],switches,nbr_sw) && jmi_compare_switches(&bool_old[(iter-1)*nbr_bool],booleans,nbr_bool)){
                    jmi_log_fmt(jmi->log, iter_node, logInfo, "Found consistent switched state before solving at <t:%g>",
                                jmi_get_t(jmi)[0]);
                    break;
                }
                else {
                    /* Check for infinite loop */
                    if((iter >= nbr_allocated_iterations/2) &&  jmi_check_infinite_loop(sw_old,switches,nbr_sw,iter)){
                        jmi_log_fmt(jmi->log, iter_node, logError, "Detected infinite loop in fixed point iteration at "
                                    "<t:%g>", jmi_get_t(jmi)[0]);
                        jmi_log_leave(jmi->log, iter_node);
                        break;
                    }
                    if(iter >= nbr_allocated_iterations){
                        jmi_log_fmt(jmi->log, iter_node, logError, "Failed to converge during switches iteration due to too many iterations at <t:%E>", jmi_get_t(jmi)[0]);
                        jmi_log_leave(jmi->log, iter_node);
                        break;
                    }
                    
                    /* Store the new switches */
                    memcpy(&sw_old[iter*nbr_sw],switches,nbr_sw*sizeof(jmi_real_t));
                    memcpy(&bool_old[iter*nbr_bool],booleans,nbr_bool*sizeof(jmi_real_t));
                }
                jmi_log_leave(jmi->log, iter_node);
            }
        }
        
        iter = 0;
        while (1){
            jmi_log_node_t iter_node;
            iter += 1;

            iter_node = jmi_log_enter_fmt(jmi->log, logInfo, "BlockIteration", "Local iteration <iter:%d> at <t:%E>",
                                          iter, jmi_get_t(jmi)[0]);
            /* Solve block */
            ef = block->solve(block); 
            if (ef!=0){ jmi_log_leave(jmi->log, iter_node); break; }
            
            retval = jmi_evaluate_switches(jmi,switches,mode_sw);
        
            block->F(jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
            
            jmi_log_reals(jmi->log, iter_node, logInfo, "ivs", block->x, block->n);
            jmi_log_reals(jmi->log, iter_node, logInfo, "switches", switches, nbr_sw);
            jmi_log_reals(jmi->log, iter_node, logInfo, "booleans", booleans, jmi->n_boolean_d);

            
            /* Check for consistency */
            if (jmi_compare_switches(&sw_old[(iter-1)*nbr_sw],switches,nbr_sw) && jmi_compare_switches(&bool_old[(iter-1)*nbr_bool],booleans,nbr_bool)){
                jmi_log_fmt(jmi->log, iter_node, logInfo, "Found consistent solution using fixed point iteration at "
                            "<t:%E>", jmi_get_t(jmi)[0]);

                converged = 1;
                jmi_log_leave(jmi->log, iter_node);
                break;
            }
            
            /* Check for infinite loop */
            if (jmi_check_infinite_loop(sw_old,switches,nbr_sw,iter)){
                jmi_log_fmt(jmi->log, iter_node, logInfo, "Detected infinite loop in fixed point iteration at "
                            "<t:%g>, switching to enchanced fixed point iteration...", jmi_get_t(jmi)[0]);
                jmi_log_leave(jmi->log, iter_node);
                break;
            }

            /* Store the new switches */
            if(iter >= nbr_allocated_iterations){
                jmi_log_fmt(jmi->log, iter_node, logInfo, "Failed to converge during fixed point iteration due to too many "
                            "iterations, at <t:%E>, switching to enhanced fixed point iteration...",
                            jmi_get_t(jmi)[0]);
                jmi_log_leave(jmi->log, iter_node);
                break;
            }
            memcpy(&sw_old[iter*nbr_sw],switches,nbr_sw*sizeof(jmi_real_t));
            memcpy(&bool_old[iter*nbr_bool],booleans,nbr_bool*sizeof(jmi_real_t));

            jmi_log_leave(jmi->log, iter_node);
        }
        
        free(sw_old);
        free(bool_old);
        
        /* ENHANCED FIXED POINT ITERATION */
        if (converged==0 && ef==0){
            jmi_log_node_t ebi_node = jmi_log_enter_fmt(jmi->log, logInfo, "EnhancedBlockIterations",
                                          "Starting enhanced block iteration at <t:%E>", jmi_get_t(jmi)[0]);

            bool_old = (jmi_real_t*)calloc(nbr_allocated_iterations*nbr_bool, sizeof(jmi_real_t));
            sw_old = (jmi_real_t*)calloc(nbr_allocated_iterations*nbr_sw, sizeof(jmi_real_t));
            x_new = (jmi_real_t*)calloc(block->n, sizeof(jmi_real_t));
            x = (jmi_real_t*)calloc(block->n, sizeof(jmi_real_t));
            
            memcpy(bool_old,booleans,nbr_bool*sizeof(jmi_real_t)); /* Store the current booleans */
            memcpy(sw_old,switches,nbr_sw*sizeof(jmi_real_t)); /* Store the current switches */
            memcpy(x,block->x,block->n*sizeof(jmi_real_t));
            
            /* Solve block */
            ef = block->solve(block);
            
            memcpy(x_new,block->x,block->n*sizeof(jmi_real_t));
            
            retval = jmi_evaluate_switches(jmi,switches,mode_sw);
            
            block->F(jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
        
            iter = 0;
            while (1 && ef==0){
                jmi_log_node_t iter_node = jmi_log_enter_fmt(jmi->log, logInfo, "BlockIteration", 
                                               "Enhanced block iteration <iter:%d> at <t:%g>",
                                               iter, jmi_get_t(jmi)[0]);

                iter += 1;
                
                h = jmi_compute_minimal_step(block, x, x_new, &sw_old[(iter-1)*nbr_sw], &bool_old[(iter-1)*nbr_bool],nbr_sw, 1e-4);
                retval = jmi_compute_reduced_step(h,x_new,x,x,block->n);
                
                block->F(jmi,x,NULL,JMI_BLOCK_WRITE_BACK);
                
                retval = jmi_evaluate_switches(jmi,switches,mode_sw);
            
                block->F(jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
                
                ef = block->solve(block); if (ef!=0){ jmi_log_leave(jmi->log, iter_node); break; }
                
                memcpy(x_new, block->x, block->n*sizeof(jmi_real_t));
                
                jmi_log_reals(jmi->log, iter_node, logInfo, "ivs", block->x, block->n);
                jmi_log_reals(jmi->log, iter_node, logInfo, "switches", switches, nbr_sw);
                jmi_log_reals(jmi->log, iter_node, logInfo, "booleans", booleans, jmi->n_boolean_d);

                
                /* Check for consistency */
                if (jmi_compare_switches(&sw_old[(iter-1)*nbr_sw],switches,nbr_sw) && jmi_compare_switches(&bool_old[(iter-1)*nbr_bool],booleans,nbr_bool)){
                    jmi_log_fmt(jmi->log, iter_node, logInfo, "Found consistent solution using enhanced fixed point iteration at "
                                "<t:%E>", jmi_get_t(jmi)[0]);
                    converged = 1;
                    jmi_log_leave(jmi->log, iter_node);
                    break;
                }
                
                /* Check for infinite loop */
                if (jmi_check_infinite_loop(sw_old,switches,nbr_sw,iter)){
                    jmi_log_fmt(jmi->log, iter_node, logError, "Detected infinite loop in enhanced fixed point iteration at "
                                "<t:%g>", jmi_get_t(jmi)[0]);
                    jmi_log_leave(jmi->log, iter_node);
                    break;
                }
                
                /* Store the new switches */
                if(iter >= nbr_allocated_iterations){
                    jmi_log_fmt(jmi->log, iter_node, logWarning, "Failed to converge during enhanced fixed point iteration "
                                "due to too many iterations at <t:%E>", jmi_get_t(jmi)[0]);
                    jmi_log_leave(jmi->log, iter_node);
                    break;
                }
                memcpy(&sw_old[iter*nbr_sw],switches,nbr_sw*sizeof(jmi_real_t));
                memcpy(&bool_old[iter*nbr_bool],booleans,nbr_bool*sizeof(jmi_real_t));

                jmi_log_leave(jmi->log, iter_node);
            }
            
            free(sw_old);
            free(bool_old);
            free(x_new);
            free(x);

            jmi_log_leave(jmi->log, ebi_node);
        }
        
        if(converged==0){
            jmi_log_fmt(jmi->log, top_node, logError, "Failed to find a consistent solution in event iteration at <t:%g>",
                        jmi_get_t(jmi)[0]);
            ef = 1; /* Return flag */
        }
        jmi_log_leave(jmi->log, top_node);
    }else{
        ef = block->solve(block);
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



jmi_real_t jmi_compute_minimal_step(jmi_block_residual_t* block, jmi_real_t* x, jmi_real_t* x_new, jmi_real_t* sw_init, jmi_real_t* bool_init, jmi_int_t nR, jmi_real_t tolerance){
    jmi_real_t a = 0.0;
    jmi_real_t b = 1.0;
    jmi_real_t h;
    jmi_real_t *sw;
    jmi_real_t *booleans;
    jmi_real_t *x_temp;
    jmi_t* jmi = block->jmi;
    jmi_int_t retval=0;
    
    sw = (jmi_real_t*)calloc(nR, sizeof(jmi_real_t));
    x_temp = (jmi_real_t*)calloc(block->n, sizeof(jmi_real_t));
    memcpy(sw,sw_init,nR*sizeof(jmi_real_t));
    booleans = jmi_get_boolean_d(jmi);
    
    while (1){
        h = (b-a)/2.0;
        
        retval = jmi_compute_reduced_step(a+h,x_new,x,x_temp,block->n);
        
        /*jmi_write_block_x(block,x);*/
        block->F(jmi,x_temp,NULL,JMI_BLOCK_WRITE_BACK);
        
        retval = jmi_evaluate_switches(jmi,sw,1);
        
        /*
        block->F(jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
        */
        
        if (jmi_compare_switches(sw,sw_init,nR)){
            a = a+h;
        }else{
            b = b-h;
        }
        /* RESET Z DUE TO THE COUPLING BETWEEN BOOLEANS */
        /*
        memcpy(booleans,bool_init,(jmi->n_boolean_d)*sizeof(jmi_real_t));
        */
        if ( b-a < tolerance){
            break;
        }
    }
    
    free(sw);
    free(x_temp);
    
    return b;
}

int jmi_compute_reduced_step(jmi_real_t h, jmi_real_t* x_new, jmi_real_t* x, jmi_real_t* x_target, jmi_int_t size){
    int i;
    for (i=0;i<size;i++){
        x_target[i] = x[i]+(h)*(x_new[i]-x[i]);
    }
    return 0;
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
    free(b->message_buffer);
    free(b->initial);
    free(b->value_references);
    /* clean up the solver.*/
    b->delete_solver(b);

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
