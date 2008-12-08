
#include <stdio.h>
#include <stdlib.h>
#include <jmi.h>

int main(int argv, char* argc[])
{

	jmi_t* jmi;
	jmi_new(&jmi);

	int i;

	int n_ci, n_cd, n_pi, n_pd, n_dx, n_x, n_u, n_w, n_tp, n_z, n_eq_F;
	int offs_ci, offs_cd, offs_pi, offs_pd, offs_dx, offs_x, offs_u, offs_w, offs_t,
	    offs_dx_p, offs_x_p, offs_u_p, offs_w_p, offs_t_p;
	jmi_get_sizes(jmi, &n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_tp, &n_z);
	jmi_get_offsets(jmi, &offs_ci, &offs_cd, &offs_pi, &offs_pd, &offs_dx, &offs_x, &offs_u, &offs_w, &offs_t,
			&offs_dx_p, &offs_x_p, &offs_u_p, &offs_w_p, &offs_t_p);
	jmi_dae_get_sizes(jmi, &n_eq_F);

	int dF_n_nz;
	jmi_dae_dF_n_nz(jmi,JMI_DER_SYMBOLIC,&dF_n_nz);
	int* dF_row = (int*)calloc(dF_n_nz,sizeof(int));
	int* dF_col = (int*)calloc(dF_n_nz,sizeof(int));

	int dF_n_dense = (n_ci + n_cd + n_pi + n_pd +
			          n_dx + n_x + n_u + n_w + 1) * n_eq_F;

	printf("Number of interactive constants:               %d\n",n_ci);
	printf("Number of dependent constants:                 %d\n",n_cd);
	printf("Number of interactive parameters:              %d\n",n_pi);
	printf("Number of dependent parameters:                %d\n",n_pd);
	printf("Number of derivatives:                         %d\n",n_dx);
	printf("Number of states:                              %d\n",n_x);
	printf("Number of inputs:                              %d\n",n_u);
	printf("Number of algebraics:                          %d\n",n_w);
	printf("Number of DAE equations:                       %d\n",n_eq_F);
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

	jmi_real_t* res_F = (jmi_real_t*)calloc(n_eq_F,sizeof(jmi_real_t));
	jmi_real_t* dF = (jmi_real_t*)calloc(dF_n_nz,sizeof(jmi_real_t));
	jmi_real_t* dF_dense = (jmi_real_t*)calloc(dF_n_dense,sizeof(jmi_real_t));

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

	jmi_dae_F(jmi,res_F);

	/*	jmi_init_F0(ci,cd,pi,pd,dx,x,u,w,t,res_F0);
	jmi_init_F1(ci,cd,pi,pd,dx,x,u,w,t,res_F1);
    jmi_dae_ad_dF(ci,cd,pi,pd,dx,x,u,w,t,mask,jac_DER_F);
	*/

	printf("\n *** State initialized to (%f,%f,%f) ***\n\n",x[0],x[1],x[2]);
	printf("DAE residual:\n");
	for (i=0;i<n_eq_F;i++){
		printf("res[%d] = %f\n",i,res_F[i]);
	}

	jmi_dae_dF_nz_indices(jmi,JMI_DER_SYMBOLIC,dF_row,dF_col);
	printf("Number of non-zeros in the DAE residual Jacobian: %d\n",dF_n_nz);
	for (i=0;i<dF_n_nz;i++) {
		printf("%d, %d\n",dF_row[i],dF_col[i]);
	}

	int* mask = (int*)calloc(n_z,sizeof(int));
	for(i=0;i<n_z;i++) {
		mask[i]=1;
	}

	// Compute the size of the Jacobian for different sparsity configurations
	int dF_n_nz_test;
	int dF_n_cols_test;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_ROW_MAJOR,JMI_DER_X,mask,&dF_n_cols_test,&dF_n_nz_test);
	printf("Dense dF_dx: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);

    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_X,mask,&dF_n_cols_test,&dF_n_nz_test);
	printf("Sparse dF_dx: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);

    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_U,mask,&dF_n_cols_test,&dF_n_nz_test);
	printf("Sparse dF_du: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);


	mask[offs_x+1] = 0;
	mask[offs_x+2] = 0;
    jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_X,mask,&dF_n_cols_test,&dF_n_nz_test);
	printf("Sparse, first column of dF_dx: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);

	mask[offs_x+1] = 1;
	mask[offs_x+2] = 1;

	jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_SPARSE,JMI_DER_ALL,mask,&dF_n_cols_test,&dF_n_nz_test);
	printf("Sparse dF_dz: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);

	jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,JMI_DER_DENSE_COL_MAJOR,JMI_DER_ALL,mask,&dF_n_cols_test,&dF_n_nz_test);
	printf("Dense dF_dz: dF_n_cols: %d, dF_n_nz: %d\n", dF_n_cols_test, dF_n_nz_test);


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



/*
	printf("\ninitial DAE residual (F0):\n");
	for (i=0;i<n_eq_F0;i++){
		printf("res[%d] = %f\n",i,res_F0[i]);
	}

	printf("\ninitial DAE residual (F1):\n");
	for (i=0;i<n_eq_F1;i++){
		printf("res[%d] = %f\n",i,res_F1[i]);
	}

	printf("\n Jacobian of F wrt dx, x, u:\n");
	for (i=0;i<n_jac_F;i++){
		printf("jac_sd_F[%d] = %f, jac_DER_F[%d] = %f\n",i,jac_sd_F[i], i,jac_DER_F[i]);
	}
*/
	free(res_F);
	free(dF);
	free(dF_dense);
	free(mask);
/*	free(res_F0);
	free(res_F1);
*/

	free(dF_row);
	free(dF_col);

	jmi_delete(jmi);

	return 0;
}
