
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <jmi.h>
#include <jmi_opt_sim.h>
#include <jmi_opt_sim_ipopt.h>

#define TEST_VERB 0
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
    offs_dx_p, offs_x_p, offs_u_p, offs_w_p, offs_t_p;

static int dF_n_nz;
static int* dF_row;
static int* dF_col;

static int dF_n_dense;

static jmi_real_t* ci;
static jmi_real_t* cd;
static jmi_real_t* pi;
static jmi_real_t* pd;
static jmi_real_t* dx;
static jmi_real_t* x;
static jmi_real_t* u;
static jmi_real_t* w;
static jmi_real_t* t;

static jmi_real_t* res_F;
static jmi_real_t* dF_sparse;
static jmi_real_t* dF_dense;

static int* mask;

// Initialize the model
void init_model() {

	int i;

	jmi_new(&jmi);

	jmi_get_sizes(jmi, &n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_tp, &n_z);
	jmi_get_offsets(jmi, &offs_ci, &offs_cd, &offs_pi, &offs_pd, &offs_dx, &offs_x, &offs_u, &offs_w, &offs_t,
		&offs_dx_p, &offs_x_p, &offs_u_p, &offs_w_p, &offs_t_p);
	jmi_dae_get_sizes(jmi, &n_eq_F);

	jmi_dae_dF_n_nz(jmi,JMI_DER_SYMBOLIC,&dF_n_nz);
	dF_row = (int*)calloc(dF_n_nz,sizeof(int));
	dF_col = (int*)calloc(dF_n_nz,sizeof(int));

	dF_n_dense = n_z * n_eq_F;

	ci = jmi_get_ci(jmi);
	cd = jmi_get_cd(jmi);
	pi = jmi_get_pi(jmi);
	pd = jmi_get_pd(jmi);
	dx = jmi_get_dx(jmi);
	x = jmi_get_x(jmi);
	u = jmi_get_u(jmi);
	w = jmi_get_w(jmi);
	t = jmi_get_t(jmi);

	res_F = (jmi_real_t*)calloc(n_eq_F,sizeof(jmi_real_t));
	dF_sparse = (jmi_real_t*)calloc(dF_n_nz,sizeof(jmi_real_t));
	dF_dense = (jmi_real_t*)calloc(dF_n_dense,sizeof(jmi_real_t));

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
		printf("*** test_2_dae_F_indices start ***\n");
		printf("Number of non-zeros in the DAE residual Jacobian: %d\n",dF_n_nz);
		for (i=0;i<dF_n_nz;i++) {
			printf("%d, %d\n",dF_row[i],dF_col[i]);
		}
		printf("*** test_2_dae_F_indices end ***\n");
	}

	int dF_row_fix[15] = {2,1,2,3,1,2,3,4,1,3,4,1,3,4,3};
	int dF_col_fix[15] = {1,2,3,4,5,5,5,5,6,6,6,8,8,9,10};

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

