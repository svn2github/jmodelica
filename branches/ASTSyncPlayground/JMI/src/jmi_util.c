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
#include "fmi1_me.h"
#include "jmi.h"

int jmi_get_index_from_value_ref(int vref) {
    /* Translate a ValueReference into variable index in z-vector. */
    return vref & VREF_INDEX_MASK;
}

int jmi_get_type_from_value_ref(int vref) {
    /* Translate a ValueReference into variable type in z-vector. */
    return vref & VREF_TYPE_MASK;
}

/*This function has been used during debugging*/
int jmi_dae_directional_FD_dF(jmi_t* jmi, jmi_func_t *func, jmi_real_t *res, jmi_real_t* dF, jmi_real_t* dv) {
    jmi_real_t h = 0.0001;
    
    int n_p_opt;
    int n_eq;
    int n_eq_R;
    int i;
    int offs;

    jmi_real_t* dx;
    jmi_real_t* x;
    jmi_real_t* u;
    jmi_real_t* w;
    jmi_real_t* t;

    jmi_real_t* res1;
    jmi_real_t* res2;

    if(jmi->opt->n_p_opt != 0){
        jmi_opt_get_n_p_opt(jmi, &n_p_opt);
    } else{
        n_p_opt = 0;
    }
    
    dx = jmi_get_real_dx(jmi);
    x = jmi_get_real_x(jmi);
    u = jmi_get_real_u(jmi);
    w = jmi_get_real_w(jmi);
    t = jmi_get_t(jmi);
    

    jmi_dae_get_sizes(jmi, &n_eq, &n_eq_R);
    
    res1 = (jmi_real_t*)calloc(n_eq,sizeof(jmi_real_t));
    res2 = (jmi_real_t*)calloc(n_eq,sizeof(jmi_real_t));
    
    
    if(n_p_opt > 0){
        int *p_opt_indices = (int*)calloc(n_p_opt, sizeof(int));
        jmi_opt_get_p_opt_indices(jmi, p_opt_indices);
        for(i = 0; i < n_p_opt; i++){
            (*(jmi->z_val))[i] = (*(jmi->z_val))[i] + dv[i]*h;
        }
    }
    offs = n_p_opt;
    for (i=0;i<jmi->n_real_dx;i++) {
        dx[i] = dx[i] + dv[i+offs]*h;       
    }
    offs += jmi->n_real_dx;
    for (i=0;i<jmi->n_real_x;i++) {
        x[i] = x[i] + dv[i+offs]*h;
    }
    offs+=jmi->n_real_x;
    for (i=0;i<jmi->n_real_u;i++) {
        u[i] = u[i] + dv[i+offs]*h;
    }
    offs+=jmi->n_real_u;
    for (i=0;i<jmi->n_real_w;i++) {
        w[i] = w[i] + dv[i+offs]*h;
    }
    offs+=jmi->n_real_w;
    *t = *t + dv[offs]*h;
    
    for (i=0;i<jmi->n_z;i++) {
        (*(jmi->z))[i] = (*(jmi->z_val))[i];
    }
    
    jmi_func_F(jmi,jmi->dae->F, res1);
    
    if(n_p_opt > 0){
        int *p_opt_indices = (int*)calloc(n_p_opt, sizeof(int));
        jmi_opt_get_p_opt_indices(jmi, p_opt_indices);
        for(i = 0; i < n_p_opt; i++){
            (*(jmi->z_val))[i] = (*(jmi->z_val))[i] - 2*dv[i]*h;
        }
    }
    offs = n_p_opt;
    
    for (i=0;i<jmi->n_real_dx;i++) {
        dx[i] = dx[i] - 2*dv[i]*h;
    }
    offs += jmi->n_real_dx;
    for (i=0;i<jmi->n_real_x;i++) {
        x[i] = x[i] - 2*dv[i+offs]*h;
    }
    offs+=jmi->n_real_x;
    for (i=0;i<jmi->n_real_u;i++) {
        u[i] = u[i] - 2*dv[i+offs]*h;
    }
    offs+=jmi->n_real_u;
    for (i=0;i<jmi->n_real_w;i++) {
        w[i] = w[i] - 2*dv[i+offs]*h;
    }
    offs+=jmi->n_real_w;
    *t = *t - 2*dv[offs]*h;
    
    
    for (i=0;i<jmi->n_z;i++) {
        (*(jmi->z))[i] = (*(jmi->z_val))[i];
    }
    
    
    jmi_func_F(jmi, jmi->dae->F, res2);

    if(n_p_opt > 0){
        int *p_opt_indices = (int*)calloc(n_p_opt, sizeof(int));
        jmi_opt_get_p_opt_indices(jmi, p_opt_indices);
        for(i = 0; i < n_p_opt; i++){
            (*(jmi->z_val))[i] = (*(jmi->z_val))[i] + dv[i]*h;
        }
    }
    offs = n_p_opt;
    for (i=0;i<jmi->n_real_dx;i++) {
        dx[i] = dx[i] + dv[i]*h;
    }
    offs += jmi->n_real_dx;
    for (i=0;i<jmi->n_real_x;i++) {
        x[i] = x[i] + dv[i+offs]*h;
    }
    offs+=jmi->n_real_x;
    for (i=0;i<jmi->n_real_u;i++) {
        u[i] = u[i] + dv[i+offs]*h;
    }
    offs+=jmi->n_real_u;
    for (i=0;i<jmi->n_real_w;i++) {
        w[i] = w[i] + dv[i+offs]*h;
    }
    offs+=jmi->n_real_w;
    *t = *t + dv[offs]*h;
    
    for (i=0;i<jmi->n_z;i++) {
        (*(jmi->z))[i] = (*(jmi->z_val))[i];
    }
    
    for(i=0;i< n_eq;i++){
        dF[i] = (res1[i] -  res2[i])/(2*h);
    }
    
    free(res1);
    free(res2);
    
    return 0;
}

