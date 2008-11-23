

 int jmi_ad_init(jmi* jmi) {
	 return -1;
 }

 int jmi_get_ci(jmi* jmi, jmi_real_t** ci) {
	 *ci = &jmi->z[jmi->offs_ci];
	 return 0;
 }

 int jmi_get_cd(jmi* jmi, jmi_real_t** cd) {
	 *cd = &jmi->z[jmi->offs_cd];
	 return 0;
 }

 int jmi_get_pi(jmi* jmi, jmi_real_t** pi) {
	 *pi = &jmi->z[jmi->offs_pi];
	 return 0;
 }

 int jmi_get_pd(jmi* jmi, jmi_real_t** pd) {
	 *pd = &jmi->z[jmi->offs_pd];
	 return 0;
 }

 int jmi_get_dx(jmi* jmi, jmi_real_t** dx) {
	 *dx = &jmi->z[jmi->offs_dx];
	 return 0;
 }

 int jmi_get_x(jmi* jmi, jmi_real_t** x) {
	 *x = &jmi->z[jmi->offs_x];
	 return 0;
 }

 int jmi_get_u(jmi* jmi, jmi_real_t** u) {
	 *u = &jmi->z[jmi->offs_u];
	 return 0;
 }

 int jmi_get_w(jmi* jmi, jmi_real_t** w) {
	 *w = &jmi->z[jmi->offs_w];
	 return 0;
 }

 int jmi_get_t(jmi* jmi, jmi_real_t** t) {
	 *t = &jmi->z[jmi->offs_t];
	 return 0;
 }

 int jmi_dae_F(jmi* jmi, jmi_real_t* res) {
     jmi->dae->F(jmi, res);
	 return 0;
 }

 int jmi_dae_dF(jmi* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {
	 jmi->dae->dF(jmi, sparsity, skip, mask, jac);
	 return 0;
 }

 int jmi_dae_dF_nnz(jmi* jmi, int* n_nz) {
	 *n_nz = jmi->dae->dF_n_nz;
	 return 0;
 }

 int jmi_dae_dF_nz_indices(jmi* jmi, int* row, int* col) {
	 int i;
	 for (i=0;i<jmi->dae->dF_n_nz;i++) {
		 row[i] = jmi->dae->irow[i];
		 col[i] = jmi->dae->icol[i];
	 }
	 return 0;
 }

 int jmi_dae_dF_ad(jmi* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {

 }

 // Not supported in this interface
 int jmi_dae_dF_nnz_ad(jmi* jmi, int* n_nz) {
	 return -1;
 }

 // Not supported in this interface
 int jmi_dae_dF_nz_indices_ad(jmi* jmi, int* row, int* col) {
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

	Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);

	// Initialize the tapes
	for (i=0;i<jmi->jmi_dae->n_ci;i++) {
		(*jcdd->ci_independent)[i] = ci[i];
	}

	for (i=0;i<jmi->jmi_dae->n_cd;i++) {
		(*jcdd->cd_independent)[i] = cd[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pi;i++) {
		(*jcdd->pi_independent)[i] = pi[i];
		pi_[i] = pi[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pd;i++) {
		(*jcdd->pd_independent)[i] = pd[i];
		pd_[i] = pd[i];
	}

	for (i=0;i<jmi->jmi_dae->n_dx;i++) {
		(*jcdd->dx_independent)[i] = dx[i];
		dx_[i] = dx[i];
	}

	for (i=0;i<jmi->jmi_dae->n_x;i++) {
		(*jcdd->x_independent)[i] = x[i];
		x_[i] = x[i];
	}

	for (i=0;i<jmi->jmi_dae->n_u;i++) {
		(*jcdd->u_independent)[i] = u[i];
		u_[i] = u[i];
	}

	for (i=0;i<jmi->jmi_dae->n_w;i++) {
		(*jcdd->w_independent)[i] = w[i];
		w_[i] = w[i];
	}

	(*jcdd->t_independent)[0] = t;
	t_[0]  = t;

	std::vector<jmi_real_t> res_(jmi->jmi_dae->n_eq_F);

	// TODO: It is a bit arbitrary which tape to use. Lets use the
	// one for the states. This will be resolved if only one
	// tape is used.
	res_ = jcdd->F_x_tape->Forward(0,x_);

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

	Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);

	// Initialize the tapes
	for (i=0;i<jmi->jmi_dae->n_ci;i++) {
		(*jcdd->ci_independent)[i] = ci[i];
	}

	for (i=0;i<jmi->jmi_dae->n_cd;i++) {
		(*jcdd->cd_independent)[i] = cd[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pi;i++) {
		(*jcdd->pi_independent)[i] = pi[i];
		pi_[i] = pi[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pd;i++) {
		(*jcdd->pd_independent)[i] = pd[i];
		pd_[i] = pd[i];
	}

	for (i=0;i<jmi->jmi_dae->n_dx;i++) {
		(*jcdd->dx_independent)[i] = dx[i];
		dx_[i] = dx[i];
	}

	for (i=0;i<jmi->jmi_dae->n_x;i++) {
		(*jcdd->x_independent)[i] = x[i];
		x_[i] = x[i];
	}

	for (i=0;i<jmi->jmi_dae->n_u;i++) {
		(*jcdd->u_independent)[i] = u[i];
		u_[i] = u[i];
	}

	for (i=0;i<jmi->jmi_dae->n_w;i++) {
		(*jcdd->w_independent)[i] = w[i];
		w_[i] = w[i];
	}

	(*jcdd->t_independent)[0] = t;
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

	if (jcdd->F_pi_tape!=NULL && !(skip & JMI_DER_PI_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jcdd->F_pi_tape->Forward(0,pi_);
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
				jac_ = jcdd->F_pi_tape->Forward(1,d_pi);
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
					for(j=0;j<jcdd->jac_F_pi_n_nz;j++) {
						if (jcdd->jac_F_pi_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jcdd->jac_F_pi_irow[j]-1];
						}
					}
				}
			}
		}
	}
	col_index += jmi->jmi_dae->n_pi;

	if (jcdd->F_pd_tape!=NULL && !(skip & JMI_DER_PD_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jcdd->F_pd_tape->Forward(0,pd_);
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
				jac_ = jcdd->F_pd_tape->Forward(1,d_pd);
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
					for(j=0;j<jcdd->jac_F_pd_n_nz;j++) {
						if (jcdd->jac_F_pd_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jcdd->jac_F_pd_irow[j]-1];
						}
					}
				}
			}
		}
	}
	col_index += jmi->jmi_dae->n_pd;


	if (jcdd->F_dx_tape!=NULL && !(skip & JMI_DER_DX_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jcdd->F_dx_tape->Forward(0,dx_);
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
				jac_ = jcdd->F_dx_tape->Forward(1,d_dx);
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
					for(j=0;j<jcdd->jac_F_dx_n_nz;j++) {
						if (jcdd->jac_F_dx_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jcdd->jac_F_dx_irow[j]-1];

						}
					}
				}
			}
		}
	}

	col_index += jmi->jmi_dae->n_dx;

	if (jcdd->F_x_tape!=NULL && !(skip & JMI_DER_X_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jcdd->F_x_tape->Forward(0,x_);
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
				jac_ = jcdd->F_x_tape->Forward(1,d_x);
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
					for(j=0;j<jcdd->jac_F_x_n_nz;j++) {
						if (jcdd->jac_F_x_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jcdd->jac_F_x_irow[j]-1];
						}
					}
				}
			}
		}
	}

	col_index += jmi->jmi_dae->n_x;

	if (jcdd->F_u_tape!=NULL && !(skip & JMI_DER_U_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jcdd->F_u_tape->Forward(0,u_);
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
				jac_ = jcdd->F_u_tape->Forward(1,d_u);
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
					for(j=0;j<jcdd->jac_F_u_n_nz;j++) {
//						printf("** %d %d\n",col_index+i,jcdd->jac_F_u_icol[j]-1);
						if (jcdd->jac_F_u_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jcdd->jac_F_u_irow[j]-1];
						}
					}
				}
			}
		}
	}

	col_index += jmi->jmi_dae->n_u;

	if (jcdd->F_w_tape!=NULL && !(skip & JMI_DER_W_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jcdd->F_w_tape->Forward(0,w_);
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
				jac_ = jcdd->F_w_tape->Forward(1,d_w);
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
					for(j=0;j<jcdd->jac_F_w_n_nz;j++) {
//						printf("** %d %d\n",col_index+i,jcdd->jac_F_u_icol[j]-1);
						if (jcdd->jac_F_w_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jcdd->jac_F_w_irow[j]-1];
						}
					}
				}
			}
		}
	}

	col_index += jmi->jmi_dae->n_w;

	if (jcdd->F_t_tape!=NULL && !(skip & JMI_DER_T_SKIP)) {
		// loop over all columns
		// Evaluate the tape in forward mode
		jcdd->F_t_tape->Forward(0,t_);
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
				jac_ = jcdd->F_t_tape->Forward(1,d_t);
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
					for(j=0;j<jcdd->jac_F_t_n_nz;j++) {
//						printf("** %d %d\n",col_index+i,jcdd->jac_F_u_icol[j]-1);
						if (jcdd->jac_F_t_icol[j]-1 == col_index+i) {
							jac[jac_index++] = jac_[jcdd->jac_F_t_irow[j]-1];
						}
					}
				}
			}
		}
	}

	return 0;

}

