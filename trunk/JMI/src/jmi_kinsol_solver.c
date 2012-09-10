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

/* #define SET_TIGHT_TOLERANCE */

#include <sundials/sundials_math.h>
/* #include <kinsol/kinsol_impl.h> */
#include <kinsol/kinsol_direct.h>

/* #include <kinsol_jmod_impl.h> */
#include <kinpinv.h>

#include "jmi.h"
#include "fmi.h"
#include "jmi_kinsol_solver.h"
#include "jmi_block_residual.h"
#include "jmi_util.h"

/* RCONST from SUNDIALS and defines a compatible type, usually double precision */

/* Default Kinsol tolerance (machine precision) */
/* #define JMI_DEFAULT_KINSOL_TOL (RPowerR(UNIT_ROUNDOFF,1.0/3.0)) */
#define JMI_DEFAULT_KINSOL_TOL UNIT_ROUNDOFF

#define ONE RCONST(1.0)
#define Ith(v,i)    NV_Ith_S(v,i)

/*Kinsol function wrapper*/
int kin_f(N_Vector yy, N_Vector ff, void *problem_data){
	
	realtype *y, *f;
	jmi_block_residual_t *block = problem_data;
	int i,n, ret;

	y = NV_DATA_S(yy); /*y is now a vector of realtype*/
	f = NV_DATA_S(ff); /*f is now a vector of realtype*/


	/* Test if input is OK (no -1.#IND) */
	n = NV_LENGTH_S(yy);
	for (i=0;i<n;i++) {
	  /* Unrecoverable error*/
          if (Ith(yy,i)- Ith(yy,i) != 0) {
              jmi_log(block->jmi, logWarning, "Not a number in arguments to model function in DAE");
              return -1;
          }
	}

	/*Evaluate the residual*/
	ret = block->F(block->jmi,y,f,JMI_BLOCK_EVALUATE);
    if(ret) return ret;

	/* Test if output is OK (no -1.#IND) */
	n = NV_LENGTH_S(ff);
	for (i=0;i<n;i++) {
	  /* Recoverable error*/
          if (Ith(ff,i)- Ith(ff,i) != 0) {
           jmi_log(block->jmi, logWarning, "Not a number in output from model function in DAE");
           return 1;
          }
	}
	return KIN_SUCCESS; /*Success*/
	/*return 1;  //Recoverable error*/
	/*return -1; //Unrecoverable error*/
}

void kin_err(int err_code, const char *module, const char *function, char *msg, void *eh_data){
        /*int i,j;*/
	    jmi_log_category_t category;
        char buffer[4000];
        jmi_block_residual_t *block = eh_data;
        jmi_t *jmi = block->jmi;
        jmi_kinsol_solver_t* solver = block->solver;
#ifdef SET_TIGHT_TOLERANCE        
        if(solver->kin_ftol < jmi->fmi->fmi_newton_tolerance) {
            /* don't care in this case - solver will be rerun */
            return;
        }
#endif	
        if (err_code > 0){ /*Warning*/
            category = logWarning;
        }else if (err_code < 0){ /*Error*/
            category = logError;
        }

        sprintf(buffer, "[KINSOL] Error occured in %s at time %3.2fs when solving block %d: ", function, *(jmi_get_t(jmi)), block->index);
        jmi_log(block->jmi, category, buffer);
        jmi_log(block->jmi, category, msg);
        {
            realtype fnorm, snorm;
            KINGetFuncNorm(solver->kin_mem, &fnorm);
            KINGetStepLength(solver->kin_mem, &snorm);
            sprintf(buffer, "Current function norm: %g, scaled step length: %g", fnorm, snorm);
            jmi_log(block->jmi, category, buffer);
        }
/*      jmi_simple_newton_jac(block);

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
*/
}

void kin_info(const char *module, const char *function, char *msg, void *eh_data){
        char buffer[400];
        jmi_block_residual_t *block = eh_data;
        sprintf(buffer, "[KINSOL] %s", msg);
        jmi_log(block->jmi, logInfo, buffer);
}

void jmi_kinsol_error_handling(jmi_t* jmi, int flag){
 	if (flag < 0){
       	char buffer[400];
        sprintf(buffer,"KINSOL returned with error flag: %s", KINGetReturnFlagName(flag));
        jmi_log(jmi, logError, buffer);
    }
}

