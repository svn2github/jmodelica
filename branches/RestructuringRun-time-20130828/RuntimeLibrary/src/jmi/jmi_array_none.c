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

#include "jmi_common.h"

#define TRANSPOSE_FUNC(name, src_type, dst_type, to_fortran) \
void name(jmi_array_t* arr, src_type* src, dst_type* dest) { \
    int i, j, tmp1, tmp2, k, n, dim, s; \
 \
    n = arr->num_elems; \
    dim = arr->num_dims; \
 \
    for (i = 0; i < n; i++) { \
        j = 0; \
        tmp1 = i; \
        tmp2 = 0; \
 \
        for (k = 0; k < dim; k++) { \
            s = arr->size[to_fortran ? k : dim - k - 1]; \
            tmp2 = tmp1 % s; \
            tmp1 /= s; \
            j *= s; \
            j += tmp2; \
        } \
 \
        dest[i] = (dst_type) src[j]; \
    } \
}

#define COPY_FUNC(name, src_type, dst_type) \
void name(jmi_array_t* arr, src_type* src, dst_type* dest) { \
    int i, n; \
 \
    n = arr->num_elems; \
    for (i = 0; i < n; i++) { \
        dest[i] = (dst_type) src[i]; \
    } \
}

TRANSPOSE_FUNC(jmi_matrix_to_fortran_real, jmi_ad_var_t, jmi_ad_var_t, 1)
TRANSPOSE_FUNC(jmi_matrix_from_fortran_real, jmi_ad_var_t, jmi_ad_var_t, 0)
TRANSPOSE_FUNC(jmi_matrix_to_fortran_int, jmi_ad_var_t, jmi_int_t, 1)
TRANSPOSE_FUNC(jmi_matrix_from_fortran_int, jmi_int_t, jmi_ad_var_t, 0)
COPY_FUNC(jmi_copy_matrix_to_int, jmi_ad_var_t, jmi_int_t)
COPY_FUNC(jmi_copy_matrix_from_int, jmi_int_t, jmi_ad_var_t)

void jmi_dynamic_free(jmi_dynamic_list* jmi_dynamic_first) {
    jmi_dynamic_list* jmi_dynamic_prev;
    jmi_dynamic_list* jmi_dynamic_cur;
    for (jmi_dynamic_prev = jmi_dynamic_first, jmi_dynamic_cur = jmi_dynamic_prev->next;
        jmi_dynamic_cur;
        jmi_dynamic_prev = jmi_dynamic_cur, jmi_dynamic_cur = jmi_dynamic_cur->next) {
        free(jmi_dynamic_prev->data);
        free(jmi_dynamic_prev);
    }
    free(jmi_dynamic_prev->data);
    free(jmi_dynamic_prev);
}
