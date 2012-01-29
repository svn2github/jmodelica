#ifndef JM_CALLBACKS_H
#define JM_CALLBACKS_H
#include <stddef.h>

#include "jm_types.h"

typedef jm_voidp (*jm_malloc_f)(size_t size);

typedef jm_voidp (*jm_realloc_f)(void *ptr, size_t size);

typedef jm_voidp (*jm_calloc_f)(size_t numitems, size_t itemsize);

typedef void (*jm_free_f)(jm_voidp p);

typedef void (*jm_logger_f)(jm_voidp c, jm_string instanceName, int status, jm_string category, jm_string message, ...);

typedef struct jm_callbacks_ {
        jm_malloc_f malloc;
        jm_calloc_f calloc;
        jm_realloc_f realloc;
        jm_free_f free;
        jm_logger_f logger;
        jm_voidp context;
} jm_callbacks;

extern void jm_set_default_callbacks(jm_callbacks* c);

extern jm_callbacks* jm_get_default_callbacks();

/* JM_CONTEXT_H */
#endif
