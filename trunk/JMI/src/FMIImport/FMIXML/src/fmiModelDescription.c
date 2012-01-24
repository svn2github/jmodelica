#include <stdio.h>

#include <jm_named_ptr.h>
#include "fmiCallbacks.h"
#include "fmiModelDescriptionImpl.h"
#include "fmiVariableListImpl.h"
#include "fmiVendorAnnotationsImpl.h"
#include "fmiXMLParser.h"

fmiModelDescription * fmiAllocateModelDescription( fmiCallbackFunctions* callbacks) {
    jm_callbacks* cb;
    fmiModelDescription* md;
    fmiCallbacks fmiCB;
    if(callbacks) {
        fmiInitCallbacks(&fmiCB, callbacks);
        cb = &fmiCB.jmFunctions;
    }
    else {
        cb = jm_get_default_callbacks();
    }
    md = cb->malloc(sizeof(fmiModelDescription));
    if(!md) return 0;
    if(callbacks) {
        md->fmiCallbacksMap = fmiCB;
    }
    md->callbacks = cb;
    md->errMessageBuf[0] = 0;

    md->status = fmiModelDescriptionEmpty;

    jm_vector_init(char)( & md->fmiStandardVersion, 0,cb);
    jm_vector_init(char)(&md->modelName, 0,cb);
    jm_vector_init(char)(&md->modelIdentifier, 0,cb);
    jm_vector_init(char)(&md->GUID, 0,cb);
    jm_vector_init(char)(&md->description, 0,cb);
    jm_vector_init(char)(&md->author, 0,cb);
    jm_vector_init(char)(&md->version, 0,cb);
    jm_vector_init(char)(&md->generationTool, 0,cb);
    jm_vector_init(char)(&md->generationDateAndTime, 0,cb);

    md->namingConvension = fmiNamingFlat;
    md->numberOfContinuousStates = 0;
    md->numberOfEventIndicators = 0;

    md->defaultExperimentStartTime = 0;

    md->defaultExperimentStopTime = 1.0;

    md->defaultExperimentTolerance = 1e-6;

    jm_vector_init(jm_voidp)(&md->vendorList, 0, cb);

    jm_vector_init(jm_named_ptr)(&md->unitDefinitions, 0, cb);
    jm_vector_init(jm_named_ptr)(&md->displayUnitDefinitions, 0, cb);

    fmiInitTypeDefinitions(&md->typeDefinitions, cb);

    jm_vector_init(jm_named_ptr)(&md->variables, 0, cb);

    md->variablesByVR = 0;

    jm_vector_init(jm_string)(&md->descriptions, 0, cb);

    return md;
}


void fmiClearModelDescription( fmiModelDescription* md) {
    md->errMessageBuf[0] = 0;

    md->status = fmiModelDescriptionEmpty;
    jm_vector_free_data(char)(&md->fmiStandardVersion);
    jm_vector_free_data(char)(&md->modelName);
    jm_vector_free_data(char)(&md->modelIdentifier);
    jm_vector_free_data(char)(&md->GUID);
    jm_vector_free_data(char)(&md->description);
    jm_vector_free_data(char)(&md->author);
    jm_vector_free_data(char)(&md->version);
    jm_vector_free_data(char)(&md->generationTool);
    jm_vector_free_data(char)(&md->generationDateAndTime);

    md->namingConvension = fmiNamingFlat;
    md->numberOfContinuousStates = 0;
    md->numberOfEventIndicators = 0;

    md->defaultExperimentStartTime = 0;

    md->defaultExperimentStopTime = 0;

    md->defaultExperimentTolerance = 0;

    jm_vector_foreach(jm_voidp)(&md->vendorList, (void(*)(void*))fmiVendorFree);
    jm_vector_free_data(jm_voidp)(&md->vendorList);

    jm_named_vector_free_data(&md->unitDefinitions);
    jm_named_vector_free_data(&md->displayUnitDefinitions);

    fmiFreeTypeDefinitionsData(&md->typeDefinitions);

    jm_named_vector_free_data(&md->variables);
    if(md->variablesByVR) fmiFreeVariableList(md->variablesByVR);

    jm_vector_foreach(jm_string)(&md->descriptions, (void(*)(const char*))md->descriptions.callbacks->free);
    jm_vector_free_data(jm_string)(&md->descriptions);
}

int fmiIsEmpty(fmiModelDescription* md) {
    return (md->status == fmiModelDescriptionEmpty);
}

