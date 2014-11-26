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


/**
 *
 * This is the second draft of an interface to CppAD. The interface supports computation
 * of Jacobians and sparsity patterns on the form required by Ipopt.
 *
 * Usage:
 *    The AD struct jmi_func_ad_t contains all the tapes and data structures
 *    associated with CppAD. These structs are initialized in the function jmi_ad_init. In this step
 *    all the tapes and the sparsity patterns are computed and cached. This requires
 *    actual values (sensible values, ideally...) are provided for all the independent
 *    variables in the z vector. Such values may originate from XML data or solution of an initial system.
 *    Therefore it is reasonable that this function is called from outside of the the generated
 *    code.
 *
 * Current limitations:
 *   - Memory is copied at several locations form double* vectors to vector<AD>
 *     objects. This may be a bit inefficient - but how can it be avoided?
 *   - Work-vectors. New objects are created at each function call. It may make
 *     sense to allocate work vectors and save them between calls.
 *
 */

#include <time.h>
#include "jmi.h"
#include "jmi_log.h"

int jmi_init(jmi_t** jmi, int n_real_ci, int n_real_cd, int n_real_pi,
        int n_real_pd, int n_integer_ci, int n_integer_cd,
        int n_integer_pi, int n_integer_pd,int n_boolean_ci, int n_boolean_cd,
        int n_boolean_pi, int n_boolean_pd, int n_string_ci, int n_string_cd,
        int n_string_pi, int n_string_pd,
        int n_real_dx, int n_real_x, int n_real_u, int n_real_w,
        int n_tp,int n_real_d,
        int n_integer_d, int n_integer_u,
        int n_boolean_d, int n_boolean_u,
        int n_string_d, int n_string_u,
        int n_outputs, int* output_vrefs,
        int n_sw, int n_sw_init, int n_time_sw, int n_state_sw,
        int n_guards, int n_guards_init,
        int n_dae_blocks, int n_dae_init_blocks,
        int n_initial_relations, int* initial_relations,
        int n_relations, int* relations,
        int scaling_method, int n_ext_objs) {

    // Create jmi struct
    *jmi = (jmi_t*)calloc(1,sizeof(jmi_t));
    jmi_t* jmi_ = *jmi;
    // Set struct pointers in jmi
    jmi_->dae = NULL;
    jmi_->init = NULL;
    jmi_->opt = NULL;

    // Set sizes of dae vectors
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

    jmi_->n_tp = n_tp;

    jmi_->n_real_d = n_real_d;

    jmi_->n_integer_d = n_integer_d;
    jmi_->n_integer_u = n_integer_u;

    jmi_->n_boolean_d = n_boolean_d;
    jmi_->n_boolean_u = n_boolean_u;

    jmi_->n_string_d = n_string_d;
    jmi_->n_string_u = n_string_u;

    jmi_->n_outputs = n_outputs;
    jmi_->output_vrefs = (int*)calloc(n_outputs,sizeof(int));
    for (int i=0;i<n_outputs;i++) {
        jmi_->output_vrefs[i] = output_vrefs[i];
    }

    jmi_->n_sw = n_sw;
    jmi_->n_sw_init = n_sw_init;

    jmi_->n_guards = n_guards;
    jmi_->n_guards_init = n_guards_init;

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

    jmi_->offs_real_dx_p = jmi_->offs_t + (n_tp>0? 1: 0);
    jmi_->offs_real_x_p = jmi_->offs_real_dx_p + (n_tp>0? n_real_dx: 0);
    jmi_->offs_real_u_p = jmi_->offs_real_x_p + (n_tp>0? n_real_x: 0);
    jmi_->offs_real_w_p = jmi_->offs_real_u_p + (n_tp>0? n_real_u: 0);

    jmi_->offs_real_d = jmi_->offs_t + 1 + (n_real_dx + n_real_x + n_real_w + n_real_u)*n_tp;

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

    jmi_->offs_p = 0;
    jmi_->offs_v = jmi_->offs_real_dx;
    if (n_tp>0) {
        jmi_->offs_q = jmi_->offs_t + 1;
    } else {
        jmi_->offs_q = jmi_->offs_t;
    }

    jmi_->n_p = jmi_->offs_real_dx;
    jmi_->n_v = n_real_dx + n_real_x + n_real_u + n_real_w + 1;
    jmi_->n_q = (n_real_dx + n_real_x + n_real_u + n_real_w)*n_tp;
    jmi_->n_d = n_real_d + n_integer_d + n_integer_u + n_boolean_d +
        n_boolean_u;

    jmi_->n_z = jmi_->n_p + 2*(jmi_->n_v) - 1 + jmi_->n_q + 2*jmi_->n_d + 2*n_sw +
            2*n_sw_init + 2*n_guards + 2*n_guards_init;

    jmi_->z = new jmi_ad_var_vec_t(jmi_->n_z);
    //jmi_->pre_z = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t ));

    jmi_->z_val = (jmi_real_t**)calloc(1,sizeof(jmi_real_t *));
    *(jmi_->z_val) =  (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));

    jmi_->variable_scaling_factors = (jmi_real_t*)calloc(jmi_->n_z,sizeof(jmi_real_t));
    jmi_->scaling_method = JMI_SCALING_NONE;

    int i;
    for (i=0;i<jmi_->n_z;i++) {
        jmi_->variable_scaling_factors[i] = 1.0;
        (*(jmi_->z))[i] = 0;
        (*(jmi_->z_val))[i] = 0;
    }

    jmi_->tp = (jmi_real_t*)calloc(jmi_->n_tp,sizeof(jmi_real_t));

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

    jmi_->atEvent = JMI_FALSE;
    jmi_->atInitial = JMI_FALSE;

    jmi_->log = jmi_log_init(jmi_);
    
    jmi_->terminate = 0;

    return 0;
}

