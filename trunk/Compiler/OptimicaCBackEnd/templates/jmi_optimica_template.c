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
#include "fmiModelFunctions.h"
#include <jmi.h>
#include "fmi1_me.h"
#include "jmi_log.h"
#include "ModelicaUtilities.h"
#include "ModelicaStandardTables.h"

#define MODEL_IDENTIFIER $C_model_id$
#define C_GUID $C_guid$

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

static const int N_time_sw = $n_time_switches$;
static const int N_state_sw = $n_state_switches$;
static const int N_sw = $n_time_switches$ + $n_state_switches$;
static const int N_eq_F = $n_equations$;
static const int N_eq_R = $n_event_indicators$;
static const int N_guards = $n_guards$;

static const int N_eq_F0 = $n_equations$ + $n_initial_equations$;
static const int N_eq_F1 = $n_initial_guess_equations$;
static const int N_eq_Fp = 0;
static const int N_eq_R0 = $n_event_indicators$ + $n_initial_event_indicators$;
static const int N_sw_init = $n_initial_switches$;
static const int N_guards_init = $n_guards_init$;

static const int N_dae_blocks = $n_dae_blocks$;
static const int N_dae_init_blocks = $n_dae_init_blocks$;

static const int N_eq_J = $n_j$;
static const int N_eq_L = $n_l$;
static const int N_eq_opt_Ffdp = $n_free_dependent_real_parameters$;
static const int N_eq_Ceq = $n_ceq$;
static const int N_eq_Cineq = $n_cineq$;
static const int N_eq_Heq = $n_heq$;
static const int N_eq_Hineq = $n_hineq$;
static const int N_t_p = $n_tp$;

static const int Scaling_method = $C_DAE_scaling_method$;

#define sf(i) (jmi->variable_scaling_factors[i])

static const int N_outputs = $n_outputs$;
$C_DAE_output_vrefs$

$C_DAE_equation_sparsity$

$C_DAE_ODE_jacobian_sparsity$

$C_DAE_initial_relations$

$C_DAE_relations$

$C_variable_aliases$

$C_point_variable_aliases$

const char *fmi_runtime_options_map_names[] = { NULL };
const int fmi_runtime_options_map_vrefs[] = { -1 };
const int fmi_runtime_options_map_length = 1;

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

$C_functions$

static int model_ode_guards(jmi_t* jmi) {
  $C_ode_guards$
  return 0;
}

static int model_ode_next_time_event(jmi_t* jmi, jmi_time_event_t* event) {
$C_ode_time_events$
  return 0;
}

static int model_ode_derivatives(jmi_t* jmi) {
  $C_ode_derivatives$
  return 0;
}

static int model_ode_derivatives_dir_der(jmi_t* jmi) {
  $CAD_ode_derivatives$
  return 0;
}

static int model_ode_outputs(jmi_t* jmi) {
  $C_ode_outputs$
  return 0;
}

static int model_ode_guards_init(jmi_t* jmi) {
  $C_ode_guards_init$
  return 0;
}

static int model_ode_initialize(jmi_t* jmi) {
  $C_ode_initialization$
  return 0;
}

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

static int model_dae_dir_dF(jmi_t* jmi, jmi_ad_var_vec_p res, jmi_ad_var_vec_p dF, jmi_ad_var_vec_p dz) {
$C_DAE_equation_directional_derivative$
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
  /* C_DAE_initial_dependent_parameter_residuals */
	return -1;
}

$C_DAE_initial_dependent_parameter_assignments$

static int model_init_eval_parameters(jmi_t* jmi) {
    model_init_eval_parameters_base(jmi);
    return 0;
}

static int model_init_R0(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_DAE_initial_event_indicator_residuals$
	return 0;
}

static int model_opt_Ffdp(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_Opt_dependent_free_parameter_residuals$
	return 0;
}

static int model_opt_J(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_Opt_cost_function$
	return 0;
}

static int model_opt_L(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_Opt_lagrange_integrand$
	return 0;
}

static int model_opt_Ceq(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_Opt_path_equality_constraints$
	return 0;
}

static int model_opt_Cineq(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_Opt_path_inequality_constraints$
	return 0;
}

static int model_opt_Heq(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_Opt_point_equality_constraints$
	return 0;
}

static int model_opt_Hineq(jmi_t* jmi, jmi_ad_var_vec_p res) {
$C_Opt_point_inequality_constraints$
	return 0;
}