const char* fmiGetLastError(fmiModelDescription* md) {
    return md->errMessageBuf;
}

int fmiClearLastError(fmiModelDescription* md) {
    md->errMessageBuf[0] = 0;
    return (md->status != fmiModelDescriptionError);
}

void fmiFreeModelDescription(fmiModelDescription* md) {
    jm_callbacks* cb = md->callbacks;
    fmiClearModelDescription(md);
    cb->free(md);
}

const char* fmiGetModelName(fmiModelDescription* md) {
    return jm_vector_char2string(&md->modelName);
}

const char* fmiGetModelIdentifier(fmiModelDescription* md){
    return jm_vector_char2string(&md->modelIdentifier);
}

const char* fmiGetGUID(fmiModelDescription* md){
    return jm_vector_char2string(&md->GUID);
}

const char* fmiGetDesciption(fmiModelDescription* md){
    return jm_vector_char2string(&md->description);
}

const char* fmiGetAuthor(fmiModelDescription* md){
    return jm_vector_char2string(&md->author);
}

const char* fmiGetModelStandardVersion(fmiModelDescription* md){
    return jm_vector_char2string(&md->fmiStandardVersion);
}


const char* fmiGetModelVersion(fmiModelDescription* md){
    return jm_vector_char2string(&md->version);
}

const char* fmiGetGenerationTool(fmiModelDescription* md){
    return jm_vector_char2string(&md->generationTool);
}

const char* fmiGetGenerationDateAndTime(fmiModelDescription* md){
    return jm_vector_char2string(&md->generationDateAndTime);
}

fmiVariableNamingConvension fmiGetNamingConvension(fmiModelDescription* md) {
    return md->namingConvension;
}


unsigned int fmiGetNumberOfContinuousStates(fmiModelDescription* md) {
    return md->numberOfContinuousStates;
}

unsigned int fmiGetNumberOfEventIndicators(fmiModelDescription* md) {
    return md->numberOfEventIndicators;
}

double fmiGetDefaultExperimentStartTime(fmiModelDescription* md) {
    return md->defaultExperimentStartTime;
}

void fmiSetDefaultExperimentStartTime(fmiModelDescription* md, double t){
    md->defaultExperimentStartTime = t;
}

double fmiGetDefaultExperimentStopTime(fmiModelDescription* md){
    return md->defaultExperimentStopTime;
}

void fmiSetDefaultExperimentStopTime(fmiModelDescription* md, double t){
    md->defaultExperimentStopTime = t;
}

double fmiGetDefaultExperimentTolerance(fmiModelDescription* md){
    return md->defaultExperimentTolerance;
}

void fmiSetDefaultExperimentTolerance(fmiModelDescription* md, double tol){
    md->defaultExperimentTolerance = tol;
}

fmiVendorList* fmiGetVendorList(fmiModelDescription* md) {
    return (fmiVendorList*)&md->vendorList;
}

unsigned int  fmiGetNumberOfVendors(fmiVendorList* vl) {
    return jm_vector_get_size(jm_voidp)(&vl->vendors);
}

fmiVendor* fmiGetVendor(fmiVendorList* v, unsigned int  index) {
    jm_vector(jm_voidp)* vl = &v->vendors;
    if(index >= jm_vector_get_size(jm_voidp)(vl)) return 0;
    return jm_vector_get_item(jm_voidp)(vl, index);
}

fmiUnitDefinitions* fmiGetUnitDefinitions(fmiModelDescription* md) {
    return (fmiUnitDefinitions*)(&md->unitDefinitions);
}

unsigned int  fmiGetUnitDefinitionsNumber(fmiUnitDefinitions* ud) {
    return jm_vector_get_size(jm_named_ptr)(&ud->definitions);
}

fmiTypeDefinitions* fmiGetTypeDefinitions(fmiModelDescription* md) {
    return &md->typeDefinitions;
}

void fmiReportError(fmiModelDescription* md, const char* module, const char* fmt, va_list ap) {
    vsprintf(md->errMessageBuf, fmt, ap);
    if(md->callbacks->logger)
        md->callbacks->logger(md, module, 0, "ERROR", md->errMessageBuf);
}

