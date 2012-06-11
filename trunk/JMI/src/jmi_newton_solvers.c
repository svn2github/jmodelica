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


#include "jmi_newton_solvers.h"
#include "jmi_util.h"
#include "kinsol_jmod_impl.h"
#include <kinsol/kinsol_impl.h>
#include <time.h>

#define JMI_SIMPLE_NEWTON_TOL 1e-8
#define JMI_SIMPLE_NEWTON_MAX_ITER 100
#define JMI_SIMPLE_NEWTON_FD_TOL 1e-4
#define ONE RCONST(1.0)
#define Ith(v,i)    NV_Ith_S(v,i)


/*Kinsol function wrapper*/
int kin_f(N_Vector yy, N_Vector ff, void *problem_data){
	
	realtype *y, *f;
	jmi_block_residual_t *block = problem_data;
	int i,n;

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
	block->F(block->jmi,y,f,JMI_BLOCK_EVALUATE);

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
        jmi_log_category_t category;
        char buffer[4000];
        jmi_block_residual_t *block = eh_data;
        jmi_t *jmi = block->jmi;
        if (err_code > 0){ /*Warning*/
            category = logWarning;
        }else if (err_code < 0){ /*Error*/
            category = logError;
        }
        sprintf(buffer, "[KINSOL] %s: Error occured at time %3.2fs when solving block %d: %s", function, *(jmi_get_t(jmi)), block->index, msg);
        jmi_log(block->jmi, category, buffer);
}

void kin_info(const char *module, const char *function, char *msg, void *eh_data){
        char buffer[400];
        jmi_block_residual_t *block = eh_data;
        sprintf(buffer, "[KINSOL] %s", msg);
        jmi_log(block->jmi, logInfo, buffer);
}

void jmi_kinsol_error_handling(jmi_t* jmi, int flag){
        /* TODO: The error flags decoded below are for the KINsol function, but
         * jmi_kinsol_error_handling is called also for other functions. This
         * needs to be fixed. */
		if (flag < 0){
        	char buffer[400];
            switch (flag) {
            case -1:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_MEM_NULL");
            	break;
            case -2:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_ILL_INPUT");
            	break;
            case -3:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_NO_MALLOC");
            	break;
            case -4:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_MEM_FAIL");
            	break;
            case -5:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_LINESEARCH_NONCONV");
            	break;
            case -6:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_MAXITER_REACHED");
            	break;
            case -7:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_MXNEWT_5X_EXCEEDED");
            	break;
            case -8:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_LINESEARCH_BCFAIL");
            	break;
            case -9:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_LINSOLV_NO_RECOVERY");
            	break;
            case -10:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_LINIT_FAIL");
            	break;
            case -11:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_LSETUP_FAIL");
            	break;
            case -13:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_SYSFUNC_FAIL");
            	break;
            case -14:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_FIRST_SYSFUNC_ERR");
            	break;
            case -15:
            	sprintf(buffer,"KINSOL returned with error flag: KIN_REPTD_SYSFUNC_ERR");
            	break;
            default:
            	sprintf(buffer,"KINSOL returned with error flag: %d",flag);
            }
            jmi_log(jmi, logError, buffer);
        }
}

int kin_dF(int N, N_Vector u, N_Vector fu, DlsMat J, void *user_data, N_Vector tmp1, N_Vector tmp2){
	jmi_block_residual_t *block = user_data;
	int i;
	int j;
	for(i = 0; i < N; i++){ 
 	    block->x[i] = Ith(u,i);
	}
	/*printf("x[0]: %f\n Jac: ", block->x[0]);*/
	for(i = 0; i < N; i++){
		block->dx[i] = 1;
		block->dF(block->jmi,block->x,block->dx,block->res,block->dres,JMI_BLOCK_EVALUATE_WITH_STATE);
		for(j = 0; j < N; j++){
			(J->data)[i*N+j] = block->dres[j];
			/*printf(" %f, ", block->dres[j]);*/
		}
		J->cols[i] = &(J->data)[i*N];
		block->dx[i] = 0;
	}
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
	return 0;
}

