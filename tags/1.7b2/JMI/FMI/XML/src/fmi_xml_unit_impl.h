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

#ifndef FMI_XML_UNITIMPL_H
#define FMI_XML_UNITIMPL_H

#include <jm_vector.h>
#include <jm_named_ptr.h>
#include "fmi_xml_model_description.h"
#include "fmi_xml_parser.h"
#ifdef __cplusplus
extern "C" {
#endif

/* Structure encapsulating base unit information */

struct fmi_xml_display_unit_t {
    fmiReal gain;
    fmiReal offset;
    fmi_xml_unit_t* baseUnit;
    char displayUnit[1];
};

struct fmi_xml_unit_t {
        jm_vector(jm_voidp) displayUnits;
        fmi_xml_display_unit_t defaultDisplay;
        char baseUnit[1];
};

struct fmi_xml_unit_definitions_t {
    jm_vector(jm_named_ptr) definitions;
};

fmi_xml_display_unit_t* fmi_xml_get_parsed_unit(fmi_xml_parser_context_t *context, jm_vector(char)* name, int sorted);

#ifdef __cplusplus
}
#endif

#endif /* FMI_XML_UNITIMPL_H */
