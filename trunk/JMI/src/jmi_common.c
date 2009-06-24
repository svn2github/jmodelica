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
 * jmi_common.c contains all functions that is possible to factor out from jmi.c
 * and jmi_cppad.c. In effect, this code can be compiled either with C or a C++
 * compiler.
 */

#include "jmi.h"

int jmi_func_new(jmi_func_t** jmi_func, jmi_residual_func_t F, int n_eq_F, jmi_jacobian_func_t dF,
		int dF_n_nz, int* dF_row, int* dF_col) {

	int i;

	jmi_func_t* func = (jmi_func_t*)calloc(1,sizeof(jmi_func_t));
	*jmi_func = func;

	func->n_eq_F = n_eq_F;
	func->F = F;
	func->dF = dF;

	func->dF_n_nz = dF_n_nz;
	func->dF_row = (int*)calloc(dF_n_nz,sizeof(int));
	func->dF_col = (int*)calloc(dF_n_nz,sizeof(int));

	for (i=0;i<dF_n_nz;i++) {
		func->dF_row[i] = dF_row[i];
		func->dF_col[i] = dF_col[i];
	}

	func->ad = NULL;

	return 0;
}

int jmi_func_delete(jmi_func_t *func) {
	if (func->ad!=NULL) {
		return -1;
	}
	free(func->dF_row);
	free(func->dF_col);
	free(func);
	return 0;
}

// Convenience function to evaluate the Jacobian of the function contained in a
// jmi_func_t.
int jmi_func_dF(jmi_t *jmi,jmi_func_t *func, int sparsity,
		int independent_vars, int* mask, jmi_real_t* jac) {

	if (func->dF==NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}
	func->dF(jmi, sparsity, independent_vars, mask, jac);
	return 0;

}

// Convenience function for accessing the number of non-zeros in the (symbolic)
// Jacobian.
int jmi_func_dF_n_nz(jmi_t *jmi, jmi_func_t *func, int* n_nz) {
	if (func->dF==NULL) {
		*n_nz = 0;
		return -1;
	}
	*n_nz = func->dF_n_nz;
	return 0;
}

// Convenience function of accessing the non-zeros in the Jacobian
int jmi_func_dF_nz_indices(jmi_t *jmi, jmi_func_t *func, int independent_vars,
                           int *mask,int *row, int *col) {
	if (func->dF==NULL) {
		return -1;
	}

	int i;

//	int col_index = 0;           // Column index of the new Jacobian
//	int col_index_old = 0;       // Temporary variable to keep track of when to increase col_index
	int index = 0;               // Index in the row/col vectors of the new Jacobian

	// Iterate over all non-zero indices
	for (i=0;i<func->dF_n_nz;i++) {
//		printf("%d %d\n",i,jmi_check_Jacobian_column_index(jmi, independent_vars, mask, func->dF_col[i]-1));
		// Check if this particular entry should be included
		if (jmi_check_Jacobian_column_index(jmi, independent_vars, mask, func->dF_col[i]-1) == 1 ) {
			    // Copy indices
				row[index] = func->dF_row[i];
				col[index] = jmi_map_Jacobian_column_index(jmi,independent_vars,mask,func->dF_col[i]-1) + 1;
				index++;
		}
	}

	return 0;

}

// Convenience function for computing the dimensions of the Jacobian.
int jmi_func_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	*dF_n_cols = 0;
	*dF_n_nz = 0;

	if (func->dF==NULL) {
		return -1;
	}

	int i;

	for (i=0;i<jmi->n_z;i++) {
		if (jmi_check_Jacobian_column_index(jmi, independent_vars, mask, i) == 1 ) {
			(*dF_n_cols)++;
		}
	}

	if (sparsity == JMI_DER_SPARSE) {
		for (i=0;i<func->dF_n_nz;i++) {
//			printf(">>>>>>>>>>>>>>>>>>\n");
			// Check if this particular entry should be included
			if (jmi_check_Jacobian_column_index(jmi, independent_vars, mask, func->dF_col[i]-1) == 1 ) {
				(*dF_n_nz)++;
			}
		}
	} else {
		*dF_n_nz = *dF_n_cols*func->n_eq_F;
	}

	return 0;

}