// This is convenience function that is used to initialize the ad of one jmi_func_t.
int jmi_func_ad_init(jmi_t *jmi, jmi_func_t *func) {

    int i,j;

    jmi_func_ad_t* jf_ad_F = (jmi_func_ad_t*)calloc(1,sizeof(jmi_func_ad_t));
    func->ad = jf_ad_F;

    func->ad->F_z_dependent = new jmi_ad_var_vec_t(func->n_eq_F);

    // Compute the tape for all variables.
    // The z vector is assumed to be initialized previously by the user

    // Copy user's value into jmi->z
    for (i=0;i<jmi->n_z;i++) {
        (*(jmi->z))[i] = (*(jmi->z_val))[i];
    }

    {
        jmi_set_current(jmi);
        if (jmi_try(jmi)) {
            jmi_set_current(NULL);
            return -1;
        }        

        CppAD::Independent(*jmi->z);

        if (func->F(jmi, func->ad->F_z_dependent)!=0) {
            jmi_set_current(NULL);
            return -1;
        }

        func->ad->F_z_tape = new jmi_ad_tape_t(*jmi->z,*func->ad->F_z_dependent);

        // This should conclude the call to generated code
        jmi_set_current(NULL);
    }

    func->ad->tape_initialized = true;

    // Compute sparsity patterns
    int m = func->n_eq_F; // Number of rows in Jacobian

    // This matrix may become very large. May be necessary
    // to split the computation.
    std::vector<bool> r_z(jmi->n_z*jmi->n_z);
    std::vector<bool> s_z(m*jmi->n_z);
    for (i=0;i<jmi->n_z;i++) {
        for (j=0;j<jmi->n_z;j++) {
            if(i==j) {
                r_z[i*jmi->n_z+j] = true;
            } else{
                r_z[i*jmi->n_z+j] = false;
            }
        }
    }

    // Compute the sparsity pattern
    s_z = func->ad->F_z_tape->ForSparseJac(jmi->n_z,r_z);
/*
    func->ad->dF_z_n_nz = 0;
    func->ad->dF_ci_n_nz = 0;
    func->ad->dF_cd_n_nz = 0;
    func->ad->dF_pi_n_nz = 0;
    func->ad->dF_pd_n_nz = 0;
    func->ad->dF_dx_n_nz = 0;
    func->ad->dF_x_n_nz = 0;
    func->ad->dF_u_n_nz = 0;
    func->ad->dF_w_n_nz = 0;
    func->ad->dF_t_n_nz = 0;
    func->ad->dF_dx_p_n_nz = 0;
    func->ad->dF_x_p_n_nz = 0;
    func->ad->dF_u_p_n_nz = 0;
    func->ad->dF_w_p_n_nz = 0;
*/

    // Sort out all the individual variable vector sparsity patterns as well..
    for (i=0;i<(int)s_z.size();i++) { // cast to int since size() gives unsigned int...
        if (s_z[i]) {
            func->ad->dF_z_n_nz++;
        }
    }

    func->ad->dF_z_row = (int*)calloc(func->ad->dF_z_n_nz,sizeof(int));
    func->ad->dF_z_col = (int*)calloc(func->ad->dF_z_n_nz,sizeof(int));
    func->ad->dF_z_col_start_index = (int*)calloc(jmi->n_z,sizeof(int));
    func->ad->dF_z_col_n_nz = (int*)calloc(jmi->n_z,sizeof(int));

    int jac_ind = 0;
    int col_ind = 0;

    /*
     * This is a bit tricky. The sparsity matrices s_nn are represented
     * as vectors in row major format. In the row col representation it
     * is more convenient give the elements in column major order. In particular
     * it simplifies the implementation of the Jacobian evaluation.
     *
     */

    for (j=0;j<jmi->n_z;j++) {
        func->ad->dF_z_col_n_nz[j] = 0;
    }
    
    for (j=0;j<jmi->n_z;j++) {
        for (i=0;i<m;i++) {
            if (s_z[i*jmi->n_z + j]) {
                func->ad->dF_z_col[jac_ind] = j + col_ind + 1;
                func->ad->dF_z_row[jac_ind++] = i + 1;
                func->ad->dF_z_col_n_nz[func->ad->dF_z_col[jac_ind-1]-1]++;
            }
        }
    }
    
    func->ad->dF_z_col_start_index[0] = 0;
    for (j=1;j<jmi->n_z;j++) {
            func->ad->dF_z_col_start_index[j] = func->ad->dF_z_col_start_index[j-1] + func->ad->dF_z_col_n_nz[j-1];
    }

    func->ad->z_work = new jmi_real_vec_t(jmi->n_z);

    func->ad->exec_time = 0;

    jmi_new_simple_color_info(&(func->ad->color_info),
            jmi->n_z,
            2*jmi->n_real_dx + jmi->n_real_w + jmi->n_real_u, func->ad->dF_z_n_nz,
            func->ad->dF_z_row, func->ad->dF_z_col,
            jmi->offs_real_dx, 1);

    compute_cpr_groups(func->ad->color_info);

    return 0;
}

// Convenience function to evaluate the function contained in a
// jmi_func_t struct by means of AD.
int jmi_func_ad_F(jmi_t *jmi, jmi_func_t *func, jmi_real_t* res) {

    int i;

    if (func->n_eq_F==0) {
        return 0;
    }

    for (i=0;i<jmi->n_z;i++) {
        (*(func->ad->z_work))[i] = (*(jmi->z_val))[i];
    }

    jmi_real_vec_t res_w = func->ad->F_z_tape->Forward(0,*func->ad->z_work);

    for(i=0;i<func->n_eq_F;i++) {
        res[i] = res_w[i];
    }

    return 0;

}

