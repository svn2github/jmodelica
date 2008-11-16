

#include "jmi_cppad.hpp"


/**
 * This function is intended to be used in jmi->jmi_dae->F, since the 
 * function nnn_dae_F in the generated code has a function signature that
 * contains the AD types instead of doubles.
 */
static int cppad_dae_F () {

  // Invoke komputation of the function based on the tape.

}

static int cppad_dae_jac_F(Jmi* jmi, Jmi_Double_t* ci, Jmi_Double_t* cd, 
                           Jmi_Double_t* pi, Jmi_Double_t* pd,
		           Jmi_Double_t* dx, Jmi_Double_t* x, Jmi_Double_t* u,
		           Jmi_Double_t* w, Jmi_Double_t t, int sparsity, 
                           int skip, int* mask, Jmi_Double_t* jac) {

  int i,j;

  /*   
  int jac_n = N_eq_F;
  int jac_m = 0;
  int col_index = 0;
  */


  Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);

  // Initialize the tapes
  for (i=0;i<jmi->jmi_dae->n_ci;i++) {
    (*jcdd->ci_independent)[i] = ci[i];
  }

  for (i=0;i<jmi->jmi_dae->n_cd;i++) {
    (*jcdd->cd_independent)[i] = cd[i];
  }

  for (i=0;i<jmi->jmi_dae->n_pi;i++) {
    (*jcdd->pi_independent)[i] = pi[i];
  }

  for (i=0;i<jmi->jmi_dae->n_pd;i++) {
    (*jcdd->pd_independent)[i] = pd[i];
  }

  for (i=0;i<jmi->jmi_dae->n_dx;i++) {
    (*jcdd->dx_independent)[i] = dx[i];
  }

  for (i=0;i<jmi->jmi_dae->n_x;i++) {
    (*jcdd->x_independent)[i] = x[i];
  }

  for (i=0;i<jmi->jmi_dae->n_u;i++) {
    (*jcdd->u_independent)[i] = u[i];
  }

  for (i=0;i<jmi->jmi_dae->n_w;i++) {
    (*jcdd->w_independent)[i] = w[i];
  }

  (*jcdd->t_independent)[0] = t;


  // Evaluate Jacobians
  int n = 9;
  /* // this works...  
  std::vector<double> jac_(n);
  std::vector<double> x_tmp(jmi->jmi_dae->n_x);
  for (i=0;i<jmi->jmi_dae->n_x;i++) {
    x_tmp[i] = x[i];
  }

  jac_ = jcdd->x_tape->Jacobian(x_tmp);

  for (i=0;i<n;i++) {
    printf("* %f\n",jac_[i]);
  }

  for (i=0;i<n;i++) {
    jac[i] = jac_[i];
  }

  */
  /*
 
	if (!(skip & JMI_DER_PI_SKIP)) {
		for (i=0;i<N_pi;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_PD_SKIP)) {
		for (i=0;i<N_pd;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_DX_SKIP)) {
		for (i=0;i<N_dx;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_X_SKIP)) {
		for (i=0;i<N_x;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_U_SKIP)) {
		for (i=0;i<N_u;i++) {
			jac_m += mask[col_index++];
		}
	}
	if (!(skip & JMI_DER_W_SKIP)) {
		for (i=0;i<N_w;i++) {
			jac_m += mask[col_index++];
		}
	}

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	int jac_index = 0;
	col_index = 0;

	if (!(skip & JMI_DER_PI_SKIP)) {
		if (mask[col_index++] == 1) {
			Jmi_Double_t jac_tmp_1 = x[0];
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
		col_index += jmi->jmi_dae->n_pi;
	}

  */



  std::vector<double> jac_(jmi->jmi_dae->n_x*jmi->jmi_dae->n_eq_F);
  std::vector<double> x_(jmi->jmi_dae->n_x);
  std::vector<double> w_(jmi->jmi_dae->n_x);
  for (int i=0;i<jmi->jmi_dae->n_x;i++) {
    x_[i] = x[i];
  }
  
  jac_ = jcdd->x_tape->Jacobian(x_);
    for (int i=0;i<jmi->jmi_dae->n_x*jmi->jmi_dae->n_eq_F;i++) {
    jac[i] = jac_[i];
  }

    /*
  jcdd->x_tape->Forward(0,x_);

  for (i=0;i<jmi->jmi_dae->n_x;i++) {
    for (j=0;j<jmi->jmi_dae->n_x;j++) {
      w_[j] = 0.;
    }
    w_[i] = 1.;
    
  }
    
    */
  for (i=0;i<n;i++) {
    printf("* %f\n",jac_[i]);
  }
    


  /*
  std::vector< CppAD::AD<double> > X(2);
  std::vector< CppAD::AD<double> > Y(2);

  X[0] = 1.;
  X[1] = 2.;

  CppAD::Independent(X);
  Y[0] = X[0]+X[1]*X[0];
  Y[1] = X[1]*X[1];
  CppAD::ADFun<double> f(X,Y);
  std::vector<double> j(4);
  std::vector<double> xx(2);
  xx[0] = 1.;
  xx[1] = 2.;
  j = f.Jacobian(xx);
 
  for (i=0;i<4;i++) {
    printf("** %f\n",j[i]);
  }
  */

  return 0;

}


