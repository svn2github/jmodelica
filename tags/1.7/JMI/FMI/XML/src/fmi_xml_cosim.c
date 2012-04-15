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
#include <jm_vector.h>
#include "fmi_xml_model_description_impl.h"
#include "fmi_xml_parser.h"

fmi_xml_fmu_kind_enu_t fmi_xml_get_fmu_kind(fmi_xml_model_description_t* md) {
    return md->fmuKind;
}

fmi_xml_capabilities_t* fmi_xml_get_capabilities(fmi_xml_model_description_t* md){
    return &md->capabilities;
}

size_t fmi_xml_get_number_of_additional_models(fmi_xml_model_description_t* md) {
    return jm_vector_get_size(jm_string)(&md->additionalModels);
}

const char* fmi_xml_get_additional_model_name(fmi_xml_model_description_t* md, size_t index) {
    if(fmi_xml_get_number_of_additional_models(md) <= index) return 0;
    return jm_vector_get_item(jm_string)(&md->additionalModels,index);
}


const char* fmi_xml_get_entry_point(fmi_xml_model_description_t* md) {
    return jm_vector_char2string(&md->entryPoint);
}

const char* fmi_xml_get_mime_type(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->mimeType);
}

int fmi_xml_get_manual_start(fmi_xml_model_description_t* md){
    return md->manual_start;
}


int fmi_xml_handle_Implementation(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_fmiModelDescription) {
            fmi_xml_parse_error(context, "Implementation XML element must be a part of fmiModelDescription");
            return -1;
        }
    }
    else {
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}

int fmi_xml_handle_CoSimulation_StandAlone(fmi_xml_parser_context_t *context, const char* data) {
    fmi_xml_model_description_t* md = context->modelDescription;
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_Implementation) {
            fmi_xml_parse_error(context, "CoSimulation_StandAlone XML element must be a part of Implementation");
            return -1;
        }
        md->fmuKind = fmi_xml_fmu_kind_enu_cs_standalone;
    }
    else {
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}



int fmi_xml_handle_CoSimulation_Tool(fmi_xml_parser_context_t *context, const char* data) {
    fmi_xml_model_description_t* md = context->modelDescription;
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_Implementation) {
            fmi_xml_parse_error(context, "CoSimulation_Tool XML element must be a part of Implementation");
            return -1;
        }
        md->fmuKind = fmi_xml_fmu_kind_enu_cs_tool;
    }
    else {
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}

int fmi_xml_handle_Model(fmi_xml_parser_context_t *context, const char* data) {
    fmi_xml_model_description_t* md = context->modelDescription;
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_CoSimulation_Tool) {
            fmi_xml_parse_error(context, "Model XML element must be a part of CoSimulation_Tool");
            return -1;
        }
        return (
        /* <xs:attribute name="entryPoint"  type="xs:anyURI" use="required"/> */
        fmi_xml_set_attr_string(context, fmi_xml_elmID_Model, fmi_attr_id_entryPoint, 1, &(md->entryPoint)) ||
        /* <xs:attribute name="manualStart" type="xs:boolean" default="false"/> */
        fmi_xml_set_attr_boolean(context,fmi_xml_elmID_Model,fmi_attr_id_manualStart,0,&md->manual_start,0) ||
        /* <xs:attribute name="type"        type="xs:string" use="required"/> */
        fmi_xml_set_attr_string(context, fmi_xml_elmID_Model, fmi_attr_id_type,1,&md->mimeType)
                    );
    }
    else {
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}

int fmi_xml_handle_File(fmi_xml_parser_context_t *context, const char* data) {
    fmi_xml_model_description_t* md = context->modelDescription;
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_CoSimulation_Tool) {
            fmi_xml_parse_error(context, "UnitDefinitions XML element must be a part of fmiModelDescription");
            return -1;
        }
        {
            jm_vector(char)* bufFileName = fmi_xml_get_parse_buffer(context,2);
            char* fileName = 0;
            jm_string* pname;
            size_t len;
            if(fmi_xml_set_attr_string(context, fmi_xml_elmID_Model, fmi_attr_id_file, 1, bufFileName))
                return -1;
            len = jm_vector_get_size_char(bufFileName);
            pname = jm_vector_push_back(jm_string)(&md->additionalModels,fileName);
            if(pname) *pname = fileName =  md->callbacks->malloc(len + 1);
            if(!pname || !fileName) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            memcpy(fileName, jm_vector_get_itemp(char)(bufFileName,0), len);
            fileName[len] = 0;
        }
    }
    else {
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}

