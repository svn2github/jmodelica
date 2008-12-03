/**
 *
 * This is the second draft of an interface to CppAD. The interface supports computation
 * of Jacobians and sparsity patterns on the form required by Ipopt.
 *
 * Usage:
 *    The AD struct jmi_func_ad_t contains all the tapes and data structures
 *    associated with CppAD. These structs are initialized in the function jmi_ad_init. In this step
 *    all the tapes and the sparsity patterns are computed and cached. This requires
 *    actual values (sensible values, ideally...) are provided for all the independent
 *    variables in the z vector. Such values may originate from XML data or solution of an initial system.
 *    Therefore it is reasonable that this function is called from outside of the the generated
 *    code.
 *
 * Current limitations:
  *   - Memory is copied at several locations form double* vectors to vector<AD>
 *     objects. This may be a bit inefficient - but how can it be avoided?
 *   - Work-vectors. New objects are created at each function call. It may make
 *     sense to allocate work vectors and save them between calls.
 *
 */

#include "jmi.h"

#define JMI_FUNC_COMPUTE_DF_PART(tape, independent_vars_mask, n_vars, n_eq_F, dF_var_n_nz, dF_var_row, dF_var_col) {\
	if ((independent_vars & independent_vars_mask)) {\
		/* loop over all columns*/ \
	\
	for (i=0;i<n_vars;i++) {\
		/*  check the mask if evaluation should be performed */\
	if (mask[col_index + i] == 1) { \
		for (j=0;j<jmi->n_z;j++) {\
			d_z[j] = 0; \
		}\
		d_z[col_index + i] = 1.; \
		/* Evaluate jacobian column */ \
	jac_ = tape->Forward(1,d_z);  \
	switch (sparsity) {  \
	case JMI_DER_DENSE_COL_MAJOR: \
	for(j=0;j<n_eq_F;j++) { \
		jac[jac_n*(col_index+i) + j] = jac_[j]; \
	} \
	break; \
	case JMI_DER_DENSE_ROW_MAJOR: \
	for(j=0;j<n_eq_F;j++) { \
		jac[jac_m*j + (col_index+i)] = jac_[j]; \
	} \
	break; \
	case JMI_DER_SPARSE:\
	for(j=0;j<dF_var_n_nz;j++) { \
		if (dF_var_col[j]-1 == col_index+i) { \
			jac[jac_index++] = jac_[dF_var_row[j]-1]; \
		} \
	}\
	} \
	} \
	}\
	} \
	col_index += n_vars;\
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

	jmi_->z = new jmi_ad_var_vec_t(jmi_->n_z);

	jmi_->z_val = (jmi_real_t**)calloc(1,sizeof(jmi_real_t));
	*(jmi_->z_val) =  (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));

	int i;
	for (i=0;i<jmi_->n_z;i++) {
		(*(jmi_->z))[i] = 0;
		(*(jmi_->z_val))[i] = 0;
	}

	return 0;
}

