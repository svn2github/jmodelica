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

#ifndef FMI_XML_VENDORANNOTATIONS_H
#define FMI_XML_VENDORANNOTATIONS_H

#include <jm_named_ptr.h>

#include <fmi_xml_model_description.h>
#include <fmi_xml_vendor_annotations.h>

#ifdef __cplusplus
extern "C" {
#endif

struct fmi_xml_annotation_t {
    const char* name;
    char value[1];
};

struct fmi_xml_vendor_t {
    jm_vector(jm_named_ptr) annotations;
    char name[1];
};

void fmi_xml_vendor_free(fmi_xml_vendor_t* v);

struct fmi_xml_vendor_list_t {
    jm_vector(jm_voidp) vendors;
};

#ifdef __cplusplus
}
#endif

#endif /* FMI_XML_VENDORANNOTATIONS_H */
