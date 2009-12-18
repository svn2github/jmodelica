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


static const int N_ci = $n_real_ci$;
static const int N_cd = $n_real_cd$;
static const int N_pi = $n_real_pi$;
static const int N_pd = $n_real_pd$;
static const int N_dx = $n_real_x$;
static const int N_x = $n_real_x$;
static const int N_u = $n_real_u$;
static const int N_w = $n_real_w$;
static const int N_sw = $n_switches$;
static const int N_eq_F = $n_equations$;
static const int N_eq_R = $n_event_indicators$;

static const int N_eq_F0 = $n_equations$ + $n_initial_equations$;
static const int N_eq_F1 = $n_initial_guess_equations$;
static const int N_eq_Fp = $n_real_pd$;
static const int N_eq_R0 = $n_event_indicators$ + $n_initial_event_indicators$;
static const int N_sw_init = $n_switches$ + $n_initial_switches$;

static const int N_eq_Ceq = 0;
static const int N_eq_Cineq = 0;
static const int N_eq_Heq = 0;
static const int N_eq_Hineq = 0;
static const int N_t_p = 0;

$C_variable_aliases$

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
#define _sw(i) ((*(jmi->z))[jmi->offs_sw + i])
#define _sw_init(i) ((*(jmi->z))[jmi->offs_sw_init + i])


$C_function_headers$

$C_functions$

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
static int model_dae_F(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_DAE_equation_residuals$
	return 0;
}

static int model_dae_R(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_DAE_event_indicator_residuals$
	return 0;
}

static int model_init_F0(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_DAE_initial_equation_residuals$
	return 0;
}

static int model_init_F1(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_DAE_initial_guess_equation_residuals$
	return 0;
}

static int model_init_Fp(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_DAE_initial_dependent_parameter_residuals$
	return 0;
}

static int model_init_R0(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_DAE_initial_event_indicator_residuals$
	return 0;
}

static int model_opt_J(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int model_opt_Ceq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int model_opt_Cineq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int model_opt_Heq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int model_opt_Hineq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

int jmi_new(jmi_t** jmi) {

	jmi_init(jmi, N_ci, N_cd, N_pi, N_pd, N_dx,
		 N_x, N_u, N_w, N_t_p,N_sw,N_sw_init);

	// Initialize the DAE interface
	jmi_dae_init(*jmi, *model_dae_F, N_eq_F, NULL, 0, NULL, NULL,
		     *model_dae_R, N_eq_R, NULL, 0, NULL, NULL);

	// Initialize the Init interface
	jmi_init_init(*jmi, *model_init_F0, N_eq_F0, NULL,
		      0, NULL, NULL,
		      *model_init_F1, N_eq_F1, NULL,
		      0, NULL, NULL,
		      *model_init_Fp, N_eq_Fp, NULL,
		      0, NULL, NULL,
		      *model_init_R0, N_eq_R0, NULL,
		      0, NULL, NULL);

	// Initialize the Opt interface
	jmi_opt_init(*jmi, *model_opt_J, NULL, 0, NULL, NULL,
	           *model_opt_Ceq, N_eq_Ceq, NULL, 0, NULL, NULL,
	           *model_opt_Cineq, N_eq_Cineq, NULL, 0, NULL, NULL,
	           *model_opt_Heq, N_eq_Heq, NULL, 0, NULL, NULL,
	           *model_opt_Hineq, N_eq_Hineq, NULL, 0, NULL, NULL);

	return 0;
}
