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

#ifndef JM_CALLBACKS_H
#define JM_CALLBACKS_H
#include <stddef.h>
#include <stdarg.h>

#include "jm_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Forward declaration of the callbacks struct*/
typedef struct jm_callbacks jm_callbacks;

/* 
/* \defgroup Memory management callbacks
* jm_malloc_f, jm_realloc_f, jm_calloc_f, jm_free_f function 
* types correspond to the standard C memory management functions
* @{ 
*/
typedef jm_voidp (*jm_malloc_f)(size_t size);

typedef jm_voidp (*jm_realloc_f)(void *ptr, size_t size);

typedef jm_voidp (*jm_calloc_f)(size_t numitems, size_t itemsize);

typedef void (*jm_free_f)(jm_voidp p);
/* @{ 
*/

/*
* \defgroup Logging handling
* The logger callback is used to report errors. Note that this function is only used in
* fmi standard intependent code (e.g., fmi_import_context). Since logging functions
* are different between different standards separate logging functions are necessary for each fmi implementation.
* See fmiN_callbacks.h
*/
typedef void (*jm_logger_f)(jm_callbacks* c, jm_string module, jm_log_level_enu_t log_level, jm_string message);

#define JM_MAX_ERROR_MESSAGE_SIZE 2000

struct jm_callbacks {
        jm_malloc_f malloc;
        jm_calloc_f calloc;
        jm_realloc_f realloc;
        jm_free_f free;
        jm_logger_f logger;
		jm_log_level_enu_t log_level;
		jm_voidp context;
		char errMessageBuffer[JM_MAX_ERROR_MESSAGE_SIZE];
};

/*
* An alternative way to get error information is to use jm_get_last_error(). This is only meaningful
* if logger function is not present. Otherwize the string is always empty.
*/
static jm_string jm_get_last_error(jm_callbacks* cb) {return cb->errMessageBuffer; }
static void jm_clear_last_error(jm_callbacks* cb) { cb->errMessageBuffer[0] = 0; }

void jm_set_default_callbacks(jm_callbacks* c);

jm_callbacks* jm_get_default_callbacks();

void jm_log(jm_callbacks* cb, const char* module, jm_log_level_enu_t log_level, const char* fmt, ...);

void jm_log_v(jm_callbacks* cb, const char* module, jm_log_level_enu_t log_level, const char* fmt, va_list ap);

#ifdef __cplusplus
}
#endif
/* JM_CONTEXT_H */
#endif