/*Performs graph coloring, sse documentation in function jmi_func_cad_df in jmi_common.c
for a description of the output parameter*/
int jmi_dae_cad_color_graph(jmi_t *jmi, jmi_func_t *func, int n_col, int n_nz, int *row, int *col, int *sparse_repr, int *offs, int *n_colors, int *map_info, int *map_off){
    int i;
    int j;
    int n_color = 0;
    
    int *inc_length =   (int*)calloc(n_col, sizeof(int));
    int *color      =   (int*)calloc(n_col, sizeof(int));
    int *numb_col   =   (int*)calloc(n_col, sizeof(int));
    int *row_off    =   (int*)calloc(n_col, sizeof(int));
    int **incidence_v;
    
    /*inc_length number of connections for every node (One column corresponds to one node)*/
    jmi_dae_cad_get_connection_length(n_col ,n_nz,row,col, inc_length);
    
    func->coloring_counter++;
    
    incidence_v = (int**)calloc(n_col, sizeof(int*));
    for(i = 0; i<n_col; i++){
        incidence_v[i] = (int*)calloc(inc_length[i], sizeof(int)); 
    }
    
    /*Creates a matrix that contains all connections for every node*/
    jmi_dae_cad_get_connections(n_col, n_nz,row,col, incidence_v, inc_length );
    
    /*Performs the graph coloring*/
    jmi_dae_cad_first_fit( n_col, incidence_v, inc_length, color, numb_col);

    /*Total number of colors*/
    for(i = 0; i < n_col;i++){
        if(n_color < color[i]){
            n_color = color[i];
        }
    }
    n_color++;
     
    j = 0;
    for(i = 0; i < n_nz; i++){
        if(col[i] == j){
            row_off[j] = i;
            j++;
        }
    }
    
    offs[0] = 0;
    for(i = 1; i < n_color; i++){
        offs[i] = numb_col[i-1] + offs[i-1];
    }
    for(i = 0; i< n_col; i++){
        sparse_repr[i] = -1;
    }
    
    /*Sets up the sparse_repr, map_info and map_off vectors*/ 
    jmi_dae_cad_get_compression_info(n_nz, row, row_off, n_col, color, sparse_repr, offs, numb_col, map_info, map_off);
    
    for(i = 0; i < n_col; i++){
        free(incidence_v[i]);
    }
    free(incidence_v);
    free(color);
    free(inc_length);
    free(numb_col);
    free(row_off);
    *n_colors = n_color;
    return 0;
}

