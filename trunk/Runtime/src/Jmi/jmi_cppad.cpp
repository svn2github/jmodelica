
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

	    jmi_->z = *(new jmi_ad_var_vec_t(jmi_->n_z));
	    jmi_->z_val = *(new jmi_real_vec_t(jmi_->n_z));

	    return 0;
 }

 int jmi_dae_init(jmi_t* jmi, jmi_dae_F_t jmi_dae_F, int n_eq_F, jmi_dae_dF_t jmi_dae_dF,
		      int dF_n_nz, int* irow, int* icol) {

		 int i;

		// Create jmi_dae struct
		jmi_dae_t* dae = (jmi_dae_t*)calloc(1,sizeof(jmi_dae_t));
		jmi->dae = dae;

		// Set up the dae struct
	    dae->n_eq_F = n_eq_F;
	    dae->F = jmi_dae_F;
		dae->dF = jmi_dae_dF;

		dae->dF_n_nz = dF_n_nz;
		dae->dF_irow = (int*)calloc(dF_n_nz,sizeof(int));
		dae->dF_icol = (int*)calloc(dF_n_nz,sizeof(int));

		for (i=0;i<dF_n_nz;i++) {
			dae->dF_irow[i] = irow[i];
			dae->dF_icol[i] = icol[i];
		}

		dae->ad = NULL;

		return 0;
 }


int jmi_ad_init(jmi_t* jmi) {

	int i,j;

	jmi_dae_ad_t* jdad = (jmi_dae_ad_t*)calloc(1,sizeof(jmi_dae_ad_t));

	jmi->dae->ad = jdad;

	jdad->z_independent = new jmi_ad_var_vec_t(jmi->n_z);
	jdad->F_z_dependent = new jmi_ad_var_vec_t(jmi->dae->n_eq_F);

	// Compute the tape for all variables.
	// The z vector is assumed to be initialized previously by the user
	CppAD::Independent(*jdad->z_independent);
	jmi->dae->F(jmi, *jdad->F_z_dependent);
	jdad->F_z_tape = new jmi_ad_tape_t(*jdad->z_independent,*jdad->F_z_dependent);
	jdad->tape_initialized = true;

	// Compute sparsity patterns
	int m = jmi->dae->n_eq_F; // Number of rows in Jacobian

	// This matrix may become very large. May be necessary
	// to split the computations up.
	std::vector<bool> r_z(jmi->n_z*jmi->n_z);
	std::vector<bool> s_z(m*jmi->n_z);
	for (i=0;i<jmi->n_z;i++) {
		for (j=0;j<jmi->n_z;j++) {
			if(i==j) {
				r_z[i*jmi->n_z+j] = true;
			} else{
				r_z[i*jmi->n_z+j] = false;
			}
		}
	}

	// Compute the sparsity pattern
	s_z = jdad->F_z_tape->ForSparseJac(jmi->n_z,r_z);

	jdad->dF_z_n_nz = 0;
	jdad->dF_pi_n_nz = 0;
	jdad->dF_pd_n_nz = 0;
	jdad->dF_dx_n_nz = 0;
	jdad->dF_x_n_nz = 0;
	jdad->dF_u_n_nz = 0;
	jdad->dF_w_n_nz = 0;
	jdad->dF_t_n_nz = 0;

	// Sort out all the individual variable vector sparsity patterns as well..
	for (i=0;i<(int)s_z.size();i++) { // cast to int since size() gives unsigned int...
		if (s_z[i]) jdad->dF_z_n_nz++;
	}

	jdad->dF_z_irow = (int*)calloc(jdad->dF_z_n_nz,sizeof(int));
	jdad->dF_z_icol = (int*)calloc(jdad->dF_z_n_nz,sizeof(int));

	int jac_ind = 0;
	int col_ind = 0;

	/*
	 * This is a bit tricky. The sparsity matrices s_nn are represented
	 * as vectors in row major format. In the irow icol representation it
	 * is more convenient give the elements in column major order. In particular
	 * it simplifies the implementation of the Jacobian evaluation.
	 *
	 */

//	jdad->dF_irow = &jdad->jac_F_irow[jac_ind];
//	jdad->jac_F_pi_icol = &jdad->jac_F_icol[jac_ind];
	for (j=0;j<jmi->n_z;j++) {
		for (i=0;i<m;i++) {
			if (s_z[i*jmi->n_z + j]) {
				jdad->dF_z_icol[jac_ind] = j + col_ind + 1;
				jdad->dF_z_irow[jac_ind++] = i + 1;
			}
		}
	}


	/*

	jdad->jac_F_pd_irow = &jdad->jac_F_irow[jac_ind];
	jdad->jac_F_pd_icol = &jdad->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_pd;j++) {
		for (i=0;i<m;i++) {
			if (s_pd[i*jmi->jmi_dae->n_pd + j]) {
				jdad->jac_F_icol[jac_ind] = j + col_ind + 1;
				jdad->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_pd;

	jdad->jac_F_dx_irow = &jdad->jac_F_irow[jac_ind];
	jdad->jac_F_dx_icol = &jdad->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_dx;j++) {
		for (i=0;i<m;i++) {
			if (s_dx[i*jmi->jmi_dae->n_dx + j]) {
				jdad->jac_F_icol[jac_ind] = j + col_ind + 1;
				jdad->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_dx;

	jdad->jac_F_x_irow = &jdad->jac_F_irow[jac_ind];
	jdad->jac_F_x_icol = &jdad->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_x;j++) {
		for (i=0;i<m;i++) {
			if (s_x[i*jmi->jmi_dae->n_x + j]) {
				jdad->jac_F_icol[jac_ind] = j + col_ind + 1;
				jdad->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_x;

	jdad->jac_F_u_irow = &jdad->jac_F_irow[jac_ind];
	jdad->jac_F_u_icol = &jdad->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_u;j++) {
		for (i=0;i<m;i++) {
			if (s_u[i*jmi->jmi_dae->n_u + j]) {
				jdad->jac_F_icol[jac_ind] = j + col_ind + 1;
				jdad->jac_F_irow[jac_ind++] = i + 1;
				//				printf("!** %d %d\n",jdad->jac_F_u_irow[0],jdad->jac_F_u_icol[0]);
			}
		}
	}
	col_ind += jmi->jmi_dae->n_u;

	jdad->jac_F_w_irow = &jdad->jac_F_irow[jac_ind];
	jdad->jac_F_w_icol = &jdad->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_w;j++) {
		for (i=0;i<m;i++) {
			if (s_w[i*jmi->jmi_dae->n_w + j]) {
				jdad->jac_F_icol[jac_ind] = j + col_ind + 1;
				jdad->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_w;

	jdad->jac_F_t_irow = &jdad->jac_F_irow[jac_ind];
	jdad->jac_F_t_icol = &jdad->jac_F_icol[jac_ind];
	for (j=0;j<1;j++) {
		for (i=0;i<m;i++) {
			if (s_t[i*1 + j]) {
				jdad->jac_F_icol[jac_ind] = j + col_ind + 1;
				jdad->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
*/


		printf("%d, %d, %d, %d, %d, %d, %d\n", jdad->dF_pi_n_nz,
				jdad->dF_pd_n_nz,
				jdad->dF_dx_n_nz,
				jdad->dF_x_n_nz,
				jdad->dF_u_n_nz,
				jdad->dF_w_n_nz,
				jdad->dF_t_n_nz);

	  for (i=0;i<jdad->dF_z_n_nz;i++) {
	    printf("*** %d, %d\n",jdad->dF_z_irow[i],jdad->dF_z_icol[i]);
	  }


	  printf("-*** %d\n",jdad->dF_z_n_nz);

	  for (i=0;i<m*jmi->n_z;i++) {
	    printf("--*** %d\n",s_z[i]? 1 : 0);
	  }


	return 0;

}


