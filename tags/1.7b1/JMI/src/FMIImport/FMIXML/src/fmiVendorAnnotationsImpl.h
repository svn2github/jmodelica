#ifndef FMIVENDORANNOTATIONS_H
#define FMIVENDORANNOTATIONS_H

#include <jm_named_ptr.h>

#include <fmiModelDescription.h>
#include <fmiVendorAnnotations.h>

struct fmiAnnotation {
    const char* name;
    char value[1];
};

struct fmiVendor {
    jm_vector(jm_named_ptr) annotations;
    char name[1];
};

void fmiVendorFree(fmiVendor* v);

struct fmiVendorList {
    jm_vector(jm_voidp) vendors;
};

#endif /* FMIVENDORANNOTATIONS_H */
