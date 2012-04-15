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

#include <stdio.h>

#include <jm_named_ptr.h>
#include "fmi_xml_model_description_impl.h"
#include "fmi_xml_variable_list_impl.h"
#include "fmi_xml_vendor_annotations_impl.h"
#include "fmi_xml_parser.h"

fmi_xml_model_description_t * fmi_xml_allocate_model_description( jm_callbacks* callbacks) {
    jm_callbacks* cb;
    fmi_xml_model_description_t* md;

    if(callbacks) {
        cb = callbacks;
    }
    else {
        cb = jm_get_default_callbacks();
    }
    md = cb->malloc(sizeof(fmi_xml_model_description_t));
    if(!md) return 0;

    md->callbacks = cb;
    md->errMessageBuf[0] = 0;

    md->status = fmi_xml_model_description_enu_empty;

    jm_vector_init(char)( & md->fmi_xml_standard_version, 0,cb);
    jm_vector_init(char)(&md->modelName, 0,cb);
    jm_vector_init(char)(&md->modelIdentifier, 0,cb);
    jm_vector_init(char)(&md->GUID, 0,cb);
    jm_vector_init(char)(&md->description, 0,cb);
    jm_vector_init(char)(&md->author, 0,cb);
    jm_vector_init(char)(&md->version, 0,cb);
    jm_vector_init(char)(&md->generationTool, 0,cb);
    jm_vector_init(char)(&md->generationDateAndTime, 0,cb);


    md->namingConvension = fmi_xml_naming_enu_flat;
    md->numberOfContinuousStates = 0;
    md->numberOfEventIndicators = 0;

    md->defaultExperimentStartTime = 0;

    md->defaultExperimentStopTime = 1.0;

    md->defaultExperimentTolerance = 1e-6;

    jm_vector_init(jm_voidp)(&md->vendorList, 0, cb);

    jm_vector_init(jm_named_ptr)(&md->unitDefinitions, 0, cb);
    jm_vector_init(jm_named_ptr)(&md->displayUnitDefinitions, 0, cb);

    fmi_xml_init_type_definitions(&md->typeDefinitions, cb);

    jm_vector_init(jm_named_ptr)(&md->variables, 0, cb);

    md->variablesByVR = 0;

    jm_vector_init(jm_string)(&md->descriptions, 0, cb);

    md->fmuKind = fmi_xml_fmu_kind_enu_me;

    fmi_xml_init_capabilities(&md->capabilities);

    jm_vector_init(jm_string)(&md->additionalModels, 0, cb);

    jm_vector_init(char)(&md->entryPoint, 0,cb);
    jm_vector_init(char)(&md->mimeType, 0,cb);

    return md;
}



void fmi_xml_clear_model_description( fmi_xml_model_description_t* md) {
    md->errMessageBuf[0] = 0;

    md->status = fmi_xml_model_description_enu_empty;
    jm_vector_free_data(char)(&md->fmi_xml_standard_version);
    jm_vector_free_data(char)(&md->modelName);
    jm_vector_free_data(char)(&md->modelIdentifier);
    jm_vector_free_data(char)(&md->GUID);
    jm_vector_free_data(char)(&md->description);
    jm_vector_free_data(char)(&md->author);
    jm_vector_free_data(char)(&md->version);
    jm_vector_free_data(char)(&md->generationTool);
    jm_vector_free_data(char)(&md->generationDateAndTime);

    md->namingConvension = fmi_xml_naming_enu_flat;
    md->numberOfContinuousStates = 0;
    md->numberOfEventIndicators = 0;

    md->defaultExperimentStartTime = 0;

    md->defaultExperimentStopTime = 0;

    md->defaultExperimentTolerance = 0;

    jm_vector_foreach(jm_voidp)(&md->vendorList, (void(*)(void*))fmi_xml_vendor_free);
    jm_vector_free_data(jm_voidp)(&md->vendorList);

    jm_named_vector_free_data(&md->unitDefinitions);
    jm_named_vector_free_data(&md->displayUnitDefinitions);

    fmi_xml_free_type_definitions_data(&md->typeDefinitions);

    jm_vector_foreach(jm_named_ptr)(&md->variables, fmi_xml_free_direct_dependencies);
    jm_named_vector_free_data(&md->variables);
    if(md->variablesByVR) fmi_xml_free_variable_list(md->variablesByVR);

    jm_vector_foreach(jm_string)(&md->descriptions, (void(*)(const char*))md->callbacks->free);
    jm_vector_free_data(jm_string)(&md->descriptions);

    jm_vector_foreach(jm_string)(&md->additionalModels, (void(*)(const char*))md->callbacks->free);
    jm_vector_free_data(jm_string)(&md->additionalModels);

    jm_vector_free_data(char)(&md->entryPoint);
    jm_vector_free_data(char)(&md->mimeType);

}

int fmi_xml_is_model_description_empty(fmi_xml_model_description_t* md) {
    return (md->status == fmi_xml_model_description_enu_empty);
}

