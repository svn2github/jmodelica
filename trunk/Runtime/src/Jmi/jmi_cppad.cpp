
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

  jmi_->z = new jmi_ad_var_vec_t(jmi_->n_z);
  jmi_->z_val = new jmi_real_vec_t(jmi_->n_z);
  int i;
  for (i=0;i<jmi_->n_z;i++) {
    (*(jmi_->z))[i] = 0;
    (*(jmi_->z_val))[i] = 0;
  }

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

  jdad->F_z_dependent = new jmi_ad_var_vec_t(jmi->dae->n_eq_F);

  // Compute the tape for all variables.
  // The z vector is assumed to be initialized previously by the user

  // Copy user's value into jmi->z
  for (i=0;i<jmi->n_z;i++) {
    (*(jmi->z))[i] = (*(jmi->z_val))[i];
  }
  CppAD::Independent(*jmi->z);
  jmi->dae->F(jmi, jdad->F_z_dependent);
  jdad->F_z_tape = new jmi_ad_tape_t(*jmi->z,*jdad->F_z_dependent);
  jdad->tape_initialized = true;

  // Compute sparsity patterns
  int m = jmi->dae->n_eq_F; // Number of rows in Jacobian

  // This matrix may become very large. May be necessary
  // to split the computation.
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
  jdad->dF_ci_n_nz = 0;
  jdad->dF_cd_n_nz = 0;
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

  for (j=0;j<jmi->n_z;j++) {
    for (i=0;i<m;i++) {
      if (s_z[i*jmi->n_z + j]) {
	jdad->dF_z_icol[jac_ind] = j + col_ind + 1;
	jdad->dF_z_irow[jac_ind++] = i + 1;
      }
    }
  }

  for(i=0;i<jdad->dF_z_n_nz;i++) {
    if (jdad->dF_z_icol[i]-1 < jmi->offs_cd) {
      jdad->dF_ci_n_nz++;
    } else if (jdad->dF_z_icol[i]-1 >= jmi->offs_cd &&
               jdad->dF_z_icol[i]-1 < jmi->offs_pi) {
      jdad->dF_cd_n_nz++;
    } else if (jdad->dF_z_icol[i]-1 >= jmi->offs_pi &&
               jdad->dF_z_icol[i]-1 < jmi->offs_pd) {
      jdad->dF_pi_n_nz++;
    } else if (jdad->dF_z_icol[i]-1 >= jmi->offs_pd &&
               jdad->dF_z_icol[i]-1 < jmi->offs_dx) {
      jdad->dF_pd_n_nz++;
    } else if (jdad->dF_z_icol[i]-1 >= jmi->offs_dx &&
               jdad->dF_z_icol[i]-1 < jmi->offs_x) {
      jdad->dF_dx_n_nz++;
    } else if (jdad->dF_z_icol[i]-1 >= jmi->offs_x &&
               jdad->dF_z_icol[i]-1 < jmi->offs_u) {
      jdad->dF_x_n_nz++;
    } else if (jdad->dF_z_icol[i]-1 >= jmi->offs_u &&
               jdad->dF_z_icol[i]-1 < jmi->offs_w) {
      jdad->dF_u_n_nz++;
    } else if (jdad->dF_z_icol[i]-1 >= jmi->offs_w &&
               jdad->dF_z_icol[i]-1 < jmi->offs_t) {
      jdad->dF_w_n_nz++;
    } else if (jdad->dF_z_icol[i]-1 >= jmi->offs_t) {
      jdad->dF_t_n_nz++;
    }

  }

  jdad->dF_ci_irow = (int*)calloc(jdad->dF_ci_n_nz,sizeof(int));
  jdad->dF_ci_icol = (int*)calloc(jdad->dF_ci_n_nz,sizeof(int));
  jdad->dF_cd_irow = (int*)calloc(jdad->dF_cd_n_nz,sizeof(int));
  jdad->dF_cd_icol = (int*)calloc(jdad->dF_cd_n_nz,sizeof(int));
  jdad->dF_pi_irow = (int*)calloc(jdad->dF_pi_n_nz,sizeof(int));
  jdad->dF_pi_icol = (int*)calloc(jdad->dF_pi_n_nz,sizeof(int));
  jdad->dF_pd_irow = (int*)calloc(jdad->dF_pd_n_nz,sizeof(int));
  jdad->dF_pd_icol = (int*)calloc(jdad->dF_pd_n_nz,sizeof(int));
  jdad->dF_dx_irow = (int*)calloc(jdad->dF_dx_n_nz,sizeof(int));
  jdad->dF_dx_icol = (int*)calloc(jdad->dF_dx_n_nz,sizeof(int));
  jdad->dF_x_irow = (int*)calloc(jdad->dF_x_n_nz,sizeof(int));
  jdad->dF_x_icol = (int*)calloc(jdad->dF_x_n_nz,sizeof(int));
  jdad->dF_u_irow = (int*)calloc(jdad->dF_u_n_nz,sizeof(int));
  jdad->dF_u_icol = (int*)calloc(jdad->dF_u_n_nz,sizeof(int));
  jdad->dF_w_irow = (int*)calloc(jdad->dF_w_n_nz,sizeof(int));
  jdad->dF_w_icol = (int*)calloc(jdad->dF_w_n_nz,sizeof(int));
  jdad->dF_t_irow = (int*)calloc(jdad->dF_t_n_nz,sizeof(int));
  jdad->dF_t_icol = (int*)calloc(jdad->dF_t_n_nz,sizeof(int));

  jac_ind = 0;
  for(i=0;i<jdad->dF_ci_n_nz;i++) {
    jdad->dF_ci_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_ci_irow[i] = jdad->dF_z_irow[jac_ind++];
  }
  for(i=0;i<jdad->dF_cd_n_nz;i++) {
    jdad->dF_cd_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_cd_irow[i] = jdad->dF_z_irow[jac_ind++];
  }
  for(i=0;i<jdad->dF_pi_n_nz;i++) {
    jdad->dF_pi_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_pi_irow[i] = jdad->dF_z_irow[jac_ind++];
  }
  for(i=0;i<jdad->dF_pd_n_nz;i++) {
    jdad->dF_pd_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_pd_irow[i] = jdad->dF_z_irow[jac_ind++];
  }
  for(i=0;i<jdad->dF_dx_n_nz;i++) {
    jdad->dF_dx_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_dx_irow[i] = jdad->dF_z_irow[jac_ind++];
  }
  for(i=0;i<jdad->dF_x_n_nz;i++) {
    jdad->dF_x_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_x_irow[i] = jdad->dF_z_irow[jac_ind++];
  }
  for(i=0;i<jdad->dF_u_n_nz;i++) {
    jdad->dF_u_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_u_irow[i] = jdad->dF_z_irow[jac_ind++];
  }
  for(i=0;i<jdad->dF_w_n_nz;i++) {
    jdad->dF_w_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_w_irow[i] = jdad->dF_z_irow[jac_ind++];
  }
  for(i=0;i<jdad->dF_t_n_nz;i++) {
    jdad->dF_t_icol[i] = jdad->dF_z_icol[jac_ind];
    jdad->dF_t_irow[i] = jdad->dF_z_irow[jac_ind++];
  }

  /*
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
  for (i=0;i<jdad->dF_ci_n_nz;i++) {
    printf("*** ci: %d, %d\n",jdad->dF_ci_irow[i],jdad->dF_ci_icol[i]);
  }
  for (i=0;i<jdad->dF_cd_n_nz;i++) {
    printf("*** cd: %d, %d\n",jdad->dF_cd_irow[i],jdad->dF_cd_icol[i]);
  }
  for (i=0;i<jdad->dF_pi_n_nz;i++) {
    printf("*** pi: %d, %d\n",jdad->dF_pi_irow[i],jdad->dF_pi_icol[i]);
  }
  for (i=0;i<jdad->dF_pd_n_nz;i++) {
    printf("*** pd: %d, %d\n",jdad->dF_pd_irow[i],jdad->dF_pd_icol[i]);
  }
  for (i=0;i<jdad->dF_dx_n_nz;i++) {
    printf("*** dx: %d, %d\n",jdad->dF_dx_irow[i],jdad->dF_dx_icol[i]);
  }
  for (i=0;i<jdad->dF_x_n_nz;i++) {
    printf("*** x: %d, %d\n",jdad->dF_x_irow[i],jdad->dF_x_icol[i]);
  }
  for (i=0;i<jdad->dF_u_n_nz;i++) {
    printf("*** u: %d, %d\n",jdad->dF_u_irow[i],jdad->dF_u_icol[i]);
  }
  for (i=0;i<jdad->dF_w_n_nz;i++) {
    printf("*** w: %d, %d\n",jdad->dF_w_irow[i],jdad->dF_w_icol[i]);
  }
  for (i=0;i<jdad->dF_t_n_nz;i++) {
    printf("*** t: %d, %d\n",jdad->dF_t_irow[i],jdad->dF_t_icol[i]);
  }

  printf("-*** %d\n",jdad->dF_z_n_nz);

  for (i=0;i<m*jmi->n_z;i++) {
    printf("--*** %d\n",s_z[i]? 1 : 0);
  }
  */

  //jdad->res_w = new jmi_real_vec_t(jmi->dae->n_eq_F);

  return 0;

}

