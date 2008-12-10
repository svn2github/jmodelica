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
		return -1;
	}
	*n_nz = func->dF_n_nz;
	return 0;
}


// Convenience function of accessing the non-zeros in the AD Jacobian
int jmi_func_dF_nz_indices(jmi_t *jmi, jmi_func_t *func, int *row, int *col) {
	if (func->dF==NULL) {
		return -1;
	}
	int i;
	for (i=0;i<func->dF_n_nz;i++) {
		row[i] = func->dF_row[i];
		col[i] = func->dF_col[i];
	}
	return 0;

}

// Convenience function for computing the dimensions of an AD Jacobian.
int jmi_func_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {
	if (func->dF==NULL) {
		return -1;
	}

	*dF_n_cols = 0;
	*dF_n_nz = 0;

	int i,j;
	int col_index = 0;

	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_CI, jmi->n_ci, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_CD, jmi->n_cd, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_PI, jmi->n_pi, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_PD, jmi->n_pd, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_DX, jmi->n_dx, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_X, jmi->n_x, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_U, jmi->n_u, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_W, jmi->n_w, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_T, 1, func->n_eq_F, func->dF_n_nz, jmi->dae->F->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_DX_P, jmi->n_dx*jmi->n_tp, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_X_P, jmi->n_x*jmi->n_tp, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_U_P, jmi->n_u*jmi->n_tp, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_W_P, jmi->n_w*jmi->n_tp, func->n_eq_F, func->dF_n_nz, func->dF_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_T_P, 1*jmi->n_tp, func->n_eq_F, func->dF_n_nz, jmi->dae->F->dF_col)

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
		int* offs_dx_p, int* offs_x_p, int* offs_u_p, int* offs_w_p, int *offs_t_p) {
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
	*offs_t_p = jmi->offs_t_p;

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
		int dF1_n_nz, int* dF1_row, int* dF1_col) {

	// Create jmi_init struct
	jmi_init_t* init = (jmi_init_t*)calloc(1,sizeof(jmi_init_t));
	jmi->init = init;

	jmi_func_t* jf_F0;
	jmi_func_new(&jf_F0,F0,n_eq_F0,dF0,dF0_n_nz,dF0_row, dF0_row);
	jmi->init->F0 = jf_F0;

	jmi_func_t* jf_F1;
	jmi_func_new(&jf_F1,F1,n_eq_F1,dF1,dF1_n_nz,dF1_row, dF1_row);
	jmi->init->F1 = jf_F1;

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
	jmi_func_new(&jf_J,J,1,dJ,dJ_n_nz,dJ_row, dJ_row);
	jmi->opt->J = jf_J;

	jmi_func_t* jf_Ceq;
	jmi_func_new(&jf_Ceq,Ceq,n_eq_Ceq,dCeq,dCeq_n_nz,dCeq_row, dCeq_row);
	jmi->opt->Ceq = jf_Ceq;

	jmi_func_t* jf_Cineq;
	jmi_func_new(&jf_Cineq,Cineq,n_eq_Cineq,dCineq,dCineq_n_nz,dCineq_row, dCineq_row);
	jmi->opt->Cineq = jf_Cineq;

	jmi_func_t* jf_Heq;
	jmi_func_new(&jf_Heq,Heq,n_eq_Heq,dHeq,dHeq_n_nz,dHeq_row, dHeq_row);
	jmi->opt->Heq = jf_Heq;

	jmi_func_t* jf_Hineq;
	jmi_func_new(&jf_Hineq,Hineq,n_eq_Hineq,dHineq,dHineq_n_nz,dHineq_row, dHineq_row);
	jmi->opt->Hineq = jf_Hineq;

	return 0;

}

int jmi_dae_get_sizes(jmi_t* jmi, int* n_eq_F) {
	if (jmi->dae == NULL) {
		return -1;
	}
	*n_eq_F = jmi->dae->F->n_eq_F;
	return 0;
}
int jmi_init_get_sizes(jmi_t* jmi, int* n_eq_F0, int* n_eq_F1) {
	if (jmi->init == NULL) {
		return -1;
	}
	*n_eq_F0 = jmi->init->F0->n_eq_F;
	*n_eq_F1 = jmi->init->F1->n_eq_F;
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

int jmi_opt_set_optimization_interval(jmi_t *jmi, double start_time, int start_time_free,
		                              double final_time, int final_time_free) {
	jmi->opt->start_time = start_time;
	jmi->opt->start_time_free = start_time_free;
	jmi->opt->final_time = final_time;
	jmi->opt->final_time_free = final_time_free;
	return 0;
}


int jmi_get_ci(jmi_t* jmi, jmi_real_t** ci) {
	*ci = *(jmi->z_val) + jmi->offs_ci;
	return 0;
}

int jmi_get_cd(jmi_t* jmi, jmi_real_t** cd) {
	*cd = *(jmi->z_val) + jmi->offs_cd;
	return 0;
}

int jmi_get_pi(jmi_t* jmi, jmi_real_t** pi) {
	*pi = *(jmi->z_val) + jmi->offs_pi;
	return 0;
}

int jmi_get_pd(jmi_t* jmi, jmi_real_t** pd) {
	*pd = *(jmi->z_val) + jmi->offs_pd;
	return 0;
}

int jmi_get_dx(jmi_t* jmi, jmi_real_t** dx) {
	*dx = *(jmi->z_val) + jmi->offs_dx;
	return 0;
}

int jmi_get_x(jmi_t* jmi, jmi_real_t** x) {
	*x = *(jmi->z_val) + jmi->offs_x;
	return 0;
}

int jmi_get_u(jmi_t* jmi, jmi_real_t** u) {
	*u = *(jmi->z_val) + jmi->offs_u;
	return 0;
}

int jmi_get_w(jmi_t* jmi, jmi_real_t** w) {
	*w = *(jmi->z_val) + jmi->offs_w;
	return 0;
}

int jmi_get_t(jmi_t* jmi, jmi_real_t** t) {
	*t = *(jmi->z_val) + jmi->offs_t;
	return 0;
}

int jmi_get_dx_p(jmi_t* jmi, jmi_real_t** dx) {
	*dx = *(jmi->z_val) + jmi->offs_dx_p;
	return 0;
}

int jmi_get_x_p(jmi_t* jmi, jmi_real_t** x) {
	*x = *(jmi->z_val) + jmi->offs_x_p;
	return 0;
}

int jmi_get_u_p(jmi_t* jmi, jmi_real_t** u) {
	*u = *(jmi->z_val) + jmi->offs_u_p;
	return 0;
}

int jmi_get_w_p(jmi_t* jmi, jmi_real_t** w) {
	*w = *(jmi->z_val) + jmi->offs_w_p;
	return 0;
}

int jmi_get_t_p(jmi_t* jmi, jmi_real_t** t) {
	*t = *(jmi->z_val) + jmi->offs_t_p;
	return 0;
}

