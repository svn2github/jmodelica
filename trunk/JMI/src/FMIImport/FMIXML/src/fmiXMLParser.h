#ifndef FMIXMLPARSER_H
#define FMIXMLPARSER_H

#include <expat.h>

#include <jm_vector.h>
#include <jm_stack.h>
#include <jm_named_ptr.h>

#include "fmiModelDescription.h"

#define FMI_ATTRLIST(EXPAND_XML_ATTRNAME) \
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
EXPAND_XML_ATTRNAME(input)

#define XMLATTR_ID(attr) fmiXMLAttrID_##attr
typedef enum fmiXMLAttrEnum_ {
    FMI_ATTRLIST(XMLATTR_ID),
    fmiXMLAttrNum
} fmiXMLAttrEnum;

#define FMI_ELMLIST(EXPAND_XML_ELMNAME) \
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
EXPAND_XML_ELMNAME(Enumeration)

typedef struct fmiXMLParserContext fmiXMLParserContext;
#define EXPAND_ELM_HANDLE(elm) extern int fmiXMLHandle_##elm(fmiXMLParserContext *context, const char* data);
FMI_ELMLIST(EXPAND_ELM_HANDLE)

#define XMLELM_ID(elm) fmiXMLElmID_##elm,
typedef enum fmiXMLElmEnum_ {
    FMI_ELMLIST(XMLELM_ID)
    fmiXMLElmNum
} fmiXMLElmEnum;

typedef int (*elementHandleF_t)(fmiXMLParserContext *context, const char* data);

typedef struct fmiXMLElementHandleMap_t fmiXMLElementHandleMap_t;

struct fmiXMLElementHandleMap_t {
    const char* elementName;
    elementHandleF_t elementHandle;
};

jm_vector_declare_template(fmiXMLElementHandleMap_t)
jm_vector_declare_template(elementHandleF_t)
jm_stack_declare_template(elementHandleF_t)

#define fmiXML_diff_elmName(a, b) strcmp(a.elementName,b.elementName)

jm_define_comp_f(fmiXML_compare_elmName, fmiXMLElementHandleMap_t, fmiXML_diff_elmName)

#define XML_BLOCK_SIZE 16000

struct fmiXMLParserContext {
    fmiModelDescription* modelDescription;
    jm_callbacks* callbacks;

    XML_Parser parser;
    jm_vector(jm_voidp) parseBuffer;

    jm_vector(jm_named_ptr)* attrMap;
    jm_vector(fmiXMLElementHandleMap_t)* elmMap;
    jm_vector(jm_string)* attrBuffer;

    fmiUnit* lastBaseUnit;

    jm_vector(jm_voidp) directDependencyBuf;

    jm_vector(jm_string) directDependencyStringsStore;

    jm_stack(elementHandleF_t) elmHandleStack;
    jm_vector(char) elmData;

    elementHandleF_t lastElmHandle;
    elementHandleF_t currentElmHandle;
};

jm_vector(char) * fmiXMLReserveParseBuffer(fmiXMLParserContext *context, size_t index, size_t size);
jm_vector(char) * fmiXMLGetParseBuffer(fmiXMLParserContext *context, size_t index);
int fmiXMLAllocBuffer(fmiXMLParserContext *context, size_t items);

void fmiXMLFreeBuffer(fmiXMLParserContext *context);

void fmiXMLParseError(fmiXMLParserContext *context, const char* fmt, ...);
int fmiXMLSetAttrString(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, jm_vector(char)* field);
int fmiXMLSetAttrUint(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, unsigned int* field, unsigned int defaultVal);
int fmiXMLSetAttrEnum(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, unsigned int* field, unsigned int defaultVal, jm_name_ID_map_t* nameMap);
int fmiXMLSetAttrBoolean(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, unsigned int* field, unsigned int defaultVal);
int fmiXMLSetAttrInt(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, int* field, int defaultVal);
int fmiXMLSetAttrDouble(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, double* field, double defaultVal);
int fmiXMLAttrIsDefined(fmiXMLParserContext *context, fmiXMLAttrEnum attrID);

#endif /* FMIXMLPARSER_H */

