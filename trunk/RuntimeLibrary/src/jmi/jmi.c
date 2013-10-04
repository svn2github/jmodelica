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


/*
 * jmi.c contains pure C functions and does not support any AD functions.
 */


#include "jmi.h"
#include "jmi_block_residual.h"
#include "jmi_log.h"

int jmi_init(jmi_t** jmi, int n_real_ci, int n_real_cd, int n_real_pi,
        int n_real_pd, int n_integer_ci, int n_integer_cd,
        int n_integer_pi, int n_integer_pd,int n_boolean_ci, int n_boolean_cd,
        int n_boolean_pi, int n_boolean_pd, int n_string_ci, int n_string_cd,
        int n_string_pi, int n_string_pd,
        int n_real_dx, int n_real_x, int n_real_u, int n_real_w,
        int n_real_d, int n_integer_d, int n_integer_u,
        int n_boolean_d, int n_boolean_u,
        int n_string_d, int n_string_u,
        int n_outputs, int* output_vrefs,
        int n_sw, int n_sw_init,
        int n_guards, int n_guards_init,
        int n_dae_blocks, int n_dae_init_blocks,
        int n_initial_relations, int* initial_relations,
        int n_relations, int* relations,
        int scaling_method, int n_ext_objs, jmi_callbacks_t* jmi_callbacks) {
    jmi_t* jmi_ ;
    int i;
    
    /* Create jmi struct */
    *jmi = (jmi_t*)calloc(1,sizeof(jmi_t));
    jmi_ = *jmi;
    /* Set struct pointers in jmi */
    jmi_->dae = NULL;
    jmi_->init = NULL;
    /* jmi_->user_func = NULL; */
    jmi_->fmi = NULL;

    /* Set sizes of dae vectors */
    jmi_->n_real_ci = n_real_ci;
    jmi_->n_real_cd = n_real_cd;
    jmi_->n_real_pi = n_real_pi;
    jmi_->n_real_pd = n_real_pd;

    jmi_->n_integer_ci = n_integer_ci;
    jmi_->n_integer_cd = n_integer_cd;
    jmi_->n_integer_pi = n_integer_pi;
    jmi_->n_integer_pd = n_integer_pd;

    jmi_->n_boolean_ci = n_boolean_ci;
    jmi_->n_boolean_cd = n_boolean_cd;
    jmi_->n_boolean_pi = n_boolean_pi;
    jmi_->n_boolean_pd = n_boolean_pd;

    jmi_->n_string_ci = n_string_ci;
    jmi_->n_string_cd = n_string_cd;
    jmi_->n_string_pi = n_string_pi;
    jmi_->n_string_pd = n_string_pd;

    jmi_->n_real_dx = n_real_dx;
    jmi_->n_real_x = n_real_x;
    jmi_->n_real_u = n_real_u;
    jmi_->n_real_w = n_real_w;

    jmi_->n_real_d = n_real_d;

    jmi_->n_integer_d = n_integer_d;
    jmi_->n_integer_u = n_integer_u;

    jmi_->n_boolean_d = n_boolean_d;
    jmi_->n_boolean_u = n_boolean_u;

    jmi_->n_string_d = n_string_d;
    jmi_->n_string_u = n_string_u;

    jmi_->n_outputs = n_outputs;
    jmi_->output_vrefs = (int*)calloc(n_outputs,sizeof(int));
    for (i=0;i<n_outputs;i++) {
        jmi_->output_vrefs[i] = output_vrefs[i];
    }

    jmi_->n_sw = n_sw;
    jmi_->n_sw_init = n_sw_init;

    jmi_->n_guards = n_guards;
    jmi_->n_guards_init = n_guards_init;
    
    jmi_->n_dae_blocks = n_dae_blocks;
    jmi_->n_dae_init_blocks = n_dae_init_blocks;

    jmi_->offs_real_ci = 0;
    jmi_->offs_real_cd = jmi_->offs_real_ci + n_real_ci;
    jmi_->offs_real_pi = jmi_->offs_real_cd + n_real_cd;
    jmi_->offs_real_pd = jmi_->offs_real_pi + n_real_pi;

    jmi_->offs_integer_ci = jmi_->offs_real_pd + n_real_pd;
    jmi_->offs_integer_cd = jmi_->offs_integer_ci + n_integer_ci;
    jmi_->offs_integer_pi = jmi_->offs_integer_cd + n_integer_cd;
    jmi_->offs_integer_pd = jmi_->offs_integer_pi + n_integer_pi;

    jmi_->offs_boolean_ci = jmi_->offs_integer_pd + n_integer_pd;
    jmi_->offs_boolean_cd = jmi_->offs_boolean_ci + n_boolean_ci;
    jmi_->offs_boolean_pi = jmi_->offs_boolean_cd + n_boolean_cd;
    jmi_->offs_boolean_pd = jmi_->offs_boolean_pi + n_boolean_pi;

    jmi_->offs_real_dx = jmi_->offs_boolean_pd + n_boolean_pd;
    jmi_->offs_real_x = jmi_->offs_real_dx + n_real_dx;
    jmi_->offs_real_u = jmi_->offs_real_x + n_real_x;
    jmi_->offs_real_w = jmi_->offs_real_u + n_real_u;
    jmi_->offs_t = jmi_->offs_real_w + n_real_w;

    jmi_->offs_real_d = jmi_->offs_t + 1;

    jmi_->offs_integer_d = jmi_->offs_real_d + n_real_d;
    jmi_->offs_integer_u = jmi_->offs_integer_d + n_integer_d;

    jmi_->offs_boolean_d = jmi_->offs_integer_u + n_integer_u;
    jmi_->offs_boolean_u = jmi_->offs_boolean_d + n_boolean_d;

    jmi_->offs_sw = jmi_->offs_boolean_u + n_boolean_u;
    jmi_->offs_sw_init = jmi_->offs_sw + n_sw;

    jmi_->offs_guards = jmi_->offs_sw_init + n_sw_init;
    jmi_->offs_guards_init = jmi_->offs_guards + n_guards;

    jmi_->offs_pre_real_dx = jmi_->offs_guards_init + n_guards_init;
    jmi_->offs_pre_real_x = jmi_->offs_pre_real_dx + n_real_dx;
    jmi_->offs_pre_real_u = jmi_->offs_pre_real_x + n_real_x;
    jmi_->offs_pre_real_w = jmi_->offs_pre_real_u + n_real_u;

    jmi_->offs_pre_real_d = jmi_->offs_pre_real_w + n_real_w;
    jmi_->offs_pre_integer_d = jmi_->offs_pre_real_d + n_real_d;
    jmi_->offs_pre_integer_u = jmi_->offs_pre_integer_d + n_integer_d;

    jmi_->offs_pre_boolean_d = jmi_->offs_pre_integer_u + n_integer_u;
    jmi_->offs_pre_boolean_u = jmi_->offs_pre_boolean_d + n_boolean_d;
    jmi_->offs_pre_sw = jmi_->offs_pre_boolean_u + n_boolean_u;
    jmi_->offs_pre_sw_init = jmi_->offs_pre_sw + n_sw;
    jmi_->offs_pre_guards = jmi_->offs_pre_sw_init + n_sw_init;
    jmi_->offs_pre_guards_init = jmi_->offs_pre_guards + n_guards;

    jmi_->n_v = n_real_dx + n_real_x + n_real_u + n_real_w + 1;
    jmi_->n_z = jmi_->offs_real_dx + 2*(jmi_->n_v) - 1 + 
        2*(n_real_d + n_integer_d + n_integer_u + n_boolean_d + n_boolean_u) + 
        2*n_sw + 2*n_sw_init + 2*n_guards + 2*n_guards_init;

    jmi_->z = (jmi_real_t**)calloc(1,sizeof(jmi_real_t *));
    *(jmi_->z) = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));
    /*jmi_->pre_z = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t ));*/
    
    jmi_->dz = (jmi_real_t**)calloc(1, sizeof(jmi_real_t *));
    *(jmi_->dz) = (jmi_real_t*)calloc(jmi_->n_v, sizeof(jmi_real_t));/*Need number of equations*/
    
    jmi_->ext_objs = (void**)calloc(n_ext_objs, sizeof(void*));
    jmi_->indep_extobjs_initialized = 0;
    jmi_->dep_extobjs_initialized = 0;
    jmi_->block_level = 0;
    jmi_->dz_active_index = 0;
    for (i=0;i<JMI_ACTIVE_VAR_BUFS_NUM;i++) {
        jmi_->dz_active_variables_buf[i] = (jmi_real_t*)calloc(jmi_->n_v, sizeof(jmi_real_t));
    }
    
    jmi_->dz_active_variables[0] = jmi_->dz_active_variables_buf[0];

    jmi_->variable_scaling_factors = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));
    jmi_->scaling_method = JMI_SCALING_NONE;

    for (i=0;i<jmi_->n_z;i++) {
        jmi_->variable_scaling_factors[i] = 1.0;
        (*(jmi_->z))[i] = 0;
    }

    for (i=0;i<jmi_->n_v;i++) {
        int j;
        (*(jmi_->dz))[i] = 0;
        for (j=0; j<JMI_ACTIVE_VAR_BUFS_NUM; j++) {
            jmi_->dz_active_variables_buf[j][i] = 0;
        }
    }

    jmi_->scaling_method = scaling_method;

    jmi_->n_initial_relations = n_initial_relations;
    jmi_->n_relations = n_relations;
    jmi_->initial_relations = (jmi_int_t*)calloc(n_initial_relations,sizeof(jmi_int_t));
    jmi_->relations = (jmi_int_t*)calloc(n_relations,sizeof(jmi_int_t));

    for (i=0;i<n_initial_relations;i++) {
        jmi_->initial_relations[i] = initial_relations[i];
    }

    for (i=0;i<n_relations;i++) {
        jmi_->relations[i] = relations[i];
    }

    jmi_->dae_block_residuals = (jmi_block_residual_t**)calloc(n_dae_blocks,
            sizeof(jmi_block_residual_t*));

    jmi_->dae_init_block_residuals = (jmi_block_residual_t**)calloc(n_dae_init_blocks,
            sizeof(jmi_block_residual_t*));

    jmi_->atEvent = JMI_FALSE;
    jmi_->atInitial = JMI_FALSE;
    
    jmi_init_runtime_options(jmi_, &jmi_->options);

    jmi_->events_epsilon = jmi_->options.events_default_tol;
    jmi_->recomputeVariables = 1;

    jmi_->jmi_callbacks = jmi_callbacks;
    jmi_->log = jmi_log_init(jmi_, jmi_callbacks);

    jmi_->terminate = 0;

    jmi_->is_initialized = 0;

    return 0;

}

