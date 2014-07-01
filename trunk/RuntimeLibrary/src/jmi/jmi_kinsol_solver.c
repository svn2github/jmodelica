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

#include <sundials/sundials_math.h>
#include <sundials/sundials_direct.h>
#include <nvector/nvector_serial.h>
#include <kinsol/kinsol_direct.h>
#include <kinsol/kinsol_impl.h>

#include "jmi_kinsol_solver.h"
#include "jmi_block_solver_impl.h"

#include "jmi_brent_search.h"

/* RCONST from SUNDIALS and defines a compatible type, usually double precision */
#define ONE RCONST(1.0)
#define Ith(v,i)    NV_Ith_S(v,i)
#define UROUND 1e-15

static int jmi_kin_lsolve(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *res_norm);
static void jmi_update_f_scale(jmi_block_solver_t *block);
static int jmi_kin_lsetup(struct KINMemRec * kin_mem);

int kin_dF(int N, N_Vector u, N_Vector fu, DlsMat J, jmi_block_solver_t * block, N_Vector tmp1, N_Vector tmp2);

/*Kinsol function wrapper
    @param yy - Input - function argument
    @param ff - Output - residuals
    @param problem_data - solver object propagated as opaque data
*/
int kin_f(N_Vector yy, N_Vector ff, void *problem_data){
    
    realtype *y, *f;
    jmi_block_solver_t *block = problem_data;
    int i,n, ret;
    block->nb_fevals++;
    y = NV_DATA_S(yy); /*y is now a vector of realtype*/
    f = NV_DATA_S(ff); /*f is now a vector of realtype*/


    /* Test if input is OK (no -1.#IND) */
    n = NV_LENGTH_S(yy);
    for (i=0;i<n;i++) {
        /* Unrecoverable error*/
        if (Ith(yy,i)- Ith(yy,i) != 0) {
            jmi_log_node(block->log, logWarning, "NaNInput", "Not a number in <input: #r%d#> to <block: %s>", 
                         block->value_references[i], block->label);
            return -1;
        }
    }

    /*Evaluate the residual*/
    ret = block->F(block->problem_data,y,f,JMI_BLOCK_EVALUATE);
    
    if(ret) {
        jmi_log_node(block->log, logWarning, "Warning", "<errorCode: %d> returned from <block: %s>", 
                     ret, block->label);
        return ret;
    }

    /* Test if output is OK (no -1.#IND) */
    n = NV_LENGTH_S(ff);
    for (i=0;i<n;i++) {
        double v = Ith(ff,i);
        /* Recoverable error*/
        if (v- v != 0) {
            jmi_log_node(block->log, logWarning, "NaNOutput", 
                         "Not a number in <output: %I> from <block: %s>", i, block->label);
            ret = 1;
#if 0           
            block->F(block->jmi,y,f,JMI_BLOCK_EVALUATE);
#endif
        }
    }
    /* record information for Brent search */
    if(!ret && (block->n == 1) && block->options->use_Brent_in_1d_flag) {
        double yv = y[0];
        double fv = f[0];
        jmi_kinsol_solver_t* solver = block->solver;
        if(fv <= 0) {
            if(solver->f_neg_max_1d < fv) {
                solver->f_neg_max_1d = fv;
                solver->y_neg_max_1d = yv;
            }    
        }
        else {
            if(solver->f_pos_min_1d > fv) {
                solver->f_pos_min_1d = fv;
                solver->y_pos_min_1d = yv;
            }    
        }
    }

    /*
    realtype* y = NV_DATA_S(yy); */ /*y is now a vector of realtype*/
    /* printf("f = N.array([\n");
    for (i=0;i<n;i++) {
        printf("%12.12f\n",y[i]);
    }
    printf("]);\n");
*/
    return ret; /*Success*/
    /*return 1;  //Recoverable error*/
    /*return -1; //Unrecoverable error*/
}

static void kin_reset_char_log(jmi_kinsol_solver_t* solver) {
    solver->char_log_length = 0;
    solver->char_log[0] = 0;
}

static void kin_char_log(jmi_kinsol_solver_t* solver, char c) {
    if (solver->char_log_length < JMI_KINSOL_SOLVER_MAX_CHAR_LOG_LENGTH) {
        solver->char_log[solver->char_log_length] = c;
        solver->char_log_length++;
        solver->char_log[solver->char_log_length] = 0;
    } else {
        solver->char_log[JMI_KINSOL_SOLVER_MAX_CHAR_LOG_LENGTH-1] = '?';
    }
}

/* Wrapper function to Jacobian evaluation as needed by standard KINSOL solvers */
int kin_dF(int N, N_Vector u, N_Vector fu, DlsMat J, jmi_block_solver_t * block, N_Vector tmp1, N_Vector tmp2){
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;        
    struct KINMemRec * kin_mem = (struct KINMemRec *)solver->kin_mem;    
    int i, j, ret = 0;
    realtype curtime = block->cur_time;
    realtype *jac_fd = NULL;
    solver->kin_jac_update_time = curtime;
    block->nb_jevals++;
    
    kin_char_log(solver, 'J');
    if((block->callbacks->log_options.log_level >= 6)) {
        char message[256];
        sprintf(message, "Updating Jacobian (evaluations: %d)", (int)block->nb_jevals);
        jmi_log_node(block->log, logInfo, "Progress", "<source:%s><block:%s><message:%s>",
                     "jmi_kinsol_solver", block->label, message);
    }

    if (!block->dF || block->options->block_jacobian_check) {
        /* Use (almost) standard finite differences */
        realtype inc, inc_inv, ujsaved, ujscale, sign;
        realtype *tmp2_data, *u_data, *uscale_data;
        N_Vector ftemp, jthCol;
            
        /* Save pointer to the array in tmp2 */
        tmp2_data = N_VGetArrayPointer(tmp2);
      
        /* Rename work vectors for readibility */
        ftemp = tmp1; 
        jthCol = tmp2;
      
        /* Obtain pointers to the data for u and uscale */
        u_data   = N_VGetArrayPointer(u);
        uscale_data = N_VGetArrayPointer(solver->kin_y_scale);
      
        /* This is the only for loop for 0..N-1 in KINSOL */
      
        for (j = 0; j < N; j++) {
          realtype sqrt_relfunc = kin_mem->kin_sqrt_relfunc;
            
          /* Generate the jth col of Jac(u) */      
          N_VSetArrayPointer(DENSE_COL(J,j), jthCol);
      
          ujsaved = u_data[j];
          ujscale = ONE/uscale_data[j];
          sign = (ujsaved >= 0) ? 1 : -1;
          inc = MAX(ABS(ujsaved), ujscale)*sign;
          if(sqrt_relfunc > 0) 
              inc *= sqrt_relfunc;
          u_data[j] += inc;
      
          ret = kin_f(u, ftemp, block);
          if(ret > 0) {
              /* try to recover by stepping in the opposite direction */
              inc = -inc;
              u_data[j] = ujsaved + inc;
          
              ret = kin_f(u, ftemp, block);
          }
          if (ret != 0) break; 
      
          u_data[j] = ujsaved;
      
          inc_inv = ONE/inc;
          N_VLinearSum(inc_inv, ftemp, -inc_inv, fu, jthCol);      
        }
      
        /* Evaluate the residual with the original u vector to avoid that the initial guess 
           for the final IV is pertubated when the iterations start*/
        /*ret = kin_f(u, ftemp, block);*/

        /* Restore original array pointer in tmp2 */
        N_VSetArrayPointer(tmp2_data, tmp2);
        if (block->options->block_jacobian_check) {
            jac_fd = (realtype*) calloc(N * N, sizeof(realtype));
            for (i = 0; i < N * N; i++) {
                jac_fd[i] = J->data[i];
            }
        }
    }
    if (block->dF) {
        /* utilize directional derivatives to calculate Jacobian */
        for(i = 0; i < N; i++){ 
            block->x[i] = Ith(u,i);
        }
        for(i = 0; i < N; i++){
            block->dx[i] = 1;
            ret |= block->dF(block->problem_data,block->x,block->dx,block->res,block->dres,JMI_BLOCK_EVALUATE);
            for(j = 0; j < N; j++){
                realtype dres = block->dres[j];
                (J->data)[i*N+j] = dres;
            }
            J->cols[i] = &(J->data)[i*N];
            block->dx[i] = 0;
        }       
    }
    
    if (block->options->block_jacobian_check) {
        /* compare analytical and finite differences Jacobians */
        if (block->dF) {
            for (i = 0; i < N; i++) {
                for (j = 0; j < N; j++) {
                    realtype fd_val = jac_fd[i * N + j];
                    realtype a_val = J->data[i * N + j];
                    realtype rel_error = RAbs(a_val - fd_val) / (RAbs(fd_val) + 1);
                    if (rel_error >= block->options->block_jacobian_check_tol) {
                        jmi_log_node(block->log, logError, "JacobianCheck",
                                     "<j: %d, i: %d, analytic: %e, finiteDifference: %e, relativeError: %e>", 
                                     j, i, a_val, fd_val, rel_error);
                    }
                }
            }
        } else {
            jmi_log_node(block->log, logError, "JacobianCheck", 
                         "No block jacobian specified, unable to do jacobian check");
        }
        free(jac_fd);
    }

    if((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "JacobianUpdated", "<block:%s>", block->label);
        if (block->callbacks->log_options.log_level >= 6) {
            jmi_log_real_matrix(block->log, node, logInfo, "jacobian", J->data, N, N);
        }
        jmi_log_leave(block->log, node);
    }
    
    return ret;
}

