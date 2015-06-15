#include <stdlib.h>
#include <jmi_get_set.h>

#define NOT_USED(x) ((void)x)

typedef struct jmi_get_set_module_t jmi_get_set_module_t;

struct jmi_get_set_module_t {
	int dummy_placeholder;
};

#define GET_MODULE(j) ((j)->modules.mod_get_set)

#define RECOMPUTE_VARIABLES(j)     ((j)->recomputeVariables)
#define RECOMPUTE_VARIABLES_SET(j) (RECOMPUTE_VARIABLES(j) = 1)
#define RECOMPUTE_VARIABLES_CLR(j) (RECOMPUTE_VARIABLES(j) = 0)

int jmi_get_set_module_init(jmi_t *jmi) {
	jmi_get_set_module_t *module;
	int result = JMI_ERROR;

	if ((module = (jmi_get_set_module_t*)malloc(sizeof(*module))) == NULL) {
		goto error;
	}

    GET_MODULE(jmi) = (jmi_module_t*)module;

	result = JMI_OK;
error:
	return result;
}

void
jmi_get_set_module_destroy(jmi_t *jmi)
{
	if (jmi && GET_MODULE(jmi)) {
		free(GET_MODULE(jmi));

		GET_MODULE(jmi) = (jmi_module_t*)0;
	}
}

int jmi_set_real_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 const jmi_real_t value[]) {

    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    int needParameterUpdate = 0, needRecomputeVars = 0;

    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if(z[index] != value[i]) {
            /* Set value from the value array to z vector. */

            z[index] = value[i];
            needRecomputeVars = 1;
            if (index < jmi->offs_real_dx) {
                needParameterUpdate = 1;
            }
        }

    }
    if(needRecomputeVars) {
    	RECOMPUTE_VARIABLES_SET(jmi);
        /* jmi->recomputeVariables = 1; */

        if( needParameterUpdate ) {
          jmi_init_eval_parameters(jmi);
        }
    }

    return 0;
}

int jmi_set_integer_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_int_t value[]) {

    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    int needParameterUpdate = 0;
    int needRecomputeVars = 0;

    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if(z[index] != value[i]) {

            /* Set value from the value array to z vector. */
            z[index] = value[i];
            needRecomputeVars = 1;
            if (index < jmi->offs_real_dx) {
                needParameterUpdate = 1;
            }
        }
    }

    if(needRecomputeVars) {
    	RECOMPUTE_VARIABLES_SET(jmi);

        if( needParameterUpdate ) {
              jmi_init_eval_parameters(jmi);
        }
    }
    return 0;
}

int jmi_set_boolean_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    const jmi_boolean value[]) {

    /* Get the z vector*/
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;
    int needParameterUpdate = 0, needRecomputeVars = 0;

    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        if(z[index] != value[i]) {
            /* Set value from the value array to z vector. */
            z[index] = value[i];
            needRecomputeVars = 1;
            if (index < jmi->offs_real_dx) {
                needParameterUpdate = 1;
            }
        }
    }

    if(needRecomputeVars) {
    	RECOMPUTE_VARIABLES_SET(jmi);

        if( needParameterUpdate ) {
              jmi_init_eval_parameters(jmi);
        }
    }
    return 0;
}

int jmi_set_string_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   const jmi_string value[]) {

	NOT_USED(vr);
	NOT_USED(nvr);
	NOT_USED(value);

	RECOMPUTE_VARIABLES_SET(jmi);
    jmi_log_comment(jmi->log, logWarning, "Strings are not yet supported.");
    return 0;
}

int jmi_get_real_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                 jmi_real_t value[], int eval_required) {

    int retval;
    jmi_value_reference i;
    jmi_value_reference index;
    jmi_real_t* z;

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && eval_required == 1 && jmi->user_terminate == 0) {

        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }

        RECOMPUTE_VARIABLES_CLR(jmi);
    }

    /* Get the z vector*/
    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        /* Set value from z vector to return value array*/
        value[i] = (jmi_real_t)z[index];
    }

    return 0;
}

int jmi_get_integer_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_int_t value[], int eval_required) {

    int retval;
    jmi_real_t* z;
    jmi_value_reference i;
    jmi_value_reference index;

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && eval_required == 1 && jmi->user_terminate == 0) {

        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }

        RECOMPUTE_VARIABLES_CLR(jmi);
    }

    /* Get the z vector*/
    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        /* Set value from z vector to return value array*/
        value[i] = (jmi_int_t)z[index];
    }
    return 0;
}

int jmi_get_boolean_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                    jmi_boolean value[], int eval_required) {

    int retval;
    jmi_real_t* z;
    jmi_value_reference i;
    jmi_value_reference index;

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && eval_required == 1 && jmi->user_terminate == 0) {

        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }

        RECOMPUTE_VARIABLES_CLR(jmi);
    }

    /* Get the z vector*/
    z = jmi_get_z(jmi);

    for (i = 0; i < nvr; i = i + 1) {
        /* Get index in z vector from value reference. */
        index = get_index_from_value_ref(vr[i]);

        /* Set value from z vector to return value array*/
        value[i] = z[index];
    }
    return 0;
}

