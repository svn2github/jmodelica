 /*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the Common Public License as published by
    IBM, version 1.0 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY. See the Common Public License for more details.

    You should have received a copy of the Common Public License
    along with this program.  If not, see
     <http://www.ibm.com/developerworks/library/os-cpl.html/>.
*/

#include <vector>
#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <jmi.h>
#include <jmi_opt_sim_lp.h>
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

static jmi_real_t* ci;
static jmi_real_t* cd;
static jmi_real_t* pi;
static jmi_real_t* pd;
static jmi_real_t* dx;
static jmi_real_t* x;
static jmi_real_t* u;
static jmi_real_t* w;
static jmi_real_t* t;

static int* mask;

static jmi_opt_sim_t *jmi_opt_sim;
static jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt;

// Initialize the model
void init_model() {

	int i;

	jmi_new(&jmi);

	jmi_print_summary(jmi);

	ci = jmi_get_ci(jmi);
	cd = jmi_get_cd(jmi);
	pi = jmi_get_pi(jmi);
	pd = jmi_get_pd(jmi);
	dx = jmi_get_dx(jmi);
	x = jmi_get_x(jmi);
	u = jmi_get_u(jmi);
	w = jmi_get_w(jmi);
	t = jmi_get_t(jmi);


	jmi_get_sizes(jmi, &n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_tp, &n_z);
	jmi_get_offsets(jmi, &offs_ci, &offs_cd, &offs_pi, &offs_pd, &offs_dx, &offs_x, &offs_u, &offs_w, &offs_t,
		&offs_dx_p, &offs_x_p, &offs_u_p, &offs_w_p);
	jmi_dae_get_sizes(jmi, &n_eq_F);

	// Here initial values for all parameters should be read from
	// xml-files
    pi[0] = 0.00354;
    pi[1] = 0.00384;
    pi[2] = 0.00258;
    pi[3] = 0.103;
    pi[4] = 0.2;
    pi[5] = 0.0;
    pi[6] = 0.0;
    pi[7] = 0.0;

	// Initialize the AD
	jmi_ad_init(jmi);

	dF_n_dense = n_z * n_eq_F;

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

int test_jacobian(int verbose) {

	int i,j;

    x[0] = 0.2;
    x[1] = 0.4;
    x[2] = 0.1;
    x[3] = 3;

    t[0] = 0;

    u[0] = 4;

    jmi_real_t* jac =  (jmi_real_t*)calloc(16,sizeof(jmi_real_t));
    jmi_real_t* tmp =  (jmi_real_t*)calloc(4,sizeof(jmi_real_t));

	jmi_ode_df(jmi, JMI_DER_CPPAD, JMI_DER_DENSE_COL_MAJOR,
			JMI_DER_X, mask, jac);

	jmi_real_t err = 0;
	jmi_real_t tol = 1e-4;

	for (i=0;i<4;i++) {
		jmi_ode_f(jmi);
		for (j=0;j<4;j++) {
			tmp[j] = dx[j];
		}
		x[i] += tol;
		jmi_ode_f(jmi);
		for (j=0;j<4;j++) {
			err += (jac[i*4+j] - (dx[j]-tmp[j])/tol)*
			       (jac[i*4+j] - (dx[j]-tmp[j])/tol);
			if (verbose==1) {
				printf("%d %d %f %f\n",i,j,jac[i*4+j] , (dx[j]-tmp[j])/tol);
			}
		}
		x[i] -= tol;

	}

	if (verbose==1) {
		printf("error: %f\n",err);
	}

	free(jac);
	free(tmp);

	if (err<1e-3) {
		return 0;
	} else {
		return -1;
	}
}


int test_simulation(int verbose) {

	int i,j;
	// Simulate model

    x[0] = pi[4];
    x[1] = pi[5];
    x[2] = pi[6];
    x[3] = pi[7];

    t[0] = 0;

    u[0] = 0;

    jmi_real_t h = 0.001;

	jmi_real_t t_f = 10.0;

    jmi_real_t* x_sim = (jmi_real_t*)calloc(4,sizeof(jmi_real_t));
	jmi_real_t t_sim = 0;

	for (i=0;i<4;i++) {
		x_sim[i] = x[i];
	}

	FILE *f = fopen("result_fe.m","wt");
	fprintf(f,"vars=[");
	// Solve differential equation by means of forward Euler
	while (t_sim<t_f) {
		for (i=0;i<4;i++) {
			x[i] = x_sim[i];
		}
		jmi_ode_f(jmi);

		for (i=0;i<4;i++) {
			x_sim[i] = x[i] + h*dx[i];
		}
		t_sim += h;
        t[0] = t_sim;
		fprintf(f,"%f %f %f %f %f\n",t_sim,x_sim[0],x_sim[1],x_sim[2],x_sim[3],x_sim[4]);

	}
	fprintf(f,"];");

	fclose(f);



	return 0;

}

int main(int argv, char* argc[])
{


	init_model();



	printf("******************************************************\n");
	printf("*                                                    *\n");
	printf("*    Tests based on the Furuta pendulum (with CPPAD) *\n");
	printf("*                                                    *\n");
	printf("******************************************************\n\n");

	int test_ok = 0;
	int test_fail = 0;

	test_function(&test_jacobian, "test_jacobian",TEST_VERB,&test_ok, &test_fail);
    test_function(&test_simulation, "test_simulation",TEST_VERB,&test_ok, &test_fail);

    printf(">>> Number of tests run:    %d\n", test_ok + test_fail);
    printf(">>> Number of tests OK:     %d\n", test_ok);
    printf(">>> Number of tests FAIL:   %d\n", test_fail);

//	test_optimization(jmi);


	delete_model();


	return 0;
}