static void jmi_kinsol_linesearch_nonconv_error_message(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    jmi_log_node_t node = jmi_log_enter(block->log, logError, "KinsolError");
    realtype fnorm, snorm;
    KINGetFuncNorm(solver->kin_mem, &fnorm);
    KINGetStepLength(solver->kin_mem, &snorm);
    
    jmi_log_fmt(block->log, node, logError, "Error occured in <function: %s> at <t: %f> when solving <block: %s>",
        "KINSol", block->cur_time, block->label);
    jmi_log_fmt(block->log, node, logError, "<msg: %s>", "The line search algorithm was unable to find an iterate sufficiently distinct from the current iterate.");
    jmi_log_fmt(block->log, node, logError, "<functionNorm: %g, scaledStepLength: %g, tolerance: %g>",
                fnorm, snorm, solver->kin_stol);
    jmi_log_leave(block->log, node);
}

/* Logging callback for KINSOL used to report on errors during solution */
void kin_err(int err_code, const char *module, const char *function, char *msg, void *eh_data){
    jmi_log_category_t category = logWarning;
    jmi_block_solver_t *block = eh_data;
    jmi_kinsol_solver_t* solver = block->solver;
    realtype fnorm, snorm;
    KINGetFuncNorm(solver->kin_mem, &fnorm);
    KINGetStepLength(solver->kin_mem, &snorm);
    
    if((block->n == 1) && block->options->use_Brent_in_1d_flag)  /* Brent search will be used to find the root if possible -> no error */
            /* || (fnorm < solver->kin_stol)): In some cases KINSOL actually converges but returns an error anyway. Need to be double checked! */
    {
        return;
    }
    
    if ((err_code > 0) || !block->init) { /*Warning*/
        category = logWarning;
    } else if (err_code < 0){ /*Error*/
        category = logError;
    }
    
    if (err_code != KIN_LINESEARCH_NONCONV) /* If the error is LINSEARCH_NONCONV it might not be an error depending 
                                               in on the fnorm, so post-pone this error message in these cases */
    {
        jmi_log_node_t node = jmi_log_enter(block->log, category, "KinsolError");
        jmi_log_fmt(block->log, node, category, "Error occured in <function: %s> at <t: %f> when solving <block: %s>",
            function, block->cur_time, block->label);
        jmi_log_fmt(block->log, node, category, "<msg: %s>", msg);
        jmi_log_fmt(block->log, node, category, "<functionNorm: %g, scaledStepLength: %g, tolerance: %g>",
                    fnorm, snorm, solver->kin_stol);
        jmi_log_leave(block->log, node);
    }
    /* todo: remove? */
    /*
  {
        int i,j;
      jmi_simple_newton_jac(block);
      
        jmi_log(block->jmi, category, buffer);
        
        buffer[0] = 0;
        for(i=0; i<block->n; i++) {
            sprintf(buffer + strlen(buffer), "%12.12f ", block->x[i]);
         }
        jmi_log(block->jmi, category, buffer);
        
        block->F(block->jmi,block->x,block->res,JMI_BLOCK_EVALUATE);
        
        buffer[0] = 0;
        for(i=0; i<block->n; i++) {
            sprintf(buffer + strlen(buffer), "%12.12f ", block->res[i]);
         }
        jmi_log(block->jmi, category, buffer);
        
        buffer[0] = 0;
        for(i=0; i<block->n; i++) {
            for(j=0; j<block->n; j++) {
                sprintf(buffer + strlen(buffer), "%12.12f ", block->jac[j*(block->n) + i]);
            }
            sprintf(buffer + strlen(buffer), "\n");
        }
        jmi_log(block->jmi, category, buffer);
    }
*/
}

/* Logging callback used by KINSOL to report progress att higher log levels */
void kin_info(const char *module, const char *function, char *msg, void *eh_data){
    int i;
    jmi_block_solver_t *block = eh_data;
    jmi_kinsol_solver_t* solver = block->solver;
    struct KINMemRec* kin_mem = solver->kin_mem;
    realtype* residual_scaling_factors = N_VGetArrayPointer(solver->kin_f_scale);
    jmi_log_t *log = block->log;

    
    /* Only output an iteration under certain conditions:
         *  1. nle_solver_log > 2
         *  2. The calling function is either KINSolInit or KINSol
         *  3. The message string starts with "nni"
         *
         *  This approach gives one printout per iteration
         */

    if (block->callbacks->log_options.log_level >= 4)
    {
        jmi_log_node_t topnode = jmi_log_enter(log, logInfo, "KinsolInfo");
        jmi_log_fmt(log, topnode, logInfo, "<calling_function:%s>", function);
        jmi_log_fmt(log, topnode, logInfo, "<message:%s>", msg);
        
        if ((((strcmp("KINSolInit",function)==0) ||
              (strcmp("KINSol",function)==0)) && (strncmp("nni",msg,3)==0))) {
            realtype* f = N_VGetArrayPointer(kin_mem->kin_fval);
            long int nniters;

            int max_index = 0;
            realtype max_residual = 0;

            /* Get the number of iterations */
            KINGetNumNonlinSolvIters(kin_mem, &nniters);
    
            jmi_log_fmt(log, topnode, logInfo, "<iteration_index:%I>", (int)nniters);
            if (block->callbacks->log_options.log_level >= 5) {
                jmi_log_reals(log, topnode, logInfo, "ivs", N_VGetArrayPointer(kin_mem->kin_uu), block->n);
            }
            jmi_log_fmt(log, topnode, logInfo, "<scaled_residual_norm:%E>", kin_mem->kin_fnorm);
            jmi_log_fmt(log, topnode, logInfo, "<scaled_step_norm:%E>", N_VWL2Norm(kin_mem->kin_pp, kin_mem->kin_uscale));

            if (block->callbacks->log_options.log_level >= 5) {
                jmi_log_node_t node = jmi_log_enter_vector_(log, topnode, logInfo, "scaled_residuals");
                for (i=0;i<block->n;i++) jmi_log_real_(log, f[i]*residual_scaling_factors[i]);
                jmi_log_leave(log, node);
            }
            if (block->n >= 1) {
                max_residual = f[0]*residual_scaling_factors[0];
                for (i=1;i<block->n;i++) {
                    realtype res = f[i]*residual_scaling_factors[i];
                    if (RAbs(res) > RAbs(max_residual)) {
                        max_residual = res;
                        max_index = i;
                    }
                }
                jmi_log_fmt(log, topnode, logInfo, "<max_scaled_residual_value:%E>", max_residual);
                jmi_log_fmt(log, topnode, logInfo, "<max_scaled_residual_index:%I>", max_index);
            }

            {
                /* Only print header first time */
                int user_flags = jmi_log_get_user_flags(log);
                if ((user_flags & logUserFlagKinsolHeaderPrinted) == 0) {
                    jmi_log_node(log, logInfo, "Progress", "<source:%s><message:%s><isheader:%d>",
                                 "jmi_kinsol_solver",
                                 "iter      nfe    res_norm      max_res: ind   nlb  nab   lambda_max: ind      lambda",
                                 1);
                    jmi_log_set_user_flags(log, user_flags | logUserFlagKinsolHeaderPrinted);
                }
            }
            {
                /* Keep the progress message on a single line by using jmi_log_enter_, jmi_log_fmt_ etc. */
                jmi_log_node_t node = jmi_log_enter_(log, logInfo, "Progress");
                char message[256];
                realtype lambda_max;
                realtype lambda, steplength;
                int nwritten;

                if (nniters > 0 && solver->last_xnorm > 0) {
                    lambda_max = kin_mem->kin_mxnewtstep/solver->last_xnorm;
                    KINGetStepLength(kin_mem, &steplength);
                    lambda = steplength/solver->last_xnorm;
                }
                else {
                    lambda_max = lambda = 0;
                }

                if (solver->use_steepest_descent_flag) kin_char_log(solver, 'd');
                else if (solver->J_is_singular_flag) kin_char_log(solver, 'r');

                nwritten = sprintf(message, "%4d%-4s%5d %11.4e  %11.4e:%4d",
                                   (int)nniters+1, solver->char_log, (int)(block->nb_fevals),
                                   kin_mem->kin_fnorm, max_residual, max_index+1);

                kin_reset_char_log(solver);

                if (nniters > 0 && nwritten >= 0) {
                    char *buffer = message + nwritten;
                    if (solver->last_bounding_index >= 0) {
                        sprintf(buffer, "  %4d %4d  %11.4e:%4d %11.4e",
                                solver->last_num_limiting_bounds, solver->last_num_active_bounds,
                                lambda_max, solver->last_bounding_index+1, lambda);
                    }
                    else {
                        sprintf(buffer, "  %4d %4d  %11.4e      %11.4e",
                                solver->last_num_limiting_bounds, solver->last_num_active_bounds,
                                lambda_max, lambda);
                    }
                }


                jmi_log_fmt_(log, node, logInfo, "<source:%s><block:%s><message:%s>",
                             "jmi_kinsol_solver", block->label, message);
                jmi_log_leave(log, node);
            }
        }
        
        jmi_log_leave(log, topnode);
    }
    
}

