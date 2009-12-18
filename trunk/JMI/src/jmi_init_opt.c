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


#include "jmi_init_opt.h"

// Forward declarations
static void print_problem_stats(jmi_init_opt_t *jmi_init_opt);

static void copy_v(jmi_init_opt_t *jmi_init_opt) {

	int i;
	jmi_t* jmi = jmi_init_opt->jmi;

	jmi_real_t* v = jmi_get_dx(jmi);
	for (i=0;i<jmi->n_dx+jmi->n_x;i++) {
		v[i] = jmi_init_opt->x[i];
	}
	for (i=0;i<jmi->n_w;i++) {
		v[i+jmi->n_dx+jmi->n_x+jmi->n_u] = jmi_init_opt->x[i+jmi->n_dx+jmi->n_x];
	}


}

int jmi_init_opt_new(jmi_init_opt_t **jmi_init_opt_new, jmi_t *jmi,
		int n_p_free, int *p_free_indices,
		jmi_real_t *p_free_init, jmi_real_t *dx_init, jmi_real_t *x_init,
		jmi_real_t *w_init,
		jmi_real_t *p_free_lb, jmi_real_t *dx_lb, jmi_real_t *x_lb,
		jmi_real_t *w_lb,
		jmi_real_t *p_free_ub, jmi_real_t *dx_ub, jmi_real_t *x_ub,
		jmi_real_t *w_ub,
		int linearity_information_provided,
		int* p_free_lin, int* dx_lin, int* x_lin, int* w_lin,
		int der_eval_alg) {

	int retval,i;

	// Create struct
	jmi_init_opt_t* jmi_init_opt = (jmi_init_opt_t*)calloc(1,sizeof(jmi_init_opt_t));
	*jmi_init_opt_new = (jmi_init_opt_t*)jmi_init_opt;

	jmi_init_opt->jmi = jmi;

	// Copy der_eval_alg field
	jmi_init_opt->der_eval_alg = der_eval_alg;

	// Set size of optimization vector
	jmi_init_opt->n_x = n_p_free + jmi->n_dx + jmi->n_x +jmi->n_w;

	// Create mask for evaluation of Jacobians
	jmi_init_opt->der_mask_v = (int*)calloc(jmi->n_z,sizeof(int));
	for (i=0;i<jmi->n_z;i++) {
		jmi_init_opt->der_mask_v[i] = 1;
	}

	// Copy information about free parameters
	jmi_init_opt->n_p_free = n_p_free;
	jmi_init_opt->p_free_indices = (int*)calloc(n_p_free,sizeof(int));

	for (i=0;i<n_p_free;i++) {
		jmi_init_opt->p_free_indices[i] = p_free_indices[i];
	}

	// Initialize vectors
	jmi_init_opt->x = (jmi_real_t*)calloc(jmi_init_opt->n_x,sizeof(jmi_real_t));
	jmi_init_opt->x_init = (jmi_real_t*)calloc(jmi_init_opt->n_x,sizeof(jmi_real_t));
	jmi_init_opt->x_lb = (jmi_real_t*)calloc(jmi_init_opt->n_x,sizeof(jmi_real_t));
	jmi_init_opt->x_ub = (jmi_real_t*)calloc(jmi_init_opt->n_x,sizeof(jmi_real_t));

	// Copy values for free parameters
	for (i=0;i<n_p_free;i++) {
		jmi_init_opt->x_init[i] = p_free_init[i];
		jmi_init_opt->x_lb[i] = p_free_lb[i];
		jmi_init_opt->x_ub[i] = p_free_ub[i];
	}

	// Copy values for derivatives
	for (i=0;i<jmi->n_dx;i++) {
		jmi_init_opt->x_init[i+n_p_free] = dx_init[i];
		jmi_init_opt->x_lb[i+n_p_free] = dx_lb[i];
		jmi_init_opt->x_ub[i+n_p_free] = dx_ub[i];
	}

	// Copy values for differentiated variables
	for (i=0;i<jmi->n_x;i++) {
		jmi_init_opt->x_init[i+n_p_free + jmi->n_dx] = x_init[i];
		jmi_init_opt->x_lb[i+n_p_free + jmi->n_dx] = x_lb[i];
		jmi_init_opt->x_ub[i+n_p_free + jmi->n_dx] = x_ub[i];
	}

	// Copy values for the algebraics
	for (i=0;i<jmi->n_w;i++) {
		jmi_init_opt->x_init[i+n_p_free + jmi->n_dx + jmi->n_x] = w_init[i];
		jmi_init_opt->x_lb[i+n_p_free + jmi->n_dx + jmi->n_x] = w_lb[i];
		jmi_init_opt->x_ub[i+n_p_free + jmi->n_dx + jmi->n_x] = w_ub[i];
	}

	// Copy initial point to optimization vector
	for (i=0;i<jmi_init_opt->n_x;i++) {
		jmi_init_opt->x[i] = jmi_init_opt->x_init[i];
	}


	// Set non-linear variables: currently not supported TODO:
	jmi_init_opt->n_nonlinear_variables = 0;

	// Initialized work vectors
	jmi_init_opt->res_F1 = (jmi_real_t*)calloc(jmi->init->F1->n_eq_F,sizeof(jmi_real_t));

	int dF1_dv_n_cols;
	int dF1_dv_n_nz;
	retval = jmi_init_dF1_dim(jmi, jmi_init_opt->der_eval_alg, JMI_DER_SPARSE,
				JMI_DER_DX | JMI_DER_X | JMI_DER_W,
				jmi_init_opt->der_mask_v, &dF1_dv_n_cols, &dF1_dv_n_nz);
	if (retval<0) {
		return retval;
	}

	jmi_init_opt->dF1_dv_n_nz = dF1_dv_n_nz;

	// Allocate memory
	jmi_init_opt->dF1_dv_icol = (int*)calloc(jmi_init_opt->dF1_dv_n_nz,sizeof(int));
	jmi_init_opt->dF1_dv_irow = (int*)calloc(jmi_init_opt->dF1_dv_n_nz,sizeof(int));
	jmi_init_opt->dF1_dv = (jmi_real_t*)calloc(jmi_init_opt->dF1_dv_n_nz,sizeof(jmi_real_t));

	retval = jmi_init_dF1_nz_indices(jmi,jmi_init_opt->der_eval_alg,
			JMI_DER_DX | JMI_DER_X | JMI_DER_W,
			jmi_init_opt->der_mask_v, jmi_init_opt->dF1_dv_irow,
			jmi_init_opt->dF1_dv_icol);
	if (retval<0) {
		return retval;
	}

	// Set number of equality constraints
	jmi_init_opt->n_h = jmi->init->F0->n_eq_F;

	// Compute the number of non-zero entries in the equality constraint
	// Jacobian
	int dF0_dv_n_cols;
	int dF0_dv_n_nz;
	retval = jmi_init_dF0_dim(jmi, jmi_init_opt->der_eval_alg, JMI_DER_SPARSE,
				JMI_DER_DX | JMI_DER_X | JMI_DER_W,
				jmi_init_opt->der_mask_v, &dF0_dv_n_cols, &dF0_dv_n_nz);
	if (retval<0) {
		return retval;
	}

	//printf("*** %d, %d\n",dF0_dv_n_nz,dF0_dv_n_cols);

	jmi_init_opt->dh_n_nz = dF0_dv_n_nz;

	// Allocate memory
	jmi_init_opt->dh_icol = (int*)calloc(jmi_init_opt->dh_n_nz,sizeof(int));
	jmi_init_opt->dh_irow = (int*)calloc(jmi_init_opt->dh_n_nz,sizeof(int));

	// Compute the non-zero indices in equality constraint Jacobian
	retval = jmi_init_dF0_nz_indices(jmi,jmi_init_opt->der_eval_alg,
			JMI_DER_DX | JMI_DER_X | JMI_DER_W,
			jmi_init_opt->der_mask_v, jmi_init_opt->dh_irow,
			jmi_init_opt->dh_icol);
	if (retval<0) {
		return retval;
	}

/*
	for (i=0;i<jmi_init_opt->dh_n_nz;i++) {
		printf("%d %d %d\n",i,jmi_init_opt->dh_irow[i],jmi_init_opt->dh_icol[i]);
	}
*/

	print_problem_stats(jmi_init_opt);

	return 0;

}

