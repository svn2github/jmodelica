 /*
    Copyright (C) 2013 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/



/** \file jmi_global.c
 *  \brief Thread-safe global data and exception handling.
 */

#include <stdlib.h>
#include <stdio.h>
#include "jmi_global.h"
#include "jmi_log.h"
#include "jmi_common.h"


#ifdef _MSC_VER
/* Use Microsoft stuff. */

#include <Windows.h>
#include <WinBase.h>

/**
 * \brief Handle to thread-specific storage.
 */
DWORD jmi_tls_handle;

/**
 * \brief DLL entry/exit point.
 *
 * Used to set up and free thread-specific storage.
 */
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {
	switch (fdwReason) {
	case DLL_PROCESS_ATTACH:
		/* TODO: Handle failure. */
		jmi_tls_handle = TlsAlloc();
		break;
	case DLL_PROCESS_DETACH:
		TlsFree(jmi_tls_handle);
		break;
	default:
		break;
	}
	return TRUE;
}

/* Macro for function that sets thread-specific storage value. */
#define jmi_tls_set_value TlsSetValue

/* Macro for function that gets thread-specific storage value. */
#define jmi_tls_get_value TlsGetValue

#else /* ifdef _MSC_VER */
/* Assume pthreads is available. */

#define _MULTI_THREADED
#include <pthread.h>

/**
 * \brief Handle to thread-specific storage.
 */
pthread_key_t jmi_tls_handle;

/**
 * \brief Called when shared library is loaded.
 *
 * Used to set up thread-specific storage.
 */
__attribute__((constructor)) static void jmi_init_tls() {
	/* TODO: Handle failure. */
	pthread_key_create(&jmi_tls_handle, NULL);
}

/**
 * \brief Called when shared library is unloaded.
 *
 * Used to free thread-specific storage.
 */
__attribute__((destructor)) static void jmi_free_tls() {
	pthread_key_delete(jmi_tls_handle);
}

/* Macro for function that sets thread-specific storage value. */
#define jmi_tls_set_value pthread_setspecific

/* Macro for function that gets thread-specific storage value. */
#define jmi_tls_get_value pthread_getspecific

#endif /* ifdef _MSC_VER */

/* TODO: Add version without multi-thread support, to be used where pthereads is unavailable. */


/**
 * \brief Set the current jmi struct.
 */
void jmi_set_current(jmi_t* jmi) {
	if (jmi != NULL && jmi_tls_get_value(jmi_tls_handle) != NULL)
	    fprintf(stderr, "jmi_set_current(): current is not NULL\n");
	jmi_tls_set_value(jmi_tls_handle, jmi);
}

/**
 * \brief Get the current jmi struct.
 */
jmi_t* jmi_get_current() {
	jmi_t* res = (jmi_t*) jmi_tls_get_value(jmi_tls_handle);
	if (res == NULL)
	    fprintf(stderr, "jmi_get_current(): current is NULL\n");
	return res;
}

/**
 * \brief Check if the current jmi struct is set.
 */
int jmi_current_is_set() {
	return jmi_tls_get_value(jmi_tls_handle) != NULL;
}

/* TODO: This version needs more consideration to support FMUs calling other FMUs. */


/**
 * \brief Set up for exception handling.
 */
void jmi_throw() {
	jmi_t* jmi;

	jmi = jmi_get_current();
	longjmp(jmi->try_location, 1);
}


/**
 * \brief Print a node with single attribute to logger, using saved jmi_t struct.
 */
void jmi_global_log(int warning, const char* name, const char* fmt, const char* value) {
	jmi_t* jmi = jmi_get_current();
    jmi_log_node(jmi->log, warning ? logWarning : logInfo, name, fmt, value);
}

/**
 * \brief Allocate memory with user-supplied function, if any. Otherwise use calloc().
 */
void* jmi_global_calloc(size_t n, size_t s) {
	jmi_t* jmi = jmi_get_current();
	if (jmi->jmi_callbacks->allocate_memory != NULL) {
		return (char*) jmi->jmi_callbacks->allocate_memory(n, s);
	} else {
		return (char*) calloc(n, s);
	}
}

/**
 * Signal a failed assertion.
 *
 * If level is JMI_ASSERT_ERROR, then function will not return.
 */
void jmi_assert_failed(const char* msg, int level) {
	if (level == JMI_ASSERT_WARNING) {
		jmi_global_log(1, "AssertionWarning", "<msg:%s>", msg);
	} else if (level == JMI_ASSERT_ERROR) {
		jmi_global_log(1, "AssertionError", "<msg:%s>", msg);
		jmi_throw();
	}
}
