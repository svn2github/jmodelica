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

int jmi_check_and_log_illegal_residual_output(jmi_block_solver_t *block, double* f, double* ivs, double* residual_heuristic_nominal, int N) {
    int i, ret=0;
    jmi_log_t *log = block->log;
    int nansPresent = FALSE;
    int infsPresent = FALSE;
    int limValsPresent = FALSE;

    for (i=0;i<N;i++) {
        double v = f[i];
        /* Recoverable error*/
        if (v != v) { /* NaN */
            ret = 1;
            nansPresent = TRUE;
            block->residual_error_indicator[i] = 1;
        } else if(v - v != 0) { /* Inf */
            ret = 1;
            infsPresent = TRUE;
            block->residual_error_indicator[i] = 2;
        } else if (v >  JMI_LIMIT_VALUE * residual_heuristic_nominal[i] ||
            v < -JMI_LIMIT_VALUE * residual_heuristic_nominal[i]) {
                ret = 1;
                limValsPresent = TRUE;
                block->residual_error_indicator[i] = 3;
        } else {
            block->residual_error_indicator[i] = 0;
        }

    }

    if(ret && N==1) {
        if (nansPresent)
            jmi_log_node(log, logWarning, "IllegalResidualOutput", "Not a number as output from <block: %s> with <input: %g>", block->label, ivs[0]);
        if (infsPresent)
            jmi_log_node(log, logWarning, "IllegalResidualOutput", "INF as output from <block: %s> with <input: %g>", block->label, ivs[0]);
        if( limValsPresent)
            jmi_log_node(log, logWarning, "IllegalResidualOutput", "Absolute value of <output: %g> too big in <block: %s> with <input: %g>", f[i], block->label, ivs[0]);
    } else if (ret) {
        jmi_log_node_t outer;
        jmi_log_node_t inner;
        outer = jmi_log_enter_fmt(log, logWarning, "IllegalResidualOutput", "The residual output is illegal in <block: %s>", block->label);    
        if (nansPresent) {
            inner = jmi_log_enter_index_vector_(log, outer, logWarning, "NaNResidualIndices", 'R');
            for(i=0; i<N; i++) {
                if(block->residual_error_indicator[i] == 1) 
                    jmi_log_int_(log, i);
            }
            jmi_log_leave(log, inner);
        }
        if (infsPresent) {
            inner = jmi_log_enter_index_vector_(log, outer, logWarning, "INFResidualIndices", 'R');
            for(i=0; i<N; i++) {
                if(block->residual_error_indicator[i] == 2) 
                    jmi_log_int_(log, i);
            }
            jmi_log_leave(log, inner);
        }
        if( limValsPresent) {
            inner = jmi_log_enter_index_vector_(log, outer, logWarning, "LimitingValueIndices", 'R');
            for(i=0; i<N; i++) {
                if(block->residual_error_indicator[i] == 3) 
                    jmi_log_int_(log, i);
            }
            jmi_log_leave(log, inner);
        }
        if(block->callbacks->log_options.log_level >= 3) {
            jmi_log_reals(log, outer, logWarning, "ivs", ivs, block->n);
            jmi_log_reals(log, outer, logWarning, "residuals", f, block->n);                   
        }
        jmi_log_leave(log, outer);
    }
    return ret;
}

int jmi_check_and_log_illegal_iv_input(jmi_block_solver_t *block, double* ivs, int N) {
    int i, ret = 0;
    jmi_log_t *log = block->log;
    int nansPresent = FALSE;
    int infsPresent = FALSE;
    int limValsPresent = FALSE;

    for (i=0;i<N;i++) {
        double v = ivs[i];
        /* Recoverable error*/
        if (v != v) { /* NaN */
            ret = -1;
            nansPresent = TRUE;
            block->residual_error_indicator[i] = 1;
        } else if(v - v != 0) { /* Inf */
            ret = -1;
            infsPresent = TRUE;
            block->residual_error_indicator[i] = 2;
        } else if (v >  JMI_LIMIT_VALUE * block->nominal[i] ||
            v < -JMI_LIMIT_VALUE * block->nominal[i]) {
                ret = -1;
                limValsPresent = TRUE;
                block->residual_error_indicator[i] = 3;
        } else {
            block->residual_error_indicator[i] = 0;
        }

    }

    if(ret && N==1) {
        if (nansPresent)
            jmi_log_node(log, logWarning, "IllegalIterationVariableInput", "Not a number as input to <block: %s>", block->label);
        if (infsPresent)
            jmi_log_node(log, logWarning, "IllegalIterationVariableInput", "INF as input to <block: %s>", block->label);
        if( limValsPresent)
            jmi_log_node(log, logWarning, "IllegalIterationVariableInput", "Absolute value of input too big in <block: %s>", block->label);
    } else if (ret) {
        jmi_log_node_t outer;
        jmi_log_node_t inner;
        outer = jmi_log_enter_fmt(log, logWarning, "IllegalIterationVariableInput", "The iteration variable input is illegal in <block: %s>", block->label);

        if (nansPresent) {
            inner = jmi_log_enter_vector_(log, outer, logWarning, "NaNIterationVariableIndices");
            for(i=0; i<N; i++) {
                if(block->residual_error_indicator[i] == 1) 
                    jmi_log_vref_(log, 'r', block->value_references[i]);
            }
            jmi_log_leave(log, inner);
        }
        if (infsPresent) {
            inner = jmi_log_enter_vector_(log, outer, logWarning, "INFIterationVariableIndices");
            for(i=0; i<N; i++) {
                if(block->residual_error_indicator[i] == 2) 
                    jmi_log_vref_(log, 'r', block->value_references[i]);
            }
            jmi_log_leave(log, inner);
        }
        if( limValsPresent) {
            inner = jmi_log_enter_vector_(log, outer, logWarning, "LimitingValueIndices");
            for(i=0; i<N; i++) {
                if(block->residual_error_indicator[i] == 3) 
                    jmi_log_vref_(log, 'r', block->value_references[i]);
            }
            jmi_log_leave(log, inner);
        }
        if(block->callbacks->log_options.log_level >= 3) {
            jmi_log_reals(log, outer, logWarning, "ivs", ivs, block->n);
               
        }
        jmi_log_leave(log, outer);
    }
    return ret;
}