int jmi_delete(jmi_t* jmi){
	/*
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
*/
  return 0;
}

/*
 * This strategy may be a bit risky: pointers to
 * memory allocated by a vector oject is given
 * to users. Pros: Less copying of memory. Cons:
 * the vector object must not be resized etc.
 */
int jmi_get_ci(jmi_t* jmi, jmi_real_t** ci) {
  *ci = &((*(jmi->z_val))[jmi->offs_ci]);
  return 0;
}

int jmi_get_cd(jmi_t* jmi, jmi_real_t** cd) {
  *cd = &((*(jmi->z_val))[jmi->offs_cd]);
  return 0;
}

int jmi_get_pi(jmi_t* jmi, jmi_real_t** pi) {
  *pi = &((*(jmi->z_val))[jmi->offs_pi]);
  return 0;
}

int jmi_get_pd(jmi_t* jmi, jmi_real_t** pd) {
  *pd = &((*(jmi->z_val))[jmi->offs_pd]);
  return 0;
}

int jmi_get_dx(jmi_t* jmi, jmi_real_t** dx) {
  *dx = &((*(jmi->z_val))[jmi->offs_dx]);
  return 0;
}

int jmi_get_x(jmi_t* jmi, jmi_real_t** x) {
  *x = &((*(jmi->z_val))[jmi->offs_x]);
  return 0;
}