// This is convenience function that is used to initialize the ad of one jmi_func_t.
int jmi_func_ad_init(jmi_t *jmi, jmi_func_t *func) {

	int i,j;

	jmi_func_ad_t* jf_ad_F = (jmi_func_ad_t*)calloc(1,sizeof(jmi_func_ad_t));
	func->ad = jf_ad_F;

	func->ad->F_z_dependent = new jmi_ad_var_vec_t(func->n_eq_F);

	// Compute the tape for all variables.
	// The z vector is assumed to be initialized previously by the user

	// Copy user's value into jmi->z
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}
	CppAD::Independent(*jmi->z);
	func->F(jmi, func->ad->F_z_dependent);
	func->ad->F_z_tape = new jmi_ad_tape_t(*jmi->z,*func->ad->F_z_dependent);

	func->ad->tape_initialized = true;

	// Compute sparsity patterns
	int m = func->n_eq_F; // Number of rows in Jacobian

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
	s_z = func->ad->F_z_tape->ForSparseJac(jmi->n_z,r_z);

	func->ad->dF_z_n_nz = 0;
	func->ad->dF_ci_n_nz = 0;
	func->ad->dF_cd_n_nz = 0;
	func->ad->dF_pi_n_nz = 0;
	func->ad->dF_pd_n_nz = 0;
	func->ad->dF_dx_n_nz = 0;
	func->ad->dF_x_n_nz = 0;
	func->ad->dF_u_n_nz = 0;
	func->ad->dF_w_n_nz = 0;
	func->ad->dF_t_n_nz = 0;

	// Sort out all the individual variable vector sparsity patterns as well..
	for (i=0;i<(int)s_z.size();i++) { // cast to int since size() gives unsigned int...
		if (s_z[i]) func->ad->dF_z_n_nz++;
	}

	func->ad->dF_z_row = (int*)calloc(func->ad->dF_z_n_nz,sizeof(int));
	func->ad->dF_z_col = (int*)calloc(func->ad->dF_z_n_nz,sizeof(int));

	int jac_ind = 0;
	int col_ind = 0;

	/*
	 * This is a bit tricky. The sparsity matrices s_nn are represented
	 * as vectors in row major format. In the row col representation it
	 * is more convenient give the elements in column major order. In particular
	 * it simplifies the implementation of the Jacobian evaluation.
	 *
	 */

	for (j=0;j<jmi->n_z;j++) {
		for (i=0;i<m;i++) {
			if (s_z[i*jmi->n_z + j]) {
				func->ad->dF_z_col[jac_ind] = j + col_ind + 1;
				func->ad->dF_z_row[jac_ind++] = i + 1;
			}
		}
	}

	for(i=0;i<func->ad->dF_z_n_nz;i++) {
		if (func->ad->dF_z_col[i]-1 < jmi->offs_cd) {
			func->ad->dF_ci_n_nz++;
		} else if (func->ad->dF_z_col[i]-1 >= jmi->offs_cd &&
				func->ad->dF_z_col[i]-1 < jmi->offs_pi) {
			func->ad->dF_cd_n_nz++;
		} else if (func->ad->dF_z_col[i]-1 >= jmi->offs_pi &&
				func->ad->dF_z_col[i]-1 < jmi->offs_pd) {
			func->ad->dF_pi_n_nz++;
		} else if (func->ad->dF_z_col[i]-1 >= jmi->offs_pd &&
				func->ad->dF_z_col[i]-1 < jmi->offs_dx) {
			func->ad->dF_pd_n_nz++;
		} else if (func->ad->dF_z_col[i]-1 >= jmi->offs_dx &&
				func->ad->dF_z_col[i]-1 < jmi->offs_x) {
			func->ad->dF_dx_n_nz++;
		} else if (func->ad->dF_z_col[i]-1 >= jmi->offs_x &&
				func->ad->dF_z_col[i]-1 < jmi->offs_u) {
			func->ad->dF_x_n_nz++;
		} else if (func->ad->dF_z_col[i]-1 >= jmi->offs_u &&
				func->ad->dF_z_col[i]-1 < jmi->offs_w) {
			func->ad->dF_u_n_nz++;
		} else if (func->ad->dF_z_col[i]-1 >= jmi->offs_w &&
				func->ad->dF_z_col[i]-1 < jmi->offs_t) {
			func->ad->dF_w_n_nz++;
		} else if (func->ad->dF_z_col[i]-1 >= jmi->offs_t) {
			func->ad->dF_t_n_nz++;
		}

	}

	func->ad->dF_ci_row = (int*)calloc(func->ad->dF_ci_n_nz,sizeof(int));
	func->ad->dF_ci_col = (int*)calloc(func->ad->dF_ci_n_nz,sizeof(int));
	func->ad->dF_cd_row = (int*)calloc(func->ad->dF_cd_n_nz,sizeof(int));
	func->ad->dF_cd_col = (int*)calloc(func->ad->dF_cd_n_nz,sizeof(int));
	func->ad->dF_pi_row = (int*)calloc(func->ad->dF_pi_n_nz,sizeof(int));
	func->ad->dF_pi_col = (int*)calloc(func->ad->dF_pi_n_nz,sizeof(int));
	func->ad->dF_pd_row = (int*)calloc(func->ad->dF_pd_n_nz,sizeof(int));
	func->ad->dF_pd_col = (int*)calloc(func->ad->dF_pd_n_nz,sizeof(int));
	func->ad->dF_dx_row = (int*)calloc(func->ad->dF_dx_n_nz,sizeof(int));
	func->ad->dF_dx_col = (int*)calloc(func->ad->dF_dx_n_nz,sizeof(int));
	func->ad->dF_x_row = (int*)calloc(func->ad->dF_x_n_nz,sizeof(int));
	func->ad->dF_x_col = (int*)calloc(func->ad->dF_x_n_nz,sizeof(int));
	func->ad->dF_u_row = (int*)calloc(func->ad->dF_u_n_nz,sizeof(int));
	func->ad->dF_u_col = (int*)calloc(func->ad->dF_u_n_nz,sizeof(int));
	func->ad->dF_w_row = (int*)calloc(func->ad->dF_w_n_nz,sizeof(int));
	func->ad->dF_w_col = (int*)calloc(func->ad->dF_w_n_nz,sizeof(int));
	func->ad->dF_t_row = (int*)calloc(func->ad->dF_t_n_nz,sizeof(int));
	func->ad->dF_t_col = (int*)calloc(func->ad->dF_t_n_nz,sizeof(int));

	jac_ind = 0;
	for(i=0;i<func->ad->dF_ci_n_nz;i++) {
		func->ad->dF_ci_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_ci_row[i] = func->ad->dF_z_row[jac_ind++];
	}
	for(i=0;i<func->ad->dF_cd_n_nz;i++) {
		func->ad->dF_cd_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_cd_row[i] = func->ad->dF_z_row[jac_ind++];
	}
	for(i=0;i<func->ad->dF_pi_n_nz;i++) {
		func->ad->dF_pi_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_pi_row[i] = func->ad->dF_z_row[jac_ind++];
	}
	for(i=0;i<func->ad->dF_pd_n_nz;i++) {
		func->ad->dF_pd_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_pd_row[i] = func->ad->dF_z_row[jac_ind++];
	}
	for(i=0;i<func->ad->dF_dx_n_nz;i++) {
		func->ad->dF_dx_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_dx_row[i] = func->ad->dF_z_row[jac_ind++];
	}
	for(i=0;i<func->ad->dF_x_n_nz;i++) {
		func->ad->dF_x_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_x_row[i] = func->ad->dF_z_row[jac_ind++];
	}
	for(i=0;i<func->ad->dF_u_n_nz;i++) {
		func->ad->dF_u_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_u_row[i] = func->ad->dF_z_row[jac_ind++];
	}
	for(i=0;i<func->ad->dF_w_n_nz;i++) {
		func->ad->dF_w_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_w_row[i] = func->ad->dF_z_row[jac_ind++];
	}
	for(i=0;i<func->ad->dF_t_n_nz;i++) {
		func->ad->dF_t_col[i] = func->ad->dF_z_col[jac_ind];
		func->ad->dF_t_row[i] = func->ad->dF_z_row[jac_ind++];
	}

	/*
  printf("%d, %d, %d, %d, %d, %d, %d\n", func->ad->dF_pi_n_nz,
	 func->ad->dF_pd_n_nz,
	 func->ad->dF_dx_n_nz,
	 func->ad->dF_x_n_nz,
	 func->ad->dF_u_n_nz,
	 func->ad->dF_w_n_nz,
	 func->ad->dF_t_n_nz);

  for (i=0;i<func->ad->dF_z_n_nz;i++) {
    printf("*** %d, %d\n",func->ad->dF_z_row[i],func->ad->dF_z_col[i]);
  }
  for (i=0;i<func->ad->dF_ci_n_nz;i++) {
    printf("*** ci: %d, %d\n",func->ad->dF_ci_row[i],func->ad->dF_ci_col[i]);
  }
  for (i=0;i<func->ad->dF_cd_n_nz;i++) {
    printf("*** cd: %d, %d\n",func->ad->dF_cd_row[i],func->ad->dF_cd_col[i]);
  }
  for (i=0;i<func->ad->dF_pi_n_nz;i++) {
    printf("*** pi: %d, %d\n",func->ad->dF_pi_row[i],func->ad->dF_pi_col[i]);
  }
  for (i=0;i<func->ad->dF_pd_n_nz;i++) {
    printf("*** pd: %d, %d\n",func->ad->dF_pd_row[i],func->ad->dF_pd_col[i]);
  }
  for (i=0;i<func->ad->dF_dx_n_nz;i++) {
    printf("*** dx: %d, %d\n",func->ad->dF_dx_row[i],func->ad->dF_dx_col[i]);
  }
  for (i=0;i<func->ad->dF_x_n_nz;i++) {
    printf("*** x: %d, %d\n",func->ad->dF_x_row[i],func->ad->dF_x_col[i]);
  }
  for (i=0;i<func->ad->dF_u_n_nz;i++) {
    printf("*** u: %d, %d\n",func->ad->dF_u_row[i],func->ad->dF_u_col[i]);
  }
  for (i=0;i<func->ad->dF_w_n_nz;i++) {
    printf("*** w: %d, %d\n",func->ad->dF_w_row[i],func->ad->dF_w_col[i]);
  }
  for (i=0;i<func->ad->->dF_t_n_nz;i++) {
    printf("*** t: %d, %d\n",func->ad->dF_t_row[i],func->ad->dF_t_col[i]);
  }

  printf("-*** %d\n",func->ad->dF_z_n_nz);

  for (i=0;i<m*jmi->n_z;i++) {
    printf("--*** %d\n",s_z[i]? 1 : 0);
  }

	 */

	func->ad->z_work = new jmi_real_vec_t(jmi->n_z);


	return 0;
}

