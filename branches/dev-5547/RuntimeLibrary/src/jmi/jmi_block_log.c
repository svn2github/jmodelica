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

#include <time.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "jmi_block_log.h"
#include "jmi_log.h"
#include "jmi_block_solver_impl.h"

#define Ith(v,i)    NV_Ith_S(v,i)

int jmi_check_illegal_values(int *error_indicator, jmi_real_t *nominal, jmi_real_t *inputs, int n, int* nans_present, int *infs_present, int *lim_vals_present) {
	int i, ret = 0;
	nans_present[0] = FALSE;
	infs_present[0] = FALSE;
	lim_vals_present[0] = FALSE;
	for (i=0;i<n;i++) {
		double v = inputs[i];
		/* Recoverable error*/
		if (v != v) { /* NaN */
			ret = -1;
			nans_present[0] = TRUE;
			error_indicator[i] = 1;
		} else if(v - v != 0) { /* Inf */
			ret = -1;
			infs_present[0] = TRUE;
			error_indicator[i] = 2;
		} else if (v >  JMI_LIMIT_VALUE * nominal[i] ||
			v < -JMI_LIMIT_VALUE * nominal[i]) {
				ret = -1;
				lim_vals_present[0] = TRUE;
				error_indicator[i] = 3;
		} else {
			error_indicator[i] = 0;
		}
	}
}

void jmi_log_illegal_input(jmi_log_t *log, int *error_indicator, int n, int nans_present, int infs_present, int lim_vals_present, jmi_real_t *inputs,
	jmi_string_t label, int is_iter_var_flag, int* value_references, int log_level, const char* label_type) {
	int i;
	int ret = (nans_present+infs_present+lim_vals_present) > 0 ? TRUE: FALSE;
	char* warn_input_type;
	if (is_iter_var_flag) {
		warn_input_type = "IllegalIterationVariableInput";
	} else {
		warn_input_type = "IllegalVariableInput";
	}

	if(ret && n==1) {
        if (nans_present)
            jmi_log_node(log, logWarning, warn_input_type, "Not a number as input to <%s: %s>", label_type, label);
        if (infs_present)
            jmi_log_node(log, logWarning, warn_input_type, "INF as input to <%s: %s>", label_type, label);
        if( lim_vals_present)
            jmi_log_node(log, logWarning, warn_input_type, "Absolute value of input too big in <%s: %s>", label_type, label);
    } else if (ret) {
        jmi_log_node_t outer;
        jmi_log_node_t inner;
        outer = jmi_log_enter_fmt(log, logWarning, warn_input_type, "The iteration variable input is illegal in <%s: %s>", label_type, label);

        if (nans_present) {
            inner = jmi_log_enter_vector_(log, outer, logWarning, is_iter_var_flag? "NaNIterationVariableIndices": "NaNVariableIndices");
            for(i=0; i<n; i++) {
                if(error_indicator[i] == 1) {
					if (is_iter_var_flag)
						jmi_log_vref_(log, 'r', value_references[i]);
					else
						jmi_log_int_(log, i);
				}
            }
            jmi_log_leave(log, inner);
        }
        if (infs_present) {
            inner = jmi_log_enter_vector_(log, outer, logWarning,  is_iter_var_flag? "INFIterationVariableIndices": "INFVariableIndices");
            for(i=0; i<n; i++) {
                if(error_indicator[i] == 2) {
					if (is_iter_var_flag)
						jmi_log_vref_(log, 'r', value_references[i]);
					else
						jmi_log_int_(log, i);
				}
            }
            jmi_log_leave(log, inner);
        }
        if( lim_vals_present) {
            inner = jmi_log_enter_vector_(log, outer, logWarning, "LimitingValueIndices");
            for(i=0; i<n; i++) {
                if(error_indicator[i] == 3) {
					if (is_iter_var_flag)
						jmi_log_vref_(log, 'r', value_references[i]);
					else
						jmi_log_int_(log, i);
				}
            }
            jmi_log_leave(log, inner);
        }
        if(log_level >= 3) {
            jmi_log_reals(log, outer, logWarning, is_iter_var_flag?"ivs":"inputs", inputs, n);
               
        }
        jmi_log_leave(log, outer);
    }
}