int jmi_init_opt_delete(jmi_init_opt_t *jmi_init_opt) {

	free(jmi_init_opt->x);
	free(jmi_init_opt->x_lb);
	free(jmi_init_opt->x_ub);
	free(jmi_init_opt->x_init);

	free(jmi_init_opt->p_free_indices);
	free(jmi_init_opt->dh_irow);
	free(jmi_init_opt->dh_icol);
	free(jmi_init_opt->p_free_indices);
	free(jmi_init_opt->res_F1);
	free(jmi_init_opt->dF1_dv);
	free(jmi_init_opt->dF1_dv_irow);
	free(jmi_init_opt->dF1_dv_icol);
	free(jmi_init_opt->der_mask_v);

	return 0;

}

int jmi_init_opt_get_dimensions(jmi_init_opt_t *jmi_init_opt, int *n_x, int *n_h,
		int *dh_n_nz) {

	if (jmi_init_opt->jmi->opt == NULL) {
		return -1;
	}
	*n_x = jmi_init_opt->n_x;
	*n_h = jmi_init_opt->n_h;
	*dh_n_nz = jmi_init_opt->dh_n_nz;

	return 0;
}

jmi_real_t* jmi_init_opt_get_x(jmi_init_opt_t *jmi_init_opt) {
	return jmi_init_opt->x;
}