int jmi_func_F(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res) {
    return jmi_func_ad_F(jmi,func, res);
}

int jmi_func_cad_directional_dF(jmi_t *jmi, jmi_func_t *func, jmi_real_t *res,
             jmi_real_t *dF, jmi_real_t* dv) {

        return -1;

}

// Convenience function for accessing the number of non-zeros in the AD
// Jacobian.
int jmi_func_ad_dF_n_nz(jmi_t *jmi, jmi_func_t *func, int* n_nz) {

    if (func->ad==NULL) {
        *n_nz = 0;
        return -1;
    }
    *n_nz = func->ad->dF_z_n_nz;
    return 0;

}

// Convenience function of accessing the non-zeros in the AD Jacobian
int jmi_func_ad_dF_nz_indices(jmi_t *jmi, jmi_func_t *func, int independent_vars,
        int *mask, int *row, int *col) {
    if (func->ad==NULL) {
        return -1;
    }
    int i;

    int index = 0;               // Index in the row/col vectors of the new Jacobian

    // Iterate over all non-zero indices
    for (i=0;i<func->ad->dF_z_n_nz;i++) {
//      printf("%d %d\n",i,jmi_check_Jacobian_column_index(jmi, independent_vars, mask, func->dF_col[i]-1));
        // Check if this particular entry should be included
        if (jmi_check_Jacobian_column_index(jmi, independent_vars, mask, func->ad->dF_z_col[i]-1) == 1 ) {
                // Copy indices
                row[index] = func->ad->dF_z_row[i];
                col[index] = jmi_map_Jacobian_column_index(jmi,independent_vars,mask,func->ad->dF_z_col[i]-1) + 1;
                index++;
        }
    }
    return 0;
}

