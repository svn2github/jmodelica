#include "fmiModelDescriptionImpl.h"
#include "fmiVariableListImpl.h"

fmiVariableList* fmiVariableListAlloc(jm_callbacks* cb, size_t size) {
    fmiVariableList* vl = cb->malloc(sizeof(fmiVariableList));
    if(!vl) return 0;
    vl->vr = 0;
    if(jm_vector_init(jm_voidp)(&vl->variables,size,cb) < size) {
        fmiVariableListFree(vl);
        return 0;
    }
}

void fmiVariableListFree(fmiVariableList* vl) {
    jm_callbacks* cb = vl->variables.callbacks;
    jm_vector_free(size_t)(vl->vr);
    jm_vector_free_data(jm_voidp)(&vl->variables);
    cb->free(vl);
}

/* Get number of variables in a list */
unsigned int  fmiGetVariableListSize(fmiVariableList* vl) {
    return jm_vector_get_size(jm_voidp)(&vl->variables);
}

/* Make a copy */
fmiVariableList* fmiVariableListClone(fmiVariableList* vl) {
    fmiVariableList* copy = fmiVariableListAlloc(vl->variables.callbacks, fmiGetVariableListSize(vl));
    if(!copy) return 0;
    jm_vector_copy(jm_voidp)(&copy->variables, &vl->variables);
    return copy;
}

/* Get a pointer to the list of the value references for all the variables */
const fmiValueReference* fmiGetValueReferceList(fmiVariableList* vl) {
    if(!vl->vr) {
        size_t i, nv = fmiGetVariableListSize(vl);
        vl->vr = jm_vector_alloc(size_t)(nv,nv,vl->variables.callbacks);
        if(vl->vr) {
            for(i = 0; i < nv; i++) {
                jm_vector_set_item(size_t)(vl->vr, i, fmiGetVariableValueReference( fmiGetVariable(vl, i)));
            }
        }
    }
    return jm_vector_get_itemp(size_t)(vl->vr,0);
}

/* Get a single variable from the list*/
fmiVariable* fmiGetVariable(fmiVariableList* vl, unsigned int  index) {
    if(index >= fmiGetVariableListSize(vl)) return 0;
    return jm_vector_get_item(jm_voidp)(&vl->variables, index);
}

/* Operations on variable lists. Every operation creates a new list. */
/* Select sub-lists */
fmiVariableList* fmiGetSublist(fmiVariableList* vl, unsigned int  fromIndex, unsigned int  toIndex) {
    fmiVariableList* out;
    size_t size, i;
    if(fromIndex > toIndex) return 0;
    if(toIndex >=  fmiGetVariableListSize(vl)) return 0;
    size = toIndex - fromIndex + 1;
    out = fmiVariableListAlloc(vl->variables.callbacks, size);
    if(!out ) return 0;
    for(i=0; i < size; i++) {
        jm_vector_set_item(jm_voidp)(&out->variables, i, jm_vector_get_item(jm_voidp)(&vl->variables, fromIndex+i));
    }
    return out;
}

/* fmiFilterVariables calls  the provided 'filter' function on every variable in the list.
  It returns a sub-list list with the variables for which filter returned non-zero value. */
fmiVariableList* fmiFilterVariables(fmiVariableList* vl, fmiVariableFilterFunction filter) {
    size_t nv, i;
    fmiVariableList* out = fmiVariableListAlloc(vl->variables.callbacks, 0);
    nv = fmiGetVariableListSize(vl);
    for(i=0; i < nv;i++) {
        fmiVariable* variable = fmiGetVariable(vl, i);
        if(filter(variable))
            if(!jm_vector_push_back(jm_voidp)(&out->variables, variable))
                break;
    }
    if(i != nv) {
        fmiVariableListFree(out);
        out = 0;
    }
    return out;
}