// Convenience function to evaluate the function contained in a
// jmi_func_t struct by means of AD.
int jmi_func_ad_F(jmi_t *jmi, jmi_func_t *func, jmi_real_t* res) {

	int i;

	for (i=0;i<jmi->n_z;i++) {
		(*(func->ad->z_work))[i] = (*(jmi->z_val))[i];
	}

	jmi_real_vec_t res_w = func->ad->F_z_tape->Forward(0,*func->ad->z_work);

	for(i=0;i<func->n_eq_F;i++) {
		res[i] = res_w[i];
	}

	return 0;

}

// Convenience function for accessing the number of non-zeros in the AD
// Jacobian.
int jmi_func_ad_dF_n_nz(jmi_t *jmi, jmi_func_t *func, int* n_nz) {

	if (func->ad==NULL) {
		return -1;
	}
	*n_nz = func->ad->dF_z_n_nz;
	return 0;

}

// Convenience function of accessing the non-zeros in the AD Jacobian
int jmi_func_ad_dF_nz_indices(jmi_t *jmi, jmi_func_t *func, int *row, int *col) {
	if (func->ad==NULL) {
		return -1;
	}
	int i;
	for (i=0;i<func->ad->dF_z_n_nz;i++) {
		row[i] = func->ad->dF_z_row[i];
		col[i] = func->ad->dF_z_col[i];
	}
	return 0;
}

