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

#ifndef FMI_IMPORT_UTIL_H_
#define FMI_IMPORT_UTIL_H_

#include "fmi_functions.h"

char* fmi_import_get_dll_path(char* fmu_unzipped_path, char* model_identifier, fmiCallbackFunctions callBackFunctions);
char* fmi_import_get_model_description_path(char* fmu_unzipped_path, fmiCallbackFunctions callBackFunctions);

#endif /* End of header file FMI_IMPORT_UTIL_H_ */