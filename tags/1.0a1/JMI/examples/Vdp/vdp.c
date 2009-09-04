 /*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/


/**
 * This file encodes the optimization problem
 *
 *  min x_3(t_f) + p_2*x_3(t_1) + p_1^2 + w_1(t_f)^2 + p_2*w_1(t_1)^2
 *  u_1,p_1
 *
 *  subject to
 *
 *   \dot x_1 = (1 - x_2^2)*x_1 - x_2 + u_1
 *   \dot x_2 = p_1*x_1
 *   \dot x_3 = exp(p_3*t)*(x_1^2 + x_2^2 + u_1^2);
 *   w_1 = x_1 + x_2
 *
 *  x_1 >= -0.5
 *  u_1 >= -0.5
 *  u_1 <= 1
 *
 *  x_1(t_f) = 0;
 *  x_2(t_f) = 0;
 * with initial conditions
 *
 *   x_1(0) = 0;
 *   x_2(0) = 1;
 *   x_3(0) = 0;
 *
 *  and t_f = 5.
 *  and t_1 = 0.1
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <jmi.h>

static const int x1_0 = 0;
static const int x2_0 = 1;
static const int x3_0 = 0;

static const int N_ci = 0;
static const int N_cd = 0;
static const int N_pi = 3;
static const int N_pd = 0;
static const int N_dx = 3;
static const int N_x = 3;
static const int N_u = 1;
static const int N_w = 1;
static const int N_eq_F = 4;

static const int N_eq_F0 = 7;
static const int N_eq_F1 = 0;
static const int N_eq_Fp = 0;

static const int N_eq_Ceq = 0;
static const int N_eq_Cineq = 3;
static const int N_eq_Heq = 2;
static const int N_eq_Hineq = 0;

static const int N_t_p = 2;

#define _ci(i) ((*(jmi->z))[jmi->offs_ci+i])
#define _cd(i) ((*(jmi->z))[jmi->offs_cd+i])
#define _pi(i) ((*(jmi->z))[jmi->offs_pi+i])
#define _pd(i) ((*(jmi->z))[jmi->offs_pd+i])
#define _dx(i) ((*(jmi->z))[jmi->offs_dx+i])
#define _x(i) ((*(jmi->z))[jmi->offs_x+i])
#define _u(i) ((*(jmi->z))[jmi->offs_u+i])
#define _w(i) ((*(jmi->z))[jmi->offs_w+i])
#define _t ((*(jmi->z))[jmi->offs_t])
#define _dx_p(j,i) ((*(jmi->z))[jmi->offs_dx_p + j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)+ i])
#define _x_p(j,i) ((*(jmi->z))[jmi->offs_x_p + j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])
#define _u_p(j,i) ((*(jmi->z))[jmi->offs_u_p + j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])
#define _w_p(j,i) ((*(jmi->z))[jmi->offs_w_p + j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])
/*
#define ci jmi_get_ci(jmi);
#define cd jmi_get_cd(jmi);
#define pi jmi_get_pi(jmi);
#define pd jmi_get_pd(jmi);
#define dx jmi_get_dx(jmi);
#define x jmi_get_x(jmi);
#define u jmi_get_u(jmi);
#define w jmi_get_w(jmi);
#define t jmi_get_t(jmi);
*/

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

  (*res)[0] = (1-_x(1)*_x(1))*_x(0) - _x(1) + _u(0) - _dx(0);
  (*res)[1] = _pi(0)*_x(0) - _dx(1);
  (*res)[2] = exp(_pi(2)*_t)*(_x(0)*_x(0) + _x(1)*_x(1) + _u(0)*_u(0)) - _dx(2);
  (*res)[3] = _x(0) + _x(1) - _w(0);

  return 0;
}

/*
 * TODO: This code can certainly be improved and optimized. For example, macros would probably
 * make it easier to read.
 */

