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
$external_func_includes$

static const int N_real_ci = $n_real_ci$;
static const int N_real_cd = $n_real_cd$;
static const int N_real_pi = $n_real_pi$;
static const int N_real_pd = $n_real_pd$;

static const int N_integer_ci = $n_integer_ci$;
static const int N_integer_cd = $n_integer_cd$;
static const int N_integer_pi = $n_integer_pi$;
static const int N_integer_pd = $n_integer_pd$;

static const int N_boolean_ci = $n_boolean_ci$;
static const int N_boolean_cd = $n_boolean_cd$;
static const int N_boolean_pi = $n_boolean_pi$;
static const int N_boolean_pd = $n_boolean_pd$;

static const int N_string_ci = $n_string_ci$;
static const int N_string_cd = $n_string_cd$;
static const int N_string_pi = $n_string_pi$;
static const int N_string_pd = $n_string_pd$;

static const int N_real_dx = $n_real_x$;
static const int N_real_x = $n_real_x$;
static const int N_real_u = $n_real_u$;
static const int N_real_w = $n_real_w$;

static const int N_real_d = $n_real_d$;

static const int N_integer_d = $n_integer_d$;
static const int N_integer_u = $n_integer_u$;

static const int N_boolean_d = $n_boolean_d$;
static const int N_boolean_u = $n_boolean_u$;

static const int N_string_d = $n_string_d$;
static const int N_string_u = $n_string_u$;

static const int N_sw = $n_switches$;
static const int N_eq_F = $n_equations$;
static const int N_eq_R = $n_event_indicators$;

static const int N_eq_F0 = $n_equations$ + $n_initial_equations$;
static const int N_eq_F1 = $n_initial_guess_equations$;
static const int N_eq_Fp = $n_real_pd$ + $n_integer_pd$;
static const int N_eq_R0 = $n_event_indicators$ + $n_initial_event_indicators$;
static const int N_sw_init = $n_switches$ + $n_initial_switches$;

static const int N_eq_J = 0;
static const int N_eq_L = 0;
static const int N_eq_opt_Ffdp = 0;
static const int N_eq_Ceq = 0;
static const int N_eq_Cineq = 0;
static const int N_eq_Heq = 0;
static const int N_eq_Hineq = 0;
static const int N_t_p = 0;

static const int Scaling_method = $C_DAE_scaling_method$;

#define sf(i) (jmi->variable_scaling_factors[i])

$C_variable_aliases$

#define _real_ci(i) ((*(jmi->z))[jmi->offs_real_ci+i])
#define _real_cd(i) ((*(jmi->z))[jmi->offs_real_cd+i])
#define _real_pi(i) ((*(jmi->z))[jmi->offs_real_pi+i])
#define _real_pd(i) ((*(jmi->z))[jmi->offs_real_pd+i])
#define _real_dx(i) ((*(jmi->z))[jmi->offs_real_dx+i])
#define _real_x(i) ((*(jmi->z))[jmi->offs_real_x+i])
#define _real_u(i) ((*(jmi->z))[jmi->offs_real_u+i])
#define _real_w(i) ((*(jmi->z))[jmi->offs_real_w+i])
#define _t ((*(jmi->z))[jmi->offs_t])
#define _real_dx_p(j,i) ((*(jmi->z))[jmi->offs_real_dx_p + \
  j*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)+ i])
#define _real_real_x_p(j,i) ((*(jmi->z))[jmi->offs_real_x_p + \
  j*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w) + i])
#define _real_u_p(j,i) ((*(jmi->z))[jmi->offs_real_u_p + \
  j*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w) + i])
#define _real_w_p(j,i) ((*(jmi->z))[jmi->offs_real_w_p + \
  j*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w) + i])
#define _sw(i) ((*(jmi->z))[jmi->offs_sw + i])
#define _sw_init(i) ((*(jmi->z))[jmi->offs_sw_init + i])


$C_records$

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

static int model_opt_Ffdp(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int model_opt_J(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int model_opt_L(jmi_t* jmi, jmi_ad_var_vec_p res) {
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

  jmi_init(jmi, N_real_ci, N_real_cd, N_real_pi, N_real_pd,
	   N_integer_ci, N_integer_cd, N_integer_pi, N_integer_pd,
	   N_boolean_ci, N_boolean_cd, N_boolean_pi, N_boolean_pd,
	   N_string_ci, N_string_cd, N_string_pi, N_string_pd,
	   N_real_dx,N_real_x, N_real_u, N_real_w,N_t_p,
	   N_real_d,N_integer_d,N_integer_u,N_boolean_d,N_boolean_u,
	   N_string_d,N_string_u,N_sw,N_sw_init,Scaling_method);

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
	jmi_opt_init(*jmi, *model_opt_Ffdp, N_eq_opt_Ffdp, NULL, 0, NULL, NULL,
		     *model_opt_J, N_eq_L, NULL, 0, NULL, NULL,
		     *model_opt_L, N_eq_L, NULL, 0, NULL, NULL,
		     *model_opt_Ceq, N_eq_Ceq, NULL, 0, NULL, NULL,
		     *model_opt_Cineq, N_eq_Cineq, NULL, 0, NULL, NULL,
		     *model_opt_Heq, N_eq_Heq, NULL, 0, NULL, NULL,
		     *model_opt_Hineq, N_eq_Hineq, NULL, 0, NULL, NULL);

	return 0;
}
