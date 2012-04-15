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

#ifndef FMI_XML_XMLPARSER_H
#define FMI_XML_XMLPARSER_H

#include <expat.h>

#include <jm_vector.h>
#include <jm_stack.h>
#include <jm_named_ptr.h>

#include "fmi_xml_model_description.h"

#ifdef __cplusplus
extern "C" {
#endif

#define FMI_XML_ATTRLIST(EXPAND_XML_ATTRNAME) \
    EXPAND_XML_ATTRNAME(fmiVersion), \
    EXPAND_XML_ATTRNAME(displayUnit), \
    EXPAND_XML_ATTRNAME(gain), \
    EXPAND_XML_ATTRNAME(offset), \
    EXPAND_XML_ATTRNAME(unit), \
    EXPAND_XML_ATTRNAME(name), \
    EXPAND_XML_ATTRNAME(description), \
    EXPAND_XML_ATTRNAME(quantity), \
    EXPAND_XML_ATTRNAME(relativeQuantity), \
    EXPAND_XML_ATTRNAME(min), \
    EXPAND_XML_ATTRNAME(max), \
    EXPAND_XML_ATTRNAME(nominal), \
    EXPAND_XML_ATTRNAME(declaredType), \
    EXPAND_XML_ATTRNAME(start), \
    EXPAND_XML_ATTRNAME(fixed), \
    EXPAND_XML_ATTRNAME(startTime), \
    EXPAND_XML_ATTRNAME(stopTime), \
    EXPAND_XML_ATTRNAME(tolerance), \
    EXPAND_XML_ATTRNAME(value), \
    EXPAND_XML_ATTRNAME(valueReference), \
    EXPAND_XML_ATTRNAME(variability), \
    EXPAND_XML_ATTRNAME(causality), \
    EXPAND_XML_ATTRNAME(alias), \
    EXPAND_XML_ATTRNAME(modelName), \
    EXPAND_XML_ATTRNAME(modelIdentifier), \
    EXPAND_XML_ATTRNAME(guid), \
    EXPAND_XML_ATTRNAME(author), \
    EXPAND_XML_ATTRNAME(version), \
    EXPAND_XML_ATTRNAME(generationTool), \
    EXPAND_XML_ATTRNAME(generationDateAndTime), \
    EXPAND_XML_ATTRNAME(variableNamingConvention), \
    EXPAND_XML_ATTRNAME(numberOfContinuousStates), \
    EXPAND_XML_ATTRNAME(numberOfEventIndicators), \
    EXPAND_XML_ATTRNAME(input), \
    EXPAND_XML_ATTRNAME(canHandleVariableCommunicationStepSize), \
    EXPAND_XML_ATTRNAME(canHandleEvents), \
    EXPAND_XML_ATTRNAME(canRejectSteps), \
    EXPAND_XML_ATTRNAME(canInterpolateInputs), \
    EXPAND_XML_ATTRNAME(maxOutputDerivativeOrder), \
    EXPAND_XML_ATTRNAME(canRunAsynchronuously), \
    EXPAND_XML_ATTRNAME(canSignalEvents), \
    EXPAND_XML_ATTRNAME(canBeInstantiatedOnlyOncePerProcess), \
    EXPAND_XML_ATTRNAME(canNotUseMemoryManagementFunctions), \
    EXPAND_XML_ATTRNAME(file), \
    EXPAND_XML_ATTRNAME(entryPoint), \
    EXPAND_XML_ATTRNAME(manualStart), \
    EXPAND_XML_ATTRNAME(type)

#define FMI_XML_ATTR_ID(attr) fmi_attr_id_##attr
typedef enum fmi_xml_attr_enu_t {
    FMI_XML_ATTRLIST(FMI_XML_ATTR_ID),
    fmi_xml_attr_number
} fmi_xml_attr_enu_t;

#define FMI_XML_ELMLIST(EXPAND_XML_ELMNAME) \
    EXPAND_XML_ELMNAME(fmiModelDescription) \
    EXPAND_XML_ELMNAME(UnitDefinitions) \
    EXPAND_XML_ELMNAME(BaseUnit) \
    EXPAND_XML_ELMNAME(DisplayUnitDefinition) \
    EXPAND_XML_ELMNAME(TypeDefinitions) \
    EXPAND_XML_ELMNAME(Type) \
    EXPAND_XML_ELMNAME(RealType) \
    EXPAND_XML_ELMNAME(IntegerType) \
    EXPAND_XML_ELMNAME(BooleanType) \
    EXPAND_XML_ELMNAME(StringType) \
    EXPAND_XML_ELMNAME(EnumerationType) \
    EXPAND_XML_ELMNAME(Item) \
    EXPAND_XML_ELMNAME(DefaultExperiment) \
    EXPAND_XML_ELMNAME(VendorAnnotations) \
    EXPAND_XML_ELMNAME(Tool) \
    EXPAND_XML_ELMNAME(Annotation) \
    EXPAND_XML_ELMNAME(ModelVariables) \
    EXPAND_XML_ELMNAME(ScalarVariable) \
    EXPAND_XML_ELMNAME(DirectDependency) \
    EXPAND_XML_ELMNAME(Name) \
    EXPAND_XML_ELMNAME(Real) \
    EXPAND_XML_ELMNAME(Integer) \
    EXPAND_XML_ELMNAME(Boolean) \
    EXPAND_XML_ELMNAME(String) \
    EXPAND_XML_ELMNAME(Enumeration) \
    EXPAND_XML_ELMNAME(Implementation) \
    EXPAND_XML_ELMNAME(CoSimulation_StandAlone) \
    EXPAND_XML_ELMNAME(Capabilities) \
    EXPAND_XML_ELMNAME(CoSimulation_Tool) \
    EXPAND_XML_ELMNAME(Model) \
    EXPAND_XML_ELMNAME(File)

typedef struct fmi_xml_parser_context_t fmi_xml_parser_context_t;
#define EXPAND_ELM_HANDLE(elm) extern int fmi_xml_handle_##elm(fmi_xml_parser_context_t *context, const char* data);
FMI_XML_ELMLIST(EXPAND_ELM_HANDLE)

#define FMI_XML_ELM_ID(elm) fmi_xml_elmID_##elm,
typedef enum fmi_xml_elm_enu_t {
    FMI_XML_ELMLIST(FMI_XML_ELM_ID)
    fmi_xml_elm_number
} fmi_xml_elm_enu_t;

typedef int (*fmi_xml_element_handle_ft)(fmi_xml_parser_context_t *context, const char* data);

typedef struct fmi_xml_element_handle_map_t fmi_xml_element_handle_map_t;

struct fmi_xml_element_handle_map_t {
    const char* elementName;
    fmi_xml_element_handle_ft elementHandle;
};

jm_vector_declare_template(fmi_xml_element_handle_map_t)
jm_vector_declare_template(fmi_xml_element_handle_ft)
jm_stack_declare_template(fmi_xml_element_handle_ft)

#define fmi_xml_diff_elmName(a, b) strcmp(a.elementName,b.elementName)

jm_define_comp_f(fmi_xml_compare_elmName, fmi_xml_element_handle_map_t, fmi_xml_diff_elmName)

#define XML_BLOCK_SIZE 16000

struct fmi_xml_parser_context_t {
    fmi_xml_model_description_t* modelDescription;
    jm_callbacks* callbacks;

    XML_Parser parser;
    jm_vector(jm_voidp) parseBuffer;

    jm_vector(jm_named_ptr)* attrMap;
    jm_vector(fmi_xml_element_handle_map_t)* elmMap;
    jm_vector(jm_string)* attrBuffer;

    fmi_xml_unit_t* lastBaseUnit;

    jm_vector(jm_voidp) directDependencyBuf;

    jm_vector(jm_string) directDependencyStringsStore;

    int skipOneVariableFlag;

    jm_stack(fmi_xml_element_handle_ft) elmHandleStack;
    jm_vector(char) elmData;

    fmi_xml_element_handle_ft lastElmHandle;
    fmi_xml_element_handle_ft currentElmHandle;
};

jm_vector(char) * fmi_xml_reserve_parse_buffer(fmi_xml_parser_context_t *context, size_t index, size_t size);
jm_vector(char) * fmi_xml_get_parse_buffer(fmi_xml_parser_context_t *context, size_t index);
int fmi_xml_alloc_parse_buffer(fmi_xml_parser_context_t *context, size_t items);

void fmi_xml_free_parse_buffer(fmi_xml_parser_context_t *context);

void fmi_xml_parse_error(fmi_xml_parser_context_t *context, const char* fmt, ...);
void fmi_xml_parse_warning(fmi_xml_parser_context_t *context, const char* fmt, ...);
int fmi_xml_set_attr_string(fmi_xml_parser_context_t *context, fmi_xml_elm_enu_t elmID, fmi_xml_attr_enu_t attrID, int required, jm_vector(char)* field);
int fmi_xml_set_attr_uint(fmi_xml_parser_context_t *context, fmi_xml_elm_enu_t elmID, fmi_xml_attr_enu_t attrID, int required, unsigned int* field, unsigned int defaultVal);
int fmi_xml_set_attr_enum(fmi_xml_parser_context_t *context, fmi_xml_elm_enu_t elmID, fmi_xml_attr_enu_t attrID, int required, unsigned int* field, unsigned int defaultVal, jm_name_ID_map_t* nameMap);
int fmi_xml_set_attr_boolean(fmi_xml_parser_context_t *context, fmi_xml_elm_enu_t elmID, fmi_xml_attr_enu_t attrID, int required, int* field, int defaultVal);
int fmi_xml_set_attr_int(fmi_xml_parser_context_t *context, fmi_xml_elm_enu_t elmID, fmi_xml_attr_enu_t attrID, int required, int* field, int defaultVal);
int fmi_xml_set_attr_double(fmi_xml_parser_context_t *context, fmi_xml_elm_enu_t elmID, fmi_xml_attr_enu_t attrID, int required, double* field, double defaultVal);
int fmi_xml_is_attr_defined(fmi_xml_parser_context_t *context, fmi_xml_attr_enu_t attrID);

#ifdef __cplusplus
}
#endif

#endif /* FMI_XML_XMLPARSER_H */