static int vdp_dae_dF(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	jmi_real_t* ci = jmi_get_ci(jmi);
	jmi_real_t* cd = jmi_get_cd(jmi);
	jmi_real_t* pi = jmi_get_pi(jmi);
	jmi_real_t* pd = jmi_get_pd(jmi);
	jmi_real_t* dx = jmi_get_dx(jmi);
	jmi_real_t* x = jmi_get_x(jmi);
	jmi_real_t* u = jmi_get_u(jmi);
	jmi_real_t* w = jmi_get_w(jmi);
	jmi_real_t* t = jmi_get_t(jmi);

	int i;
	int jac_n = N_eq_F;
	int mask_col_index = 0;
	int jac_col_index = 0;

	int jac_m;
	int jac_n_nz;
	jmi_dae_dF_dim(jmi,JMI_DER_SYMBOLIC,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	// pi_0 row 1, col 0: x[0]
	// pi_2 row 2, col 2: t*exp(pi[2]*t)*(x[0]*x[0] + x[1]*x[1] + u[0]*u[0])

	// dx_0 row 0, col 1: -1
	// dx_1 row 1, col 2: -1
	// dx_2 row 2, col 3: -1

	// x_0 row 0, col 4: (1-x[1]*x[1])
	// x_0 row 1, col 4: pi[0]
	// x_0 row 2, col 4: exp(pi[2]*t)*2*x[0]
	// x_0 row 3, col 4: 1
	// x_1 row 0, col 5: -2*x[1]*x[0] - 1
	// x_1 row 2, col 5: exp(pi[2]*t)*2*x[1]
    // x_1 row 3, col 5: 1

	// u_0 row 0, col 7: 1
	// u_0 row 2, col 7: exp(pi[2]*t)*2*u[0]

	// w_0 row 4, col 8: -1

	// t row 3, col 9: pi[2]*exp(pi[2]*t)*(x[0]*x[0] + x[1]*x[1] + u[0]*u[0])

	int jac_index = 0;
	mask_col_index = 0;
	if ((independent_vars & JMI_DER_PI)) {

		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = x[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 1] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*1 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jmi_real_t jac_tmp_1 = t[0]*exp(pi[2]*t[0])*(x[0]*x[0] + x[1]*x[1] + u[0]*u[0]);
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					jac[jac_n*jac_col_index + 2] = jac_tmp_1;
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					jac[jac_m*2 + jac_col_index] = jac_tmp_1;
					break;
				case JMI_DER_SPARSE:
					jac[jac_index] = jac_tmp_1;
					jac_index++;
				}
				jac_col_index++;
			}

		}
	} else {
		mask_col_index += jmi->n_pi;
	}

	if ((independent_vars & JMI_DER_DX)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 1] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*1 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 2] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*2 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_dx;
	}

	if ((independent_vars & JMI_DER_X)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = (1-x[1]*x[1]);
			jmi_real_t jac_tmp_2 = pi[0];
			jmi_real_t jac_tmp_3 = exp(pi[2]*t[0])*2*x[0];
			jmi_real_t jac_tmp_4 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				jac[jac_n*jac_col_index + 1] = jac_tmp_2;
				jac[jac_n*jac_col_index + 2] = jac_tmp_3;
				jac[jac_n*jac_col_index + 3] = jac_tmp_4;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				jac[jac_m*1 + jac_col_index] = jac_tmp_2;
				jac[jac_m*2 + jac_col_index] = jac_tmp_3;
				jac[jac_m*3 + jac_col_index] = jac_tmp_4;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
				jac[jac_index++] = jac_tmp_3;
				jac[jac_index++] = jac_tmp_4;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -2*x[1]*x[0] - 1;
			jmi_real_t jac_tmp_2 = exp(pi[2]*t[0])*2*x[1];
			jmi_real_t jac_tmp_3 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				jac[jac_n*jac_col_index + 2] = jac_tmp_2;
				jac[jac_n*jac_col_index + 3] = jac_tmp_3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				jac[jac_m*2 + jac_col_index] = jac_tmp_2;
				jac[jac_m*3 + jac_col_index] = jac_tmp_3;
				jac_index += 3;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
				jac[jac_index++] = jac_tmp_3;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_x;
	}

	if ((independent_vars & JMI_DER_U)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = 1;
			jmi_real_t jac_tmp_2 = exp(pi[2]*t[0])*2*u[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				jac[jac_n*jac_col_index + 2] = jac_tmp_2;
				jac_index += 3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				jac[jac_m*2 + jac_col_index] = jac_tmp_2;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_u;
	}

	if ((independent_vars & JMI_DER_W)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 3] = jac_tmp_1;
				jac_index += 3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*3 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_w;
	}

	if ((independent_vars & JMI_DER_T)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = pi[2]*exp(pi[2]*t[0])*(x[0]*x[0] + x[1]*x[1] + u[0]*u[0]);
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 2] = jac_tmp_1;
				jac_index += 3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*2 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += 1;
	}



	return 0;
}