// Convenience function for computing the dimensions of an AD Jacobian.
int jmi_func_ad_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {


	if (func->ad==NULL) {
		return -1;
	}

	*dF_n_cols = 0;
	*dF_n_nz = 0;

	int i,j;
	int col_index = 0;

	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_CI, jmi->n_ci, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_CD, jmi->n_cd, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_PI, jmi->n_pi, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_PD, jmi->n_pd, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_DX, jmi->n_dx, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_X, jmi->n_x, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_U, jmi->n_u, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_W, jmi->n_w, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)
	JMI_FUNC_COMPUTE_DF_DIM_PART(JMI_DER_T, 1, func->n_eq_F, func->ad->dF_z_n_nz, func->ad->dF_z_col)

	return 0;

}

// Convenience function to evaluate the Jacobian of the function contained in a
// jmi_func_t struct by means of AD.
int jmi_func_ad_dF(jmi_t *jmi,jmi_func_t *func, int sparsity,
		int independent_vars, int* mask, jmi_real_t* jac) {

	if (func->ad==NULL) {
		return -1;
	}

	int i,j;
	for (i=0;i<jmi->n_z;i++) {
		(*(func->ad->z_work))[i] = (*(jmi->z_val))[i];
	}

	int jac_index = 0;
	int col_index = 0;
	int jac_n = func->n_eq_F;

	int jac_m;
	int jac_n_nz;
	jmi_func_ad_dF_dim(jmi,jmi->dae->F,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

	//	printf("****** %d\n",jac_m);

	jmi_real_vec_t jac_(func->n_eq_F);
	jmi_real_vec_t d_z(jmi->n_z);

	// Evaluate the tape for the current z-values
	func->ad->F_z_tape->Forward(0,*func->ad->z_work);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, jmi->n_ci, func->n_eq_F, func->ad->dF_ci_n_nz,func->ad->dF_ci_row, func->ad->dF_ci_col)
	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, jmi->n_cd, func->n_eq_F, func->ad->dF_cd_n_nz,func->ad->dF_cd_row, func->ad->dF_cd_col)
	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, jmi->n_pi, func->n_eq_F, func->ad->dF_pi_n_nz,func->ad->dF_pi_row, func->ad->dF_pi_col)
	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, jmi->n_pd, func->n_eq_F, func->ad->dF_pd_n_nz,func->ad->dF_pd_row, func->ad->dF_pd_col)
	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, jmi->n_dx, func->n_eq_F, func->ad->dF_dx_n_nz,func->ad->dF_dx_row, func->ad->dF_dx_col)
	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, jmi->n_x, func->n_eq_F, func->ad->dF_x_n_nz,func->ad->dF_x_row, func->ad->dF_x_col)
	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, jmi->n_u, func->n_eq_F, func->ad->dF_u_n_nz,func->ad->dF_u_row, func->ad->dF_u_col)
	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, jmi->n_w, func->n_eq_F, func->ad->dF_w_n_nz,func->ad->dF_w_row, func->ad->dF_w_col)
	JMI_FUNC_COMPUTE_DF_PART(func->ad->F_z_tape, independent_vars, 1, func->n_eq_F, func->ad->dF_t_n_nz,func->ad->dF_t_row, func->ad->dF_t_col)

	return 0;
}

