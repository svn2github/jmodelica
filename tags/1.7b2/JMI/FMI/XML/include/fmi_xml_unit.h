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

/** \file fmi_xml_unit.h
*  \brief Public interface to the FMI XML C-library. Handling of variable units.
*/

#ifndef FMI_XML_UNIT_H_
#define FMI_XML_UNIT_H_

#include "fmi_xml_model_description.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Support for processing variable units */
fmi_xml_unit_definitions_t* fmi_xml_get_unit_definitions(fmi_xml_model_description_t* md);
unsigned int  fmi_xml_get_unit_definitions_number(fmi_xml_unit_definitions_t*);
fmi_xml_unit_t* fmi_xml_get_unit(fmi_xml_unit_definitions_t*, unsigned int  index);
const char* fmi_xml_get_unit_name(fmi_xml_unit_t*);
unsigned int fmi_xml_get_unit_display_unit_number(fmi_xml_unit_t*);
fmi_xml_display_unit_t* fmi_xml_get_unit_display_unit(fmi_xml_unit_t*, size_t index);

fmi_xml_display_unit_t* fmi_xml_get_type_display_unit(fmi_xml_real_typedef_t*);
fmi_xml_unit_t* fmi_xml_get_base_unit(fmi_xml_display_unit_t*);
const char* fmi_xml_get_display_unit_name(fmi_xml_display_unit_t*);
fmiReal fmi_xml_get_display_unit_gain(fmi_xml_display_unit_t*);
fmiReal fmi_xml_get_display_unit_offset(fmi_xml_display_unit_t*);

fmiReal fmi_xml_convert_to_display_unit(fmiReal, fmi_xml_display_unit_t*, int isRelativeQuantity);
fmiReal fmi_xml_convert_from_display_unit(fmiReal, fmi_xml_display_unit_t*, int isRelativeQuantity);

#ifdef __cplusplus
}
#endif
#endif
