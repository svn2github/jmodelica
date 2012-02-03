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
        curp += strlen(instanceName)+2;
    }
    if(category) {
        sprintf(curp, "[%s]", category);
        curp += strlen(category)+2;
    }
    fprintf(stdout, "%s[status=%d]", buf, status);
    vfprintf (stdout, message, args);
    fprintf(stdout, "\n");
    va_end (args);
}

jm_callbacks jm_standard_callbacks = {malloc, calloc, realloc, free, jm_default_logger, 0};

jm_callbacks* jm_default_callbacks = &jm_standard_callbacks;

void jm_set_default_callbacks(jm_callbacks* c) {
    jm_default_callbacks = c;
}

jm_callbacks* jm_get_default_callbacks() { return jm_default_callbacks; }
