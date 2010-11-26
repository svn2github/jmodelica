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
 * jmi.c contains pure C functions and does not support any AD functions.
 */


#include "jmi.h"

int jmi_init(jmi_t** jmi, int n_real_ci, int n_real_cd, int n_real_pi,
		int n_real_pd, int n_integer_ci, int n_integer_cd,
		int n_integer_pi, int n_integer_pd,int n_boolean_ci, int n_boolean_cd,
		int n_boolean_pi, int n_boolean_pd, int n_string_ci, int n_string_cd,
		int n_string_pi, int n_string_pd,
		int n_real_dx, int n_real_x, int n_real_u, int n_real_w,
		int n_tp,int n_real_d,
		int n_integer_d, int n_integer_u,
		int n_boolean_d, int n_boolean_u,
		int n_string_d, int n_string_u, int n_sw, int n_sw_init,
		int n_dae_blocks, int n_dae_init_blocks,
		int scaling_method) {
	jmi_t* jmi_ ;
	int i;
	
	/* Create jmi struct */
	*jmi = (jmi_t*)calloc(1,sizeof(jmi_t));
	jmi_ = *jmi;
	/* Set struct pointers in jmi */
	jmi_->dae = NULL;
	jmi_->init = NULL;
	jmi_->opt = NULL;

	/* Set sizes of dae vectors */
	jmi_->n_real_ci = n_real_ci;
	jmi_->n_real_cd = n_real_cd;
	jmi_->n_real_pi = n_real_pi;
	jmi_->n_real_pd = n_real_pd;

	jmi_->n_integer_ci = n_integer_ci;
	jmi_->n_integer_cd = n_integer_cd;
	jmi_->n_integer_pi = n_integer_pi;
	jmi_->n_integer_pd = n_integer_pd;

	jmi_->n_boolean_ci = n_boolean_ci;
	jmi_->n_boolean_cd = n_boolean_cd;
	jmi_->n_boolean_pi = n_boolean_pi;
	jmi_->n_boolean_pd = n_boolean_pd;

	jmi_->n_string_ci = n_string_ci;
	jmi_->n_string_cd = n_string_cd;
	jmi_->n_string_pi = n_string_pi;
	jmi_->n_string_pd = n_string_pd;

	jmi_->n_real_dx = n_real_dx;
	jmi_->n_real_x = n_real_x;
	jmi_->n_real_u = n_real_u;
	jmi_->n_real_w = n_real_w;

	jmi_->n_tp = n_tp;

	jmi_->n_real_d = n_real_d;

	jmi_->n_integer_d = n_integer_d;
	jmi_->n_integer_u = n_integer_u;

	jmi_->n_boolean_d = n_boolean_d;
	jmi_->n_boolean_u = n_boolean_u;

	jmi_->n_string_d = n_string_d;
	jmi_->n_string_u = n_string_u;

	jmi_->n_sw = n_sw;
	jmi_->n_sw_init = n_sw_init;
	
	jmi_->n_dae_blocks = n_dae_blocks;
	jmi_->n_dae_init_blocks = n_dae_init_blocks;

	jmi_->offs_real_ci = 0;
	jmi_->offs_real_cd = jmi_->offs_real_ci + n_real_ci;
	jmi_->offs_real_pi = jmi_->offs_real_cd + n_real_cd;
	jmi_->offs_real_pd = jmi_->offs_real_pi + n_real_pi;

	jmi_->offs_integer_ci = jmi_->offs_real_pd + n_real_pd;
	jmi_->offs_integer_cd = jmi_->offs_integer_ci + n_integer_ci;
	jmi_->offs_integer_pi = jmi_->offs_integer_cd + n_integer_cd;
	jmi_->offs_integer_pd = jmi_->offs_integer_pi + n_integer_pi;

	jmi_->offs_boolean_ci = jmi_->offs_integer_pd + n_integer_pd;
	jmi_->offs_boolean_cd = jmi_->offs_boolean_ci + n_boolean_ci;
	jmi_->offs_boolean_pi = jmi_->offs_boolean_cd + n_boolean_cd;
	jmi_->offs_boolean_pd = jmi_->offs_boolean_pi + n_boolean_pi;

	jmi_->offs_real_dx = jmi_->offs_boolean_pd + n_boolean_pd;
	jmi_->offs_real_x = jmi_->offs_real_dx + n_real_dx;
	jmi_->offs_real_u = jmi_->offs_real_x + n_real_x;
	jmi_->offs_real_w = jmi_->offs_real_u + n_real_u;
	jmi_->offs_t = jmi_->offs_real_w + n_real_w;

	jmi_->offs_real_dx_p = jmi_->offs_t + (n_tp>0? 1: 0);
	jmi_->offs_real_x_p = jmi_->offs_real_dx_p + (n_tp>0? n_real_dx: 0);
	jmi_->offs_real_u_p = jmi_->offs_real_x_p + (n_tp>0? n_real_x: 0);
	jmi_->offs_real_w_p = jmi_->offs_real_u_p + (n_tp>0? n_real_u: 0);

	jmi_->offs_real_d = jmi_->offs_t + 1 + (n_real_dx + n_real_x + n_real_w + n_real_u)*n_tp;

	jmi_->offs_integer_d = jmi_->offs_real_d + n_real_d;
	jmi_->offs_integer_u = jmi_->offs_integer_d + n_integer_d;

	jmi_->offs_boolean_d = jmi_->offs_integer_u + n_integer_u;
	jmi_->offs_boolean_u = jmi_->offs_boolean_d + n_boolean_d;

	jmi_->offs_sw = jmi_->offs_boolean_u + n_boolean_u;
	jmi_->offs_sw_init = jmi_->offs_sw + n_sw;

	jmi_->offs_p = 0;
	jmi_->offs_v = jmi_->offs_real_dx;
	if (n_tp>0) {
		jmi_->offs_q = jmi_->offs_t + 1;
	} else {
		jmi_->offs_q = jmi_->offs_t;
	}

	jmi_->n_p = jmi_->offs_real_dx;
	jmi_->n_v = n_real_dx + n_real_x + n_real_u + n_real_w + 1;
	jmi_->n_q = (n_real_dx + n_real_x + n_real_u + n_real_w)*n_tp;
	jmi_->n_d = n_real_d + n_integer_d + n_integer_u + n_boolean_d +
		n_boolean_u;

	jmi_->n_z = jmi_->n_p + jmi_->n_v + jmi_->n_q + jmi_->n_d + n_sw + n_sw_init;

	jmi_->z = (jmi_ad_var_vec_p)calloc(1,sizeof(jmi_ad_var_vec_t));
	*(jmi_->z) = (jmi_ad_var_vec_t)calloc(jmi_->n_z,sizeof(jmi_ad_var_t));
	jmi_->pre_z = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t ));
	jmi_->z_val = (jmi_real_vec_p)calloc(1, sizeof(jmi_real_t *));
	*(jmi_->z_val) =  (jmi_real_vec_t)calloc(jmi_->n_z,sizeof(jmi_real_t));

	jmi_->variable_scaling_factors = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));
	jmi_->scaling_method = JMI_SCALING_NONE;

	for (i=0;i<jmi_->n_z;i++) {
		jmi_->variable_scaling_factors[i] = 1.0;
		(*(jmi_->z))[i] = 0;
		(*(jmi_->z_val))[i] = 0;
	}

	jmi_->tp = (jmi_real_t*)calloc(jmi_->n_tp,sizeof(jmi_real_t));

	jmi_->scaling_method = scaling_method;

	jmi_->dae_block_residuals = (jmi_block_residual_t**)calloc(n_dae_blocks,
			sizeof(jmi_block_residual_t*));

	jmi_->dae_init_block_residuals = (jmi_block_residual_t**)calloc(n_dae_init_blocks,
			sizeof(jmi_block_residual_t*));

	return 0;

}

