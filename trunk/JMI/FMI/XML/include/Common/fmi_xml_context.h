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



/** \file fmi_xml_context.h
*  \brief XML context is the entry point to the library. It is used to initialize, get FMI version and start parsing.
*/

#ifndef FMI_XML_CONTEXT_H_
#define FMI_XML_CONTEXT_H_

#include <stddef.h>
#include <jm_callbacks.h>
#include <FMI1/fmi1_xml_model_description.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct fmi_xml_context_t fmi_xml_context_t;

fmi_xml_context_t* fmi_xml_allocate_context( jm_callbacks* callbacks);

void fmi_xml_free_context(fmi_xml_context_t *context);

typedef enum
{ 
	fmi_version_unknown_enu = 0,
	fmi_version_1_enu,
	fmi_version_2_0_enu
} fmi_version_enu_t;

fmi_version_enu_t fmi_xml_get_fmi_version( fmi_xml_context_t*, const char* fileName);

fmi1_xml_model_description_t* fmi1_xml_parse( fmi_xml_context_t* c, const char* fileName);

#ifdef __cplusplus
}
#endif
#endif