/* Get the list of all the variables in the model */
fmiVariableList* fmiGetVariableList(fmiModelDescription* md) {
    fmiVariableList* vl;
    size_t nv, i;
    if(md->status != fmiModelDescriptionOK) return 0;
    nv = jm_vector_get_size(jm_named_ptr)(&md->variables);
    vl = fmiAllocVariableList(md->callbacks, nv);
    if(!vl) return 0;
    for(i = 0; i< nv; i++) {
        jm_vector_set_item(jm_voidp)(&vl->variables, i, jm_vector_get_item(jm_named_ptr)(&md->variables, i).ptr);
    }
    return vl;
}


int fmiXMLHandle_fmiModelDescription(fmiXMLParserContext *context, const char* data) {
    jm_name_ID_map_t namingConventionMap[] = {{"flat",fmiNamingFlat},{"structured", fmiNamingStructured},{0,0}};
    fmiModelDescription* md = context->modelDescription;

    if(!data) {
        if(context -> currentElmHandle != 0) {
            fmiXMLParseError(context, "fmiModelDescription must be the root XML element");
            return -1;
        }
        /* process the attributes */
        return (
                    /* <xs:attribute name="fmiVersion" type="xs:normalizedString" use="required" fixed="1.0"/> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_fmiVersion, 1, &(md->fmiStandardVersion)) ||
                    /* <xs:attribute name="modelName" type="xs:normalizedString" use="required"> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_modelName, 1, &(md->modelName)) ||
                    /* <xs:attribute name="modelIdentifier" type="xs:normalizedString" use="required"> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_modelIdentifier, 1, &(md->modelIdentifier)) ||
                    /* <xs:attribute name="guid" type="xs:normalizedString" use="required"> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_guid, 1, &(md->GUID)) ||
                    /* <xs:attribute name="description" type="xs:string"/> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_description, 0, &(md->description)) ||
                    /* <xs:attribute name="author" type="xs:string"/> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_author, 0, &(md->author)) ||
                    /* <xs:attribute name="version" type="xs:normalizedString"> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_version, 0, &(md->version)) ||
                    /* <xs:attribute name="generationTool" type="xs:normalizedString"/> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_generationTool, 0, &(md->generationTool)) ||
                    /* <xs:attribute name="generationDateAndTime" type="xs:dateTime"/> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_generationDateAndTime, 0, &(md->generationDateAndTime)) ||
                    /* <xs:attribute name="variableNamingConvention" use="optional" default="flat"> */
                    fmiXMLSetAttrEnum(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_variableNamingConvention, 0, &(md->namingConvension), fmiNamingFlat, namingConventionMap) ||
                    /* <xs:attribute name="numberOfContinuousStates" type="xs:unsignedInt" use="required"/> */
                    fmiXMLSetAttrUint(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_numberOfContinuousStates, 1, &(md->numberOfContinuousStates),0) ||
                    /* <xs:attribute name="numberOfEventIndicators" type="xs:unsignedInt" use="required"/> */
                    fmiXMLSetAttrUint(context, fmiXMLElmID_fmiModelDescription, fmiXMLAttrID_numberOfEventIndicators, 1, &(md->numberOfEventIndicators),0)
                    );
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
}

int fmiXMLHandle_DefaultExperiment(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        if(  context -> currentElmHandle != fmiXMLHandle_fmiModelDescription)
        {
            fmiXMLParseError(context, "DefaultExperiment XML element must be a part of fmiModelDescription");
            return -1;
        }
        if(  (context -> lastElmHandle != 0) &&
             (context -> lastElmHandle != fmiXMLHandle_TypeDefinitions) &&
              (context->lastElmHandle != fmiXMLHandle_UnitDefinitions)
                )
        {
            fmiXMLParseError(context, "DefaultExperiment XML element must either be the first or follow TypeDefinitions or UnitDefinitions");
            return -1;
        }
        /* process the attributes */
        return (
        /* <xs:attribute name="startTime" type="xs:double"/> */
                    fmiXMLSetAttrDouble(context, fmiXMLElmID_DefaultExperiment, fmiXMLAttrID_startTime, 0, &md->defaultExperimentStartTime, 0) ||
        /* <xs:attribute name="stopTime" type="xs:double"/>  */
                    fmiXMLSetAttrDouble(context, fmiXMLElmID_DefaultExperiment, fmiXMLAttrID_stopTime, 0, &md->defaultExperimentStopTime, 1) ||
        /* <xs:attribute name="tolerance" type="xs:double">  */
                    fmiXMLSetAttrDouble(context, fmiXMLElmID_DefaultExperiment, fmiXMLAttrID_tolerance, 0, &md->defaultExperimentTolerance, 1e-6)
                    );
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}