const char* fmi_xml_get_last_error(fmi_xml_model_description_t* md) {
    return md->errMessageBuf;
}

int fmi_xml_clear_last_error(fmi_xml_model_description_t* md) {
    md->errMessageBuf[0] = 0;
    return (md->status != fmi_xml_model_description_enu_error);
}

void fmi_xml_free_model_description(fmi_xml_model_description_t* md) {
    jm_callbacks* cb = md->callbacks;
    fmi_xml_clear_model_description(md);
    cb->free(md);
}

const char* fmi_xml_get_model_name(fmi_xml_model_description_t* md) {
    return jm_vector_char2string(&md->modelName);
}

const char* fmi_xml_get_model_identifier(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->modelIdentifier);
}

const char* fmi_xml_get_GUID(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->GUID);
}

const char* fmi_xml_get_description(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->description);
}

const char* fmi_xml_get_author(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->author);
}

const char* fmi_xml_get_model_standard_version(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->fmi_xml_standard_version);
}


const char* fmi_xml_get_model_version(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->version);
}

const char* fmi_xml_get_generation_tool(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->generationTool);
}

const char* fmi_xml_get_generation_date_and_time(fmi_xml_model_description_t* md){
    return jm_vector_char2string(&md->generationDateAndTime);
}

fmi_xml_variable_naming_convension_enu_t fmi_xml_get_naming_convention(fmi_xml_model_description_t* md) {
    return md->namingConvension;
}


unsigned int fmi_xml_get_number_of_continuous_states(fmi_xml_model_description_t* md) {
    return md->numberOfContinuousStates;
}

unsigned int fmi_xml_get_number_of_event_indicators(fmi_xml_model_description_t* md) {
    return md->numberOfEventIndicators;
}

double fmi_xml_get_default_experiment_start(fmi_xml_model_description_t* md) {
    return md->defaultExperimentStartTime;
}

void fmi_xml_set_default_experiment_start(fmi_xml_model_description_t* md, double t){
    md->defaultExperimentStartTime = t;
}

double fmi_xml_get_default_experiment_stop(fmi_xml_model_description_t* md){
    return md->defaultExperimentStopTime;
}

void fmi_xml_set_default_experiment_stop(fmi_xml_model_description_t* md, double t){
    md->defaultExperimentStopTime = t;
}

double fmi_xml_get_default_experiment_tolerance(fmi_xml_model_description_t* md){
    return md->defaultExperimentTolerance;
}

void fmi_xml_set_default_experiment_tolerance(fmi_xml_model_description_t* md, double tol){
    md->defaultExperimentTolerance = tol;
}

fmi_xml_vendor_list_t* fmi_xml_get_vendor_list(fmi_xml_model_description_t* md) {
    return (fmi_xml_vendor_list_t*)&md->vendorList;
}

unsigned int  fmi_xml_get_number_of_vendors(fmi_xml_vendor_list_t* vl) {
    return jm_vector_get_size(jm_voidp)(&vl->vendors);
}

fmi_xml_vendor_t* fmi_xml_get_vendor(fmi_xml_vendor_list_t* v, unsigned int  index) {
    jm_vector(jm_voidp)* vl = &v->vendors;
    if(index >= jm_vector_get_size(jm_voidp)(vl)) return 0;
    return jm_vector_get_item(jm_voidp)(vl, index);
}

fmi_xml_unit_definitions_t* fmi_xml_get_unit_definitions(fmi_xml_model_description_t* md) {
    return (fmi_xml_unit_definitions_t*)(&md->unitDefinitions);
}

unsigned int  fmi_xml_get_unit_definitions_number(fmi_xml_unit_definitions_t* ud) {
    return jm_vector_get_size(jm_named_ptr)(&ud->definitions);
}

fmi_xml_type_definitions_t* fmi_xml_get_type_definitions(fmi_xml_model_description_t* md) {
    return &md->typeDefinitions;
}

void fmi_xml_report_error(fmi_xml_model_description_t* md, const char* module, const char* fmt, ...){
    va_list args;
    va_start (args, fmt);
    fmi_xml_report_error_v(md, module, fmt, args);
    va_end (args);
}

void fmi_xml_report_error_v(fmi_xml_model_description_t* md, const char* module, const char* fmt, va_list ap) {
    vsprintf(md->errMessageBuf, fmt, ap);
    if(md->callbacks->logger)
        md->callbacks->logger(md, module, 0, "ERROR", md->errMessageBuf);
}

void fmi_xml_report_warning(fmi_xml_model_description_t* md, const char* module, const char* fmt, ...){
    va_list args;
    va_start (args, fmt);
    fmi_xml_report_warning_v(md, module, fmt, args);
    va_end (args);
}

void fmi_xml_report_warning_v(fmi_xml_model_description_t* md, const char* module, const char* fmt, va_list ap){
    vsprintf(md->errMessageBuf, fmt, ap);
    if(md->callbacks->logger)
        md->callbacks->logger(md, module, 0, "WARNING", md->errMessageBuf);
}


