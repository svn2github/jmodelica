#ifndef FMIVARIABLELISTIMPL_H
#define FMIVARIABLELISTIMPL_H

#include <jm_vector.h>
#include "fmiModelDescription.h"
#include "fmiVariableList.h"

struct fmiVariableList {
    jm_vector(jm_voidp) variables;
    jm_vector(size_t)* vr;
};

/* Allocate an empty list */
fmiVariableList* fmiVariableListAlloc(jm_callbacks* cb, size_t size);

#endif /* FMIVARIABLELISTIMPL_H */
