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

$external_func_includes$

const char *C_GUID = $C_guid$;

static int model_ode_guards_init(jmi_t* jmi);
static int model_init_R0(jmi_t* jmi, jmi_real_t** res);
static int model_ode_initialize(jmi_t* jmi);

static const int N_real_ci = $n_real_ci$;
static const int N_real_cd = $n_real_cd$;
static const int N_real_pi = $n_real_pi$;
static const int N_real_pd = $n_real_pd$;

static const int N_integer_ci = $n_integer_ci$ + $n_enum_ci$;
static const int N_integer_cd = $n_integer_cd$ + $n_enum_cd$;
static const int N_integer_pi = $n_integer_pi$ + $n_enum_pi$;
static const int N_integer_pd = $n_integer_pd$ + $n_enum_pd$;

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

static const int N_integer_d = $n_integer_d$ + $n_enum_d$;
static const int N_integer_u = $n_integer_u$ + $n_enum_u$;

static const int N_boolean_d = $n_boolean_d$;
static const int N_boolean_u = $n_boolean_u$;

static const int N_string_d = $n_string_d$;
static const int N_string_u = $n_string_u$;

static const int N_ext_objs = $n_ext_objs$;

static const int N_sw = $n_switches$;
static const int N_eq_F = $n_equations$;
static const int N_eq_R = $n_event_indicators$;

static const int N_dae_blocks = $n_dae_blocks$;
static const int N_dae_init_blocks = $n_dae_init_blocks$;
static const int N_guards = $n_guards$;

static const int N_eq_F0 = $n_equations$ + $n_initial_equations$;
static const int N_eq_F1 = $n_initial_guess_equations$;
static const int N_eq_Fp = 0;
static const int N_eq_R0 = $n_event_indicators$ + $n_initial_event_indicators$;
static const int N_sw_init = $n_initial_switches$;
static const int N_guards_init = $n_guards_init$;

static const int Scaling_method = $C_DAE_scaling_method$;

#define sf(i) (jmi->variable_scaling_factors[i])

static const int N_outputs = $n_outputs$;
$C_DAE_output_vrefs$

$C_DAE_equation_sparsity$

$C_DAE_ODE_jacobian_sparsity$

$C_DAE_initial_relations$

$C_DAE_relations$

$C_variable_aliases$

$C_runtime_option_map$

#define _real_ci(i) ((*(jmi->z))[jmi->offs_real_ci+i])
#define _real_cd(i) ((*(jmi->z))[jmi->offs_real_cd+i])
#define _real_pi(i) ((*(jmi->z))[jmi->offs_real_pi+i])
#define _real_pd(i) ((*(jmi->z))[jmi->offs_real_pd+i])
#define _real_dx(i) ((*(jmi->z))[jmi->offs_real_dx+i])
#define _real_x(i) ((*(jmi->z))[jmi->offs_real_x+i])
#define _real_u(i) ((*(jmi->z))[jmi->offs_real_u+i])
#define _real_w(i) ((*(jmi->z))[jmi->offs_real_w+i])
#define _t ((*(jmi->z))[jmi->offs_t])

#define _real_d(i) ((*(jmi->z))[jmi->offs_real_d+i])
#define _integer_d(i) ((*(jmi->z))[jmi->offs_integer_d+i])
#define _integer_u(i) ((*(jmi->z))[jmi->offs_integer_u+i])
#define _boolean_d(i) ((*(jmi->z))[jmi->offs_boolean_d+i])
#define _boolean_u(i) ((*(jmi->z))[jmi->offs_boolean_u+i])

#define _pre_real_dx(i) ((*(jmi->z))[jmi->offs_pre_real_dx+i])
#define _pre_real_x(i) ((*(jmi->z))[jmi->offs_pre_real_x+i])
#define _pre_real_u(i) ((*(jmi->z))[jmi->offs_pre_real_u+i])
#define _pre_real_w(i) ((*(jmi->z))[jmi->offs_pre_real_w+i])

#define _pre_real_d(i) ((*(jmi->z))[jmi->offs_pre_real_d+i])
#define _pre_integer_d(i) ((*(jmi->z))[jmi->offs_pre_integer_d+i])
#define _pre_integer_u(i) ((*(jmi->z))[jmi->offs_pre_integer_u+i])
#define _pre_boolean_d(i) ((*(jmi->z))[jmi->offs_pre_boolean_d+i])
#define _pre_boolean_u(i) ((*(jmi->z))[jmi->offs_pre_boolean_u+i])

#define _sw(i) ((*(jmi->z))[jmi->offs_sw + i])
#define _sw_init(i) ((*(jmi->z))[jmi->offs_sw_init + i])
#define _pre_sw(i) ((*(jmi->z))[jmi->offs_pre_sw + i])
#define _pre_sw_init(i) ((*(jmi->z))[jmi->offs_pre_sw_init + i])
#define _guards(i) ((*(jmi->z))[jmi->offs_guards + i])
#define _guards_init(i) ((*(jmi->z))[jmi->offs_guards_init + i])
#define _pre_guards(i) ((*(jmi->z))[jmi->offs_pre_guards + i])
#define _pre_guards_init(i) ((*(jmi->z))[jmi->offs_pre_guards_init + i])

#define _atInitial (jmi->atInitial)

$C_records$

$C_enum_strings$

$C_function_headers$

$CAD_function_headers$

$C_dae_blocks_residual_functions$

$C_dae_init_blocks_residual_functions$

$CAD_dae_blocks_residual_functions$

$CAD_dae_init_blocks_residual_functions$

$C_functions$

$CAD_functions$