static int cppad_dae_jac_F_nnz(Jmi* jmi, int* nnz) {
  
  Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);
  
  if (jcdd->tapes_initialized) {
    *nnz = jcdd->jac_n_nz;
    return 0;
  } else {
    return -1;
  }

}

static int cppad_dae_jac_F_nz_indices(Jmi* jmi, int* row, int* col) {

  Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);

  if (jcdd->tapes_initialized) {
    int i;

    for (i=0;i<jcdd->jac_n_nz;i++) { 
      row[i] = jcdd->jac_irow[i];
      col[i] = jcdd->jac_icol[i];
    }

    return 0;
  } else {
    return -1;
  }

}

int jmi_cppad_new(Jmi* jmi, jmi_cppad_dae_F_t cppad_res_func) {
  
  int i;

  Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)malloc(sizeof(Jmi_cppad_dae_der));
  Jmi_dae_der *jmi_dae_der = &(jcdd->jmi_dae_der);
  
  jmi_dae_der->jac_F = cppad_dae_jac_F;
  jmi_dae_der->jac_F_nnz = cppad_dae_jac_F_nnz;
  jmi_dae_der->jac_F_nz_indices = cppad_dae_jac_F_nz_indices;
  
  jcdd->F = cppad_res_func;

  Jmi_AD_vec *ci_independent = new Jmi_AD_vec(jmi->jmi_dae->n_ci);
  jcdd->ci_independent = ci_independent;
  Jmi_AD_vec *cd_independent = new Jmi_AD_vec(jmi->jmi_dae->n_cd);
  jcdd->cd_independent = cd_independent;

  Jmi_AD_vec *pi_independent = new Jmi_AD_vec(jmi->jmi_dae->n_pi);
  Jmi_AD_vec *pi_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
  jcdd->pi_independent = pi_independent;
  jcdd->pi_dependent = pi_dependent;
  Jmi_AD_vec *pd_independent = new Jmi_AD_vec(jmi->jmi_dae->n_pd);
  Jmi_AD_vec *pd_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
  jcdd->pd_independent = pd_independent;
  jcdd->pd_dependent = pd_dependent;
  Jmi_AD_vec *dx_independent = new Jmi_AD_vec(jmi->jmi_dae->n_dx);
  Jmi_AD_vec *dx_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
  jcdd->dx_independent = dx_independent;
  jcdd->dx_dependent = dx_dependent;
  Jmi_AD_vec *x_independent = new Jmi_AD_vec(jmi->jmi_dae->n_x);
  Jmi_AD_vec *x_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
  jcdd->x_independent = x_independent;
  jcdd->x_dependent = x_dependent;
  Jmi_AD_vec *u_independent = new Jmi_AD_vec(jmi->jmi_dae->n_u);
  Jmi_AD_vec *u_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
  jcdd->u_independent = u_independent;
  jcdd->u_dependent = u_dependent;
  Jmi_AD_vec *w_independent = new Jmi_AD_vec(jmi->jmi_dae->n_w);
  Jmi_AD_vec *w_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
  jcdd->w_independent = w_independent;
  jcdd->w_dependent = w_dependent;
  Jmi_AD_vec *t_independent = new Jmi_AD_vec(1);
  Jmi_AD_vec *t_dependent = new Jmi_AD_vec(jmi->jmi_dae->n_eq_F);
  jcdd->t_independent = t_independent;
  jcdd->t_dependent = t_dependent;

  jcdd->pi_tape = NULL;
  jcdd->pd_tape = NULL;
  jcdd->dx_tape = NULL;
  jcdd->x_tape = NULL;
  jcdd->u_tape = NULL;
  jcdd->w_tape = NULL;
  jcdd->t_tape = NULL;

  jcdd->tapes_initialized = false;
  
  // TODO: Add computation of sparsity patterns. It is probably reasonable to
  // do both steps in the computation, i.e., i) compute the sparsity pattern
  // in CppAD format and ii) transform the sparsity information into Ipopt
  // format which is more compact. It should be ok to allocate this memory here.



  jmi->jmi_dae_der = (Jmi_dae_der*)jcdd;

  return 0;
}