// Convenience function for computing the dimensions of an AD Jacobian.
int jmi_func_ad_dF_dim(jmi_t *jmi, jmi_func_t *func, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {

    *dF_n_cols = 0;
    *dF_n_nz = 0;

    if (func->ad==NULL) {
        return -1;
    }

    int i;
    for (i=0;i<jmi->n_z;i++) {
        if (jmi_check_Jacobian_column_index(jmi, independent_vars, mask, i) == 1 ) {
            (*dF_n_cols)++;
        }
    }

    if (sparsity == JMI_DER_SPARSE) {
        for (i=0;i<func->ad->dF_z_n_nz;i++) {
            // Check if this particular entry should be included
            if (jmi_check_Jacobian_column_index(jmi, independent_vars, mask, func->ad->dF_z_col[i]-1) == 1 ) {
                (*dF_n_nz)++;
            }
        }
    } else {
        *dF_n_nz = *dF_n_cols*func->n_eq_F;
    }
    return 0;

}

// Convenience function to evaluate the Jacobian of the function contained in a
// jmi_func_t struct by means of AD.
int jmi_func_ad_dF(jmi_t *jmi,jmi_func_t *func, int sparsity,
        int independent_vars, int* mask, jmi_real_t* jac) {

    clock_t start = clock();

    int use_cpr_compression = 0;

    if (func->ad==NULL) {
        return -1;
    }

    if (func->n_eq_F==0) {
        return 0;
    }

    int i,j,k;

    for (i=0;i<jmi->n_z;i++) {
        (*(func->ad->z_work))[i] = (*(jmi->z_val))[i];
    }

    int jac_index = 0;
    int jac_n = func->n_eq_F;

    int jac_m;
    int jac_n_nz;
    jmi_func_ad_dF_dim(jmi,func,sparsity,independent_vars,mask,&jac_m,&jac_n_nz);

    //  printf("****** %d\n",jac_m);

    jmi_real_vec_t jac_(func->n_eq_F);
    jmi_real_vec_t d_z(jmi->n_z);

    for (j=0;j<jmi->n_z;j++) {
        d_z[j] = 0;
    }

    // Evaluate the tape for the current z-values
    func->ad->F_z_tape->Forward(0,*func->ad->z_work);

    // Set Jacobian to zero if dense evaluation.
    if ((sparsity & JMI_DER_DENSE_ROW_MAJOR) | (sparsity & JMI_DER_DENSE_COL_MAJOR)) {
        for (i=0;i<jac_n*jac_m;i++) {
            jac[i] = 0;
        }
    }

    //printf("-- %d \n",independent_vars);
    // Check if evaluation wrt dx, x, w and u - if so, use CPR seeding
    if (independent_vars == (JMI_DER_DX | JMI_DER_X | JMI_DER_W | JMI_DER_U) && sparsity==JMI_DER_SPARSE) {
        use_cpr_compression = 1;
        //printf("Hepp\n");
    }

    if (use_cpr_compression==1) {
        //printf("***********start***************\n");
        // Loop over all groups
        for (i=0;i<func->ad->color_info->n_groups;i++) {
            //printf("-------------start %d --------------\n", i);
            // Set the seed vector
            for (j=0;j<func->ad->color_info->n_cols_in_group[i];j++) {
                d_z[func->ad->color_info->group_cols[func->ad->color_info->group_start_index[i] + j]] = 1.;
            }
            /*
            for (j=0;j<jmi->n_z;j++) {
                printf(" * %d %f\n",j,d_z[j]);
            }*/
            // Evaluate directional derivative
            jac_ = func->ad->F_z_tape->Forward(1,d_z);
            // Extract Jacobian values
            for (j=0;j<func->ad->color_info->n_cols_in_group[i];j++) {
                for (k=func->ad->dF_z_col_start_index[func->ad->color_info->group_cols[func->ad->color_info->group_start_index[i] + j]];
                        k<func->ad->dF_z_col_start_index[func->ad->color_info->group_cols[func->ad->color_info->group_start_index[i] + j]]+func->ad->dF_z_col_n_nz[func->ad->color_info->group_cols[func->ad->color_info->group_start_index[i] + j]];
                        k++) {
                    jac[k-func->ad->dF_z_col_start_index[jmi->offs_real_dx]] = jac_[func->ad->dF_z_row[k]-1];
                }
            }
            // Reset seed vector
            for (j=0;j<func->ad->color_info->n_cols_in_group[i];j++) {
                d_z[func->ad->color_info->group_cols[func->ad->color_info->group_start_index[i] + j]] = 0.;
            }
        }
        //printf("-------------end------------\n");
    } else {

    // Iterate over all columns
    int q;
    for (i=0;i<jmi->n_z;i++) {
        if (jmi_check_Jacobian_column_index(jmi, independent_vars, mask, i) == 1 ) {
            //printf("Jopp %d\n",i);
            // Evaluate jacobian for column i
            d_z[i] = 1.;
            jac_ = func->ad->F_z_tape->Forward(1,d_z);
            d_z[i] = 0.;
            switch (sparsity) {
            case JMI_DER_DENSE_COL_MAJOR:
                q = jmi_map_Jacobian_column_index(jmi,independent_vars,mask,i);
                for(j=0;j<func->n_eq_F;j++) {
                    jac[jac_n*q + j] = jac_[j];
                }
                break;
            case JMI_DER_DENSE_ROW_MAJOR:
                q = jmi_map_Jacobian_column_index(jmi,independent_vars,mask,i);
                for(j=0;j<func->n_eq_F;j++) {
                    jac[jac_m*j + q] = jac_[j];
                }
                break;
            case JMI_DER_SPARSE:
                // TODO: This may be a bit inefficient?
                //printf("Jepp %d\n",func->ad->dF_z_n_nz);

                for (j=func->ad->dF_z_col_start_index[i];
                     j<func->ad->dF_z_col_start_index[i]+func->ad->dF_z_col_n_nz[i];
                     j++) {
                    jac[jac_index++] = jac_[func->ad->dF_z_row[j]-1];
                }
            }
        }
    }
    }

    clock_t end = clock();

    func->ad->exec_time += (int)(end-start);
    //printf("%d,%d, %d\n",(int)CLOCKS_PER_SEC,func->ad->exec_time,(int)(end-start));

    return 0;
}

int jmi_ad_init(jmi_t* jmi) {

    if (jmi->dae!=NULL) {
        int n_eq_F, n_eq_R;
        jmi_dae_get_sizes(jmi,&n_eq_F, &n_eq_R);
        if (n_eq_F>0) {
          if (jmi_func_ad_init(jmi, jmi->dae->F)!=0) {
            return -1;
          }
        }
        if (n_eq_R>0) {
          if (jmi_func_ad_init(jmi, jmi->dae->R)!=0) {
            return -1;
          }
        }
    }

    if (jmi->init!=NULL) {
        int n_eq_F0, n_eq_F1, n_eq_Fp, n_eq_R0;
        jmi_init_get_sizes(jmi,&n_eq_F0,&n_eq_F1,&n_eq_Fp,&n_eq_R0);
        if (n_eq_F0>0) {
          if (jmi_func_ad_init(jmi, jmi->init->F0)!=0) {
            return -1;
          }
        }
        if (n_eq_F1>0) {
          if (jmi_func_ad_init(jmi, jmi->init->F1)!=0) {
            return -1;
          }
        }
        if (n_eq_Fp>0) {
          if (jmi_func_ad_init(jmi, jmi->init->Fp)!=0) {
            return -1;
          }
        }
        if (n_eq_R0>0) {
          if (jmi_func_ad_init(jmi, jmi->init->R0)!=0) {
            return -1;
          }
        }
    }
    if (jmi->opt!=NULL) {
        int n_eq_J, n_eq_L, n_eq_Ffdp, n_eq_Ceq, n_eq_Cineq, n_eq_Heq, n_eq_Hineq;
        jmi_opt_get_sizes(jmi, &n_eq_J, &n_eq_L, &n_eq_Ffdp, &n_eq_Ceq, &n_eq_Cineq,
                &n_eq_Heq, &n_eq_Hineq);

        if (n_eq_Ffdp>0) {
          if (jmi_func_ad_init(jmi,jmi->opt->Ffdp)!=0) {
            return -1;
          }
        }

        if (n_eq_J>0) {
          if (jmi_func_ad_init(jmi,jmi->opt->J)!=0) {
            return -1;
          }
        }

        if (n_eq_L>0) {
          if (jmi_func_ad_init(jmi,jmi->opt->L)!=0) {
            return -1;
          }
        }

        if (n_eq_Ceq>0) {
          if (jmi_func_ad_init(jmi,jmi->opt->Ceq)!=0) {
            return -1;
          }
        }
        if (n_eq_Cineq>0) {
          if (jmi_func_ad_init(jmi,jmi->opt->Cineq)!=0) {
            return -1;
          }
        }
        if (n_eq_Heq>0) {
          if (jmi_func_ad_init(jmi,jmi->opt->Heq)!=0) {
            return -1;
          }
        }
        if (n_eq_Hineq>0) {
          if (jmi_func_ad_init(jmi,jmi->opt->Hineq)!=0) {
            return -1;
          }
        }
    }

    return 0;
}
int jmi_func_ad_delete(jmi_func_ad_t *jfa) {

    delete jfa->F_z_dependent;
    delete jfa->F_z_tape;

    free(jfa->dF_z_row);
    free(jfa->dF_z_col);
    free(jfa->dF_z_col_start_index);
    free(jfa->dF_z_col_n_nz);
    jmi_delete_simple_color_info(&jfa->color_info);


/*
    free(jfa->dF_ci_row);
    free(jfa->dF_ci_col);
    free(jfa->dF_cd_row);
    free(jfa->dF_cd_col);
    free(jfa->dF_pi_row);
    free(jfa->dF_pi_col);
    free(jfa->dF_pd_row);
    free(jfa->dF_pd_col);
    free(jfa->dF_dx_row);
    free(jfa->dF_dx_col);
    free(jfa->dF_x_row);
    free(jfa->dF_x_col);
    free(jfa->dF_u_row);
    free(jfa->dF_u_col);
    free(jfa->dF_w_row);
    free(jfa->dF_w_col);
    free(jfa->dF_t_row);
    free(jfa->dF_t_col);
    free(jfa->dF_dx_p_row);
    free(jfa->dF_dx_p_col);
    free(jfa->dF_x_p_row);
    free(jfa->dF_x_p_col);
    free(jfa->dF_u_p_row);
    free(jfa->dF_u_p_col);
    free(jfa->dF_w_p_row);
    free(jfa->dF_w_p_col);
    */
    delete jfa->z_work;
    free(jfa);

    return 0;
}

int jmi_delete(jmi_t* jmi){
    int i;
    if(jmi->dae != NULL) {
        if (jmi->dae->F->ad != NULL) {
            jmi_func_ad_delete(jmi->dae->F->ad);
        }
        jmi_func_delete(jmi->dae->F);
                jmi_func_delete(jmi->dae->R);
                free(jmi->dae);
                jmi->dae = 0;
    }
        if(jmi->init != NULL) {
                if (jmi->init->F0->ad != NULL) {
                        jmi_func_ad_delete(jmi->init->F0->ad);
                }
                if (jmi->init->F1->ad != NULL) {
                        jmi_func_ad_delete(jmi->init->F1->ad);
                }
                if (jmi->init->Fp->ad != NULL) {
                        jmi_func_ad_delete(jmi->init->Fp->ad);
                }
                jmi_delete_init(&(jmi->init));
        }

        if(jmi->opt != NULL) {
        if (jmi->opt->Ffdp->ad != NULL) {
            jmi_func_ad_delete(jmi->opt->Ffdp->ad);
        }
        if (jmi->opt->J->ad != NULL) {
            jmi_func_ad_delete(jmi->opt->J->ad);
        }
        if (jmi->opt->L->ad != NULL) {
            jmi_func_ad_delete(jmi->opt->L->ad);
        }
        if (jmi->opt->Ceq->ad != NULL) {
            jmi_func_ad_delete(jmi->opt->Ceq->ad);
        }
        if (jmi->opt->Cineq->ad != NULL) {
            jmi_func_ad_delete(jmi->opt->Cineq->ad);
        }
        if (jmi->opt->Heq->ad != NULL) {
            jmi_func_ad_delete(jmi->opt->Heq->ad);
        }
        if (jmi->opt->Hineq->ad != NULL) {
            jmi_func_ad_delete(jmi->opt->Hineq->ad);
        }
        jmi_func_delete(jmi->opt->Ffdp);
        jmi_func_delete(jmi->opt->J);
        jmi_func_delete(jmi->opt->L);
        jmi_func_delete(jmi->opt->Ceq);
        jmi_func_delete(jmi->opt->Cineq);
        jmi_func_delete(jmi->opt->Heq);
        jmi_func_delete(jmi->opt->Hineq);
        free(jmi->opt);
    }
        
#if 0
        /* NO block_residual are possible */ 
    for (i=0; i < jmi->n_dae_init_blocks;i=i+1){ /*Deallocate init BLT blocks.*/
        jmi_delete_block_residual(jmi->dae_init_block_residuals[i]);
    }
    for (i=0; i < jmi->n_dae_blocks;i=i+1){ /*Deallocate BLT blocks.*/
        jmi_delete_block_residual(jmi->dae_block_residuals[i]);
    }
#endif
    
    free(jmi->output_vrefs);
    delete jmi->z;
    free(*(jmi->z_val));
    free(jmi->z_val);
    //free(jmi->pre_z);
    free(jmi->tp);
    free(jmi->variable_scaling_factors);
    free(jmi->initial_relations);
    free(jmi->relations);
    free(jmi);

    return 0;
}

int jmi_ode_derivatives(jmi_t* jmi) {
    return 0;
}

int jmi_ode_derivatives_dir_der(jmi_t* jmi, jmi_real_t* dv) {
    return 0;
}

int jmi_ode_outputs(jmi_t* jmi) {
    return 0;
}

int jmi_ode_initialize(jmi_t* jmi) {
    return 0;
}

int jmi_ode_guards(jmi_t* jmi) {
    return 0;
}

int jmi_ode_guards_init(jmi_t* jmi) {
    return 0;
}

int jmi_ode_next_time_event(jmi_t* jmi, jmi_real_t* nextTime) {
    return 0;
}

jmi_ad_var_t jmi_sample(jmi_t* jmi, jmi_real_t offset, jmi_real_t h) {

    /* TODO: JMI_FLOOR is yet to be defined. Once done, this function can be
             moved to jmi_common.c
    printf("jmi_sample: %f\n",COND_EXP_EQ(LOG_EXP_OR(LOG_EXP_NOT(jmi->atEvent), SURELY_LT_ZERO(t-offset)),
                      JMI_TRUE, JMI_FALSE,
                      COND_EXP_EQ(ALMOST_ZERO(JMI_FLOOR((t-offset)/h)),JMI_TRUE,JMI_TRUE,JMI_FALSE)));
    */
    return 0;
}

int jmi_ode_f(jmi_t* jmi) {

    if (jmi->n_real_w != 0) { // Check if not ODE
        return -1;
    }

    int i;
    jmi_real_t* dx = jmi_get_real_dx(jmi);
    for(i=0;i<jmi->n_real_dx;i++) {
        dx[i]=0;
    }

    jmi_real_t* dx_res = (jmi_real_t*)calloc(jmi->n_real_x,sizeof(jmi_real_t));

    int ret_val = jmi_func_F(jmi,jmi->dae->F, dx_res);

    for(i=0;i<jmi->n_real_dx;i++) {
        dx[i]=dx_res[i];
    }

    free(dx_res);

    return ret_val;
}

int jmi_ode_df(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (jmi->n_real_w != 0) { // Check if not ODE
        return -1;
    }

    if (eval_alg & JMI_DER_SYMBOLIC) {

        int i;
        jmi_real_t* dx = jmi_get_real_dx(jmi);
        for(i=0;i<jmi->n_real_dx;i++) {
            dx[i]=0;
        }

        return jmi_func_sym_dF(jmi, jmi->dae->F, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        int i;
        jmi_real_t* dx = jmi_get_real_dx(jmi);
        for(i=0;i<jmi->n_real_dx;i++) {
            dx[i]=0;
        }


        return jmi_func_ad_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_ode_df_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {

    if (jmi->n_real_w != 0) { // Check if not ODE
        return -1;
    }

    if (eval_alg & JMI_DER_SYMBOLIC) {
           int df_n_cols;
            int* mask = (int*)calloc(jmi->n_z,sizeof(int));
            int i;
            for (i=0;i<jmi->n_z;i++) {
                mask[i] = 1;
            }
            int ret_val =  jmi_func_sym_dF_dim(jmi, jmi->dae->F, JMI_DER_SPARSE,
                   JMI_DER_ALL & (~JMI_DER_DX), mask,
                    &df_n_cols, n_nz);
            free(mask);
            return ret_val;

    } else if (eval_alg & JMI_DER_CPPAD) {
           int df_n_cols;
            int* mask = (int*)calloc(jmi->n_z,sizeof(int));
            int i;
            for (i=0;i<jmi->n_z;i++) {
                mask[i] = 1;
            }
            int ret_val =  jmi_func_ad_dF_dim(jmi, jmi->dae->F, JMI_DER_SPARSE,
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

    if (jmi->n_real_w != 0) { // Check if not ODE
        return -1;
    }

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->dae->F, independent_vars & (~JMI_DER_DX), mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->dae->F, independent_vars & (~JMI_DER_DX), mask, row, col);

    } else {
        return -1;
    }
}

int jmi_ode_df_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *df_n_cols, int *df_n_nz) {

    if (jmi->n_real_w != 0) { // Check if not ODE
        return -1;
    }

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars & (~JMI_DER_DX), mask,
                df_n_cols, df_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars & (~JMI_DER_DX), mask,
                df_n_cols, df_n_nz);

    } else {
        return -1;
    }
}


int jmi_dae_F(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->dae->F, res);
}