int jmi_ad_init(jmi_t* jmi) {

	if (jmi->dae!=NULL) {
		jmi_func_ad_init(jmi, jmi->dae->F);
	}
	if (jmi->init!=NULL) {
		jmi_func_ad_init(jmi, jmi->init->F0);
		jmi_func_ad_init(jmi, jmi->init->F1);
	}
	return 0;
}

int jmi_delete(jmi_t* jmi){

	if(jmi->dae != NULL) {
		if (jmi->dae->F->ad != NULL) {

			delete jmi->dae->F->ad->F_z_dependent;
			delete jmi->dae->F->ad->F_z_tape;
			free(jmi->dae->F->ad->dF_z_row);
			free(jmi->dae->F->ad->dF_z_col);

			free(jmi->dae->F->ad->dF_ci_row);
			free(jmi->dae->F->ad->dF_ci_col);
			free(jmi->dae->F->ad->dF_cd_row);
			free(jmi->dae->F->ad->dF_cd_col);
			free(jmi->dae->F->ad->dF_pi_row);
			free(jmi->dae->F->ad->dF_pi_col);
			free(jmi->dae->F->ad->dF_pd_row);
			free(jmi->dae->F->ad->dF_pd_col);
			free(jmi->dae->F->ad->dF_dx_row);
			free(jmi->dae->F->ad->dF_dx_col);
			free(jmi->dae->F->ad->dF_x_row);
			free(jmi->dae->F->ad->dF_x_col);
			free(jmi->dae->F->ad->dF_u_row);
			free(jmi->dae->F->ad->dF_u_col);
			free(jmi->dae->F->ad->dF_w_row);
			free(jmi->dae->F->ad->dF_w_col);
			free(jmi->dae->F->ad->dF_t_row);
			free(jmi->dae->F->ad->dF_t_col);
			delete jmi->dae->F->ad->z_work;
			free(jmi->dae->F->ad);
		}
		free(jmi->dae->F->dF_row);
		free(jmi->dae->F->dF_col);
		free(jmi->dae->F);
		free(jmi->dae);
	}
	if(jmi->init != NULL) {
		free(jmi->init);
	}
	if(jmi->opt != NULL) {
		free(jmi->opt);
	}

	delete jmi->z;
	free(*(jmi->z_val));
	free(jmi->z_val);
	free(jmi);

	return 0;
}

