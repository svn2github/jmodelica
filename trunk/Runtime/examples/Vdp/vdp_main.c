
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <jmi.h>
#include <jmi_opt_sim.h>
#include <jmi_opt_sim_ipopt.h>

#define TEST_VERB 1
#define SMALL 1e-10

// Signature of test functions
typedef int (*test_function_t)(int verbose);

// Run a test function
int test_function(test_function_t tf, char *name, int verbose, int *nbr_test_ok, int *nbr_test_fail) {
	int retval = tf(verbose);
	if (retval == 0) {
		printf(">>> test %s OK! <<<\n",name);
		(*nbr_test_ok)++;
	} else {
		printf(">>> test %s FAIL! <<<\n",name);
		(*nbr_test_fail)++;
	}
	return retval;
}

// Global variables
static jmi_t *jmi;
static int n_ci, n_cd, n_pi, n_pd, n_dx, n_x, n_u, n_w, n_tp, n_z, n_eq_F;
static int offs_ci, offs_cd, offs_pi, offs_pd, offs_dx, offs_x, offs_u, offs_w, offs_t,
    offs_dx_p, offs_x_p, offs_u_p, offs_w_p;

static int dF_n_nz;
static int* dF_row;
static int* dF_col;
static int dF_n_dense;
static jmi_real_t* res_F;
static jmi_real_t* dF_sparse;
static jmi_real_t* dF_dense;

static int dJ_n_nz;
static int* dJ_row;
static int* dJ_col;
static int dJ_n_dense;
static jmi_real_t J;
static jmi_real_t* dJ_sparse;
static jmi_real_t* dJ_dense;

static jmi_real_t* ci;
static jmi_real_t* cd;
static jmi_real_t* pi;
static jmi_real_t* pd;
static jmi_real_t* dx;
static jmi_real_t* x;
static jmi_real_t* u;
static jmi_real_t* w;
static jmi_real_t* t;

static jmi_real_t* dx_p_1;
static jmi_real_t* x_p_1;
static jmi_real_t* u_p_1;
static jmi_real_t* w_p_1;

static jmi_real_t* dx_p_2;
static jmi_real_t* x_p_2;
static jmi_real_t* u_p_2;
static jmi_real_t* w_p_2;

static int* mask;

static jmi_opt_sim_t *jmi_opt_sim;
static jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt;


// Initialize the model
void init_model() {

	int i;

	jmi_new(&jmi);

	jmi_get_sizes(jmi, &n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_tp, &n_z);
	jmi_get_offsets(jmi, &offs_ci, &offs_cd, &offs_pi, &offs_pd, &offs_dx, &offs_x, &offs_u, &offs_w, &offs_t,
		&offs_dx_p, &offs_x_p, &offs_u_p, &offs_w_p);
	jmi_dae_get_sizes(jmi, &n_eq_F);

	jmi_dae_dF_n_nz(jmi,JMI_DER_SYMBOLIC,&dF_n_nz);
	dF_row = (int*)calloc(dF_n_nz,sizeof(int));
	dF_col = (int*)calloc(dF_n_nz,sizeof(int));

	dF_n_dense = n_z * n_eq_F;

	jmi_opt_dJ_n_nz(jmi,JMI_DER_SYMBOLIC,&dJ_n_nz);
	dJ_row = (int*)calloc(dJ_n_nz,sizeof(int));
	dJ_col = (int*)calloc(dJ_n_nz,sizeof(int));

	dJ_n_dense = n_z;

	ci = jmi_get_ci(jmi);
	cd = jmi_get_cd(jmi);
	pi = jmi_get_pi(jmi);
	pd = jmi_get_pd(jmi);
	dx = jmi_get_dx(jmi);
	x = jmi_get_x(jmi);
	u = jmi_get_u(jmi);
	w = jmi_get_w(jmi);
	t = jmi_get_t(jmi);

	dx_p_1 = jmi_get_dx_p(jmi,0);
	x_p_1 = jmi_get_x_p(jmi,0);
	u_p_1 = jmi_get_u_p(jmi,0);
	w_p_1 = jmi_get_w_p(jmi,0);

	dx_p_2 = jmi_get_dx_p(jmi,1);
	x_p_2 = jmi_get_x_p(jmi,1);
	u_p_2 = jmi_get_u_p(jmi,1);
	w_p_2 = jmi_get_w_p(jmi,1);

	res_F = (jmi_real_t*)calloc(n_eq_F,sizeof(jmi_real_t));
	dF_sparse = (jmi_real_t*)calloc(dF_n_nz,sizeof(jmi_real_t));
	dF_dense = (jmi_real_t*)calloc(dF_n_dense,sizeof(jmi_real_t));

	dJ_sparse = (jmi_real_t*)calloc(dJ_n_nz,sizeof(jmi_real_t));
	dJ_dense = (jmi_real_t*)calloc(dJ_n_dense,sizeof(jmi_real_t));

	mask = (int*)calloc(n_z,sizeof(int));
	for(i=0;i<n_z;i++) {
		mask[i]=1;
	}

}

// Delete model
void delete_model() {

	jmi_delete(jmi);

	free(res_F);
	free(dF_sparse);
	free(dF_dense);
	free(mask);
	free(dF_row);
	free(dF_col);
}