int jmi_kinsol_solve(jmi_block_residual_t * block){
	int flag;
	int i;
	int verbosity = 0;

	long int nniters = 0, njevals = 0;
	clock_t c0,c1; /*timers*/


	c0 = clock();
	
	if (block->init == 1){
		/*Initialize work vectors.*/

		/*Sets the scaling vectors to ones.*/
		/*To be changed. */
		N_VConst_Serial(ONE,block->kin_y_scale);
		N_VConst_Serial(ONE,block->kin_f_scale);
		
		/* Initialize the work vector */
		block->F(block->jmi,block->x,block->res,JMI_BLOCK_INITIALIZE);
		/*N_VSetArrayPointer(block->x,block->kin_y);*/
		
		for(i=0;i<block->n;i=i+1){
			Ith(block->kin_y,i)=block->x[i];
		}

        block->kin_mem = KINCreate();
		flag = KINInit(block->kin_mem, kin_f, block->kin_y); /*Initialize Kinsol*/
		jmi_kinsol_error_handling(block->jmi, flag);
		
		/*Attach linear solver*/
		/*Dense Kinsol solver*/
		/*flag = KINDense(block->kin_mem, block->n);
		  jmi_kinsol_error_handling(flag);*/
		 
		 
		/*Dense Kinsol using regularization*/
		flag = KINPinv(block->kin_mem, block->n);
		jmi_kinsol_error_handling(block->jmi, flag);
		/*End linear solver*/
		
		/*Set problem data to Kinsol*/
		flag = KINSetUserData(block->kin_mem, block);
		jmi_kinsol_error_handling(block->jmi, flag);
		
        if(block->dF != NULL){
			flag = KINDlsSetDenseJacFn(block->kin_mem, kin_dF);
			if (flag<0) {
				jmi_kinsol_error_handling(block->jmi, flag);
				return flag;
			}
		}
		
		/*Stopping tolerance of F*/
		flag = KINSetFuncNormTol(block->kin_mem, block->kin_ftol); 
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}
		
		/*Stepsize tolerance*/
		flag = KINSetScaledStepTol(block->kin_mem, 0.001*(block->kin_stol)); 
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}
		
		/* Allow long steps */
		flag = KINSetMaxNewtonStep(block->kin_mem, 1e30);
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}
		
		/* Disable residual monitoring */
		flag = KINSetNoResMon(block->kin_mem,1);
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}
  
		/*Verbosity*/
		flag = KINSetPrintLevel(block->kin_mem, verbosity);
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}
		
		/*Error function*/
        flag = KINSetErrHandlerFn(block->kin_mem, kin_err, block);
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}
		
		/*Info function*/
        flag = KINSetInfoHandlerFn(block->kin_mem, kin_info, block);
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}
		
		/*Solve the block*/
		flag = KINSol(block->kin_mem, block->kin_y, KIN_LINESEARCH, block->kin_y_scale, block->kin_f_scale);
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}
		
		block->init = 0; /*The block is initialized*/

	}else{

		for(i=0;i<block->n;i=i+1){
		  Ith(block->kin_y,i)=block->x[i];
		}
	
		if(block->dF != NULL){
			flag = KINDlsSetDenseJacFn(block->kin_mem, kin_dF);
			if (flag<0) {
				jmi_kinsol_error_handling(block->jmi, flag);
				return flag;
			}
		}

		/*
		 * A proper local even iteration should problably be done here.
		 *
		 */

		if (block->jmi->atEvent) {
			block->F(block->jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
		}

		flag = KINSol(block->kin_mem, block->kin_y, KIN_LINESEARCH, block->kin_y_scale, block->kin_f_scale);
		if (flag<0) {
			jmi_kinsol_error_handling(block->jmi, flag);
			return flag;
		}

		if (block->jmi->atEvent) {
			block->F(block->jmi,NULL,NULL,JMI_BLOCK_EVALUATE_NON_REALS);
			flag = KINSol(block->kin_mem, block->kin_y, KIN_LINESEARCH, block->kin_y_scale, block->kin_f_scale);
			if (flag<0) {
				jmi_kinsol_error_handling(block->jmi, flag);
				return flag;
			}
		}


		/* In the case when the initial guess is a solution (flag ==1) 
		   it seems as if the  Jacobian has to be reevaluated */
		if (flag ==1) {
		  flag = KINSetNoInitSetup(block->kin_mem, 0);
			if (flag<0) {
				jmi_kinsol_error_handling(block->jmi, flag);
				return flag;
			}
		} else {
		  flag = KINSetNoInitSetup(block->kin_mem, 1);
			if (flag<0) {
				jmi_kinsol_error_handling(block->jmi, flag);
				return flag;
			}
		}
	}
	c1 = clock();
	
	
	/* Make information available for logger */
	block->time_spent += ((realtype) ((long)(c1-c0))/(CLOCKS_PER_SEC));

	/* Get debug information */
	nniters = 0;
	flag = KINGetNumNonlinSolvIters(block->kin_mem, &nniters);
	if (flag<0) {
		jmi_kinsol_error_handling(block->jmi, flag);
		return flag;
	}

	njevals = 0;
	flag = KINPinvGetNumJacEvals(block->kin_mem, &njevals);
	if (flag<0) {
		jmi_kinsol_error_handling(block->jmi, flag);
		return flag;
	}

	/* Store debug information */
	block->nb_calls++;
	block->nb_iters += nniters;
	block->nb_jevals += njevals ;
	
	return 0;
}