int jmi_cppad_init(Jmi* jmi, Jmi_Double_t* ci_init, Jmi_Double_t* cd_init, 
                           Jmi_Double_t* pi_init, Jmi_Double_t* pd_init,
		           Jmi_Double_t* dx_init, Jmi_Double_t* x_init, Jmi_Double_t* u_init,
		           Jmi_Double_t* w_init, Jmi_Double_t t_init) {

  int i,j;

  Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);

  // Initialize variables
  for (i=0;i<jmi->jmi_dae->n_ci;i++) {
    (*jcdd->ci_independent)[i] = ci_init[i];
  }

  for (i=0;i<jmi->jmi_dae->n_cd;i++) {
    (*jcdd->cd_independent)[i] = cd_init[i];
  }

  for (i=0;i<jmi->jmi_dae->n_pi;i++) {
    (*jcdd->pi_independent)[i] = pi_init[i];
  }

  for (i=0;i<jmi->jmi_dae->n_pd;i++) {
    (*jcdd->pd_independent)[i] = pd_init[i];
  }

  for (i=0;i<jmi->jmi_dae->n_dx;i++) {
    (*jcdd->dx_independent)[i] = dx_init[i];
  }

  for (i=0;i<jmi->jmi_dae->n_x;i++) {
    (*jcdd->x_independent)[i] = x_init[i];
  }

  for (i=0;i<jmi->jmi_dae->n_u;i++) {
    (*jcdd->u_independent)[i] = u_init[i];
  }

  for (i=0;i<jmi->jmi_dae->n_w;i++) {
    (*jcdd->w_independent)[i] = w_init[i];
  }

  (*jcdd->t_independent)[0] = t_init;

  // Compute the tapes
  if (jmi->jmi_dae->n_pi > 0) {
    CppAD::Independent(*jcdd->pi_independent);
    jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
	    *jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
	    *jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->pi_dependent);
    jcdd->pi_tape = new CppAD::ADFun<double>(*jcdd->pi_independent,*jcdd->pi_dependent);
  }

  if (jmi->jmi_dae->n_pd > 0) {
    CppAD::Independent(*jcdd->pd_independent);
    jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
	    *jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
	    *jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->pd_dependent);
    jcdd->pd_tape = new CppAD::ADFun<double>(*jcdd->pd_independent,*jcdd->pd_dependent);
  }

  if (jmi->jmi_dae->n_dx > 0) {
    CppAD::Independent(*jcdd->dx_independent);
    jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
	    *jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
	    *jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->dx_dependent);
    jcdd->dx_tape = new CppAD::ADFun<double>(*jcdd->dx_independent,*jcdd->dx_dependent);
  }
  
  if (jmi->jmi_dae->n_x > 0) {
    CppAD::Independent(*jcdd->x_independent);
    jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
	    *jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
	    *jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->x_dependent);
    jcdd->x_tape = new CppAD::ADFun<double>(*jcdd->x_independent,*jcdd->x_dependent);
  }

  if (jmi->jmi_dae->n_u > 0) {
    CppAD::Independent(*jcdd->u_independent);
    jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
	    *jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
	    *jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->u_dependent);
    jcdd->u_tape = new CppAD::ADFun<double>(*jcdd->u_independent,*jcdd->u_dependent);
  }

  if (jmi->jmi_dae->n_w > 0) {
    CppAD::Independent(*jcdd->w_independent);
    jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
	    *jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
	    *jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->w_dependent);
    jcdd->w_tape = new CppAD::ADFun<double>(*jcdd->w_independent,*jcdd->w_dependent);
  }

  CppAD::Independent(*jcdd->t_independent);
    jcdd->F(jmi,*jcdd->ci_independent, *jcdd->cd_independent, *jcdd->pi_independent,
	    *jcdd->pd_independent, *jcdd->dx_independent, *jcdd->x_independent,
	    *jcdd->u_independent, *jcdd->w_independent, (*jcdd->t_independent)[0], *jcdd->t_dependent);
    jcdd->t_tape = new CppAD::ADFun<double>(*jcdd->t_independent,*jcdd->t_dependent);
 
  // Compute sparsity patterns
  int m = jmi->jmi_dae->n_eq_F; // Number of rows in Jacobian

  std::vector<bool> r_pi(jmi->jmi_dae->n_pi*jmi->jmi_dae->n_pi);
  std::vector<bool> s_pi(m*jmi->jmi_dae->n_pi);
  for (i=0;i<jmi->jmi_dae->n_pi;i++) {
    for (j=0;j<jmi->jmi_dae->n_pi;j++) {
      if(i==j) {
	r_pi[i*jmi->jmi_dae->n_pi+j] = true;
      } else{
	r_pi[i*jmi->jmi_dae->n_pi+j] = false;
      }
    }
  }

  std::vector<bool> r_pd(jmi->jmi_dae->n_pd*jmi->jmi_dae->n_pd);
  std::vector<bool> s_pd(m*jmi->jmi_dae->n_pd);
  for (i=0;i<jmi->jmi_dae->n_pd;i++) {
    for (j=0;j<jmi->jmi_dae->n_pd;j++) {
      if(i==j) {
	r_pd[i*jmi->jmi_dae->n_pd+j] = true;
      } else{
	r_pd[i*jmi->jmi_dae->n_pd+j] = false;
      }
    }
  }

  std::vector<bool> r_dx(jmi->jmi_dae->n_dx*jmi->jmi_dae->n_dx);
  std::vector<bool> s_dx(m*jmi->jmi_dae->n_dx);
  for (i=0;i<jmi->jmi_dae->n_dx;i++) {
    for (j=0;j<jmi->jmi_dae->n_dx;j++) {
      if(i==j) {
	r_dx[i*jmi->jmi_dae->n_dx+j] = true;
      } else{
	r_dx[i*jmi->jmi_dae->n_dx+j] = false;
      }
    }
  }


  std::vector<bool> r_x(jmi->jmi_dae->n_x*jmi->jmi_dae->n_dx);
  std::vector<bool> s_x(m*jmi->jmi_dae->n_x);
  for (i=0;i<jmi->jmi_dae->n_dx;i++) {
    for (j=0;j<jmi->jmi_dae->n_x;j++) {
      if(i==j) {
	r_x[i*jmi->jmi_dae->n_x+j] = true;
      } else{
	r_x[i*jmi->jmi_dae->n_x+j] = false;
      }
    }
  }

  std::vector<bool> r_u(jmi->jmi_dae->n_u*jmi->jmi_dae->n_u);
  std::vector<bool> s_u(m*jmi->jmi_dae->n_u);
  for (i=0;i<jmi->jmi_dae->n_u;i++) {
    for (j=0;j<jmi->jmi_dae->n_u;j++) {
      if(i==j) {
	r_u[i*jmi->jmi_dae->n_u+j] = true;
      } else{
	r_u[i*jmi->jmi_dae->n_u+j] = false;
      }
    }
  }

  std::vector<bool> r_w(jmi->jmi_dae->n_w*jmi->jmi_dae->n_w);
  std::vector<bool> s_w(m*jmi->jmi_dae->n_w);
  for (i=0;i<jmi->jmi_dae->n_w;i++) {
    for (j=0;j<jmi->jmi_dae->n_w;j++) {
      if(i==j) {
	r_u[i*jmi->jmi_dae->n_w+j] = true;
      } else{
	r_u[i*jmi->jmi_dae->n_w+j] = false;
      }
    }
  }

  std::vector<bool> r_t(1);
  std::vector<bool> s_t(m);
  for (i=0;i<m;i++) {
    for (j=0;j<1;j++) {
      if(i==j) {
	r_t[i*1+j] = true;
      } else{
	r_t[i*1+j] = false;
      }
    }
  }

  jcdd->jac_n_nz = 0;
  
  if (jmi->jmi_dae->n_pi > 0) {
    s_pi = jcdd->pi_tape->ForSparseJac(jmi->jmi_dae->n_pi,r_pi);
  }

  if (jmi->jmi_dae->n_pd > 0) {
    s_pd = jcdd->pd_tape->ForSparseJac(jmi->jmi_dae->n_pd,r_pd);
  }

  if (jmi->jmi_dae->n_dx > 0) {
    s_dx = jcdd->dx_tape->ForSparseJac(jmi->jmi_dae->n_dx,r_dx);
  }

  if (jmi->jmi_dae->n_x > 0) {
    s_x = jcdd->x_tape->ForSparseJac(jmi->jmi_dae->n_x,r_x);
  }

  if (jmi->jmi_dae->n_u > 0) {
    s_u = jcdd->u_tape->ForSparseJac(jmi->jmi_dae->n_u,r_u);
  }

  if (jmi->jmi_dae->n_w > 0) {
    s_w = jcdd->w_tape->ForSparseJac(jmi->jmi_dae->n_w,r_w);
  }

  s_t = jcdd->t_tape->ForSparseJac(1,r_t);

  for (i=0;i<(int)s_pi.size();i++) { // cast to int since size() gives unsigned int...
    if (s_pi[i]) jcdd->jac_n_nz++;
  }

  for (i=0;i<(int)s_pd.size();i++) {
    if (s_pd[i]) jcdd->jac_n_nz++;
  }

  for (i=0;i<(int)s_dx.size();i++) {
    if (s_dx[i]) jcdd->jac_n_nz++;
  }

  for (i=0;i<(int)s_x.size();i++) {
    if (s_x[i]) jcdd->jac_n_nz++;
  }

  for (i=0;i<(int)s_u.size();i++) {
    if (s_u[i]) jcdd->jac_n_nz++;
  }

  for (i=0;i<(int)s_w.size();i++) {
    if (s_w[i]) jcdd->jac_n_nz++;
  }

  for (i=0;i<(int)s_t.size();i++) {
    if (s_t[i]) jcdd->jac_n_nz++;
  }


  jcdd->jac_icol = (int*)calloc(jcdd->jac_n_nz,sizeof(int));
  jcdd->jac_irow = (int*)calloc(jcdd->jac_n_nz,sizeof(int));

  int jac_ind = 0;
  int col_ind = 0;

  for (i=0;i<m;i++) {
    for (j=0;j<jmi->jmi_dae->n_pi;j++) {
      if (s_pi[i*jmi->jmi_dae->n_pi + j]) {
	jcdd->jac_icol[jac_ind] = j + col_ind + 1;
        jcdd->jac_irow[jac_ind++] = i + 1;
      }
    }
  }
  col_ind += jmi->jmi_dae->n_pi;

  for (i=0;i<m;i++) {
    for (j=0;j<jmi->jmi_dae->n_pd;j++) {
      if (s_pd[i*jmi->jmi_dae->n_pd + j]) {
	jcdd->jac_icol[jac_ind] = j + col_ind + 1;
        jcdd->jac_irow[jac_ind++] = i + 1;
      }
    }
  }
  col_ind += jmi->jmi_dae->n_pd;

  for (i=0;i<m;i++) {
    for (j=0;j<jmi->jmi_dae->n_dx;j++) {
      if (s_dx[i*jmi->jmi_dae->n_dx + j]) {
	jcdd->jac_icol[jac_ind] = j + col_ind + 1;
        jcdd->jac_irow[jac_ind++] = i + 1;
      }
    }
  }
  col_ind += jmi->jmi_dae->n_dx;

  for (i=0;i<m;i++) {
    for (j=0;j<jmi->jmi_dae->n_x;j++) {
      if (s_x[i*jmi->jmi_dae->n_x + j]) {
	jcdd->jac_icol[jac_ind] = j + col_ind + 1;
        jcdd->jac_irow[jac_ind++] = i + 1;
      }
    }
  }
  col_ind += jmi->jmi_dae->n_x;

  for (i=0;i<m;i++) {
    for (j=0;j<jmi->jmi_dae->n_u;j++) {
      if (s_u[i*jmi->jmi_dae->n_u + j]) {
	jcdd->jac_icol[jac_ind] = j + col_ind + 1;
        jcdd->jac_irow[jac_ind++] = i + 1;
      }
    }
  }
  col_ind += jmi->jmi_dae->n_u;

  for (i=0;i<m;i++) {
    for (j=0;j<jmi->jmi_dae->n_w;j++) {
      if (s_w[i*jmi->jmi_dae->n_w + j]) {
	jcdd->jac_icol[jac_ind] = j + col_ind + 1;
        jcdd->jac_irow[jac_ind++] = i + 1;
      }
    }
  }
  col_ind += jmi->jmi_dae->n_w;

  for (i=0;i<m;i++) {
    for (j=0;j<1;j++) {
      if (s_t[i*1 + j]) {
	jcdd->jac_icol[jac_ind] = j + col_ind + 1;
        jcdd->jac_irow[jac_ind++] = i + 1;
      }
    }
  }

  jcdd->tapes_initialized = true;

  /*
  for (i=0;i<jcdd->jac_n_nz;i++) {
    printf("*** %d, %d\n",jcdd->jac_irow[i],jcdd->jac_icol[i]);
  }


  printf("*** %d\n",jcdd->jac_n_nz);

  for (i=0;i<m*jmi->jmi_dae->n_x;i++) {
    printf("*** %d\n",s_x[i]? 1 : 0);
  }
  */

  return 0;
}