int jmi_init_opt_get_bounds(jmi_init_opt_t *jmi_init_opt, jmi_real_t *x_lb, jmi_real_t *x_ub) {
	if (jmi_init_opt->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_init_opt->n_x;i++) {
		x_lb[i] = jmi_init_opt->x_lb[i];
		x_ub[i] = jmi_init_opt->x_ub[i];
	}
	return 0;
}

int jmi_init_opt_set_bounds(jmi_init_opt_t *jmi_init_opt, jmi_real_t *x_lb, jmi_real_t *x_ub) {
	if (jmi_init_opt->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_init_opt->n_x;i++) {
		jmi_init_opt->x_lb[i] = x_lb[i];
		jmi_init_opt->x_ub[i] = x_ub[i];
	}
	return 0;
}

int jmi_init_opt_get_initial(jmi_init_opt_t *jmi_init_opt, jmi_real_t *x_init) {
	if (jmi_init_opt->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_init_opt->n_x;i++) {
		x_init[i] = jmi_init_opt->x_init[i];
	}
	return 0;
}

int jmi_init_opt_set_initial(jmi_init_opt_t *jmi_init_opt,
		jmi_real_t *x_init) {
	if (jmi_init_opt->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_init_opt->n_x;i++) {
		jmi_init_opt->x_init[i] = x_init[i];
	}
	return 0;
}

int jmi_init_opt_f(jmi_init_opt_t *jmi_init_opt, jmi_real_t *f) {
	if (jmi_init_opt->jmi->init == NULL) {
		return -1;
	}
	int i;

	// Copy values into jmi->z
    // Copy free paramters TODO:
	// Copy variables
	copy_v(jmi_init_opt);

	*f = 0.0;
	int retval = jmi_init_F1(jmi_init_opt->jmi, jmi_init_opt->res_F1);
	if (retval<0) {
		return retval;
	}
	for (i=0;i<jmi_init_opt->jmi->init->F1->n_eq_F;i++) {
		// Call cost function evaluation
		*f += 0.5*jmi_init_opt->res_F1[i]*jmi_init_opt->res_F1[i];
	}
	return retval;

}

