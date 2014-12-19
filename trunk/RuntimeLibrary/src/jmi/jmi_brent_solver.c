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

#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include "jmi_brent_solver.h"
#include "jmi_block_solver_impl.h"

#include "jmi_brent_search.h"

#define BRENT_BASE_LOG_LEVEL 6     /* Minimal Brent printouts log level */
#define BRENT_EXTENDED_LOG_LEVEL 7 /* Extended Brent printouts log level */

#define BRENT_INITIAL_STEP_FACTOR 0.01 /* Initial bracketing step as a fraction of nominal */

/* Interface to the residual function that is compatible with Brent search.
   @param y - input - function argument
   @param f - output - residual value
   @param problem_data - solver object propagated as opaques data
*/
int brentf(realtype y, realtype* f, void* problem_data) {
    jmi_block_solver_t *block = (jmi_block_solver_t*)problem_data;
    int ret = 0;
    
    /* Increment function calls counter */
    block->nb_fevals++;

    /* Check that arguments are valid */
    if ((y- y) != 0) {
        jmi_log_node(block->log, logWarning, "NaNInput", "Not a number in arguments to <block: %s>", block->label);
        return -1;
    }

    /*Evaluate the residual*/
    ret = block->F(block->problem_data,&y,f,JMI_BLOCK_EVALUATE);
    if (ret) {
        jmi_log_t* log = block->log;
        jmi_log_node_t node = 
            jmi_log_enter_fmt(log, logWarning, "Warning", "<errorCode: %d> returned when calling residual function in <block: %s>", ret, block->label);
        jmi_log_reals(log, node, logWarning, "ivs", &y, 1);
        jmi_log_leave(log, node);
        return ret;
    }
    /* Check that outputs are valid */    
    {
        realtype v = *f;
        if (v- v != 0) {
             jmi_log_t* log = block->log;
             jmi_log_node_t node = jmi_log_enter_fmt(block->log, logWarning, "NaNOutput", "Not a number in output from <block: %s>", block->label);
             jmi_log_reals(log, node, logWarning, "ivs", &y, 1);
             jmi_log_leave(log, node);
             ret = 1;
        }
    }
    return ret;
}


/* Initialize solver structures 

block->options->use_Brent_in_1d_flag
solver->kin_stol = block->options->min_tol;
*/


int jmi_brent_solver_new(jmi_brent_solver_t** solver_ptr, jmi_block_solver_t* block) {
    jmi_brent_solver_t* solver;
    int flag = 0;
    
    solver = (jmi_brent_solver_t*)calloc(1,sizeof(jmi_brent_solver_t));
    if (!solver) return -1;
         
    *solver_ptr = solver;
    return flag;
}

void jmi_brent_solver_delete(jmi_block_solver_t* block) {
    jmi_brent_solver_t* solver = block->solver;
    
    /*Deallocate struct */
    free(solver);
    block->solver = 0;
}

void jmi_brent_solver_print_solve_start(jmi_block_solver_t *block,
                                        jmi_log_node_t *destnode) {
    if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
        jmi_log_t *log = block->log;
        *destnode = jmi_log_enter_fmt(log, logInfo, "BrentSolve", 
                                      "Brent solver invoked for <block:%s> with <variable:#r%d#>",
                                      block->label, block->value_references[0]);
    }
}

const char* jmi_brent_flag_to_name(int flag) {
    switch(flag) {
    case JMI_BRENT_MEM_FAIL: return "BRENT_MEM_FAIL";
    case JMI_BRENT_ILL_INPUT: return "BRENT_ILL_INPUT";
    case JMI_BRENT_SYSFUNC_FAIL: return "BRENT_SYSFUNC_FAIL";
    case JMI_BRENT_FIRST_SYSFUNC_ERR: return "JMI_BRENT_FIRST_SYSFUNC_ERR";
    case JMI_BRENT_REPTD_SYSFUNC_ERR: return "JMI_BRENT_REPTD_SYSFUNC_ERR";
    case JMI_BRENT_ROOT_BRACKETING_FAILED: return "BRENT_ROOT_BRACKETING_FAILED";
    case JMI_BRENT_FAILED: return "BRENT_FAILED";
    case JMI_BRENT_SUCCESS: return "BRENT_SUCCESS";
    default: return "BRENT_ERROR";
    }
}