static int vdp_dae_dF_n_nz(int* n_nz) {

	*n_nz = (2 + //pi
			0 + //pd
			3 + //dx
			7 + //x
			2 + //u
			1 + //w
			1 //t
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

	//dF/dpd_2
	row[jac_ind] = 3;
	col[jac_ind++] = 3;

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
	//dF/x_1
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 2;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 4;
	col[jac_ind++] = col_ind + 1;

	//dF/x_2
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 2;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 2;
	row[jac_ind] = 4;
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
	row[jac_ind] = 4;
	col[jac_ind++] = col_ind + 1;
	col_ind += N_w;

	// Jacobian for time
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;

	return 0;
}

static int vdp_init_F0(jmi_t* jmi, jmi_ad_var_vec_p res) {
/*
	printf("- pi[0] = %f\n",_pi(0));
	printf("- dx[0] = %f\n",_dx(0));
	printf("- dx[1] = %f\n",_dx(1));
	printf("- dx[2] = %f\n",_dx(2));
	printf("- x[0] = %f\n",_x(0));
	printf("- x[1] = %f\n",_x(1));
	printf("- x[2] = %f\n",_x(2));
	printf("- u[0] = %f\n",_u(0));
	printf("- w[0] = %f\n",_w(0));
*/

  (*res)[0] = (1-_x(1)*_x(1))*_x(0) - _x(1) + _u(0) - _dx(0);
  (*res)[1] = _pi(0)*_x(0) - _dx(1);
  (*res)[2] = exp(_pi(2)*_t)*(_x(0)*_x(0) + _x(1)*_x(1) + _u(0)*_u(0)) - _dx(2);
  (*res)[3] = _x(0) + _x(1) - _w(0);
  (*res)[4] = _x(0) - x1_0;
  (*res)[5] = _x(1) - x2_0;
  (*res)[6] = _x(2) - x3_0;

/*
  printf("-- %f\n",(*res)[0]);
  printf("-- %f\n",(*res)[1]);
  printf("-- %f\n",(*res)[2]);
  printf("-- %f\n",(*res)[3]);
  printf("-- %f\n",(*res)[4]);
  printf("-- %f\n",(*res)[5]);
  printf("-- %f\n",(*res)[6]);
*/

  return 0;
}

static int vdp_init_dF0(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	jmi_real_t* ci = jmi_get_ci(jmi);
	jmi_real_t* cd = jmi_get_cd(jmi);
	jmi_real_t* pi = jmi_get_pi(jmi);
	jmi_real_t* pd = jmi_get_pd(jmi);
	jmi_real_t* dx = jmi_get_dx(jmi);
	jmi_real_t* x = jmi_get_x(jmi);
	jmi_real_t* u = jmi_get_u(jmi);
	jmi_real_t* w = jmi_get_w(jmi);
	jmi_real_t* t = jmi_get_t(jmi);

	int i;
	int jac_n = N_eq_F0;
	int mask_col_index = 0;
    int jac_col_index = 0;
/*
    printf("hej\n");
    for (i=0;i<jmi->n_z;i++) {
    	printf("--- %d\n",mask[i]);
    }
    printf("hej\n");
*/
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
	mask_col_index = 0;
	if ((independent_vars & JMI_DER_PI)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = x[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 1] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*1 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = t[0]*exp(pi[2]*t[0])*(x[0]*x[0] + x[1]*x[1] + u[0]*u[0]);
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 2] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*2 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}

	} else {
		mask_col_index += jmi->n_pi;
	}

	if ((independent_vars & JMI_DER_DX)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 1] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*1 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 2] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*2 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_dx;
	}

	if ((independent_vars & JMI_DER_X)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = (1-x[1]*x[1]);
			jmi_real_t jac_tmp_2 = pi[0];
			jmi_real_t jac_tmp_3 = exp(pi[2]*t[0])*2*x[0];
			jmi_real_t jac_tmp_4 = 1;
			jmi_real_t jac_tmp_5 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				jac[jac_n*jac_col_index + 1] = jac_tmp_2;
				jac[jac_n*jac_col_index + 2] = jac_tmp_3;
				jac[jac_n*jac_col_index + 3] = jac_tmp_4;
				jac[jac_n*jac_col_index + 4] = jac_tmp_5;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				jac[jac_m*1 + jac_col_index] = jac_tmp_2;
				jac[jac_m*2 + jac_col_index] = jac_tmp_3;
				jac[jac_m*3 + jac_col_index] = jac_tmp_4;
				jac[jac_m*4 + jac_col_index] = jac_tmp_5;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
				jac[jac_index++] = jac_tmp_3;
				jac[jac_index++] = jac_tmp_4;
				jac[jac_index++] = jac_tmp_5;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -2*x[1]*x[0] - 1;
			jmi_real_t jac_tmp_2 = exp(pi[2]*t[0])*2*x[1];
			jmi_real_t jac_tmp_3 = 1;
			jmi_real_t jac_tmp_4 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				jac[jac_n*jac_col_index + 2] = jac_tmp_2;
				jac[jac_n*jac_col_index + 3] = jac_tmp_3;
				jac[jac_n*jac_col_index + 5] = jac_tmp_4;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				jac[jac_m*2 + jac_col_index] = jac_tmp_2;
				jac[jac_m*3 + jac_col_index] = jac_tmp_3;
				jac[jac_m*5 + jac_col_index] = jac_tmp_4;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
				jac[jac_index++] = jac_tmp_3;
				jac[jac_index++] = jac_tmp_4;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 6] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*6 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_x;
	}

	if ((independent_vars & JMI_DER_U)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = 1;
			jmi_real_t jac_tmp_2 = exp(pi[2]*t[0])*2*u[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				jac[jac_n*jac_col_index + 2] = jac_tmp_2;
				jac_index += 3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				jac[jac_m*2 + jac_col_index] = jac_tmp_2;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_u;
	}


	if ((independent_vars & JMI_DER_W)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 3] = jac_tmp_1;
				jac_index += 3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*3 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_w;
	}

	if ((independent_vars & JMI_DER_T)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = pi[2]*exp(pi[2]*t[0])*(x[0]*x[0] + x[1]*x[1] + u[0]*u[0]);
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 2] = jac_tmp_1;
				jac_index += 3;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*2 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
			}
			jac_col_index++;
		}
	} else {
		mask_col_index += 1;
	}


	return 0;
}

