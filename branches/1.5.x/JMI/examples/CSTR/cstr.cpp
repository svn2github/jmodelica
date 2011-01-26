/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <jmi.h>

static const int N_ci = 0;
static const int N_cd = 0;
static const int N_pi = 17;
static const int N_pd = 0;
static const int N_dx = 3;
static const int N_x = 3;
static const int N_u = 1;
static const int N_w = 0;
static const int N_eq_F = 3;

static const int N_eq_F0 = 3 + 3;
static const int N_eq_F1 = 0;
static const int N_eq_Fp = 0;

static const int N_eq_Ceq = 0;
static const int N_eq_Cineq = 2;
static const int N_eq_Heq = 0;
static const int N_eq_Hineq = 0;
static const int N_t_p = 1;

#define F0 ((*(jmi->z))[jmi->offs_pi+0])
#define c0 ((*(jmi->z))[jmi->offs_pi+1])
#define F ((*(jmi->z))[jmi->offs_pi+2])
#define T0 ((*(jmi->z))[jmi->offs_pi+3])
#define r ((*(jmi->z))[jmi->offs_pi+4])
#define k0 ((*(jmi->z))[jmi->offs_pi+5])
#define EdivR ((*(jmi->z))[jmi->offs_pi+6])
#define U ((*(jmi->z))[jmi->offs_pi+7])
#define rho ((*(jmi->z))[jmi->offs_pi+8])
#define Cp ((*(jmi->z))[jmi->offs_pi+9])
#define dH ((*(jmi->z))[jmi->offs_pi+10])
#define V ((*(jmi->z))[jmi->offs_pi+11])
#define c_init ((*(jmi->z))[jmi->offs_pi+12])
#define T_init ((*(jmi->z))[jmi->offs_pi+13])
#define c_ref ((*(jmi->z))[jmi->offs_pi+14])
#define T_ref ((*(jmi->z))[jmi->offs_pi+15])
#define Tc_ref ((*(jmi->z))[jmi->offs_pi+16])
#define c ((*(jmi->z))[jmi->offs_x+0])
#define T ((*(jmi->z))[jmi->offs_x+1])
#define J ((*(jmi->z))[jmi->offs_x+2])
#define der_c ((*(jmi->z))[jmi->offs_dx+0])
#define der_T ((*(jmi->z))[jmi->offs_dx+1])
#define der_J ((*(jmi->z))[jmi->offs_dx+2])
#define Tc ((*(jmi->z))[jmi->offs_u+0])
#define time ((*(jmi->z))[jmi->offs_t])

#define _ci(i) ((*(jmi->z))[jmi->offs_ci+i])
#define _cd(i) ((*(jmi->z))[jmi->offs_cd+i])
#define _pi(i) ((*(jmi->z))[jmi->offs_pi+i])
#define _pd(i) ((*(jmi->z))[jmi->offs_pd+i])
#define _dx(i) ((*(jmi->z))[jmi->offs_dx+i])
#define _x(i) ((*(jmi->z))[jmi->offs_x+i])
#define _u(i) ((*(jmi->z))[jmi->offs_u+i])
#define _w(i) ((*(jmi->z))[jmi->offs_w+i])
#define _t ((*(jmi->z))[jmi->offs_t])
#define _dx_p(j,i) ((*(jmi->z))[jmi->offs_dx_p + \
  j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)+ i])
#define _x_p(j,i) ((*(jmi->z))[jmi->offs_x_p + \
  j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])
#define _u_p(j,i) ((*(jmi->z))[jmi->offs_u_p + \
  j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])
#define _w_p(j,i) ((*(jmi->z))[jmi->offs_w_p + \
  j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])

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
	(*res)[0] = ( ( F0 ) * ( c0 - ( c ) ) ) / ( V ) - ( ( ( k0 ) * ( c ) ) * ( exp((  - ( EdivR ) ) / ( T )) ) ) - (der_c);
    (*res)[1] = ( ( F0 ) * ( T0 - ( T ) ) ) / ( V ) - ( ( ( ( ( dH ) / ( ( rho ) * ( Cp ) ) ) * ( k0 ) ) * ( c ) ) * ( exp((  - ( EdivR ) ) / ( T )) ) ) + ( ( ( 2 ) * ( U ) ) / ( ( ( r ) * ( rho ) ) * ( Cp ) ) ) * ( Tc - ( T ) ) - (der_T);
    (*res)[2] = (c_ref-c)*(c_ref-c) + (T_ref-T)*(T_ref-T) + (Tc_ref-Tc)*(Tc_ref-Tc) - der_J;
    return 0;
}

static int vdp_init_F0(jmi_t* jmi, jmi_ad_var_vec_p res) {
    (*res)[0] = ( ( F0 ) * ( c0 - ( c ) ) ) / ( V ) - ( ( ( k0 ) * ( c ) ) * ( exp((  - ( EdivR ) ) / ( T )) ) ) - (der_c);
    (*res)[1] = ( ( F0 ) * ( T0 - ( T ) ) ) / ( V ) - ( ( ( ( ( dH ) / ( ( rho ) * ( Cp ) ) ) * ( k0 ) ) * ( c ) ) * ( exp((  - ( EdivR ) ) / ( T )) ) ) + ( ( ( 2 ) * ( U ) ) / ( ( ( r ) * ( rho ) ) * ( Cp ) ) ) * ( Tc - ( T ) ) - (der_T);
    (*res)[2] = (c_ref-c)*(c_ref-c) + (T_ref-T)*(T_ref-T) + (Tc_ref-Tc)*(Tc_ref-Tc) - der_J;
    (*res)[3] = c - c_init;
    (*res)[4] = T - T_init;
    (*res)[5] = J - 0;
	return 0;
}

static int vdp_init_F1(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int vdp_init_Fp(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}


static int vdp_opt_J(jmi_t* jmi, jmi_ad_var_vec_p res) {
	//printf("%f, %f, %f, %f\n",c,T,J,_x_p(0,2));
	(*res)[0] = _x_p(0,2);
	return 0;
}

static int vdp_opt_Ceq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int vdp_opt_Cineq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	(*res)[0] = Tc - 320;
	(*res)[1] = -Tc + 280;
	return 0;
}

static int vdp_opt_Heq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int vdp_opt_Hineq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

int jmi_new(jmi_t** jmi) {

	jmi_init(jmi, N_ci, N_cd, N_pi, N_pd, N_dx,
			      N_x, N_u, N_w, N_t_p);

	// Initialize the DAE interface
	jmi_dae_init(*jmi, *vdp_dae_F, N_eq_F, NULL, 0, NULL, NULL);

	// Initialize the Init interface
	jmi_init_init(*jmi, *vdp_init_F0, N_eq_F0, NULL,
			0, NULL, NULL, *vdp_init_F1, N_eq_F1, NULL,
            0, NULL, NULL,
            *vdp_init_Fp, N_eq_Fp, NULL,0, NULL, NULL);
	// Initialize the Opt interface
	jmi_opt_init(*jmi, *vdp_opt_J, NULL, 0, NULL, NULL,
	           *vdp_opt_Ceq, N_eq_Ceq, NULL, 0, NULL, NULL,
	           *vdp_opt_Cineq, N_eq_Cineq, NULL, 0, NULL, NULL,
	           *vdp_opt_Heq, N_eq_Heq, NULL, 0, NULL, NULL,
	           *vdp_opt_Hineq, N_eq_Hineq, NULL, 0, NULL, NULL);

	return 0;
}