int jmi_init_opt_df(jmi_init_opt_t *jmi_init_opt, jmi_real_t *df) {
	if (jmi_init_opt->jmi->init == NULL) {
		return -1;
	}
	int i;

	jmi_t *jmi = jmi_init_opt->jmi;

	// Copy values into jmi->z
    // Copy free paramters TODO:
	// Copy variables
	copy_v(jmi_init_opt);

	// Evaluate jacobian
	int retval = jmi_init_dF1(jmi, jmi_init_opt->der_eval_alg,
			JMI_DER_SPARSE, JMI_DER_DX | JMI_DER_X | JMI_DER_W,
			jmi_init_opt->der_mask_v, jmi_init_opt->dF1_dv);
	if (retval<0) {
		return retval;
	}

	// Evaluate residual
	retval = jmi_init_F1(jmi, jmi_init_opt->res_F1);
	if (retval<0) {
		return retval;
	}

	// Initialize the gradient vector
	for (i=0;i<jmi_init_opt->n_x;i++) {
		df[i] = 0.;
	}

	// Compute gradient
	for (i=0;i<jmi_init_opt->dF1_dv_n_nz;i++) {
		df[jmi_init_opt->dF1_dv_icol[i]-1] +=
			jmi_init_opt->dF1_dv[i]*
			jmi_init_opt->res_F1[jmi_init_opt->dF1_dv_irow[i]-1];
		//printf("** %d %d %d %f %f \n",i,jmi_init_opt->dF1_dv_irow[i],jmi_init_opt->dF1_dv_icol[i],jmi_init_opt->dF1_dv[i],jmi_init_opt->res_F1[jmi_init_opt->dF1_dv_irow[i]-1]);
	}

	/*
	for(i=0;i<jmi_init_opt->dF1_dv_n_nz;i++) {
		printf("%f\n",df[i]);
	}
	 */

    return retval;

}

int jmi_init_opt_h(jmi_init_opt_t *jmi_init_opt, jmi_real_t *res) {
	if (jmi_init_opt->jmi->init == NULL || jmi_init_opt->jmi->dae == NULL)  {
		return -1;
	}

	// Copy values into jmi->z
    // Copy free paramters TODO:
	// Copy variables
	copy_v(jmi_init_opt);

	int retval = jmi_init_F0(jmi_init_opt->jmi, res);

	return retval;
}

int jmi_init_opt_dh(jmi_init_opt_t *jmi_init_opt, jmi_real_t *jac) {
	if (jmi_init_opt->jmi->init == NULL || jmi_init_opt->jmi->dae == NULL)  {
		return -1;
	}

	jmi_t *jmi = jmi_init_opt->jmi;

	// Copy values into jmi->z
    // Copy free paramters TODO:
	// Copy variables
	copy_v(jmi_init_opt);

	// Evaluate jacobian
	int retval = jmi_init_dF0 (jmi, jmi_init_opt->der_eval_alg,
			JMI_DER_SPARSE, JMI_DER_DX | JMI_DER_X | JMI_DER_W,
			jmi_init_opt->der_mask_v, jac);
	return retval;

}

int jmi_init_opt_dh_nz_indices(jmi_init_opt_t *jmi_init_opt, int *irow, int *icol) {
	if (jmi_init_opt->jmi->init == NULL || jmi_init_opt->jmi->dae == NULL)  {
		return -1;
	}

	int i;

	for (i=0;i<jmi_init_opt->dh_n_nz;i++) {
		irow[i] = jmi_init_opt->dh_irow[i];
		icol[i] = jmi_init_opt->dh_icol[i];
	}

	return 0;

}


/*
int jmi_init_opt_write_file_matlab(jmi_init_opt_t *jmi_init_opt, const char *file_name) {
	return jmi_init_opt->write_file_matlab(jmi_init_opt, file_name);
}

int jmi_init_opt_get_result(jmi_init_opt_t *jmi_init_opt, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w) {
	return jmi_init_opt->get_result(jmi_init_opt, p_opt, t, dx, x, u, w);
}


*/

static void print_problem_stats(jmi_init_opt_t *jmi_init_opt) {

	printf("Creating NLP for the DAE initialization problem:\n");
	printf("Number of variables:                                       %d\n",jmi_init_opt->n_x);
	printf("Number of non-linear variables:                            %d\n",jmi_init_opt->n_nonlinear_variables);

	printf("Number of equality constraints:                            %d\n",jmi_init_opt->n_h);
	printf("Number of non-zeros in equality constraint Jacobian:       %d\n",jmi_init_opt->dh_n_nz);

}