int jmi_dae_dF(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->dae->F, sparsity,
                independent_vars, mask, jac) ;
    } else if (eval_alg & JMI_DER_CAD) {
        /* TODO: Add code here */
        return 0;
    } else if (eval_alg & JMI_DER_FD) {
        /* TODO: Add code here */
        return 0;
    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_dae_dF_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->dae->F, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->dae->F, n_nz);

    } else {
        return -1;
    }
}

int jmi_dae_dF_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->dae->F, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->dae->F, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_dae_dF_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->dae->F, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}

int jmi_dae_directional_dF(jmi_t* jmi, int eval_alg, jmi_real_t* res, jmi_real_t* dF, jmi_real_t* dz) {
    return -1;
}


int jmi_dae_R(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->dae->R, res);
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
    return jmi_func_F(jmi,jmi->init->F0, res);
}

int jmi_init_dF0(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->init->F0, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {
        //printf("hej\n");
        return jmi_func_ad_dF(jmi,jmi->init->F0, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_init_dF0_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->init->F0, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->init->F0, n_nz);

    } else {
        return -1;
    }
}

int jmi_init_dF0_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->init->F0, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->init->F0, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_init_dF0_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->init->F0, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->init->F0, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}


int jmi_init_F1(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->init->F1, res);
}

int jmi_init_dF1(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->init->F1, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->init->F1, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_init_dF1_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->init->F1, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->init->F1, n_nz);

    } else {
        return -1;
    }
}