static void jmi_update_f_scale(jmi_block_residual_t *block, DlsMat J) {
    jmi_kinsol_solver_t* solver = block->solver;        
    size_t i, N = block->n;
    realtype tol = block->jmi->fmi->fmi_newton_tolerance;
   /* realtype tol_sq = tol*tol; */
    
    realtype curtime = *(jmi_get_t(block->jmi));
    
    /* update only one per time step */
    if(curtime == solver->kin_scale_update_time) 
        return;
    
    solver->kin_scale_update_time = curtime;  
    
    N_VConst_Serial(0,solver->kin_f_new_scale);
    for(i = 0; i < N; i++){
        int j;
        realtype xscale = RAbs(block->nominal[i]);
        realtype x = RAbs(block->x[i]);
        if(x < xscale) x = xscale;
        if(x < solver->kin_stol) x = solver->kin_stol;

        for(j = 0; j < N; j++){
            realtype dres = RAbs((J->data)[i*N+j]);
            realtype fscale;
            fscale = dres * x;
            Ith(solver->kin_f_new_scale,j) = MAX(Ith(solver->kin_f_new_scale,j), fscale);
		}
	}
    for(i = 0; i < N; i++) {
        if(Ith(solver->kin_f_new_scale,i) < tol)
            Ith(solver->kin_f_new_scale,i) = 1/tol;
        else
            Ith(solver->kin_f_new_scale,i) = 1/Ith(solver->kin_f_new_scale,i);
    }
}

/* Use internal function for finite difference to avoid reimplementation */
int kinPinvDQJac(int N,	 N_Vector u, N_Vector fu, DlsMat Jac, void *data, N_Vector tmp1, N_Vector tmp2);

int kin_dF(int N, N_Vector u, N_Vector fu, DlsMat J, void *user_data, N_Vector tmp1, N_Vector tmp2){
	jmi_block_residual_t *block = user_data;
    jmi_kinsol_solver_t* solver = block->solver;        
	int i;
	int j;
    int ret = 0;
    
    if(!block->dF) {
        /* Use standard KINSOL finite differences */
        ret = kinPinvDQJac(N, u, fu, J, solver->kin_mem, tmp1, tmp2);
        jmi_update_f_scale(block, J);
        return ret;         
    }
    
	for(i = 0; i < N; i++){ 
 	    block->x[i] = Ith(u,i);
	}

	/*printf("x[0]: %f\n Jac: ", block->x[0]);*/
	for(i = 0; i < N; i++){
		block->dx[i] = 1;
		ret |= block->dF(block->jmi,block->x,block->dx,block->res,block->dres,JMI_BLOCK_EVALUATE);
		for(j = 0; j < N; j++){
            realtype dres = block->dres[j];
			(J->data)[i*N+j] = dres;
			/*printf(" %f, ", block->dres[j]);*/
		}
		J->cols[i] = &(J->data)[i*N];
	    block->dx[i] = 0;
	}
    jmi_update_f_scale(block, J);
 
    /*
	printf("Q=N.array([");
	for(i = 0; i < N; i++){
		printf("[");
		for(j = 0; j < N; j++){
			printf("%12.12e",(J->data)[i+j*N]);
			if (j<N-1) {
				printf(", ");
			}
		}
		printf("]");
		if (i<N-1) {
			printf(",\n");
		}
	}
	printf("])\n");
	printf("print N.linalg.cond(Q)\n");
*/
	/*printf("\n");*/
	return ret;
}