/* Print out meaningfull message based on KINSOL return flag */
void jmi_kinsol_error_handling(jmi_block_solver_t * block, int flag){
    if (flag != 0) {
        jmi_log_node(block->log, logError, "KinsolError", "KINSOL returned with <kinsol_flag: %s>", jmi_kinsol_flag_to_name(flag));
    }
}

/* initialize data on bounds */
static int jmi_kinsol_init_bounds(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    
    int i,num_bounds = 0;
    
    if(!block->options->enforce_bounds_flag) {
        solver->num_bounds = 0;
        return 0;
    }
    
    for(i=0; i < block->n; ++i) {
        if(block->max[i] != BIG_REAL) num_bounds++;
        if(block->min[i] != -BIG_REAL) num_bounds++;
    }
    
    solver->num_bounds = num_bounds;
    if(!num_bounds) return 0;
    solver->bound_vindex = (int*)calloc(num_bounds, sizeof(int));
    solver->bound_kind  = (int*)calloc(num_bounds, sizeof(int));
    solver->bound_limiting  = (int*)calloc(num_bounds, sizeof(int));
    solver->bounds = (realtype*)calloc(num_bounds, sizeof(realtype));
    solver->active_bounds = (realtype*)calloc(block->n, sizeof(realtype));
    num_bounds = 0;

    for(i=0; i < block->n; ++i) {
        if(block->max[i] != BIG_REAL) {
            /* upper bound on a variable */
            solver->bound_vindex[num_bounds] = i; /* variable index */
            solver->bound_kind[num_bounds] = 1;
            solver->bounds[num_bounds] = block->max[i];
            num_bounds++;
        }
        if(block->min[i] != -BIG_REAL) {
            /* lower bound on a variable */
            solver->bound_vindex[num_bounds] = i; /* variable index */
            solver->bound_kind[num_bounds] = -1;
            solver->bounds[num_bounds] = block->min[i];
            num_bounds++;
        }
    }
    
    return 0;
}

/* Helper to convert log_level used in the logger to print level in KINSOL */
static int get_print_level(jmi_block_solver_t* bs) {
    int log_level = bs->callbacks->log_options.log_level;
    if (log_level <= 2) return 0;
    else if (log_level <= 4) return log_level-2;
    else return 3;
}

/* Initialize solver structures */
static int jmi_kinsol_init(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    int ef, i;
    double max_nominal;
    struct KINMemRec * kin_mem = solver->kin_mem; 

    jmi_log_node_t node = jmi_log_enter_fmt(block->log, logInfo, "SolverOptions", "<block:%s>", block->label);
    jmi_log_fmt(block->log, node,logInfo, "Tolerance <tolerance: %g>",block->options->res_tol);
    jmi_log_fmt(block->log, node,logInfo, "Max number of iterations <max_iter: %d>",block->options->max_iter);
    jmi_log_fmt(block->log, node,logInfo, "Experimental <mode: %d>",block->options->experimental_mode);
    jmi_log_leave(block->log, node);

    KINSetPrintLevel(solver->kin_mem, get_print_level(block));
    
    /* set tolerances */
    if((block->n > 1) || !block->options->use_Brent_in_1d_flag) {
        solver->kin_stol = block->options->res_tol;
        if(solver->kin_stol < block->options->min_tol) {
            solver->kin_stol = block->options->min_tol;
        }
    }
    else
        solver->kin_stol = block->options->min_tol;
    
    solver->kin_ftol = UROUND; /* block->options->res_tol; */
    
    /* If not set, set the default */
    if (block->options->regularization_tolerance == -1){
        solver->kin_reg_tol = 1.0/block->options->res_tol;
    } else {
        solver->kin_reg_tol = block->options->regularization_tolerance;
    }

    KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
    KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);
    KINSetNumMaxIters(solver->kin_mem, block->options->max_iter);
    
    /* Allow long steps */
    max_nominal = 1;
    for(i=0;i< block->n;++i){
        if (RAbs(block->nominal[i]) > max_nominal) {
            max_nominal = RAbs(block->nominal[i]);
        }
    }
    KINSetMaxNewtonStep(solver->kin_mem, block->options->step_limit_factor*max_nominal);
    
    if(block->options->iteration_variable_scaling_mode)
    {
        /* 
            Set variable scaling based on nominal values.          
        */
        int i;
        for(i=0;i< block->n;++i){
            double nominal = RAbs(block->nominal[i]);
            if(nominal != 1.0) {
                if(nominal == 0.0)
                    nominal = 1/solver->kin_stol;
                else
                    nominal = 1/nominal;
                Ith(solver->kin_y_scale,i)=nominal;
            }
        }
    }

    jmi_kinsol_init_bounds(block);
    
    /* evaluate the function at initial */
    ef =  kin_f(solver->kin_y, kin_mem->kin_fval, block);
    if(ef) {
        jmi_log_node(block->log, logError, "Error", "Residual function evaluation failed at initial point for "
                     "<block: %s>", block->label);
    }
    kin_mem->kin_uscale = solver->kin_y_scale;
    /* evaluate Jacobian at initial */
    if(jmi_kin_lsetup(kin_mem)) {
        ef = 1;
        jmi_log_node(block->log, logError, "Error", "Jacobian evaluation failed at initial point for "
                     "<block: %s>", block->label);
    }
    return ef;
}