int jmi_ad_init(jmi_t* jmi) {
  /*return -1;*/
  return 0;
}

int jmi_delete(jmi_t* jmi){
	int i;
	if(jmi->dae != NULL) {
		jmi_func_delete(jmi->dae->F);
		free(jmi->dae);
	}
	if(jmi->init != NULL) {
		jmi_func_delete(jmi->init->F0);
		jmi_func_delete(jmi->init->F1);
		free(jmi->init);
	}
	if(jmi->opt != NULL) {
		jmi_func_delete(jmi->opt->Ffdp);
		jmi_func_delete(jmi->opt->J);
		jmi_func_delete(jmi->opt->L);
		jmi_func_delete(jmi->opt->Ceq);
		jmi_func_delete(jmi->opt->Cineq);
		jmi_func_delete(jmi->opt->Heq);
		jmi_func_delete(jmi->opt->Hineq);
		free(jmi->opt);
	}
	for (i=0; i < jmi->n_dae_init_blocks;i=i+1){ /*Deallocate init BLT blocks.*/
		jmi_delete_block_residual(jmi->dae_init_block_residuals[i]);
	}
	for (i=0; i < jmi->n_dae_blocks;i=i+1){ /*Deallocate BLT blocks.*/
		jmi_delete_block_residual(jmi->dae_block_residuals[i]);
	}
	free(*(jmi->z));
	free(*(jmi->z_val));
	free(jmi->z);
	free(jmi->pre_z);
	free(jmi->z_val);
	free(jmi->variable_scaling_factors);
	free(jmi->tp);
	free(jmi);

	return 0;
}

