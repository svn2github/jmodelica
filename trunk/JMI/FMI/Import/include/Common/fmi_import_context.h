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


/** \file fmi_import_context.h
*  \brief Import context is the entry point to the library. It is used to initialize, get FMI version and start parsing.
*/

#ifndef FMI_IMPORT_CONTEXT_H_
#define FMI_IMPORT_CONTEXT_H_

#include <stddef.h>
#include <jm_callbacks.h>
#include <Common/fmi_xml_context.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef fmi_xml_context_t fmi_import_context_t ;

static fmi_import_context_t* fmi_import_allocate_context( jm_callbacks* callbacks) {
	return fmi_xml_allocate_context(callbacks);
}

fmi_version_enu_t fmi_import_get_fmi_version( fmi_import_context_t*, const char* fileName, const char* dirName);

typedef struct fmi1_import_t fmi1_import_t;
fmi1_import_t* fmi1_import_parse_xml( fmi_import_context_t* c, const char* dirName);

#ifdef __cplusplus
}
#endif
#endif

struct fmi_xml_context_t {
	jm_callbacks* callbacks;

	fmi_version_enu_t fmiVersion;
};