// Example of generated function

#include <stdio.h>
#include <stdlib.h>
#include "../../Jmi/jmi_cppad.hpp"

static const int N_ci = 0;
static const int N_cd = 0;
static const int N_pi = 1;
static const int N_pd = 0;
static const int N_dx = 3;
static const int N_x = 3;
static const int N_u = 1;
static const int N_w = 0;
static const int N_eq_F = 3;

static int vdp_dae_F(Jmi* jmi, Jmi_Double_t* ci, Jmi_Double_t* cd, Jmi_Double_t* pi, Jmi_Double_t* pd,
		Jmi_Double_t* dx, Jmi_Double_t* x, Jmi_Double_t* u, Jmi_Double_t* w,
		Jmi_Double_t t, Jmi_Double_t* res) {

  res[0] = (1-x[1]*x[1])*x[0] - x[1] + u[0] - dx[0];
  res[1] = pi[0]*x[0] - dx[1];
  res[2] = x[0]*x[0] + x[1]*x[1] + u[0]*u[0] - dx[2];
  
  return 0;
}

int vdp_cppad_dae_F(Jmi* jmi, Jmi_AD_vec &ci, Jmi_AD_vec &cd, Jmi_AD_vec &pi, Jmi_AD_vec &pd,
		Jmi_AD_vec &dx, Jmi_AD_vec &x, Jmi_AD_vec &u, Jmi_AD_vec &w,
		    Jmi_AD &t, Jmi_AD_vec &res){

  res[0] = (1-x[1]*x[1])*x[0] - x[1] + u[0] - dx[0];
  res[1] = pi[0]*x[0] - dx[1];
  res[2] = x[0]*x[0] + x[1]*x[1] + u[0]*u[0] - dx[2];
  
  return 0;
}

/*
 * TODO: This code can certainly be improved and optimized. For example, macros would probably
 * make it easier to read.
 */
static int vdp_dae_jac_sd_F(Jmi* jmi, Jmi_Double_t* ci, Jmi_Double_t* cd, Jmi_Double_t* pi, Jmi_Double_t* pd,
		Jmi_Double_t* dx, Jmi_Double_t* x, Jmi_Double_t* u,
		Jmi_Double_t* w, Jmi_Double_t t, int sparsity, int skip, int* mask, Jmi_Double_t* jac) {

	int i;
	int jac_n = N_eq_F;
	int jac_m = 0;
	int col_index = 0;

	if (!(skip & JMI_DER_PI_SKIP)) {
		for (i=0;i<N_pi;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_PD_SKIP)) {
		for (i=0;i<N_pd;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_DX_SKIP)) {
		for (i=0;i<N_dx;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_X_SKIP)) {
		for (i=0;i<N_x;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_U_SKIP)) {
		for (i=0;i<N_u;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_W_SKIP)) {
		for (i=0;i<N_w;i++) {
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
	if (!(skip & JMI_DER_PI_SKIP)) {
		if (mask[col_index++] == 1) {
			Jmi_Double_t jac_tmp_1 = x[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*0 + 1] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*1 + 0] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
		}
	} else {
		col_index += jmi->jmi_dae->n_pi;
	}

	if (!(skip & JMI_DER_DX_SKIP)) {
		if (mask[col_index++] == 1) {
			Jmi_Double_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*1 + 0] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + 1] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
		}
		if (mask[col_index++] == 1) {
			Jmi_Double_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*2 + 1] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*1 + 2] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
		}
		if (mask[col_index++] == 1) {
			Jmi_Double_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*3 + 2] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*2 + 3] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
		}
	} else {
		col_index += jmi->jmi_dae->n_dx;
	}

	if (!(skip & JMI_DER_X_SKIP)) {
		if (mask[col_index++] == 1) {
			Jmi_Double_t jac_tmp_1 = (1-x[1]*x[1]);
			Jmi_Double_t jac_tmp_2 = pi[0];
			Jmi_Double_t jac_tmp_3 = 2*x[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*4 + 0] = jac_tmp_1;
				jac[jac_n*4 + 1] = jac_tmp_2;
				jac[jac_n*4 + 2] = jac_tmp_3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + 4] = jac_tmp_1;
				jac[jac_m*1 + 4] = jac_tmp_2;
				jac[jac_m*2 + 4] = jac_tmp_3;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
				jac[jac_index++] = jac_tmp_3;
			}
		}
		if (mask[col_index++] == 1) {
			Jmi_Double_t jac_tmp_1 = -2*x[1]*x[0] - 1;
			Jmi_Double_t jac_tmp_2 = 2*x[1];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*5 + 0] = jac_tmp_1;
				jac[jac_n*5 + 2] = jac_tmp_2;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + 5] = jac_tmp_1;
				jac[jac_m*2 + 5] = jac_tmp_2;
				jac_index += 3;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
			}
		}
		if (mask[col_index++] == 1) {
		}
	} else {
		col_index += jmi->jmi_dae->n_x;
	}

	if (!(skip & JMI_DER_U_SKIP)) {
		if (mask[col_index++] == 1) {
			Jmi_Double_t jac_tmp_1 = 1;
			Jmi_Double_t jac_tmp_2 = 2*u[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*7 + 0] = jac_tmp_1;
				jac[jac_n*7 + 2] = jac_tmp_2;
				jac_index += 3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + 7] = jac_tmp_1;
				jac[jac_m*2 + 7] = jac_tmp_2;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
			}

		}
	} else {
		col_index += jmi->jmi_dae->n_u;
	}

	return 0;
}

static int vdp_dae_jac_sd_F_nnz(Jmi* jmi, int* nnz) {

	*nnz = (1 + //pi
			0 + //pd
			3 + //dx
			5 + //x
			2 + //u
			0 + //w
			0 //t
			);

	return 0;
}