int jmi_func_F(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res) {
	return func->F(jmi,&res);
}

int jmi_ode_f(jmi_t* jmi) {
	int i;
	jmi_real_t* dx;
	jmi_real_t* dx_res;
	
	if (jmi->n_real_w != 0) { /* Check if not ODE */
		return -1;
	}

	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	dx = jmi_get_real_dx(jmi);
	for(i=0;i<jmi->n_real_dx;i++) {
		dx[i]=0;
	}

	dx_res = calloc(jmi->n_real_x,sizeof(jmi_real_t));

	/*jmi->dae->F->F(jmi, &res);*/
	jmi_func_F(jmi,jmi->dae->F,dx_res);

	for(i=0;i<jmi->n_real_dx;i++) {
		dx[i]=dx_res[i];
	}

	free(dx_res);

	return 0;
}

int jmi_ode_df(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	if (jmi->n_real_w != 0) { /* Check if not ODE */
		return -1;
	}

	if (eval_alg & JMI_DER_SYMBOLIC) {

		int i;
		jmi_real_t* dx = jmi_get_real_dx(jmi);
		for(i=0;i<jmi->n_real_dx;i++) {
			dx[i]=0;
		}

		return jmi_func_dF(jmi, jmi->dae->F, sparsity,
				independent_vars & ~JMI_DER_DX, mask, jac) ;

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_ode_df_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	int ret_val;

	if (jmi->n_real_w != 0) { /* Check if not ODE */
		return -1;
	}

	if (eval_alg & JMI_DER_SYMBOLIC) {
        int df_n_cols;
        int* mask = calloc(jmi->n_z,sizeof(int));
        int i;
        for (i=0;i<jmi->n_z;i++) {
        	mask[i] = 1;
        }
		ret_val =  jmi_func_dF_dim(jmi, jmi->dae->F, JMI_DER_SPARSE,
			   JMI_DER_ALL & (~JMI_DER_DX), mask,
				&df_n_cols, n_nz);
		free(mask);
		return ret_val;
	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_ode_df_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (jmi->n_real_w != 0) { /* Check if not ODE */
		return -1;
	}

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->dae->F, independent_vars & (~JMI_DER_DX),
				mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_ode_df_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *df_n_cols, int *df_n_nz) {

	if (jmi->n_real_w != 0) { /* Check if not ODE */
		return -1;
	}

	if (eval_alg & JMI_DER_SYMBOLIC) {
		return jmi_func_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars & (~JMI_DER_DX), mask,
				df_n_cols, df_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_ode_derivatives(jmi_t* jmi) {

	int i, return_status;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return_status = jmi->dae->ode_derivatives(jmi);

	/* Write back evaluation result */
	if (return_status==0) {
		for (i=0;i<jmi->n_z;i++) {
			(*(jmi->z_val))[i] = (*(jmi->z))[i];
		}
		return 0;
	}
	return return_status;
}

int jmi_ode_outputs(jmi_t* jmi) {

	int i, return_status;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return_status = jmi->dae->ode_outputs(jmi);

	/* Write back evaluation result */
	if (return_status==0) {
		for (i=0;i<jmi->n_z;i++) {
			(*(jmi->z_val))[i] = (*(jmi->z))[i];
		}
		return 0;
	}
	return return_status;
}

int jmi_ode_initialize(jmi_t* jmi) {

	int i, return_status;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return_status = jmi->dae->ode_initialize(jmi);

	/* Write back evaluation result */
	if (return_status==0) {
		for (i=0;i<jmi->n_z;i++) {
			(*(jmi->z_val))[i] = (*(jmi->z))[i];
		}
		return 0;
	}
	return return_status;
}

int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	/*jmi->dae->F->F(jmi, &res);*/
	jmi_func_F(jmi,jmi->dae->F,res);

	return 0;
}

int jmi_dae_dF(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->dae->F, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_dae_dF_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->dae->F, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_dae_dF_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->dae->F, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_dae_dF_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {
		return jmi_func_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_dae_R(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	/*jmi->dae->F->F(jmi, &res);*/
	jmi_func_F(jmi,jmi->dae->R,res);

	return 0;
}

int jmi_init_F0(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}
	return jmi_func_F(jmi,jmi->init->F0,res);
}

int jmi_init_dF0(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->init->F0, sparsity,
				independent_vars, mask, jac) ;

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_init_dF0_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->init->F0, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_init_dF0_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->F0, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_init_dF0_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {
		return jmi_func_dF_dim(jmi, jmi->init->F0, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}


int jmi_init_F1(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return jmi_func_F(jmi,jmi->init->F1,res);

}

int jmi_init_dF1(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->init->F1, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_init_dF1_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->init->F1, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_init_dF1_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->F1, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_init_dF1_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->init->F1, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_init_Fp(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return jmi_func_F(jmi,jmi->init->Fp,res);

}

int jmi_init_dFp(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->init->Fp, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_init_dFp_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->init->Fp, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_init_dFp_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->Fp, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_init_dFp_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->init->Fp, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_init_eval_parameters(jmi_t* jmi) {

	int i, return_status;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return_status = jmi->init->eval_parameters(jmi);

	/* Write back evaluation result */
	if (return_status==0) {
		for (i=0;i<jmi->n_z;i++) {
			(*(jmi->z_val))[i] = (*(jmi->z))[i];
		}
		return 0;
	}
	return return_status;
}

int jmi_init_R0(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	/*jmi->dae->F->F(jmi, &res);*/
	jmi_func_F(jmi,jmi->init->R0,res);

	return 0;
}

int jmi_opt_Ffdp(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return jmi_func_F(jmi,jmi->opt->Ffdp,res);

}

int jmi_opt_dFfdp(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->opt->Ffdp, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dFfdp_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->opt->Ffdp, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dFfdp_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->opt->Ffdp, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_opt_dFfdp_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->opt->Ffdp, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}


int jmi_opt_J(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return jmi_func_F(jmi,jmi->opt->J,res);
}

int jmi_opt_dJ(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->opt->J, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dJ_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->opt->J, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dJ_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->opt->J, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_opt_dJ_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dJ_n_cols, int *dJ_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->opt->J, sparsity, independent_vars, mask,
				dJ_n_cols, dJ_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_L(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return jmi_func_F(jmi,jmi->opt->L,res);
}

int jmi_opt_dL(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->opt->L, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dL_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->opt->L, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dL_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->opt->L, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_opt_dL_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dL_n_cols, int *dL_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->opt->L, sparsity, independent_vars, mask,
				dL_n_cols, dL_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_Ceq(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}
	return jmi_func_F(jmi,jmi->opt->Ceq,res);
}

int jmi_opt_dCeq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->opt->Ceq, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dCeq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->opt->Ceq, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dCeq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->opt->Ceq, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_opt_dCeq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->opt->Ceq, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_Cineq(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	return jmi_func_F(jmi,jmi->opt->Cineq,res);
}

int jmi_opt_dCineq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->opt->Cineq, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dCineq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->opt->Cineq, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dCineq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->opt->Cineq, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_opt_dCineq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->opt->Cineq, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_Heq(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}
	return jmi_func_F(jmi,jmi->opt->Heq,res);
}

int jmi_opt_dHeq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->opt->Heq, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dHeq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->opt->Heq, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dHeq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->opt->Heq, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_opt_dHeq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->opt->Heq, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_Hineq(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}
	return jmi_func_F(jmi,jmi->opt->Hineq,res);
}

int jmi_opt_dHineq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->opt->Hineq, sparsity,
				independent_vars, mask, jac) ;


	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dHineq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->opt->Hineq, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_opt_dHineq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->opt->Hineq, independent_vars, mask, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}

}

int jmi_opt_dHineq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->opt->Hineq, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {
		return -1;
	} else {
		return -1;
	}
}

int jmi_with_cppad_derivatives()
{
	return JMI_AD_WITH_CPPAD;
}