static int cppad_dae_jac_F_nnz(Jmi* jmi, int* nnz) {

	Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);

	if (jcdd->tapes_initialized) {
		*nnz = jcdd->jac_F_n_nz;
		return 0;
	} else {
		return -1;
	}

}

static int cppad_dae_jac_F_nz_indices(Jmi* jmi, int* row, int* col) {

	Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);

	if (jcdd->tapes_initialized) {
		int i;

		for (i=0;i<jcdd->jac_F_n_nz;i++) {
			row[i] = jcdd->jac_F_irow[i];
			col[i] = jcdd->jac_F_icol[i];
		}

		return 0;
	} else {
		return -1;
	}

}

int jmi_cppad_new(Jmi* jmi, jmi_cppad_dae_F_t cppad_res_func) {

	Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)malloc(sizeof(Jmi_cppad_dae_der));
	Jmi_dae_der *jmi_dae_der = &(jcdd->jmi_dae_der);

	// TODO: Is it ok to set this here?
	jmi->jmi_dae->F = cppad_dae_F;

	jmi_dae_der->jac_F = cppad_dae_jac_F;
	jmi_dae_der->jac_F_nnz = cppad_dae_jac_F_nnz;
	jmi_dae_der->jac_F_nz_indices = cppad_dae_jac_F_nz_indices;

	jcdd->F = cppad_res_func;

	Jmi_AD_vec *ci_independent = new Jmi_AD_vec(jmi->jmi_dae->n_ci);
	jcdd->ci_independent = ci_independent;
	Jmi_AD_vec *cd_independent = new Jmi_AD_vec(jmi->jmi_dae->n_cd);
	jcdd->cd_independent = cd_independent;

	Jmi_AD_vec *pi_independent = new Jmi_AD_vec(jmi->jmi_dae->n_pi);
	Jmi_AD_vec *F_pi_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
	jcdd->pi_independent = pi_independent;
	jcdd->F_pi_dependent = F_pi_dependent;
	Jmi_AD_vec *pd_independent = new Jmi_AD_vec(jmi->jmi_dae->n_pd);
	Jmi_AD_vec *F_pd_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
	jcdd->pd_independent = pd_independent;
	jcdd->F_pd_dependent = F_pd_dependent;
	Jmi_AD_vec *dx_independent = new Jmi_AD_vec(jmi->jmi_dae->n_dx);
	Jmi_AD_vec *F_dx_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
	jcdd->dx_independent = dx_independent;
	jcdd->F_dx_dependent = F_dx_dependent;
	Jmi_AD_vec *x_independent = new Jmi_AD_vec(jmi->jmi_dae->n_x);
	Jmi_AD_vec *F_x_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
	jcdd->x_independent = x_independent;
	jcdd->F_x_dependent = F_x_dependent;
	Jmi_AD_vec *u_independent = new Jmi_AD_vec(jmi->jmi_dae->n_u);
	Jmi_AD_vec *F_u_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
	jcdd->u_independent = u_independent;
	jcdd->F_u_dependent = F_u_dependent;
	Jmi_AD_vec *w_independent = new Jmi_AD_vec(jmi->jmi_dae->n_w);
	Jmi_AD_vec *F_w_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
	jcdd->w_independent = w_independent;
	jcdd->F_w_dependent = F_w_dependent;
	Jmi_AD_vec *t_independent = new Jmi_AD_vec(1);
	Jmi_AD_vec *F_t_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
	jcdd->t_independent = t_independent;
	jcdd->F_t_dependent = F_t_dependent;

	jcdd->F_pi_tape = NULL;
	jcdd->F_pd_tape = NULL;
	jcdd->F_dx_tape = NULL;
	jcdd->F_x_tape = NULL;
	jcdd->F_u_tape = NULL;
	jcdd->F_w_tape = NULL;
	jcdd->F_t_tape = NULL;

	jcdd->tapes_initialized = false;

	// TODO: Add computation of sparsity patterns. It is probably reasonable to
	// do both steps in the computation, i.e., i) compute the sparsity pattern
	// in CppAD format and ii) transform the sparsity information into Ipopt
	// format which is more compact. It should be ok to allocate this memory here.



	jmi->jmi_dae_der = (Jmi_dae_der*)jcdd;

	return 0;
}