/* Limit the maximum step to be within bounds. Do projection if needed. */
static void jmi_kinsol_limit_step(struct KINMemRec * kin_mem, N_Vector x, N_Vector b) {
    jmi_block_solver_t *block = (jmi_block_solver_t *)kin_mem->kin_user_data;
    jmi_kinsol_solver_t* solver = (jmi_kinsol_solver_t*)block->solver;  
    realtype xnorm;        /* step norm */
    realtype min_step_ratio; /* fraction of the Newton step that is still over minimal step*/
    realtype max_step_ratio; /* maximum step length ratio limited by bounds */

    realtype* xxd = N_VGetArrayPointer(x); /* Newton step on input, may be modified if step is projected */
    realtype* xd = N_VGetArrayPointer(b); /* used as a buffer */
    booleantype activeBounds = FALSE;
    booleantype limitingBounds = FALSE;
    int i;
    jmi_log_t *log = block->log;

    /* MAX_NETON_STEP_RATIO is used just to ensure that full Newton step can 
    be taken when no bounds are present. 
    TODO: Consider addionally limiting the Newton step length set
    based on the nominal values of the IVs.
    Consider using block->options->step_limit_factor instead
    */
#define MAX_NETON_STEP_RATIO 10.0

    xnorm = N_VWL2Norm(x, kin_mem->kin_uscale); /* scaled L2 norm of the Newton step */
    solver->last_xnorm = xnorm;
    solver->last_bounding_index = -1;
    solver->last_num_limiting_bounds = 0;
    solver->last_num_active_bounds = 0;

    if((solver->num_bounds == 0) || (xnorm == 0.0)) 
    {
        /* make sure full newton step can be taken */
        realtype maxstep = MAX_NETON_STEP_RATIO * xnorm;
#if 0
        if(maxstep > kin_mem->kin_mxnewtstep)
#endif
            kin_mem->kin_mxnewtstep = maxstep;
        return;
    }

    /*  Scale the step up so that step multiplier is 1.0 at the beginning.
        The "long" step is now saved into "b", pointed by "xd"
    */
    N_VScale(MAX_NETON_STEP_RATIO, x, b);
    
    /* minimal/maximal allowed step multiplier */
    max_step_ratio = 1.0;
    min_step_ratio = 2*solver->kin_stol;

    /* 
        Go over the list of bounds and reduce "max_step_ratio" 
    */
    for(i = 0; i < solver->num_bounds; ++i) {
        int index = solver->bound_vindex[i]; /* variable index */
        int kind = solver->bound_kind[i];   /* min or max */
        realtype ui =  NV_Ith_S(kin_mem->kin_uu,index);  /* current variable value */
        realtype pi = xd[index];            /* solved step length for the variable*/
        realtype bound = solver->bounds[i]; 
        realtype pbi = (bound - ui)*(1 - UNIT_ROUNDOFF);  /* distance to the bound */
        realtype step_ratio_i;
        if(    ((kind == 1)&& (pbi >= pi))
            || ((kind == -1)&& (pbi <= pi))) {
            solver->bound_limiting[i] = 0 ;
            continue; /* will not cross the bound */
        }

        solver->bound_limiting[i] = 1 ;
        limitingBounds = TRUE ;
        solver->last_num_limiting_bounds++;
        step_ratio_i =pbi/pi;   /* step ration to bound */
        if(step_ratio_i < min_step_ratio) {
            /* this bound is active (we need to follow it) */
            activeBounds = TRUE;
            solver->last_num_active_bounds++;
            xxd[index] = 0;
            /* distance to the bound */
            solver->active_bounds[index] = pbi; /*  (kind == 1)? pbi:-pbi ; */
        }
        else {
            if (max_step_ratio > step_ratio_i) {
                /* reduce the step */
                max_step_ratio = step_ratio_i;
                solver->last_bounding_index = index;
            }
        }
    }

    /* log the bounds that limit the step */
    if (block->callbacks->log_options.log_level >= 5 && limitingBounds) {
        /* Print limiting bounds */
        jmi_log_node_t outer = jmi_log_enter_(log, logInfo, "LimitationBounds");
        int kind;
        for (kind=1; kind >= -1; kind -= 2) {
            jmi_log_node_t inner = jmi_log_enter_vector_(log, outer, logInfo, 
                                                         kind==1 ? "max" : "min");            
            for (i=0; i < solver->num_bounds; i++) {
                int index = solver->bound_vindex[i]; /* variable index */
                if (solver->bound_limiting[i] != 0
                    && solver->bound_kind[i] == kind) {
                    jmi_log_vref_(log, 'r', block->value_references[index]);
                }
            }
            jmi_log_leave(log, inner);
        }
        jmi_log_leave(log, outer);
    }
    /* log the bounds that we are following */
    if (block->callbacks->log_options.log_level >= 5 && activeBounds) {        
        /* Print active bounds*/
        jmi_log_node_t outer = jmi_log_enter_(log, logInfo, "ActiveBounds");
        int kind;
        for (kind=1; kind >= -1; kind -= 2) {
            jmi_log_node_t inner = jmi_log_enter_vector_(log, outer, logInfo, 
                                                         kind==1 ? "max" : "min");            
            for (i=0; i < solver->num_bounds; i++) {
                int index = solver->bound_vindex[i]; /* variable index */
                
                if (solver->bound_limiting[i] 
                    && solver->active_bounds[index] != 0
                    && solver->bound_kind[i] == kind) {
                    jmi_log_vref_(log, 'r', block->value_references[index]);
                }
            }
            jmi_log_leave(log, inner);
        }
        jmi_log_leave(log, outer);
    }

    /* 
        Since analysis was done with x = MAX_NETON_STEP_RATIO * Newton step
        the actual Newton step ration is also MAX_NETON_STEP_RATIO larger
    */
    max_step_ratio *= MAX_NETON_STEP_RATIO * (1 - UNIT_ROUNDOFF);
    
    /* If the step is limited by a bound or we're following the bound it
    should be allowed to take the full step length more than 5 times
    which is a fixed check in KINSOL */
    if((max_step_ratio < 1) || activeBounds) {
        kin_mem->kin_ncscmx = 0; /* allow for more steps of kin_mxnewtstep length in this case */
    }

    if(!activeBounds) {
        /* bounds do not affect the base-line algorithm, only limit the step */
        kin_mem->kin_mxnewtstep = max_step_ratio * xnorm ;
        return;
    }

    /* Update the x to be the maximum vector within bounds */ 
    for(i = 0; i < block->n; ++i) {
        realtype bnd = solver->active_bounds[i];
        if(bnd != 0.0) { /* the maximum step should keep us on this active bound */
            xd[i] = bnd;
            solver->active_bounds[i] = 0;
        }
        else if(max_step_ratio < 1.0) { /* update the step length for other vars */
            xd[i] = xxd[i] * max_step_ratio;
        }
        else xd[i] = xxd[i];
    }
    if(max_step_ratio < 1.0) {
        /* reduce the norms of Jp. This is only approximate since active bounds are not accounted for.*/
        kin_mem->kin_sfdotJp *= max_step_ratio;
        kin_mem->kin_sJpnorm *= max_step_ratio;
    }
    /* The maximum newton step leads to the bound  
    -> store the "x" and set maximum step to be L2 norm of x */
    N_VScale(1.0, b, x);

    xnorm = N_VWL2Norm(x, kin_mem->kin_uscale); /* scaled L2 norm of the Newton step */
    solver->last_xnorm = xnorm*(1 - UNIT_ROUNDOFF);

    kin_mem->kin_mxnewtstep =  solver->last_xnorm;
}

/* Form regualrized matrix Transpose(J).J */
static void jmi_kinsol_reg_matrix(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    /*    jmi_t * jmi = block->jmi; */
    int i,j,k;
    realtype **JTJ_c =  solver->JTJ->cols;
    realtype **jac = solver->J->cols;
    int N = block->n;
    
    /* Add the regularization parameter on the diagonal.
    TODO: consider using scales of X instead of 1.0 for regularization
      */

    for (i=0;i<N;i++) {
        /*Calculate value at RTR(i,i) */
        JTJ_c[i][i] = 1;
        for (k=0;k<N;k++) JTJ_c[i][i] += jac[i][k]*jac[i][k];
        for (j=i+1;j<N;j++){
            
            /*Calculate value at RTR(i,j) */
            JTJ_c[j][i] = 0;
            for (k=0;k<N;k++) JTJ_c[j][i] += jac[j][k]*jac[i][k];
            JTJ_c[i][j] = JTJ_c[j][i];
        }
    }
}

/* Estimate condition number utilizing dgecon from LAPACK*/
static realtype jmi_calculate_jacobian_condition_number(jmi_block_solver_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    char norm = 'I';
    int N = block->n;
    double J_norm = 1.0;
    double J_recip_cond = 1.0;
    int info;

    /* Copy Jacobian to factorization matrix */
    DenseCopy(solver->J, solver->J_LU);
    /* Perform LU factorization to be used with dgecon */
    dgetrf_(&N, &N, solver->J_LU->data, &N, solver->lapack_ipiv, &info);
    if (info != 0 ) {
    	/* If matrix i singular, return something very large to be evaluated*/
    	return 1e100;
    }

    /* Compute infinity norm of J to be used with dgecon */
    J_norm = dlange_(&norm, &N, &N, solver->J->data, &N, solver->lapack_work);

    /* Compute reciprocal condition number */
    dgecon_(&norm, &N, solver->J_LU->data, &N, &J_norm, &J_recip_cond, solver->lapack_work, solver->lapack_iwork,&info);
    /* To be evaluated - why is this needed? Error handling due to J being used instead of J_LU?
    if(Jcond < 0) Jcond = -Jcond;
    if(Jcond == 0.0) Jcond = 1e-30;
    */
    return 1.0/J_recip_cond;
}