void jmi_brent_solver_print_solve_end(jmi_block_solver_t *block, const jmi_log_node_t *node, int flag) {
    /* jmi_brent_solver_t* solver = block->solver; */

    /* NB: must match the condition in jmi_brent_solver_print_solve_start exactly! */
    if (block->callbacks->log_options.log_level >= BRENT_BASE_LOG_LEVEL) {
        jmi_log_t *log = block->log;
        const char *flagname = jmi_brent_flag_to_name(flag);
        if (flagname != NULL) jmi_log_fmt_(log, *node, logInfo, "Brent solver finished with <brent_exit_flag:%s>. ", flagname);
        else jmi_log_fmt_(log, *node, logInfo, "Brent solver finished with unrecognized <brent_exit_flag:%d>. ", flag);
        jmi_log_fmt_(log, *node, logInfo, "<solution:%g>", block->x[0]);
        jmi_log_leave(log, *node);
    }
}

/* Initialize solver structures */
/* just a placeholder in case more init is needed*/
static int jmi_brent_init(jmi_block_solver_t * block) {
   jmi_brent_solver_t* solver = (jmi_brent_solver_t*)block->solver;
   solver->originalStart = block->x[0];
    return 0;
}


static int jmi_brent_try_bracket(jmi_block_solver_t * block, 
                                     double x_cur, double f_cur,
                                     double x_bracket, double* f_bracket)
{
    int flag;
    jmi_brent_solver_t* solver = (jmi_brent_solver_t*)block->solver;
    jmi_log_t *log = block->log;

    flag =  brentf(x_bracket, f_bracket, block); /* evaluate residual */
    if (flag) {
        /* report error */
        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentTryBracket",
                     "Unable to evaluate residual at <iv: %g>", x_bracket);
        return -1;
    }

    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentTryBracket",
                 "Trying to bracket the root with <iv: %g, f: %g>", x_bracket, f_bracket[0]);

    if (f_bracket[0] > DBL_MIN) { 
        if (f_cur <= 0) { /* sign change - bracketing done */
            solver->f_pos_min = f_bracket[0];
            solver->y_pos_min = x_bracket;
            solver->f_neg_max = f_cur;
            solver->y_neg_max = x_cur;
            return 1;
        }
    }
    else if (f_bracket[0] < -DBL_MIN) { 
        if (f_cur >= 0) { /* sign change - bracketing done */
            solver->f_neg_max = f_bracket[0];
            solver->y_neg_max = x_bracket;
            solver->f_pos_min = f_cur;
            solver->y_pos_min = x_cur;
            return 1;
        }
    }
    else {
        block->x[0] = x_bracket;
        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketExact", "Got zero residual while bracketing");
        return 2;
    }
    return 0; /* will need more bracketing */
}

