
#include <vector>
#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include "../../Jmi/jmi.h"
#include "../../Jmi/jmi_cppad.hpp"

#include <cppad/cppad.hpp>

      template <class Type>
      Type Poly(const std::vector<double> &a, const Type &x)
      {     size_t k  = a.size();
            Type y   = 0.;  // initialize summation
            Type x_i = 1.;  // initialize x^i
            size_t i;
            for(i = 0; i < k; i++)
            {     y   += a[i] * x_i;  // y   = y + a_i * x^i
                  x_i *= x;           // x_i = x_i * x
            }
            return y;
      }


int test_cppad() {
    using CppAD::AD;           // use AD as abbreviation for CppAD::AD
      using std::vector;         // use vector as abbreviation for std::vector
      size_t i;                  // a temporary index

      // vector of polynomial coefficients
      size_t k = 5;              // number of polynomial coefficients
      vector<double> a(k);       // vector of polynomial coefficients
      for(i = 0; i < k; i++)
            a[i] = 1.;           // value of polynomial coefficients

      // domain space vector
      size_t n = 2;              // number of domain space variables
      vector< AD<double> > X(n); // vector of domain space variables
      X[0] = 3.;                 // value corresponding to operation sequence

      // declare independent variables and start recording operation sequence
      CppAD::Independent(X);

      // range space vector
      size_t m = 1;              // number of ranges space variables
      vector< AD<double> > Y(m); // vector of ranges space variables
      Y[0] = Poly(a, X[0]);      // value during recording of operations

      // store operation sequence in f: X -> Y and stop recording
      CppAD::ADFun<double> f(X, Y);

      // compute derivative using operation sequence stored in f
      vector<double> jac(m * n); // Jacobian of f (m by n matrix)
      vector<double> x(n);       // domain space vector
      x[0] = 3.;                 // argument value for derivative
      jac  = f.Jacobian(x);      // Jacobian for operation sequence

      // print the results
      std::cout << "f'(3) computed by CppAD = " << jac[0] << std::endl;

      // check if the derivative is correct
      int error_code;
      if( jac[0] == 142. )
            error_code = 0;      // return code for correct case
      else  error_code = 1;      // return code for incorrect case

      return error_code;

}

int main(int argv, char* argc[])
{

	Jmi* jmi;
	jmi_new(&jmi);

	int i;

	int jac_F_nnz;
	jmi->jmi_dae->jac_sd_F_nnz(jmi,&jac_F_nnz);
	int* jac_F_row = (int*)calloc(jac_F_nnz,sizeof(int));
	int* jac_F_col = (int*)calloc(jac_F_nnz,sizeof(int));

	int jac_F_n_dense = (jmi->jmi_dae->n_pi +
			jmi->jmi_dae->n_pd +
			jmi->jmi_dae->n_dx +
			jmi->jmi_dae->n_x +
			jmi->jmi_dae->n_u +
			jmi->jmi_dae->n_w) * jmi->jmi_dae->n_eq_F;

	printf("Number of interactive constants:               %d\n",jmi->jmi_dae->n_ci);
	printf("Number of dependent constants:                 %d\n",jmi->jmi_dae->n_cd);
	printf("Number of interactive parameters:              %d\n",jmi->jmi_dae->n_pi);
	printf("Number of dependent parameters:                %d\n",jmi->jmi_dae->n_pd);
	printf("Number of derivatives:                         %d\n",jmi->jmi_dae->n_dx);
	printf("Number of states:                              %d\n",jmi->jmi_dae->n_x);
	printf("Number of inputs:                              %d\n",jmi->jmi_dae->n_u);
	printf("Number of algebraics:                          %d\n",jmi->jmi_dae->n_w);
	printf("Number of DAE equations:                       %d\n",jmi->jmi_dae->n_eq_F);
/*	printf("Number of DAE initial equations (F0):          %d\n",n_eq_F0);
	printf("Number of DAE initial equations (F1):          %d\n",n_eq_F1);
	printf("Number of elements in Jacobian wrt dx, x, u:   %d\n",n_jac_F);
*/

	Jmi_Double_t* ci = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_ci,sizeof(Jmi_Double_t));
	Jmi_Double_t* cd = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_cd,sizeof(Jmi_Double_t));
	Jmi_Double_t* pi = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_pi,sizeof(Jmi_Double_t));
	Jmi_Double_t* pd = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_pd,sizeof(Jmi_Double_t));
	Jmi_Double_t* dx = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_dx,sizeof(Jmi_Double_t));
	Jmi_Double_t* x = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_x,sizeof(Jmi_Double_t));
	Jmi_Double_t* u = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_u,sizeof(Jmi_Double_t));
	Jmi_Double_t* w = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_w,sizeof(Jmi_Double_t));
	Jmi_Double_t* res_F = (Jmi_Double_t*)calloc(jmi->jmi_dae->n_eq_F,sizeof(Jmi_Double_t));
	Jmi_Double_t* jac_sd_F = (Jmi_Double_t*)calloc(jac_F_nnz,sizeof(Jmi_Double_t));
	Jmi_Double_t* jac_sd_F_dense = (Jmi_Double_t*)calloc(jac_F_n_dense,sizeof(Jmi_Double_t));
