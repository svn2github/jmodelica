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


#ifndef FMI_DLL_COMMON_H_
#define FMI_DLL_COMMON_H_

#include "fmi_dll_types.h"
#include "jm_types.h"

fmi_dll_t*		fmi_dll_common_create_dllfmu(const char* dllPath, const char* modelIdentifier, fmiCallbackFunctions callBackFunctions, fmi_dll_standard_enu_t standard);
jm_status_enu_t	fmi_dll_common_load_dll(fmi_dll_t* fmu);
const char*		fmi_dll_common_get_last_error(fmi_dll_t* fmu);
jm_status_enu_t	fmi_dll_common_load_fcn(fmi_dll_t* fmu);
void			fmi_dll_common_free_dll(fmi_dll_t* fmu);
void			fmi_dll_common_destroy_dllfmu(fmi_dll_t* fmu);

#endif /* End of header file FMI_DLL_COMMON_H_ */