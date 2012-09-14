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

#include <sundials/sundials_math.h>
#include <kinsol/kinsol_direct.h>

/* #include <kinsol_jmod_impl.h> */
#include <kinpinv.h>

#include "jmi.h"
#include "fmi.h"
#include "jmi_kinsol_solver.h"
#include "jmi_block_residual.h"
#include "jmi_util.h"

#include <kinsol/kinsol_impl.h>


/* RCONST from SUNDIALS and defines a compatible type, usually double precision */

/* Default Kinsol tolerance (machine precision pwr 1/3)  -> 1e-6 */
/* We use tighter:  1e-12 */
#define JMI_DEFAULT_KINSOL_TOL 1e-12

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
    if(ret) {
        jmi_log(block->jmi, logWarning, "Error code returned from equation block function");
        return ret;
    }

	/* Test if output is OK (no -1.#IND) */
	n = NV_LENGTH_S(ff);
	for (i=0;i<n;i++) {
          double v = Ith(ff,i);
	  /* Recoverable error*/
          if (v- v != 0) {
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

static int kin_lsolve(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *res_norm);
int kin_dF(int N, N_Vector u, N_Vector fu, DlsMat J, void *user_data, N_Vector tmp1, N_Vector tmp2);

static int jmi_kinsol_init(jmi_block_residual_t * block) {
    jmi_kinsol_solver_t* solver = block->solver;
    jmi_t * jmi = block->jmi;
    int i;
    int ef;
    struct KINMemRec * kin_mem = solver->kin_mem; 
    /* set tolerances */
    solver->kin_ftol = jmi->fmi->fmi_newton_tolerance;
    solver->kin_stol = solver->kin_ftol * solver->kin_ftol;

    KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
    KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);
    /* 
        Set variable scaling based on nominal values.          
    */
    for(i=0;i< block->n;++i){
        double nominal = RAbs(block->nominal[i]);
        if(nominal != 1.0) {
            if(nominal == 0.0)
                nominal = 1/solver->kin_ftol;
            else
                nominal = 1/nominal;
            Ith(solver->kin_y_scale,i)=nominal;
        }
    }
    /* calculate the number of contrains */
    {
        int num_bounds = 0;
    
        for(i=0; i < block->n; ++i) {
            if(block->max[i] != BIG_REAL) num_bounds++;
            if(block->min[i] != -BIG_REAL) num_bounds++;
        }

        solver->num_bounds = num_bounds;
        solver->bound_vindex = (int*)calloc(num_bounds, sizeof(int));
        solver->bound_kind  = (int*)calloc(num_bounds, sizeof(int));
        solver->bounds = (realtype*)calloc(num_bounds, sizeof(realtype));
        solver->active_bounds = (realtype*)calloc(block->n, sizeof(realtype));
        num_bounds = 0;
        for(i=0; i < block->n; ++i) {
            if(block->max[i] != BIG_REAL) {
                solver->bound_vindex[num_bounds] = i;
                solver->bound_kind[num_bounds] = 1;
                solver->bounds[num_bounds] = block->max[i];
                num_bounds++;
            }
            if(block->min[i] != -BIG_REAL) {
                solver->bound_vindex[num_bounds] = i;
                solver->bound_kind[num_bounds] = -1;
                solver->bounds[num_bounds] = block->min[i];
                num_bounds++;
            }
        }
        if(num_bounds > 0) {                
            solver->kin_lsolve = (int (*)(void *, N_Vector, N_Vector,realtype *))kin_mem->kin_lsolve;
            kin_mem->kin_lsolve = kin_lsolve;
        }
    }
   
    /* evaluate the function at initial */
    ef =  kin_f(solver->kin_y, kin_mem->kin_fval, block);
    ef |= kin_dF(block->n, solver->kin_y, kin_mem->kin_fval, solver->J, block, kin_mem->kin_vtemp1, kin_mem->kin_vtemp1);    
    if(ef) {
        jmi_log(jmi, logError, "Residual evaluation function or jacobian failed at initial codition");
    }
    return ef;
}

static void jmi_kinsol_limit_step(struct KINMemRec * kin_mem, N_Vector x) {
    jmi_block_residual_t *block = kin_mem->kin_user_data;
    jmi_kinsol_solver_t* solver = block->solver;
    realtype xnorm;
    realtype minstepmul;
    realtype stepmul;
    realtype* xd = N_VGetArrayPointer(x);
    booleantype activeBounds = FALSE;
    int i;

    /* handle bounds */
    if(solver->num_bounds == 0) return;
    
    xnorm = N_VWL2Norm(x, kin_mem->kin_uscale);
    
    /* minimal/maximal allowed step multiplier */
    stepmul = (block->n)/(xnorm+kin_mem->kin_scsteptol);
    minstepmul= stepmul * kin_mem->kin_scsteptol;   
    
/*   if(stepmul > 1.0 ) */ 
        stepmul = 1.0; 
        
    for(i = 0; i < solver->num_bounds; ++i) {
        int index = solver->bound_vindex[i]; /* variable index */
        int kind = solver->bound_kind[i];   /* min or max */
        realtype ui =  NV_Ith_S(kin_mem->kin_uu,index);  /* current variable value */
        realtype pi = xd[index];            /* solved step length for the variable*/
        realtype up = ui + pi;    /*  next step */
        realtype bound = solver->bounds[i]; 
        realtype stepmuli;
        if(kind * (bound - up) >= 0) 
            continue; /* will not cross the bound */
        stepmuli = (bound - ui)/pi;             /* distance to the bound */
        if(stepmuli < minstepmul) {
            activeBounds = TRUE;  /* this bound is active (follow it) */
            xd[index] = 0;
            solver->active_bounds[index] = (kind == 1)? (bound - ui):(ui - bound) ; /* distance to the bound */
        }
        else
            stepmul = MIN(stepmul, stepmuli);          /* reduce the step */
    }
    
    if(stepmul != 1.0) {
        realtype xbnorm;
        stepmul -= minstepmul/2;
        N_VScale(stepmul, x, x);
        if(activeBounds) {
            for(i = 0; i < block->n; ++i) {
                realtype bnd = solver->active_bounds[i];
                if(bnd != 0) {
                    xd[i] = bnd;
                    solver->active_bounds[i] = 0;
                }
            }
            xbnorm = N_VWL2Norm(x, kin_mem->kin_uscale);
            stepmul = xbnorm/xnorm;
        }
        else
            xbnorm = stepmul * xnorm;
        kin_mem->kin_sfdotJp *= stepmul;
        kin_mem->kin_sJpnorm *= stepmul;        
        xnorm = xbnorm;          
    }
    else if(activeBounds) {
        realtype xbnorm;
        for(i = 0; i < block->n; ++i) {
            realtype bnd = solver->active_bounds[i];
            if(bnd != 0) {
                xd[i] = bnd;
                solver->active_bounds[i] = 0;
            }
        }
        xbnorm = N_VWL2Norm(x, kin_mem->kin_uscale);          
        stepmul = xbnorm/xnorm;
        kin_mem->kin_sfdotJp *= stepmul;
        kin_mem->kin_sJpnorm *= stepmul;
        xnorm = xbnorm;
    }
    
    kin_mem->kin_mxnewtstep = xnorm;
    kin_mem->kin_ncscmx = 0;   
}

static int kin_lsolve(struct KINMemRec * kin_mem, N_Vector x, N_Vector b, realtype *res_norm) {
    jmi_block_residual_t *block = kin_mem->kin_user_data;
    jmi_kinsol_solver_t* solver = block->solver;
    int ret = solver->kin_lsolve(kin_mem, x, b, res_norm);    
    jmi_kinsol_limit_step(kin_mem, x);
   
    return ret;
        
}

void dgecon_(char *norm, int *n, double *a, int *lda, double *anorm, double *rcond, 
             double *work, int *iwork, int *info);
void dgetrf_(  int *  m, int * n, double * a, int *lda,	int * ipiv, int * info);

/* 
    Compute appropriate equation scaling and function tolerance based on Jacobian J,
    nominal values (block->nominal) and current point (block->x).
    Store result in solver->kin_f_scale.
*/
static int jmi_update_f_scale(jmi_block_residual_t *block, DlsMat J) {
    jmi_kinsol_solver_t* solver = block->solver; 
    jmi_t* jmi = block->jmi;
    int i, N = block->n;
    realtype tol = jmi->fmi->fmi_newton_tolerance;
    realtype curtime = *(jmi_get_t(block->jmi));
    realtype* scale_ptr = N_VGetArrayPointer(solver->kin_f_scale);
    realtype* col_ptr;
    int ef = 0;
    solver->kin_scale_update_time = curtime;  
    if(solver->kin_jac_update_time != curtime) {
        /* need a fresh jac for proper update */
        return;
    }
    
    /* Scale equations by Jacobian rows. */
    N_VConst_Serial(0,solver->kin_f_scale);
    for(i = 0; i < N; i++){
        int j;
        realtype xscale = RAbs(block->nominal[i]);
        realtype x = RAbs(block->x[i]);
        if(x < xscale) x = xscale;
        if(x < tol) x = tol;
        col_ptr = DENSE_COL(J, i);

        for(j = 0; j < N; j++){
            realtype dres = col_ptr[j];
            realtype fscale;
            fscale = dres * x;
            col_ptr[j] = fscale;
            scale_ptr[j] = MAX(scale_ptr[j], RAbs(fscale));
		}
	}
    for(i = 0; i < N; i++) {
        if(scale_ptr[i] < tol)
            scale_ptr[i] = 1.0; /* Singular Jacobian? */
        else
            scale_ptr[i] = 1/scale_ptr[i];
    }
    for(i = 0; i < N; i++){
        int j;
        col_ptr = DENSE_COL(J, i);
        for(j = 0; j < N; j++){
            col_ptr[j] *= scale_ptr[j];
		}
	}
    /* estimate condition number of the scaled jacobian 
        and scale function tolerance with it. */
    {
        char norm = 'I';
        double Jnorm = 1.0, Jcond = 1.0;
        int info;
        dgetrf_(  &N, &N, solver->J->data, &N,	solver->lapack_iwork, &info);
        if(info > 0) {
            jmi_log(jmi, logWarning, "A singular Jacobian detected. Solution may be inaccurate.");
            ef = 1;
        }
        else {
            dgecon_(&norm, &N, solver->J->data, &N, &Jnorm, &Jcond, solver->lapack_work, solver->lapack_iwork,&info);
        }
        tol *= Jcond;
        if(tol < JMI_DEFAULT_KINSOL_TOL) {
            if(block->init)
                jmi_log(jmi, logWarning, "Requested tolerance is below machine precision. Raugher tolerance will be used.");
            tol = JMI_DEFAULT_KINSOL_TOL;
        }
    }
    solver->kin_ftol = tol;
    solver->kin_stol = tol * tol;
    KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol);
    KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
    
    return ef;
}

