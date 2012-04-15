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

#include <string.h>

#include "fmi_xml_parser.h"
#include "fmi_xml_model_description_impl.h"
#include "fmi_xml_vendor_annotations_impl.h"

void fmi_xml_vendor_free(fmi_xml_vendor_t* v) {
    jm_named_vector_free_data(&v->annotations);
    v->annotations.callbacks->free(v);
}

const char* fmi_xml_get_vendor_name(fmi_xml_vendor_t* v) {
    return v->name;
}

unsigned int  fmi_xml_get_number_of_vendor_annotations(fmi_xml_vendor_t* v) {
    return jm_vector_get_size(jm_named_ptr)(&v->annotations);
}

fmi_xml_annotation_t* fmi_xml_get_vendor_annotation(fmi_xml_vendor_t* v, unsigned int  index) {
    if(index >= fmi_xml_get_number_of_vendor_annotations(v)) return 0;
    return jm_vector_get_item(jm_named_ptr)(&v->annotations, index).ptr;
}

const char* fmi_xml_get_annotation_name(fmi_xml_annotation_t* a) {
    return a->name;
}

const char* fmi_xml_get_annotation_value(fmi_xml_annotation_t* a) {
    return a->value;
}

int fmi_xml_handle_VendorAnnotations(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_fmiModelDescription) {
            fmi_xml_parse_error(context, "VendorAnnotations XML element must be a part of fmiModelDescription");
            return -1;
        }
    }
    else {
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}

int fmi_xml_handle_Tool(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_VendorAnnotations) {
            fmi_xml_parse_error(context, "Tool XML element must be a part of VendorAnnotations");
            return -1;
        }
        {            
            fmi_xml_model_description_t* md = context->modelDescription;
            jm_vector(char)* bufName = fmi_xml_reserve_parse_buffer(context,1,100);
            fmi_xml_vendor_t* vendor = 0;
            fmi_xml_vendor_t dummyV;
            jm_voidp *pvendor;

            if(!bufName) return -1;
            /* <xs:attribute name="name" type="xs:normalizedString" use="required"> */
            if( fmi_xml_set_attr_string(context, fmi_xml_elmID_Tool, fmi_attr_id_name, 1, bufName)) return -1;
            pvendor = jm_vector_push_back(jm_voidp)(&md->vendorList, vendor);
            if(pvendor )
                *pvendor = vendor = jm_named_alloc_v(bufName,sizeof(fmi_xml_vendor_t), dummyV.name - (char*)&dummyV, context->callbacks).ptr;
            if(!pvendor || !vendor) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            jm_vector_init(jm_named_ptr)(&vendor->annotations,0, context->callbacks);
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}
int fmi_xml_handle_Annotation(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_Tool) {
            fmi_xml_parse_error(context, "Annotation XML element must be a part of Tool");
            return -1;
        }

        {
            fmi_xml_model_description_t* md = context->modelDescription;
            size_t numVendors = jm_vector_get_size(jm_voidp)(&(md->vendorList));
            fmi_xml_vendor_t* vendor =jm_vector_get_item(jm_voidp)(&(md->vendorList), numVendors-1);
            jm_vector(char)* bufName = fmi_xml_reserve_parse_buffer(context,1,100);
            jm_vector(char)* bufValue = fmi_xml_reserve_parse_buffer(context,2,100);
            jm_named_ptr named, *pnamed;
            fmi_xml_annotation_t* annotation = 0;
            size_t vallen;

            if(!bufName || !bufValue ||
            /*     <xs:attribute name="name" type="xs:normalizedString" use="required"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_Annotation, fmi_attr_id_name, 1, bufName) ||
            /* <xs:attribute name="value" type="xs:string" use="required"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_Annotation, fmi_attr_id_value, 1, bufValue)
                    )
                return -1;
            vallen = jm_vector_get_size(char)(bufValue);
            named.ptr = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&vendor->annotations, named);

            if(pnamed) *pnamed = named = jm_named_alloc_v(bufName,sizeof(fmi_xml_annotation_t)+vallen+1,sizeof(fmi_xml_annotation_t)+vallen,context->callbacks);
            annotation = named.ptr;
            if( !pnamed || !annotation ) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            annotation->name = named.name;
            if(vallen)
                memcpy(annotation->value,jm_vector_get_itemp(char)(bufValue,0), vallen);
            annotation->value[vallen] = 0;
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