int jmi_ad_init(jmi_t* jmi) {
    /*return -1;*/
    return 0;
}

int jmi_delete(jmi_t* jmi){
    int i;
    if(jmi->dae != NULL) {
        jmi_func_delete(jmi->dae->F);
        jmi_func_delete(jmi->dae->R);
        jmi_delete_simple_color_info(&jmi->color_info_A);
        jmi_delete_simple_color_info(&jmi->color_info_B);
        jmi_delete_simple_color_info(&jmi->color_info_C);
        jmi_delete_simple_color_info(&jmi->color_info_D);
        free(jmi->dae);
        jmi->dae = 0;
    }

    jmi_delete_init(&(jmi->init));

    for (i=0; i < jmi->n_dae_init_blocks;i=i+1){ /*Deallocate init BLT blocks.*/
        jmi_delete_block_residual(jmi->dae_init_block_residuals[i]);
    }
        free(jmi->dae_init_block_residuals);
    for (i=0; i < jmi->n_dae_blocks;i=i+1){ /*Deallocate BLT blocks.*/
        jmi_delete_block_residual(jmi->dae_block_residuals[i]);
    }
        free(jmi->dae_block_residuals);

    free(jmi->output_vrefs);
    free(*(jmi->z));
    free(jmi->z);
/*  free(jmi->pre_z);*/
    free(*(jmi->dz));
    free(jmi->dz);
    free(jmi->initial_relations);
    free(jmi->relations);
    for(i=0; i<JMI_ACTIVE_VAR_BUFS_NUM; i++) {
        free(jmi->dz_active_variables_buf[i]);
    }
    free(jmi->variable_scaling_factors);
    free(jmi->ext_objs);
    free(jmi->log->jmi_callbacks);
    jmi_log_delete(jmi->log);
    free(jmi);

    return 0;
}