int jmi_new(jmi_t** jmi) {


	  jmi_init(jmi, N_real_ci, N_real_cd, N_real_pi, N_real_pd,
		   N_integer_ci, N_integer_cd, N_integer_pi, N_integer_pd,
		   N_boolean_ci, N_boolean_cd, N_boolean_pi, N_boolean_pd,
		   N_string_ci, N_string_cd, N_string_pi, N_string_pd,
		   N_real_dx,N_real_x, N_real_u, N_real_w,N_t_p,
		   N_real_d,N_integer_d,N_integer_u,N_boolean_d,N_boolean_u,
		   N_string_d,N_string_u, N_outputs,(int (*))Output_vrefs,
	           N_sw,N_sw_init,N_time_sw,N_state_sw, N_guards,N_guards_init,
		   N_dae_blocks,N_dae_init_blocks,
		   N_initial_relations, (int (*))DAE_initial_relations,
		   N_relations, (int (*))DAE_relations,
		   Scaling_method, -1);

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
                     *model_ode_outputs,*model_ode_initialize,*model_ode_guards,*model_ode_guards_init,
                     *model_ode_next_time_event);

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

	/* Initialize the Opt interface */
	jmi_opt_init(*jmi, *model_opt_Ffdp, N_eq_opt_Ffdp, NULL, 0, NULL, NULL,
		     *model_opt_J, N_eq_J, NULL, 0, NULL, NULL,
		     *model_opt_L, N_eq_L, NULL, 0, NULL, NULL,
		     *model_opt_Ceq, N_eq_Ceq, NULL, 0, NULL, NULL,
		     *model_opt_Cineq, N_eq_Cineq, NULL, 0, NULL, NULL,
		     *model_opt_Heq, N_eq_Heq, NULL, 0, NULL, NULL,
		     *model_opt_Hineq, N_eq_Hineq, NULL, 0, NULL, NULL);

	return 0;
}

int jmi_destruct_external_objs(jmi_t* jmi) {
	return 0;
}

$C_set_start_values$

int jmi_set_start_values(jmi_t* jmi) {
    jmi_set_start_values_base(jmi);
    jmi_copy_z_to_zval(jmi);
    return 0;
}

const char *jmi_get_model_identifier() { return "$C_model_id$"; }

#ifdef __cplusplus
extern "C" {
#endif
/* FMI Functions*/

/* Inquire version numbers of header files */
DllExport const char* fmiGetModelTypesPlatform() {
    return fmi1_me_get_model_types_platform();
}
DllExport const char* fmiGetVersion() {
    return fmi1_me_get_version();
}

/* Creation and destruction of model instances and setting debug status */
DllExport fmiComponent fmiInstantiateModel(fmiString instanceName, fmiString GUID, fmiCallbackFunctions functions, fmiBoolean loggingOn) {
    return fmi1_me_instantiate_model(instanceName, GUID, functions, loggingOn);
}

DllExport void fmiFreeModelInstance(fmiComponent c) {
    fmi1_me_free_model_instance(c);
}

DllExport fmiStatus fmiSetDebugLogging(fmiComponent c, fmiBoolean loggingOn) {
    return fmi1_me_set_debug_logging(c, loggingOn);
}


/* Providing independent variables and re-initialization of caching */
DllExport fmiStatus fmiSetTime(fmiComponent c, fmiReal fmitime) {
    return fmi1_me_set_time(c, fmitime);
}

DllExport fmiStatus fmiSetContinuousStates(fmiComponent c, const fmiReal x[], size_t nx) {
    return fmi1_me_set_continuous_states(c, x, nx);
}

DllExport fmiStatus fmiCompletedIntegratorStep(fmiComponent c, fmiBoolean* callEventUpdate) {
    return fmi1_me_completed_integrator_step(c, callEventUpdate);
}

DllExport fmiStatus fmiSetReal(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal value[]) {
    return fmi1_me_set_real(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetInteger(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]) {
    return fmi1_me_set_integer(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetBoolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]) {
    return fmi1_me_set_boolean(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetString(fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString  value[]) {
    return fmi1_me_set_string(c, vr, nvr, value);
}


/* Evaluation of the model equations */
DllExport fmiStatus fmiInitialize(fmiComponent c, fmiBoolean toleranceControlled, fmiReal relativeTolerance, fmiEventInfo* eventInfo) {
    return fmi1_me_initialize(c, toleranceControlled, relativeTolerance, eventInfo);
}

DllExport fmiStatus fmiGetDerivatives(fmiComponent c, fmiReal derivatives[] , size_t nx) {
    return fmi1_me_get_derivatives(c, derivatives, nx);
}

DllExport fmiStatus fmiGetEventIndicators(fmiComponent c, fmiReal eventIndicators[], size_t ni) {
    return fmi1_me_get_event_indicators(c, eventIndicators, ni);
}

DllExport fmiStatus fmiGetReal(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal value[]) {
    return fmi1_me_get_real(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetInteger(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]) {
    return fmi1_me_get_integer(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetBoolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]) {
    return fmi1_me_get_boolean(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetString(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]) {
    return fmi1_me_get_string(c, vr, nvr, value);
}

DllExport jmi_t* fmiGetJMI(fmiComponent c) {
    return fmi1_me_get_jmi_t(c);
}

DllExport fmiStatus fmiEventUpdate(fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {
    return fmi1_me_event_update(c, intermediateResults, eventInfo);
}

DllExport fmiStatus fmiGetContinuousStates(fmiComponent c, fmiReal states[], size_t nx) {
    return fmi1_me_get_continuous_states(c, states, nx);
}

DllExport fmiStatus fmiGetNominalContinuousStates(fmiComponent c, fmiReal x_nominal[], size_t nx) {
    return fmi1_me_get_nominal_continuous_states(c, x_nominal, nx);
}

DllExport fmiStatus fmiGetStateValueReferences(fmiComponent c, fmiValueReference vrx[], size_t nx) {
    return fmi1_me_get_state_value_references(c, vrx, nx);
}

DllExport fmiStatus fmiTerminate(fmiComponent c) {
    return fmi1_me_terminate(c);
}

#ifdef __cplusplus
}
#endif