/* Callback from KINSOL called to calculate Jacobian */
static int jmi_kin_lsetup(struct KINMemRec * kin_mem) {
    jmi_block_solver_t *block = kin_mem->kin_user_data;
    jmi_kinsol_solver_t* solver = block->solver;
    
    int info;
    int N = block->n;
      
    int ret;
    SetToZero(solver->J);

    /* Evaluate Jacobian */
    ret = kin_dF(N, solver->kin_y, kin_mem->kin_fval, solver->J, block, kin_mem->kin_vtemp1, kin_mem->kin_vtemp2);
    solver->updated_jacobian_flag = 1; /* The Jacobian is current */
    
    if(ret != 0 ) return ret; /* There was an error in calculation of Jacobian */
    
    if(solver->use_steepest_descent_flag) return ret; /* No further processing when using steepest descent */

    DenseCopy(solver->J, solver->J_LU); /* make at copy of the Jacobian that will be used for LU factorization */

    /* Equillibrate if corresponding option is set */
    if((N>1) && block->options->use_jacobian_equilibration_flag) {
        int info;
        double rowcnd, colcnd, amax;
        dgeequ_(&N, &N, solver->J_LU->data, &N, solver->rScale, solver->cScale, 
                &rowcnd, &colcnd, &amax, &info);
        if(info == 0) {
            dlaqge_(&N, &N, solver->J_LU->data, &N, solver->rScale, solver->cScale, 
                    &rowcnd, &colcnd, &amax, &solver->equed);
        }
        else
            solver->equed = 'N';
    }
    
    /* Perform factorization to detect if there is a singular Jacobian */
    dgetrf_(  &N, &N, solver->J_LU->data, &N, solver->lapack_ipiv, &info);
    
    if(info != 0 ) {
        solver->J_is_singular_flag = 1;
        jmi_log_node(block->log, logWarning, "Regularization", "Singular Jacobian detected when factorizing in linear solver. "
                     "Will try to regularize the equations in <block: %s>", block->label);
        if(N > 1) {
            jmi_kinsol_reg_matrix(block);
            dgetrf_(  &N, &N, solver->JTJ->data, &N, solver->lapack_ipiv, &info);
        }
    } else {
        /* if (solver->using_max_min_scaling_flag) {
            realtype cond = jmi_calculate_condition_number(block, solver->J->data);
            jmi_log_node(block->log, logWarning, "JacobianConditioningNumber",
                             "<JacobianConditionEstimate:%E> large values may lead to convergence problems.", cond);
        }
        */
        solver->J_is_singular_flag = 0;
    }
    
    if(solver->force_new_J_flag ) {
        /* If the Jacobian was caluclated due to the singularity in the previous point
        update the residual scales if corresponding option is set
       */
        solver->force_new_J_flag = 0;
        if(block->options->rescale_after_singular_jac_flag)
            jmi_update_f_scale(block);
    }    
        
    return 0;
        
}

/* Callback from KINSOL to solver linear system and calculate the step */
static int jmi_kin_lsolve(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *res_norm) {
    jmi_block_solver_t *block = kin_mem->kin_user_data;
    jmi_kinsol_solver_t* solver = block->solver;
    realtype*  bd = N_VGetArrayPointer(b); /* residuals */
    realtype*  xd = N_VGetArrayPointer(x); /* iteration vars */
    jmi_log_node_t node;
    
    int N = block->n;
    char trans = 'N';
    int ret = 0, i;
    
    solver->updated_jacobian_flag = 0; /* The Jacobian is no longer current */
    
    if(solver->force_new_J_flag) {        
        return 1;
    }
    
    /*
      Taken directly from SUNDIALS:
 
        Compute the terms Jpnorm and sfdotJp for use in the global strategy
       routines and in KINForcingTerm. Both of these terms are subsequently
       corrected if the step is reduced by constraints or the line search.
  
       sJpnorm is the norm of the scaled product (scaled by fscale) of
       the current Jacobian matrix J and the step vector p.
  
       sfdotJp is the dot product of the scaled f vector and the scaled
       vector J*p, where the scaling uses fscale. */
    if((block->callbacks->log_options.log_level >= 6)) {
        node = jmi_log_enter_fmt(block->log, logInfo, "KinsolLinearSolver", "Solving the linear system in <block:%s>", block->label);
    }
  
    kin_mem->kin_sJpnorm = N_VWL2Norm(b,solver->kin_f_scale);
    N_VProd(b, solver->kin_f_scale, x);
    N_VProd(x, solver->kin_f_scale, x);
    
    kin_mem->kin_sfdotJp = N_VDotProd(kin_mem->kin_fval, x);

    /* if the Jacobian was equilibrated then scale the residuals accordingly */
    if((solver->equed == 'R') || (solver->equed == 'B')) {
        for(i = 0; i < N; i++) {
            bd[i] *= solver->rScale[i];
        }
    }
    if(solver->use_steepest_descent_flag) {
        /* Make step in steepest descent direction and not Newton*/
        realtype **jac = solver->J->cols;
        int N = block->n;
        int j;
        
#if 1
        /*  Step = Transpose(J) W*W F, 
            where W is the diagonal matix of residual scaling factors. 
            W*W F is effectively calculated above in "x" as a part of kin_sfdotJp calculation.
            Step is saved in "b" and then copied into "x" */
        for (i=0;i<N;i++) {
            bd[i] = 0;
            for (j=0;j<N;j++){
                bd[i] += jac[i][j] * xd[j];
            }
        }
        N_VScale(ONE, b, x);
#else
        /* Test steepest descent without scaling */
        for (i=0;i<N;i++) {
            xd[i] = 0;
            for (j=0;j<N;j++){
/*                printf("x[%d] += jac[%d][%d] * b[%d], %g += %g * %g\n",
                       i,i,j,j,xd[i], jac[i][j], bd[j]);*/
                xd[i] += jac[i][j] * bd[j];
            }
        }
#endif
        ret = 0;
    }
    else if(solver->J_is_singular_flag) {
        /* solve the regularized problem */
        
        realtype** jac = solver->J->cols;
        if(N > 1) {
            int i,j;
            for (i=0;i<N;i++){
                xd[i] = 0;
                for (j=0;j<N;j++) xd[i] += jac[i][j]*bd[j];
            }
            /* Back-solve and get solution in x */
            trans = 'N'; /* No transposition */
            i = 1;
            dgetrs_(&trans, &N, &i, solver->JTJ->data, &N, solver->lapack_ipiv, xd, &N, &ret);
            solver->force_new_J_flag = 1;
        }
        else {
            xd[0] = block->nominal[0] * 0.1 *((bd[0] > 0)?1:-1) * ((jac[0][0] > 0)?1:-1);
			ret = 0;
        }

		/* Evaluate discrete variables after a regularization. */
		if (block->at_event) {
            jmi_log_node_t inner_node;
			if(block->callbacks->log_options.log_level >= 5 && block->log_discrete_variables) {
                inner_node =jmi_log_enter_fmt(block->log, logInfo, "RegularizationDiscreteUpdate", 
                                "Evaluating switches after regularization.");
                jmi_log_fmt(block->log, inner_node, logInfo, "Pre discrete variables");
                block->log_discrete_variables(block->problem_data, inner_node);
			}

            block->F(block->problem_data, block->x, block->res, JMI_BLOCK_EVALUATE | JMI_BLOCK_EVALUATE_NON_REALS);
            
            if(block->callbacks->log_options.log_level >= 5 && block->log_discrete_variables) {
                jmi_log_fmt(block->log, inner_node, logInfo, "Post discrete variables");
                block->log_discrete_variables(block->problem_data, inner_node);
                jmi_log_leave(block->log, inner_node);
			}
		}
    }
    else {
        /* Normal linear system solve (with LU) to get Newton step */
        N_VScale(ONE, b, x);
        i = 1;
        
        if((block->callbacks->log_options.log_level >= 6)) {
            jmi_log_real_matrix(block->log, node, logInfo, "jacobian", solver->J->data, N, N);
            jmi_log_reals(block->log, node, logInfo, "rhs", xd, N);
        }
        
        dgetrs_(&trans, &N, &i, solver->J_LU->data, &N, solver->lapack_ipiv, xd, &N, &ret);
        
        if((block->callbacks->log_options.log_level >= 6)) {
            jmi_log_reals(block->log, node, logInfo, "solution", xd, N);
        }
    }

    if((block->callbacks->log_options.log_level >= 6)) {
        jmi_log_leave(block->log, node);
    }

    if(ret) return ret; /* Break out on error */
    
    if((solver->equed == 'C') || (solver->equed == 'B')) {
        /* scale solution if the Jacobian was equilibrated */
        int i;
        for(i = 0; i < block->n; i++) {
            xd[i] *= solver->cScale[i];
        }
    }

    {
        jmi_log_node_t topnode;
        if(block->callbacks->log_options.log_level >= 5) {
            topnode = jmi_log_enter_(block->log,logInfo,"StepDirection");
            jmi_log_reals(block->log, topnode, logInfo, "unbounded_step", xd, block->n);
        }
        jmi_kinsol_limit_step(kin_mem, x, b);
        if(block->callbacks->log_options.log_level >= 5) {
            jmi_log_reals(block->log, topnode, logInfo, "bounded_step", xd, block->n);
            jmi_log_leave(block->log, topnode);
        }
    }
    return 0;
}

