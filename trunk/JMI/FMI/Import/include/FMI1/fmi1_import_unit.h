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

/** \file fmi1_import_unit.h
*  \brief Public interface to the FMI XML C-library. Handling of variable units.
*/

#ifndef FMI1_IMPORT_UNIT_H_
#define FMI1_IMPORT_UNIT_H_

#include "fmi1_import.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Support for processing variable units */
fmi1_import_unit_definitions_t* fmi1_import_get_unit_definitions(fmi1_import_t* fmu);
unsigned int  fmi1_import_get_unit_definitions_number(fmi1_import_unit_definitions_t*);
fmi1_import_unit_t* fmi1_import_get_unit(fmi1_import_unit_definitions_t*, unsigned int  index);
const char* fmi1_import_get_unit_name(fmi1_import_unit_t*);
unsigned int fmi1_import_get_unit_display_unit_number(fmi1_import_unit_t*);
fmi1_import_display_unit_t* fmi1_import_get_unit_display_unit(fmi1_import_unit_t*, size_t index);

fmi1_import_display_unit_t* fmi1_import_get_type_display_unit(fmi1_import_real_typedef_t*);
fmi1_import_unit_t* fmi1_import_get_base_unit(fmi1_import_display_unit_t*);
const char* fmi1_import_get_display_unit_name(fmi1_import_display_unit_t*);
fmi1_real_t fmi1_import_get_display_unit_gain(fmi1_import_display_unit_t*);
fmi1_real_t fmi1_import_get_display_unit_offset(fmi1_import_display_unit_t*);

fmi1_real_t fmi1_import_convert_to_display_unit(fmi1_real_t, fmi1_import_display_unit_t*, int isRelativeQuantity);
fmi1_real_t fmi1_import_convert_from_display_unit(fmi1_real_t, fmi1_import_display_unit_t*, int isRelativeQuantity);

#ifdef __cplusplus
}
#endif
#endif
