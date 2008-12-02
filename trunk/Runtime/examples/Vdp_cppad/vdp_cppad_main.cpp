
#include <vector>
#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include <jmi.h>

int main(int argv, char* argc[])
{

	jmi_t* jmi;
	// Create a new Jmi object.
	jmi_new(&jmi);

	int i;


	int dF_n_nz;
	jmi_dae_dF_n_nz(jmi,JMI_DER_SYMBOLIC,&dF_n_nz);
	int* dF_row = (int*)calloc(dF_n_nz,sizeof(int));
	int* dF_col = (int*)calloc(dF_n_nz,sizeof(int));

	int dF_n_dense = (jmi->n_pi +
			jmi->n_pd +
			jmi->n_dx +
			jmi->n_x +
			jmi->n_u +
			jmi->n_w + 1) * jmi->dae->n_eq_F;


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


	jmi_real_t* res_F = (jmi_real_t*)calloc(jmi->dae->n_eq_F,sizeof(jmi_real_t));
	jmi_real_t* dF = (jmi_real_t*)calloc(dF_n_nz,sizeof(jmi_real_t));
	jmi_real_t* dF_dense = (jmi_real_t*)calloc(dF_n_dense,sizeof(jmi_real_t));

	/*	Jmi_Double_t* res_F0 = (Jmi_Double_t*)calloc(n_eq_F0,sizeof(Jmi_Double_t));
	Jmi_Double_t* res_F1 = (Jmi_Double_t*)calloc(n_eq_F1,sizeof(Jmi_Double_t));
	Jmi_Double_t* jac_DER_F = (Jmi_Double_t*)calloc(n_jac_F,sizeof(Jmi_Double_t));
	 */


	// Here initial values for all parameters should be read from
	// xml-files
	pi[0] = 1;
	x[0] = 5;
	x[1] = 6;
	x[2] = 7;
	t_[0] = 0;

	// Initialize the AD
	jmi_ad_init(jmi);

	// Evaluate the residual
	jmi_dae_F(jmi,res_F);

	printf("\n *** State initialized to (%f,%f,%f) ***\n\n",x[0],x[1],x[2]);
	printf("DAE residual:\n");
	for (i=0;i<jmi->dae->n_eq_F;i++){
		printf("res[%d] = %f\n",i,res_F[i]);
	}

	// Try another point
	pi[0] = 1;
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;
	t_[0] = 0;


	// Evaluate the residual
	jmi_dae_F(jmi,res_F);

	printf("\n *** State initialized to (%f,%f,%f) ***\n\n",x[0],x[1],x[2]);
	printf("DAE residual:\n");
	for (i=0;i<jmi->dae->n_eq_F;i++){
		printf("res[%d] = %f\n",i,res_F[i]);
	}

	jmi_dae_dF_nz_indices(jmi,JMI_DER_SYMBOLIC,dF_row,dF_col);
	printf("Number of non-zeros in the DAE residual Jacobian: %d\n",dF_n_nz);
	for (i=0;i<dF_n_nz;i++) {
		printf("%d, %d\n",dF_row[i],dF_col[i]);
	}

	int* mask = (int*)calloc(jmi->n_z,sizeof(int));
	for(i=0;i<jmi->n_z;i++) {
		mask[i]=1;
	}

	// Evalute symbolic Jacobian
	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_ALL,mask,dF);
	printf("Jacobian (sparse):\n");
	for (i=0;i<dF_n_nz;i++) {
		printf("%f\n",dF[i]);
	}

	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,JMI_DER_ALL,mask,dF_dense);
	printf("Jacobian (dense col major):\n");
	for (i=0;i<dF_n_dense;i++) {
		printf("%f\n",dF_dense[i]);
	}

	jmi_dae_dF(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_ROW_MAJOR,JMI_DER_ALL,mask,dF_dense);
	printf("Jacobian (dense row major):\n");
	for (i=0;i<dF_n_dense;i++) {
		printf("%f\n",dF_dense[i]);
	}

	// Do some stuff with the AD functions
	int dF_n_nz_ad;
	jmi_dae_dF_n_nz(jmi,JMI_DER_CPPAD,&dF_n_nz_ad);
	int* dF_row_ad = (int*)calloc(dF_n_nz_ad,sizeof(int));
	int* dF_col_ad = (int*)calloc(dF_n_nz_ad,sizeof(int));

	jmi_real_t* dF_ad = (jmi_real_t*)calloc(dF_n_nz_ad,sizeof(jmi_real_t));

	jmi_real_t* dF_ad_dense = (jmi_real_t*)calloc(dF_n_dense,sizeof(jmi_real_t));

	jmi_dae_dF_nz_indices(jmi,JMI_DER_CPPAD,dF_row_ad,dF_col_ad);
	printf("Number of non-zeros in the DAE residual Jacobian (cppad): %d\n",dF_n_nz_ad);
	for (i=0;i<dF_n_nz_ad;i++) {
		printf("%d, %d\n",dF_row_ad[i],dF_col_ad[i]);
	}

	jmi_dae_dF(jmi,JMI_DER_CPPAD,JMI_DER_SPARSE,JMI_DER_ALL,mask,dF_ad);
	printf("Jacobian (sparse) (cppad):\n");
	for (i=0;i<dF_n_nz_ad;i++) {
		printf("%f\n",dF_ad[i]);
	}

	jmi_dae_dF(jmi,JMI_DER_CPPAD,JMI_DER_DENSE_COL_MAJOR,JMI_DER_ALL,mask,dF_ad_dense);
	printf("Jacobian (dense col major) (cppad):\n");
	for (i=0;i<dF_n_dense;i++) {
		printf("%f\n",dF_ad_dense[i]);
	}

	jmi_dae_dF(jmi,JMI_DER_CPPAD,JMI_DER_DENSE_ROW_MAJOR,JMI_DER_ALL,mask,dF_ad_dense);
	printf("Jacobian (dense row major) (cppad):\n");
	for (i=0;i<dF_n_dense;i++) {
		printf("%f\n",dF_ad_dense[i]);
	}

	jmi_delete(jmi);

	free(res_F);
	free(dF);
	free(dF_dense);
	free(dF_row);
	free(dF_col);
	free(dF_row_ad);
	free(dF_col_ad);
	free(dF_ad);
	free(dF_ad_dense);
	free(mask);


	return 0;
}