int jmi_kinsol_solver_new(jmi_kinsol_solver_t** solver_ptr, jmi_block_residual_t* block) {
    jmi_kinsol_solver_t* solver= (jmi_kinsol_solver_t*)calloc(1,sizeof(jmi_kinsol_solver_t));
    jmi_t* jmi = block->jmi;
    int flag, n = block->n;
    int verbosity = 0;
    
    if(!solver ) return -1;
    
    /*Initialize work vectors.*/

    /*Sets the scaling vectors to ones.*/
    /*To be changed. */
    solver->kin_y = N_VMake_Serial(n, block->x);
	solver->kin_y_scale = N_VNew_Serial(n);
	solver->kin_f_scale = N_VNew_Serial(n);
    solver->kin_f_new_scale  = N_VNew_Serial(n);
    solver->kin_scale_update_time = -1.0;
    solver->kin_ftol_update_time = -1.0;
    
    /*NOTE: it'd be nice to use "jmi->fmi->fmi_newton_tolerance" here
      However, fmi pointer is not set yet at this point.
    */
	solver->kin_ftol = JMI_DEFAULT_KINSOL_TOL;
	solver->kin_stol = JMI_DEFAULT_KINSOL_TOL;

    /* Initialize scaling to 1.0 - defaults */
    N_VConst_Serial(1.0,solver->kin_y_scale);

    /* Initial equation scaling is 1.0 */
    N_VConst_Serial(1.0,solver->kin_f_scale);
    N_VConst_Serial(1.0,solver->kin_f_new_scale);
                
    solver->kin_mem = KINCreate();
    flag = KINInit(solver->kin_mem, kin_f, solver->kin_y); /*Initialize Kinsol*/
    jmi_kinsol_error_handling(jmi, flag);
    
    /*Attach linear solver*/
    /*Dense Kinsol solver*/
    /*flag = KINDense(solver->kin_mem, block->n);
      jmi_kinsol_error_handling(flag);*/
     
     
    /*Dense Kinsol using regularization*/
    flag = KINPinv(solver->kin_mem, block->n);
    jmi_kinsol_error_handling(jmi, flag);
    /*End linear solver*/
    
    /*Set problem data to Kinsol*/
    flag = KINSetUserData(solver->kin_mem, block);
    jmi_kinsol_error_handling(jmi, flag);
    
    flag = KINDlsSetDenseJacFn(solver->kin_mem, kin_dF);
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }
    
    /*Stopping tolerance of F -> just the default */
    flag = KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol); 
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }
    
    /*Stepsize tolerance*/
    flag = KINSetScaledStepTol(solver->kin_mem, 1e-3 * solver->kin_stol); 
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }
    
    /* Allow long steps */
    flag = KINSetMaxNewtonStep(solver->kin_mem, 1e30);
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }
    
    /* Disable residual monitoring (since inexact solution is given sometimes by 
    the linear solver) */
    flag = KINSetNoResMon(solver->kin_mem,1);
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }

    /*Verbosity*/
    flag = KINSetPrintLevel(solver->kin_mem, verbosity);
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }
    
    /*Error function*/
    flag = KINSetErrHandlerFn(solver->kin_mem, kin_err, block);
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }
    
    /*Info function*/
    flag = KINSetInfoHandlerFn(solver->kin_mem, kin_info, block);
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }
      
    *solver_ptr = solver;
    return flag;
}

