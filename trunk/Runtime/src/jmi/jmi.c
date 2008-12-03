/*
 * jmi.c contains pure C functions and does not support any AD functions.
 */


#include "jmi.h"

int jmi_init(jmi_t** jmi, int n_ci, int n_cd, int n_pi, int n_pd, int n_dx,
		int n_x, int n_u, int n_w) {

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

	jmi_->offs_ci = 0;
	jmi_->offs_cd = n_ci;
	jmi_->offs_pi = n_ci + n_cd;
	jmi_->offs_pd = n_ci + n_cd + n_pi;
	jmi_->offs_dx = n_ci + n_cd + n_pi + n_pd;
	jmi_->offs_x = n_ci + n_cd + n_pi + n_pd + n_dx;
	jmi_->offs_u = n_ci + n_cd + n_pi + n_pd + n_dx + n_x;
	jmi_->offs_w = n_ci + n_cd + n_pi + n_pd + n_dx + n_x + n_u;
	jmi_->offs_t = n_ci + n_cd + n_pi + n_pd + n_dx + n_x + n_u + n_w;

	jmi_->n_z = n_ci + n_cd + n_pi + n_pd + n_dx +
	n_x + n_u + n_w + 1;

	jmi_->z = (jmi_ad_var_vec_p)calloc(1,sizeof(jmi_ad_var_vec_t));
	*(jmi_->z) = (jmi_ad_var_vec_t)calloc(jmi_->n_z,sizeof(jmi_ad_var_t));

	jmi_->z_val = (jmi_real_vec_p)calloc(1,sizeof(jmi_real_t));
	*(jmi_->z_val) =  (jmi_real_vec_t)calloc(jmi_->n_z,sizeof(jmi_real_t));

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
		free(jmi->opt);
	}
	free(*(jmi->z));
	free(*(jmi->z_val));
	free(jmi->z);
	free(jmi->z_val);
	free(jmi);

	return 0;
}

int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	jmi->dae->F->F(jmi, &res);

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

int jmi_dae_dF_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->dae->F, row, col);

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

int jmi_init_F0(jmi_t* jmi, jmi_real_t* res) {

	int i;
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}

	jmi->init->F0->F(jmi, &res);

	return 0;
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

int jmi_init_dF0_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->F0, row, col);

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

	jmi->init->F1->F(jmi, &res);

	return 0;
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

int jmi_init_dF1_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->F1, row, col);

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