int jmi_dae_cad_get_compression_info(int n_nz, int *row, int *row_off, int n_col, int *color, int *sparse_repr, int *offs, int *numb_color, int *map_info, int *map_off){
    int i;
    int j;
    int c;
    for(i = 0; i<n_col; i++){
        c = color[i];
        j = 0;
        while(j<numb_color[c]&&sparse_repr[offs[c]+j] != -1){
            j++;
        }
        sparse_repr[offs[c]+j] = i;
        if(i !=n_col-1){
            map_off[offs[c] + j] = row_off[i+1]-row_off[i];
        } else{
            map_off[offs[c] + j] = n_nz-row_off[i];
        }
    }
    
    map_off[n_col-1] = n_nz - map_off[n_col-1];
    
    for(i = n_col-2; i >= 0; i--){
        map_off[i] = map_off[i+1]-map_off[i];
    }
    
    for(i = 0; i < n_col-1; i++){
        for(j = map_off[i]; j < map_off[i+1]; j++){
            map_info[j] = row[row_off[sparse_repr[i]]+j - map_off[i]];                  
        }
    }
    
    for(j = map_off[n_col-1]; j < n_nz; j++){
        map_info[j] = row[row_off[sparse_repr[n_col-1]]+j - map_off[n_col-1]];
    }
    return 0;
}
    
int jmi_dae_cad_first_fit( int n_col, int **inc_vec, int *inc_length, int *color, int *numb_col){
    int i;
    int j;
    int max_col = 0;
    int *col_set  = (int*)calloc(n_col, sizeof(int));
    
    for(i = 0; i < n_col; i++){
        color[i] = 0;
        col_set[i] = 0;
        numb_col[i] = 0;
    }
    
    for(i = 0; i < n_col; i++){
        for(j = 0; j < inc_length[i]; j++){
            if(color[inc_vec[i][j]] != 0){
                col_set[color[inc_vec[i][j]]-1] = 1;
            }
        }
        j = 0;
        while(col_set[j] == 1 && j < n_col){
            j++;
        }
        color[i] = j+1;
        numb_col[j]++;
        if(max_col < j+1){
            max_col = j+1;
        }
        for(j = 0; j < max_col; j++){
            col_set[j] = 0;
        }
    }
    for(i = 0; i < n_col; i++){
        color[i]--;
    }
    free(col_set);
    return 0;
}
        
int jmi_dae_cad_get_connection_length( int n_col, int n_nz, int *row, int *col, int *inc_length){
    int i;
    int j;
    int k;
    int c;
    
    int *offs = (int*)calloc(n_col+1, sizeof(int));
    
    j=0;
    for(i = 0; i<n_nz;i++){
        if(j == col[i]){
            offs[j] = i;
            j++;
        }
    }
    offs[j] = n_nz;
    for(i = 0; i<n_col; i++){
        c=0;
        for(j = 0; j < n_nz; j++){
            for(k = offs[i]; k < offs[i+1]; k++){
                if(row[j]== row[k]){
                    c++;
                    k = offs[i+1];
                    j =offs[col[j]+1]-1;
                }
            }
        }
        inc_length[i] = c;
    }
    free(offs);
    return 0;
}