int jmi_func_F(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res) {
    int return_status;

    if (jmi_current_is_set()) {
    	return_status = func->F(jmi, &res);
    } else {
    	jmi_set_current(jmi);
		if (jmi_try(jmi))
			return_status = -1;
		else
			return_status = func->F(jmi, &res);
		jmi_set_current(NULL);
    }
    return return_status;
}

int jmi_func_cad_directional_dF(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res,
             jmi_real_t *dF, jmi_real_t* dv) {
	int return_status;
	jmi_set_current(jmi);
	if (jmi_try(jmi))
		return_status = -1;
	else
		return_status = func->cad_dir_dF(jmi, &res, &dF, &dv);
    jmi_set_current(NULL);
    return return_status;
}

int jmi_ode_f(jmi_t* jmi) {
    int i;
    jmi_real_t* dx;
    jmi_real_t* dx_res;
    
    if (jmi->n_real_w != 0) { /* Check if not ODE */
        return -1;
    }

    dx = jmi_get_real_dx(jmi);
    for(i=0;i<jmi->n_real_dx;i++) {
        dx[i]=0;
    }

    dx_res = calloc(jmi->n_real_x,sizeof(jmi_real_t));

    /*jmi->dae->F->F(jmi, &res);*/
    jmi_func_F(jmi,jmi->dae->F,dx_res);

    for(i=0;i<jmi->n_real_dx;i++) {
        dx[i]=dx_res[i];
    }

    free(dx_res);

    return 0;
}