// Test computation of dF dimenstions
int test_3_dae_dF_dim(int verbose) {

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_ROW_MAJOR,JMI_DER_X,mask,&dF_n_cols_test,&dF_n_nz_test);

	if (verbose == 1) {
		printf("*** test_3_dae_F_indices start ***\n");
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
		printf("*** test_4_dae_F_indices start ***\n");
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
		printf("*** test_5_dae_F_indices start ***\n");
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

	mask[3] = 0; // mask dx_3
	mask[5] = 0; // mask x_2

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,
    		         JMI_DER_DX | JMI_DER_X | JMI_DER_W,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	mask[3] = 1;
	mask[5] = 1;

	if (verbose == 1) {
		printf("*** test_6_dae_F_indices start ***\n");
		printf("Sparse dF_ddx_dx_dw (dx_3 and x_3 masked): dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
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

	mask[3] = 0; // mask dx_3
	mask[5] = 0; // mask x_2

	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,
    		         JMI_DER_DX | JMI_DER_X | JMI_DER_W,mask,
    		         &dF_n_cols_test,&dF_n_nz_test);

	mask[3] = 1;
	mask[5] = 1;

	if (verbose == 1) {
		printf("*** test_7_dae_F_indices start ***\n");
		printf("Dense dF_ddx_dx_dw (dx_3 and x_3 masked): dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
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
		printf("*** test_8_dae_F_indices start ***\n");
		printf("Dense dF: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_8_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 112;
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
		printf("*** test_9_dae_F_indices start ***\n");
		printf("Sparse dF: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);
		printf("*** test_9_dae_dF_dim end ***\n");
	}

	int dF_n_nz_fix = 15;
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

	jmi_real_t jac_fix[15] = {1, -1, -1, -1, -3, 1, 14.778112197861301,
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

	jmi_real_t jac_fix_sparse[15] = {1, -1, -1, -1, -3, 1, 14.778112197861301,
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
			printf("%f\n",dF_dense[i]);
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

	jmi_real_t jac_fix_sparse[15] = {1, -1, -1, -1, -3, 1, 14.778112197861301,
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

void test_optimization() {

	int i;

	jmi_opt_sim_t *jmi_opt_sim;
	jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt;

	int n_ci, n_cd, n_pi, n_pd, n_dx, n_x, n_u, n_w, n_tp, n_z, n_eq_F,
	    n_eq_F0, n_eq_F1, n_eq_Ceq, n_eq_Cineq, n_eq_Heq, n_eq_Hineq;
	int offs_ci, offs_cd, offs_pi, offs_pd, offs_dx, offs_x, offs_u, offs_w, offs_t,
	    offs_dx_p, offs_x_p, offs_u_p, offs_w_p, offs_t_p;
	jmi_get_sizes(jmi, &n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_tp, &n_z);
	jmi_get_offsets(jmi, &offs_ci, &offs_cd, &offs_pi, &offs_pd, &offs_dx, &offs_x, &offs_u, &offs_w, &offs_t,
			&offs_dx_p, &offs_x_p, &offs_u_p, &offs_w_p, &offs_t_p);
	jmi_dae_get_sizes(jmi, &n_eq_F);
	jmi_init_get_sizes(jmi, &n_eq_F0, &n_eq_F1);
	jmi_opt_get_sizes(jmi, &n_eq_Ceq, &n_eq_Cineq, &n_eq_Heq, &n_eq_Hineq);

	printf("Number of interactive constants:                 %d\n",n_ci);
	printf("Number of dependent constants:                   %d\n",n_cd);
	printf("Number of interactive parameters:                %d\n",n_pi);
	printf("Number of dependent parameters:                  %d\n",n_pd);
	printf("Number of derivatives:                           %d\n",n_dx);
	printf("Number of states:                                %d\n",n_x);
	printf("Number of inputs:                                %d\n",n_u);
	printf("Number of algebraics:                            %d\n",n_w);
	printf("Number of DAE equations (F):                     %d\n",n_eq_F);

	printf("Number of DAE initial equations (F0):            %d\n",n_eq_F0);
	printf("Number of DAE initial equations (F1):            %d\n",n_eq_F1);
	printf("Number of Path equality constriants (Ceq):       %d\n",n_eq_Ceq);
	printf("Number of Path inequality constriants (Cineq):   %d\n",n_eq_Cineq);
	printf("Number of Point equality constriants (Heq):      %d\n",n_eq_Heq);
	printf("Number of Point inequality constriants (Hineq):  %d\n",n_eq_Hineq);
/*
	jmi_real_t* ci;
	jmi_real_t* cd;
	jmi_real_t* pi;
	jmi_real_t* pd;
	jmi_real_t* dx;
	jmi_real_t* x;
	jmi_real_t* u;
	jmi_real_t* w;
	jmi_real_t* t_;

	jmi_get_ci(jmi, &ci);
	jmi_get_cd(jmi, &cd);
	jmi_get_pi(jmi, &pi);
	jmi_get_pd(jmi, &pd);
	jmi_get_dx(jmi, &dx);
	jmi_get_x(jmi, &x);
	jmi_get_u(jmi, &u);
	jmi_get_w(jmi, &w);
	jmi_get_t(jmi, &t_);
*/
	// Here initial values for all parameters should be read from
	// xml-files
    pi[0] = 1;

	x[0] = 0;
	x[1] = 0;
	x[2] = 0;

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

	int n_e = 3;
	int hs_free = 0;
	jmi_real_t *hs = (jmi_real_t*)calloc(n_e,sizeof(jmi_real_t));
    for (i=0;i<n_e;i++) {
    	hs[i] = 1/(jmi_real_t)n_e;
    }

    int n_cp = 2;

    // Specify parameters to optimize
    int n_p_opt = 0;
    jmi_opt_set_p_opt_indices(jmi, n_p_opt, NULL);

    jmi_real_t *z;
    z = jmi_get_ci(jmi);

    for(i=0;i<jmi->n_z;i++) {
    	printf(">>>>>> %d, %f\n",i,z[i]);
    }


    // Initial point
    jmi_real_t *pi_init = NULL;
    jmi_real_t *dx_init = (jmi_real_t*)calloc(n_dx,sizeof(jmi_real_t));
    jmi_real_t *x_init = (jmi_real_t*)calloc(n_x,sizeof(jmi_real_t));
    jmi_real_t *u_init = (jmi_real_t*)calloc(n_u,sizeof(jmi_real_t));
    jmi_real_t *w_init = (jmi_real_t*)calloc(n_w,sizeof(jmi_real_t));

    // Bounds
    jmi_real_t *pi_lb = NULL;
    jmi_real_t *dx_lb = (jmi_real_t*)calloc(n_dx,sizeof(jmi_real_t));
    jmi_real_t *x_lb = (jmi_real_t*)calloc(n_x,sizeof(jmi_real_t));
    jmi_real_t *u_lb = (jmi_real_t*)calloc(n_u,sizeof(jmi_real_t));
    jmi_real_t *w_lb = (jmi_real_t*)calloc(n_w,sizeof(jmi_real_t));
    jmi_real_t t0_lb = 0;
    jmi_real_t tf_lb = 0;
    jmi_real_t *hs_lb = NULL;

    jmi_real_t *pi_ub = NULL;
    jmi_real_t *dx_ub = (jmi_real_t*)calloc(n_dx,sizeof(jmi_real_t));
    jmi_real_t *x_ub = (jmi_real_t*)calloc(n_x,sizeof(jmi_real_t));
    jmi_real_t *u_ub = (jmi_real_t*)calloc(n_u,sizeof(jmi_real_t));
    jmi_real_t *w_ub = (jmi_real_t*)calloc(n_w,sizeof(jmi_real_t));
    jmi_real_t t0_ub = 0;
    jmi_real_t tf_ub = 0;
    jmi_real_t *hs_ub = NULL;

    dx_init[0] = 3;
    dx_init[1] = 4;
    dx_init[2] = 5;
    x_init[0] = -3;
    x_init[1] = -4;
    x_init[2] = -5;
    u_init[0] = 2;



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

	jmi_opt_sim_lp_radau_new(&jmi_opt_sim, jmi, n_e,
			             hs, hs_free,
			            pi_init, dx_init, x_init,
			            u_init, w_init,
			            pi_lb, dx_lb, x_lb,
			            u_lb, w_lb, t0_lb,
			            tf_lb, hs_lb,
			            pi_ub, dx_ub, x_ub,
			            u_ub, w_ub, t0_ub,
			            tf_ub, hs_ub,
			            n_cp,JMI_DER_SYMBOLIC);

	jmi_opt_sim_ipopt_new(&jmi_opt_sim_ipopt, jmi_opt_sim);

	jmi_opt_sim_ipopt_solve(jmi_opt_sim_ipopt);

    free(hs);

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

    printf(">>> Number of tests run:    %d\n", test_ok + test_fail);
    printf(">>> Number of tests OK:     %d\n", test_ok);
    printf(">>> Number of tests FAIL:   %d\n", test_fail);

//	test_optimization(jmi);

	delete_model();


	return 0;
}