int jmi_get_u(jmi_t* jmi, jmi_real_t** u) {
  *u = &((*(jmi->z_val))[jmi->offs_u]);
  return 0;
}

int jmi_get_w(jmi_t* jmi, jmi_real_t** w) {
  *w = &((*(jmi->z_val))[jmi->offs_w]);
  return 0;
}

int jmi_get_t(jmi_t* jmi, jmi_real_t** t) {
  *t = &((*(jmi->z_val))[jmi->offs_t]);
  return 0;
}

int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {
	int i;
	// No need to copy anything: jmi->z_val is used for evaluation.
	// This may have to change, however.

	// TODO: In this operation the intermediate residual storage res_w
	// is allocated upon every call. Is there a way to avoid this?
	jmi_real_vec_t res_w = jmi->dae->ad->F_z_tape->Forward(0,*jmi->z_val);
	for(i=0;i<jmi->dae->n_eq_F;i++) {
		res[i] = res_w[i];
	}

	return 0;
}


int jmi_dae_dF(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {
	if (jmi->dae->dF==NULL) {
		return -1;
	}
	jmi->dae->dF(jmi, sparsity, skip, mask, jac);
	return 0;
}

int jmi_dae_dF_n_nz(jmi_t* jmi, int* n_nz) {
	if (jmi->dae->dF==NULL) {
		return -1;
	}
	*n_nz = jmi->dae->dF_n_nz;
	return 0;
}

int jmi_dae_dF_nz_indices(jmi_t* jmi, int* row, int* col) {
	if (jmi->dae->dF==NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi->dae->dF_n_nz;i++) {
		row[i] = jmi->dae->dF_irow[i];
		col[i] = jmi->dae->dF_icol[i];
	}
	return 0;
}

int jmi_dae_dF_dim(jmi_t* jmi, int sparsity, int skip, int *mask,
		             int *dF_n_cols, int *dF_n_nz) {
	if (jmi->dae->dF==NULL) {
		return -1;
	}

	*dF_n_cols = 0;
	*dF_n_nz = 0;

	int i,j;
	int col_index = 0;

	if (!(skip & JMI_DER_CI_SKIP)) {
		for (i=0;i<jmi->n_ci;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_ci;
	}
	if (!(skip & JMI_DER_CD_SKIP)) {
		for (i=0;i<jmi->n_cd;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_ci;
	}
	if (!(skip & JMI_DER_PI_SKIP)) {
		for (i=0;i<jmi->n_pi;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_pi;
	}
	if (!(skip & JMI_DER_PD_SKIP)) {
		for (i=0;i<jmi->n_pd;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_pd;
	}
	if (!(skip & JMI_DER_DX_SKIP)) {
		for (i=0;i<jmi->n_dx;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_dx;
	}

	if (!(skip & JMI_DER_X_SKIP)) {
		for (i=0;i<jmi->n_x;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_x;
	}

	if (!(skip & JMI_DER_U_SKIP)) {
		for (i=0;i<jmi->n_u;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_u;
	}
	if (!(skip & JMI_DER_W_SKIP)) {
		for (i=0;i<jmi->n_w;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_w;
	}
	if (!(skip & JMI_DER_T_SKIP)) {
		for (i=0;i<1;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->dF_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->dF_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	}

	return 0;
}


#define JMI_DAE_COMPUTE_DF_PART(skip_mask, n_vars, dF_var_n_nz, dF_var_irow, dF_var_icol) {                               \
if (!(skip & skip_mask)) {                                                      \
	/* loop over all columns*/                                                         \
                                                                                     \
	for (i=0;i<n_vars;i++) {                                                      \
		/*  check the mask if evaluation should be performed */                      \
		if (mask[col_index + i] == 1) {                                             \
			for (j=0;j<jmi->n_z;j++) {                                               \
				d_z[j] = 0;                                                            \
			}                                                                      \
			d_z[col_index + i] = 1.;                                             \
			/* Evaluate jacobian column */ \
			jac_ = jmi->dae->ad->F_z_tape->Forward(1,d_z);  \
			switch (sparsity) {  \
			case JMI_DER_DENSE_COL_MAJOR: \
				for(j=0;j<jmi->dae->n_eq_F;j++) { \
					jac[jac_n*(col_index+i) + j] = jac_[j]; \
				} \
				break; \
			case JMI_DER_DENSE_ROW_MAJOR: \
				for(j=0;j<jmi->dae->n_eq_F;j++) { \
					jac[jac_m*j + (col_index+i)] = jac_[j]; \
				} \
				break; \
			case JMI_DER_SPARSE:\
				for(j=0;j<dF_var_n_nz;j++) { \
					if (dF_var_icol[j]-1 == col_index+i) { \
						jac[jac_index++] = jac_[dF_var_irow[j]-1]; \
					} \
				}\
			} \
		} \
	}\
} \
col_index += n_vars;\
}\


int jmi_dae_dF_ad(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {
	if (jmi->dae->ad==NULL) {
		return -1;
	}

	int i,j;

	int jac_index = 0;
	int col_index = 0;
	int jac_n = jmi->dae->n_eq_F;

	int jac_m;
	int jac_n_nz;
	jmi_dae_dF_dim_ad(jmi,sparsity,skip,mask,&jac_m,&jac_n_nz);

	printf("****** %d\n",jac_m);

	jmi_real_vec_t jac_(jmi->dae->n_eq_F);
	jmi_real_vec_t d_z(jmi->n_z);

	// Evaluate the tape for the current z-values
	jmi->dae->ad->F_z_tape->Forward(0,*jmi->z_val);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	JMI_DAE_COMPUTE_DF_PART(skip, jmi->n_ci, jmi->dae->ad->dF_ci_n_nz,jmi->dae->ad->dF_ci_irow, jmi->dae->ad->dF_ci_icol)
	JMI_DAE_COMPUTE_DF_PART(skip, jmi->n_cd, jmi->dae->ad->dF_cd_n_nz,jmi->dae->ad->dF_cd_irow, jmi->dae->ad->dF_cd_icol)
	JMI_DAE_COMPUTE_DF_PART(skip, jmi->n_pi, jmi->dae->ad->dF_pi_n_nz,jmi->dae->ad->dF_pi_irow, jmi->dae->ad->dF_pi_icol)
	JMI_DAE_COMPUTE_DF_PART(skip, jmi->n_pd, jmi->dae->ad->dF_pd_n_nz,jmi->dae->ad->dF_pd_irow, jmi->dae->ad->dF_pd_icol)
    JMI_DAE_COMPUTE_DF_PART(skip, jmi->n_dx, jmi->dae->ad->dF_dx_n_nz,jmi->dae->ad->dF_dx_irow, jmi->dae->ad->dF_dx_icol)
    JMI_DAE_COMPUTE_DF_PART(skip, jmi->n_x, jmi->dae->ad->dF_x_n_nz,jmi->dae->ad->dF_x_irow, jmi->dae->ad->dF_x_icol)
    JMI_DAE_COMPUTE_DF_PART(skip, jmi->n_u, jmi->dae->ad->dF_u_n_nz,jmi->dae->ad->dF_u_irow, jmi->dae->ad->dF_u_icol)
    JMI_DAE_COMPUTE_DF_PART(skip, jmi->n_w, jmi->dae->ad->dF_w_n_nz,jmi->dae->ad->dF_w_irow, jmi->dae->ad->dF_w_icol)
    JMI_DAE_COMPUTE_DF_PART(skip, 1, jmi->dae->ad->dF_t_n_nz,jmi->dae->ad->dF_t_irow, jmi->dae->ad->dF_t_icol)



/*

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

	*/
	return 0;

	return -1;
}



int jmi_dae_dF_n_nz_ad(jmi_t* jmi, int* n_nz) {
	if (jmi->dae->ad==NULL) {
		return -1;
	}
	*n_nz = jmi->dae->ad->dF_z_n_nz;
	return 0;
}

int jmi_dae_dF_nz_indices_ad(jmi_t* jmi, int* row, int* col) {
	if (jmi->dae->ad==NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi->dae->ad->dF_z_n_nz;i++) {
		row[i] = jmi->dae->ad->dF_z_irow[i];
		col[i] = jmi->dae->ad->dF_z_icol[i];
	}
	return 0;
}

int jmi_dae_dF_dim_ad(jmi_t* jmi, int sparsity, int skip, int *mask,
		             int *dF_n_cols, int *dF_n_nz) {

	if (jmi->dae->ad==NULL) {
		return -1;
	}

	*dF_n_cols = 0;
	*dF_n_nz = 0;

	int i,j;
	int col_index = 0;

	if (!(skip & JMI_DER_CI_SKIP)) {
		for (i=0;i<jmi->n_ci;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_ci;
	}
	if (!(skip & JMI_DER_CD_SKIP)) {
		for (i=0;i<jmi->n_cd;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_ci;
	}
	if (!(skip & JMI_DER_PI_SKIP)) {
		for (i=0;i<jmi->n_pi;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_pi;
	}
	if (!(skip & JMI_DER_PD_SKIP)) {
		for (i=0;i<jmi->n_pd;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_pd;
	}
	if (!(skip & JMI_DER_DX_SKIP)) {
		for (i=0;i<jmi->n_dx;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_dx;
	}

	if (!(skip & JMI_DER_X_SKIP)) {
		for (i=0;i<jmi->n_x;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_x;
	}

	if (!(skip & JMI_DER_U_SKIP)) {
		for (i=0;i<jmi->n_u;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_u;
	}
	if (!(skip & JMI_DER_W_SKIP)) {
		for (i=0;i<jmi->n_w;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	} else {
		col_index += jmi->n_w;
	}
	if (!(skip & JMI_DER_T_SKIP)) {
		for (i=0;i<1;i++) {
			if (mask[col_index]) {
				(*dF_n_cols)++;
				if (sparsity & JMI_DER_SPARSE) {
					for (j=0;j<jmi->dae->ad->dF_z_n_nz;j++) {
						//printf("%d, %d, %d\n",jmi->dae->ad->dF_z_n_nz,jmi->dae->ad->dF_z_icol[j]-1,col_index);
						(*dF_n_nz) += jmi->dae->ad->dF_z_icol[j]-1 == col_index? 1 : 0;
					}
				} else {
					(*dF_n_nz) += jmi->dae->n_eq_F;
				}
			}
			col_index++;
		}
	}

	return 0;

}

