/**
 *
 * This is the second draft of an interface to CppAD. The interface supports computation
 * of Jacobians and sparsity patterns on the form required by Ipopt.
 *
 * Usage:
 *    The AD structs jmi_xxx_ad_t (dae, init and opt) contains all the tapes and data structures
 *    associated with CppAD. These structs are initialized in the function jmi_ad_init. In this step
 *    all the tapes and the sparsity patterns are computed and cached. This requires
 *    actual values (sensible values, ideally...) are provided for all the independent
 *    variables in the z vector. Such values may originate from XML data or solution of an initial system.
 *    Therefore it is reasonable that this function is called from outside of the the generated
 *    code.
 *
 * Current limitations:
 *   - Only the DAE part of the interface is supported.
 *   - Memory is copied at several locations form double* vectors to vector<AD>
 *     objects. This may be a bit inefficient - but how can it be avoided?
 *   - Work-vectors. New objects are created at each function call. It may make
 *     sense to allocate work vectors and save them between calls.
 *
 * Issues:
 *   - The code contains a lot of repetitive segments, which could probably be factored
 *     out by means of functions or macros.
 */



#include "jmi.h"

#define JMI_DAE_COMPUTE_DF_DIM_PART(independent_vars_mask, n_vars, jmi_dF_n_nz, jmi_dF_icol) {\
	if ((independent_vars & independent_vars_mask)) {\
		for (i=0;i<n_vars;i++) {\
			if (mask[col_index]) {\
				(*dF_n_cols)++;\
				if (sparsity & JMI_DER_SPARSE) {\
					for (j=0;j<jmi_dF_n_nz;j++) {\
						/*printf("%d, %d, %d\n",jmi->dae->F->dY_n_nz,jmi->dae->F->dY_icol[j]-1,col_index);*/\
	(*dF_n_nz) += jmi_dF_icol[j]-1 == col_index? 1 : 0;\
					}\
				} else {\
					(*dF_n_nz) += jmi->dae->F->n_eq_Y;\
				}\
			}\
			col_index++;\
		}\
	} else {\
		col_index += n_vars;\
	}\
}\


