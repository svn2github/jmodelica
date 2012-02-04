/*
    Copyright (C) 2012 Modelon AB

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
#include <string.h>

#include "fmi_xml_model_description_impl.h"
#include "fmi_xml_variable_list_impl.h"

fmi_xml_variable_list_t* fmi_xml_alloc_variable_list(jm_callbacks* cb, size_t size) {
    fmi_xml_variable_list_t* vl = cb->malloc(sizeof(fmi_xml_variable_list_t));
    if(!vl) return 0;
    vl->vr = 0;
    if(jm_vector_init(jm_voidp)(&vl->variables,size,cb) < size) {
        fmi_xml_free_variable_list(vl);
        return 0;
    }
    return vl;
}

void fmi_xml_free_variable_list(fmi_xml_variable_list_t* vl) {
    jm_callbacks* cb = vl->variables.callbacks;
    jm_vector_free(size_t)(vl->vr);
    jm_vector_free_data(jm_voidp)(&vl->variables);
    cb->free(vl);
}

/* Get number of variables in a list */
unsigned int  fmi_xml_get_variable_list_size(fmi_xml_variable_list_t* vl) {
    return jm_vector_get_size(jm_voidp)(&vl->variables);
}

/* Make a copy */
fmi_xml_variable_list_t* fmi_xml_clone_variable_list(fmi_xml_variable_list_t* vl) {
    fmi_xml_variable_list_t* copy = fmi_xml_alloc_variable_list(vl->variables.callbacks, fmi_xml_get_variable_list_size(vl));
    if(!copy) return 0;
    jm_vector_copy(jm_voidp)(&copy->variables, &vl->variables);
    return copy;
}

fmi_xml_variable_list_t* fmi_xml_join_var_list(fmi_xml_variable_list_t* a, fmi_xml_variable_list_t* b) {
    size_t asize = fmi_xml_get_variable_list_size(a);
    size_t bsize = fmi_xml_get_variable_list_size(b);
    size_t joinSize = asize + bsize;
    fmi_xml_variable_list_t* list = fmi_xml_alloc_variable_list(a->variables.callbacks,joinSize);
    if(!list) {
        return list;
    }
    jm_vector_copy(jm_voidp)(&list->variables,&a->variables);
    jm_vector_resize(jm_voidp)(&list->variables,joinSize);
    memcpy((void*)jm_vector_get_itemp(jm_voidp)(&list->variables,asize), (void*)jm_vector_get_itemp(jm_voidp)(&b->variables,0), sizeof(jm_voidp)*bsize);
    return list;
}

fmi_xml_variable_list_t* fmi_xml_create_var_list(fmi_xml_model_description_t* md,fmi_xml_variable_t* v) {
    fmi_xml_variable_list_t* list = fmi_xml_alloc_variable_list(md->callbacks,1);
    if(!list ) {
        return list;
    }
    jm_vector_set_item(jm_voidp)(&list->variables,0,v);
    return list;
}

fmi_xml_variable_list_t* fmi_xml_append_to_var_list(fmi_xml_variable_list_t* list, fmi_xml_variable_t* v) {
    fmi_xml_variable_list_t* out = fmi_xml_alloc_variable_list(list->variables.callbacks, fmi_xml_get_variable_list_size(list)+1);
    if(!out) return 0;
    jm_vector_copy(jm_voidp)(&out->variables,&list->variables);
    jm_vector_push_back(jm_voidp)(&out->variables, v);
    return out;
}

fmi_xml_variable_list_t* fmi_xml_prepend_to_var_list(fmi_xml_variable_list_t* list, fmi_xml_variable_list_t* v) {
    size_t lsize = fmi_xml_get_variable_list_size(list);
    fmi_xml_variable_list_t* out = fmi_xml_alloc_variable_list(list->variables.callbacks, lsize+1);
    if(!out) return 0;
    jm_vector_set_item(jm_voidp)(&out->variables,0,v);
    memcpy((void*)jm_vector_get_itemp(jm_voidp)(&out->variables,1), (void*)jm_vector_get_itemp(jm_voidp)(&list->variables,0), sizeof(jm_voidp)*lsize);
    return out;
}


/* Get a pointer to the list of the value references for all the variables */
const fmiValueReference* fmi_xml_get_value_referece_list(fmi_xml_variable_list_t* vl) {
    if(!vl->vr) {
        size_t i, nv = fmi_xml_get_variable_list_size(vl);
        vl->vr = jm_vector_alloc(size_t)(nv,nv,vl->variables.callbacks);
        if(vl->vr) {
            for(i = 0; i < nv; i++) {
                jm_vector_set_item(size_t)(vl->vr, i, fmi_xml_get_variable_vr( fmi_xml_get_variable(vl, i)));
            }
        }
    }
    return jm_vector_get_itemp(size_t)(vl->vr,0);
}

/* Get a single variable from the list*/
fmi_xml_variable_t* fmi_xml_get_variable(fmi_xml_variable_list_t* vl, unsigned int  index) {
    if(index >= fmi_xml_get_variable_list_size(vl)) return 0;
    return jm_vector_get_item(jm_voidp)(&vl->variables, index);
}

/* Operations on variable lists. Every operation creates a new list. */
/* Select sub-lists */
fmi_xml_variable_list_t* fmi_xml_get_sublist(fmi_xml_variable_list_t* vl, unsigned int  fromIndex, unsigned int  toIndex) {
    fmi_xml_variable_list_t* out;
    size_t size, i;
    if(fromIndex > toIndex) return 0;
    if(toIndex >=  fmi_xml_get_variable_list_size(vl)) return 0;
    size = toIndex - fromIndex + 1;
    out = fmi_xml_alloc_variable_list(vl->variables.callbacks, size);
    if(!out ) return 0;
    for(i=0; i < size; i++) {
        jm_vector_set_item(jm_voidp)(&out->variables, i, jm_vector_get_item(jm_voidp)(&vl->variables, fromIndex+i));
    }
    return out;
}

/* fmi_xml_filter_variables calls  the provided 'filter' function on every variable in the list.
  It returns a sub-list list with the variables for which filter returned non-zero value. */
fmi_xml_variable_list_t* fmi_xml_filter_variables(fmi_xml_variable_list_t* vl, fmi_xml_variable_filter_function_ft filter) {
    size_t nv, i;
    fmi_xml_variable_list_t* out = fmi_xml_alloc_variable_list(vl->variables.callbacks, 0);
    nv = fmi_xml_get_variable_list_size(vl);
    for(i=0; i < nv;i++) {
        fmi_xml_variable_t* variable = fmi_xml_get_variable(vl, i);
        if(filter(variable))
            if(!jm_vector_push_back(jm_voidp)(&out->variables, variable))
                break;
    }
    if(i != nv) {
        fmi_xml_free_variable_list(out);
        out = 0;
    }
    return out;
}