int jmi_ode_unsolved_block_dir_der(jmi_t *jmi, jmi_block_residual_t *current_block){
	int i;
	int j;
	int INFO;
	int n_x;
	int nrhs;
	nrhs = 1;
	INFO = 0;
  	n_x = current_block->n;
  	
	/* We now assume that the block is solved, so first we retrieve the
           solution of the equation system - put it into current_block->x 
	*/
  	current_block->dF(jmi, current_block->x, current_block->dx,current_block->res, current_block->dv, JMI_BLOCK_INITIALIZE);
  	
	/* Evaluate the right hand side of the linear system we would like to solve. This is
           done by evaluating the AD function with a seed vector dv (corresponding to
           inputs and states - which are known) and the entries of dz (corresponding
           to states and derivatives) that have already been solved. The seeding
           vector is set internally in the block function. The output argument is 
           current_block->dv, where the right hand side is stored. */
  	current_block->dF(jmi, current_block->x, current_block->dx,current_block->res, current_block->dv, JMI_BLOCK_EVALUATE_INACTIVE);

        /* Now we evaluate the system matrix of the linear system. */
    for(i = 0; i < n_x; i++){
    	current_block->dx[i] = 1;
    	current_block->dF(current_block->jmi,current_block->x,current_block->dx,current_block->res,current_block->dres,JMI_BLOCK_EVALUATE);
    	for(j = 0; j < n_x; j++){
  			current_block->jac[i*n_x+j] = current_block->dres[j];
    	}
    	current_block->dx[i] = 0;
  	}
  	
        /* Solve linear equation system to get dz_i for the block */
 	dgesv_( &n_x, &nrhs, current_block->jac, &n_x, current_block->ipiv, current_block->dv, &n_x, &INFO );	
        /* Write back results into the global dz vector. */
  	current_block->dF(jmi, current_block->x, current_block->dx, current_block->res, current_block->dv, JMI_BLOCK_WRITE_BACK);
}

int jmi_simple_newton_solve(jmi_block_residual_t *block) {

	int i, j, INCX, nbr_iter;
	double err_norm;

	int N = block->n;
	int NRHS = 1;
	int LDA = block->n;
	int LDB = block->n;
	int INFO = 0;

	/* Initialize the work vector */
	block->F(block->jmi,block->x,block->res,JMI_BLOCK_INITIALIZE);

	/* Evaluate */
	block->F(block->jmi,block->x,block->res,JMI_BLOCK_EVALUATE);

/*	for (i=0;i<block->n;i++) {
		printf(" %f, %f\n",block->x[i],block->res[i]);
	} */

	/* Compute norm */
	INCX = 1;
	err_norm = dnrm2_(&N,block->res,&INCX);

/*	printf ("Initial norm error: %f\n",err_norm); */

	/* Iterate */
	nbr_iter = 0;
	while (err_norm>=JMI_SIMPLE_NEWTON_TOL) {

		if (nbr_iter>JMI_SIMPLE_NEWTON_MAX_ITER) {
			return -1;
		}

		/*
		printf("-- x and res %d --\n",nbr_iter);
		for (i=0;i<block->n;i++) {
			printf(" %f, %f\n",block->x[i],block->res[i]);
		}
		printf("-- x and res --\n");
		 */

		/* Compute jacobian */
		jmi_simple_newton_jac(block);

		block->F(block->jmi,block->x,block->res,JMI_BLOCK_EVALUATE);

		/*
		printf("-- Jacobian at iteration %d --\n",nbr_iter);
		for (i=0;i<N;i++) {
			for (j=0;j<N;j++) {
				printf("%12.12f, ",block->jac[j*N + i]);
			}
			printf("\n");
		}
		printf("-- Jacobian --\n");
		*/

		/* Solve linear system to get the step */
		/* J_{k}*dx_{k} = F_{k} */


		/*
		for (i=0;i<block->n;i++) {
			printf(">> %12.12f, %12.12f\n", block->res[i], block->x[i]);
		}
		*/

		dgesv_( &N, &NRHS, block->jac, &LDA, block->ipiv, block->res,
				&LDB, &INFO );

		/*printf("Info: %d\n",INFO); */

		/*
		for (i=0;i<block->n;i++) {
			printf("** %12.12f, %12.12f\n", block->res[i], block->x[i]);
		}
		*/

		/* Compute new x */
		/* x_{k+1} = x_{k} - dx_{k} */
		for (i=0;i<block->n;i++) {
			block->x[i] = block->x[i] - block->res[i];
		}

		/* Evaluate residual with new x */
		block->F(block->jmi,block->x,block->res,JMI_BLOCK_EVALUATE);

		/* Compute norm of the residual */
		INCX = 1;
		err_norm = dnrm2_(&N,block->res,&INCX);

/*		printf ("Norm error after iteration %d: %12.12f\n",nbr_iter,err_norm); */

		nbr_iter++;

	}

	return 0;

}

int jmi_simple_newton_jac(jmi_block_residual_t *block) {

	int i,j;

	for (i=0;i<block->n;i++) {
		for (j=0;j<block->n;j++) {
			block->jac[i*(block->n) + j] = block->res[j];
/*			printf(" - %12.12f\n",block->jac[i*(block->n) + j]); */
		}
	}

	for (i=0;i<block->n;i++) {
		block->x[i] += JMI_SIMPLE_NEWTON_FD_TOL;
		block->F(block->jmi,block->x,block->res,JMI_BLOCK_EVALUATE);
		for (j=0;j<block->n;j++) {
/*			printf(" * %12.12f\n",block->res[j]); */
			block->jac[i*(block->n) + j] = (block->res[j]-block->jac[i*(block->n) + j])/(JMI_SIMPLE_NEWTON_FD_TOL);
		}
		block->x[i] -= JMI_SIMPLE_NEWTON_FD_TOL;
	}

	return 0;

}