int jmi_ode_df(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (jmi->n_real_w != 0) { /* Check if not ODE */
        return -1;
    }

    if (eval_alg & JMI_DER_SYMBOLIC) {

        int i;
        jmi_real_t* dx = jmi_get_real_dx(jmi);
        for(i=0;i<jmi->n_real_dx;i++) {
            dx[i]=0;
        }

        return jmi_func_sym_dF(jmi, jmi->dae->F, sparsity,
                independent_vars & ~JMI_DER_DX, mask, jac) ;
    } else {
        return -1;
    }
}

int jmi_ode_df_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

    int ret_val;

    if (jmi->n_real_w != 0) { /* Check if not ODE */
        return -1;
    }

    if (eval_alg & JMI_DER_SYMBOLIC) {
        int df_n_cols;
        int* mask = calloc(jmi->n_z,sizeof(int));
        int i;
        for (i=0;i<jmi->n_z;i++) {
            mask[i] = 1;
        }
        ret_val =  jmi_func_sym_dF_dim(jmi, jmi->dae->F, JMI_DER_SPARSE,
               JMI_DER_ALL & (~JMI_DER_DX), mask,
                &df_n_cols, n_nz);
        free(mask);
        return ret_val;
    } else {
        return -1;
    }
}

int jmi_ode_df_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

    if (jmi->n_real_w != 0) { /* Check if not ODE */
        return -1;
    }

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->dae->F, independent_vars & (~JMI_DER_DX),
                mask, row, col);
    } else {
        return -1;
    }

}

int jmi_ode_df_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *df_n_cols, int *df_n_nz) {

    if (jmi->n_real_w != 0) { /* Check if not ODE */
        return -1;
    }

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars & (~JMI_DER_DX), mask,
                df_n_cols, df_n_nz);
    } else {
        return -1;
    }
}

int jmi_ode_derivatives(jmi_t* jmi) {

    int return_status;
    jmi_log_node_t node;
    jmi_real_t *t = jmi_get_t(jmi);

    if((jmi->options.log_level >= 5)) {
        node = jmi_log_enter_fmt(jmi->log, logInfo, "EquationSolve", 
                                 "Model equations evaluation invoked at <t:%E>", t[0]);
    }

    jmi->block_level = 0; /* to recover from errors */
    return_status = jmi_generic_func(jmi, jmi->dae->ode_derivatives);

    if((jmi->options.log_level >= 5)) {
        jmi_log_fmt(jmi->log, node, logInfo, "Model equations evaluation finished");
        jmi_log_leave(jmi->log, node);
    }

    return return_status;
}

int jmi_ode_derivatives_dir_der(jmi_t* jmi, jmi_real_t *dv) {

    int return_status;
    jmi->block_level = 0; /* to recover from errors */
    
    return_status = jmi_generic_func(jmi, jmi->dae->ode_derivatives_dir_der);

    return return_status;
}

int jmi_ode_outputs(jmi_t* jmi) {

    int return_status;
    
    return_status = jmi_generic_func(jmi, jmi->dae->ode_outputs);

    return return_status;
}

