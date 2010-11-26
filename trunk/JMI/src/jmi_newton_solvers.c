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

#define JMI_SIMPLE_NEWTON_TOL 1e-8
#define JMI_SIMPLE_NEWTON_MAX_ITER 100
#define JMI_SIMPLE_NEWTON_FD_TOL 1e-4
#define JMI_KINSOL_TOL RCONST(1.0e-8)
#define ONE RCONST(1.0)
#define Ith(v,i)    NV_Ith_S(v,i)


/*Kinsol function wrapper*/
int kin_f(N_Vector yy, N_Vector ff, void *problem_data){
	
	int i; /*Iteration variable*/
	realtype *y, *f;
	jmi_block_residual_t *block = problem_data;

	y = NV_DATA_S(yy); /*y is now a vector of realtype*/
	f = NV_DATA_S(ff); /*f is now a vector of realtype*/

	for(i=0; i<block->n;i=i+1){ /*Update the variables in the block*/
		block->x[i]=y[i];
	}

	block->F(block->jmi,block->x,block->res,JMI_BLOCK_EVALUATE); /*Evaluate the residual*/
	
	for(i=0; i<block->n;i=i+1){ /*Set the result to ff*/
		f[i] = block->res[i];
	}
	
	return KIN_SUCCESS; /*Success*/
	/*return 1;  //Recoverable error*/
	/*return -1; //Unrecoverable error*/
}

void kin_err(int err_code, const char *module, const char *function, char *msg, void *eh_data){
	if (err_code > 0){ /*Warning*/
		printf("[KINSOL WARNING] ");
	}else if (err_code < 0){ /*Error*/
		printf("[KINSOL ERROR] ");
	}
	printf(function);
	printf(" ");
	printf(msg);
	printf("\n");
}


int jmi_kinsol_error_handling(int flag){
	if (flag < 0){
		printf("Kinsol failed with flag %d", flag); 
	}
	return 0;
}

int jmi_kinsol_solve(jmi_block_residual_t * block){
	int flag;
	int error_return;
	int i;
	int verbosity = 0;

	/*Check if the block is to be initialized.*/
	if (block->init == 1){
		
		/*Initialize work vectors.*/
		block->kin_ftol = JMI_KINSOL_TOL; /*To be changed.*/
		block->kin_stol = JMI_KINSOL_TOL; /*To be changed.*/
		
		/*Sets the scaling vectors to ones.*/
		/*To be changed. */
		N_VConst_Serial(ONE,block->kin_y_scale);
		N_VConst_Serial(ONE,block->kin_f_scale);
		
		/* Initialize the work vector */
		block->F(block->jmi,block->x,block->res,JMI_BLOCK_INITIALIZE);
		for(i=0;i<block->n;i=i+1){
			Ith(block->kin_y,i)=block->x[i];
		}
		
		flag = KINInit(block->kin_mem, kin_f, block->kin_y); /*Initialize Kinsol*/
		error_return = jmi_kinsol_error_handling(flag);
		
		flag = KINDense(block->kin_mem, block->n);
		error_return = jmi_kinsol_error_handling(flag);
		
		/*Set problem data to Kinsol*/
		flag = KINSetUserData(block->kin_mem, block);
		error_return = jmi_kinsol_error_handling(flag);
		
		/*Stopping tolerance of F*/
		flag = KINSetFuncNormTol(block->kin_mem, block->kin_ftol); 
		error_return = jmi_kinsol_error_handling(flag);
		
		/*Stepsize tolerance*/
		flag = KINSetScaledStepTol(block->kin_mem, block->kin_stol); 
		error_return = jmi_kinsol_error_handling(flag);
		
		/*Verbosity*/
		flag = KINSetPrintLevel(block->kin_mem, verbosity);
		error_return = jmi_kinsol_error_handling(flag);
		
		/*Error function*/
		flag = KINSetErrHandlerFn(block->kin_mem, kin_err, NULL);
		error_return = jmi_kinsol_error_handling(flag);
		
		/*Solve the block*/
		flag = KINSol(block->kin_mem, block->kin_y, KIN_LINESEARCH, block->kin_y_scale, block->kin_f_scale);
		error_return = jmi_kinsol_error_handling(flag);
		
		block->init = 0; /*The block is initialized*/
	}else{
		/* Initialize the work vector */
		block->F(block->jmi,block->x,block->res,JMI_BLOCK_INITIALIZE);
		for(i=0;i<block->n;i=i+1){
			Ith(block->kin_y,i)=block->x[i];
		}
		
		/*Do not initially update the jacobian*/
		flag = KINSetNoInitSetup(block->kin_mem, 0);
		error_return = jmi_kinsol_error_handling(flag);
		
		/*Solve the block*/
		flag = KINSol(block->kin_mem, block->kin_y, KIN_LINESEARCH, block->kin_y_scale, block->kin_f_scale);
		error_return = jmi_kinsol_error_handling(flag);
	}
	
	return 0;
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