int jmi_get_sizes(jmi_t* jmi, int* n_ci, int* n_cd, int* n_pi, int* n_pd,
		                        int* n_dx, int* n_x, int* n_u, int* n_w, int* n_tp, int* n_z) {

	*n_ci = jmi->n_ci;
	*n_cd = jmi->n_cd;
	*n_pi = jmi->n_pi;
	*n_pd = jmi->n_pd;
	*n_dx = jmi->n_dx;
	*n_x = jmi->n_x;
	*n_u = jmi->n_u;
	*n_w = jmi->n_w;
    *n_tp = jmi->n_tp;
    *n_z = jmi->n_z;

	return 0;
}

int jmi_get_offsets(jmi_t* jmi, int* offs_ci, int* offs_cd, int* offs_pi, int* offs_pd,
		int* offs_dx, int* offs_x, int* offs_u, int* offs_w, int *offs_t,
		int* offs_dx_p, int* offs_x_p, int* offs_u_p, int* offs_w_p) {
	*offs_ci = jmi->offs_ci;
	*offs_cd = jmi->offs_cd;
	*offs_pi = jmi->offs_pi;
	*offs_pd = jmi->offs_pd;
	*offs_dx = jmi->offs_dx;
	*offs_x = jmi->offs_x;
	*offs_u = jmi->offs_u;
	*offs_w = jmi->offs_w;
	*offs_t = jmi->offs_t;
	*offs_dx_p = jmi->offs_dx_p;
	*offs_x_p = jmi->offs_x_p;
	*offs_u_p = jmi->offs_u_p;
	*offs_w_p = jmi->offs_w_p;

	return 0;
}

int jmi_dae_init(jmi_t* jmi, jmi_residual_func_t F, int n_eq_F, jmi_jacobian_func_t dF,
		int dF_n_nz, int* dF_row, int* dF_col) {

	// Create jmi_dae struct
	jmi_dae_t* dae = (jmi_dae_t*)calloc(1,sizeof(jmi_dae_t));
	jmi->dae = dae;

	jmi_func_t* jf_F;
	jmi_func_new(&jf_F,F,n_eq_F,dF,dF_n_nz,dF_row, dF_col);
	jmi->dae->F = jf_F;

	return 0;
}

int jmi_init_init(jmi_t* jmi, jmi_residual_func_t F0, int n_eq_F0,
		jmi_jacobian_func_t dF0,
		int dF0_n_nz, int* dF0_row, int* dF0_col,
		jmi_residual_func_t F1, int n_eq_F1,
		jmi_jacobian_func_t dF1,
		int dF1_n_nz, int* dF1_row, int* dF1_col,
		jmi_residual_func_t Fp, int n_eq_Fp,
		jmi_jacobian_func_t dFp,
		int dFp_n_nz, int* dFp_row, int* dFp_col) {

	// Create jmi_init struct
	jmi_init_t* init = (jmi_init_t*)calloc(1,sizeof(jmi_init_t));
	jmi->init = init;

	jmi_func_t* jf_F0;
	jmi_func_new(&jf_F0,F0,n_eq_F0,dF0,dF0_n_nz,dF0_row, dF0_col);
	jmi->init->F0 = jf_F0;

	jmi_func_t* jf_F1;
	jmi_func_new(&jf_F1,F1,n_eq_F1,dF1,dF1_n_nz,dF1_row, dF1_col);
	jmi->init->F1 = jf_F1;

	jmi_func_t* jf_Fp;
	jmi_func_new(&jf_Fp,Fp,n_eq_Fp,dFp,dFp_n_nz,dFp_row, dFp_col);
	jmi->init->Fp = jf_Fp;

	return 0;
}

