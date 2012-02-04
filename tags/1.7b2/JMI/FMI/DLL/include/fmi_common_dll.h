/*
    Copyright (C) 2009 Modelon AB

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


#ifndef FMI_COMMON_DLL_H
#define FMI_COMMON_DLL_H

#include "fmi_common_types_dll.h"

DLLFMU*		fmi_common_dll_create_DLLFMU(const char* dllPath, const char* modelIdentifier, fmiCallbackFunctions callBackFunctions, fmiStandard standard);
callStatus	fmi_common_dll_load_DLLFMU(DLLFMU* fmu);
void		fmi_common_dll_free_DLLFMU(DLLFMU* fmu);
void		fmi_common_dll_destroy_DLLFMU(DLLFMU* fmu);

#endif /* End of header file FMI_COMMON_DLL_H */