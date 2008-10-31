#include <stdio.h>
#include <stdlib.h>

#include "../../Jmi/jmi_dae.h"
#include "../../Jmi/jmi_dae_der.h"
#include "../../Jmi/jmi_dae_sd.h"
#include "../../Jmi/jmi_dae_ad.h"
#include "../../Jmi/jmi_init.h"

int main(int argv, char* argc[])
{

	int i;

	int n_ci;
	int n_cd;
	int n_pi;
	int n_pd;
	int n_dx;
	int n_x;
	int n_u;
	int n_w;
	int n_eq_F;
	int n_eq_F0;
	int n_eq_F1;

	jmi_dae_get_sizes(&n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_eq_F);
	jmi_init_get_sizes(&n_ci, &n_cd, &n_pi, &n_pd, &n_dx, &n_x, &n_u, &n_w, &n_eq_F0, &n_eq_F1);

	int n_jac_F;
	int mask = AD_DX | AD_X | AD_U;
	jmi_dae_der_get_sizes(&n_jac_F,mask);

	printf("Number of interactive constants:               %d\n",n_ci);
	printf("Number of dependent constants:                 %d\n",n_cd);
	printf("Number of interactive parameters:              %d\n",n_pi);
	printf("Number of dependent parameters:                %d\n",n_pd);
	printf("Number of derivatives:                         %d\n",n_dx);
	printf("Number of states:                              %d\n",n_x);
	printf("Number of inputs:                              %d\n",n_u);
	printf("Number of algebraics:                          %d\n",n_w);
	printf("Number of DAE equations:                       %d\n",n_eq_F);
	printf("Number of DAE initial equations (F0):          %d\n",n_eq_F0);
	printf("Number of DAE initial equations (F1):          %d\n",n_eq_F1);
	printf("Number of elements in Jacobian wrt dx, x, u:   %d\n",n_jac_F);

	Double_t* ci = (Double_t*)calloc(n_ci,sizeof(Double_t));
	Double_t* cd = (Double_t*)calloc(n_cd,sizeof(Double_t));
	Double_t* pi = (Double_t*)calloc(n_pi,sizeof(Double_t));
	Double_t* pd = (Double_t*)calloc(n_pd,sizeof(Double_t));
	Double_t* dx = (Double_t*)calloc(n_dx,sizeof(Double_t));
	Double_t* x = (Double_t*)calloc(n_x,sizeof(Double_t));
	Double_t* u = (Double_t*)calloc(n_u,sizeof(Double_t));
	Double_t* w = (Double_t*)calloc(n_w,sizeof(Double_t));
	Double_t* res_F = (Double_t*)calloc(n_eq_F,sizeof(Double_t));
	Double_t* res_F0 = (Double_t*)calloc(n_eq_F0,sizeof(Double_t));
	Double_t* res_F1 = (Double_t*)calloc(n_eq_F1,sizeof(Double_t));
	Double_t* jac_sd_F = (Double_t*)calloc(n_jac_F,sizeof(Double_t));
	Double_t* jac_ad_F = (Double_t*)calloc(n_jac_F,sizeof(Double_t));

	Double_t t = 0;

	// Here initial values for all parameters should be read from
	// xml-files

	// Try to initialize x = (0,1,0)
	x[0] = 0;
	x[1] = 1;
	x[2] = 0;

	jmi_dae_F(ci,cd,pi,pd,dx,x,u,w,t,res_F);
	jmi_init_F0(ci,cd,pi,pd,dx,x,u,w,t,res_F0);
	jmi_init_F1(ci,cd,pi,pd,dx,x,u,w,t,res_F1);
    jmi_dae_sd_dF(ci,cd,pi,pd,dx,x,u,w,t,mask,jac_sd_F);
    jmi_dae_ad_dF(ci,cd,pi,pd,dx,x,u,w,t,mask,jac_ad_F);

	printf("\n *** State initialized to (0,1,0) ***\n\n");
	printf("DAE residual:\n");
	for (i=0;i<n_eq_F;i++){
		printf("res[%d] = %f\n",i,res_F[i]);
	}

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
		printf("jac_sd_F[%d] = %f, jac_ad_F[%d] = %f\n",i,jac_sd_F[i], i,jac_ad_F[i]);
	}

	free(ci);
	free(cd);
	free(pi);
	free(pd);
	free(dx);
	free(x);
	free(u);
	free(w);
	free(res_F);
	free(res_F0);
	free(res_F1);

	return 0;
}
