
#include "jmi.h"

 int jmi_ad_init(jmi_t* jmi) {

	 int i,j;

	 jmi_dae_ad_t* jdad = (jmi_dae_ad_t*)calloc(1,jmi_dae_ad_t);

	 jmi->dae->ad = jdad;

	 jdad->z_independent = new Jmi_AD_vec(jmi->n_pi);
	 jdad->F_z_dependent = new Jmi_AD_vec(jmi->dae->n_eq_F);

	 // Compute the tape for all variables.
	 // The z vector is assumed to be initialized previously by the user
	 CppAD::Independent(*jdad->z_independent);
	 jdad->F(jmi, *jdad->F_z_dependent);

	 jdad->tapes_initialized = true;

	 // Compute sparsity patterns
	 int m = jmi->dae->n_eq_F; // Number of rows in Jacobian

	 std::vector<bool> r_pi(jmi->n_z*jmi->n_z);
	 std::vector<bool> s_pi(m*jmi->n_z);
	 for (i=0;i<jmi->n_z;i++) {
			for (j=0;j<jmi->n_z;j++) {
				if(i==j) {
					r_pi[i*jmi->n_z+j] = true;
				} else{
					r_pi[i*jmi->n_z+j] = false;
				}
			}
		}

		jdad->dF_n_nz = 0;
		jdad->dF_pi_n_nz = 0;
		jdad->dF_pd_n_nz = 0;
		jdad->dF_dx_n_nz = 0;
		jdad->dF_x_n_nz = 0;
		jdad->dF_u_n_nz = 0;
		jdad->dF_w_n_nz = 0;
		jdad->dF_t_n_nz = 0;

		s_pi = jdad->F_z_tape->ForSparseJac(jmi->n_z,r_z);

		// Sort out all the individual variable vector sparsity patterns as well..
		for (i=0;i<(int)s_z.size();i++) { // cast to int since size() gives unsigned int...
			if (s_z[i]) jdad->dF_n_nz++;
		}

		jdad->dF_irow = (int*)calloc(jdad->dF_n_nz,sizeof(int));
		jdad->dF_icol = (int*)calloc(jdad->dF_n_nz,sizeof(int));

		int jac_ind = 0;
		int col_ind = 0;

		/*
		 * This is a bit tricky. The sparsity matrices s_nn are represented
		 * as vectors in row major format. In the irow icol representation it
		 * is more convenient give the elements in column major order. In particular
		 * it simplifies the implementation of the Jacobian evaluation.
		 *
		 */

		jdad->dF_irow = &jdad->jac_F_irow[jac_ind];
		jdad->jac_F_pi_icol = &jdad->jac_F_icol[jac_ind];
		for (j=0;j<jmi->jmi_dae->n_pi;j++) {
			for (i=0;i<m;i++) {
				if (s_pi[i*jmi->jmi_dae->n_pi + j]) {
					jdad->jac_F_icol[jac_ind] = j + col_ind + 1;
					jdad->jac_F_irow[jac_ind++] = i + 1;
				}
			}
		}
		col_ind += jmi->jmi_dae->n_pi;

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

		jdad->tapes_initialized = true;

	/*
		printf("%d, %d, %d, %d, %d, %d, %d, * %d, %d\n", jdad->jac_F_pi_n_nz,
				jdad->jac_F_pd_n_nz,
				jdad->jac_F_dx_n_nz,
				jdad->jac_F_x_n_nz,
				jdad->jac_F_u_n_nz,
				jdad->jac_F_w_n_nz,
				jdad->jac_F_t_n_nz,jdad->jac_F_u_icol[0],jdad->jac_F_u_icol[1]);
	*/
		/*
	  for (i=0;i<jdad->jac_n_nz;i++) {
	    printf("*** %d, %d\n",jdad->jac_irow[i],jdad->jac_icol[i]);
	  }


	  printf("*** %d\n",jdad->jac_n_nz);

	  for (i=0;i<m*jmi->jmi_dae->n_x;i++) {
	    printf("*** %d\n",s_x[i]? 1 : 0);
	  }
		 */

		return 0;

	 return 0;
 }

 int jmi_get_ci(jmi_t* jmi, jmi_real_t** ci) {
	 *ci = jmi->z + jmi->offs_ci;
	 return 0;
 }

 int jmi_get_cd(jmi_t* jmi, jmi_real_t** cd) {
	 *cd = jmi->z + jmi->offs_cd;
	 return 0;
 }

 int jmi_get_pi(jmi_t* jmi, jmi_real_t** pi) {
	 *pi = jmi->z + jmi->offs_pi;
	 return 0;
 }

 int jmi_get_pd(jmi_t* jmi, jmi_real_t** pd) {
	 *pd = jmi->z + jmi->offs_pd;
	 return 0;
 }

 int jmi_get_dx(jmi_t* jmi, jmi_real_t** dx) {
	 *dx = jmi->z + jmi->offs_dx;
	 return 0;
 }

 int jmi_get_x(jmi_t* jmi, jmi_real_t** x) {
	 *x = jmi->z + jmi->offs_x;
	 return 0;
 }

 int jmi_get_u(jmi_t* jmi, jmi_real_t** u) {
	 *u = jmi->z + jmi->offs_u;
	 return 0;
 }

 int jmi_get_w(jmi_t* jmi, jmi_real_t** w) {
	 *w = jmi->z + jmi->offs_w;
	 return 0;
 }

 int jmi_get_t(jmi_t* jmi, jmi_real_t** t) {
	 *t = jmi->z + jmi->offs_t;
	 return 0;
 }

 int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {
     jmi->dae->F(jmi, res);
	 return 0;
 }

 int jmi_dae_dF(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {
	 jmi->dae->dF(jmi, sparsity, skip, mask, jac);
	 return 0;
 }

 int jmi_dae_dF_n_nz(jmi_t* jmi, int* n_nz) {
	 *n_nz = jmi->dae->dF_n_nz;
	 return 0;
 }

 int jmi_dae_dF_nz_indices(jmi_t* jmi, int* row, int* col) {
	 int i;
	 for (i=0;i<jmi->dae->dF_n_nz;i++) {
		 row[i] = jmi->dae->dF_irow[i];
		 col[i] = jmi->dae->dF_icol[i];
	 }
	 return 0;
 }

 int jmi_dae_dF_ad(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {

	 return -1;
 }

 // Not supported in this interface
 int jmi_dae_dF_n_nz_ad(jmi_t* jmi, int* n_nz) {
	 return -1;
 }

 // Not supported in this interface
 int jmi_dae_dF_nz_indices_ad(jmi_t* jmi, int* row, int* col) {
	 return -1;
 }



// *****************************************************



/**
 * This function is intended to be used in jmi->jmi_dae->F, since the
 * function nnn_dae_F in the generated code has a function signature that
 * contains the AD types instead of doubles.
 */
static int cppad_dae_F (Jmi* jmi, jmi_real_t* res) {

	int i;

	std::vector<jmi_real_t> pi_(jmi->jmi_dae->n_pi);
	std::vector<jmi_real_t> pd_(jmi->jmi_dae->n_pd);
	std::vector<jmi_real_t> dx_(jmi->jmi_dae->n_dx);
	std::vector<jmi_real_t> x_(jmi->jmi_dae->n_x);
	std::vector<jmi_real_t> u_(jmi->jmi_dae->n_u);
	std::vector<jmi_real_t> w_(jmi->jmi_dae->n_w);
	std::vector<jmi_real_t> t_(1);

	jmi_dae_ad_t *jdad = (jmi_dae_ad_t*)(jmi->jmi_dae_der);

	// Initialize the tapes
	for (i=0;i<jmi->jmi_dae->n_ci;i++) {
		(*jdad->ci_independent)[i] = ci[i];
	}

	for (i=0;i<jmi->jmi_dae->n_cd;i++) {
		(*jdad->cd_independent)[i] = cd[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pi;i++) {
		(*jdad->pi_independent)[i] = pi[i];
		pi_[i] = pi[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pd;i++) {
		(*jdad->pd_independent)[i] = pd[i];
		pd_[i] = pd[i];
	}

	for (i=0;i<jmi->jmi_dae->n_dx;i++) {
		(*jdad->dx_independent)[i] = dx[i];
		dx_[i] = dx[i];
	}

	for (i=0;i<jmi->jmi_dae->n_x;i++) {
		(*jdad->x_independent)[i] = x[i];
		x_[i] = x[i];
	}

	for (i=0;i<jmi->jmi_dae->n_u;i++) {
		(*jdad->u_independent)[i] = u[i];
		u_[i] = u[i];
	}

	for (i=0;i<jmi->jmi_dae->n_w;i++) {
		(*jdad->w_independent)[i] = w[i];
		w_[i] = w[i];
	}

	(*jdad->t_independent)[0] = t;
	t_[0]  = t;

	std::vector<jmi_real_t> res_(jmi->jmi_dae->n_eq_F);

	// TODO: It is a bit arbitrary which tape to use. Lets use the
	// one for the states. This will be resolved if only one
	// tape is used.
	res_ = jdad->F_x_tape->Forward(0,x_);

	for (i=0;i<jmi->jmi_dae->n_eq_F;i++) {
		res[i] = res_[i];
	}

	return 0;
}

static int cppad_dae_jac_F(Jmi* jmi, jmi_real_t* ci, jmi_real_t* cd,
		jmi_real_t* pi, jmi_real_t* pd,
		jmi_real_t* dx, jmi_real_t* x, jmi_real_t* u,
		jmi_real_t* w, jmi_real_t t, int sparsity,
		int skip, int* mask, jmi_real_t* jac) {

	int i,j;

	std::vector<jmi_real_t> pi_(jmi->jmi_dae->n_pi);
	std::vector<jmi_real_t> pd_(jmi->jmi_dae->n_pd);
	std::vector<jmi_real_t> dx_(jmi->jmi_dae->n_dx);
	std::vector<jmi_real_t> x_(jmi->jmi_dae->n_x);
	std::vector<jmi_real_t> u_(jmi->jmi_dae->n_u);
	std::vector<jmi_real_t> w_(jmi->jmi_dae->n_w);
	std::vector<jmi_real_t> t_(1);

	int jac_n = jmi->jmi_dae->n_eq_F;
	int jac_m = 0;
	int col_index = 0;

	jmi_dae_ad_t *jdad = (jmi_dae_ad_t*)(jmi->jmi_dae_der);

	// Initialize the tapes
	for (i=0;i<jmi->jmi_dae->n_ci;i++) {
		(*jdad->ci_independent)[i] = ci[i];
	}

	for (i=0;i<jmi->jmi_dae->n_cd;i++) {
		(*jdad->cd_independent)[i] = cd[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pi;i++) {
		(*jdad->pi_independent)[i] = pi[i];
		pi_[i] = pi[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pd;i++) {
		(*jdad->pd_independent)[i] = pd[i];
		pd_[i] = pd[i];
	}

	for (i=0;i<jmi->jmi_dae->n_dx;i++) {
		(*jdad->dx_independent)[i] = dx[i];
		dx_[i] = dx[i];
	}

	for (i=0;i<jmi->jmi_dae->n_x;i++) {
		(*jdad->x_independent)[i] = x[i];
		x_[i] = x[i];
	}

	for (i=0;i<jmi->jmi_dae->n_u;i++) {
		(*jdad->u_independent)[i] = u[i];
		u_[i] = u[i];
	}

	for (i=0;i<jmi->jmi_dae->n_w;i++) {
		(*jdad->w_independent)[i] = w[i];
		w_[i] = w[i];
	}

	(*jdad->t_independent)[0] = t;
	t_[0]  = t;

	if (!(skip & JMI_DER_PI_SKIP)) {
		for (i=0;i<jmi->jmi_dae->n_pi;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_PD_SKIP)) {
		for (i=0;i<jmi->jmi_dae->n_pd;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_DX_SKIP)) {
		for (i=0;i<jmi->jmi_dae->n_dx;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_X_SKIP)) {
		for (i=0;i<jmi->jmi_dae->n_x;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_U_SKIP)) {
		for (i=0;i<jmi->jmi_dae->n_u;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_W_SKIP)) {
		for (i=0;i<jmi->jmi_dae->n_w;i++) {
			jac_m += mask[col_index++];
		}
	}

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	int jac_index = 0;
	col_index = 0;

	if (jdad->F_pi_tape!=NULL && !(skip & JMI_DER_PI_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jdad->F_pi_tape->Forward(0,pi_);
		std::vector<jmi_real_t> jac_(jmi->jmi_dae->n_eq_F);
		std::vector<jmi_real_t> d_pi(jmi->jmi_dae->n_pi);
		for (i=0;i<jmi->jmi_dae->n_pi;i++) {
			// check the mask if evaluation should be performed
			if (mask[col_index + i] == 1) {
				for (j=0;j<jmi->jmi_dae->n_pi;j++) {
					d_pi[j] = 0;
				}
				d_pi[i] = 1.;
				// Evaluate jacobian column
				jac_ = jdad->F_pi_tape->Forward(1,d_pi);
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_n*(col_index+i) + j] = jac_[j];
					}
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_m*j + (col_index+i)] = jac_[j];
					}
					//					}
					break;
				case JMI_DER_SPARSE:
					for(j=0;j<jdad->jac_F_pi_n_nz;j++) {
						if (jdad->jac_F_pi_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jdad->jac_F_pi_irow[j]-1];
						}
					}
				}
			}
		}
	}
	col_index += jmi->jmi_dae->n_pi;

	if (jdad->F_pd_tape!=NULL && !(skip & JMI_DER_PD_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jdad->F_pd_tape->Forward(0,pd_);
		std::vector<jmi_real_t> jac_(jmi->jmi_dae->n_eq_F);
		std::vector<jmi_real_t> d_pd(jmi->jmi_dae->n_pd);
		for (i=0;i<jmi->jmi_dae->n_pd;i++) {
			// check the mask if evaluation should be performed
			if (mask[col_index + i] == 1) {
				for (j=0;j<jmi->jmi_dae->n_pd;j++) {
					d_pd[j] = 0;
				}
				d_pd[i] = 1.;
				// Evaluate jacobian column
				jac_ = jdad->F_pd_tape->Forward(1,d_pd);
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_n*(col_index+i) + j] = jac_[j];
					}
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_m*j + (col_index+i)] = jac_[j];
					}
					break;
				case JMI_DER_SPARSE:
					for(j=0;j<jdad->jac_F_pd_n_nz;j++) {
						if (jdad->jac_F_pd_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jdad->jac_F_pd_irow[j]-1];
						}
					}
				}
			}
		}
	}
	col_index += jmi->jmi_dae->n_pd;


	if (jdad->F_dx_tape!=NULL && !(skip & JMI_DER_DX_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jdad->F_dx_tape->Forward(0,dx_);
		std::vector<jmi_real_t> jac_(jmi->jmi_dae->n_eq_F);
		std::vector<jmi_real_t> d_dx(jmi->jmi_dae->n_dx);
		for (i=0;i<jmi->jmi_dae->n_dx;i++) {
			// check the mask if evaluation should be performed
			if (mask[col_index + i] == 1) {
				for (j=0;j<jmi->jmi_dae->n_dx;j++) {
					d_dx[j] = 0;
				}
				d_dx[i] = 1.;
				// Evaluate jacobian column
				jac_ = jdad->F_dx_tape->Forward(1,d_dx);
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_n*(col_index+i) + j] = jac_[j];
					}
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_m*j + (col_index+i)] = jac_[j];
					}
					//					}
					break;
				case JMI_DER_SPARSE:
					for(j=0;j<jdad->jac_F_dx_n_nz;j++) {
						if (jdad->jac_F_dx_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jdad->jac_F_dx_irow[j]-1];

						}
					}
				}
			}
		}
	}

	col_index += jmi->jmi_dae->n_dx;

	if (jdad->F_x_tape!=NULL && !(skip & JMI_DER_X_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jdad->F_x_tape->Forward(0,x_);
		std::vector<jmi_real_t> jac_(jmi->jmi_dae->n_eq_F);
		std::vector<jmi_real_t> d_x(jmi->jmi_dae->n_x);
		for (i=0;i<jmi->jmi_dae->n_x;i++) {
			// check the mask if evaluation should be performed
			if (mask[col_index + i] == 1) {
				for (j=0;j<jmi->jmi_dae->n_x;j++) {
					d_x[j] = 0;
				}
				d_x[i] = 1.;
				// Evaluate jacobian column
				jac_ = jdad->F_x_tape->Forward(1,d_x);
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_n*(col_index+i) + j] = jac_[j];
					}
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_m*j + (col_index+i)] = jac_[j];
					}
					break;
				case JMI_DER_SPARSE:
					for(j=0;j<jdad->jac_F_x_n_nz;j++) {
						if (jdad->jac_F_x_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jdad->jac_F_x_irow[j]-1];
						}
					}
				}
			}
		}
	}

	col_index += jmi->jmi_dae->n_x;

	if (jdad->F_u_tape!=NULL && !(skip & JMI_DER_U_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jdad->F_u_tape->Forward(0,u_);
		std::vector<jmi_real_t> jac_(jmi->jmi_dae->n_eq_F);
		std::vector<jmi_real_t> d_u(jmi->jmi_dae->n_u);
		for (i=0;i<jmi->jmi_dae->n_u;i++) {
			// check the mask if evaluation should be performed
			if (mask[col_index + i] == 1) {
				for (j=0;j<jmi->jmi_dae->n_u;j++) {
					d_u[j] = 0;
				}
				d_u[i] = 1.;
				// Evaluate jacobian column
				jac_ = jdad->F_u_tape->Forward(1,d_u);
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_n*(col_index+i) + j] = jac_[j];
					}
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_m*j + (col_index+i)] = jac_[j];
					}
					break;
				case JMI_DER_SPARSE:
					for(j=0;j<jdad->jac_F_u_n_nz;j++) {
//						printf("** %d %d\n",col_index+i,jdad->jac_F_u_icol[j]-1);
						if (jdad->jac_F_u_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jdad->jac_F_u_irow[j]-1];
						}
					}
				}
			}
		}
	}

	col_index += jmi->jmi_dae->n_u;

	if (jdad->F_w_tape!=NULL && !(skip & JMI_DER_W_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jdad->F_w_tape->Forward(0,w_);
		std::vector<jmi_real_t> jac_(jmi->jmi_dae->n_eq_F);
		std::vector<jmi_real_t> d_w(jmi->jmi_dae->n_w);
		for (i=0;i<jmi->jmi_dae->n_w;i++) {
			// check the mask if evaluation should be performed
			if (mask[col_index + i] == 1) {
				for (j=0;j<jmi->jmi_dae->n_w;j++) {
					d_w[j] = 0;
				}
				d_w[i] = 1.;
				// Evaluate jacobian column
				jac_ = jdad->F_w_tape->Forward(1,d_w);
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_n*(col_index+i) + j] = jac_[j];
					}
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_m*j + (col_index+i)] = jac_[j];
					}
					break;
				case JMI_DER_SPARSE:
					for(j=0;j<jdad->jac_F_w_n_nz;j++) {
//						printf("** %d %d\n",col_index+i,jdad->jac_F_u_icol[j]-1);
						if (jdad->jac_F_w_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jdad->jac_F_w_irow[j]-1];
						}
					}
				}
			}
		}
	}

	col_index += jmi->jmi_dae->n_w;

	if (jdad->F_t_tape!=NULL && !(skip & JMI_DER_T_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jdad->F_t_tape->Forward(0,t_);
		std::vector<jmi_real_t> jac_(jmi->jmi_dae->n_eq_F);
		std::vector<jmi_real_t> d_t(1);
		for (i=0;i<1;i++) {
			// check the mask if evaluation should be performed
			if (mask[col_index + i] == 1) {
				for (j=0;j<1;j++) {
					d_t[j] = 0;
				}
				d_t[i] = 1.;
				// Evaluate jacobian column
				jac_ = jdad->F_t_tape->Forward(1,d_t);
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_n*(col_index+i) + j] = jac_[j];
					}
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					for(j=0;j<jmi->jmi_dae->n_eq_F;j++) {
						jac[jac_m*j + (col_index+i)] = jac_[j];
					}
					break;
				case JMI_DER_SPARSE:
					for(j=0;j<jdad->jac_F_t_n_nz;j++) {
//						printf("** %d %d\n",col_index+i,jdad->jac_F_u_icol[j]-1);
						if (jdad->jac_F_t_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jdad->jac_F_t_irow[j]-1];
						}
					}
				}
			}
		}
	}

	return 0;

}