#define JMI_DAE_COMPUTE_DF_PART(independent_vars_mask, n_vars, dF_var_n_nz, dF_var_irow, dF_var_icol) {\
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
	jac_ = jmi->dae->F->ad->Y_z_tape->Forward(1,d_z);  \
	switch (sparsity) {  \
	case JMI_DER_DENSE_COL_MAJOR: \
	for(j=0;j<jmi->dae->F->n_eq_Y;j++) { \
		jac[jac_n*(col_index+i) + j] = jac_[j]; \
	} \
	break; \
	case JMI_DER_DENSE_ROW_MAJOR: \
	for(j=0;j<jmi->dae->F->n_eq_Y;j++) { \
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

int jmi_dae_init(jmi_t* jmi, jmi_residual_func_t jmi_dae_F, int n_eq_F, jmi_jacobian_func_t jmi_dae_dF,
		int dF_n_nz, int* irow, int* icol) {

	int i;

	// Create jmi_dae struct
	jmi_dae_t* dae = (jmi_dae_t*)calloc(1,sizeof(jmi_dae_t));
	jmi->dae = dae;
	jmi_func_t* jf_F = (jmi_func_t*)calloc(1,sizeof(jmi_func_t));
	jmi->dae->F = jf_F;

	// Set up the dae struct
	dae->F->n_eq_Y = n_eq_F;
	dae->F->Y = jmi_dae_F;
	dae->F->dY = jmi_dae_dF;

	dae->F->dY_n_nz = dF_n_nz;
	dae->F->dY_irow = (int*)calloc(dF_n_nz,sizeof(int));
	dae->F->dY_icol = (int*)calloc(dF_n_nz,sizeof(int));

	for (i=0;i<dF_n_nz;i++) {
		dae->F->dY_irow[i] = irow[i];
		dae->F->dY_icol[i] = icol[i];
	}

	dae->F->ad = NULL;

	return 0;
}

int jmi_ad_init(jmi_t* jmi) {

	int i,j;

//	jmi_dae_ad_t* jdad = (jmi_dae_ad_t*)calloc(1,sizeof(jmi_dae_ad_t));
//	jmi->dae->ad = jdad;

	jmi_func_ad_t* jf_ad_F = (jmi_func_ad_t*)calloc(1,sizeof(jmi_func_ad_t));
	jmi->dae->F->ad = jf_ad_F;

	jmi->dae->F->ad->Y_z_dependent = new jmi_ad_var_vec_t(jmi->dae->F->n_eq_Y);

	// Compute the tape for all variables.
	// The z vector is assumed to be initialized previously by the user

	// Copy user's value into jmi->z
	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->z))[i] = (*(jmi->z_val))[i];
	}
	CppAD::Independent(*jmi->z);
	jmi->dae->F->Y(jmi, jmi->dae->F->ad->Y_z_dependent);
	jmi->dae->F->ad->Y_z_tape = new jmi_ad_tape_t(*jmi->z,*jmi->dae->F->ad->Y_z_dependent);

	jmi->dae->F->ad->tape_initialized = true;

	// Compute sparsity patterns
	int m = jmi->dae->F->n_eq_Y; // Number of rows in Jacobian

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
	s_z = jmi->dae->F->ad->Y_z_tape->ForSparseJac(jmi->n_z,r_z);

	jmi->dae->F->ad->dY_z_n_nz = 0;
	jmi->dae->F->ad->dY_ci_n_nz = 0;
	jmi->dae->F->ad->dY_cd_n_nz = 0;
	jmi->dae->F->ad->dY_pi_n_nz = 0;
	jmi->dae->F->ad->dY_pd_n_nz = 0;
	jmi->dae->F->ad->dY_dx_n_nz = 0;
	jmi->dae->F->ad->dY_x_n_nz = 0;
	jmi->dae->F->ad->dY_u_n_nz = 0;
	jmi->dae->F->ad->dY_w_n_nz = 0;
	jmi->dae->F->ad->dY_t_n_nz = 0;

	// Sort out all the individual variable vector sparsity patterns as well..
	for (i=0;i<(int)s_z.size();i++) { // cast to int since size() gives unsigned int...
		if (s_z[i]) jmi->dae->F->ad->dY_z_n_nz++;
	}

	jmi->dae->F->ad->dY_z_irow = (int*)calloc(jmi->dae->F->ad->dY_z_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_z_icol = (int*)calloc(jmi->dae->F->ad->dY_z_n_nz,sizeof(int));

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
				jmi->dae->F->ad->dY_z_icol[jac_ind] = j + col_ind + 1;
				jmi->dae->F->ad->dY_z_irow[jac_ind++] = i + 1;
			}
		}
	}

	for(i=0;i<jmi->dae->F->ad->dY_z_n_nz;i++) {
		if (jmi->dae->F->ad->dY_z_icol[i]-1 < jmi->offs_cd) {
			jmi->dae->F->ad->dY_ci_n_nz++;
		} else if (jmi->dae->F->ad->dY_z_icol[i]-1 >= jmi->offs_cd &&
				jmi->dae->F->ad->dY_z_icol[i]-1 < jmi->offs_pi) {
			jmi->dae->F->ad->dY_cd_n_nz++;
		} else if (jmi->dae->F->ad->dY_z_icol[i]-1 >= jmi->offs_pi &&
				jmi->dae->F->ad->dY_z_icol[i]-1 < jmi->offs_pd) {
			jmi->dae->F->ad->dY_pi_n_nz++;
		} else if (jmi->dae->F->ad->dY_z_icol[i]-1 >= jmi->offs_pd &&
				jmi->dae->F->ad->dY_z_icol[i]-1 < jmi->offs_dx) {
			jmi->dae->F->ad->dY_pd_n_nz++;
		} else if (jmi->dae->F->ad->dY_z_icol[i]-1 >= jmi->offs_dx &&
				jmi->dae->F->ad->dY_z_icol[i]-1 < jmi->offs_x) {
			jmi->dae->F->ad->dY_dx_n_nz++;
		} else if (jmi->dae->F->ad->dY_z_icol[i]-1 >= jmi->offs_x &&
				jmi->dae->F->ad->dY_z_icol[i]-1 < jmi->offs_u) {
			jmi->dae->F->ad->dY_x_n_nz++;
		} else if (jmi->dae->F->ad->dY_z_icol[i]-1 >= jmi->offs_u &&
				jmi->dae->F->ad->dY_z_icol[i]-1 < jmi->offs_w) {
			jmi->dae->F->ad->dY_u_n_nz++;
		} else if (jmi->dae->F->ad->dY_z_icol[i]-1 >= jmi->offs_w &&
				jmi->dae->F->ad->dY_z_icol[i]-1 < jmi->offs_t) {
			jmi->dae->F->ad->dY_w_n_nz++;
		} else if (jmi->dae->F->ad->dY_z_icol[i]-1 >= jmi->offs_t) {
			jmi->dae->F->ad->dY_t_n_nz++;
		}

	}

	jmi->dae->F->ad->dY_ci_irow = (int*)calloc(jmi->dae->F->ad->dY_ci_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_ci_icol = (int*)calloc(jmi->dae->F->ad->dY_ci_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_cd_irow = (int*)calloc(jmi->dae->F->ad->dY_cd_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_cd_icol = (int*)calloc(jmi->dae->F->ad->dY_cd_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_pi_irow = (int*)calloc(jmi->dae->F->ad->dY_pi_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_pi_icol = (int*)calloc(jmi->dae->F->ad->dY_pi_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_pd_irow = (int*)calloc(jmi->dae->F->ad->dY_pd_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_pd_icol = (int*)calloc(jmi->dae->F->ad->dY_pd_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_dx_irow = (int*)calloc(jmi->dae->F->ad->dY_dx_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_dx_icol = (int*)calloc(jmi->dae->F->ad->dY_dx_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_x_irow = (int*)calloc(jmi->dae->F->ad->dY_x_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_x_icol = (int*)calloc(jmi->dae->F->ad->dY_x_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_u_irow = (int*)calloc(jmi->dae->F->ad->dY_u_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_u_icol = (int*)calloc(jmi->dae->F->ad->dY_u_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_w_irow = (int*)calloc(jmi->dae->F->ad->dY_w_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_w_icol = (int*)calloc(jmi->dae->F->ad->dY_w_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_t_irow = (int*)calloc(jmi->dae->F->ad->dY_t_n_nz,sizeof(int));
	jmi->dae->F->ad->dY_t_icol = (int*)calloc(jmi->dae->F->ad->dY_t_n_nz,sizeof(int));

	jac_ind = 0;
	for(i=0;i<jmi->dae->F->ad->dY_ci_n_nz;i++) {
		jmi->dae->F->ad->dY_ci_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_ci_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}
	for(i=0;i<jmi->dae->F->ad->dY_cd_n_nz;i++) {
		jmi->dae->F->ad->dY_cd_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_cd_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}
	for(i=0;i<jmi->dae->F->ad->dY_pi_n_nz;i++) {
		jmi->dae->F->ad->dY_pi_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_pi_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}
	for(i=0;i<jmi->dae->F->ad->dY_pd_n_nz;i++) {
		jmi->dae->F->ad->dY_pd_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_pd_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}
	for(i=0;i<jmi->dae->F->ad->dY_dx_n_nz;i++) {
		jmi->dae->F->ad->dY_dx_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_dx_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}
	for(i=0;i<jmi->dae->F->ad->dY_x_n_nz;i++) {
		jmi->dae->F->ad->dY_x_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_x_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}
	for(i=0;i<jmi->dae->F->ad->dY_u_n_nz;i++) {
		jmi->dae->F->ad->dY_u_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_u_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}
	for(i=0;i<jmi->dae->F->ad->dY_w_n_nz;i++) {
		jmi->dae->F->ad->dY_w_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_w_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}
	for(i=0;i<jmi->dae->F->ad->dY_t_n_nz;i++) {
		jmi->dae->F->ad->dY_t_icol[i] = jmi->dae->F->ad->dY_z_icol[jac_ind];
		jmi->dae->F->ad->dY_t_irow[i] = jmi->dae->F->ad->dY_z_irow[jac_ind++];
	}

	/*
  printf("%d, %d, %d, %d, %d, %d, %d\n", jmi->dae->F->ad->dY_pi_n_nz,
	 jmi->dae->F->ad->dY_pd_n_nz,
	 jmi->dae->F->ad->dY_dx_n_nz,
	 jmi->dae->F->ad->dY_x_n_nz,
	 jmi->dae->F->ad->dY_u_n_nz,
	 jmi->dae->F->ad->dY_w_n_nz,
	 jmi->dae->F->ad->dY_t_n_nz);

  for (i=0;i<jmi->dae->F->ad->dY_z_n_nz;i++) {
    printf("*** %d, %d\n",jmi->dae->F->ad->dY_z_irow[i],jmi->dae->F->ad->dY_z_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->dY_ci_n_nz;i++) {
    printf("*** ci: %d, %d\n",jmi->dae->F->ad->dY_ci_irow[i],jmi->dae->F->ad->dY_ci_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->dY_cd_n_nz;i++) {
    printf("*** cd: %d, %d\n",jmi->dae->F->ad->dY_cd_irow[i],jmi->dae->F->ad->dY_cd_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->dY_pi_n_nz;i++) {
    printf("*** pi: %d, %d\n",jmi->dae->F->ad->dY_pi_irow[i],jmi->dae->F->ad->dY_pi_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->dY_pd_n_nz;i++) {
    printf("*** pd: %d, %d\n",jmi->dae->F->ad->dY_pd_irow[i],jmi->dae->F->ad->dY_pd_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->dY_dx_n_nz;i++) {
    printf("*** dx: %d, %d\n",jmi->dae->F->ad->dY_dx_irow[i],jmi->dae->F->ad->dY_dx_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->dY_x_n_nz;i++) {
    printf("*** x: %d, %d\n",jmi->dae->F->ad->dY_x_irow[i],jmi->dae->F->ad->dY_x_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->dY_u_n_nz;i++) {
    printf("*** u: %d, %d\n",jmi->dae->F->ad->dY_u_irow[i],jmi->dae->F->ad->dY_u_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->dY_w_n_nz;i++) {
    printf("*** w: %d, %d\n",jmi->dae->F->ad->dY_w_irow[i],jmi->dae->F->ad->dY_w_icol[i]);
  }
  for (i=0;i<jmi->dae->F->ad->->dY_t_n_nz;i++) {
    printf("*** t: %d, %d\n",jmi->dae->F->ad->dY_t_irow[i],jmi->dae->F->ad->dY_t_icol[i]);
  }

  printf("-*** %d\n",jmi->dae->F->ad->dY_z_n_nz);

  for (i=0;i<m*jmi->n_z;i++) {
    printf("--*** %d\n",s_z[i]? 1 : 0);
  }

	 */

	jmi->dae->F->ad->z_work = new jmi_real_vec_t(jmi->n_z);

	return 0;

}

int jmi_delete(jmi_t* jmi){

	if(jmi->dae != NULL) {
		free(jmi->dae->F->dY_irow);
		free(jmi->dae->F->dY_icol);
		if (jmi->dae->F->ad != NULL) {

			delete jmi->dae->F->ad->Y_z_dependent;
			delete jmi->dae->F->ad->Y_z_tape;
			free(jmi->dae->F->ad->dY_z_irow);
			free(jmi->dae->F->ad->dY_z_icol);

			free(jmi->dae->F->ad->dY_ci_irow);
			free(jmi->dae->F->ad->dY_ci_icol);
			free(jmi->dae->F->ad->dY_cd_irow);
			free(jmi->dae->F->ad->dY_cd_icol);
			free(jmi->dae->F->ad->dY_pi_irow);
			free(jmi->dae->F->ad->dY_pi_icol);
			free(jmi->dae->F->ad->dY_pd_irow);
			free(jmi->dae->F->ad->dY_pd_icol);
			free(jmi->dae->F->ad->dY_dx_irow);
			free(jmi->dae->F->ad->dY_dx_icol);
			free(jmi->dae->F->ad->dY_x_irow);
			free(jmi->dae->F->ad->dY_x_icol);
			free(jmi->dae->F->ad->dY_u_irow);
			free(jmi->dae->F->ad->dY_u_icol);
			free(jmi->dae->F->ad->dY_w_irow);
			free(jmi->dae->F->ad->dY_w_icol);
			free(jmi->dae->F->ad->dY_t_irow);
			free(jmi->dae->F->ad->dY_t_icol);
			free(jmi->dae->F->ad);
			delete jmi->dae->F->ad->z_work;
		}
		free(jmi->dae);
	}
	if(jmi->init != NULL) {
		free(jmi->init);
	}
	if(jmi->opt != NULL) {
		free(jmi->opt);
	}

	delete jmi->z;
	delete jmi->z_val;
	free(jmi);

	return 0;
}

int jmi_get_sizes(jmi_t* jmi, int* n_ci, int* n_cd, int* n_pi, int* n_pd,
		                        int* n_dx, int* n_x, int* n_u, int* n_w) {

	*n_ci = jmi->n_ci;
	*n_cd = jmi->n_cd;
	*n_pi = jmi->n_pi;
	*n_pd = jmi->n_pd;
	*n_dx = jmi->n_dx;
	*n_x = jmi->n_x;
	*n_u = jmi->n_u;
	*n_w = jmi->n_w;

	return 0;
}

int jmi_dae_get_sizes(jmi_t* jmi, int* n_eq_F) {
	*n_eq_F = jmi->dae->F->n_eq_Y;
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

	for (i=0;i<jmi->n_z;i++) {
		(*(jmi->dae->F->ad->z_work))[i] = (*(jmi->z_val))[i];
	}

	jmi_real_vec_t res_w = jmi->dae->F->ad->Y_z_tape->Forward(0,*jmi->dae->F->ad->z_work);

	for(i=0;i<jmi->dae->F->n_eq_Y;i++) {
		res[i] = res_w[i];
	}

	return 0;
}

int jmi_dae_dF(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
	if (eval_alg & JMI_DER_SYMBOLIC) {

		if (jmi->dae->F->dY==NULL) {
			return -1;
		}
		jmi->dae->F->dY(jmi, sparsity, independent_vars, mask, jac);
		return 0;

	} else if (eval_alg & JMI_DER_CPPAD) {
		if (jmi->dae->F->ad==NULL) {
			return -1;
		}

		int i,j;
		for (i=0;i<jmi->n_z;i++) {
			(*(jmi->dae->F->ad->z_work))[i] = (*(jmi->z_val))[i];
		}

		int jac_index = 0;
		int col_index = 0;
		int jac_n = jmi->dae->F->n_eq_Y;

		int jac_m;
		int jac_n_nz;
		jmi_dae_dF_dim(jmi,JMI_DER_CPPAD,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

		//	printf("****** %d\n",jac_m);

		jmi_real_vec_t jac_(jmi->dae->F->n_eq_Y);
		jmi_real_vec_t d_z(jmi->n_z);

		// Evaluate the tape for the current z-values
		jmi->dae->F->ad->Y_z_tape->Forward(0,*jmi->dae->F->ad->z_work);

		// Set Jacobian to zero if dense evaluation.
		if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
			for (i=0;i<jac_n*jac_m;i++) {
				jac[i] = 0;
			}
		}

		JMI_DAE_COMPUTE_DF_PART(independent_vars, jmi->n_ci, jmi->dae->F->ad->dY_ci_n_nz,jmi->dae->F->ad->dY_ci_irow, jmi->dae->F->ad->dY_ci_icol)
		JMI_DAE_COMPUTE_DF_PART(independent_vars, jmi->n_cd, jmi->dae->F->ad->dY_cd_n_nz,jmi->dae->F->ad->dY_cd_irow, jmi->dae->F->ad->dY_cd_icol)
		JMI_DAE_COMPUTE_DF_PART(independent_vars, jmi->n_pi, jmi->dae->F->ad->dY_pi_n_nz,jmi->dae->F->ad->dY_pi_irow, jmi->dae->F->ad->dY_pi_icol)
		JMI_DAE_COMPUTE_DF_PART(independent_vars, jmi->n_pd, jmi->dae->F->ad->dY_pd_n_nz,jmi->dae->F->ad->dY_pd_irow, jmi->dae->F->ad->dY_pd_icol)
		JMI_DAE_COMPUTE_DF_PART(independent_vars, jmi->n_dx, jmi->dae->F->ad->dY_dx_n_nz,jmi->dae->F->ad->dY_dx_irow, jmi->dae->F->ad->dY_dx_icol)
		JMI_DAE_COMPUTE_DF_PART(independent_vars, jmi->n_x, jmi->dae->F->ad->dY_x_n_nz,jmi->dae->F->ad->dY_x_irow, jmi->dae->F->ad->dY_x_icol)
		JMI_DAE_COMPUTE_DF_PART(independent_vars, jmi->n_u, jmi->dae->F->ad->dY_u_n_nz,jmi->dae->F->ad->dY_u_irow, jmi->dae->F->ad->dY_u_icol)
		JMI_DAE_COMPUTE_DF_PART(independent_vars, jmi->n_w, jmi->dae->F->ad->dY_w_n_nz,jmi->dae->F->ad->dY_w_irow, jmi->dae->F->ad->dY_w_icol)
		JMI_DAE_COMPUTE_DF_PART(independent_vars, 1, jmi->dae->F->ad->dY_t_n_nz,jmi->dae->F->ad->dY_t_irow, jmi->dae->F->ad->dY_t_icol)

		return 0;

	} else {
		return -1;
	}
}

int jmi_dae_dF_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
	if (eval_alg & JMI_DER_SYMBOLIC) {
		if (jmi->dae->F->dY==NULL) {
			return -1;
		}
		*n_nz = jmi->dae->F->dY_n_nz;
		return 0;

	} else if (eval_alg & JMI_DER_CPPAD) {
		if (jmi->dae->F->ad==NULL) {
			return -1;
		}
		*n_nz = jmi->dae->F->ad->dY_z_n_nz;
		return 0;
	} else {
		return -1;
	}
}

int jmi_dae_dF_nz_indices(jmi_t* jmi, int eval_alg, int* row, int* col) {
	if (eval_alg & JMI_DER_SYMBOLIC) {
		if (jmi->dae->F->dY==NULL) {
			return -1;
		}
		int i;
		for (i=0;i<jmi->dae->F->dY_n_nz;i++) {
			row[i] = jmi->dae->F->dY_irow[i];
			col[i] = jmi->dae->F->dY_icol[i];
		}
		return 0;

	} else if (eval_alg & JMI_DER_CPPAD) {
		if (jmi->dae->F->ad==NULL) {
			return -1;
		}
		int i;
		for (i=0;i<jmi->dae->F->ad->dY_z_n_nz;i++) {
			row[i] = jmi->dae->F->ad->dY_z_irow[i];
			col[i] = jmi->dae->F->ad->dY_z_icol[i];
		}
		return 0;
	} else {
		return -1;
	}
}



int jmi_dae_dF_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
		int *dF_n_cols, int *dF_n_nz) {
	if (eval_alg & JMI_DER_SYMBOLIC) {
		if (jmi->dae->F->dY==NULL) {
			return -1;
		}

		*dF_n_cols = 0;
		*dF_n_nz = 0;

		int i,j;
		int col_index = 0;

		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_CI, jmi->n_ci, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_CD, jmi->n_cd, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_PI, jmi->n_pi, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_PD, jmi->n_pd, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_DX, jmi->n_dx, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_X, jmi->n_x, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_U, jmi->n_u, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_W, jmi->n_w, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_T, 1, jmi->dae->F->dY_n_nz, jmi->dae->F->dY_icol)

		return 0;

	} else if (eval_alg & JMI_DER_CPPAD) {

		if (jmi->dae->F->ad==NULL) {
			return -1;
		}

		*dF_n_cols = 0;
		*dF_n_nz = 0;

		int i,j;
		int col_index = 0;

		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_CI, jmi->n_ci, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_CD, jmi->n_cd, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_PI, jmi->n_pi, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_PD, jmi->n_pd, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_DX, jmi->n_dx, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_X, jmi->n_x, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_U, jmi->n_u, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_W, jmi->n_w, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)
		JMI_DAE_COMPUTE_DF_DIM_PART(JMI_DER_T, 1, jmi->dae->F->ad->dY_z_n_nz, jmi->dae->F->ad->dY_z_icol)

		return 0;

	} else {
		return -1;
	}
}