int jmi_init_dF1_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->init->F1, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->init->F1, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_init_dF1_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->init->F1, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->init->F1, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}

int jmi_init_Fp(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->init->Fp, res);
}

int jmi_init_dFp(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->init->Fp, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->init->Fp, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_init_dFp_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->init->Fp, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->init->Fp, n_nz);

    } else {
        return -1;
    }
}

int jmi_init_dFp_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->init->Fp, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->init->Fp, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_init_dFp_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->init->Fp, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->init->Fp, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}

int jmi_init_eval_parameters(jmi_t* jmi) {
    int i, return_status;

    for (i=0;i<jmi->n_z;i++) {
        (*(jmi->z))[i] = (*(jmi->z_val))[i];
    }

    return_status = jmi_generic_func(jmi, jmi->init->eval_parameters);

    // Write back evaluation result
    if (return_status==0) {
        /*for (i=0;i<jmi->n_z;i++) {
        *   (*(jmi->z_val))[i] = CppAD::Value(((*(jmi->z))[i]));
        *}
        */
        jmi_copy_z_to_zval(jmi);
        return 0;
    }
    return return_status;

}

int jmi_copy_z_to_zval(jmi_t* jmi) {
    int i;
    for (i=0;i<jmi->n_z;i++) {
        (*(jmi->z_val))[i] = CppAD::Value(((*(jmi->z))[i]));
    }
    return 0;
}