int jmi_opt_init(jmi_t* jmi, jmi_residual_func_t J,
		jmi_jacobian_func_t dJ,
		int dJ_n_nz, int* dJ_row, int* dJ_col,
		jmi_residual_func_t Ceq, int n_eq_Ceq,
		jmi_jacobian_func_t dCeq,
		int dCeq_n_nz, int* dCeq_row, int* dCeq_col,
		jmi_residual_func_t Cineq, int n_eq_Cineq,
		jmi_jacobian_func_t dCineq,
		int dCineq_n_nz, int* dCineq_row, int* dCineq_col,
		jmi_residual_func_t Heq, int n_eq_Heq,
		jmi_jacobian_func_t dHeq,
		int dHeq_n_nz, int* dHeq_row, int* dHeq_col,
		jmi_residual_func_t Hineq, int n_eq_Hineq,
		jmi_jacobian_func_t dHineq,
		int dHineq_n_nz, int* dHineq_row, int* dHineq_col) {

	// Create opt_init_t struct
	jmi_opt_t* opt = (jmi_opt_t*)calloc(1,sizeof(jmi_opt_t));
	jmi->opt = opt;

	jmi_func_t* jf_J;
	jmi_func_new(&jf_J,J,1,dJ,dJ_n_nz,dJ_row, dJ_col);
	jmi->opt->J = jf_J;

	jmi_func_t* jf_Ceq;
	jmi_func_new(&jf_Ceq,Ceq,n_eq_Ceq,dCeq,dCeq_n_nz,dCeq_row, dCeq_col);
	jmi->opt->Ceq = jf_Ceq;

	jmi_func_t* jf_Cineq;
	jmi_func_new(&jf_Cineq,Cineq,n_eq_Cineq,dCineq,dCineq_n_nz,dCineq_row, dCineq_col);
	jmi->opt->Cineq = jf_Cineq;

	jmi_func_t* jf_Heq;
	jmi_func_new(&jf_Heq,Heq,n_eq_Heq,dHeq,dHeq_n_nz,dHeq_row, dHeq_col);
	jmi->opt->Heq = jf_Heq;

	jmi_func_t* jf_Hineq;
	jmi_func_new(&jf_Hineq,Hineq,n_eq_Hineq,dHineq,dHineq_n_nz,dHineq_row, dHineq_col);
	jmi->opt->Hineq = jf_Hineq;

	return 0;

}

int jmi_variable_type(jmi_t *jmi, int col_index) {
	int i;

    if (col_index>=jmi->offs_ci && col_index<jmi->offs_cd) {
    	return JMI_DER_CI;
    } else if (col_index >= jmi->offs_cd && col_index < jmi->offs_pi) {
    	return JMI_DER_CD;
    } else if (col_index>=jmi->offs_pi && col_index<jmi->offs_pd) {
    	return JMI_DER_PI;
    } else if (col_index>=jmi->offs_pd && col_index<jmi->offs_dx) {
    	return JMI_DER_PD;
    } else if (col_index>=jmi->offs_dx && col_index<jmi->offs_x) {
    	return JMI_DER_DX;
    } else if (col_index>=jmi->offs_x && col_index<jmi->offs_u) {
    	return JMI_DER_X;
    } else if (col_index>=jmi->offs_u && col_index<jmi->offs_w) {
    	return JMI_DER_U;
    } else if (col_index>=jmi->offs_w && col_index<jmi->offs_t) {
    	return JMI_DER_W;
    } else if (col_index>=jmi->offs_t && col_index<jmi->offs_dx_p) {
    	return JMI_DER_T;
    }

    for (i=0;i<jmi->n_tp;i++) {
    	if (col_index>=jmi->offs_dx_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i &&
    			col_index<jmi->offs_x_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i) {
    		return JMI_DER_DX_P;
    	} else if (col_index>=jmi->offs_x_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i &&
    			col_index<jmi->offs_u_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i) {
    		return JMI_DER_X_P;
    	} else if (col_index>=jmi->offs_u_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i &&
    			col_index<jmi->offs_w_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i) {
    		return JMI_DER_U_P;
    	} else if (col_index>=jmi->offs_w_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i &&
    			col_index<jmi->offs_w_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i + jmi->n_w) {
    		return JMI_DER_W_P;
    	}
    }

    return -1;
}

