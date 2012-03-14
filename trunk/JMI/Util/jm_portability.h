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

#ifndef JM_PORTABILITY_H_
#define JM_PORTABILITY_H_
#include <config.h>
/* Include platform dependent headers */
#if defined(_MSC_VER) || defined(WIN32)
#include <windows.h> /* Microsoft Windows API */
#define DLL_HANDLE HANDLE
#else
#define DLL_HANDLE void*
#include <dlfcn.h>  /* Standard POSIX/UNIX API */
#endif

#include "jm_types.h"
DLL_HANDLE		jm_portability_load_dll_handle		(const char* dll_file_path);
jm_status_enu_t jm_portability_free_dll_handle		(DLL_HANDLE dll_handle);
jm_status_enu_t jm_portability_load_dll_function	(DLL_HANDLE dll_handle, char* dll_function_name, void** dll_function_ptrptr);
char*			jm_portability_get_last_dll_error	(void);

#endif /* End of header file JM_PORTABILITY_H_ */
