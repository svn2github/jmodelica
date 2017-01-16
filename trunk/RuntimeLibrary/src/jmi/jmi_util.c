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

#include <stdarg.h>
#ifdef _WIN32
    #include <win32_dirent.h>
#else
    #include <dirent.h>
#endif
#include "jmi.h"
#include "jmi_log.h"
#include "jmi_global.h"
#include <stdio.h>
#include <assert.h>
#include "jmi_math.h"

void jmi_min_time_event(jmi_time_event_t* event, int def, int phase, jmi_ad_var_t time) {
    if (JMI_TRUE == LOG_EXP_OR(
                        LOG_EXP_OR(
                            LOG_EXP_NOT(AD_WRAP_LITERAL(event->defined)), 
                            SURELY_GT_ZERO(event->time - time)), 
                        LOG_EXP_AND(
                            ALMOST_ZERO(event->time - time), 
                            SURELY_GT_ZERO(event->phase - phase)))) {
        event->defined = def;
        event->phase = phase;
        event->time = time;
    }
}

void jmi_internal_error(jmi_t *jmi, const char msg[]) {
    jmi_log_node(jmi->log, logError, "Error", "Internal error <msg:%s>", msg);
    jmi_throw();
    jmi_log_node(jmi->log, logError, "Error", "Could not throw an exception after internal error", msg);
}

void jmi_flag_termination(jmi_t *jmi, const char* msg) {
    jmi->model_terminate = 1;
    /* TODO: This is an informative message, not a warning, but is rather important. Change once log level is made separate from message category. */
    jmi_log_node(jmi->log, logWarning, "SimulationTerminated", "<msg:%s>", msg);
}

int jmi_copy_pre_values(jmi_t *jmi) {
    int i;
    jmi_real_t* z;
    z = jmi_get_z(jmi);
    for (i=jmi->offs_real_dx;i<jmi->offs_t;i++) {
        z[i - jmi->offs_real_dx + jmi->offs_pre_real_dx] = z[i];
    }
    for (i=jmi->offs_real_d;i<jmi->offs_pre_real_dx;i++) {
        z[i - jmi->offs_real_d + jmi->offs_pre_real_d] = z[i];
    }
    return 0;
}

jmi_real_t* jmi_get_z(jmi_t* jmi) {
    return *(jmi->z);
}

int jmi_get_z_size(jmi_t* jmi) {
    return jmi->n_z;
}

jmi_string_t* jmi_get_string_z(jmi_t* jmi) {
    return jmi->z_t.strings.values;
}

jmi_real_t* jmi_get_z_last(jmi_t* jmi) {
    return *(jmi->z_last);
}

jmi_real_t* jmi_get_real_ci(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_ci;
}

jmi_real_t* jmi_get_real_cd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_cd;
}

jmi_real_t* jmi_get_real_pi(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_pi;
}

jmi_real_t* jmi_get_real_pd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_pd;
}

jmi_real_t* jmi_get_integer_ci(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_ci;
}

jmi_real_t* jmi_get_integer_cd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_cd;
}

jmi_real_t* jmi_get_integer_pi(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_pi;
}

jmi_real_t* jmi_get_integer_pd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_pd;
}

jmi_real_t* jmi_get_boolean_ci(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_ci;
}

jmi_real_t* jmi_get_boolean_cd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_cd;
}

jmi_real_t* jmi_get_boolean_pi(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_pi;
}

jmi_real_t* jmi_get_boolean_pd(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_pd;
}

jmi_real_t* jmi_get_real_dx(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_dx;
}

jmi_real_t* jmi_get_real_x(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_x;
}

jmi_real_t* jmi_get_real_u(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_u;
}

jmi_real_t* jmi_get_real_w(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_w;
}

jmi_real_t* jmi_get_t(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_t;
}

jmi_real_t* jmi_get_real_d(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_real_d;
}

jmi_real_t* jmi_get_integer_d(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_d;
}

jmi_real_t* jmi_get_integer_u(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_integer_u;
}

jmi_real_t* jmi_get_boolean_d(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_d;
}