int jmi_get_string_impl(jmi_t* jmi, const jmi_value_reference vr[], size_t nvr,
                   jmi_string  value[], int eval_required) {

    int retval;
    int i;

    if (jmi->recomputeVariables == 1 && jmi->is_initialized == 1 && eval_required == 1 && jmi->user_terminate == 0) {

        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {
            jmi_log_comment(jmi->log, logError, "Evaluating the derivatives failed.");
            return -1;
        }

        RECOMPUTE_VARIABLES_CLR(jmi);
    }

    /* Strings not yet supported. */
    for(i = 0; i < nvr; i++) value[i] = 0;
    jmi_log_comment(jmi->log, logWarning, "Strings are not yet supported.");

    return 0;
}

int jmi_set_time_impl(jmi_t* jmi, jmi_real_t time) {
    jmi_real_t* time_old = (jmi_get_t(jmi));

    if (*time_old != time) {
        if (*time_old > time && jmi->is_initialized == 1) {
            jmi_reset_internal_variables(jmi);
        }

        *time_old = time;
        RECOMPUTE_VARIABLES_SET(jmi);
    }

    return 0;
}

int jmi_set_continuous_states_impl(jmi_t* jmi, const jmi_real_t x[], size_t nx) {
    jmi_real_t* x_cur = jmi_get_real_x(jmi);
    size_t i;

    for (i = 0; i < nx; i++){
        if (x_cur[i] != x[i]){
            x_cur[i] = x[i];

            RECOMPUTE_VARIABLES_SET(jmi);
        }
    }
    return 0;
}

int jmi_get_event_indicators_impl(jmi_t* jmi, jmi_real_t eventIndicators[], size_t ni) {
    int retval;
    jmi_log_node_t node;

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        node =jmi_log_enter_fmt(jmi->log, logInfo, "GetEventIndicators",
                                "Call to get event indicators at <t:%g>.", jmi_get_t(jmi)[0]);
    }

    if (RECOMPUTE_VARIABLES(jmi) == 1 && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {

            /* Store the current time and states */
            jmi_real_t time = *(jmi_get_t(jmi));
            jmi_real_t *x = (jmi_real_t*)jmi->jmi_callbacks.allocate_memory(jmi->n_real_x, sizeof(jmi_real_t));
            memcpy(x, jmi_get_real_x(jmi), jmi->n_real_x*sizeof(jmi_real_t));

            jmi_log_node(jmi->log, logWarning, "Warning",
                "Evaluating the derivatives failed while evaluating the event indicators at <t:%g>, retrying with restored values.", jmi_get_t(jmi)[0]);
            /* If it failed, reset to the previous succesful values */
            jmi_reset_last_successful_values(jmi);

            /* Restore the current time and states */
            memcpy (jmi_get_real_x(jmi), x, jmi->n_real_x*sizeof(jmi_real_t));
            *(jmi_get_t(jmi)) = time;
            jmi->jmi_callbacks.free_memory(x);

            /* Try again */
            retval = jmi_ode_derivatives(jmi);
            if(retval != 0) {
                if (jmi->jmi_callbacks.log_options.log_level >= 5){
                    jmi_log_leave(jmi->log, node);
                }
                jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed while evaluating the event indicators at <t:%g>", jmi_get_t(jmi)[0]);
                /* If it failed, reset to the previous succesful values */
                jmi_reset_last_successful_values(jmi);

                return -1;
            }
        }

        RECOMPUTE_VARIABLES_CLR(jmi);
    }

    retval = jmi_dae_R_perturbed(jmi,eventIndicators);
    if(retval != 0) {
        jmi_log_comment(jmi->log, logError, "Evaluating the event indicators failed.");
        if (jmi->jmi_callbacks.log_options.log_level >= 5){
            jmi_log_leave(jmi->log, node);
        }
        return -1;
    }

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        jmi_log_reals(jmi->log, node, logInfo, "Event Indicators", eventIndicators, ni);
        jmi_log_leave(jmi->log, node);
    }

    return 0;
}