int jmi_cppad_init(Jmi* jmi, jmi_real_t* ci_init, jmi_real_t* cd_init,
		jmi_real_t* pi_init, jmi_real_t* pd_init,
		jmi_real_t* dx_init, jmi_real_t* x_init, jmi_real_t* u_init,
		jmi_real_t* w_init, jmi_real_t t_init) {

	int i,j;

	Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);

	// Initialize variables
	for (i=0;i<jmi->jmi_dae->n_ci;i++) {
		(*jcdd->ci_independent)[i] = ci_init[i];
	}

	for (i=0;i<jmi->jmi_dae->n_cd;i++) {
		(*jcdd->cd_independent)[i] = cd_init[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pi;i++) {
		(*jcdd->pi_independent)[i] = pi_init[i];
	}

	for (i=0;i<jmi->jmi_dae->n_pd;i++) {
		(*jcdd->pd_independent)[i] = pd_init[i];
	}

	for (i=0;i<jmi->jmi_dae->n_dx;i++) {
		(*jcdd->dx_independent)[i] = dx_init[i];
	}

	for (i=0;i<jmi->jmi_dae->n_x;i++) {
		(*jcdd->x_independent)[i] = x_init[i];
	}

	for (i=0;i<jmi->jmi_dae->n_u;i++) {
		(*jcdd->u_independent)[i] = u_init[i];
	}

	for (i=0;i<jmi->jmi_dae->n_w;i++) {
		(*jcdd->w_independent)[i] = w_init[i];
	}

	(*jcdd->t_independent)[0] = t_init;

	// Compute the tapes
	if (jmi->jmi_dae->n_pi > 0) {
		CppAD::Independent(*jcdd->pi_independent);
		jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
				*jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
				*jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->F_pi_dependent);
		jcdd->F_pi_tape = new CppAD::ADFun<double>(*jcdd->pi_independent,*jcdd->F_pi_dependent);
	}

	if (jmi->jmi_dae->n_pd > 0) {
		CppAD::Independent(*jcdd->pd_independent);
		jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
				*jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
				*jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->F_pd_dependent);
		jcdd->F_pd_tape = new CppAD::ADFun<double>(*jcdd->pd_independent,*jcdd->F_pd_dependent);
	}

	if (jmi->jmi_dae->n_dx > 0) {
		CppAD::Independent(*jcdd->dx_independent);
		jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
				*jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
				*jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->F_dx_dependent);
		jcdd->F_dx_tape = new CppAD::ADFun<double>(*jcdd->dx_independent,*jcdd->F_dx_dependent);
	}

	if (jmi->jmi_dae->n_x > 0) {
		CppAD::Independent(*jcdd->x_independent);
		jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
				*jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
				*jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->F_x_dependent);
		jcdd->F_x_tape = new CppAD::ADFun<double>(*jcdd->x_independent,*jcdd->F_x_dependent);
	}

	if (jmi->jmi_dae->n_u > 0) {
		CppAD::Independent(*jcdd->u_independent);
		jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
				*jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
				*jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->F_u_dependent);
		jcdd->F_u_tape = new CppAD::ADFun<double>(*jcdd->u_independent,*jcdd->F_u_dependent);
	}

	if (jmi->jmi_dae->n_w > 0) {
		CppAD::Independent(*jcdd->w_independent);
		jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
				*jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
				*jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->F_w_dependent);
		jcdd->F_w_tape = new CppAD::ADFun<double>(*jcdd->w_independent,*jcdd->F_w_dependent);
	}

	CppAD::Independent(*jcdd->t_independent);
	jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
			*jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
			*jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->F_t_dependent);
	jcdd->F_t_tape = new CppAD::ADFun<double>(*jcdd->t_independent,*jcdd->F_t_dependent);

	// Compute sparsity patterns
	int m = jmi->jmi_dae->n_eq_F; // Number of rows in Jacobian

	std::vector<bool> r_pi(jmi->jmi_dae->n_pi*jmi->jmi_dae->n_pi);
	std::vector<bool> s_pi(m*jmi->jmi_dae->n_pi);
	for (i=0;i<jmi->jmi_dae->n_pi;i++) {
		for (j=0;j<jmi->jmi_dae->n_pi;j++) {
			if(i==j) {
				r_pi[i*jmi->jmi_dae->n_pi+j] = true;
			} else{
				r_pi[i*jmi->jmi_dae->n_pi+j] = false;
			}
		}
	}

	std::vector<bool> r_pd(jmi->jmi_dae->n_pd*jmi->jmi_dae->n_pd);
	std::vector<bool> s_pd(m*jmi->jmi_dae->n_pd);
	for (i=0;i<jmi->jmi_dae->n_pd;i++) {
		for (j=0;j<jmi->jmi_dae->n_pd;j++) {
			if(i==j) {
				r_pd[i*jmi->jmi_dae->n_pd+j] = true;
			} else{
				r_pd[i*jmi->jmi_dae->n_pd+j] = false;
			}
		}
	}

	std::vector<bool> r_dx(jmi->jmi_dae->n_dx*jmi->jmi_dae->n_dx);
	std::vector<bool> s_dx(m*jmi->jmi_dae->n_dx);
	for (i=0;i<jmi->jmi_dae->n_dx;i++) {
		for (j=0;j<jmi->jmi_dae->n_dx;j++) {
			if(i==j) {
				r_dx[i*jmi->jmi_dae->n_dx+j] = true;
			} else{
				r_dx[i*jmi->jmi_dae->n_dx+j] = false;
			}
		}
	}


	std::vector<bool> r_x(jmi->jmi_dae->n_x*jmi->jmi_dae->n_dx);
	std::vector<bool> s_x(m*jmi->jmi_dae->n_x);
	for (i=0;i<jmi->jmi_dae->n_dx;i++) {
		for (j=0;j<jmi->jmi_dae->n_x;j++) {
			if(i==j) {
				r_x[i*jmi->jmi_dae->n_x+j] = true;
			} else{
				r_x[i*jmi->jmi_dae->n_x+j] = false;
			}
		}
	}

	std::vector<bool> r_u(jmi->jmi_dae->n_u*jmi->jmi_dae->n_u);
	std::vector<bool> s_u(m*jmi->jmi_dae->n_u);
	for (i=0;i<jmi->jmi_dae->n_u;i++) {
		for (j=0;j<jmi->jmi_dae->n_u;j++) {
			if(i==j) {
				r_u[i*jmi->jmi_dae->n_u+j] = true;
			} else{
				r_u[i*jmi->jmi_dae->n_u+j] = false;
			}
		}
	}

	std::vector<bool> r_w(jmi->jmi_dae->n_w*jmi->jmi_dae->n_w);
	std::vector<bool> s_w(m*jmi->jmi_dae->n_w);
	for (i=0;i<jmi->jmi_dae->n_w;i++) {
		for (j=0;j<jmi->jmi_dae->n_w;j++) {
			if(i==j) {
				r_u[i*jmi->jmi_dae->n_w+j] = true;
			} else{
				r_u[i*jmi->jmi_dae->n_w+j] = false;
			}
		}
	}

	std::vector<bool> r_t(1);
	std::vector<bool> s_t(m);
	for (i=0;i<m;i++) {
		for (j=0;j<1;j++) {
			if(i==j) {
				r_t[i*1+j] = true;
			} else{
				r_t[i*1+j] = false;
			}
		}
	}

	jcdd->jac_F_n_nz = 0;
	jcdd->jac_F_pi_n_nz = 0;
	jcdd->jac_F_pd_n_nz = 0;
	jcdd->jac_F_dx_n_nz = 0;
	jcdd->jac_F_x_n_nz = 0;
	jcdd->jac_F_u_n_nz = 0;
	jcdd->jac_F_w_n_nz = 0;
	jcdd->jac_F_t_n_nz = 0;

	if (jmi->jmi_dae->n_pi > 0) {
		s_pi = jcdd->F_pi_tape->ForSparseJac(jmi->jmi_dae->n_pi,r_pi);
	}

	if (jmi->jmi_dae->n_pd > 0) {
		s_pd = jcdd->F_pd_tape->ForSparseJac(jmi->jmi_dae->n_pd,r_pd);
	}

	if (jmi->jmi_dae->n_dx > 0) {
		s_dx = jcdd->F_dx_tape->ForSparseJac(jmi->jmi_dae->n_dx,r_dx);
	}

	if (jmi->jmi_dae->n_x > 0) {
		s_x = jcdd->F_x_tape->ForSparseJac(jmi->jmi_dae->n_x,r_x);
	}

	if (jmi->jmi_dae->n_u > 0) {
		s_u = jcdd->F_u_tape->ForSparseJac(jmi->jmi_dae->n_u,r_u);
	}

	if (jmi->jmi_dae->n_w > 0) {
		s_w = jcdd->F_w_tape->ForSparseJac(jmi->jmi_dae->n_w,r_w);
	}

	s_t = jcdd->F_t_tape->ForSparseJac(1,r_t);

	for (i=0;i<(int)s_pi.size();i++) { // cast to int since size() gives unsigned int...
		if (s_pi[i]) jcdd->jac_F_pi_n_nz++;
	}

	for (i=0;i<(int)s_pd.size();i++) {
		if (s_pd[i]) jcdd->jac_F_pd_n_nz++;
	}

	for (i=0;i<(int)s_dx.size();i++) {
		if (s_dx[i]) jcdd->jac_F_dx_n_nz++;
	}

	for (i=0;i<(int)s_x.size();i++) {
		if (s_x[i]) jcdd->jac_F_x_n_nz++;
	}

	for (i=0;i<(int)s_u.size();i++) {
		if (s_u[i]) jcdd->jac_F_u_n_nz++;
	}

	for (i=0;i<(int)s_w.size();i++) {
		if (s_w[i]) jcdd->jac_F_w_n_nz++;
	}

	for (i=0;i<(int)s_t.size();i++) {
		if (s_t[i]) jcdd->jac_F_t_n_nz++;
	}

	jcdd->jac_F_n_nz = jcdd->jac_F_pi_n_nz + jcdd->jac_F_pd_n_nz + jcdd->jac_F_dx_n_nz +
	jcdd->jac_F_x_n_nz + jcdd->jac_F_u_n_nz + jcdd->jac_F_w_n_nz + jcdd->jac_F_t_n_nz;

	jcdd->jac_F_irow = (int*)calloc(jcdd->jac_F_n_nz,sizeof(int));
	jcdd->jac_F_icol = (int*)calloc(jcdd->jac_F_n_nz,sizeof(int));

	int jac_ind = 0;
	int col_ind = 0;

	/*
	 * This is a bit tricky. The sparsity matrices s_nn are represented
	 * as vectors in row major format. In the irow icol representation it
	 * is more convenient give the elements in column major order. In particular
	 * it simplifies the implementation of the Jacobian evaluation.
	 *
	 */

	jcdd->jac_F_pi_irow = &jcdd->jac_F_irow[jac_ind];
	jcdd->jac_F_pi_icol = &jcdd->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_pi;j++) {
		for (i=0;i<m;i++) {
			if (s_pi[i*jmi->jmi_dae->n_pi + j]) {
				jcdd->jac_F_icol[jac_ind] = j + col_ind + 1;
				jcdd->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_pi;

	jcdd->jac_F_pd_irow = &jcdd->jac_F_irow[jac_ind];
	jcdd->jac_F_pd_icol = &jcdd->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_pd;j++) {
		for (i=0;i<m;i++) {
			if (s_pd[i*jmi->jmi_dae->n_pd + j]) {
				jcdd->jac_F_icol[jac_ind] = j + col_ind + 1;
				jcdd->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_pd;

	jcdd->jac_F_dx_irow = &jcdd->jac_F_irow[jac_ind];
	jcdd->jac_F_dx_icol = &jcdd->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_dx;j++) {
		for (i=0;i<m;i++) {
			if (s_dx[i*jmi->jmi_dae->n_dx + j]) {
				jcdd->jac_F_icol[jac_ind] = j + col_ind + 1;
				jcdd->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_dx;

	jcdd->jac_F_x_irow = &jcdd->jac_F_irow[jac_ind];
	jcdd->jac_F_x_icol = &jcdd->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_x;j++) {
		for (i=0;i<m;i++) {
			if (s_x[i*jmi->jmi_dae->n_x + j]) {
				jcdd->jac_F_icol[jac_ind] = j + col_ind + 1;
				jcdd->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_x;

	jcdd->jac_F_u_irow = &jcdd->jac_F_irow[jac_ind];
	jcdd->jac_F_u_icol = &jcdd->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_u;j++) {
		for (i=0;i<m;i++) {
			if (s_u[i*jmi->jmi_dae->n_u + j]) {
				jcdd->jac_F_icol[jac_ind] = j + col_ind + 1;
				jcdd->jac_F_irow[jac_ind++] = i + 1;
//				printf("!** %d %d\n",jcdd->jac_F_u_irow[0],jcdd->jac_F_u_icol[0]);
			}
		}
	}
	col_ind += jmi->jmi_dae->n_u;

	jcdd->jac_F_w_irow = &jcdd->jac_F_irow[jac_ind];
	jcdd->jac_F_w_icol = &jcdd->jac_F_icol[jac_ind];
	for (j=0;j<jmi->jmi_dae->n_w;j++) {
		for (i=0;i<m;i++) {
			if (s_w[i*jmi->jmi_dae->n_w + j]) {
				jcdd->jac_F_icol[jac_ind] = j + col_ind + 1;
				jcdd->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}
	col_ind += jmi->jmi_dae->n_w;

	jcdd->jac_F_t_irow = &jcdd->jac_F_irow[jac_ind];
	jcdd->jac_F_t_icol = &jcdd->jac_F_icol[jac_ind];
	for (j=0;j<1;j++) {
		for (i=0;i<m;i++) {
			if (s_t[i*1 + j]) {
				jcdd->jac_F_icol[jac_ind] = j + col_ind + 1;
				jcdd->jac_F_irow[jac_ind++] = i + 1;
			}
		}
	}

	jcdd->tapes_initialized = true;

/*
	printf("%d, %d, %d, %d, %d, %d, %d, * %d, %d\n", jcdd->jac_F_pi_n_nz,
			jcdd->jac_F_pd_n_nz,
			jcdd->jac_F_dx_n_nz,
			jcdd->jac_F_x_n_nz,
			jcdd->jac_F_u_n_nz,
			jcdd->jac_F_w_n_nz,
			jcdd->jac_F_t_n_nz,jcdd->jac_F_u_icol[0],jcdd->jac_F_u_icol[1]);
*/
	/*
  for (i=0;i<jcdd->jac_n_nz;i++) {
    printf("*** %d, %d\n",jcdd->jac_irow[i],jcdd->jac_icol[i]);
  }


  printf("*** %d\n",jcdd->jac_n_nz);

  for (i=0;i<m*jmi->jmi_dae->n_x;i++) {
    printf("*** %d\n",s_x[i]? 1 : 0);
  }
	 */

	return 0;
}


int jmi_cppad_delete(Jmi* jmi) {
	Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);
	delete jcdd->ci_independent;
	delete jcdd->cd_independent;
	delete jcdd->pi_independent;
	delete jcdd->F_pi_dependent;
	delete jcdd->F_pi_tape;
	delete jcdd->pd_independent;
	delete jcdd->F_pd_dependent;
	delete jcdd->F_pd_tape;
	delete jcdd->dx_independent;
	delete jcdd->F_dx_dependent;
	delete jcdd->F_dx_tape;
	delete jcdd->x_independent;
	delete jcdd->F_x_dependent;
	delete jcdd->F_x_tape;
	delete jcdd->u_independent;
	delete jcdd->F_u_dependent;
	delete jcdd->F_u_tape;
	delete jcdd->w_independent;
	delete jcdd->F_w_dependent;
	delete jcdd->F_w_tape;
	delete jcdd->t_independent;
	delete jcdd->F_t_dependent;
	delete jcdd->F_t_tape;

	free(jcdd);
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
} Jmi_cppad_dae_der;

 */