int jmi_dae_cad_get_connections( int n_col, int n_nz, int *row, int *col, int **inc_vec, int *inc_length){
    int i;
    int j;
    int k;
    int c;

    int *offs = (int*)calloc(n_col+1, sizeof(int));
    
    j=0;
    for(i = 0; i<n_nz;i++){
        if(j == col[i]){
            offs[j] = i;
            j++;
        }
    }
    offs[j] = n_nz;
    
    for(i = 0; i<n_col; i++){
        c = 0;
        for(j = 0; j < n_nz; j++){
            for(k = offs[i]; k < offs[i+1]; k++){
                if(row[j]== row[k]){
                    inc_vec[i][c] = col[j];
                    c++;
                    k = offs[i+1];
                    j =offs[col[j]+1]-1;
                }
            }   
        }
    }
    free(offs);
    return 0;
}

void compute_cpr_groups(jmi_simple_color_info_t *color_info) {
    int n_cols_in_group; /* Counter for the number of columns in a group */
    int n_selected_cols; /* Total number of columns added to groups */

    int i,j,k,l,compatible;

    int n_c_g = color_info->n_cols_in_grouping;
    int offs_c_g = color_info->col_offset;

    int* selected_groups = (int*)calloc(n_c_g,sizeof(int));
    for (i=0;i<n_c_g;i++) {
        selected_groups[i] = 0;
    }

    /*clock_t start = clock();*/

    /*
    printf("**********\n");
    for (i=0;i<n_c_g;i++) {
        for (j=0;j<func->ad->dF_z_col_n_nz[i+offs_c_g];j++) {
            printf(" - %d %d\n", i+offs_c_g,func->ad->dF_z_row[func->ad->dF_z_col_start_index[i+offs_c_g]+j]);
        }
    }


    printf("n_cols_in_grouping=%d\n",n_c_g);
*/

    color_info->n_groups = 0;
    color_info->group_start_index[0] = 0;
    n_cols_in_group = 0;
    n_selected_cols = 0;
    /* Loop until all column have been added to a graph */
    while(n_selected_cols<n_c_g) {
        /*printf("Starting sweep, n_groups = %d\n",color_info->n_groups);*/
        /* Reset group column counter */
        n_cols_in_group = 0;
        /* Loop over all colums and add the ones that are i) compatible
         and ii) have not been selected */
        for(i=0;i<n_c_g;i++) {
            /*printf("About to check, col = %d\n",i+offs_c_g);*/
            /* If the column has not been added to a group... */
            if (selected_groups[i]!=1) {
                /*printf("Col %d has not been selected\n",i+offs_c_g);*/
                /* ...make compatibility check */
                compatible = 1;
                /* Loop over all columns that have been added to group */
                for (j=color_info->group_start_index[color_info->n_groups];
                        j<color_info->group_start_index[color_info->n_groups] +
                        n_cols_in_group;j++) {

                    /*printf("a row index: %d\n", color_info->col_start_index[color_info->group_cols[j]]);
                    printf("b row index: %d\n", color_info->col_start_index[i + offs_c_g]);
                    printf("qew: %d, %d\n", i, offs_c_g);*/
                    int* col_a_row_ind = &color_info->rows[color_info->col_start_index[color_info->group_cols[j]]];
                    int* col_b_row_ind = &color_info->rows[color_info->col_start_index[i + offs_c_g]];
                    int col_a_n_nz = color_info->col_n_nz[color_info->group_cols[j]];
                    int col_b_n_nz = color_info->col_n_nz[i+offs_c_g];

                    /*printf("Checking col %d, n_nz=%d, against %d, n_n_z=%d (in group)\n",
                            i+offs_c_g,col_b_n_nz,color_info->group_cols[j],col_a_n_nz);*/

                    for (k=0;k<col_a_n_nz;k++) {
                        for (l=0;l<col_b_n_nz;l++) {
                            /*printf(" ** %d %d\n",col_a_row_ind[k],col_b_row_ind[l]);*/
                            if (col_a_row_ind[k] == col_b_row_ind[l]) {
                                compatible = 0;
                                break;
                            }
                        }
                    }
                }
                if (compatible==1) {
                    /*printf("Col %d added to group\n",i+offs_c_g);*/
                    selected_groups[i] = 1;
                    color_info->group_cols[n_selected_cols] = i + offs_c_g;
                    n_selected_cols++;
                    n_cols_in_group++;
                } else {
                    /*printf("Col %d incompatible\n",i+offs_c_g);*/
                }
            } else {
                   /* printf("Col %d has already been selected\n",i+offs_c_g);*/
            }
        }
        color_info->n_groups++;
        color_info->group_start_index[color_info->n_groups] =
                color_info->group_start_index[color_info->n_groups - 1] + n_cols_in_group;
        color_info->n_cols_in_group[color_info->n_groups - 1] = n_cols_in_group;
        /*printf("End iteration over cols, col = %d, n_cols_in_group = %d\n",i,n_cols_in_group);*/
    }

    free(selected_groups);
    /*
    printf("Computed CPR groups: %d groups computed from %d columns\n",color_info->n_groups,color_info->n_cols_in_grouping);
    for (i=0;i<color_info->n_groups;i++) {
        for (j=0;j<color_info->n_cols_in_group[i];j++) {
            printf(" >> %d %d\n",i,color_info->group_cols[color_info->group_start_index[i]+j]);
        }
    }*/

}