int jmi_init_R0(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->init->R0, res);
}

int jmi_opt_Ffdp(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->opt->Ffdp, res);
}

int jmi_opt_dFfdp(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->opt->Ffdp, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->opt->Ffdp, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_opt_dFfdp_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->opt->Ffdp, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->opt->Ffdp, n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_dFfdp_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->opt->Ffdp, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->opt->Ffdp, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_opt_dFfdp_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->opt->Ffdp, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {
        return jmi_func_ad_dF_dim(jmi, jmi->opt->Ffdp, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_J(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->opt->J, res);
}

int jmi_opt_dJ(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->opt->J, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->opt->J, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_opt_dJ_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->opt->J, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->opt->J, n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_dJ_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->opt->J, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->opt->J, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_opt_dJ_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dJ_n_cols, int *dJ_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->opt->J, sparsity, independent_vars, mask,
                dJ_n_cols, dJ_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->opt->J, sparsity, independent_vars, mask,
                dJ_n_cols, dJ_n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_L(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->opt->L, res);
}

int jmi_opt_dL(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->opt->L, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->opt->L, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_opt_dL_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->opt->L, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->opt->L, n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_dL_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->opt->L, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->opt->L, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_opt_dL_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dL_n_cols, int *dL_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->opt->L, sparsity, independent_vars, mask,
                dL_n_cols, dL_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->opt->L, sparsity, independent_vars, mask,
                dL_n_cols, dL_n_nz);

    } else {
        return -1;
    }
}


int jmi_opt_Ceq(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->opt->Ceq, res);
}

int jmi_opt_dCeq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->opt->Ceq, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->opt->Ceq, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_opt_dCeq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->opt->Ceq, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->opt->Ceq, n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_dCeq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->opt->Ceq, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->opt->Ceq, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_opt_dCeq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->opt->Ceq, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->opt->Ceq, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}


int jmi_opt_Cineq(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->opt->Cineq, res);
}

int jmi_opt_dCineq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->opt->Cineq, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->opt->Cineq, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_opt_dCineq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->opt->Cineq, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->opt->Cineq, n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_dCineq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->opt->Cineq, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->opt->Cineq, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_opt_dCineq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->opt->Cineq, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->opt->Cineq, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}


int jmi_opt_Heq(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->opt->Heq, res);
}

int jmi_opt_dHeq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->opt->Heq, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->opt->Heq, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_opt_dHeq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->opt->Heq, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->opt->Heq, n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_dHeq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->opt->Heq, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->opt->Heq, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_opt_dHeq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->opt->Heq, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->opt->Heq, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_Hineq(jmi_t* jmi, jmi_real_t* res) {
    return jmi_func_F(jmi,jmi->opt->Hineq, res);
}

int jmi_opt_dHineq(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int* mask, jmi_real_t* jac) {

    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF(jmi, jmi->opt->Hineq, sparsity,
                independent_vars, mask, jac) ;

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF(jmi,jmi->opt->Hineq, sparsity, independent_vars, mask, jac);

    } else {
        return -1;
    }
}

int jmi_opt_dHineq_n_nz(jmi_t* jmi, int eval_alg, int* n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_n_nz(jmi, jmi->opt->Hineq, n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_n_nz(jmi, jmi->opt->Hineq, n_nz);

    } else {
        return -1;
    }
}

int jmi_opt_dHineq_nz_indices(jmi_t* jmi, int eval_alg, int independent_vars,
        int *mask, int* row, int* col) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_nz_indices(jmi, jmi->opt->Hineq, independent_vars, mask, row, col);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_nz_indices(jmi, jmi->opt->Hineq, independent_vars, mask, row, col);

    } else {
        return -1;
    }
}

