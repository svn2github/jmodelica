#ifndef FMICALLBACKS_H
#define FMICALLBACKS_H

#include "fmi-me-1.0/fmiModelFunctions.h"
#include <jm_callbacks.h>

typedef struct fmiCallbacks_ {
    jm_callbacks jmFunctions;
    fmiCallbackFunctions fmiFunctions;
} fmiCallbacks;

typedef struct fmiMemoryHeader_ {
    fmiCallbacks* callbacks;
    size_t size;
} fmiMemoryHeader;

/*
    In order to replace the system malloc/calloc/realloc/free an FMU must compile with -DFMU_REPLACE_SYSTEM_MALLOC
    and execute the following call sequence:
    1. During inititalization in fmiInstantiateModel allocate fmiCallbacks struct and call fmiInitCallbacks on it:
        fmiCallbacks cb;
        fmiInitCallbacks(&cb);
       The allocated structure must be preserved between entries into the DLL (must be part of the FMU context)
    2. On each entry into the FMU DLL where malloc/calloc (not callbacks) are expected to be called call
    jm_set_default_callbacks(&cb) to set memory handling functions to point to the correct context.
    Note that realloc and free get the correct context from heap memory directly.
*/
void fmiInitCallbacks(fmiCallbacks* callbacks, fmiCallbackFunctions* fmiFunctions);

#endif /* FMICALLBACKS_H */