static int vdp_dae_jac_sd_F_nz_indices(Jmi* jmi, int* row, int* col) {

//	int i,j;
	int jac_ind = 0;
	int col_ind = 0;

	// Jacobian for independent parameters
    //dF/dpd_1
	row[jac_ind] = 2;
	col[jac_ind++] = 1;
	col_ind += jmi->jmi_dae->n_pi;

	// Jacobian for dependent parameters

	// Jacobian for derivatives
	//dF/ddx_1
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 1;
	//dF/ddx_2
	row[jac_ind] = 2;
	col[jac_ind++] = col_ind + 2;
	//dF/ddx_3
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 3;

	col_ind += jmi->jmi_dae->n_dx;

	// Jacobian for states
	//dF/dx_1
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 2;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;
	//dF/dx_2
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 2;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 2;
	//dF/dx_3

	col_ind += jmi->jmi_dae->n_x;

	// Jacobian for inputs
	//dF/du_2
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;

	col_ind += jmi->jmi_dae->n_u;

	// Jacobian for algebraics
	col_ind += jmi->jmi_dae->n_w;

	// Jacobian for time



	/*
	// Template for dense Jacobian...

	// Jacobian for independent parameters
	for (j=col_ind;j<jmi->jmi_dae->n_pi+col_ind;j++) {
		for (i=0;i<jmi->jmi_dae->n_eq_F;i++) {
			row[jac_ind] = i+1;
			col[jac_ind++] = j+1;
		}
	}

	col_ind += jmi->jmi_dae->n_pi;
	// Jacobian for dependent parameters
	for (j=col_ind;j<jmi->jmi_dae->n_pd+col_ind;j++) {
		for (i=0;i<jmi->jmi_dae->n_eq_F;i++) {
			row[jac_ind] = i+1;
			col[jac_ind++] = j+1;
		}
	}

	col_ind += jmi->jmi_dae->n_pd;
	// Jacobian for derivatives
	for (j=col_ind;j<jmi->jmi_dae->n_dx+col_ind;j++) {
		for (i=0;i<jmi->jmi_dae->n_eq_F;i++) {
			row[jac_ind] = i+1;
			col[jac_ind++] = j+1;
		}
	}

	col_ind += jmi->jmi_dae->n_dx;
	// Jacobian for states
	for (j=col_ind;j<jmi->jmi_dae->n_x+col_ind;j++) {
		for (i=0;i<jmi->jmi_dae->n_eq_F;i++) {
			row[jac_ind] = i+1;
			col[jac_ind++] = j+1;
		}
	}

	col_ind += jmi->jmi_dae->n_x;
	// Jacobian for inputs
	for (j=col_ind;j<jmi->jmi_dae->n_u+col_ind;j++) {
		for (i=0;i<jmi->jmi_dae->n_eq_F;i++) {
			row[jac_ind] = i+1;
			col[jac_ind++] = j+1;
		}
	}

	col_ind += jmi->jmi_dae->n_u;
	// Jacobian for algebraics
	for (j=col_ind;j<jmi->jmi_dae->n_w+col_ind;j++) {
		for (i=0;i<jmi->jmi_dae->n_eq_F;i++) {
			row[jac_ind] = i+1;
			col[jac_ind++] = j+1;
		}
	}

	col_ind += jmi->jmi_dae->n_w;
	// Jacobian for time
	for (j=col_ind;j<1+col_ind;j++) {
		for (i=0;i<jmi->jmi_dae->n_eq_F;i++) {
			row[jac_ind] = i+1;
			col[jac_ind++] = j+1;
		}
	}
    */
	return 0;
}



// This is the init function
int jmi_new(Jmi** jmi) {
  // Create jmi struct
  *jmi = (Jmi*)calloc(1,sizeof(Jmi));
  Jmi* jmi_ = *jmi;
  // Create jmi_dae struct
  Jmi_dae* jmi_dae = (Jmi_dae*)calloc(1,sizeof(Jmi_dae));
  // Set struct pointers in jmi
  jmi_->jmi_dae = jmi_dae;
  jmi_->jmi_init = NULL;
  jmi_->jmi_opt = NULL;
  jmi_->jmi_dae_der = NULL;
  jmi_->jmi_init_der = NULL;
  jmi_->jmi_opt_der = NULL;
  // Assign function pointers
  jmi_dae->F = vdp_dae_F;
  jmi_dae->jac_sd_F = vdp_dae_jac_sd_F;
  jmi_dae->jac_sd_F_nnz = vdp_dae_jac_sd_F_nnz;
  jmi_dae->jac_sd_F_nz_indices = vdp_dae_jac_sd_F_nz_indices;
  // Set sizes of dae vectors
  jmi_dae->n_ci = N_ci;
  jmi_dae->n_cd = N_cd;
  jmi_dae->n_pi = N_pi;
  jmi_dae->n_pd = N_pd;
  jmi_dae->n_dx = N_dx;
  jmi_dae->n_x = N_x;
  jmi_dae->n_u = N_u;
  jmi_dae->n_w = N_w;
  jmi_dae->n_eq_F = N_eq_F;
  
  jmi_cppad_new(jmi_, vdp_cppad_dae_F);



  return 0;
}

int jmi_delete(Jmi* jmi){

	if(jmi->jmi_dae != NULL) {
		free(jmi->jmi_dae);
	}
	if(jmi->jmi_init != NULL) {
		free(jmi->jmi_init);
	}
	if(jmi->jmi_opt != NULL) {
		free(jmi->jmi_opt);
	}
	// TODO: Check der structs if not NULL return error and the user has to deallocate them first.
	if(jmi->jmi_dae_der != NULL) {
	  jmi_cppad_delete(jmi);
	}
	

	free(jmi);

	return 0;
}