$C_export_functions$
$C_export_wrappers$

static int model_ode_guards(jmi_t* jmi) {
  $C_ode_guards$
  return 0;
}

static int model_ode_next_time_event(jmi_t* jmi, jmi_real_t* nextTime) {
$C_ode_time_events$
  return 0;
}

static int model_ode_derivatives(jmi_t* jmi) {
  int ef = 0;
  $C_ode_derivatives$
  return ef;
}

static int model_ode_derivatives_dir_der(jmi_t* jmi) {
  int ef = 0;
  $CAD_ode_derivatives$
  return ef;
}

static int model_ode_outputs(jmi_t* jmi) {
  int ef = 0;
  $C_ode_outputs$
  return ef;
}

static int model_ode_guards_init(jmi_t* jmi) {
  $C_ode_guards_init$
  return 0;
}

static int model_ode_initialize(jmi_t* jmi) {
  int ef = 0;
  $C_ode_initialization$
  return ef;
}


static int model_ode_initialize_dir_der(jmi_t* jmi) {
  int ef = 0;
  /* This function is not needed - no derivatives of the initialization system is exposed.*/
  return ef;
}

static int model_dae_F(jmi_t* jmi, jmi_real_t** res) {
$C_DAE_equation_residuals$
	return 0;
}

static int model_dae_dir_dF(jmi_t* jmi, jmi_real_t** res, jmi_real_t** dF, jmi_real_t** dz) {
$C_DAE_equation_directional_derivative$
	return 0;
}

static int model_dae_R(jmi_t* jmi, jmi_real_t** res) {
$C_DAE_event_indicator_residuals$
	return 0;
}

static int model_init_F0(jmi_t* jmi, jmi_real_t** res) {
$C_DAE_initial_equation_residuals$
	return 0;
}

static int model_init_F1(jmi_t* jmi, jmi_real_t** res) {
$C_DAE_initial_guess_equation_residuals$
	return 0;
}

static int model_init_Fp(jmi_t* jmi, jmi_real_t** res) {
  /* C_DAE_initial_dependent_parameter_residuals */
	return -1;
}

static int model_init_eval_parameters(jmi_t* jmi) {
$C_DAE_initial_dependent_parameter_assignments$
        return 0;
}

static int model_init_R0(jmi_t* jmi, jmi_real_t** res) {
$C_DAE_initial_event_indicator_residuals$
	return 0;
}

int jmi_new(jmi_t** jmi, jmi_callbacks_t* jmi_callbacks) {

  jmi_init(jmi, N_real_ci, N_real_cd, N_real_pi, N_real_pd,
	   N_integer_ci, N_integer_cd, N_integer_pi, N_integer_pd,
	   N_boolean_ci, N_boolean_cd, N_boolean_pi, N_boolean_pd,
	   N_string_ci, N_string_cd, N_string_pi, N_string_pd,
	   N_real_dx,N_real_x, N_real_u, N_real_w,
	   N_real_d,N_integer_d,N_integer_u,N_boolean_d,N_boolean_u,
	   N_string_d,N_string_u, N_outputs,(int (*))Output_vrefs,
           N_sw,N_sw_init,N_guards,N_guards_init,
	   N_dae_blocks,N_dae_init_blocks,
	   N_initial_relations, (int (*))DAE_initial_relations,
	   N_relations, (int (*))DAE_relations,
	   Scaling_method, N_ext_objs, jmi_callbacks);

  $C_dae_add_blocks_residual_functions$

  $C_dae_init_add_blocks_residual_functions$

  $CAD_dae_add_blocks_residual_functions$

  $CAD_dae_init_add_blocks_residual_functions$

	/* Initialize the DAE interface */
	jmi_dae_init(*jmi, *model_dae_F, N_eq_F, NULL, 0, NULL, NULL,
                     *model_dae_dir_dF,
        		     CAD_dae_n_nz,(int (*))CAD_dae_nz_rows,(int (*))CAD_dae_nz_cols,
        		     CAD_ODE_A_n_nz, (int (*))CAD_ODE_A_nz_rows, (int(*))CAD_ODE_A_nz_cols,
        		     CAD_ODE_B_n_nz, (int (*))CAD_ODE_B_nz_rows, (int(*))CAD_ODE_B_nz_cols,
        		     CAD_ODE_C_n_nz, (int (*))CAD_ODE_C_nz_rows, (int(*))CAD_ODE_C_nz_cols,
        		     CAD_ODE_D_n_nz, (int (*))CAD_ODE_D_nz_rows, (int(*))CAD_ODE_D_nz_cols,
		     *model_dae_R, N_eq_R, NULL, 0, NULL, NULL,*model_ode_derivatives,
		     	 *model_ode_derivatives_dir_der,
                     *model_ode_outputs,*model_ode_initialize,*model_ode_guards,
                     *model_ode_guards_init,*model_ode_next_time_event);

	/* Initialize the Init interface */
	jmi_init_init(*jmi, *model_init_F0, N_eq_F0, NULL,
		      0, NULL, NULL,
		      *model_init_F1, N_eq_F1, NULL,
		      0, NULL, NULL,
		      *model_init_Fp, N_eq_Fp, NULL,
		      0, NULL, NULL,
		      *model_init_eval_parameters,
		      *model_init_R0, N_eq_R0, NULL,
		      0, NULL, NULL);

	return 0;
}

int jmi_terminate(jmi_t* jmi) {
$C_destruct_external_object$
	return 0;
}

int jmi_set_start_values(jmi_t* jmi) {
$C_set_start_values$
    return 0;
}

const char *jmi_get_model_identifier() { return "$C_model_id$"; }