void jmi_log_illegal_output(jmi_log_t *log, int *error_indicator, int n_outputs, int n_inputs, jmi_real_t *inputs, jmi_real_t *outputs, int nans_present, int infs_present, int lim_vals_present, 
	jmi_string_t label, int is_iter_var_flag, int log_level, const char* label_type) {
		int i;
		int ret = (nans_present+infs_present+lim_vals_present) > 0 ? TRUE: FALSE;
		char* warn_output_type;
		if (is_iter_var_flag) {
			warn_output_type = "IllegalIterationVariableInput";
		} else {
			warn_output_type = "IllegalVariableInput";
		}

		if(ret && n_outputs==1 && n_inputs==1) {
			if (nans_present)
				jmi_log_node(log, logWarning, warn_output_type, "Not a number as output from <%s: %s> with <input: %g>", label_type, label, inputs[0]);
			if (infs_present)
				jmi_log_node(log, logWarning, warn_output_type, "INF as output from <%s: %s> with <input: %g>", label_type, label, inputs[0]);
			if( lim_vals_present)
				jmi_log_node(log, logWarning, warn_output_type, "Absolute value of <output: %g> too big in <%s: %s> with <input: %g>", label_type, label, inputs[0]);
		} else if (ret) {
			jmi_log_node_t outer;
			jmi_log_node_t inner;
			outer = jmi_log_enter_fmt(log, logWarning, warn_output_type, "The output is illegal in <%s: %s>", label_type, label);

			if (nans_present) {
				inner = jmi_log_enter_vector_(log, outer, logWarning, is_iter_var_flag? "NaNResidualIndices": "NaNOutputIndices");
				for(i=0; i<n_outputs; i++) {
					if(error_indicator[i] == 1) {
							jmi_log_int_(log, i);
					}
				}
				jmi_log_leave(log, inner);
			}
			if (infs_present) {
				inner = jmi_log_enter_vector_(log, outer, logWarning,  is_iter_var_flag? "INFResidualIndices": "INFOutputIndices");
				for(i=0; i<n_outputs; i++) {
					if(error_indicator[i] == 2) {
							jmi_log_int_(log, i);
					}
				}
				jmi_log_leave(log, inner);
			}
			if( lim_vals_present) {
				inner = jmi_log_enter_vector_(log, outer, logWarning, "LimitingValueIndices");
				for(i=0; i<n_outputs; i++) {
					if(error_indicator[i] == 3) {
							jmi_log_int_(log, i);
					}
				}
				jmi_log_leave(log, inner);
			}
			if(log_level >= 3) {
				jmi_log_reals(log, outer, logWarning, is_iter_var_flag?"ivs":"inputs", inputs, n_inputs);
				jmi_log_reals(log, outer, logWarning,  is_iter_var_flag?"residuals":"outputs", outputs, n_outputs); 

			}
			jmi_log_leave(log, outer);
		}
}

int jmi_check_and_log_illegal_residual_output(jmi_block_solver_t *block, double* f, double* ivs, double* residual_heuristic_nominal, int N) {
    int i, ret=0;
    jmi_log_t *log = block->log;
    int nans_present = FALSE;
    int infs_present = FALSE;
    int lim_vals_present = FALSE;

	ret = jmi_check_illegal_values(block->residual_error_indicator, block->residual_heuristic_nominal, f, N, &nans_present, &infs_present, &lim_vals_present);
	jmi_log_illegal_output(log, block->residual_error_indicator, N, N, nans_present, infs_present, lim_vals_present, ivs, f, block->label, TRUE, block->callbacks->log_options.log_level, "block");

    return ret;
}



int jmi_check_and_log_illegal_iv_input(jmi_block_solver_t *block, double* ivs, int N) {
    int i, ret = 0;
    jmi_log_t *log = block->log;
    int nans_present = FALSE;
    int infs_present = FALSE;
    int lim_vals_present = FALSE;

	ret = jmi_check_illegal_values(block->residual_error_indicator, block->nominal, ivs, N, &nans_present, &infs_present, &lim_vals_present);

	jmi_log_illegal_input(log, block->residual_error_indicator, N, nans_present, infs_present, 
		lim_vals_present, ivs, block->label, TRUE, block->value_references, block->callbacks->log_options.log_level, "block");

    return ret;
}