int jmi_cppad_delete(Jmi* jmi) {
  Jmi_cppad_dae_der *jcdd = (Jmi_cppad_dae_der*)(jmi->jmi_dae_der);
  delete jcdd->ci_independent;
  delete jcdd->cd_independent;
  delete jcdd->pi_independent;
  delete jcdd->pi_dependent;
  delete jcdd->pi_tape;
  delete jcdd->pd_independent;
  delete jcdd->pd_dependent;
  delete jcdd->pd_tape;
  delete jcdd->dx_independent;
  delete jcdd->dx_dependent;
  delete jcdd->dx_tape;
  delete jcdd->x_independent;
  delete jcdd->x_dependent;
  delete jcdd->x_tape;
  delete jcdd->u_independent;
  delete jcdd->u_dependent;
  delete jcdd->u_tape;
  delete jcdd->w_independent;
  delete jcdd->w_dependent;
  delete jcdd->w_tape;
  delete jcdd->t_independent;
  delete jcdd->t_dependent;
  delete jcdd->t_tape;

  free(jcdd);
  return 0;
}

/*
typedef struct {
  Jmi_dae_der jmi_dae_der;
  jmi_cppad_dae_F_t F;
  CppAD::ADFun<double> *pi_tape;
  CppAD::ADFun<double> *pd_tape;
  CppAD::ADFun<double> *dx_tape;
  CppAD::ADFun<double> *x_tape;
  CppAD::ADFun<double> *u_tape;
  CppAD::ADFun<double> *w_tape;
} Jmi_cppad_dae_der;

*/