int jmi_check_Jacobian_column_index(jmi_t *jmi, int independent_vars, int *mask, int col_index) {

//	printf("<<< %d %d\n", col_index, mask[col_index]);
//	printf("<< %d %d\n", independent_vars, jmi_variable_type(jmi, col_index));

	if (mask[col_index] == 0) {
//		printf("Hej\n");
		return 0;
	} else if ((independent_vars & jmi_variable_type(jmi, col_index))) {
//		printf("Hojj\n");
		return 1;
	} else {
//		printf("Hepp\n");
		return 0;
	}
}

int jmi_map_Jacobian_column_index(jmi_t *jmi, int independent_vars, int *mask, int col_index) {

//	printf("jmi_map_Jacobian_column_index start: %d\n",col_index);
	int new_col_index = 0;
	int i = 0;

	for (i=0; i<col_index; i++) {
//		printf("****************** 1 \n");
		if (jmi_check_Jacobian_column_index(jmi, independent_vars, mask, i)==1) {
			new_col_index++;
		}
//		printf("****************** 2 \n");
	}

//	printf("jmi_map_Jacobian_column_index end: %d\n",new_col_index);

	return new_col_index;
}

int jmi_dae_get_sizes(jmi_t* jmi, int* n_eq_F) {
	if (jmi->dae == NULL) {
		return -1;
	}
	*n_eq_F = jmi->dae->F->n_eq_F;
	return 0;
}
int jmi_init_get_sizes(jmi_t* jmi, int* n_eq_F0, int* n_eq_F1, int* n_eq_Fp) {
	if (jmi->init == NULL) {
		return -1;
	}
	*n_eq_F0 = jmi->init->F0->n_eq_F;
	*n_eq_F1 = jmi->init->F1->n_eq_F;
	*n_eq_Fp = jmi->init->Fp->n_eq_F;
	return 0;
}

int jmi_opt_get_sizes(jmi_t* jmi, int* n_eq_Ceq, int* n_eq_Cineq, int* n_eq_Heq, int* n_eq_Hineq) {
	if (jmi->opt == NULL) {
		return -1;
	}
	*n_eq_Ceq = jmi->opt->Ceq->n_eq_F;
	*n_eq_Cineq = jmi->opt->Cineq->n_eq_F;
	*n_eq_Heq = jmi->opt->Heq->n_eq_F;
	*n_eq_Hineq = jmi->opt->Hineq->n_eq_F;
return 0;
}

int jmi_set_tp(jmi_t *jmi, jmi_real_t *tp) {
	int i;
	for (i=0;i<jmi->n_tp;i++) {
		jmi->tp[i] = tp[i];
	}
	return 0;
}

int jmi_get_n_tp(jmi_t *jmi, int *n_tp) {
	*n_tp = jmi->n_tp;
	return 0;
}

int jmi_get_tp(jmi_t *jmi, jmi_real_t *tp) {
	int i;
	if (jmi->tp != NULL) {
		for (i=0;i<jmi->n_tp;i++) {
			tp[i] = jmi->tp[i];
		}
		return 0;
	} else {
		return -1;
	}
}

int jmi_opt_get_optimization_interval(jmi_t *jmi, double *start_time, int *start_time_free,
		                              double *final_time, int *final_time_free) {
	*start_time = jmi->opt->start_time;
	*start_time_free = jmi->opt->start_time_free;
	*final_time = jmi->opt->final_time;
	*final_time_free = jmi->opt->final_time_free;
	return 0;
}


int jmi_opt_set_optimization_interval(jmi_t *jmi, double start_time, int start_time_free,
		 double final_time, int final_time_free) {
	jmi->opt->start_time = start_time;
	jmi->opt->start_time_free = start_time_free;
	jmi->opt->final_time = final_time;
	jmi->opt->final_time_free = final_time_free;
	return 0;
}