int jmi_ode_initialize(jmi_t* jmi) {

    int return_status;
    jmi_log_node_t node;
    jmi_real_t* t = jmi_get_t(jmi);

    if((jmi->options.log_level >= 5)) {
        node = jmi_log_enter_fmt(jmi->log, logInfo, "EquationSolve", 
                                 "Model equations evaluation invoked at <t:%E>", t[0]);
    }

    return_status = jmi_generic_func(jmi, jmi->dae->ode_initialize);

    if((jmi->options.log_level >= 5)) {
        jmi_log_fmt(jmi->log, node, logInfo, "Model equations evaluation finished");
        jmi_log_leave(jmi->log, node);
    }
    return return_status;
}

int jmi_ode_guards(jmi_t* jmi) {

    int return_status;

    return_status = jmi_generic_func(jmi, jmi->dae->ode_guards);
    
    return return_status;
}

int jmi_ode_guards_init(jmi_t* jmi) {

    int return_status;

    return_status = jmi_generic_func(jmi, jmi->dae->ode_guards_init);

    return return_status;
}

int jmi_ode_next_time_event(jmi_t* jmi, jmi_real_t* nextTime) {

    int return_status;

    jmi_set_current(jmi);
    if (jmi_try(jmi))
		return_status = -1;
	else
		return_status = jmi->dae->ode_next_time_event(jmi, nextTime);
    jmi_set_current(NULL);

    return return_status;
}

jmi_ad_var_t jmi_sample(jmi_t* jmi, jmi_real_t offset, jmi_real_t h) {
    jmi_real_t t = jmi_get_t(jmi)[0];
    /* This is a workaround for an issue with gcc 4.5.1: http://trac.jmodelica.org/ticket/1349 */
        /* The original code is: if (!jmi->atEvent || SURELY_LT_ZERO(t-offset)) */
    jmi_real_t tmp = ((t-offset)<=-1e-6)? JMI_TRUE: JMI_FALSE;
    if (!jmi->atEvent || tmp) {
      /*printf("jmi_sample1: %f %f %12.12f %12.12f\n",offset,fmod((t-offset),h),(t-offset));*/
        return JMI_FALSE;
    }
    /*  printf("jmi_sample2: %f %f %12.12f %12.12f\n",offset,h,fmod((t-offset),h),(t-offset));*/
    return ALMOST_ZERO(jmi_dremainder((t-offset),h));
}

int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {

    /*jmi->dae->F->F(jmi, &res);*/
    jmi_func_F(jmi,jmi->dae->F,res);

    return 0;
}

int jmi_dae_dF(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF(jmi, jmi->dae->F, sparsity,
                independent_vars, mask, jac) ;
    } else if (eval_alg & JMI_DER_CAD) {
        return  jmi_func_cad_dF(jmi, jmi->dae->F, sparsity,
                independent_vars, mask, jac);
    } else if (eval_alg & JMI_DER_FD) {
        return jmi_func_fd_dF(jmi, jmi->dae->F, sparsity,
                independent_vars, mask, jac);
    } else {
        return -1;
    }
}

int jmi_dae_dF_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_n_nz(jmi, jmi->dae->F, n_nz);
    } else if (eval_alg & JMI_DER_CAD) {
        return jmi_func_cad_dF_n_nz(jmi, jmi->dae->F, n_nz);
    } else if(eval_alg & JMI_DER_FD) {
        return jmi_func_fd_dF_n_nz(jmi, jmi->dae->F, n_nz);
    } else {
        return -1;
    }
}

int jmi_dae_dF_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_nz_indices(jmi, jmi->dae->F, independent_vars, mask, row, col);
    } else if (eval_alg & JMI_DER_CAD) {
        return jmi_func_cad_dF_nz_indices(jmi, jmi->dae->F, independent_vars, mask, row, col);
    } else if (eval_alg & JMI_DER_FD) {
        return jmi_func_fd_dF_nz_indices(jmi, jmi->dae->F, independent_vars, mask, row, col);
    } else {
        return -1;
    }

}

int jmi_dae_dF_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);
    } else if (eval_alg & JMI_DER_CAD) {
        return jmi_func_cad_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);
    } else if (eval_alg & JMI_DER_FD) {
        return jmi_func_fd_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);
    } else {
        return -1;
    }

}