int jmi_opt_dHineq_dim(jmi_t* jmi, int eval_alg, int sparsity, int independent_vars, int *mask,
        int *dF_n_cols, int *dF_n_nz) {
    if (eval_alg & JMI_DER_SYMBOLIC) {

        return jmi_func_sym_dF_dim(jmi, jmi->opt->Hineq, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else if (eval_alg & JMI_DER_CPPAD) {

        return jmi_func_ad_dF_dim(jmi, jmi->opt->Hineq, sparsity, independent_vars, mask,
                dF_n_cols, dF_n_nz);

    } else {
        return -1;
    }
}

int jmi_with_cppad_derivatives()
{
    return JMI_AD_WITH_CPPAD;
}

// Array interface
#include "jmi_array_cppad.h"
#include "jmi_array_common.h"

jmi_dynamic_list::~jmi_dynamic_list() {
    delete next;
}
jmi_dynamic_list_arr::~jmi_dynamic_list_arr() {
    delete data;
}

jmi_ad_var_t jmi_array_val_1(jmi_array_t* arr, jmi_ad_var_t i1) {
    return (*(arr->var))[_JMI_ARR_I_1(arr, i1)];
}
jmi_ad_var_t jmi_array_val_2(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2) {
    return (*(arr->var))[_JMI_ARR_I_2(arr, i1, i2)];
}
jmi_ad_var_t jmi_array_val_3(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3) {
    return (*(arr->var))[_JMI_ARR_I_3(arr, i1, i2, i3)];
}
jmi_ad_var_t jmi_array_val_4(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4) {
    return (*(arr->var))[_JMI_ARR_I_4(arr, i1, i2, i3, i4)];
}
jmi_ad_var_t jmi_array_val_5(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5) {
    return (*(arr->var))[_JMI_ARR_I_5(arr, i1, i2, i3, i4, i5)];
}
jmi_ad_var_t jmi_array_val_6(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6) {
    return (*(arr->var))[_JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6)];
}
jmi_ad_var_t jmi_array_val_7(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7) {
    return (*(arr->var))[_JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7)];
}
jmi_ad_var_t jmi_array_val_8(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8) {
    return (*(arr->var))[_JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8)];
}
jmi_ad_var_t jmi_array_val_9(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9) {
    return (*(arr->var))[_JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9)];
}
jmi_ad_var_t jmi_array_val_10(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10) {
    return (*(arr->var))[_JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10)];
}
jmi_ad_var_t jmi_array_val_11(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11) {
    return (*(arr->var))[_JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11)];
}
jmi_ad_var_t jmi_array_val_12(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12) {
    return (*(arr->var))[_JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12)];
}
jmi_ad_var_t jmi_array_val_13(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13) {
    return (*(arr->var))[_JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13)];
}
jmi_ad_var_t jmi_array_val_14(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14) {
    return (*(arr->var))[_JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14)];
}
jmi_ad_var_t jmi_array_val_15(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15) {
    return (*(arr->var))[_JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15)];
}
jmi_ad_var_t jmi_array_val_16(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16) {
    return (*(arr->var))[_JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16)];
}
jmi_ad_var_t jmi_array_val_17(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17) {
    return (*(arr->var))[_JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17)];
}
jmi_ad_var_t jmi_array_val_18(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18) {
    return (*(arr->var))[_JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18)];
}
jmi_ad_var_t jmi_array_val_19(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19) {
    return (*(arr->var))[_JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19)];
}
jmi_ad_var_t jmi_array_val_20(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20) {
    return (*(arr->var))[_JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20)];
}
jmi_ad_var_t jmi_array_val_21(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21) {
    return (*(arr->var))[_JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21)];
}
jmi_ad_var_t jmi_array_val_22(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22) {
    return (*(arr->var))[_JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22)];
}
jmi_ad_var_t jmi_array_val_23(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23) {
    return (*(arr->var))[_JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23)];
}
jmi_ad_var_t jmi_array_val_24(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23, jmi_ad_var_t i24) {
    return (*(arr->var))[_JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24)];
}
jmi_ad_var_t jmi_array_val_25(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23, jmi_ad_var_t i24, jmi_ad_var_t i25) {
    return (*(arr->var))[_JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25)];
}

jmi_ad_array_ref_t jmi_array_ref_1(jmi_array_t* arr, jmi_ad_var_t i1) {
    return (*(arr->var))[_JMI_ARR_I_1(arr, i1)];
}
jmi_ad_array_ref_t jmi_array_ref_2(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2) {
    return (*(arr->var))[_JMI_ARR_I_2(arr, i1, i2)];
}
jmi_ad_array_ref_t jmi_array_ref_3(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3) {
    return (*(arr->var))[_JMI_ARR_I_3(arr, i1, i2, i3)];
}
jmi_ad_array_ref_t jmi_array_ref_4(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4) {
    return (*(arr->var))[_JMI_ARR_I_4(arr, i1, i2, i3, i4)];
}
jmi_ad_array_ref_t jmi_array_ref_5(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5) {
    return (*(arr->var))[_JMI_ARR_I_5(arr, i1, i2, i3, i4, i5)];
}
jmi_ad_array_ref_t jmi_array_ref_6(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6) {
    return (*(arr->var))[_JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6)];
}
jmi_ad_array_ref_t jmi_array_ref_7(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7) {
    return (*(arr->var))[_JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7)];
}
jmi_ad_array_ref_t jmi_array_ref_8(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8) {
    return (*(arr->var))[_JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8)];
}
jmi_ad_array_ref_t jmi_array_ref_9(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9) {
    return (*(arr->var))[_JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9)];
}
jmi_ad_array_ref_t jmi_array_ref_10(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10) {
    return (*(arr->var))[_JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10)];
}
jmi_ad_array_ref_t jmi_array_ref_11(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11) {
    return (*(arr->var))[_JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11)];
}
jmi_ad_array_ref_t jmi_array_ref_12(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12) {
    return (*(arr->var))[_JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12)];
}
jmi_ad_array_ref_t jmi_array_ref_13(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13) {
    return (*(arr->var))[_JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13)];
}
jmi_ad_array_ref_t jmi_array_ref_14(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14) {
    return (*(arr->var))[_JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14)];
}
jmi_ad_array_ref_t jmi_array_ref_15(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15) {
    return (*(arr->var))[_JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15)];
}
jmi_ad_array_ref_t jmi_array_ref_16(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16) {
    return (*(arr->var))[_JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16)];
}
jmi_ad_array_ref_t jmi_array_ref_17(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17) {
    return (*(arr->var))[_JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17)];
}
jmi_ad_array_ref_t jmi_array_ref_18(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18) {
    return (*(arr->var))[_JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18)];
}
jmi_ad_array_ref_t jmi_array_ref_19(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19) {
    return (*(arr->var))[_JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19)];
}
jmi_ad_array_ref_t jmi_array_ref_20(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20) {
    return (*(arr->var))[_JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20)];
}
jmi_ad_array_ref_t jmi_array_ref_21(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21) {
    return (*(arr->var))[_JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21)];
}
jmi_ad_array_ref_t jmi_array_ref_22(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22) {
    return (*(arr->var))[_JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22)];
}
jmi_ad_array_ref_t jmi_array_ref_23(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23) {
    return (*(arr->var))[_JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23)];
}
jmi_ad_array_ref_t jmi_array_ref_24(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23, jmi_ad_var_t i24) {
    return (*(arr->var))[_JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24)];
}
jmi_ad_array_ref_t jmi_array_ref_25(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23, jmi_ad_var_t i24, jmi_ad_var_t i25) {
    return (*(arr->var))[_JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25)];
}
