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

#endif /* FMIVARIABLEIMPL_H */