/* Get the list of all the variables in the model */
fmi_xml_variable_list_t* fmi_xml_get_variable_list(fmi_xml_model_description_t* md) {
    fmi_xml_variable_list_t* vl;
    size_t nv, i;
    if(md->status != fmi_xml_model_description_enu_ok) return 0;
    nv = jm_vector_get_size(jm_named_ptr)(&md->variables);
    vl = fmi_xml_alloc_variable_list(md->callbacks, nv);
    if(!vl) return 0;
    for(i = 0; i< nv; i++) {
        jm_vector_set_item(jm_voidp)(&vl->variables, i, jm_vector_get_item(jm_named_ptr)(&md->variables, i).ptr);
    }
    return vl;
}


int fmi_xml_handle_fmiModelDescription(fmi_xml_parser_context_t *context, const char* data) {
    jm_name_ID_map_t namingConventionMap[] = {{"flat",fmi_xml_naming_enu_flat},{"structured", fmi_xml_naming_enu_structured},{0,0}};
    fmi_xml_model_description_t* md = context->modelDescription;

    if(!data) {
        if(context -> currentElmHandle != 0) {
            fmi_xml_parse_error(context, "fmi_xml_model_description must be the root XML element");
            return -1;
        }
        /* process the attributes */
        return (
                    /* <xs:attribute name="fmiVersion" type="xs:normalizedString" use="required" fixed="1.0"/> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_fmiVersion, 1, &(md->fmi_xml_standard_version)) ||
                    /* <xs:attribute name="modelName" type="xs:normalizedString" use="required"> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_modelName, 1, &(md->modelName)) ||
                    /* <xs:attribute name="modelIdentifier" type="xs:normalizedString" use="required"> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_modelIdentifier, 1, &(md->modelIdentifier)) ||
                    /* <xs:attribute name="guid" type="xs:normalizedString" use="required"> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_guid, 1, &(md->GUID)) ||
                    /* <xs:attribute name="description" type="xs:string"/> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_description, 0, &(md->description)) ||
                    /* <xs:attribute name="author" type="xs:string"/> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_author, 0, &(md->author)) ||
                    /* <xs:attribute name="version" type="xs:normalizedString"> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_version, 0, &(md->version)) ||
                    /* <xs:attribute name="generationTool" type="xs:normalizedString"/> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_generationTool, 0, &(md->generationTool)) ||
                    /* <xs:attribute name="generationDateAndTime" type="xs:dateTime"/> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_generationDateAndTime, 0, &(md->generationDateAndTime)) ||
                    /* <xs:attribute name="variableNamingConvention" use="optional" default="flat"> */
                    fmi_xml_set_attr_enum(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_variableNamingConvention, 0, &(md->namingConvension), fmi_xml_naming_enu_flat, namingConventionMap) ||
                    /* <xs:attribute name="numberOfContinuousStates" type="xs:unsignedInt" use="required"/> */
                    fmi_xml_set_attr_uint(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_numberOfContinuousStates, 1, &(md->numberOfContinuousStates),0) ||
                    /* <xs:attribute name="numberOfEventIndicators" type="xs:unsignedInt" use="required"/> */
                    fmi_xml_set_attr_uint(context, fmi_xml_elmID_fmiModelDescription, fmi_attr_id_numberOfEventIndicators, 1, &(md->numberOfEventIndicators),0)
                    );
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
}

int fmi_xml_handle_DefaultExperiment(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        if(  context -> currentElmHandle != fmi_xml_handle_fmiModelDescription)
        {
            fmi_xml_parse_error(context, "DefaultExperiment XML element must be a part of fmiModelDescription");
            return -1;
        }
        if(  (context -> lastElmHandle != 0) &&
             (context -> lastElmHandle != fmi_xml_handle_TypeDefinitions) &&
              (context->lastElmHandle != fmi_xml_handle_UnitDefinitions)
                )
        {
            fmi_xml_parse_error(context, "DefaultExperiment XML element must either be the first or follow TypeDefinitions or UnitDefinitions");
            return -1;
        }
        /* process the attributes */
        return (
        /* <xs:attribute name="startTime" type="xs:double"/> */
                    fmi_xml_set_attr_double(context, fmi_xml_elmID_DefaultExperiment, fmi_attr_id_startTime, 0, &md->defaultExperimentStartTime, 0) ||
        /* <xs:attribute name="stopTime" type="xs:double"/>  */
                    fmi_xml_set_attr_double(context, fmi_xml_elmID_DefaultExperiment, fmi_attr_id_stopTime, 0, &md->defaultExperimentStopTime, 1) ||
        /* <xs:attribute name="tolerance" type="xs:double">  */
                    fmi_xml_set_attr_double(context, fmi_xml_elmID_DefaultExperiment, fmi_attr_id_tolerance, 0, &md->defaultExperimentTolerance, 1e-6)
                    );
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}
