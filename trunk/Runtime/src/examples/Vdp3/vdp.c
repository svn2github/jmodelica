// Example of generated function

#include <stdio.h>
#include <stdlib.h>
#include "../../Jmi3/jmi.h"

static int vdp_dae_get_sizes(int* n_ci, int* n_cd, int* n_pi, int* n_pd,
		int* n_dx, int* n_x, int* n_u, int* n_w, int* n_eq_F){

	*n_ci = 0;
	*n_cd = 0;
	*n_pi = 1;
	*n_pd = 0;
	*n_dx = 3;
	*n_x = 3;
	*n_u = 1;
	*n_w = 0;
	*n_eq_F = 3;

	return 1;

}

static int vdp_dae_F(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
		Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
		Double_t t, Double_t* res) {

	res[0] = (1-x[1]*x[1])*x[0] - x[1] + u[0] - dx[0];
	res[1] = pi[0]*x[0] - dx[1];
	res[2] = x[0]*x[0] + x[1]*x[1] + u[0]*u[0] - dx[2];

	return 1;
}

static int vdp_dae_jac_sd_F(Jmi* jmi, Double_t* ci, Double_t* cd, Double_t* pi, Double_t* pd,
		Double_t* dx, Double_t* x, Double_t* u,
		Double_t* w, Double_t t, int sparsity, int skip, int* mask, Double_t* jac) {

	int jac_index = 0;
	int col_index = 0;
	if (!(skip & DER_PI_SKIP)) {
		if (mask[col_index++] == 1) {
			jac[jac_index++] = x[0];
		}
	} else {
		col_index += jmi->jmi_dae->n_pi;
	}

	if (!(skip & DER_DX_SKIP)) {
		if (mask[col_index++] == 1) {
			jac[jac_index++] = -1;
		}
		if (mask[col_index++] == 1) {
			jac[jac_index++] = -1;
		}
		if (mask[col_index++] == 1) {
			jac[jac_index++] = -1;
		}
	} else {
		col_index += jmi->jmi_dae->n_dx;
	}

	if (!(skip & DER_X_SKIP)) {
		if (mask[col_index++] == 1) {
			jac[jac_index++] = (1-x[1]*x[1]);
			jac[jac_index++] = pi[0];
			jac[jac_index++] = 2*x[0];
		}
		if (mask[col_index++] == 1) {
			jac[jac_index++] = -2*x[1]*x[0] - 1;
			jac[jac_index++] = 2*x[1];
		}
		if (mask[col_index++] == 1) {
		}
	} else {
		col_index += jmi->jmi_dae->n_x;
	}

	if (!(skip & DER_U_SKIP)) {
		if (mask[col_index++] == 1) {
			jac[jac_index++] = 1;
			jac[jac_index++] = 2*u[0];
		}
	} else {
		col_index += jmi->jmi_dae->n_u;
	}

	return 1;
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

	return 1;
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
	return 1;
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
	vdp_dae_get_sizes(&jmi_dae->n_ci, &jmi_dae->n_cd, &jmi_dae->n_pi, &jmi_dae->n_pd, &jmi_dae->n_dx,
			&jmi_dae->n_x, &jmi_dae->n_u, &jmi_dae->n_w, &jmi_dae->n_eq_F);
	return 1;
}

int jmi_delete(Jmi** jmi){
	Jmi* jmi_ = *jmi;
	if(jmi_->jmi_dae != NULL) {
		free(jmi_->jmi_dae);
	}
	if(jmi_->jmi_init != NULL) {
		free(jmi_->jmi_init);
	}
	if(jmi_->jmi_opt != NULL) {
		free(jmi_->jmi_opt);
	}
	free(jmi_);

	return 1;
}
