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

int jmi_init(jmi_t** jmi, int n_ci, int n_cd, int n_pi, int n_pd, int n_dx,
		int n_x, int n_u, int n_w, int n_tp, int n_sw, int n_sw_init) {

	// Create jmi struct
	*jmi = (jmi_t*)calloc(1,sizeof(jmi_t));
	jmi_t* jmi_ = *jmi;
	// Set struct pointers in jmi
	jmi_->dae = NULL;
	jmi_->init = NULL;
	jmi_->opt = NULL;

	// Set sizes of dae vectors
	jmi_->n_ci = n_ci;
	jmi_->n_cd = n_cd;
	jmi_->n_pi = n_pi;
	jmi_->n_pd = n_pd;
	jmi_->n_dx = n_dx;
	jmi_->n_x = n_x;
	jmi_->n_u = n_u;
	jmi_->n_w = n_w;
	jmi_->n_sw = n_sw;
	jmi_->n_sw_init = n_sw_init;

	jmi_->n_tp = n_tp;

	jmi_->offs_ci = 0;
	jmi_->offs_cd = n_ci;
	jmi_->offs_pi = n_ci + n_cd;
	jmi_->offs_pd = n_ci + n_cd + n_pi;
	jmi_->offs_dx = n_ci + n_cd + n_pi + n_pd;
	jmi_->offs_x = n_ci + n_cd + n_pi + n_pd + n_dx;
	jmi_->offs_u = n_ci + n_cd + n_pi + n_pd + n_dx + n_x;
	jmi_->offs_w = n_ci + n_cd + n_pi + n_pd + n_dx + n_x + n_u;
	jmi_->offs_t = n_ci + n_cd + n_pi + n_pd + n_dx + n_x + n_u + n_w;
	jmi_->offs_dx_p = jmi_->offs_t + (n_tp>0? 1: 0);
	jmi_->offs_x_p = jmi_->offs_dx_p + (n_tp>0? n_dx: 0);
	jmi_->offs_u_p = jmi_->offs_x_p + (n_tp>0? n_x: 0);
	jmi_->offs_w_p = jmi_->offs_u_p + (n_tp>0? n_u: 0);
	jmi_->offs_sw = jmi_->offs_t + 1 + (n_dx + n_x + n_w + n_u)*n_tp + (n_sw>0? 1: 0);
	jmi_->offs_sw_init = jmi_->offs_sw + n_sw;

	jmi_->offs_p = 0;
	jmi_->offs_v = jmi_->offs_dx;
	if (n_tp>0) {
		jmi_->offs_q = jmi_->offs_t + 1;
	} else {
		jmi_->offs_q = jmi_->offs_t;
	}

	jmi_->n_p = n_ci + n_cd + n_pi + n_pd;
	jmi_->n_v = n_dx + n_x + n_u + n_w + 1;
	jmi_->n_q = (n_dx + n_x + n_u + n_w)*n_tp;

	jmi_->n_z = jmi_->n_p + jmi_->n_v + jmi_->n_q + n_sw + n_sw_init;

	jmi_->z = (jmi_ad_var_vec_p)calloc(1,sizeof(jmi_ad_var_vec_t));
	*(jmi_->z) = (jmi_ad_var_vec_t)calloc(jmi_->n_z,sizeof(jmi_ad_var_t));

	jmi_->z_val = (jmi_real_vec_p)calloc(1, sizeof(jmi_real_t *));
	*(jmi_->z_val) =  (jmi_real_vec_t)calloc(jmi_->n_z,sizeof(jmi_real_t));

	jmi_->tp = (jmi_real_t*)calloc(jmi_->n_tp,sizeof(jmi_real_t));

	return 0;

}

int jmi_ad_init(jmi_t* jmi) {
	return -1;
}

int jmi_delete(jmi_t* jmi){
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
		jmi_func_delete(jmi->opt->J);
		jmi_func_delete(jmi->opt->Ceq);
		jmi_func_delete(jmi->opt->Cineq);
		jmi_func_delete(jmi->opt->Heq);
		jmi_func_delete(jmi->opt->Hineq);
		free(jmi->opt);
	}
	free(*(jmi->z));
	free(*(jmi->z_val));
	free(jmi->z);
	free(jmi->z_val);
	free(jmi);

	return 0;
}

int jmi_func_F(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res) {
	return func->F(jmi,&res);
}

int jmi_ode_f(jmi_t* jmi) {

	if (jmi->n_w != 0) { // Check if not ODE
		return -1;
	}

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	jmi_real_t* dx = jmi_get_dx(jmi);
	for(i=0;i<jmi->n_dx;i++) {
		dx[i]=0;
	}

	jmi_real_t* dx_res = calloc(jmi->n_x,sizeof(jmi_real_t));

	//jmi->dae->F->F(jmi, &res);
	jmi_func_F(jmi,jmi->dae->F,dx_res);

	for(i=0;i<jmi->n_dx;i++) {
		dx[i]=dx_res[i];
	}

	free(dx_res);

	return 0;
}

int jmi_ode_df(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	if (jmi->n_w != 0) { // Check if not ODE
		return -1;
	}

	if (eval_alg & JMI_DER_SYMBOLIC) {

		int i;
		jmi_real_t* dx = jmi_get_dx(jmi);
		for(i=0;i<jmi->n_dx;i++) {
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

	if (jmi->n_w != 0) { // Check if not ODE
		return -1;
	}

	if (eval_alg & JMI_DER_SYMBOLIC) {
        int df_n_cols;
        int* mask = calloc(jmi->n_z,sizeof(int));
        int i;
        for (i=0;i<jmi->n_z;i++) {
        	mask[i] = 1;
        }
		int ret_val =  jmi_func_dF_dim(jmi, jmi->dae->F, JMI_DER_SPARSE,
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

	if (jmi->n_w != 0) { // Check if not ODE
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

	if (jmi->n_w != 0) { // Check if not ODE
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

int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	//jmi->dae->F->F(jmi, &res);
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

	//jmi->dae->F->F(jmi, &res);
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

int jmi_init_R0(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	//jmi->dae->F->F(jmi, &res);
	jmi_func_F(jmi,jmi->init->R0,res);

	return 0;
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