/* 
    Compute appropriate equation scaling and function tolerance based on Jacobian J,
    nominal values (block->nominal) and current point (block->x).
    Store result in solver->kin_f_scale.
*/
static void jmi_update_f_scale(jmi_block_solver_t *block) {
    realtype* dummy = 0;
    jmi_kinsol_solver_t* solver = block->solver; 
    int i, N = block->n;
    realtype tol = solver->kin_stol;
    realtype curtime = block->cur_time;
    realtype* scale_ptr = N_VGetArrayPointer(solver->kin_f_scale);
    realtype* col_ptr;
    realtype* scaled_col_ptr;
    int use_scaling_flag = block->options->residual_equation_scaling_mode;

    solver->kin_scale_update_time = curtime;
    kin_char_log(solver, 's');

    /* Form scaled Jacobian as needed for automatic scaling and condition number checking*/
    if((block->options->residual_equation_scaling_mode != jmi_residual_scaling_none)
            || block->options->check_jac_cond_flag){

        if(block->options->residual_equation_scaling_mode == jmi_residual_scaling_auto) {
            /* Zero out the scales initially. */
            N_VConst_Serial(0,solver->kin_f_scale);
        }

        for(i = 0; i < N; i++){
            int j;
            /* column scaling is formed by max(nominal, actual_value) */
            realtype xscale = RAbs(block->nominal[i]);
            realtype x = RAbs(block->x[i]);
            if(x < xscale) x = xscale;
            if(x < tol) x = tol;
            col_ptr = DENSE_COL(solver->J, i);
            scaled_col_ptr = DENSE_COL(solver->J_scale, i);

            /* row scaling is product of Jac entry and column scaling */
            for(j = 0; j < N; j++){
                realtype dres = col_ptr[j];
                realtype fscale;
                fscale = dres * x;
                scaled_col_ptr[j] = fscale;
                if(block->options->residual_equation_scaling_mode == jmi_residual_scaling_auto) {
                    scale_ptr[j] = MAX(scale_ptr[j], RAbs(fscale));
                }
            }
        }
    }
    
    /* Read manual scaling from annotations and put them in scale_ptr*/
    if(block->options->residual_equation_scaling_mode == jmi_residual_scaling_manual){
        block->F(block->problem_data,dummy,scale_ptr,JMI_BLOCK_EQUATION_NOMINAL) ;
    }
    
    if(use_scaling_flag) {
        solver->using_max_min_scaling_flag = 0; /* NOT using max/min scaling */
        /* check that scaling factors has reasonable magnitude */
        for(i = 0; i < N; i++) {
            if(scale_ptr[i] < tol) {
                scale_ptr[i] = 1/tol; /* Singular Jacobian? */
                solver->using_max_min_scaling_flag = 1; /* Using maximum scaling */
                jmi_log_node(block->log, logWarning, "Warning", "Using maximum scaling factor in <block: %s>, "
                             "<equation: %I> Consider rescaling in the model or tighter tolerance.", block->label, i);
            }
            else if(scale_ptr[i] > 1/tol) {
                scale_ptr[i] = tol;
                solver->using_max_min_scaling_flag = 1; /* Using minimum scaling */
                jmi_log_node(block->log, logWarning, "Warning", "Using minimal scaling factor in <block: %s>, "
                             "<equation: %I> Consider rescaling in the model or tighter tolerance.", block->label, i);
            }
            else
                scale_ptr[i] = 1/scale_ptr[i];
        }

        if (block->callbacks->log_options.log_level >= 4) {
            jmi_log_node_t outer = jmi_log_enter_fmt(block->log, logInfo, "ResidualScalingUpdated", "<block:%s>", block->label);
            if (block->callbacks->log_options.log_level >= 5) {
                jmi_log_node_t inner = jmi_log_enter_vector_(block->log, outer, logInfo, "scaling");
                realtype* res = scale_ptr;
                for (i=0;i<N;i++) jmi_log_real_(block->log, 1/res[i]);
                jmi_log_leave(block->log, inner);
            }
            jmi_log_leave(block->log, outer);
        }
    }
    
    if (solver->using_max_min_scaling_flag) {
        realtype cond = jmi_calculate_jacobian_condition_number(block);

        jmi_log_node(block->log, logInfo, "Regularization",
            "Calculated condition number in <block: %s>. Regularizing if <cond: %E> is greater than <regtol: %E>", block->label, cond, solver->kin_reg_tol);
        if (cond > solver->kin_reg_tol) {
            if(N > 1) {
                int info;
                jmi_kinsol_reg_matrix(block);
                dgetrf_(  &block->n, &block->n, solver->JTJ->data, &block->n, solver->lapack_ipiv, &info);
            }
            solver->J_is_singular_flag = 1;
        }
    }
    
    
    /* estimate condition number of the scaled jacobian 
        and scale function tolerance with it. */
    if((N > 1) && block->options->check_jac_cond_flag){
        realtype* scaled_col_ptr;
        char norm = 'I';
        double Jnorm = 1.0, Jcond = 1.0;
        int info;

        for(i = 0; i < N; i++){
            int j;
            scaled_col_ptr = DENSE_COL(solver->J_scale, i);
            for(j = 0; j < N; j++){
                scaled_col_ptr[j] = scaled_col_ptr[j] * scale_ptr[j];
            }
        }

        dgetrf_(  &N, &N, solver->J_scale->data, &N, solver->lapack_iwork, &info);
        if(info > 0) {
            jmi_log_node(block->log, logWarning, "SingularJacobian",
                         "Singular Jacobian detected when checking condition number in <block:%s>. Solver may fail to converge.", block->label);
        }
        else {
            dgecon_(&norm, &N, solver->J_scale->data, &N, &Jnorm, &Jcond, solver->lapack_work, solver->lapack_iwork,&info);       
            
            if(tol * Jcond < UNIT_ROUNDOFF) {
                jmi_log_node(block->log, logWarning, "IllConditionedJacobian",
                             "<JacobianInverseConditionEstimate:%E> Solver may fail to converge.", Jcond);
            }
            else {
                jmi_log_node(block->log, logInfo, "JacobianCondition",
                             "<JacobianInverseConditionEstimate:%E>", Jcond);
            }
        }
    }
    return;
}