int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {
	return jmi_func_ad_F(jmi,jmi->dae->F, res);
}

int jmi_dae_dF(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->dae->F, sparsity,
				independent_vars, mask, jac) ;

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_ad_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac);

	} else {
		return -1;
	}
}

int jmi_dae_dF_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->dae->F, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_ad_dF_n_nz(jmi, jmi->dae->F, n_nz);

	} else {
		return -1;
	}
}

int jmi_dae_dF_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->dae->F, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_dF_nz_indices(jmi, jmi->dae->F, row, col);

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

		return jmi_func_ad_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else {
		return -1;
	}
}

int jmi_dae_F0(jmi_t* jmi, jmi_real_t* res) {
	return jmi_func_ad_F(jmi,jmi->init->F0, res);
}

int jmi_dae_dF0(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->init->F0, sparsity,
				independent_vars, mask, jac) ;

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_ad_dF(jmi,jmi->init->F0, sparsity, independent_vars, mask, jac);

	} else {
		return -1;
	}
}

int jmi_dae_dF0_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->init->F0, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_ad_dF_n_nz(jmi, jmi->init->F0, n_nz);

	} else {
		return -1;
	}
}

int jmi_dae_dF0_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->F0, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->F0, row, col);

	} else {
		return -1;
	}
}

int jmi_dae_dF0_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->init->F0, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_ad_dF_dim(jmi, jmi->init->F0, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else {
		return -1;
	}
}


int jmi_dae_F1(jmi_t* jmi, jmi_real_t* res) {
	return jmi_func_ad_F(jmi,jmi->init->F1, res);
}

int jmi_dae_dF1(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF(jmi, jmi->init->F1, sparsity,
				independent_vars, mask, jac) ;

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_ad_dF(jmi,jmi->init->F1, sparsity, independent_vars, mask, jac);

	} else {
		return -1;
	}
}

int jmi_dae_dF1_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_n_nz(jmi, jmi->init->F1, n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_ad_dF_n_nz(jmi, jmi->init->F1, n_nz);

	} else {
		return -1;
	}
}

int jmi_dae_dF1_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->F1, row, col);

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_dF_nz_indices(jmi, jmi->init->F1, row, col);

	} else {
		return -1;
	}
}

int jmi_dae_dF1_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		return jmi_func_dF_dim(jmi, jmi->init->F1, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else if (eval_alg & JMI_DER_CPPAD) {

		return jmi_func_ad_dF_dim(jmi, jmi->init->F1, sparsity, independent_vars, mask,
				dF_n_cols, dF_n_nz);

	} else {
		return -1;
	}
}