jmi_real_t* jmi_get_boolean_u(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_boolean_u;
}

jmi_real_t* jmi_get_sw(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_sw;
}

jmi_real_t* jmi_get_state_sw(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_state_sw;
}

jmi_real_t* jmi_get_time_sw(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_time_sw;
}

jmi_real_t* jmi_get_sw_init(jmi_t* jmi) {
    return *(jmi->z) + jmi->offs_sw_init;
}

void jmi_init_runtime_options(jmi_t *jmi, jmi_options_t* op) {
    jmi_block_solver_init_default_options(&op->block_solver_options);

    op->nle_solver_default_tol = 1e-10;           /**< \brief Default tolerance for the equation block solver */
    op->nle_solver_tol_factor = 0.0001;           /**< \brief Tolerance safety factor for the non-linear equation block solver. */
    op->events_default_tol = 1e-10;               /**< \brief Default tolerance for the event iterations. */        
    op->time_events_default_tol = JMI_ALMOST_EPS; /** <\brief Default tolerance for the time event iterations. */
    op->events_tol_factor = 0.0001;               /**< \brief Tolerance safety factor for the event iterations. */
    op->cs_solver = JMI_ODE_CVODE;                /**< \brief Option for changing the internal CS solver. */
    op->cs_rel_tol = 1e-6;                        /**< \brief Default tolerance for the adaptive solvers in the CS case. */
    op->cs_step_size = 1e-3;                      /**< \brief Default step-size for the non-adaptive solvers in the CS case. */   
    op->cs_experimental_mode = 0;

    op->log_options = &jmi->jmi_callbacks.log_options;
}

jmi_value_reference jmi_get_index_from_value_ref(jmi_value_reference vref) {
    /* Translate a ValueReference into variable index in z-vector. */
    return vref & VREF_INDEX_MASK;
}

jmi_type_t jmi_get_type_from_value_ref(jmi_value_reference vref) {
    /* Translate a ValueReference into variable type in z-vector. */    
    switch (vref & VREF_TYPE_MASK) {
        case REAL_TYPE_MASK: return JMI_REAL;
        case INT_TYPE_MASK:  return JMI_INTEGER;
        case BOOL_TYPE_MASK: return JMI_BOOLEAN;
        case STR_TYPE_MASK:  return JMI_STRING;
        default:
            return -1;
    }
}

jmi_value_reference jmi_value_ref_is_negated(jmi_value_reference vref) {
    /* Checks for a valueReference if it is negated. */
    return vref & VREF_NEGATE_MASK;
}

jmi_value_reference jmi_get_value_ref_from_index(int index, jmi_type_t type) {
    /* Translates an index together with a type to a value reference */
    switch (type) {
        case JMI_REAL:    return index + REAL_TYPE_MASK;
        case JMI_INTEGER: return index + INT_TYPE_MASK;
        case JMI_BOOLEAN: return index + BOOL_TYPE_MASK;
        case JMI_STRING:  return index + STR_TYPE_MASK;
        default:
            return -1;
    }
}

int jmi_compare_switches(jmi_real_t* sw_pre, jmi_real_t* sw_post, jmi_int_t size) {
    int i, all_switches_equal = 1;
    
    for (i = 0; i < size; i++){
        if (sw_pre[i] != sw_post[i]){
            all_switches_equal = 0;
            break;
        }
    }
    return all_switches_equal;
}

int jmi_compare_discrete_reals(jmi_real_t* dr_pre, jmi_real_t* dr_post, jmi_real_t* nominals, jmi_int_t size) {
    int i, all_discrete_reals_equal = 1;
    
    for (i = 0; i < size; i++){
        if (RAbs(dr_pre[i] - dr_post[i])/nominals[i] > JMI_ALMOST_EPS ){
            all_discrete_reals_equal = 0;
            break;
        }
    }
    return all_discrete_reals_equal;
}