int jmi_kinsol_solver_new(jmi_kinsol_solver_t** solver_ptr, jmi_block_solver_t* block) {
    jmi_kinsol_solver_t* solver;
    int flag, n = block->n;
    
    struct KINMemRec * kin_mem = KINCreate();
    if(!kin_mem) return -1;
    solver = (jmi_kinsol_solver_t*)calloc(1,sizeof(jmi_kinsol_solver_t));
    if(!solver ) return -1;
    solver->kin_mem = kin_mem;
    
    /*Initialize work vectors.*/

    /*Sets the scaling vectors to ones.*/
    /*To be changed. */
    solver->kin_y = N_VMake_Serial(n, block->x);
    solver->kin_y_scale = N_VNew_Serial(n);
    solver->kin_f_scale = N_VNew_Serial(n);
    solver->kin_scale_update_time = -1.0;
    solver->kin_jac_update_time = -1.0;
    /*NOTE: it'd be nice to use "jmi->newton_tolerance" here
      However, newton_tolerance is not set yet at this point.
    */
    solver->kin_ftol = UROUND; /* block->options->min_tol; */
    solver->kin_stol = block->options->min_tol;
    solver->using_max_min_scaling_flag = 0; /* Not using max/min scaling */
    
    solver->J = NewDenseMat(n ,n);
    solver->JTJ = NewDenseMat(n ,n);
    solver->J_LU = NewDenseMat(n ,n);
    solver->J_scale = NewDenseMat(n ,n);

    solver->equed = 'N';
    solver->rScale = (realtype*)calloc(n+1,sizeof(realtype));
    solver->cScale = (realtype*)calloc(n+1,sizeof(realtype));

    solver->lapack_work = (realtype*)calloc(4*(n+1),sizeof(realtype));
    solver->lapack_iwork = (int *)calloc(n+2, sizeof(int));
    solver->lapack_ipiv = (int *)calloc(n+2, sizeof(int));

    kin_reset_char_log(solver);

    /* Initialize scaling to 1.0 - defaults */
    N_VConst_Serial(1.0,solver->kin_y_scale);

    /* Initial equation scaling is 1.0 */
    N_VConst_Serial(1.0,solver->kin_f_scale);
                
    flag = KINInit(solver->kin_mem, kin_f, solver->kin_y); /*Initialize Kinsol*/
    jmi_kinsol_error_handling(block, flag);
    
    /*Attach linear solver*/
    /*Dense Kinsol solver*/
    /*flag = KINDense(solver->kin_mem, block->n);
      jmi_kinsol_error_handling(flag);*/
     
     
   /*Dense Kinsol using regularization*/
    /*    flag = KINPinv(solver->kin_mem, block->n);
    jmi_kinsol_error_handling(jmi, flag);
    KINDlsSetDenseJacFn(solver->kin_mem, (KINDlsDenseJacFn)kin_dF);

    */
    kin_mem->kin_lsetup = jmi_kin_lsetup;
    kin_mem->kin_lsolve = jmi_kin_lsolve;
    kin_mem->kin_setupNonNull = TRUE;
    kin_mem->kin_inexact_ls = FALSE;
    
    /*End linear solver*/
    
    /*Set problem data to Kinsol*/
    flag = KINSetUserData(solver->kin_mem, block);
    jmi_kinsol_error_handling(block, flag);  
    
    /*Stopping tolerance of F -> just a default */
    KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol); 
    
    /*Stepsize tolerance*/
    KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
    
    /* Max number of iters */
    KINSetNumMaxIters(solver->kin_mem, block->options->max_iter);
    
    /* Disable residual monitoring (since inexact solution is given sometimes by 
    the linear solver) */
    KINSetNoResMon(solver->kin_mem,1);

    /*Verbosity*/
    KINSetPrintLevel(solver->kin_mem, get_print_level(block));
    
    /*Error function*/
    KINSetErrHandlerFn(solver->kin_mem, kin_err, block);
    /*Info function*/
    KINSetInfoHandlerFn(solver->kin_mem, kin_info, block);
    /*  Jacobian can be reused */
    KINSetNoInitSetup(solver->kin_mem, 1);    
      
    *solver_ptr = solver;

    return flag;
}

void jmi_kinsol_solver_delete(jmi_block_solver_t* block) {
    jmi_kinsol_solver_t* solver = block->solver;
    
    /*Deallocate Kinsol work vectors.*/
    N_VDestroy_Serial(solver->kin_y);
    N_VDestroy_Serial(solver->kin_y_scale);
    N_VDestroy_Serial(solver->kin_f_scale);
    DestroyMat(solver->J);
    DestroyMat(solver->JTJ);
    DestroyMat(solver->J_LU);
    DestroyMat(solver->J_scale);
    free(solver->cScale);
    free(solver->rScale);
    free(solver->lapack_work);
    free(solver->lapack_iwork);
    free(solver->lapack_ipiv);
    
    if(solver->num_bounds > 0) {
        free(solver->bound_vindex);
        free(solver->bound_kind);
        free(solver->bound_limiting);
        free(solver->bounds);
        free(solver->active_bounds);
    }
    
    /*Deallocate Kinsol */
    KINFree(&(solver->kin_mem));
    /*Deallocate struct */
    free(solver);
    block->solver = 0;
}