int jmi_delete(jmi_t* jmi){
	if(jmi->dae != NULL) {
		free(jmi->dae->dF_irow);
		free(jmi->dae->dF_icol);

		//TODO: Free all the AD stuff

		free(jmi->dae);
	}
	if(jmi->init != NULL) {
		free(jmi->init);
	}
	if(jmi->opt != NULL) {
		free(jmi->opt);
	}

	delete &jmi->z;
	delete &jmi->z_val;
	free(jmi);

	return 0;
}


int jmi_get_ci(jmi_t* jmi, jmi_real_t** ci) {
	*ci = &(jmi->z_val[jmi->offs_ci]);
	return 0;
}

int jmi_get_cd(jmi_t* jmi, jmi_real_t** cd) {
	*cd = &(jmi->z_val[jmi->offs_cd]);
	return 0;
}

int jmi_get_pi(jmi_t* jmi, jmi_real_t** pi) {
	*pi = &(jmi->z_val[jmi->offs_pi]);
	return 0;
}

int jmi_get_pd(jmi_t* jmi, jmi_real_t** pd) {
	*pd = &(jmi->z_val[jmi->offs_pd]);
	return 0;
}

int jmi_get_dx(jmi_t* jmi, jmi_real_t** dx) {
	*dx = &(jmi->z_val[jmi->offs_dx]);
	return 0;
}

int jmi_get_x(jmi_t* jmi, jmi_real_t** x) {
	*x = &(jmi->z_val[jmi->offs_x]);
	return 0;
}

int jmi_get_u(jmi_t* jmi, jmi_real_t** u) {
	*u = &(jmi->z_val[jmi->offs_u]);
	return 0;
}

int jmi_get_w(jmi_t* jmi, jmi_real_t** w) {
	*w = &(jmi->z_val[jmi->offs_w]);
	return 0;
}

int jmi_get_t(jmi_t* jmi, jmi_real_t** t) {
	*t = &(jmi->z_val[jmi->offs_t]);
	return 0;
}

