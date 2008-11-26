
#include "jmi.h"

#define JMI_DAE_COMPUTE_DF_DIM_PART(skip_mask, n_vars, jmi_dF_n_nz, jmi_dF_icol) {\
	if (!(skip & skip_mask)) {\
		for (i=0;i<n_vars;i++) {\
			if (mask[col_index]) {\
				(*dF_n_cols)++;\
				if (sparsity & JMI_DER_SPARSE) {\
					for (j=0;j<jmi_dF_n_nz;j++) {\
					  /*printf("%d, %d, %d\n",jmi->dae->dF_n_nz,jmi->dae->dF_icol[j]-1,col_index);*/\
						(*dF_n_nz) += jmi_dF_icol[j]-1 == col_index? 1 : 0;\
					}\
				} else {\
					(*dF_n_nz) += jmi->dae->n_eq_F;\
				}\
			}\
			col_index++;\
		}\
	} else {\
		col_index += n_vars;\
	}\
}\


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
  return -1;
}

int jmi_delete(jmi_t* jmi){
  if(jmi->dae != NULL) {
    free(jmi->dae->dF_irow);
    free(jmi->dae->dF_icol);
    free(jmi->dae);
  }
  if(jmi->init != NULL) {
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

int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {
  int i;
  for (i=0;i<jmi->n_z;i++) {
    (*(jmi->z))[i] = (*(jmi->z_val))[i];
  }

  jmi->dae->F(jmi, &res);
  return 0;
}

int jmi_dae_dF(jmi_t* jmi, int sparsity, int skip, int* mask, jmi_real_t* jac) {
	if (jmi->dae->dF==NULL) {
		return -1;
	}
	int i;
  for (i=0;i<jmi->n_z;i++) {
    (*(jmi->z))[i] = (*(jmi->z_val))[i];
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

 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_CI_SKIP, jmi->n_ci, jmi->dae->dF_n_nz, jmi->dae->dF_icol)
 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_CD_SKIP, jmi->n_cd, jmi->dae->dF_n_nz, jmi->dae->dF_icol)
 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_PI_SKIP, jmi->n_pi, jmi->dae->dF_n_nz, jmi->dae->dF_icol)
 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_PD_SKIP, jmi->n_pd, jmi->dae->dF_n_nz, jmi->dae->dF_icol)
 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_DX_SKIP, jmi->n_dx, jmi->dae->dF_n_nz, jmi->dae->dF_icol)
 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_X_SKIP, jmi->n_x, jmi->dae->dF_n_nz, jmi->dae->dF_icol)
 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_U_SKIP, jmi->n_u, jmi->dae->dF_n_nz, jmi->dae->dF_icol)
 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_W_SKIP, jmi->n_w, jmi->dae->dF_n_nz, jmi->dae->dF_icol)
 JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_T_SKIP, 1, jmi->dae->dF_n_nz, jmi->dae->dF_icol)

	return 0;
}

// Not supported in this interface
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

// Not supported in this interface
int jmi_dae_dF_dim_ad(jmi_t* jmi, int sparsity, int skip, int *mask,
		             int *dF_n_cols, int *dF_n_nz) {
	return -1;
}