/*	Jmi_Double_t* res_F0 = (Jmi_Double_t*)calloc(n_eq_F0,sizeof(Jmi_Double_t));
	Jmi_Double_t* res_F1 = (Jmi_Double_t*)calloc(n_eq_F1,sizeof(Jmi_Double_t));
	Jmi_Double_t* jac_DER_F = (Jmi_Double_t*)calloc(n_jac_F,sizeof(Jmi_Double_t));
*/
	Jmi_Double_t t = 0;

	// Here initial values for all parameters should be reDER from
	// xml-files
    pi[0] = 1;

	// Try to initialize x = (0,1,0)
	x[0] = 1;
	x[1] = 2;
	x[2] = 3;


	// Initialize the AD stuff
	jmi_cppad_init(jmi, ci, cd, pi, pd, dx, x, u, w, t);



	jmi->jmi_dae->F(jmi,ci,cd,pi,pd,dx,x,u,w,t,res_F);

	/*	jmi_init_F0(ci,cd,pi,pd,dx,x,u,w,t,res_F0);
	jmi_init_F1(ci,cd,pi,pd,dx,x,u,w,t,res_F1);
    jmi_dae_ad_dF(ci,cd,pi,pd,dx,x,u,w,t,mask,jac_DER_F);
	*/

	printf("\n *** State initialized to (%f,%f,%f) ***\n\n",x[0],x[1],x[2]);
	printf("DAE residual:\n");
	for (i=0;i<jmi->jmi_dae->n_eq_F;i++){
		printf("res[%d] = %f\n",i,res_F[i]);
	}

	jmi->jmi_dae->jac_sd_F_nz_indices(jmi,jac_F_row,jac_F_col);
	printf("Number of non-zeros in the DAE residual Jacobian: %d\n",jac_F_nnz);
	for (i=0;i<jac_F_nnz;i++) {
		printf("%d, %d\n",jac_F_row[i],jac_F_col[i]);
	}

	int* mask = (int*)calloc(jac_F_nnz,sizeof(int));
	for(i=0;i<jac_F_nnz;i++) {
		mask[i]=1;
	}
    jmi->jmi_dae->jac_sd_F(jmi,ci,cd,pi,pd,dx,x,u,w,t,JMI_DER_SPARSE,0,mask,jac_sd_F);
	printf("Jacobian (sparse):\n");
	for (i=0;i<jac_F_nnz;i++) {
		printf("%f\n",jac_sd_F[i]);
	}

    jmi->jmi_dae->jac_sd_F(jmi,ci,cd,pi,pd,dx,x,u,w,t,JMI_DER_DENSE_COL_MAJOR,0,mask,jac_sd_F_dense);
	printf("Jacobian (dense col major):\n");
	for (i=0;i<jac_F_n_dense;i++) {
		printf("%f\n",jac_sd_F_dense[i]);
	}

    jmi->jmi_dae->jac_sd_F(jmi,ci,cd,pi,pd,dx,x,u,w,t,JMI_DER_DENSE_ROW_MAJOR,0,mask,jac_sd_F_dense);
	printf("Jacobian (dense row major):\n");
	for (i=0;i<jac_F_n_dense;i++) {
		printf("%f\n",jac_sd_F_dense[i]);
	}

	// Do some stuff with the AD functions
	int jac_cppad_F_nnz;
	jmi->jmi_dae_der->jac_F_nnz(jmi,&jac_cppad_F_nnz);
	int* jac_cppad_F_row = (int*)calloc(jac_cppad_F_nnz,sizeof(int));
	int* jac_cppad_F_col = (int*)calloc(jac_cppad_F_nnz,sizeof(int));

	Jmi_Double_t* jac_cppad_F = (Jmi_Double_t*)calloc(jac_F_n_dense,sizeof(Jmi_Double_t));	

	Jmi_Double_t* jac_cppad_F_dense = (Jmi_Double_t*)calloc(jac_F_n_dense,sizeof(Jmi_Double_t));



	jmi->jmi_dae_der->jac_F_nz_indices(jmi,jac_cppad_F_row,jac_cppad_F_col);
	printf("Number of non-zeros in the DAE residual Jacobian (cppad): %d\n",jac_cppad_F_nnz);
	for (i=0;i<jac_cppad_F_nnz;i++) {
		printf("%d, %d\n",jac_cppad_F_row[i],jac_cppad_F_col[i]);
	}	

    jmi->jmi_dae_der->jac_F(jmi,ci,cd,pi,pd,dx,x,u,w,t,JMI_DER_SPARSE,0,mask,jac_cppad_F);
	printf("Jacobian (sparse) (cppad):\n");
	for (i=0;i<jac_cppad_F_nnz;i++) {
		printf("%f\n",jac_cppad_F[i]);
	}

    jmi->jmi_dae_der->jac_F(jmi,ci,cd,pi,pd,dx,x,u,w,t,JMI_DER_DENSE_COL_MAJOR,0,mask,jac_cppad_F_dense);
	printf("Jacobian (dense col major) (cppad):\n");
	for (i=0;i<jac_F_n_dense;i++) {
		printf("%f\n",jac_cppad_F_dense[i]);
	}

    jmi->jmi_dae_der->jac_F(jmi,ci,cd,pi,pd,dx,x,u,w,t,JMI_DER_DENSE_ROW_MAJOR,0,mask,jac_cppad_F_dense);
	printf("Jacobian (dense row major) (cppad):\n");
	for (i=0;i<jac_F_n_dense;i++) {
		printf("%f\n",jac_cppad_F_dense[i]);
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

	free(ci);
	free(cd);
	free(pi);
	free(pd);
	free(dx);
	free(x);
	free(u);
	free(w);
	free(res_F);
	free(jac_sd_F);
	free(jac_sd_F_dense);
	free(mask);
/*	free(res_F0);
	free(res_F1);
*/

	free(jac_F_row);
	free(jac_F_col);

	jmi_delete(jmi);


	test_cppad();

	return 0;
}
