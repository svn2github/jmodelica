// Example of generated function


#include <stdio.h>
#include <stdlib.h>
#include <jmi.h>

static const int x1_0 = 0;
static const int x2_0 = 1;
static const int x3_0 = 2;

static const int N_ci = 0;
static const int N_cd = 0;
static const int N_pi = 1;
static const int N_pd = 0;
static const int N_dx = 3;
static const int N_x = 3;
static const int N_u = 1;
static const int N_w = 0;
static const int N_eq_F = 3;

static const int N_eq_F0 = 6;
static const int N_eq_F1 = 0;

static const int N_eq_Ceq = 0;
static const int N_eq_Cineq = 0;
static const int N_eq_Heq = 0;
static const int N_eq_Hineq = 0;

static const int N_t_p = 1;

#define ci(i) ((*(jmi->z))[jmi->offs_ci+i])
#define cd(i) ((*(jmi->z))[jmi->offs_cd+i])
#define pi(i) ((*(jmi->z))[jmi->offs_pi+i])
#define pd(i) ((*(jmi->z))[jmi->offs_pd+i])
#define dx(i) ((*(jmi->z))[jmi->offs_dx+i])
#define x(i) ((*(jmi->z))[jmi->offs_x+i])
#define u(i) ((*(jmi->z))[jmi->offs_u+i])
#define w(i) ((*(jmi->z))[jmi->offs_w+i])
#define tt ((*(jmi->z))[jmi->offs_t])
#define dx_p(j,i) ((*(jmi->z))[jmi->offs_dx_p + j*jmi->n_dx + i])
#define x_p(j,i) ((*(jmi->z))[jmi->offs_x_p + j*jmi->n_x + i])
#define u_p(j,i) ((*(jmi->z))[jmi->offs_u_p + j*jmi->n_u + i])
#define w_p(j,i) ((*(jmi->z))[jmi->offs_w_p + j*jmi->n_w + i])
#define tt_p(j) ((*(jmi->z))[jmi->offs_t_p+j])

/*
 * The res argument is of type pointer to a vector. This means that
 * in the case of no AD, the type of res is double**. This is
 * necessary in order to accommodate the AD case, in which case
 * the type of res is vector< CppAD::AD<double> >. In C++, it would
 * be ok to pass such an object by reference, using the & operator:
 * 'vector< CppAD::AD<double> > &res'. However, since we would like
 * to be able to compile the code both with a C and a C++ compiler
 * this solution does not work. Probably not too bad, since we can use
 * macros.
 */
static int vdp_dae_F(jmi_t* jmi, jmi_ad_var_vec_p res) {

  (*res)[0] = (1-x(1)*x(1))*x(0) - x(1) + u(0) - dx(0);
  (*res)[1] = pi(0)*x(0) - dx(1);
  (*res)[2] = x(0)*x(0) + x(1)*x(1) + u(0)*u(0) - dx(2);

  return 0;
}

/*
 * TODO: This code can certainly be improved and optimized. For example, macros would probably
 * make it easier to read.
 */

static int vdp_dae_dF(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	jmi_real_t* ci;
	jmi_real_t* cd;
	jmi_real_t* pi;
	jmi_real_t* pd;
	jmi_real_t* dx;
	jmi_real_t* x;
	jmi_real_t* u;
	jmi_real_t* w;
	jmi_real_t* t_;
	jmi_real_t t;

	jmi_get_ci(jmi, &ci);
	jmi_get_cd(jmi, &cd);
	jmi_get_pi(jmi, &pi);
	jmi_get_pd(jmi, &pd);
	jmi_get_dx(jmi, &dx);
	jmi_get_x(jmi, &x);
	jmi_get_u(jmi, &u);
	jmi_get_w(jmi, &w);
	jmi_get_t(jmi, &t_);

	t = t_[0];

	int i;
	int jac_n = N_eq_F;
	int col_index = 0;

	int jac_m;
	int jac_n_nz;
	jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	int jac_index = 0;
	col_index = 0;
	if ((independent_vars & JMI_DER_PI)) {
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = x[0];
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
		col_index += jmi->n_pi;
	}

	if ((independent_vars & JMI_DER_DX)) {
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
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
			jmi_real_t jac_tmp_1 = -1;
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
			jmi_real_t jac_tmp_1 = -1;
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
		col_index += jmi->n_dx;
	}

	if ((independent_vars & JMI_DER_X)) {
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = (1-x[1]*x[1]);
			jmi_real_t jac_tmp_2 = pi[0];
			jmi_real_t jac_tmp_3 = 2*x[0];
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
			jmi_real_t jac_tmp_1 = -2*x[1]*x[0] - 1;
			jmi_real_t jac_tmp_2 = 2*x[1];
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
		col_index += jmi->n_x;
	}

	if ((independent_vars & JMI_DER_U)) {
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = 1;
			jmi_real_t jac_tmp_2 = 2*u[0];
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
		col_index += jmi->n_u;
	}

	return 0;
}

