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

#ifndef FMI_XML_CALLBACKS_H
#define FMI_XML_CALLBACKS_H

#include "fmi-me-1.0/fmiModelFunctions.h"
#include <jm_callbacks.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef struct fmi_callbacks_t {
    jm_callbacks jmFunctions;
    fmiCallbackFunctions fmiFunctions;
} fmi_callbacks_t;

typedef struct fmi_memory_header_t {
    fmi_callbacks_t* callbacks;
    size_t size;
} fmi_memory_header_t;

/*
    In order to replace the system malloc/calloc/realloc/free an FMU must compile with -DFMU_REPLACE_SYSTEM_MALLOC
    and execute the following call sequence:
    1. During inititalization in fmi_xml_instantiate_model allocate fmiCallbacks struct and call fmi_xml_init_callbacks on it:
        fmiCallbacks cb;
        fmi_xml_init_callbacks(&cb);
       The allocated structure must be preserved between entries into the DLL (must be part of the FMU context)
    2. On each entry into the FMU DLL where malloc/calloc (not callbacks) are expected to be called call
    jm_set_default_callbacks(&cb) to set memory handling functions to point to the correct context.
    Note that realloc and free get the correct context from heap memory directly.
*/
void fmi_init_callbacks(fmi_callbacks_t* callbacks, fmiCallbackFunctions* fmiFunctions);

#ifdef __cplusplus
}
#endif
#endif /* FMI_XML_CALLBACKS_H */
