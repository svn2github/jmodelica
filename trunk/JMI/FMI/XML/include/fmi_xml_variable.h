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



/** \file fmi_xml_variable.h
*  \brief Public interface to the FMI XML C-library. Handling of model variables.
*/

#ifndef FMI_XML_VARIABLE_H_
#define FMI_XML_VARIABLE_H_

#include "fmi_xml_model_description.h"
#include "fmi_xml_type.h"


#ifdef __cplusplus
extern "C" {
#endif

const char* fmi_xml_get_variable_name(fmi_xml_variable_t*);
const char* fmi_xml_get_variable_description(fmi_xml_variable_t*);

fmi_xml_value_reference_t fmi_xml_get_variable_vr(fmi_xml_variable_t*);

/*
    For scalar variable gives the type definition is present
*/
fmi_xml_variable_typedef_t* fmi_xml_get_variable_declared_type(fmi_xml_variable_t*);
fmi_xml_base_type_enu_t fmi_xml_get_variable_base_type(fmi_xml_variable_t*);

int   fmi_xml_get_variable_has_start(fmi_xml_variable_t*);
int   fmi_xml_get_variable_is_fixed(fmi_xml_variable_t*);

typedef enum fmi_xml_variability_enu_t {
        fmi_xml_variability_enu_constant,
        fmi_xml_variability_enu_parameter,
        fmi_xml_variability_enu_discrete,
        fmi_xml_variability_enu_continuous
} fmi_xml_variability_enu_t;

const char* fmi_xml_variability_to_string(fmi_xml_variability_enu_t v);

fmi_xml_variability_enu_t fmi_xml_get_variability(fmi_xml_variable_t*);

typedef enum fmi_xml_causality_enu_t {
        fmi_xml_causality_enu_input,
        fmi_xml_causality_enu_output,
        fmi_xml_causality_enu_internal,
        fmi_xml_causality_enu_none
} fmi_xml_causality_enu_t;

const char* fmi_xml_causality_to_string(fmi_xml_causality_enu_t c);

fmi_xml_causality_enu_t fmi_xml_get_causality(fmi_xml_variable_t*);

/* DirectDependency is returned for variables with causality Output. Null pointer for others. */
fmi_xml_variable_list_t* fmi_xml_get_direct_dependency(fmi_xml_variable_t*);

fmi_xml_real_variable_t* fmi_xml_get_variable_as_real(fmi_xml_variable_t*);
fmi_xml_integer_variable_t* fmi_xml_get_variable_as_integer(fmi_xml_variable_t*);
fmi_xml_enum_variable_t* fmI_xml_get_variable_as_enum(fmi_xml_variable_t*);
fmi_xml_string_variable_t* fmi_xml_get_variable_as_string(fmi_xml_variable_t*);
fmi_xml_bool_variable_t* fmi_xml_get_variable_as_boolean(fmi_xml_variable_t*);

fmi_xml_real_t fmi_xml_get_real_variable_start(fmi_xml_real_variable_t* v);
fmi_xml_real_t fmi_xml_get_real_variable_max(fmi_xml_real_variable_t* v);
fmi_xml_real_t fmi_xml_get_real_variable_min(fmi_xml_real_variable_t* v);
fmi_xml_real_t fmi_xml_get_real_variable_nominal(fmi_xml_real_variable_t* v);
fmi_xml_unit_t* fmi_xml_get_real_variable_unit(fmi_xml_real_variable_t* v);
fmi_xml_display_unit_t* fmi_xml_get_real_variable_display_unit(fmi_xml_real_variable_t* v);

const char* fmi_xml_get_string_variable_start(fmi_xml_string_variable_t* v);
fmiBoolean fmi_xml_get_boolean_variable_start(fmi_xml_bool_variable_t* v);

fmi_xml_int_t fmi_xml_get_integer_variable_start(fmi_xml_integer_variable_t* v);
fmi_xml_int_t fmi_xml_get_integer_variable_min(fmi_xml_integer_variable_t* v);
fmi_xml_int_t fmi_xml_get_integer_variable_max(fmi_xml_integer_variable_t* v);

fmi_xml_int_t fmi_xml_get_enum_variable_start(fmi_xml_enum_variable_t* v);
fmi_xml_int_t fmi_xml_get_enum_variable_min(fmi_xml_enum_variable_t* v);
fmi_xml_int_t fmi_xml_get_enum_variable_max(fmi_xml_enum_variable_t* v);


typedef enum fmi_xml_variable_alias_kind_enu_t {
    fmi_xml_variable_is_negated_alias = -1,
    fmi_xml_variable_is_not_alias = 0,
    fmi_xml_variable_is_alias = 1
} fmi_xml_variable_alias_kind_enu_t;

fmi_xml_variable_alias_kind_enu_t fmi_xml_get_variable_alias_kind(fmi_xml_variable_t*);
fmi_xml_variable_t* fmi_xml_get_variable_alias_base(fmi_xml_model_description_t* md,fmi_xml_variable_t*);

/*
    Return the list of all the variables aliased to the given one (including the base one.
    The list is ordered: base variable, aliases, negated aliases.
*/
fmi_xml_variable_list_t* fmi_xml_get_variable_aliases(fmi_xml_model_description_t* md,fmi_xml_variable_t*);

#ifdef __cplusplus
}
#endif
#endif