static int vdp_dae_dF_n_nz(int* n_nz) {

	*n_nz = (1 + //pi
			0 + //pd
			3 + //dx
			5 + //x
			2 + //u
			0 + //w
			0 //t
			);

	return 0;
}

static int vdp_dae_dF_nz_indices(int* row, int* col) {

//	int i,j;
	int jac_ind = 0;
	int col_ind = 0;

	// Jacobian for independent parameters
    //dF/dpd_1
	row[jac_ind] = 2;
	col[jac_ind++] = 1;
	col_ind += N_pi;

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

	col_ind += N_dx;

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

	col_ind += N_x;

	// Jacobian for inputs
	//dF/du_2
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;

	col_ind += N_u;

	// Jacobian for algebraics
	col_ind += N_w;

	// Jacobian for time

	return 0;
}

static int vdp_init_F0(jmi_t* jmi, jmi_ad_var_vec_p res) {

  (*res)[0] = (1-x(1)*x(1))*x(0) - x(1) + u(0) - dx(0);
  (*res)[1] = pi(0)*x(0) - dx(1);
  (*res)[2] = x(0)*x(0) + x(1)*x(1) + u(0)*u(0) - dx(2);
  (*res)[3] = x(0) - x1_0;
  (*res)[4] = x(1) - x2_0;
  (*res)[5] = x(2) - x3_0;
  return 0;
}

static int vdp_init_dF0(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	jmi_real_t* ci;
	jmi_real_t* cd;
	jmi_real_t* pi;
	jmi_real_t* pd;
	jmi_real_t* dx;
	jmi_real_t* x;
	jmi_real_t* u;
	jmi_real_t* w;
	jmi_real_t* t_;
	jmi_real_t t;

	jmi_get_ci(jmi, &ci);
	jmi_get_cd(jmi, &cd);
	jmi_get_pi(jmi, &pi);
	jmi_get_pd(jmi, &pd);
	jmi_get_dx(jmi, &dx);
	jmi_get_x(jmi, &x);
	jmi_get_u(jmi, &u);
	jmi_get_w(jmi, &w);
	jmi_get_t(jmi, &t_);

	t = t_[0];

	int i;
	int jac_n = N_eq_F0;
	int col_index = 0;


	int jac_m;
	int jac_n_nz;
	jmi_init_dF0_dim(jmi,JMI_DER_SYMBOLIC,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	int jac_index = 0;
	col_index = 0;
	if ((independent_vars & JMI_DER_PI)) {
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = x[0];
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
		col_index += jmi->n_pi;
	}

	if ((independent_vars & JMI_DER_DX)) {
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
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
			jmi_real_t jac_tmp_1 = -1;
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
			jmi_real_t jac_tmp_1 = -1;
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
		col_index += jmi->n_dx;
	}

	if ((independent_vars & JMI_DER_X)) {
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = (1-x[1]*x[1]);
			jmi_real_t jac_tmp_2 = pi[0];
			jmi_real_t jac_tmp_3 = 2*x[0];
			jmi_real_t jac_tmp_4 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*4 + 0] = jac_tmp_1;
				jac[jac_n*4 + 1] = jac_tmp_2;
				jac[jac_n*4 + 2] = jac_tmp_3;
				jac[jac_n*4 + 3] = jac_tmp_4;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + 4] = jac_tmp_1;
				jac[jac_m*1 + 4] = jac_tmp_2;
				jac[jac_m*2 + 4] = jac_tmp_3;
				jac[jac_m*3 + 4] = jac_tmp_4;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
				jac[jac_index++] = jac_tmp_3;
				jac[jac_index++] = jac_tmp_4;
			}
		}
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -2*x[1]*x[0] - 1;
			jmi_real_t jac_tmp_2 = 2*x[1];
			jmi_real_t jac_tmp_3 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*5 + 0] = jac_tmp_1;
				jac[jac_n*5 + 2] = jac_tmp_2;
				jac[jac_n*5 + 4] = jac_tmp_3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + 5] = jac_tmp_1;
				jac[jac_m*2 + 5] = jac_tmp_2;
				jac[jac_m*4 + 5] = jac_tmp_3;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
				jac[jac_index++] = jac_tmp_3;
			}
		}
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*6 + 5] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*5 + 6] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
			}

		}
	} else {
		col_index += jmi->n_x;
	}

	if ((independent_vars & JMI_DER_U)) {
		if (mask[col_index++] == 1) {
			jmi_real_t jac_tmp_1 = 1;
			jmi_real_t jac_tmp_2 = 2*u[0];
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
		col_index += jmi->n_u;
	}

	return 0;
}