int jmi_util_dae_derivative_checker(jmi_t *jmi,jmi_func_t *func, int sparsity,
        int independent_vars, int screen_use, int *mask){
    
        int i = 0;

        jmi_real_t tol = 0.001;
        
        int dF_n_cols;
        int dF_n_nz;
        int dF_n_eq = 0;
        int* dF_row;
        int* dF_col;
        int passed;
        int failed;
        

        jmi_func_cad_dF_dim(jmi, jmi->dae->F, i, independent_vars, mask, &dF_n_cols, &dF_n_nz);
        
        dF_row = (int*)calloc(dF_n_nz, sizeof(int));
        dF_col = (int*)calloc(dF_n_nz, sizeof(int));
        jmi_func_cad_dF_nz_indices(jmi, jmi->dae->F, independent_vars, mask, dF_row, dF_col);
        
        for(i = 0; i < dF_n_nz;i++){
            if(dF_row[i] > dF_n_eq){
                dF_n_eq = dF_row[i];
            }
        }
        dF_n_eq++;
        
        passed = 0;
        failed = 0;
        
        if(sparsity & JMI_DER_SPARSE){
            jmi_real_t *jac_cad = (jmi_real_t*)calloc(dF_n_nz, sizeof(jmi_real_t));
            jmi_real_t *jac_fd;
            jmi_func_cad_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac_cad);        
            jac_fd = (jmi_real_t*)calloc(dF_n_nz, sizeof(jmi_real_t));
            jmi_func_fd_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac_fd);
            for(i = 0; i < dF_n_nz; i++){
                if(jac_fd[i] != 0 && jac_cad[i] != 0){
                    jmi_real_t rel_tol;
                    rel_tol = 1.0 - jac_fd[i]/jac_cad[i];
                    if((rel_tol < tol) && (rel_tol > -tol)){
                        passed++;
                    } else{
                        if(screen_use & JMI_DER_CHECK_SCREEN_ON){
                            printf("\nFAILED\trow: %d,\t col: %d,\n", dF_row[i], dF_col[i]);
                            printf("cad: %.4f,\t fd: %.4f,\t rel_tol: %.7f\t\n ", jac_cad[i], jac_fd[i], rel_tol);
                            failed++;
                        } else if(screen_use & JMI_DER_CHECK_SCREEN_OFF){
                            printf("\nEvaluation error found, derivative check failed\n");
                            return -1;
                        } else{
                            printf("\nNo such flag\n");
                            return -1;
                        }
                    }
                }else{
                    jmi_real_t abs_tol;
                    abs_tol = jac_cad[i]-jac_fd[i];
                    if((abs_tol < tol) && (abs_tol > -tol)){
                        passed++;
                    } else{
                        if(screen_use & JMI_DER_CHECK_SCREEN_ON){
                            printf("\nFAILED\trow: %d,\t col: %d,\n", dF_row[i], dF_col[i]);
                            printf("cad: %.4f,\t fd: %.4f,\t abs_tol: %.7f\t\n", jac_cad[i], jac_fd[i], abs_tol);
                            failed++;
                        } else if(screen_use & JMI_DER_CHECK_SCREEN_OFF){
                            printf("\nEvaluation error found, derivative check failed\n");
                            return -1;
                        } else{
                            printf("\nNo such flag\n");
                            return -1;
                        }
                    }
                }
            }
            free(jac_cad);
            free(jac_fd);
            
        } else if(sparsity & JMI_DER_DENSE_COL_MAJOR){
            jmi_real_t *jac_cad = (jmi_real_t*)calloc(dF_n_cols*dF_n_eq, sizeof(jmi_real_t));
            jmi_real_t *jac_fd;
            jmi_func_cad_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac_cad);    
            jac_fd = (jmi_real_t*)calloc(dF_n_cols*dF_n_eq, sizeof(jmi_real_t));
            jmi_func_fd_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac_fd);
            for(i = 0; i < dF_n_cols*dF_n_eq; i++){
                if(jac_fd[i] != 0 && jac_cad[i] != 0){
                    jmi_real_t rel_tol;
                    rel_tol = 1.0 - jac_fd[i]/jac_cad[i];           
                    if((rel_tol < tol) && (rel_tol > -tol)){
                        passed++;
                    } else{
                        if(screen_use & JMI_DER_CHECK_SCREEN_ON){
                            printf("\nFAILED\trow: %d,\t col: %d,\n", i % dF_n_eq, (i - (i % dF_n_eq))/dF_n_eq);
                            printf("cad: %.4f,\t fd: %.4f,\t rel_tol: %.7f\n", jac_cad[i], jac_fd[i], rel_tol);
                            failed++;
                        } else if(screen_use & JMI_DER_CHECK_SCREEN_OFF){
                            printf("\nEvaluation error found, derivative check failed\n");
                            return -1;
                        } else{
                            printf("\nNo such flag\n");
                            return -1;
                        }
                    }
                }else{
                    jmi_real_t abs_tol;
                    abs_tol = jac_cad[i]-jac_fd[i];
                    if((abs_tol < tol) && (abs_tol > -tol)){
                        passed++;
                    } else{
                        if(screen_use & JMI_DER_CHECK_SCREEN_ON){
                            printf("\nFAILED\trow: %d,\t col: %d,\n", i % dF_n_eq, (i - (i % dF_n_eq))/dF_n_eq);
                            printf("cad: %.4f,\t fd: %.4f,\t abs_tol: %.7f\n", jac_cad[i], jac_fd[i], abs_tol);
                            failed++;
                        } else if(screen_use & JMI_DER_CHECK_SCREEN_OFF){
                            printf("\nEvaluation error found, derivative check failed\n");
                            return -1;
                        } else{
                            printf("\nNo such flag\n");
                            return -1;
                        }
                    }
                }
            }
            free(jac_cad);
            free(jac_fd);
            
        } else if(sparsity & JMI_DER_DENSE_ROW_MAJOR){
            jmi_real_t *jac_cad = (jmi_real_t*)calloc(dF_n_cols*dF_n_eq, sizeof(jmi_real_t));
            jmi_real_t *jac_fd;
            jmi_func_cad_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac_cad);    
            jac_fd = (jmi_real_t*)calloc(dF_n_cols*dF_n_eq, sizeof(jmi_real_t));
            jmi_func_fd_dF(jmi,jmi->dae->F, sparsity, independent_vars, mask, jac_fd);
            for(i = 0; i < dF_n_cols*dF_n_eq; i++){
                if(jac_fd[i] != 0 || jac_cad[i] != 0){
                    jmi_real_t rel_tol;
                    rel_tol = 1.0 - jac_fd[i]/jac_cad[i];   
                    if((rel_tol < tol) && (rel_tol > -tol)){
                        passed++;
                    } else{
                        if(screen_use & JMI_DER_CHECK_SCREEN_ON){
                            printf("\nFAILED\trow: %d,\t col: %d,\n", (i - (i % dF_n_cols))/dF_n_cols, i % dF_n_cols);
                            printf("cad: %.4f,\t fd: %.4f,\t rel_tol: %.7f\n", jac_cad[i], jac_fd[i], rel_tol);
                            failed++;
                        } else if(screen_use & JMI_DER_CHECK_SCREEN_OFF){
                            printf("\nEvaluation error found, derivative check failed\n");
                            return -1;
                        } else{
                            printf("\nNo such flag\n");
                            return -1;
                        }
                    }
                }
                else{
                    jmi_real_t abs_tol;
                    abs_tol = jac_cad[i]-jac_fd[i];
                    if((abs_tol < tol) && (abs_tol > -tol)){
                        passed++;
                    } else{
                        if(screen_use & JMI_DER_CHECK_SCREEN_ON){
                            printf("\nFAILED\trow: %d,\t col: %d,\n", (i - (i % dF_n_cols))/dF_n_cols, i % dF_n_cols);
                            printf("cad: %.4f,\t fd: %.4f,\t abs_tol: %.7f\n", jac_cad[i], jac_fd[i], abs_tol);
                            failed++;
                        } else if(screen_use & JMI_DER_CHECK_SCREEN_OFF){
                            printf("\nEvaluation error found, derivative check failed\n");
                            return -1;
                        } else{
                            printf("\nNo such flag\n");
                            return -1;
                        }
                    }
                }
            }
            free(jac_cad);
            free(jac_fd);
        } else{
            return -1;
        }
        if(screen_use & JMI_DER_CHECK_SCREEN_ON){
            printf("\nPASSED: %d\tFAILED: %d\n\n", passed, failed);
        }
        free(dF_row);
        free(dF_col);
        return 0;
}