int jmi_dae_directional_dF(jmi_t* jmi, int eval_alg, jmi_real_t* res, jmi_real_t* dF, jmi_real_t* dz) {
    
    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_directional_dF(jmi, jmi->dae->F, res, dF, dz);
    } else if (eval_alg & JMI_DER_CAD) {
        return jmi_func_cad_directional_dF(jmi, jmi->dae->F, res, dF, dz);
    } else if (eval_alg & JMI_DER_FD) {
        return jmi_func_fd_directional_dF(jmi, jmi->dae->F, res, dF, dz);
    } else{
        return -1;
    }
}

int jmi_dae_R(jmi_t* jmi, jmi_real_t* res) {

    /*jmi->dae->F->F(jmi, &res);*/
    jmi_func_F(jmi,jmi->dae->R,res);

    return 0;
}

int jmi_dae_R_perturbed(jmi_t* jmi, jmi_real_t* res){
    int retval,i;
    jmi_real_t *switches;
    
    retval = jmi_dae_R(jmi,res);
    if (retval!=0){return -1;}
    
    switches = jmi_get_sw(jmi);
    
    for (i = 0; i < jmi->n_sw; i=i+1){
        if (switches[i] == 1.0){
            if (jmi->relations[i] == JMI_REL_GEQ){
                res[i] = res[i]+jmi->events_epsilon;
            }else if (jmi->relations[i] == JMI_REL_LEQ){
                res[i] = res[i]-jmi->events_epsilon;
            }else{
                res[i] = res[i];
            }
        }else{
            if (jmi->relations[i] == JMI_REL_GT){
                res[i] = res[i]-jmi->events_epsilon;
            }else if (jmi->relations[i] == JMI_REL_LT){
                res[i] = res[i]+jmi->events_epsilon;
            }else{
                res[i] = res[i];
            }
        }
    }
    return 0;
}

int jmi_init_F0(jmi_t* jmi, jmi_real_t* res) {
    
    return jmi_func_F(jmi,jmi->init->F0,res);
}

int jmi_init_dF0(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF(jmi, jmi->init->F0, sparsity,
                independent_vars, mask, jac) ;
    } else {
        return -1;
    }
}

int jmi_init_dF0_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_n_nz(jmi, jmi->init->F0, n_nz);
    } else {
        return -1;
    }
}

int jmi_init_dF0_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_nz_indices(jmi, jmi->init->F0, independent_vars, mask, row, col);
    } else {
        return -1;
    }

}

int jmi_init_dF0_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_dim(jmi, jmi->init->F0, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);
    } else {
        return -1;
    }

}


int jmi_init_F1(jmi_t* jmi, jmi_real_t* res) {

    return jmi_func_F(jmi,jmi->init->F1,res);

}

int jmi_init_dF1(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF(jmi, jmi->init->F1, sparsity,
                independent_vars, mask, jac) ;
    } else {
        return -1;
    }
}

int jmi_init_dF1_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_n_nz(jmi, jmi->init->F1, n_nz);
    } else {
        return -1;
    }
}

int jmi_init_dF1_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_nz_indices(jmi, jmi->init->F1, independent_vars, mask, row, col);
    } else {
        return -1;
    }

}

int jmi_init_dF1_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_dim(jmi, jmi->init->F1, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);
    } else {
        return -1;
    }
}

int jmi_init_Fp(jmi_t* jmi, jmi_real_t* res) {

    return jmi_func_F(jmi,jmi->init->Fp,res);

}

int jmi_init_dFp(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {
    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF(jmi, jmi->init->Fp, sparsity,
                independent_vars, mask, jac) ;
    } else {
        return -1;
    }
}

int jmi_init_dFp_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_n_nz(jmi, jmi->init->Fp, n_nz);
    } else {
        return -1;
    }
}

int jmi_init_dFp_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {

    if (eval_alg & JMI_DER_SYMBOLIC) {
        return jmi_func_sym_dF_nz_indices(jmi, jmi->init->Fp, independent_vars, mask, row, col);
    } else {
        return -1;
    }

}

int jmi_init_dFp_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->init->Fp, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);
    } else {
        return -1;
    }
}

int jmi_init_eval_parameters(jmi_t* jmi) {

    int return_status;

    return_status = jmi_generic_func(jmi, jmi->init->eval_parameters);

    return return_status;
}

int jmi_init_R0(jmi_t* jmi, jmi_real_t* res) {

    /*jmi->dae->F->F(jmi, &res);*/
    jmi_func_F(jmi,jmi->init->R0,res);

    return 0;
}