/* Use internal function for finite difference to avoid reimplementation */
int kinPinvDQJac(int N,	 N_Vector u, N_Vector fu, DlsMat Jac, void *data, N_Vector tmp1, N_Vector tmp2);

int kin_dF(int N, N_Vector u, N_Vector fu, DlsMat J, void *user_data, N_Vector tmp1, N_Vector tmp2){
	jmi_block_residual_t *block = user_data;
    jmi_kinsol_solver_t* solver = block->solver;        
	int i;
	int j;
    int ret = 0;
    realtype curtime = *(jmi_get_t(block->jmi));
    solver->kin_jac_update_time = curtime;
    
    if(!block->dF) {
        /* Use standard KINSOL finite differences */
        ret = kinPinvDQJac(N, u, fu, J, solver->kin_mem, tmp1, tmp2);
        DenseCopy(J, solver->J);
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
    DenseCopy(J, solver->J);
    
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
    int verbosity = 1;
    
    if(!solver ) return -1;
    
    /*Initialize work vectors.*/

    /*Sets the scaling vectors to ones.*/
    /*To be changed. */
    solver->kin_y = N_VMake_Serial(n, block->x);
	solver->kin_y_scale = N_VNew_Serial(n);
	solver->kin_f_scale = N_VNew_Serial(n);
    solver->J = NewDenseMat(n ,n);
    solver->lapack_work = (realtype*)calloc(4*n,sizeof(realtype));
    solver->lapack_iwork = (int *)calloc(n, sizeof(int));
    
    solver->kin_scale_update_time = -1.0;
    solver->kin_lsolve = NULL;
    
    /*NOTE: it'd be nice to use "jmi->fmi->fmi_newton_tolerance" here
      However, fmi pointer is not set yet at this point.
    */
	solver->kin_ftol = JMI_DEFAULT_KINSOL_TOL;
	solver->kin_stol = JMI_DEFAULT_KINSOL_TOL * JMI_DEFAULT_KINSOL_TOL;

    /* Initialize scaling to 1.0 - defaults */
    N_VConst_Serial(1.0,solver->kin_y_scale);

    /* Initial equation scaling is 1.0 */
    N_VConst_Serial(1.0,solver->kin_f_scale);
                
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
    
    KINDlsSetDenseJacFn(solver->kin_mem, kin_dF);
    
    /*Stopping tolerance of F -> just a default */
    KINSetFuncNormTol(solver->kin_mem, solver->kin_ftol); 
    
    /*Stepsize tolerance*/
    KINSetScaledStepTol(solver->kin_mem, solver->kin_stol);
    
    /* Allow long steps */
    KINSetMaxNewtonStep(solver->kin_mem, n*10);
    
    /* Disable residual monitoring (since inexact solution is given sometimes by 
    the linear solver) */
    KINSetNoResMon(solver->kin_mem,1);

    /*Verbosity*/
    KINSetPrintLevel(solver->kin_mem, verbosity);
    
    /*Error function*/
    KINSetErrHandlerFn(solver->kin_mem, kin_err, block);
    /*Info function*/
    KINSetInfoHandlerFn(solver->kin_mem, kin_info, block);
    /*  Jacobian can be reused */
    KINSetNoInitSetup(solver->kin_mem, 1);
    
      
    *solver_ptr = solver;
    return flag;
}

int jmi_kinsol_solver_solve(jmi_block_residual_t * block){
    int flag;
    jmi_kinsol_solver_t* solver = block->solver;
    realtype curtime = *(jmi_get_t(block->jmi));
    long int nniters = 0, njevals = 0, njevalscur=0;
    
    if(block->init) {
        jmi_kinsol_init(block);
    }
    
    /* update the scaling only once per time step */
    if(block->init || (curtime != solver->kin_scale_update_time)) {
        jmi_update_f_scale(block, solver->J);
    }
    
    KINPinvGetNumJacEvals(solver->kin_mem, &njevalscur);
  
    flag = KINSol(solver->kin_mem, solver->kin_y, KIN_LINESEARCH, solver->kin_y_scale, solver->kin_f_scale);
    
    KINPinvGetNumJacEvals(solver->kin_mem, &njevals);
    if(njevals > njevalscur) { 
 
        if(block->init) {
            /* This is the first call: make sure scaling was appropriate*/
            int flagNonscaled = flag;
            /* Get & store debug information */
            KINGetNumNonlinSolvIters(solver->kin_mem, &block->nb_iters);
            block->nb_jevals = njevals ;
            /* Update the scaling  */
            jmi_update_f_scale(block, solver->J);
            
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
 
    /* Get debug information */
    KINGetNumNonlinSolvIters(solver->kin_mem, &nniters);    
    KINPinvGetNumJacEvals(solver->kin_mem, &njevals);
     
    /* Store debug information */
    block->nb_iters += nniters;
    block->nb_jevals += njevals ;
    
    
    if(flag >= 0) return 0;
    return flag;
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
    DestroyMat(solver->J);
    free(solver->lapack_work);
    free(solver->lapack_iwork);    
    
    if(solver->num_bounds > 0) {
        free(solver->bound_vindex);
        free(solver->bound_kind);
        free(solver->bounds);
        free(solver->active_bounds);
    }
    
	/*Deallocate Kinsol */
    KINFree(&(solver->kin_mem));
	/*Deallocate struct */
	free(solver);
    block->solver = 0;
}
