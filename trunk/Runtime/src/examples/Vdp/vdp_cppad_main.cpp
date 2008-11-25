
#include <vector>
#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include "../../Jmi/jmi.h"
#include "../../Jmi/jmi_cppad.hpp"

#include <cppad/cppad.hpp>

int main(int argv, char* argc[])
{

	jmi_t* jmi;
	// Create a new Jmi object.
	jmi_new(&jmi);

	int i;

	std::vector<double> q = *(new std::vector<double>(5));
	for (i=0;i<5;i++) {
		q[i] = i;
	}
	double* qq = &q[0];
	for (i=0;i<5;i++) {
		printf("%f\n",qq[i]);
	}


	/*
	int dF_n_nz;
	jmi_dae_dF_n_nz(jmi,&dF_n_nz);
	int* dF_row = (int*)calloc(dF_n_nz,sizeof(int));
	int* dF_col = (int*)calloc(dF_n_nz,sizeof(int));

	int dF_n_dense = (jmi->n_pi +
			jmi->n_pd +
			jmi->n_dx +
			jmi->n_x +
			jmi->n_u +
			jmi->n_w) * jmi->dae->n_eq_F;
*/

	printf("Number of interactive constants:               %d\n",jmi->n_ci);
	printf("Number of dependent constants:                 %d\n",jmi->n_cd);
	printf("Number of interactive parameters:              %d\n",jmi->n_pi);
	printf("Number of dependent parameters:                %d\n",jmi->n_pd);
	printf("Number of derivatives:                         %d\n",jmi->n_dx);
	printf("Number of states:                              %d\n",jmi->n_x);
	printf("Number of inputs:                              %d\n",jmi->n_u);
	printf("Number of algebraics:                          %d\n",jmi->n_w);
	printf("Number of DAE equations:                       %d\n",jmi->dae->n_eq_F);
/*	printf("Number of DAE initial equations (F0):          %d\n",n_eq_F0);
	printf("Number of DAE initial equations (F1):          %d\n",n_eq_F1);
	printf("Number of elements in Jacobian wrt dx, x, u:   %d\n",n_jac_F);
*/


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

	/*
	jmi_real_t* res_F = (jmi_real_t*)calloc(jmi->dae->n_eq_F,sizeof(jmi_real_t));
	jmi_real_t* dF = (jmi_real_t*)calloc(dF_n_nz,sizeof(jmi_real_t));
	jmi_real_t* dF_dense = (jmi_real_t*)calloc(dF_n_dense,sizeof(jmi_real_t));
*/
	/*	Jmi_Double_t* res_F0 = (Jmi_Double_t*)calloc(n_eq_F0,sizeof(Jmi_Double_t));
	Jmi_Double_t* res_F1 = (Jmi_Double_t*)calloc(n_eq_F1,sizeof(Jmi_Double_t));
	Jmi_Double_t* jac_DER_F = (Jmi_Double_t*)calloc(n_jac_F,sizeof(Jmi_Double_t));
*/

	t_[0] = 0;

	// Here initial values for all parameters should be reDER from
	// xml-files
    pi[0] = 1;

	// Try to initialize x = (0,1,0)
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;

	printf("** * %f\n",x[0]);
	printf("** * %f\n",x[1]);
	printf("** * %f\n",x[2]);
	printf("** * %f\n",jmi->z_val[jmi->offs_x + 0]);
	printf("** * %f\n",jmi->z_val[jmi->offs_x +1]);
	printf("** * %f\n",jmi->z_val[jmi->offs_x +2]);


	jmi_ad_init(jmi);

	jmi_delete(jmi);

	return 0;
}
