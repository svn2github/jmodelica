#ifndef FMIVARIABLEIMPL_H
#define FMIVARIABLEIMPL_H

#include <jm_vector.h>

#include <fmiModelDescription.h>
#include <fmiVariable.h>
#include "fmiTypeImpl.h"

/* General variable type is convenien to unify all the variable list operations */
struct fmiVariable {
    fmiVariableTypeBase* typeBase;

    const char* description;
    jm_vector(jm_voidp)* directDependency;

    fmiValueReference vr;
    fmiVariable* alias;

    char aliasKind;
    char variability;
    char causality;

    char name[1];
};

static int fmiCompareVR (const void* first, const void* second) {
    fmiVariable* a = *(fmiVariable**)first;
    fmiVariable* b = *(fmiVariable**)second;
    fmiBaseType at = fmiGetVariableBaseType(a);
    fmiBaseType bt = fmiGetVariableBaseType(b);
    if(at!=bt) return at - bt;
    return a->vr - b->vr;
}

#endif /* FMIVARIABLEIMPL_H */