static int cppad_dae_jac_F_nnz(Jmi* jmi, int* nnz) {

	jmi_dae_ad_t *jdad = (jmi_dae_ad_t*)(jmi->jmi_dae_der);

	if (jdad->tapes_initialized) {
		*nnz = jdad->jac_F_n_nz;
		return 0;
	} else {
		return -1;
	}

}

static int cppad_dae_jac_F_nz_indices(Jmi* jmi, int* row, int* col) {

	jmi_dae_ad_t *jdad = (jmi_dae_ad_t*)(jmi->jmi_dae_der);

	if (jdad->tapes_initialized) {
		int i;

		for (i=0;i<jdad->jac_F_n_nz;i++) {
			row[i] = jdad->jac_F_irow[i];
			col[i] = jdad->jac_F_icol[i];
		}

		return 0;
	} else {
		return -1;
	}

}


int jmi_cppad_init(Jmi* jmi, jmi_real_t* ci_init, jmi_real_t* cd_init,
		jmi_real_t* pi_init, jmi_real_t* pd_init,
		jmi_real_t* dx_init, jmi_real_t* x_init, jmi_real_t* u_init,
		jmi_real_t* w_init, jmi_real_t t_init) {

	int i,j;


}


int jmi_cppad_delete(Jmi* jmi) {
	jmi_dae_ad_t *jdad = (jmi_dae_ad_t*)(jmi->jmi_dae_der);
	delete jdad->ci_independent;
	delete jdad->cd_independent;
	delete jdad->pi_independent;
	delete jdad->F_pi_dependent;
	delete jdad->F_pi_tape;
	delete jdad->pd_independent;
	delete jdad->F_pd_dependent;
	delete jdad->F_pd_tape;
	delete jdad->dx_independent;
	delete jdad->F_dx_dependent;
	delete jdad->F_dx_tape;
	delete jdad->x_independent;
	delete jdad->F_x_dependent;
	delete jdad->F_x_tape;
	delete jdad->u_independent;
	delete jdad->F_u_dependent;
	delete jdad->F_u_tape;
	delete jdad->w_independent;
	delete jdad->F_w_dependent;
	delete jdad->F_w_tape;
	delete jdad->t_independent;
	delete jdad->F_t_dependent;
	delete jdad->F_t_tape;

	free(jdad);
	return 0;
}

/*
typedef struct {
  Jmi_dae_der jmi_dae_der;
  jmi_cppad_dae_F_t F;
  CppAD::ADFun<double> *pi_tape;
  CppAD::ADFun<double> *pd_tape;
  CppAD::ADFun<double> *dx_tape;
  CppAD::ADFun<double> *x_tape;
  CppAD::ADFun<double> *u_tape;
  CppAD::ADFun<double> *w_tape;
} jmi_dae_ad_t;

 */
