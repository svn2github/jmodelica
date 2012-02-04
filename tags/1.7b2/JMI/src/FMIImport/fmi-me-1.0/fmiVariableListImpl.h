#ifndef FMIVARIABLELISTIMPL_H
#define FMIVARIABLELISTIMPL_H

#include <jm_vector.h>

struct fmiVariableList {
    jm_vector(jm_voidp) variables;
    jm_vector(size_t) vr;
};

#endif // FMIVARIABLELISTIMPL_H