int jmi_func_cad_dF_get_independent_ind(jmi_t *jmi, jmi_func_t *func, int independent_vars, int *col_independent_ind) {
    
    int n_p_opt = jmi->opt->n_p_opt;
    int n_dx = jmi->n_real_dx;
    int n_x = jmi->n_real_x;
    int n_u = jmi->n_real_u;
    int n_w = jmi->n_real_w;
    int n_t = 0;

    int max_n_nz = func->cad_dF_n_nz;
    
    int aim = 0;
    int i = 0;
    int j = 0;

    if(JMI_DER_T & independent_vars){
        n_t = 1;
    }
    
    aim+=n_p_opt;
    while(func->cad_dF_col[i]<aim && aim != 0 && i < max_n_nz){
        if(JMI_DER_P_OPT & independent_vars){   
            col_independent_ind[j] = func->cad_dF_col[i];
            j++;
        }
        i++;
    }
    aim+=n_dx;
    while(func->cad_dF_col[i]<aim && aim != 0 && i < max_n_nz){
        if(JMI_DER_DX & independent_vars){  
            col_independent_ind[j] = func->cad_dF_col[i];
            j++;
        }
        i++;
    }
    aim+=n_x;
    while(func->cad_dF_col[i]<aim && aim != 0 && i < max_n_nz){
        if(JMI_DER_X & independent_vars){
            col_independent_ind[j] = func->cad_dF_col[i];
            j++;
        }
        i++;
    }
    aim+=n_u;
    while(func->cad_dF_col[i]<aim && aim != 0 && i < max_n_nz){
        if(JMI_DER_U & independent_vars){
            col_independent_ind[j] = func->cad_dF_col[i];
            j++;
        }
        i++;
    }
    aim+=n_w;
    while(func->cad_dF_col[i]<aim && aim != 0 && i < max_n_nz){
        if(JMI_DER_W & independent_vars){   
            col_independent_ind[j] = func->cad_dF_col[i];
            j++;        
        }
        i++;
    }   
    aim+=n_t;
    while(func->cad_dF_col[i]<aim && aim != 0 && i < max_n_nz){
        if(JMI_DER_T & independent_vars){   
            col_independent_ind[j] = func->cad_dF_col[i];
            j++;        
        }
        i++;
    }
    return 0;
}