int jmi_kinsol_solver_solve(jmi_block_residual_t * block){
    int flag;
    int i;
    jmi_kinsol_solver_t* solver = block->solver;
    jmi_t * jmi = block->jmi;
    
    long int nniters = 0, njevals = 0, njevalscur=0;
    
    if(block->init) {
        /* set tolerances */
#ifdef SET_TIGHT_TOLERANCE
        solver->kin_stol = 1e-20;
        solver->kin_ftol = 1e-20;
#else        
        solver->kin_stol = jmi->fmi->fmi_newton_tolerance;
        solver->kin_ftol = jmi->fmi->fmi_newton_tolerance;
#endif        

        KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
        KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);
        /* 
            Set variable scaling based on nominal values.          
        */
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
    else if(solver->kin_ftol_update_time != solver->kin_scale_update_time) {
        /* Equation scaling was updated last time. */
        realtype curtime = *(jmi_get_t(block->jmi));
    
        /* update only once per time step */
        if(curtime != solver->kin_ftol_update_time) {
            solver->kin_ftol_update_time = solver->kin_scale_update_time;
            N_VScale_Serial(ONE, solver->kin_f_new_scale, solver->kin_f_scale);
        }
    }
    
    flag = KINPinvGetNumJacEvals(solver->kin_mem, &njevalscur);
    if (flag<0) {
        jmi_kinsol_error_handling(jmi, flag);
        return flag;
    }
  
    flag = KINSol(solver->kin_mem, solver->kin_y, KIN_LINESEARCH, solver->kin_y_scale, solver->kin_f_scale);
    
    KINPinvGetNumJacEvals(solver->kin_mem, &njevals);
    if(njevals > njevalscur) {
        /*  Jacobian can be reused */
        KINSetNoInitSetup(solver->kin_mem, 1);
 
        if(block->init) {
            int flagNonscaled = flag;
            /* If this is the first call then solve again to make sure 
            the scaled solution is fine.  */
            solver->kin_ftol_update_time = solver->kin_scale_update_time;
            N_VScale_Serial(ONE, solver->kin_f_new_scale, solver->kin_f_scale);
            
            /* Get & store debug information */
            KINGetNumNonlinSolvIters(solver->kin_mem, &block->nb_iters);
            block->nb_jevals = njevals ;

            flag = KINSol(solver->kin_mem, solver->kin_y, KIN_LINESEARCH, solver->kin_y_scale, solver->kin_f_scale);
            if(flag == KIN_INITIAL_GUESS_OK) flag = KIN_SUCCESS;
            if(flag < 0) {
                if(flagNonscaled == 0)
                    jmi_log(block->jmi, logError, "The non-scaled problem solved fine, scaled problem failed");
                else
                    jmi_log(block->jmi, logError, "Both non-scaled and scaled problem failed");
            }
            else if(flagNonscaled < 0) {
                jmi_log(block->jmi, logWarning, "The non-scaled problem failed, scaled solved fine");
            }
        }
    }
 
#ifdef SET_TIGHT_TOLERANCE
    if(flag == 0) {
        /* prevent solution drift off by requiring function norm
          to be about constant between the calls.
        */
        realtype norm;
        KINGetFuncNorm(solver->kin_mem, &norm);           
        solver->kin_ftol = norm * (1.0 + UNIT_ROUNDOFF);
        KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);        
    }
    else if (flag<0) {
         realtype ftol = jmi->fmi->fmi_newton_tolerance;
         /* check that the solution was done with specified tolerance and not a finer one */
         if(solver->kin_ftol < ftol) {
             realtype norm;
             KINGetFuncNorm(solver->kin_mem, &norm);           
             /* Check if the solution was OK */
             if(norm <= ftol ) {
             /* the tolerance was too tight, reset it*/
 	                solver->kin_ftol = norm * (1.0 + UNIT_ROUNDOFF);
 	                KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);
 	                flag = 0;
             }
             else {
                 /* try again. mostly to print error */
                 solver->kin_ftol = ftol;
                 KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol); 
                 flag = KINSol(solver->kin_mem, solver->kin_y, KIN_LINESEARCH, solver->kin_y_scale, solver->kin_f_scale);               
             }           
         }
     }
#endif  
    /* Get debug information */
    KINGetNumNonlinSolvIters(solver->kin_mem, &nniters);    
    KINPinvGetNumJacEvals(solver->kin_mem, &njevals);
     
    /* Store debug information */
    block->nb_iters += nniters;
    block->nb_jevals += njevals ;
    
    return 0;
}

int jmi_kinsol_solver_evaluate_jacobian(jmi_block_residual_t* block, jmi_real_t* jacobian) {
    int i,j;
    int n_x;
    int ef;
    n_x = block->n;

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

int jmi_kinsol_solver_evaluate_jacobian_factorization(jmi_block_residual_t* block, jmi_real_t* factorization) {
    int i,j;
    int n_x;
    int ef;
    n_x = block->n;
/*
	for(i = 0; i < n_x; i++){
		block->dx[i] = 1;
		ef |= block->dF(block->jmi,block->x,block->dx,block->res,block->dres,JMI_BLOCK_EVALUATE);
		for(j = 0; j < n_x; j++){
			jacobian[i*n_x+j] = block->dres[j];
		}
		block->dx[i] = 0;
	}
*/
    return 0;
}

void jmi_kinsol_solver_delete(jmi_block_residual_t* block) {
    jmi_kinsol_solver_t* solver = block->solver;
    /*Deallocate Kinsol work vectors.*/
	N_VDestroy_Serial(solver->kin_y);
	N_VDestroy_Serial(solver->kin_y_scale);
	N_VDestroy_Serial(solver->kin_f_scale);
    N_VDestroy_Serial(solver->kin_f_new_scale);
	/*Deallocate Kinsol */
    KINFree(&(solver->kin_mem));
	/*Deallocate struct */
	free(solver);
    block->solver = 0;
}