int jmi_brent_solver_solve(jmi_block_solver_t * block){
    int flag;
#ifdef JMI_PROFILE_RUNTIME
    clock_t t;
#endif
    jmi_brent_solver_t* solver = (jmi_brent_solver_t*)block->solver;
    double f, init;
    jmi_log_node_t topnode;
    jmi_log_t *log = block->log;
#ifdef JMI_PROFILE_RUNTIME
    if (block->parent_block) {
        t = clock();
    }
#endif



    jmi_brent_solver_print_solve_start(block, &topnode);

    if (block->init) {
        jmi_brent_init(block);
        init = block->x[0];
    }
    else {
        /* Read initial values and bounds for iteration variables from variable vector.
        * This is needed if the user has changed initial guesses in between calls to
        * the solver.
        */
        double nom, min, max;
        flag = block->F(block->problem_data,block->x,block->res,JMI_BLOCK_INITIALIZE);
        init = block->x[0];
        if (flag ||(init != init)) {        
            if(!flag) flag = 100;
            jmi_log_node(log, logWarning, "ErrorReadingInitialGuess", "<errorCode: %d> returned from <block: %s> "
                         "when reading initial guess.", flag, block->label);
            jmi_brent_solver_print_solve_end(block, &topnode, flag);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return flag;
        }

        if(block->options->iteration_variable_scaling_mode != jmi_iter_var_scaling_none) {
            flag = block->F(block->problem_data,block->nominal,block->res,JMI_BLOCK_NOMINAL);
            nom = block->nominal[0];
            if (flag ||(nom != nom)) {
                if(!flag) flag = 100;
                jmi_log_node(log, logWarning, "ErrorReadingNominal", "<errorCode: %d> returned to <block: %s> "
                    "when reading nominal value.", flag, block->label);
                jmi_brent_solver_print_solve_end(block, &topnode, flag);
#ifdef JMI_PROFILE_RUNTIME
                if (block->parent_block) {
                    block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
                }
#endif
                return flag;
            }
        }


        flag = block->F(block->problem_data,block->min,block->res,JMI_BLOCK_MIN);
        min = block->min[0];
        if (flag ||(min != min)) {        
            if(!flag) flag = 100;
            jmi_log_node(log, logWarning, "ErrorReadingMin", "<errorCode: %d> returned to <block: %s> "
                "when reading  min bound value.", flag, block->label);
            jmi_brent_solver_print_solve_end(block, &topnode, flag);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return flag;
        }

        flag = block->F(block->problem_data,block->max,block->res,JMI_BLOCK_MAX);
        max = block->max[0];
        if (flag || (max != max)) {        
            if(!flag) flag = 100;
            jmi_log_node(log, logWarning, "ErrorReadingMax", "<errorCode: %d> returned to <block: %s> "
                "when reading max bound value.", flag, block->label);
            jmi_brent_solver_print_solve_end(block, &topnode, flag);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return flag;
        }


        if ((init > max) || (init < min)) {
            realtype old_init = init;
            init = init > max ? max : min;
            block->x[0] = block->initial[0] = init;
            jmi_log_node(block->log, logWarning, "StartOutOfBounds",
                         "Start value <start: %g> is not between <min: %g> and <max: %g> "
                         "for the iteration variable <iv: #r%d#> in <block: %s>. Clamping to <clamped_start: %g>.",
                         old_init, min, max, block->value_references[0], block->label, init);
        }


    }

    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<max: %g>", block->max[0]);
    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<min: %g>", block->min[0]);
    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<nominal: %g>", block->nominal[0]);
    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<initial_guess: %g>", block->x[0]);

    /* evaluate att initial */
    /* evaluate the function at initial */
    flag = brentf(block->x[0], &f, block);

    if(flag) {
        if(block->x[0] != solver->originalStart) {
            jmi_log_node(log, logWarning, "Warning",  "Residual function evaluation failed at initial point for "
                         "<block: %s>, will try <initial_guess: %g>", block->label, solver->originalStart);
        
            flag = brentf(solver->originalStart, &f, block);
            if(!flag) {
                block->x[0] = solver->originalStart;
            }
        }
        if(flag && (block->x[0] != block->min[0]) && (block->min[0] != solver->originalStart)) {
            jmi_log_node(log, logWarning, "Warning",  "Residual function evaluation failed at initial point for "
                         "<block: %s>, will try <initial_guess: %g>", block->label, block->min[0]);
        
            flag = brentf(block->min[0], &f, block);
            if(!flag) {
                block->x[0] = block->min[0];
            }
        }
        if(flag && (block->x[0] != block->max[0]) && (block->max[0] != solver->originalStart)) {
            jmi_log_node(log, logWarning, "Warning",  "Residual function evaluation failed at initial point for "
                         "<block: %s>, will try <initial_guess: %g>", block->label, block->max[0]);        
            flag = brentf(block->max[0], &f, block);
            if(!flag) {
                block->x[0] = block->max[0];
            }
        }
    }

    jmi_log_fmt(log, topnode, BRENT_EXTENDED_LOG_LEVEL, "<initial_f:%g>", f);

    if (flag) {

        jmi_log_node(block->log, logError, "Error", "Residual function evaluation failed at initial point for "
                     "<block: %s>", block->label);
        jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_FIRST_SYSFUNC_ERR);
#ifdef JMI_PROFILE_RUNTIME
        if (block->parent_block) {
            block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
        }
#endif
        if(block->options->experimental_mode & jmi_block_solver_experimental_Brent_ignore_error)
            return JMI_BRENT_SUCCESS;
        else
            return JMI_BRENT_FIRST_SYSFUNC_ERR;
    }

    /* bracket the root */
    if ((f > DBL_MIN) || ((f < -DBL_MIN))) {
        double x = block->x[0], tmp, f_tmp;
        double lower = x, f_lower = f;
        double upper = x, f_upper = f;
        double initialStep = block->nominal[0]*BRENT_INITIAL_STEP_FACTOR;
        double lstep = initialStep, ustep = initialStep;
        while (1) {
            if (lower > block->min[0] && /* lower is fine as long as we're inside the bounds */
                (
                    ( upper >= block->max[0]) ||  /* prefer lower if upper is outside bounds */
                    ((f_lower < f_upper) && (f > 0)) || /* or lower is "closer" to sign change */
                    ((f_lower >= f_upper) && (f < 0))
                )
                ) {
                /* widen the interval */
                tmp = lower - lstep;  
                if ((tmp < block->min[0]) || (tmp != tmp)) { /* make sure we're inside bounds and not NAN*/
                    tmp = block->min[0];
                    /* This update can increase roundoff that prevents lstep from decreasing.
                       Ok if we hit the bound anyway. */
                    lstep = lower - tmp;
                }
                if ( lower > solver->originalStart && tmp <= solver->originalStart && lstep > initialStep * 10) {
                    tmp = solver->originalStart;
                    lstep = initialStep;
                }

                flag = jmi_brent_try_bracket(block, lower, f_lower, tmp, &f_tmp);

                 /* modify the step for the next time */
                if (flag < 0) { 
                    /* there was an error - reduce the step */
                    lstep *= 0.5;
                    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepReduced", 
                                 "Reducing bracketing step in negative direction "
                                 "to <lstep: %g>", lstep);
                    if ((lstep <= UNIT_ROUNDOFF * block->nominal[0]) || (lower - lstep == lower)) {
                        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepTooSmall", 
                                     "Too small bracketing step - modifying <lower_bound: %g> "
                                     "on the iteration variable", lower);
                        block->min[0] = lower; /* we cannot step further without breaking the function -> update the bound */
                    }
                }
                else if (flag == 0) {
                    /* increase the step */
                    lstep *= 2;
                    lower = tmp;
                    f_lower = f_tmp;
                    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepIncreased",
                                 "Increasing bracketing step in negative direction "
                                 "to <lstep: %g>", lstep);
                }
            }
            else if (upper < block->max[0]) { /* upper might work otherwise */
                tmp = upper + ustep;
                if ((tmp > block->max[0]) || (tmp != tmp)) {
                    tmp = block->max[0];
                    /* This update can increase roundoff that prevents lstep from decreasing.
                       Ok if we hit the bound anyway. */
                    ustep = tmp - upper;
                }
                if ( upper < solver->originalStart && tmp >= solver->originalStart && ustep > initialStep * 10) {
                    tmp = solver->originalStart;
                    ustep = initialStep;
                }

                flag = jmi_brent_try_bracket(block, upper, f_upper, tmp, &f_tmp);

                 /* modify the step for the next time */
                if (flag < 0) { 
                    /* there was an error - reduce the step */
                    ustep *= 0.5;
                    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepReduced", 
                                 "Reducing bracketing step in positive direction "
                                 "to <ustep: %g>", ustep);

                    if ((ustep <= UNIT_ROUNDOFF * block->nominal[0]) ||  (upper + ustep == upper)) {
                        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepTooSmall", 
                                     "Too small bracketing step - modifying <upper_bound: %g> "
                                     "on the iteration variable", upper);
                        block->max[0] = upper; /* we cannot step further without breaking the function -> update the bound */
                    }
                }
                else if (flag == 0) {
                    /* increase the step */
                    ustep *= 2;
                    upper = tmp;
                    f_upper = f_tmp;
                    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketStepIncreased",
                                 "Increasing bracketing step in positive direction "
                                 "to <ustep: %g>", ustep);
                }
            }
            else {
                jmi_log_node(log, logError, "BrentBracketFailed", "Could not bracket the root in <block: %s>. Both lower and upper are at bounds.", block->label);
                jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_ROOT_BRACKETING_FAILED);