static int vdp_init_dF0_n_nz(int* n_nz) {

	*n_nz = (1 + //pi
			0 + //pd
			3 + //dx
			5 + 3 + //x
			2 + //u
			0 + //w
			0 //t
			);

	return 0;
}

static int vdp_init_dF0_nz_indices(int* row, int* col) {

//	int i,j;
	int jac_ind = 0;
	int col_ind = 0;

	// Jacobian for independent parameters
    //dF/dpd_1
	row[jac_ind] = 2;
	col[jac_ind++] = 1;
	col_ind += N_pi;

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

	col_ind += N_dx;

	// Jacobian for states
	//dF/dx_1
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 2;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 4;
	col[jac_ind++] = col_ind + 1;

	//dF/dx_2
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 2;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 2;
	row[jac_ind] = 5;
	col[jac_ind++] = col_ind + 1;

	//dF/dx_3
	row[jac_ind] = 6;
	col[jac_ind++] = col_ind + 1;

	col_ind += N_x;

	// Jacobian for inputs
	//dF/du_2
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;

	col_ind += N_u;

	// Jacobian for algebraics
	col_ind += N_w;

	// Jacobian for time

	return 0;
}


static int vdp_init_F1(jmi_t* jmi, jmi_ad_var_vec_p res) {

  return -1;
}

static int vdp_init_dF1(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	return -1;
}

static int vdp_init_dF1_n_nz(int* n_nz) {

	*n_nz = 0;
	return -1;
}

static int vdp_init_dF1_nz_indices(int* row, int* col) {

	return -1;
}

static int vdp_opt_J(jmi_t* jmi, jmi_ad_var_vec_p res) {
	(*res)[0] = x_p(0,2);
  return 0;
}

static int vdp_opt_dJ(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	int i;
	int jac_n = 1;
	int col_index = 0;


	int jac_m;
	int jac_n_nz;
	jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	col_index = jmi->offs_x_p;
	if ((independent_vars & JMI_DER_X_P)) {
		if (mask[col_index] == 1) {
			jmi_real_t jac_tmp_1 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[col_index] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[0] = jac_tmp_1;
			}
		}
	}

	return 0;
}

static int vdp_opt_dJ_n_nz(int* n_nz) {

	*n_nz = 1;
	return 0;
}

static int vdp_opt_dJ_nz_indices(int* row, int* col) {
	row[0] = 1;
	col[0] = 1 + // p_i
	         3 + // dx
	         3 + // x
	         1 + // u
	         1 + // t
	         3 + // dx_p
	         2;  // x_p_3
	return 0;
}


static int vdp_opt_Ceq(jmi_t* jmi, jmi_ad_var_vec_p res) {

  return -1;
}

static int vdp_opt_dCeq(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	return -1;
}

static int vdp_opt_dCeq_n_nz(int* n_nz) {

	*n_nz = 0;
	return -1;
}

static int vdp_opt_dCeq_nz_indices(int* row, int* col) {

	return -1;
}

static int vdp_opt_Cineq(jmi_t* jmi, jmi_ad_var_vec_p res) {

  return -1;
}

static int vdp_opt_dCineq(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	return -1;
}

static int vdp_opt_dCineq_n_nz(int* n_nz) {

	*n_nz = 0;
	return -1;
}

static int vdp_opt_dCineq_nz_indices(int* row, int* col) {

	return -1;
}
static int vdp_opt_Heq(jmi_t* jmi, jmi_ad_var_vec_p res) {

  return -1;
}

static int vdp_opt_dHeq(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	return -1;
}

static int vdp_opt_dHeq_n_nz(int* n_nz) {

	*n_nz = 0;
	return -1;
}

static int vdp_opt_dHeq_nz_indices(int* row, int* col) {

	return -1;
}
static int vdp_opt_Hineq(jmi_t* jmi, jmi_ad_var_vec_p res) {

  return -1;
}

static int vdp_opt_dHineq(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	return -1;
}

static int vdp_opt_dHineq_n_nz(int* n_nz) {

	*n_nz = 0;
	return -1;
}

static int vdp_opt_dHineq_nz_indices(int* row, int* col) {

	return -1;
}