int jmi_get_derivatives_impl(jmi_t* jmi, jmi_real_t derivatives[] , size_t nx) {
    int retval;
    jmi_log_node_t node;

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        node =jmi_log_enter_fmt(jmi->log, logInfo, "GetDerivatives",
                                "Call to get derivatives at <t:%g>.", jmi_get_t(jmi)[0]);
        if (jmi->jmi_callbacks.log_options.log_level >= 6){
            jmi_log_reals(jmi->log, node, logInfo, "switches", jmi_get_sw(jmi), jmi->n_sw);
            jmi_log_reals(jmi->log, node, logInfo, "booleans", jmi_get_boolean_d(jmi), jmi->n_boolean_d);
            jmi_log_reals(jmi->log, node, logInfo, "integers", jmi_get_integer_d(jmi), jmi->n_integer_d);
        }
    }

    if (RECOMPUTE_VARIABLES(jmi) == 1  && jmi->user_terminate == 0) {
        retval = jmi_ode_derivatives(jmi);
        if(retval != 0) {

            /* Store the current time and states */
            jmi_real_t time = *(jmi_get_t(jmi));
            jmi_real_t *x = jmi->jmi_callbacks.allocate_memory(jmi->n_real_x, sizeof(jmi_real_t));
            memcpy(x, jmi_get_real_x(jmi), jmi->n_real_x*sizeof(jmi_real_t));

            jmi_log_node(jmi->log, logWarning, "Warning",
                "Evaluating the derivatives failed at <t:%g>, retrying with restored values.", jmi_get_t(jmi)[0]);
            /* If it failed, reset to the previous succesful values */
            jmi_reset_last_successful_values(jmi);

            /* Restore the current time and states */
            memcpy (jmi_get_real_x(jmi), x, jmi->n_real_x*sizeof(jmi_real_t));
            *(jmi_get_t(jmi)) = time;
            jmi->jmi_callbacks.free_memory(x);

            /* Try again */
            retval = jmi_ode_derivatives(jmi);
            if(retval != 0) {
                if (jmi->jmi_callbacks.log_options.log_level >= 5){
                    jmi_log_leave(jmi->log, node);
                }
                jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed at <t:%g>", jmi_get_t(jmi)[0]);
                /* If it failed, reset to the previous successful values */
                jmi_reset_last_successful_values(jmi);

                return -1;
            }
        }

        RECOMPUTE_VARIABLES_CLR(jmi);
    }

    memcpy (derivatives, jmi_get_real_dx(jmi), nx*sizeof(jmi_real_t));

    /* Verify that output is free from NANs */
    {
        int index_of_nan = 0;
        retval = jmi_check_nan(jmi, derivatives, nx, &index_of_nan);
        if (retval != 0) {
            jmi_log_node(jmi->log, logError, "Error",
                    "Evaluating the derivatives failed at <t:%g>. Produced NaN in <index:%I>", jmi_get_t(jmi)[0], index_of_nan);
            return -1;
        }
    }

    if (jmi->jmi_callbacks.log_options.log_level >= 5){
        jmi_log_leave(jmi->log, node);
    }

    return 0;
}


int jmi_save_last_successful_values(jmi_t *jmi) {
    jmi_real_t* z;
    jmi_real_t* z_last;

    z = jmi_get_z(jmi);
    z_last = jmi_get_z_last(jmi);
    memcpy(z_last, z, jmi->n_z*sizeof(jmi_real_t));

    return 0;
}

int jmi_reset_last_successful_values(jmi_t *jmi) {
    jmi_real_t* z;
    jmi_real_t* z_last;

    z = jmi_get_z(jmi);
    z_last = jmi_get_z_last(jmi);
    memcpy(z, z_last, jmi->n_z*sizeof(jmi_real_t));

    return 0;
}

int jmi_reset_last_internal_successful_values(jmi_t *jmi) {
    jmi_real_t* z;
    jmi_real_t* z_last;

    z = jmi_get_z(jmi);
    z_last = jmi_get_z_last(jmi);
    memcpy(&z[jmi->offs_real_dx], &z_last[jmi->offs_real_dx], (jmi->n_z-jmi->offs_real_dx)*sizeof(jmi_real_t));

    return 0;
}

int jmi_reset_internal_variables(jmi_t* jmi) {
    /* Store the current time and states */
    jmi_real_t time = *(jmi_get_t(jmi));
    jmi_real_t *x = jmi->real_x_work;
    jmi_real_t *u = jmi->real_u_work;

    memcpy(x, jmi_get_real_x(jmi), jmi->n_real_x*sizeof(jmi_real_t));
    memcpy(u, jmi_get_real_u(jmi), jmi->n_real_u*sizeof(jmi_real_t));

    jmi_reset_last_successful_values(jmi);

    /* Restore the current time and states */
    memcpy (jmi_get_real_u(jmi), u, jmi->n_real_u*sizeof(jmi_real_t));
    memcpy (jmi_get_real_x(jmi), x, jmi->n_real_x*sizeof(jmi_real_t));
    *(jmi_get_t(jmi)) = time;

    if (jmi->jmi_callbacks.log_options.log_level >= 6){
        jmi_log_node_t node =jmi_log_enter_fmt(jmi->log, logInfo, "ResettingInternalVariables",
                                "Resetting internal variables at <t:%g>.", jmi_get_t(jmi)[0]);
        jmi_log_leave(jmi->log, node);
    }

    return 0;
}

int
jmi_update_all(jmi_t* jmi)
{
    return jmi_generic_func(jmi, jmi->dae->ode_derivatives);
}