static int vdp_init_dF0_n_nz(int* n_nz) {

	*n_nz = (2 + //pi
			0 + //pd
			3 + //dx
			7 + 3 + //x
			2 + //u
			1 + //w
			1 //t
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

	//dF/dpd_2
	row[jac_ind] = 3;
	col[jac_ind++] = 3;

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
	row[jac_ind] = 5;
	col[jac_ind++] = col_ind + 1;

	//dF/dx_2
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 2;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 2;
	row[jac_ind] = 4;
	col[jac_ind++] = col_ind + 2;
	row[jac_ind] = 6;
	col[jac_ind++] = col_ind + 2;

	//dF/dx_3
	row[jac_ind] = 7;
	col[jac_ind++] = col_ind + 3;

	col_ind += N_x;

	// Jacobian for inputs
	//dF/du_2
	row[jac_ind] = 1;
	col[jac_ind++] = col_ind + 1;
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;

	col_ind += N_u;

	// Jacobian for algebraics
	row[jac_ind] = 4;
	col[jac_ind++] = col_ind + 1;
	col_ind += N_w;

	// Jacobian for time
	row[jac_ind] = 3;
	col[jac_ind++] = col_ind + 1;

	return 0;
}


static int vdp_init_F1(jmi_t* jmi, jmi_ad_var_vec_p res) {

  return 0;
}

static int vdp_init_dF1(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	return 0;
}

static int vdp_init_dF1_n_nz(int* n_nz) {

	*n_nz = 0;
	return 0;
}

static int vdp_init_dF1_nz_indices(int* row, int* col) {

	return 0;
}

static int vdp_init_Fp(jmi_t* jmi, jmi_ad_var_vec_p res) {

  return 0;
}

static int vdp_init_dFp(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	return 0;
}

static int vdp_init_dFp_n_nz(int* n_nz) {
	*n_nz = 0;
	return 0;
}

static int vdp_init_dFp_nz_indices(int* row, int* col) {

	return 0;
}

static int vdp_opt_J(jmi_t* jmi, jmi_ad_var_vec_p res) {

	 //min x_3(t_f) + x_3(t_1) + p_1^2 + w_1(t_f)^2 + w_1(t_1)^2

	(*res)[0] = _x_p(0,2) + _pi(1)*_x_p(1,2) + _pi(0)*_pi(0) + _w_p(0,0)*_w_p(0,0) + _pi(1)*_w_p(1,0)*_w_p(1,0);
  return 0;
}

static int vdp_opt_dJ(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {


	jmi_real_t* ci = jmi_get_ci(jmi);
	jmi_real_t* cd = jmi_get_cd(jmi);
	jmi_real_t* pi = jmi_get_pi(jmi);
	jmi_real_t* pd = jmi_get_pd(jmi);
	jmi_real_t* dx_p_1 = jmi_get_dx_p(jmi,0);
	jmi_real_t* x_p_1 = jmi_get_x_p(jmi,0);
	jmi_real_t* u_p_1 = jmi_get_u_p(jmi,0);
	jmi_real_t* w_p_1 = jmi_get_w_p(jmi,0);
	jmi_real_t* dx_p_2 = jmi_get_dx_p(jmi,1);
	jmi_real_t* x_p_2 = jmi_get_x_p(jmi,1);
	jmi_real_t* u_p_2 = jmi_get_u_p(jmi,1);
	jmi_real_t* w_p_2 = jmi_get_w_p(jmi,1);


	int i;
	int jac_n = 1;
	int col_index = 0;
	int jac_col_index = 0;
	int mask_col_index = 0;

	int jac_m;
	int jac_n_nz;
	jmi_opt_dJ_dim(jmi,JMI_DER_SYMBOLIC,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	int jac_index = 0;
	mask_col_index = 0;
	if ((independent_vars & JMI_DER_PI)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = 2*pi[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = x_p_2[2] + w_p_2[0]*w_p_2[0];
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}

	} else {
		mask_col_index += jmi->n_pi;
	}

	if ((independent_vars & JMI_DER_DX)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_dx;
	}

	if ((independent_vars & JMI_DER_X)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_x;
	}

	if ((independent_vars & JMI_DER_U)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_u;
	}

	if ((independent_vars & JMI_DER_W)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_w;
	}

	if ((independent_vars & JMI_DER_T)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += 1;
	}

	for (i=0;i<N_t_p;i++) {

		if ((independent_vars & JMI_DER_DX_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_dx;
		}


		if ((independent_vars & JMI_DER_X_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jmi_real_t jac_tmp_1;
				switch (i) {
				case 0:
					jac_tmp_1 = 1;
					break;
				case 1:
					jac_tmp_1 = pi[1];
				}
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					jac[jac_n*jac_col_index + 0] = jac_tmp_1;
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					jac[jac_m*0 + jac_col_index] = jac_tmp_1;
					break;
				case JMI_DER_SPARSE:
					jac[jac_index] = jac_tmp_1;
					jac_index++;
				}
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_x;
		}


		if ((independent_vars & JMI_DER_U_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_u;
		}

		if ((independent_vars & JMI_DER_W_P)) {
			if (mask[mask_col_index++] == 1) {
				jmi_real_t jac_tmp_1;
				switch (i) {
				case 0:
					jac_tmp_1 = 2*w_p_1[0];
					break;
				case 1:
					jac_tmp_1 = pi[1]*2*w_p_2[0];
				}
				switch (sparsity) {
				case JMI_DER_DENSE_COL_MAJOR:
					jac[jac_n*jac_col_index + 0] = jac_tmp_1;
					break;
				case JMI_DER_DENSE_ROW_MAJOR:
					jac[jac_m*0 + jac_col_index] = jac_tmp_1;
					break;
				case JMI_DER_SPARSE:
					jac[jac_index] = jac_tmp_1;
					jac_index++;
				}
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_w;
		}
	}


	return 0;
}

static int vdp_opt_dJ_n_nz(int* n_nz) {

	*n_nz = 6;
	return 0;
}

static int vdp_opt_dJ_nz_indices(int* row, int* col) {
	row[0] = 1;
	col[0] = 1;

	row[1] = 1;
	col[1] = 2;

	row[2] = 1;
	col[2] = 18;

	row[3] = 1;
	col[3] = 20;

	row[4] = 1;
	col[4] = 26;

	row[5] = 1;
	col[5] = 28;

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
	(*res)[0] = -_x(0) - 0.5;  // x_1 >= -0.25
	(*res)[1] = -_u(0) - 0.5;   // u_1 >= -0.1
	(*res)[2] = _u(0) - 1;       // u_1 <= 0.75
  return 0;
}

static int vdp_opt_dCineq(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	jmi_real_t* ci = jmi_get_ci(jmi);
	jmi_real_t* cd = jmi_get_cd(jmi);
	jmi_real_t* pi = jmi_get_pi(jmi);
	jmi_real_t* pd = jmi_get_pd(jmi);
	jmi_real_t* dx_p_1 = jmi_get_dx_p(jmi,0);
	jmi_real_t* x_p_1 = jmi_get_x_p(jmi,0);
	jmi_real_t* u_p_1 = jmi_get_u_p(jmi,0);
	jmi_real_t* w_p_1 = jmi_get_w_p(jmi,0);
	jmi_real_t* dx_p_2 = jmi_get_dx_p(jmi,1);
	jmi_real_t* x_p_2 = jmi_get_x_p(jmi,1);
	jmi_real_t* u_p_2 = jmi_get_u_p(jmi,1);
	jmi_real_t* w_p_2 = jmi_get_w_p(jmi,1);

	int i;
	int jac_n = N_eq_Cineq;
	int col_index = 0;
	int jac_col_index = 0;
	int mask_col_index = 0;

	int jac_m;
	int jac_n_nz;
	jmi_opt_dCineq_dim(jmi,JMI_DER_SYMBOLIC,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	int jac_index = 0;
	mask_col_index = 0;
	if ((independent_vars & JMI_DER_PI)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}

	} else {
		mask_col_index += jmi->n_pi;
	}

	if ((independent_vars & JMI_DER_DX)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_dx;
	}

	if ((independent_vars & JMI_DER_X)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 0] = jac_tmp_1;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*0 + jac_col_index] = jac_tmp_1;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index] = jac_tmp_1;
				jac_index++;
			}
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_x;
	}

	if ((independent_vars & JMI_DER_U)) {
		if (mask[mask_col_index++] == 1) {
			jmi_real_t jac_tmp_1 = -1;
			jmi_real_t jac_tmp_2 = 1;
			switch (sparsity) {
			case JMI_DER_DENSE_COL_MAJOR:
				jac[jac_n*jac_col_index + 1] = jac_tmp_1;
				jac[jac_n*jac_col_index + 2] = jac_tmp_2;
				break;
			case JMI_DER_DENSE_ROW_MAJOR:
				jac[jac_m*1 + jac_col_index] = jac_tmp_1;
				jac[jac_m*2 + jac_col_index] = jac_tmp_2;
				break;
			case JMI_DER_SPARSE:
				jac[jac_index++] = jac_tmp_1;
				jac[jac_index++] = jac_tmp_2;
			}

			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_u;
	}

	if ((independent_vars & JMI_DER_W)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_w;
	}

	if ((independent_vars & JMI_DER_T)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += 1;
	}

	for (i=0;i<N_t_p;i++) {

		if ((independent_vars & JMI_DER_DX_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_dx;
		}


		if ((independent_vars & JMI_DER_X_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_x;
		}


		if ((independent_vars & JMI_DER_U_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_u;
		}

		if ((independent_vars & JMI_DER_W_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_w;
		}
	}

	return 0;
}

static int vdp_opt_dCineq_n_nz(int* n_nz) {

	*n_nz = 3;
	return 0;
}

static int vdp_opt_dCineq_nz_indices(int* row, int* col) {
	row[0] = 1;
	col[0] = 7;

	row[1] = 2;
	col[1] = 10;

	row[2] = 3;
	col[2] = 10;

	return -1;
}
static int vdp_opt_Heq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	(*res)[0] = _x_p(0,0);  // x_1(t_f) = 0
	(*res)[1] = _x_p(0,1);  // x_2(t_f) = 0
  return 0;
}

static int vdp_opt_dHeq(jmi_t* jmi, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

	jmi_real_t* ci = jmi_get_ci(jmi);
	jmi_real_t* cd = jmi_get_cd(jmi);
	jmi_real_t* pi = jmi_get_pi(jmi);
	jmi_real_t* pd = jmi_get_pd(jmi);
	jmi_real_t* dx_p_1 = jmi_get_dx_p(jmi,0);
	jmi_real_t* x_p_1 = jmi_get_x_p(jmi,0);
	jmi_real_t* u_p_1 = jmi_get_u_p(jmi,0);
	jmi_real_t* w_p_1 = jmi_get_w_p(jmi,0);
	jmi_real_t* dx_p_2 = jmi_get_dx_p(jmi,1);
	jmi_real_t* x_p_2 = jmi_get_x_p(jmi,1);
	jmi_real_t* u_p_2 = jmi_get_u_p(jmi,1);
	jmi_real_t* w_p_2 = jmi_get_w_p(jmi,1);


	int i;
	int jac_n = N_eq_Heq;
	int col_index = 0;
	int jac_col_index = 0;
	int mask_col_index = 0;

	int jac_m;
	int jac_n_nz;
	jmi_opt_dHeq_dim(jmi,JMI_DER_SYMBOLIC,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

	// Set Jacobian to zero if dense evaluation.
	if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
		for (i=0;i<jac_n*jac_m;i++) {
			jac[i] = 0;
		}
	}

	int jac_index = 0;
	mask_col_index = 0;
	if ((independent_vars & JMI_DER_PI)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}

	} else {
		mask_col_index += jmi->n_pi;
	}

	if ((independent_vars & JMI_DER_DX)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_dx;
	}

	if ((independent_vars & JMI_DER_X)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_x;
	}

	if ((independent_vars & JMI_DER_U)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_u;
	}

	if ((independent_vars & JMI_DER_W)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += jmi->n_w;
	}

	if ((independent_vars & JMI_DER_T)) {
		if (mask[mask_col_index++] == 1) {
			jac_col_index++;
		}
	} else {
		mask_col_index += 1;
	}

	for (i=0;i<N_t_p;i++) {

		if ((independent_vars & JMI_DER_DX_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_dx;
		}


		if ((independent_vars & JMI_DER_X_P)) {
			if (mask[mask_col_index++] == 1) {
				if (i==0) {
					jmi_real_t jac_tmp_1 = 1;
					switch (sparsity) {
					case JMI_DER_DENSE_COL_MAJOR:
						jac[jac_n*jac_col_index + 0] = jac_tmp_1;
						break;
					case JMI_DER_DENSE_ROW_MAJOR:
						jac[jac_m*0 + jac_col_index] = jac_tmp_1;
						break;
					case JMI_DER_SPARSE:
					jac[jac_index++] = jac_tmp_1;
					}
				}
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jmi_real_t jac_tmp_1 = 1;
				if (i==0) {
					switch (sparsity) {
					case JMI_DER_DENSE_COL_MAJOR:
						jac[jac_n*jac_col_index + 1] = jac_tmp_1;
						break;
					case JMI_DER_DENSE_ROW_MAJOR:
						jac[jac_m*1 + jac_col_index] = jac_tmp_1;
						break;
					case JMI_DER_SPARSE:
					jac[jac_index++] = jac_tmp_1;
					}
				}
				jac_col_index++;
			}
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_x;
		}


		if ((independent_vars & JMI_DER_U_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_u;
		}

		if ((independent_vars & JMI_DER_W_P)) {
			if (mask[mask_col_index++] == 1) {
				jac_col_index++;
			}
		} else {
			mask_col_index += jmi->n_w;
		}
	}

	return 0;
}

static int vdp_opt_dHeq_n_nz(int* n_nz) {

	*n_nz = 2;
	return 0;
}

static int vdp_opt_dHeq_nz_indices(int* row, int* col) {

	row[0] = 1;
	col[0] = 16;

	row[1] = 2;
	col[1] = 17;

	return 0;
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

	/*
	printf("** %d, %d, %d\n",dF_n_nz,dF0_n_nz,dF1_n_nz);
	int i;
	for (i=0;i<dF0_n_nz;i++) {
		printf("%d %d\n",dF0_irow[i],dF0_icol[i]);
	}
*/

	jmi_init_init(*jmi, *vdp_init_F0, N_eq_F0, *vdp_init_dF0,
			          dF0_n_nz, dF0_irow, dF0_icol,
			            *vdp_init_F1, N_eq_F1, *vdp_init_dF1,
			            dF1_n_nz, dF1_irow, dF1_icol,*vdp_init_Fp, N_eq_Fp, NULL,
			            0, NULL, NULL);

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