// This is the new function
int jmi_new(jmi_t** jmi) {


	jmi_init(jmi, N_ci, N_cd, N_pi, N_pd, N_dx,
			      N_x, N_u, N_w, N_t_p);

	// Initialize the DAE interface
	int dF_n_nz;
	vdp_dae_dF_n_nz(&dF_n_nz);
	int* dF_irow = (int*)calloc(dF_n_nz,sizeof(int));
	int* dF_icol = (int*)calloc(dF_n_nz,sizeof(int));
	vdp_dae_dF_nz_indices(dF_irow,dF_icol);
	jmi_dae_init(*jmi, *vdp_dae_F, N_eq_F, *vdp_dae_dF,
			          dF_n_nz, dF_irow, dF_icol);

	// Initialize the Init interface
	int dF0_n_nz;
	vdp_init_dF0_n_nz(&dF0_n_nz);
	int* dF0_irow = (int*)calloc(dF0_n_nz,sizeof(int));
	int* dF0_icol = (int*)calloc(dF0_n_nz,sizeof(int));
	vdp_init_dF0_nz_indices(dF0_irow,dF0_icol);
	int dF1_n_nz;
	vdp_init_dF1_n_nz(&dF1_n_nz);
	int* dF1_irow = (int*)calloc(dF1_n_nz,sizeof(int));
	int* dF1_icol = (int*)calloc(dF1_n_nz,sizeof(int));
	vdp_init_dF1_nz_indices(dF1_irow,dF1_icol);
	jmi_init_init(*jmi, *vdp_init_F0, N_eq_F0, *vdp_init_dF0,
			          dF0_n_nz, dF0_irow, dF0_icol,
			            *vdp_init_F1, N_eq_F1, *vdp_init_dF1,
			            dF1_n_nz, dF1_irow, dF1_icol);

	int dJ_n_nz;
	vdp_opt_dJ_n_nz(&dJ_n_nz);
	int* dJ_irow = (int*)calloc(dJ_n_nz,sizeof(int));
	int* dJ_icol = (int*)calloc(dJ_n_nz,sizeof(int));
	vdp_opt_dJ_nz_indices(dJ_irow,dJ_icol);

	int dCeq_n_nz;
	vdp_opt_dCeq_n_nz(&dCeq_n_nz);
	int* dCeq_irow = (int*)calloc(dCeq_n_nz,sizeof(int));
	int* dCeq_icol = (int*)calloc(dCeq_n_nz,sizeof(int));
	vdp_opt_dCeq_nz_indices(dCeq_irow,dCeq_icol);

	int dCineq_n_nz;
	vdp_opt_dCineq_n_nz(&dCineq_n_nz);
	int* dCineq_irow = (int*)calloc(dCineq_n_nz,sizeof(int));
	int* dCineq_icol = (int*)calloc(dCineq_n_nz,sizeof(int));
	vdp_opt_dCineq_nz_indices(dCineq_irow,dCineq_icol);

	int dHeq_n_nz;
	vdp_opt_dHeq_n_nz(&dHeq_n_nz);
	int* dHeq_irow = (int*)calloc(dHeq_n_nz,sizeof(int));
	int* dHeq_icol = (int*)calloc(dHeq_n_nz,sizeof(int));
	vdp_opt_dHeq_nz_indices(dHeq_irow,dHeq_icol);

	int dHineq_n_nz;
	vdp_opt_dHineq_n_nz(&dHineq_n_nz);
	int* dHineq_irow = (int*)calloc(dHineq_n_nz,sizeof(int));
	int* dHineq_icol = (int*)calloc(dHineq_n_nz,sizeof(int));
	vdp_opt_dHineq_nz_indices(dHineq_irow,dHineq_icol);

	jmi_opt_init(*jmi, *vdp_opt_J, *vdp_opt_dJ, dJ_n_nz, dJ_irow, dJ_icol,
	           *vdp_opt_Ceq, N_eq_Ceq, *vdp_opt_dCeq, dCeq_n_nz, dCeq_irow, dCeq_icol,
	           *vdp_opt_Cineq, N_eq_Cineq, *vdp_opt_dCineq, dCineq_n_nz, dCineq_irow, dCineq_icol,
	           *vdp_opt_Heq, N_eq_Heq, *vdp_opt_dHeq, dHeq_n_nz, dHeq_irow, dHeq_icol,
	           *vdp_opt_Hineq, N_eq_Hineq, *vdp_opt_dHineq, dHineq_n_nz, dHineq_irow, dHineq_icol);

	free(dF_irow);
	free(dF_icol);
	free(dF0_irow);
	free(dF0_icol);
	free(dF1_irow);
	free(dF1_icol);
	free(dJ_icol);
	free(dJ_irow);
	free(dCeq_icol);
	free(dCeq_irow);
	free(dCineq_icol);
	free(dCineq_irow);
	free(dHeq_icol);
	free(dHeq_irow);
	free(dHineq_icol);
	free(dHineq_irow);

	return 0;
}