void jmi_kinsol_solver_print_solve_start(jmi_block_solver_t * block,
                                         jmi_log_node_t *destnode) {
    if ((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_t *log = block->log;
        *destnode = jmi_log_enter_fmt(log, logInfo, "NewtonSolve", 
                                      "Newton solver invoked for <block:%s>", block->label);
        if ((block->callbacks->log_options.log_level >= 5)) {
            jmi_log_vrefs(log, *destnode, logInfo, "variables", 'r', block->value_references, block->n);
            jmi_log_reals(log, *destnode, logInfo, "max", block->max, block->n);
            jmi_log_reals(log, *destnode, logInfo, "min", block->min, block->n);
            jmi_log_reals(log, *destnode, logInfo, "nominal", block->nominal, block->n);
            jmi_log_reals(log, *destnode, logInfo, "initial_guess", block->x, block->n);
        }
    }
}

const char *jmi_kinsol_flag_to_name(int flag) {
    /*
        char* name = KINGetReturnFlagName(flag);
        KINGetReturnFlagName(flag) allocates memory and may cause memleak
     */

    switch (flag) {
    case KIN_SUCCESS: return "KIN_SUCCESS";
    case KIN_INITIAL_GUESS_OK: return "KIN_INITIAL_GUESS_OK";
    case KIN_STEP_LT_STPTOL: return "KIN_STEP_LT_STPTOL";
    case KIN_WARNING: return "KIN_WARNING";
    case KIN_MEM_NULL: return "KIN_MEM_NULL";
    case KIN_ILL_INPUT: return "KIN_ILL_INPUT";
    case KIN_NO_MALLOC: return "KIN_NO_MALLOC";
    case KIN_MEM_FAIL: return "KIN_MEM_FAIL";
    case KIN_LINESEARCH_NONCONV: return "KIN_LINESEARCH_NONCONV";
    case KIN_MAXITER_REACHED: return "KIN_MAXITER_REACHED";
    case KIN_MXNEWT_5X_EXCEEDED: return "KIN_MXNEWT_5X_EXCEEDED";
    case KIN_LINESEARCH_BCFAIL: return "KIN_LINESEARCH_BCFAIL";
    case KIN_LINSOLV_NO_RECOVERY: return "KIN_LINSOLV_NO_RECOVERY";
    case KIN_LINIT_FAIL: return "KIN_LINIT_FAIL";
    case KIN_LSETUP_FAIL: return "KIN_LSETUP_FAIL";
    case KIN_LSOLVE_FAIL: return "KIN_LSOLVE_FAIL";
    case KIN_SYSFUNC_FAIL: return "KIN_SYSFUNC_FAIL";
    case KIN_FIRST_SYSFUNC_ERR: return "KIN_FIRST_SYSFUNC_ERR";
    default: return "UNKNOWN";
    }
}

void jmi_kinsol_solver_print_solve_end(jmi_block_solver_t * block, const jmi_log_node_t *node, int flag) {
    long int nniters;
    jmi_kinsol_solver_t* solver = block->solver;
    KINGetNumNonlinSolvIters(solver->kin_mem, &nniters);

    /* NB: must match the condition in jmi_kinsol_solver_print_solve_start exactly! */
    if((block->callbacks->log_options.log_level >= 4)) {
        jmi_log_t *log = block->log;
        const char *flagname = jmi_kinsol_flag_to_name(flag);
        if (flagname != NULL) jmi_log_fmt(log, *node, logInfo, "Newton solver finished with <kinsol_exit_flag:%s>", flagname);
        else jmi_log_fmt(log, *node, logInfo, "Newton solver finished with unrecognized <kinsol_exit_flag:%d>", flag);
        jmi_log_leave(log, *node);
    }
}


int jmi_kinsol_solver_solve(jmi_block_solver_t * block){
    int flag;
    jmi_kinsol_solver_t* solver = block->solver;
    realtype curtime = block->cur_time;
    long int nniters = 0;
    int flagNonscaled;
    realtype fnorm;
    jmi_log_node_t topnode;
    jmi_log_t *log = block->log;

    if(block->n == 1) {
       if (block->options->use_Brent_in_1d_flag) {
           return jmi_brent_solver_solve(block);
       }
       solver->f_pos_min_1d = BIG_REAL;
       solver->f_neg_max_1d = -BIG_REAL;
    }
    
    if(block->init) {
        flag = jmi_kinsol_init(block);
        if(flag) return flag;
    }
    else {
        /* Read initial values for iteration variables from variable vector.
        * This is needed if the user has changed initial guesses in between calls to
        * Kinsol.
        */
        flag = block->F(block->problem_data,block->x,block->res,JMI_BLOCK_INITIALIZE);
        if(flag) {        
            jmi_log_node(log, logWarning, "Error", "<errorCode: %d> returned from <block: %s> "
                         "when reading initial guess.", flag, block->label);
            return flag;
        }
    }

    /* update the scaling only once per time step */
    if(block->init || (block->options->rescale_each_step_flag && (curtime > solver->kin_scale_update_time))) {
        jmi_update_f_scale(block);
    }
    
    if(block->options->experimental_mode & jmi_block_solver_experimental_steepest_descent_first) {
        KINSetNoResMon(solver->kin_mem,0);        
        solver->use_steepest_descent_flag = 1;
    }
            
    jmi_kinsol_solver_print_solve_start(block, &topnode);
    flag = KINSol(solver->kin_mem, solver->kin_y, KIN_LINESEARCH, solver->kin_y_scale, solver->kin_f_scale);
    if(block->options->experimental_mode & jmi_block_solver_experimental_steepest_descent_first) {
        KINSetNoResMon(solver->kin_mem,1);
        solver->use_steepest_descent_flag = 0;
    }
    if(flag != KIN_SUCCESS) {
        if(flag == KIN_INITIAL_GUESS_OK) {
            flag = KIN_SUCCESS;
        } /* If the evaluation of the residuals fails, e.g. due to NaN in the residuals, the Kinsol exits, but the old fnorm
             from a previous solve, possibly converged, is still stored. In such cases Kinsol reports success based on a fnorm
             value from a previous solve - if the previous solve was converged, then also a following faulty solve will be reproted
             as a success. Commenting out this code since it causes problems.*/
        else if (flag == KIN_LINESEARCH_NONCONV || flag == KIN_STEP_LT_STPTOL) {
            realtype fnorm;
            KINGetFuncNorm(solver->kin_mem, &fnorm);
            if(fnorm < solver->kin_stol) { /* Kinsol returned nonconv but the residuals are converged */
                flag = KIN_SUCCESS;
            } else if (flag == KIN_LINESEARCH_NONCONV) { /* Print the postponed error message */
                jmi_kinsol_linesearch_nonconv_error_message(block);
            }

        }
    }
    jmi_kinsol_solver_print_solve_end(block, &topnode, flag);
    
    /* Brent is called for 1D to get higher accuracy. It is called independently on the KINSOL success */ 
    if((block->n == 1) && block->options->use_Brent_in_1d_flag) {
        jmi_log_node(log, logInfo, "Brent", "Trying Brent's method in <block: %s>", block->label);
        if(( solver->f_pos_min_1d != BIG_REAL) &&
                ( solver->f_neg_max_1d != -BIG_REAL)) {
            
            realtype u, f;
            if(!jmi_brent_search(brentf, solver->y_neg_max_1d,  solver->y_pos_min_1d, 
                                 solver->f_neg_max_1d,  solver->f_pos_min_1d, 0, &u, &f,block)) {
                block->x[0] = u;
                flag = KIN_SUCCESS;
            }                
        }
        if(flag != KIN_SUCCESS) {
            jmi_log_node(log, logError, "Error", "Could neither iterate to required accuracy "
                         "nor bracket the root of 1D equation in <block: %s>", block->label);
        }
    } 
    
    if((block->options->experimental_mode & jmi_block_solver_experimental_steepest_descent) &&
        (flag != KIN_SUCCESS)) {
        /* try to solve with steepest descent instead */

        jmi_log_node(log, logInfo, "Progress", "<source:%s><block:%s><message:%s>",
                     "jmi_kinsol_solver", block->label, "Attempting steepest descent iterations");        

        solver->use_steepest_descent_flag = 1;
        KINSetNoResMon(solver->kin_mem,0);
        flag = KINSol(solver->kin_mem, solver->kin_y, KIN_LINESEARCH, solver->kin_y_scale, solver->kin_f_scale);
        if(flag == KIN_INITIAL_GUESS_OK) {
            flag = KIN_SUCCESS;
        }
        KINSetNoResMon(solver->kin_mem,1);
        solver->use_steepest_descent_flag = 0;
    }
    
    /* First time scaling is always recomputed - initial guess may be "far away" and give bad scaling 
       TODO: we should probably rescale after event as well.
    */
    if(    (block->options->residual_equation_scaling_mode != jmi_residual_scaling_none ) 
        && (block->init || (flag != KIN_SUCCESS))) {
        jmi_log_node(log, logInfo, "Rescaling", "Attempting rescaling in <block:%s>", block->label);

        flagNonscaled = flag;
        /* Get & store debug information */
        KINGetNumNonlinSolvIters(solver->kin_mem, &block->nb_iters);
        if(flagNonscaled < 0) {
            jmi_log_node(log, logWarning, "Warning", "The equations with initial scaling didn't converge to a "
                         "solution in <block: %s>", block->label);
        }
        /* Update the scaling  */
        jmi_update_f_scale(block);
        
        jmi_kinsol_solver_print_solve_start(block, &topnode);
        flag = KINSol(solver->kin_mem, solver->kin_y, KIN_LINESEARCH, solver->kin_y_scale, solver->kin_f_scale);
        if(flag == KIN_INITIAL_GUESS_OK) {
            flag = KIN_SUCCESS;
        } else if (flag == KIN_LINESEARCH_NONCONV || flag == KIN_STEP_LT_STPTOL) {
            KINGetFuncNorm(solver->kin_mem, &fnorm);
            if(fnorm <= solver->kin_stol) {
                flag = KIN_SUCCESS;
            } else if (flag == KIN_LINESEARCH_NONCONV) { /* Print the postponed error message */
                jmi_kinsol_linesearch_nonconv_error_message(block);
            }
        }
        jmi_kinsol_solver_print_solve_end(block, &topnode, flag);
        
        if(flag != KIN_SUCCESS) {
            /* If Kinsol failed, force a new Jacobian and new rescaling in the next try. */
            solver->force_new_J_flag = 1;
            
            if (flagNonscaled == 0) {
                jmi_log_node(log, logError, "Error", "The equations with initial scaling solved fine, "
                             "re-scaled equations failed in <block: %s>", block->label); 
            } else {
                jmi_log_node(log, logError, "Error", "Could not converge after re-scaling equations in <block: %s>",
                             block->label);
            }
#ifdef JMI_KINSOL_PRINT_ON_FAIL
            {
                realtype* x = block->x;
                int i;
                struct KINMemRec * kin_mem = solver->kin_mem;
                
                printf("Could not converge in block %s,KINSOL error:%s,fnorm=%g,stol=%g,ftol=%g:\n"
                       "x = N.array([\n",block->label, jmi_kinsol_flag_to_name(flag), fnorm, solver->kin_stol,solver->kin_ftol);
                for (i=0;i<block->n;i++) {
                    printf("%.16e\n",x[i]);
                }
                printf("]);\n");
                printf("x_scale = N.array([\n");
                for (i=0;i<block->n;i++) {
                    printf("%.16e\n",Ith(solver->kin_y_scale,i));
                }
                printf("]);\n");
                printf("f = N.array([\n");
                for (i=0;i<block->n;i++) {
                    printf("%.16e\n",Ith(kin_mem->kin_fval,i));
                }
                printf("]);\n");
                N_VScale( 1+2*UNIT_ROUNDOFF,solver->kin_y,solver->kin_y);
                kin_f(solver->kin_y,kin_mem->kin_fval,block);
                printf("f_inc = N.array([\n");
                for (i=0;i<block->n;i++) {
                    printf("%.16e\n",Ith(kin_mem->kin_fval,i));
                }
                printf("]);\n");
                N_VScale( 1-4*UNIT_ROUNDOFF,solver->kin_y,solver->kin_y);
                kin_f(solver->kin_y,kin_mem->kin_fval,block);
                printf("f_dec = N.array([\n");
                for (i=0;i<block->n;i++) {
                    printf("%.16e\n",Ith(kin_mem->kin_fval,i));
                }
                printf("]);\n");

                printf("f_scale = N.array([\n");
                for (i=0;i<block->n;i++) {
                    printf("%.16e\n",Ith(solver->kin_f_scale,i));
                }
                printf("]);\n");
            }
#endif
        }
    }

    /* Write solution back to model just to make sure. In some cases x was not the last evaluations*/    
    block->F(block->problem_data,block->x, NULL, JMI_BLOCK_WRITE_BACK);
    
    /* Get debug information */
    KINGetNumNonlinSolvIters(solver->kin_mem, &nniters);    
     
    /* Store debug information */
    block->nb_iters += nniters;
        
    return flag;
}