int jmi_opt_set_p_opt_indices(jmi_t *jmi, int n_p_opt, int *p_opt_indices) {
	int i;
	if (jmi->opt->p_opt_indices != NULL) {
		free(jmi->opt->p_opt_indices);
	}
	jmi->opt->n_p_opt = n_p_opt;
	jmi->opt->p_opt_indices = (int*)calloc(n_p_opt,sizeof(int));
	for (i=0;i<n_p_opt;i++) {
		jmi->opt->p_opt_indices[i] = p_opt_indices[i];
	}
	return 0;
}

int jmi_opt_get_n_p_opt(jmi_t *jmi, int *n_p_opt) {
	*n_p_opt = jmi->opt->n_p_opt;
	return 0;
}

int jmi_opt_get_p_opt_indices(jmi_t *jmi, int *p_opt_indices) {
	int i;
	if (jmi->opt->p_opt_indices != NULL) {
		for (i=0;i<jmi->opt->n_p_opt;i++) {
			p_opt_indices[i] = jmi->opt->p_opt_indices[i];
		}
	return 0;
	} else {
		return -1;
	}
}

jmi_real_t* jmi_get_z(jmi_t* jmi) {
	return *(jmi->z_val);
}

jmi_real_t* jmi_get_ci(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_ci;
}

jmi_real_t* jmi_get_cd(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_cd;
}

jmi_real_t* jmi_get_pi(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_pi;
}

jmi_real_t* jmi_get_pd(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_pd;
}

jmi_real_t* jmi_get_dx(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_dx;
}

jmi_real_t* jmi_get_x(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_x;
}

jmi_real_t* jmi_get_u(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_u;
}

jmi_real_t* jmi_get_w(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_w;
}

jmi_real_t* jmi_get_t(jmi_t* jmi) {
	return *(jmi->z_val) + jmi->offs_t;
}

jmi_real_t* jmi_get_dx_p(jmi_t* jmi, int i) {
	return *(jmi->z_val) + jmi->offs_dx_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i;
}

jmi_real_t* jmi_get_x_p(jmi_t* jmi, int i) {
	return *(jmi->z_val) + jmi->offs_x_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i;
}

jmi_real_t* jmi_get_u_p(jmi_t* jmi, int i) {
	return *(jmi->z_val) + jmi->offs_u_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i;
}

jmi_real_t* jmi_get_w_p(jmi_t* jmi, int i) {
	return *(jmi->z_val) + jmi->offs_w_p + (jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)*i;
}


void jmi_print_summary(jmi_t *jmi) {
	printf("Number of interactive constants:               %d\n",jmi->n_ci);
	printf("Number of dependent constants:                 %d\n",jmi->n_cd);
	printf("Number of interactive parameters:              %d\n",jmi->n_pi);
	printf("Number of dependent parameters:                %d\n",jmi->n_pd);
	printf("Number of derivatives:                         %d\n",jmi->n_dx);
	printf("Number of states:                              %d\n",jmi->n_x);
	printf("Number of inputs:                              %d\n",jmi->n_u);
	printf("Number of algebraics:                          %d\n",jmi->n_w);
	printf("Number of time points:                         %d\n",jmi->n_tp);
	if (jmi->dae != NULL) {
		printf("DAE interface:\n");
		printf("  Number of DAE equations:                     %d\n",jmi->dae->F->n_eq_F);
	} else {
		printf("No DAE functions available");
	}
	if (jmi->init != NULL) {
		printf("Initialization interface:\n");
		printf("  Number of F0 equations:                      %d\n",jmi->init->F0->n_eq_F);
		printf("  Number of F1 equations:                      %d\n",jmi->init->F1->n_eq_F);
	} else {
		printf("No Initialization functions available");
	}
	if (jmi->opt != NULL) {
		printf("Optimization interface:\n");
		printf("  Number of Ceq constraints:                   %d\n",jmi->opt->Ceq->n_eq_F);
		printf("  Number of Cineq constraints:                 %d\n",jmi->opt->Cineq->n_eq_F);
		printf("  Number of Heq constraints:                   %d\n",jmi->opt->Heq->n_eq_F);
		printf("  Number of Hineq constraints:                 %d\n",jmi->opt->Hineq->n_eq_F);
	} else {
		printf("No Optimization functions available");
	}
}