#ifdef JMI_PROFILE_RUNTIME
                if (block->parent_block) {
                    block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
                }
#endif
                if(block->options->experimental_mode & jmi_block_solver_experimental_Brent_ignore_error) {
                    block->x[0] = init;
                    block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);
                    return JMI_BRENT_SUCCESS;
                }
                else
                    return JMI_BRENT_ROOT_BRACKETING_FAILED;
            }
            if (flag > 0) { 
                break; /* bracketing done*/
            }
        }
        if (flag == 2) {
            /* root found while in bracketing */
            jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SUCCESS);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return JMI_BRENT_SUCCESS;
        }
    }
    else {
        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracketExact", "Initial guess has zero residual");
        jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SUCCESS);
#ifdef JMI_PROFILE_RUNTIME
        if (block->parent_block) {
            block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
        }
#endif
        return JMI_BRENT_SUCCESS;
    }
    jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentBracket", 
                 "Bracketed the root between <iv_neg: %g> and <iv_pos: %g>, residuals <res_neg: %g> and <res_pos: %g>", 
                 solver->y_neg_max, solver->y_pos_min, solver->f_neg_max, solver->f_pos_min);

    {            
        realtype u, f;
        flag = jmi_brent_search(brentf, solver->y_neg_max,  solver->y_pos_min, 
                                solver->f_neg_max, solver->f_pos_min, 0, &u, &f,block);
        block->x[0] = u;
        
        if (flag) {
            jmi_log_node(log, logError, "Error", "Function evaluation failed while iterating in <block: %s>", block->label);
            jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SYSFUNC_FAIL);
#ifdef JMI_PROFILE_RUNTIME
            if (block->parent_block) {
                block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
            }
#endif
            return JMI_BRENT_SYSFUNC_FAIL;
        }
        else {
                /* Write solution back to model just to make sure. In some cases x was not the last evaluations*/    
            block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);
        }
    }   
        
    jmi_brent_solver_print_solve_end(block, &topnode, JMI_BRENT_SUCCESS);
