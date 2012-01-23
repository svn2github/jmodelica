#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "jm_callbacks.h"

void jm_default_logger(jm_voidp c, jm_string instanceName, int status, jm_string category, jm_string message, ...) {
    va_list args;
    char buf[500], *curp;
    va_start (args, message);
    curp = buf;
    *curp = 0;
    if(instanceName) {
        sprintf(curp, "[%s]", instanceName);
        curp += strlen(instanceName);
    }
    if(category) {
        sprintf(curp, "[%s]", category);
        curp += strlen(category);
    }
    fprintf(stdout, "%s[status=%d]", curp, status);
    vfprintf (stdout, message, args);
    va_end (args);
}

jm_callbacks jm_standard_callbacks = {malloc, calloc, realloc, free, jm_default_logger, 0};

jm_callbacks* jm_default_callbacks = &jm_standard_callbacks;

void jm_set_default_callbacks(jm_callbacks* c) {
    jm_default_callbacks = c;
}

jm_callbacks* jm_get_default_callbacks() { return jm_default_callbacks; }
