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



/** \file fmi_xml_type.h
*  \brief Public interface to the FMI XML C-library: variable types handling.
*/

#ifndef FMI_XML_TYPE_H_
#define FMI_XML_TYPE_H_

#include "fmi_xml_model_description.h"

#ifdef __cplusplus
extern "C" {
#endif

/* \defgroup Support for processing variable types
*  @{
*/

fmi_xml_display_unit_t* fmi_xml_get_type_display_unit(fmi_xml_real_typedef_t*);

fmi_xml_type_definitions_t* fmi_xml_get_type_definitions(fmi_xml_model_description_t* md);

/* Base types used in type definitions */
typedef enum fmi_xml_base_type_enu_t
{
        fmi_xml_base_type_enu_real,
        fmi_xml_base_type_enu_int,
        fmi_xml_base_type_enu_bool,
        fmi_xml_base_type_enu_str,
        fmi_xml_base_type_enu_enum
} fmi_xml_base_type_enu_t;

/* Convert base type constant to string */
const char* fmi_xml_base_type2string(fmi_xml_base_type_enu_t bt);

size_t fmi_xml_get_type_definition_number(fmi_xml_type_definitions_t* td);

fmi_xml_variable_typedef_t* fmi_xml_get_typedef(fmi_xml_type_definitions_t* td, unsigned int  index);

const char* fmi_xml_get_type_name(fmi_xml_variable_typedef_t*);

/* Note that NULL pointer is returned if the attribute is not present in the XML.*/
const char* fmi_xml_get_type_description(fmi_xml_variable_typedef_t*);

fmi_xml_base_type_enu_t fmi_xml_get_base_type(fmi_xml_variable_typedef_t*);

/* Boolean and String has no extra attributes -> not needed*/

fmi_xml_real_typedef_t* fmi_xml_ret_type_as_real(fmi_xml_variable_typedef_t*);
fmi_xml_integer_typedef_t* fmi_xml_get_type_as_int(fmi_xml_variable_typedef_t*);
fmi_xml_enumeration_typedef_t* fmi_xml_get_type_as_enum(fmi_xml_variable_typedef_t*);

/* Note that NULL-pointer is always returned for strings and booleans */
const char* fmi_xml_get_type_quantity(fmi_xml_variable_typedef_t*);

fmiReal fmi_xml_get_real_type_min(fmi_xml_real_typedef_t*);
fmiReal fmi_xml_get_real_type_max(fmi_xml_real_typedef_t*);
fmiReal fmi_xml_get_real_type_nominal(fmi_xml_real_typedef_t*);
fmi_xml_unit_t* fmi_xml_get_real_type_unit(fmi_xml_real_typedef_t*);
int fmi_xml_get_real_type_is_relative_quantity(fmi_xml_real_typedef_t*);

fmiInteger fmi_xml_get_integer_type_min(fmi_xml_integer_typedef_t*);
fmiInteger fmi_xml_get_integer_type_max(fmi_xml_integer_typedef_t*);

fmiInteger fmi_xml_get_enum_type_min(fmi_xml_enumeration_typedef_t*);
fmiInteger fmi_xml_get_enum_type_max(fmi_xml_enumeration_typedef_t*);
unsigned int  fmi_xml_get_enum_type_size(fmi_xml_enumeration_typedef_t*);
const char* fmi_xml_get_enum_type_item_name(fmi_xml_enumeration_typedef_t*, unsigned int  item);
const char* fmi_xml_get_enum_type_item_description(fmi_xml_enumeration_typedef_t*, unsigned int  item);

/*
*  @}
*/
#ifdef __cplusplus
}
#endif
#endif