jmi_real_t jmi_turn_switch(jmi_t* jmi, jmi_real_t ev_ind, jmi_real_t sw, int rel) {
    /* x >= 0
     * x >  0
     * x <= 0
     * x <  0
     */
    jmi_real_t eps = jmi->events_epsilon;
    if (eps == 0.0) {
        if (sw == 1.0) {
            if ((ev_ind <  0.0 && rel == JMI_REL_GEQ)   ||
                (ev_ind <= 0.0 && rel == JMI_REL_GT)    ||
                (ev_ind >  0.0 && rel == JMI_REL_LEQ)   ||
                (ev_ind >= 0.0 && rel == JMI_REL_LT))
            {
                sw = 0.0;
            }
        } else {
            if ((ev_ind >= 0.0 && rel == JMI_REL_GEQ)   ||
                (ev_ind >  0.0 && rel == JMI_REL_GT)    ||
                (ev_ind <= 0.0 && rel == JMI_REL_LEQ)   ||
                (ev_ind <  0.0 && rel == JMI_REL_LT))
            {
                sw = 1.0;
            }
        }
    } else {
        if (sw == 1.0) {
            if ((ev_ind <= -eps && rel == JMI_REL_GEQ)  ||
                (ev_ind <= 0.0  && rel == JMI_REL_GT)   ||
                (ev_ind >= eps  && rel == JMI_REL_LEQ)  ||
                (ev_ind >= 0.0  && rel == JMI_REL_LT))
            {
                sw = 0.0;
            }
        } else {
            if ((ev_ind >= 0.0  && rel == JMI_REL_GEQ)   ||
                (ev_ind >= eps  && rel == JMI_REL_GT)    ||
                (ev_ind <= 0.0  && rel == JMI_REL_LEQ)   ||
                (ev_ind <= -eps && rel == JMI_REL_LT))
            {
                sw = 1.0;
            }
        }
    }
    return sw;
}

jmi_real_t jmi_turn_switch_time(jmi_t* jmi, jmi_real_t ev_ind, jmi_real_t sw, int rel) {
    /* x >= 0
     * x >  0
     * x <= 0
     * x <  0
     */
    jmi_real_t t = jmi_get_t(jmi)[0];
    jmi_real_t eps = jmi->time_events_epsilon;
    eps = eps*jmi_max(1.0, t);
    if (sw == 1.0) {
        if ((ev_ind <  -eps && rel == JMI_REL_GEQ)  ||
            (ev_ind <=  eps && rel == JMI_REL_GT)   ||
            (ev_ind >   eps && rel == JMI_REL_LEQ)  ||
            (ev_ind >= -eps && rel == JMI_REL_LT))
        {
            sw = 0.0;
        }
    } else {
        if ((ev_ind >= -eps && rel == JMI_REL_GEQ)  ||
            (ev_ind >   eps && rel == JMI_REL_GT)   ||
            (ev_ind <=  eps && rel == JMI_REL_LEQ)  ||
            (ev_ind <  -eps && rel == JMI_REL_LT))
        {
            sw = 1.0;
        }
    }
    return sw;
}

int jmi_file_exists(const char* file) {
    FILE *fp;
    if (file && (fp = fopen(file,"r")))
        fclose(fp);
    else
        return 0;
    return 1;
}

int jmi_dir_exists(const char* dir) {
    DIR* dh;
    if(dir && (dh = opendir(dir)))
        closedir(dh);
    else
        return 0;
    return 1;
}

void jmi_load_resource(jmi_t *jmi, jmi_string_t res, const jmi_string_t file) {
    size_t len;
    jmi_string_t loc = jmi->resource_location;
    if (!loc) {
        jmi_log_node(jmi->log, logError, "Error", "Resource location unavailable.");
        strcpy(res,file);
        return;
    }
    len = strlen(loc) + strlen(file);
    if (len >= JMI_PATH_MAX) {
        jmi_log_node(jmi->log, logError, "Error", "File path too long: <Path:%s, File:%s>", loc, file);
        return;
    }
    strcpy(res, loc);
    strcat(res, file);
    if (!jmi_file_exists(res))
        jmi_log_node(jmi->log, logError, "Error", "Could not locate resource <File:%s>", res);
}