int jmi_compare_switches(jmi_real_t* sw_pre, jmi_real_t* sw_post, jmi_int_t size){
    int i;
    for (i=0;i<size;i++){
        if (sw_pre[i]!=sw_post[i]){
            return 0;
        }
    }
    return 1;
}

jmi_real_t jmi_turn_switch(jmi_real_t ev_ind, jmi_real_t sw, jmi_real_t eps, int rel){
    /* x >= 0
     * x >  0
     * x <= 0
     * x <  0
     */
    if (sw == 1.0){
        if ((ev_ind <= -1*eps && rel == JMI_REL_GEQ) || (ev_ind <= 0.0 && rel == JMI_REL_GT) || (ev_ind >= eps && rel == JMI_REL_LEQ) || (ev_ind >= 0.0 && rel == JMI_REL_LT)){
            sw = 0.0;
        }
    }else{
        if ((ev_ind >= 0.0 && rel == JMI_REL_GEQ) || (ev_ind >= eps && rel == JMI_REL_GT) || (ev_ind <= 0.0 && rel == JMI_REL_LEQ) || (ev_ind <= -1*eps && rel == JMI_REL_LT)){
            sw = 1.0;
        }
    }
    return sw;
}

int jmi_evaluate_switches(jmi_t* jmi, jmi_real_t* switches, jmi_int_t mode){
    jmi_int_t nF,nR;
    jmi_int_t nF0,nF1,nFp,nR0,retval;
    jmi_int_t i,size_switches;
    jmi_real_t *event_indicators;
    jmi_real_t eps = jmi->events_epsilon;
    
    jmi_init_get_sizes(jmi,&nF0,&nF1,&nFp,&nR0); /* Get the size of R0 and F0, (interested in R0) */
    jmi_dae_get_sizes(jmi, &nF, &nR);
    
    if (mode==1) { 
        size_switches = nR;
        /* Allocate memory */
        event_indicators = (jmi_real_t*)calloc(size_switches, sizeof(jmi_real_t));
        retval = jmi_dae_R(jmi,event_indicators);
    }else{ /* INITIALIZE */
        size_switches = nR0;
        /* Allocate memory */
        event_indicators = (jmi_real_t*)calloc(size_switches, sizeof(jmi_real_t));
        retval = jmi_init_R0(jmi, event_indicators);
    }

    if (mode==1){
        for (i=0; i < size_switches; i=i+1){
            switches[i] = jmi_turn_switch(event_indicators[i], switches[i], eps, jmi->relations[i]);
        }
    }else{ /* INITIALIZE */
        for (i=0; i < size_switches; i=i+1){
            if (i < nR){
                /* NORMAL SWITCHES FIRST */
                switches[i] = jmi_turn_switch(event_indicators[i], switches[i], eps, jmi->relations[i]);
            }else{
                /* INITIALIZATION SWITCHES NEXT */
                switches[i] = jmi_turn_switch(event_indicators[i], switches[i], eps, jmi->initial_relations[i-nR]);
            }
        }
    }
    free(event_indicators);
    return 0;
}