#ifdef JMI_PROFILE_RUNTIME
    if (block->parent_block) {
        block->parent_block->time_in_brent += ((double)clock() - t) / CLOCKS_PER_SEC;
    }
#endif
    return JMI_BRENT_SUCCESS;
}

int jmi_brent_search(jmi_brent_func_t f, realtype u_min, realtype u_max, realtype f_min, realtype f_max, realtype tolerance, realtype* u_out, realtype* f_out,void *data) {
    realtype a=u_min; /* left point */
    realtype fa = f_min;
    realtype b=u_max; /* right point */
    realtype fb = f_max;
    realtype c = u_min; /* Intermediate point a <= c <= b */
    realtype fc = f_min;
    realtype e= u_max - u_min;
    realtype d=e;
    realtype m;
    realtype s;
    realtype p;
    realtype q;
    realtype r;
    realtype tol; /* absolute tolerance for the current "b" */
    int flag;
    jmi_block_solver_t* block = (jmi_block_solver_t*)data;
    jmi_log_t* log = block->log;
    jmi_log_node_t log_node;
    if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
        log_node = jmi_log_enter(log, logInfo, "BrentSearch");
    }

#ifdef DEBUG
    if (fa*fb > 0) {
        if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
            jmi_log_node(log, logError, "Error", "Brent got two endpoints with the same sign in <block: %s>", block->label);
            jmi_log_leave(log, log_node);
        }
        return JMI_BRENT_ILL_INPUT;
    }
#endif
    while(1) {
        if (RAbs(fc) < RAbs(fb)) {
            a = b;
            b = c;
            c = a;
            fa = fb;
            fb = fc;
            fc = fa;
        }

        jmi_log_node(log, BRENT_EXTENDED_LOG_LEVEL, "BrentIteration",
                     "Root is bracketed between <iv_best: %g> and <iv_second: %g>, residuals <f_best: %g> and <f_second: %g>",
                     b, c, fb, fc);

        tol = 2*UNIT_ROUNDOFF*RAbs(b) + tolerance;
        m = (c - b)/2;
        
        if ((RAbs(m) <= tol) || (fb == 0.0)) {
            /* root found (interval is small enough) */
            if (RAbs(fb) < RAbs(fc)) {
                *u_out = b;
                *f_out = fb;
            }
            else {
                *u_out = c;
                *f_out = fc;
            }
            if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
                jmi_log_leave(log, log_node);
            }
            return 0;
        }
        /* Find the new point: */
        /* Determine if a bisection is needed */
        if ((RAbs(e) < tol) || ( RAbs(fa) <= RAbs(fb))) {
            e = m;
            d = e;
        }
        else {
            s = fb/fa;
            if (a == c) {
                /* linear interpolation */
                p = 2*m*s;
                q = 1 - s;
            }
            else {
                /* inverse quadratic interpolation */
                q = fa/fc;
                r = fb/fc;
                p = s*(2*m*q*(q - r) - (b - a)*(r - 1));
                q = (q - 1)*(r - 1)*(s - 1);
            }
            if (p > 0) 
                q = -q;
            else
                p = -p;
            s = e;
            e = d;
            
            if ((2*p < 3*m*q - RAbs(tol*q)) && (p < RAbs(0.5*s*q)))
                /* interpolation successful */
                d = p/q;
            else {
                /* use bi-section */
                e = m;
                d = e;
            }
        }
        
        
        /* Best guess value is saved into "a" */
        a = b;
        fa = fb;
        b = b + ((RAbs(d) > tol) ? d : ((m > 0) ? tol: -tol));
        flag = f(b, &fb, data);
        if (flag) {
             if (RAbs(fa) < RAbs(fc)) {
                *u_out = a;
                *f_out = fa;
            }
            else {
                *u_out = c;
                *f_out = fc;
            }
            if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
                jmi_log_leave(log, log_node);
            }
            return flag;
        }

        if (fb * fc  > 0) {
            /* initialize variables */
            c = a;
            fc = fa;
            e = b - a;
            d = e;
        }
    }
    if (block->callbacks->log_options.log_level >= BRENT_EXTENDED_LOG_LEVEL) {
        jmi_log_leave(log, log_node);
    }

}