// Test evaluation of DAE residual
int test_1_dae_F(int verbose) {

	int i;

	// Initialize the variables
    pi[0] = 1;
    pi[1] = 1;
    pi[2] = 2;
    dx[0] = 1;
    dx[1] = 1;
    dx[2] = 2;
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;
	u[0] = 4;
	w[0] = 3;
	t[0] = 1;

	jmi_dae_F(jmi,res_F);

	jmi_real_t res_fix[4] = {-2,0,153.1701780775437,0};
	jmi_real_t err_sum = 0;
	for (i=0;i<n_eq_F;i++) {
		err_sum += abs(res_fix[i] - res_F[i]);
	}

	if (verbose == 1) {
		int i;
		printf("*** test_1_dae_F start ***\n");
		printf("p = {%f}\n",pi[0]);
		printf("dx = {%f,%f,%f}\n",dx[0],dx[1],dx[2]);
		printf("x = {%f,%f,%f}\n",x[0],x[1],x[2]);
		printf("u = {%f}\n",u[0]);
		printf("w = {%f}\n",w[0]);
		printf("t = {%f}\n",t[0]);

		printf("F=\n");
		for (i=0;i<n_eq_F;i++){
			printf("res[%d] = %f\n",i,res_F[i]);
		}
		printf("*** test_1_dae_F end ***\n");
	}

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dF sparse indices
int test_2_dae_dF_indices(int verbose) {

	int i;

	jmi_dae_dF_nz_indices(jmi,JMI_DER_SYMBOLIC,JMI_DER_ALL,mask,dF_row,dF_col);

	if (verbose == 1) {
		int i;
		printf("*** test_2_dae_dF_indices start ***\n");
		printf("Number of non-zeros in the DAE residual Jacobian: %d\n",dF_n_nz);
		for (i=0;i<dF_n_nz;i++) {
			printf("%d, %d\n",dF_row[i],dF_col[i]);
		}
		printf("*** test_2_dae_dF_indices end ***\n");
	}

	int dF_row_fix[16] = {2,3,1,2,3,1,2,3,4,1,3,4,1,3,4,3};
	int dF_col_fix[16] = {1,3,4,5,6,7,7,7,7,8,8,8,10,10,11,12};

	int err_sum = 0;
	for (i=0;i<dF_n_nz;i++) {
		err_sum += abs(dF_row_fix[i] - dF_row[i]);
		err_sum += abs(dF_col_fix[i] - dF_col[i]);
	}

	if (err_sum==0) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dF dimensions
int test_3_dae_dF_dim(int verbose) {

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_ROW_MAJOR,JMI_DER_X,mask,&dF_n_cols_test,&dF_n_nz_test);

	if (verbose == 1) {
		printf("*** test_3_dae_dF_indices start ***\n");
		printf("Dense dF_dx: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_3_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 12;
	int dF_n_cols_fix = 3;

	if (dF_n_nz_fix == dF_n_nz_test && dF_n_cols_fix == dF_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dF dimenstions
int test_4_dae_dF_dim(int verbose) {

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_X,mask,&dF_n_cols_test,&dF_n_nz_test);

	if (verbose == 1) {
		printf("*** test_4_dae_dF_indices start ***\n");
		printf("Sparse dF_dx: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_4_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 7;
	int dF_n_cols_fix = 3;

	if (dF_n_nz_fix == dF_n_nz_test && dF_n_cols_fix == dF_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dF dimenstions
int test_5_dae_dF_dim(int verbose) {

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
    		         JMI_DER_DX | JMI_DER_X | JMI_DER_W,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	if (verbose == 1) {
		printf("*** test_5_dae_dF_indices start ***\n");
		printf("Sparse dF_ddx_dx_dw: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_5_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 11;
	int dF_n_cols_fix = 7;

	if (dF_n_nz_fix == dF_n_nz_test && dF_n_cols_fix == dF_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dF dimenstions
int test_6_dae_dF_dim(int verbose) {

	mask[5] = 0; // mask dx_3
	mask[7] = 0; // mask x_2

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
    		         JMI_DER_DX | JMI_DER_X | JMI_DER_W,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	mask[5] = 1;
	mask[7] = 1;

	if (verbose == 1) {
		printf("*** test_6_dae_dF_indices start ***\n");
		printf("Sparse dF_ddx_dx_dw (dx_3 and x_2 masked): dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_6_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 7;
	int dF_n_cols_fix = 5;

	if (dF_n_nz_fix == dF_n_nz_test && dF_n_cols_fix == dF_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dF dimenstions
int test_7_dae_dF_dim(int verbose) {

	mask[5] = 0; // mask dx_3
	mask[7] = 0; // mask x_2

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,
    		         JMI_DER_DX | JMI_DER_X | JMI_DER_W,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	mask[5] = 1;
	mask[7] = 1;

	if (verbose == 1) {
		printf("*** test_7_dae_dF_indices start ***\n");
		printf("Dense dF_ddx_dx_dw (dx_3 and x_2 masked): dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_7_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 20;
	int dF_n_cols_fix = 5;

	if (dF_n_nz_fix == dF_n_nz_test && dF_n_cols_fix == dF_n_cols_test) {
		return 0;
	} else {
		return -1;
	}
}

// Test computation of dF dimenstions
int test_8_dae_dF_dim(int verbose) {

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,
    		         JMI_DER_ALL,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	if (verbose == 1) {
		printf("*** test_8_dae_dF_indices start ***\n");
		printf("Dense dF: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_8_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 28*4;
	int dF_n_cols_fix = 28; // Including variables for two time points

	if (dF_n_nz_fix == dF_n_nz_test && dF_n_cols_fix == dF_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dF dimenstions
int test_9_dae_dF_dim(int verbose) {

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
    		         JMI_DER_ALL,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	if (verbose == 1) {
		printf("*** test_9_dae_dF_indices start ***\n");
		printf("Sparse dF: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_9_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 16;
	int dF_n_cols_fix = 28;  // Including variables for two time points

	if (dF_n_nz_fix == dF_n_nz_test && dF_n_cols_fix == dF_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test evaluation of dF using JMI_DER_SPARSE
int test_10_dae_dF_eval(int verbose) {

	int i;
	// Initialize the variables
    pi[0] = 1;
    pi[1] = 1;
    pi[2] = 2;
    dx[0] = 1;
    dx[1] = 1;
    dx[2] = 2;
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;
	u[0] = 4;
	w[0] = 3;
	t[0] = 1;

	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_ALL,mask,dF_sparse);

	if (verbose == 1) {
		printf("*** test_10_dae_dF_eval start ***\n");
		printf("Jacobian (sparse):\n");
		for (i=0;i<dF_n_nz;i++) {
			printf("%f\n",dF_sparse[i]);
		}
		printf("*** test_10_dae_dF_eval end ***\n");
	}

	jmi_real_t jac_fix[16] = {1, 1.551701780775437e+02,-1, -1, -1, -3, 1, 14.778112197861301,
			                  1, -5, 29.556224395722602, 1, 1, 59.112448791445203, -1,
			                  3.103403561550873e+02};
	jmi_real_t err_sum = 0;
	for (i=0;i<dF_n_nz;i++) {
		err_sum += abs(jac_fix[i] - dF_sparse[i]);
	}

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}

}

// Evaluation of dF using JMI_DER_DENSE_COL_MAJOR
int test_11_dae_dF_eval(int verbose) {

	int i;
	// Initialize the variables
    pi[0] = 1;
    pi[1] = 1;
    pi[2] = 2;
    dx[0] = 1;
    dx[1] = 1;
    dx[2] = 2;
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;
	u[0] = 4;
	w[0] = 3;
	t[0] = 1;

	jmi_dae_dF_nz_indices(jmi,JMI_DER_SYMBOLIC,JMI_DER_ALL,mask,dF_row,dF_col);

	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,JMI_DER_ALL,mask,dF_dense);

	jmi_real_t jac_fix_sparse[16] = {1, 1.551701780775437e+02,-1, -1, -1, -3, 1, 14.778112197861301,
			                  1, -5, 29.556224395722602, 1, 1, 59.112448791445203, -1,
			                  3.103403561550873e+02};

	jmi_real_t *jac_fix_dense = (jmi_real_t*)calloc(dF_n_dense,sizeof(jmi_real_t));

	for (i=0;i<dF_n_nz;i++) {
		jac_fix_dense[dF_row[i]-1 + (dF_col[i]-1)*n_eq_F] = jac_fix_sparse[i];
	}

	if (verbose == 1) {
		printf("*** test_11_dae_dF_eval start ***\n");
		printf("Jacobian (dense col major):\n");
		for (i=0;i<dF_n_dense;i++) {
			printf("%f, %f\n",dF_dense[i], jac_fix_dense[i]);
		}
		printf("*** test_11_dae_dF_eval end ***\n");
	}

	jmi_real_t err_sum = 0;
	for (i=0;i<dF_n_nz;i++) {
		err_sum += abs(jac_fix_dense[i] - dF_dense[i]);
	}

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}

}

// Evaluation of dF using JMI_DER_DENSE_ROW_MAJOR
int test_12_dae_dF_eval(int verbose) {

	int i;
	// Initialize the variables
    pi[0] = 1;
    pi[1] = 1;
    pi[2] = 2;
    dx[0] = 1;
    dx[1] = 1;
    dx[2] = 2;
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;
	u[0] = 4;
	w[0] = 3;
	t[0] = 1;

	jmi_dae_dF_nz_indices(jmi,JMI_DER_SYMBOLIC,JMI_DER_ALL,mask,dF_row,dF_col);

	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_ROW_MAJOR,JMI_DER_ALL,mask,dF_dense);

	jmi_real_t jac_fix_sparse[16] = {1, 1.551701780775437e+02, -1, -1, -1, -3, 1, 14.778112197861301,
			                  1, -5, 29.556224395722602, 1, 1, 59.112448791445203, -1,
			                  3.103403561550873e+02};

	jmi_real_t *jac_fix_dense = (jmi_real_t*)calloc(dF_n_dense,sizeof(jmi_real_t));

	for (i=0;i<dF_n_nz;i++) {
		jac_fix_dense[(dF_row[i]-1)*n_z + dF_col[i]-1] = jac_fix_sparse[i];
	}

	if (verbose == 1) {
		printf("*** test_12_dae_dF_eval start ***\n");
		printf("Jacobian (dense row major):\n");
		for (i=0;i<dF_n_dense;i++) {
			printf("%f\n",dF_dense[i]);
		}
		printf("*** test_12_dae_dF_eval end ***\n");
	}

	jmi_real_t err_sum = 0;
	for (i=0;i<dF_n_nz;i++) {
		err_sum += abs(jac_fix_dense[i] - dF_dense[i]);
	}

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dF sparse indices
int test_13_dae_dF_indices(int verbose) {

	mask[5] = 0; // mask dx_3
	mask[7] = 0; // mask x_2

	int i;
	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
    		JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	jmi_dae_dF_nz_indices(jmi,JMI_DER_SYMBOLIC,
			               JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,mask,dF_row,dF_col);

	if (verbose == 1) {
		int i;
		printf("*** test_13_dae_dF_indices start ***\n");
		printf("Number of non-zeros in the DAE residual Jacobian (pi, dx, x, dx_3 and x_2 masked): %d\n",dF_n_nz_test);
		for (i=0;i<dF_n_nz_test;i++) {
			printf("%d, %d\n",dF_row[i],dF_col[i]);
		}
		printf("*** test_13_dae_dF_indices end ***\n");
	}

	int dF_row_fix[10] = {2,3,1,2,1,2,3,4,1,3};
	int dF_col_fix[10] = {1,3,4,5,6,6,6,6,8,8};

	int err_sum = 0;
	for (i=0;i<dF_n_nz_test;i++) {
		err_sum += abs(dF_row_fix[i] - dF_row[i]);
		err_sum += abs(dF_col_fix[i] - dF_col[i]);
	}

	mask[5] = 1;
	mask[7] = 1;

	if (err_sum==0) {
		return 0;
	} else {
		return -1;
	}

}


// Test evaluation of dF using JMI_DER_SPARSE
int test_14_dae_dF_eval(int verbose) {

	mask[5] = 0; // mask dx_3
	mask[7] = 0; // mask x_2

	int i;
	// Initialize the variables
    pi[0] = 1;
    pi[1] = 1;
    pi[2] = 2;
    dx[0] = 1;
    dx[1] = 1;
    dx[2] = 2;
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;
	u[0] = 4;
	w[0] = 3;
	t[0] = 1;

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
    		JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
			JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U ,mask,dF_sparse);

	if (verbose == 1) {
		printf("*** test_14_dae_dF_eval start ***\n");
		printf("Jacobian (pi, dx, x, dx_3 and x_2 masked) (sparse):\n");
		for (i=0;i<dF_n_nz_test;i++) {
			printf("%f\n",dF_sparse[i]);
		}
		printf("*** test_14_dae_dF_eval end ***\n");
	}

	jmi_real_t jac_fix[10] = {1, 1.551701780775437e+02, -1, -1, -3, 1, 14.778112197861301,
			                  1, 1, 59.112448791445203};
	jmi_real_t err_sum = 0;
	for (i=0;i<dF_n_nz_test;i++) {
		err_sum += abs(jac_fix[i] - dF_sparse[i]);
	}

	mask[5] = 1;
	mask[7] = 1;

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}

}

// Evaluation of dF using JMI_DER_DENSE_COL_MAJOR
int test_15_dae_dF_eval(int verbose) {

	mask[5] = 0; // mask dx_3
	mask[7] = 0; // mask x_2

	int i;
	// Initialize the variables
    pi[0] = 1;
    pi[1] = 1;
    pi[2] = 2;
    dx[0] = 1;
    dx[1] = 1;
    dx[2] = 2;
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;
	u[0] = 4;
	w[0] = 3;
	t[0] = 1;

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,
    		JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	jmi_dae_dF_nz_indices(jmi,JMI_DER_SYMBOLIC,
			JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,mask,dF_row,dF_col);

	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,
			JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,
			mask,dF_dense);

	jmi_real_t jac_fix_sparse[10] = {1,  1.551701780775437e+02,-1, -1, -3, 1, 14.778112197861301,
			                  1, 1, 59.112448791445203};

	jmi_real_t *jac_fix_dense = (jmi_real_t*)calloc(dF_n_nz_test,sizeof(jmi_real_t));

	for (i=0;i<10;i++) {
		jac_fix_dense[dF_row[i]-1 + (dF_col[i]-1)*n_eq_F] = jac_fix_sparse[i];
	}

	if (verbose == 1) {
		printf("*** test_15_dae_dF_eval start ***\n");
		printf("Jacobian (pi, dx, x, dx_3 and x_2 masked) (dense col major):\n");
		for (i=0;i<dF_n_nz_test;i++) {
			printf("%f\n",dF_dense[i]);
		}
		printf("*** test_15_dae_dF_eval end ***\n");
	}

	jmi_real_t err_sum = 0;
	for (i=0;i<dF_n_nz_test;i++) {
		err_sum += abs(jac_fix_dense[i] - dF_dense[i]);
	}

	mask[5] = 1;
	mask[7] = 1;

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}


}

// Evaluation of dF using JMI_DER_DENSE_ROW_MAJOR
int test_16_dae_dF_eval(int verbose) {

	mask[5] = 0; // mask dx_3
	mask[7] = 0; // mask x_2

	int i;
	// Initialize the variables
    pi[0] = 1;
    pi[1] = 1;
    pi[2] = 2;
    dx[0] = 1;
    dx[1] = 1;
    dx[2] = 2;
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;
	u[0] = 4;
	w[0] = 3;
	t[0] = 1;

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_ROW_MAJOR,
    		JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	jmi_dae_dF_nz_indices(jmi,JMI_DER_SYMBOLIC,
			JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,mask,dF_row,dF_col);

	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_ROW_MAJOR,
			JMI_DER_PI | JMI_DER_DX | JMI_DER_X | JMI_DER_U,
			mask,dF_dense);

	jmi_real_t jac_fix_sparse[10] = {1, 1.551701780775437e+02, -1, -1, -3, 1, 14.778112197861301,
			                  1, 1, 59.112448791445203};

	jmi_real_t *jac_fix_dense = (jmi_real_t*)calloc(dF_n_nz_test,sizeof(jmi_real_t));

	for (i=0;i<10;i++) {
		jac_fix_dense[(dF_row[i]-1)*dF_n_cols_test + dF_col[i]-1] = jac_fix_sparse[i];
	}

	if (verbose == 1) {
		printf("*** test_16_dae_dF_eval start ***\n");
		printf("Jacobian (pi, dx, x, dx_3 and x_2 masked) (dense row major):\n");
		for (i=0;i<dF_n_nz_test;i++) {
			printf("%f\n",dF_dense[i]);
		}
		printf("*** test_16_dae_dF_eval end ***\n");
	}

	jmi_real_t err_sum = 0;
	for (i=0;i<dF_n_nz_test;i++) {
		err_sum += abs(jac_fix_dense[i] - dF_dense[i]);
	}

	mask[5] = 1;
	mask[7] = 1;


	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}
}

// Test evaluation of J
int test_17_opt_J_eval(int verbose) {

	int i;

	// Initialize the variables
    pi[0] = 2;
    pi[1] = 1;
    pi[2] = 2;
    dx_p_1[0] = 1;
    dx_p_1[1] = 2;
    dx_p_1[2] = 3;
    x_p_1[0] = 3;
    x_p_1[1] = 4;
    x_p_1[2] = 5;
    u_p_1[0] = 6;
    w_p_1[0] = 7;
    dx_p_2[0] = 8;
    dx_p_2[1] = 9;
    dx_p_2[2] = 10;
    x_p_2[0] = 11;
    x_p_2[1] = 12;
    x_p_2[2] = 13;
    u_p_2[0] = 14;
    w_p_2[0] = 15;

	jmi_opt_J(jmi,&J);

	jmi_real_t J_fix = 296;
	jmi_real_t err = abs(J_fix - J);

	if (verbose == 1) {
		int i;
		printf("*** test_17_opt_J_eval start ***\n");
		printf("p = {%f}\n",pi[0]);
		printf("dx_p_1 = {%f,%f,%f}\n",dx_p_1[0],dx_p_1[1],dx_p_1[2]);
		printf("x_p_1 = {%f,%f,%f}\n",x_p_1[0],x_p_1[1],x_p_1[2]);
		printf("u_p_1 = {%f}\n",u_p_1[0]);
		printf("w_p_1 = {%f}\n",w_p_1[0]);
		printf("dx_p_2 = {%f,%f,%f}\n",dx_p_2[0],dx_p_2[1],dx_p_2[2]);
		printf("x_p_2 = {%f,%f,%f}\n",x_p_2[0],x_p_2[1],x_p_2[2]);
		printf("u_p_2 = {%f}\n",u_p_2[0]);
		printf("w_p_2 = {%f}\n",w_p_2[0]);


		printf("J=%f\n",J);
		printf("*** test_17_opt_J_eval end ***\n");
	}

	if (err<SMALL) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dJ sparse indices
int test_18_opt_dJ_indices(int verbose) {

	int i;

	jmi_opt_dJ_nz_indices(jmi,JMI_DER_SYMBOLIC,JMI_DER_ALL,mask,dJ_row,dJ_col);

	if (verbose == 1) {
		int i;
		printf("*** test_18_opt_dJ_indices start ***\n");
		printf("Number of non-zeros in the J Jacobian: %d\n",dJ_n_nz);
		for (i=0;i<dJ_n_nz;i++) {
			printf("%d, %d\n",dJ_row[i],dJ_col[i]);
		}
		printf("*** test_18_dae_dJ_indices end ***\n");
	}

	int dJ_row_fix[6] = {1,1,1,1,1,1};
	int dJ_col_fix[6] = {1,2,18,20,26,28};

	int err_sum = 0;
	for (i=0;i<dJ_n_nz;i++) {
		err_sum += abs(dJ_row_fix[i] - dJ_row[i]);
		err_sum += abs(dJ_col_fix[i] - dJ_col[i]);
	}

	if (err_sum==0) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dJ dimenstions
int test_19_opt_dJ_dim(int verbose) {

	int dJ_n_nz_test;
	int dJ_n_cols_test;
    jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_ROW_MAJOR,JMI_DER_X_P,mask,&dJ_n_cols_test,&dJ_n_nz_test);

	if (verbose == 1) {
		printf("*** test_19_opt_dJ_dim start ***\n");
		printf("Dense dJ_dx_p: dJ_n_cols: %d, dJ_n_nz: %d\n", dJ_n_cols_test, dJ_n_nz_test);
		printf("*** test_19_opt_dJ_dim end ***\n");
	}

	int dJ_n_nz_fix = 6;
	int dJ_n_cols_fix = 6;

	if (dJ_n_nz_fix == dJ_n_nz_test && dJ_n_cols_fix == dJ_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dJ dimenstions
int test_20_opt_dJ_dim(int verbose) {

	int dJ_n_nz_test;
	int dJ_n_cols_test;
    jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_X_P | JMI_DER_W_P,mask,&dJ_n_cols_test,&dJ_n_nz_test);

	if (verbose == 1) {
		printf("*** test_20_opt_dJ_dim start ***\n");
		printf("sparse dJ_dx_p_dw_p: dJ_n_cols: %d, dJ_n_nz: %d\n", dJ_n_cols_test, dJ_n_nz_test);
		printf("*** test_20_opt_dJ_dim end ***\n");
	}

	int dJ_n_nz_fix = 4;
	int dJ_n_cols_fix = 8;

	if (dJ_n_nz_fix == dJ_n_nz_test && dJ_n_cols_fix == dJ_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dJ dimenstions
int test_21_opt_dJ_dim(int verbose) {

	mask[18-1] = 0; // mask x_p_1[2]
	mask[28-1] = 0; // mask w_p_2[0]

	int dJ_n_nz_test;
	int dJ_n_cols_test;
    jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,&dJ_n_cols_test,&dJ_n_nz_test);

	if (verbose == 1) {
		printf("*** test_21_opt_dJ_dim start ***\n");
		printf("sparse dJ_pi_dx_p_dw_p (x_p_1(2), w_p_2(0) masked): dJ_n_cols: %d, dJ_n_nz: %d\n", dJ_n_cols_test, dJ_n_nz_test);
		printf("*** test_21_opt_dJ_dim end ***\n");
	}

	int dJ_n_nz_fix = 4;
	int dJ_n_cols_fix = 9;

	mask[18-1] = 1;
	mask[28-1] = 1;

	if (dJ_n_nz_fix == dJ_n_nz_test && dJ_n_cols_fix == dJ_n_cols_test) {
		return 0;
	} else {
		return -1;
	}

}

// Test computation of dJ sparse indices
int test_22_opt_dJ_indices(int verbose) {

	int i;

	mask[18-1] = 0; // mask x_p_1[2]
	mask[28-1] = 0; // mask w_p_2[0]

	int dJ_n_nz_test;
	int dJ_n_cols_test;

    jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,&dJ_n_cols_test,&dJ_n_nz_test);

	jmi_opt_dJ_nz_indices(jmi,JMI_DER_SYMBOLIC,JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,dJ_row,dJ_col);

	if (verbose == 1) {
		int i;
		printf("*** test_22_opt_dJ_indices start ***\n");
		printf("Number of non-zeros in the J Jacobian: %d\n",dJ_n_nz_test);
		for (i=0;i<dJ_n_nz_test;i++) {
			printf("%d, %d\n",dJ_row[i],dJ_col[i]);
		}
		printf("*** test_22_dae_dJ_indices end ***\n");
	}

	int dJ_row_fix[4] = {1,1,1,1};
	int dJ_col_fix[4] = {1,2,6,9};

	int err_sum = 0;
	for (i=0;i<dJ_n_nz_test;i++) {
		err_sum += abs(dJ_row_fix[i] - dJ_row[i]);
		err_sum += abs(dJ_col_fix[i] - dJ_col[i]);
	}

	mask[18-1] = 1;
	mask[28-1] = 1;

	if (err_sum==0) {
		return 0;
	} else {
		return -1;
	}

}



// Test evaluation of dJ using JMI_DER_SPARSE
int test_23_opt_dJ_eval(int verbose) {

	mask[18-1] = 0; // mask x_p_1[2]
	mask[28-1] = 0; // mask w_p_2[0]

	int i;
	// Initialize the variables
    pi[0] = 2;
    pi[1] = 1;
    pi[2] = 2;
    dx_p_1[0] = 1;
    dx_p_1[1] = 2;
    dx_p_1[2] = 3;
    x_p_1[0] = 3;
    x_p_1[1] = 4;
    x_p_1[2] = 5;
    u_p_1[0] = 6;
    w_p_1[0] = 7;
    dx_p_2[0] = 8;
    dx_p_2[1] = 9;
    dx_p_2[2] = 10;
    x_p_2[0] = 11;
    x_p_2[1] = 12;
    x_p_2[2] = 13;
    u_p_2[0] = 17;
    w_p_2[0] = 18;

	int dJ_n_nz_test;
	int dJ_n_cols_test;
    jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
    		JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,
    		         &dJ_n_cols_test,&dJ_n_nz_test);

	jmi_opt_dJ(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
			JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,dJ_sparse);

	if (verbose == 1) {
		printf("*** test_23_opt_dJ_eval start ***\n");
		printf("Jacobian dJ (x_p_1(2), w_p_2(0) masked) (sparse):\n");
		for (i=0;i<dJ_n_nz_test;i++) {
			printf("%f\n",dJ_sparse[i]);
		}
		printf("*** test_23_opt_dJ_eval end ***\n");
	}

	jmi_real_t jac_fix[4] = {4,13+18*18,2*7,1};

	jmi_real_t err_sum = 0;
	for (i=0;i<dJ_n_nz_test;i++) {
		err_sum += abs(jac_fix[i] - dJ_sparse[i]);
	}

	mask[18-1] = 1;
	mask[28-1] = 1;

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}

}

// Test evaluation of dJ using JMI_DER_SPARSE
int test_24_opt_dJ_eval(int verbose) {

	int i;
	// Initialize the variables
    pi[0] = 2;
    pi[1] = 1;
    pi[2] = 2;
    dx_p_1[0] = 1;
    dx_p_1[1] = 2;
    dx_p_1[2] = 3;
    x_p_1[0] = 3;
    x_p_1[1] = 4;
    x_p_1[2] = 5;
    u_p_1[0] = 6;
    w_p_1[0] = 7;
    dx_p_2[0] = 8;
    dx_p_2[1] = 9;
    dx_p_2[2] = 10;
    x_p_2[0] = 11;
    x_p_2[1] = 12;
    x_p_2[2] = 13;
    u_p_2[0] = 17;
    w_p_2[0] = 18;

	int dJ_n_nz_test;
	int dJ_n_cols_test;
    jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
    		JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,
    		         &dJ_n_cols_test,&dJ_n_nz_test);

	jmi_opt_dJ(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
			JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,dJ_sparse);

	if (verbose == 1) {
		printf("*** test_24_opt_dJ_eval start ***\n");
		printf("Jacobian dJ (sparse):\n");
		for (i=0;i<dJ_n_nz_test;i++) {
			printf("%f\n",dJ_sparse[i]);
		}
		printf("*** test_24_opt_dJ_eval end ***\n");
	}

	jmi_real_t jac_fix[6] = {4,13+18*18,1,2*7,1,2*18};
	jmi_real_t err_sum = 0;
	for (i=0;i<dJ_n_nz_test;i++) {
		err_sum += abs(jac_fix[i] - dJ_sparse[i]);
	}

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}

}

// Test evaluation of dJ using JMI_DER_SPARSE
int test_25_opt_dJ_eval(int verbose) {

	int i;
	// Initialize the variables
    pi[0] = 2;
    pi[1] = 1;
    pi[2] = 2;
    dx_p_1[0] = 1;
    dx_p_1[1] = 2;
    dx_p_1[2] = 3;
    x_p_1[0] = 3;
    x_p_1[1] = 4;
    x_p_1[2] = 5;
    u_p_1[0] = 6;
    w_p_1[0] = 7;
    dx_p_2[0] = 8;
    dx_p_2[1] = 9;
    dx_p_2[2] = 10;
    x_p_2[0] = 11;
    x_p_2[1] = 12;
    x_p_2[2] = 13;
    u_p_2[0] = 17;
    w_p_2[0] = 18;

	int dJ_n_nz_test;
	int dJ_n_cols_test;
    jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,
    		JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,
    		         &dJ_n_cols_test,&dJ_n_nz_test);

	jmi_opt_dJ(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,
			JMI_DER_PI | JMI_DER_X_P | JMI_DER_W_P,mask,dJ_dense);

	if (verbose == 1) {
		printf("*** test_25_opt_dJ_eval start ***\n");
		printf("Jacobian dJ (dense):\n");
		for (i=0;i<dJ_n_nz_test;i++) {
			printf("%f\n",dJ_dense[i]);
		}
		printf("*** test_25_opt_dJ_eval end ***\n");
	}

	jmi_real_t jac_fix[11] = {4,13+18*18,0,0,0,1,2*7,0,0,1,2*18};
	jmi_real_t err_sum = 0;
	for (i=0;i<dJ_n_nz_test;i++) {
		err_sum += abs(jac_fix[i] - dJ_dense[i]);
	}

	if (err_sum<SMALL) {
		return 0;
	} else {
		return -1;
	}

}


int test_optimization(int verbose) {

	int i;

	// Here initial values for all parameters should be read from
	// xml-files
    pi[0] = 1;
    pi[1] = 0;
    pi[2] = 0.2;

	// Specify mesh
	jmi_real_t t0 = 0;
	jmi_real_t tf = 5;
	int t0_free = 0;
	int tf_free = 0;
	jmi_opt_set_optimization_interval(jmi,t0,t0_free,tf,tf_free);

	// Set time points
	jmi_real_t *tp = (jmi_real_t*)calloc(2,sizeof(jmi_real_t));
	tp[0] = 1;
	tp[1] = 0.1;
	jmi_set_tp(jmi,tp);

	int n_e = 100;
	int hs_free = 0;
	jmi_real_t *hs = (jmi_real_t*)calloc(n_e,sizeof(jmi_real_t));
    for (i=0;i<n_e;i++) {
    	hs[i] = 1/(jmi_real_t)n_e;
    }

    int n_cp = 3;

    // Specify parameters to optimize
    int n_p_opt = 1;
    int *p_opt_indices = (int*)calloc(1,sizeof(int));
    p_opt_indices[0] = 0;
    jmi_opt_set_p_opt_indices(jmi, n_p_opt, p_opt_indices);

    jmi_real_t *z;
    z = jmi_get_ci(jmi);

    for(i=0;i<jmi->n_z;i++) {
    	printf(">>>>>> %d, %f\n",i,z[i]);
    }

    // Initial point
    jmi_real_t *p_opt_init = (jmi_real_t*)calloc(n_p_opt,sizeof(jmi_real_t));
    jmi_real_t *dx_init = (jmi_real_t*)calloc(n_dx,sizeof(jmi_real_t));
    jmi_real_t *x_init = (jmi_real_t*)calloc(n_x,sizeof(jmi_real_t));
    jmi_real_t *u_init = (jmi_real_t*)calloc(n_u,sizeof(jmi_real_t));
    jmi_real_t *w_init = (jmi_real_t*)calloc(n_w,sizeof(jmi_real_t));

    // Bounds
    jmi_real_t *p_opt_lb = (jmi_real_t*)calloc(n_p_opt,sizeof(int));
    jmi_real_t *dx_lb = (jmi_real_t*)calloc(n_dx,sizeof(jmi_real_t));
    jmi_real_t *x_lb = (jmi_real_t*)calloc(n_x,sizeof(jmi_real_t));
    jmi_real_t *u_lb = (jmi_real_t*)calloc(n_u,sizeof(jmi_real_t));
    jmi_real_t *w_lb = (jmi_real_t*)calloc(n_w,sizeof(jmi_real_t));
    jmi_real_t t0_lb = 0;
    jmi_real_t tf_lb = 0;
    jmi_real_t *hs_lb = NULL;

    jmi_real_t *p_opt_ub = (jmi_real_t*)calloc(n_p_opt,sizeof(int));
    jmi_real_t *dx_ub = (jmi_real_t*)calloc(n_dx,sizeof(jmi_real_t));
    jmi_real_t *x_ub = (jmi_real_t*)calloc(n_x,sizeof(jmi_real_t));
    jmi_real_t *u_ub = (jmi_real_t*)calloc(n_u,sizeof(jmi_real_t));
    jmi_real_t *w_ub = (jmi_real_t*)calloc(n_w,sizeof(jmi_real_t));
    jmi_real_t t0_ub = 0;
    jmi_real_t tf_ub = 0;
    jmi_real_t *hs_ub = NULL;

    p_opt_init[0] = 1;

/*
    dx_init[0] = 1;
    dx_init[1] = 1;
    dx_init[2] = 2;
    x_init[0] = 1;
    x_init[1] = 2;
    x_init[2] = 3;
    u_init[0] = 4;
    w_init[0] = 3;
*/
    dx_init[0] = 0;
    dx_init[1] = 0;
    dx_init[2] = 0;
    x_init[0] = 0;
    x_init[1] = 0;
    x_init[2] = 0;
    u_init[0] = 0;
    w_init[0] = 0;

    for (i=0;i<n_p_opt;i++) {
    	p_opt_lb[i] = 0.9;
    	p_opt_ub[i] = 1.1;
    }

    for (i=0;i<n_dx;i++) {
    	dx_lb[i] = -JMI_INF;
    	dx_ub[i] = JMI_INF;
    }

    for (i=0;i<n_x;i++) {
    	x_lb[i] = -JMI_INF;
    	x_ub[i] = JMI_INF;
    }

    for (i=0;i<n_u;i++) {
    	u_lb[i] = -JMI_INF;
    	u_ub[i] = JMI_INF;
    }

    for (i=0;i<n_w;i++) {
    	w_lb[i] = -JMI_INF;
    	w_ub[i] = JMI_INF;
    }

    // Set an extra bound for x_3
    x_lb[2] = 0;

	jmi_opt_sim_lp_radau_new(&jmi_opt_sim, jmi, n_e,
			             hs, hs_free,
			            p_opt_init, dx_init, x_init,
			            u_init, w_init,
			            p_opt_lb, dx_lb, x_lb,
			            u_lb, w_lb, t0_lb,
			            tf_lb, hs_lb,
			            p_opt_ub, dx_ub, x_ub,
			            u_ub, w_ub, t0_ub,
			            tf_ub, hs_ub,
			            n_cp,JMI_DER_SYMBOLIC);

	jmi_opt_sim_ipopt_new(&jmi_opt_sim_ipopt, jmi_opt_sim);

	jmi_opt_sim_ipopt_solve(jmi_opt_sim_ipopt);

	jmi_opt_sim_write_file_matlab(jmi_opt_sim,"result.m");

    free(hs);

    return -1;

}

int main(int argv, char* argc[])
{

	printf("*****************************************************\n");
	printf("*                                                   *\n");
	printf("*    Tests based on van Der Pol example (no AD)     *\n");
	printf("*                                                   *\n");
	printf("*****************************************************\n\n");

	int test_ok = 0;
	int test_fail = 0;

	init_model();

	jmi_print_summary(jmi);

	test_function(&test_1_dae_F, "test_1_dae_F",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_2_dae_dF_indices, "test_2_dae_dF_indices",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_3_dae_dF_dim, "test_3_dae_dF_dim",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_4_dae_dF_dim, "test_4_dae_dF_dim",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_5_dae_dF_dim, "test_5_dae_dF_dim",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_6_dae_dF_dim, "test_6_dae_dF_dim",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_7_dae_dF_dim, "test_7_dae_dF_dim",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_8_dae_dF_dim, "test_8_dae_dF_dim",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_9_dae_dF_dim, "test_9_dae_dF_dim",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_10_dae_dF_eval, "test_10_dae_dF_eval",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_11_dae_dF_eval, "test_11_dae_dF_eval",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_12_dae_dF_eval, "test_12_dae_dF_eval",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_13_dae_dF_indices, "test_13_dae_dF_indices",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_14_dae_dF_eval, "test_14_dae_dF_eval",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_15_dae_dF_eval, "test_15_dae_dF_eval",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_16_dae_dF_eval, "test_16_dae_dF_eval",TEST_VERB,&test_ok, &test_fail);
	test_function(&test_17_opt_J_eval, "test_17_opt_J_eval",TEST_VERB,&test_ok, &test_fail);
	test_function(&test_18_opt_dJ_indices, "test_18_opt_dJ_indices",TEST_VERB,&test_ok, &test_fail);
	test_function(&test_19_opt_dJ_dim, "test_19_opt_dJ_dim",TEST_VERB,&test_ok, &test_fail);
	test_function(&test_20_opt_dJ_dim, "test_20_opt_dJ_dim",TEST_VERB,&test_ok, &test_fail);
	test_function(&test_21_opt_dJ_dim, "test_21_opt_dJ_dim",TEST_VERB,&test_ok, &test_fail);
	test_function(&test_22_opt_dJ_indices, "test_22_opt_dJ_indices",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_23_opt_dJ_eval, "test_23_opt_dJ_eval",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_24_opt_dJ_eval, "test_24_opt_dJ_eval",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_25_opt_dJ_eval, "test_25_opt_dJ_eval",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_optimization, "test_optimization",TEST_VERB,&test_ok, &test_fail);

    printf(">>> Number of tests run:    %d\n", test_ok + test_fail);
    printf(">>> Number of tests OK:     %d\n", test_ok);
    printf(">>> Number of tests FAIL:   %d\n", test_fail);

//	test_optimization(jmi);

	delete_model();


	return 0;
}

