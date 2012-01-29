#include <string.h>
#include <stdio.h>

#include "fmiModelDescriptionImpl.h"
#include "fmiXMLParser.h"


#define ATTR_STR(attr) #attr
const char *fmiXMLAttrNames[] = {
    FMI_ATTRLIST(ATTR_STR)
};


#define EXPAND_ELM_NAME(elm) { #elm, fmiXMLHandle_##elm},

fmiXMLElementHandleMap_t fmiXMLElementHandleMap[fmiXMLElmNum] = {
    FMI_ELMLIST(EXPAND_ELM_NAME)
};

void fmiXMLParseFreeContext(fmiXMLParserContext *context) {
    if(context->modelDescription)
        fmiClearModelDescription(context->modelDescription);
    if(context->parser) {
        XML_ParserFree(context->parser);
        context->parser = 0;
    }
    fmiXMLFreeBuffer(context);
    if(context->attrMap) {
        jm_vector_free(jm_named_ptr)(context->attrMap);
        context->attrMap = 0;
    }
    if(context->elmMap) {
        jm_vector_free(fmiXMLElementHandleMap_t)(context->elmMap);
        context->elmMap = 0;
    }
    if(context->attrBuffer) {
        jm_vector_free(jm_string)(context->attrBuffer);
        context->attrBuffer = 0;
    }
    jm_stack_free_data(elementHandleF_t)(& context->elmHandleStack );
    jm_vector_free_data(char)( &context->elmData );

    jm_vector_free_data(jm_voidp)(&context->directDependencyBuf);
    jm_vector_foreach(jm_string)(&context->directDependencyStringsStore, (void(*)(jm_string))context->callbacks->free);
    jm_vector_free_data(jm_string)(&context->directDependencyStringsStore);
}

void fmiXMLParseError(fmiXMLParserContext *context, const char* fmt, ...) {
    va_list args;
    const char * module = "XMLparser";
    va_start (args, fmt);
    fmiReportError(context->modelDescription, module, fmt, args);
    va_end (args);
    XML_StopParser(context->parser,0);
}

int fmiXMLAttrIsDefined(fmiXMLParserContext *context, fmiXMLAttrEnum attrID) {
    return ( jm_vector_get_item(jm_string)(context->attrBuffer, attrID) != 0);
}

int fmiXMLGetAttrStr(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required,const char** valp) {

    jm_string elmName, attrName, value;

    elmName = fmiXMLElementHandleMap[elmID].elementName;
    attrName = fmiXMLAttrNames[attrID];
    value = jm_vector_get_item(jm_string)(context->attrBuffer, attrID);
    *valp =  value;
    jm_vector_set_item(jm_string)(context->attrBuffer, attrID, 0);
    if(!(*valp)) {
        if (required) {
            fmiXMLParseError(context, "Parsing XML element '%s': required attribute '%s' not found", elmName, attrName);
            return -1;
        }
        else
            return 0;
    }
    return 0;
}

int fmiXMLSetAttrString(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, jm_vector(char)* field) {
    int ret;
    jm_string elmName, attrName, val;
    size_t len;
    ret = fmiXMLGetAttrStr(context, elmID, attrID,required,&val);
    if(ret) return ret;
    if((!val || !val[0]) && !required) {
        jm_vector_resize(char)(field, 1);
        jm_vector_set_item(char)(field, 0, 0);
        jm_vector_resize(char)(field, 0);
        return 0;
    }
    elmName = fmiXMLElementHandleMap[elmID].elementName;
    attrName = fmiXMLAttrNames[attrID];

    len = strlen(val) + 1;
    if(jm_vector_resize(char)(field, len) < len) {
        fmiXMLParseError(context, "XML element '%s': could not allocate memory for setting '%s'='%s'", elmName, attrName, val);
        return -1;
    }
    /* copy terminating 0 as well but set vector size to be actual string length */
    memcpy(jm_vector_get_itemp(char)(field,0), val, len);
    jm_vector_resize(char)(field, len - 1);
    return 0;
}

int fmiXMLSetAttrUint(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, unsigned int* field, unsigned int defaultVal) {    
    int ret;
    jm_string elmName, attrName, strVal;    

    ret = fmiXMLGetAttrStr(context, elmID, attrID,required,&strVal);
    if(ret) return ret;
    if(!strVal && !required) {
        *field = defaultVal;
        return 0;
    }

    elmName = fmiXMLElementHandleMap[elmID].elementName;
    attrName = fmiXMLAttrNames[attrID];

    if(sscanf(strVal, "%u", field) != 1) {
        fmiXMLParseError(context, "XML element '%s': could not parse value for attribute '%s'='%s'", elmName, attrName, strVal);
        return -1;
    }
    return 0;
}


int fmiXMLSetAttrEnum(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, unsigned int* field, unsigned int defaultVal, jm_name_ID_map_t* nameMap) {
    int ret, i;
    jm_string elmName, attrName, strVal;

    ret = fmiXMLGetAttrStr(context, elmID, attrID,required,&strVal);
    if(ret) return ret;
    if(!strVal && !required) {
        *field = defaultVal;
        return 0;
    }

    elmName = fmiXMLElementHandleMap[elmID].elementName;
    attrName = fmiXMLAttrNames[attrID];

    i = 0;
    while(nameMap[i].name && strcmp(nameMap[i].name, strVal)) i++;
    if(!nameMap[i].name) {
        fmiXMLParseError(context, "XML element '%s': could not parse value for attribute '%s'='%s'", elmName, attrName, strVal);
        return -1;
    }
    *field = nameMap[i].ID;
    return 0;
}

int fmiXMLSetAttrBoolean(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, unsigned int* field, unsigned int defaultVal) {
    jm_name_ID_map_t fmiXMLBooleanIDMap[] = {{"true", 1},{"false", 0}, {"1", 1},{"0", 0}, {0,0}};
    return fmiXMLSetAttrEnum(context,elmID, attrID,required, field, defaultVal, fmiXMLBooleanIDMap);
}

int fmiXMLSetAttrInt(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, int* field, int defaultVal) {
    int ret;
    jm_string elmName, attrName, strVal;

    ret = fmiXMLGetAttrStr(context, elmID, attrID,required,&strVal);
    if(ret) return ret;
    if(!strVal && !required) {
        *field = defaultVal;
        return 0;
    }

    elmName = fmiXMLElementHandleMap[elmID].elementName;
    attrName = fmiXMLAttrNames[attrID];

    if(sscanf(strVal, "%d", field) != 1) {
        fmiXMLParseError(context, "XML element '%s': could not parse value for attribute '%s'='%s'", elmName, attrName, strVal);
        return -1;
    }
    return 0;
}

int fmiXMLSetAttrDouble(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiXMLAttrEnum attrID, int required, double* field, double defaultVal) {

    int ret;
    jm_string elmName, attrName, strVal;


    ret = fmiXMLGetAttrStr(context, elmID, attrID,required,&strVal);
    if(ret) return ret;
    if(!strVal && !required) {
        *field = defaultVal;
        return 0;
    }

    elmName = fmiXMLElementHandleMap[elmID].elementName;
    attrName = fmiXMLAttrNames[attrID];

    if(sscanf(strVal, "%lf", field) != 1) {
        fmiXMLParseError(context, "XML element '%s': could not parse value for attribute '%s'='%s'", elmName, attrName, strVal);
        return -1;
    }
    return 0;
}

int fmiXMLAllocBuffer(fmiXMLParserContext *context, size_t items) {

    jm_vector(jm_voidp)* parseBuffer = &context->parseBuffer;

    if(jm_vector_init(jm_voidp)(parseBuffer,items,context->callbacks) < items) {
        fmiXMLParseError(context, "Could not allocate buffer for parsing XML");
        return -1;
    }
    jm_vector_zero(jm_voidp)(parseBuffer);
    return 0;
}

void fmiXMLFreeBuffer(fmiXMLParserContext *context) {
    int i;
    jm_vector(jm_voidp)* parseBuffer = &context->parseBuffer;

    for(i=0; i < jm_vector_get_size(jm_voidp)(parseBuffer); i++) {
        jm_vector(char) * item = jm_vector_get_item(jm_voidp)(parseBuffer,i);
        if(item) jm_vector_free(char)(item);
    }
    jm_vector_free_data(jm_voidp)(parseBuffer);
}

jm_vector(char) * fmiXMLReserveParseBuffer(fmiXMLParserContext *context, size_t index, size_t size) {

    jm_vector(jm_voidp)* parseBuffer = &context->parseBuffer;
    jm_vector(char) * item = jm_vector_get_item(jm_voidp)(parseBuffer,index);
    if(!item) {
        item = jm_vector_alloc(char)(size,size,context->callbacks);
        if(!item) {
            fmiXMLParseError(context, "Could not allocate a buffer for parsing XML");
            return 0;
        }
    }
    else {
        if(jm_vector_resize(char)(item, size) < size ) {
            fmiXMLParseError(context, "Could not allocate a buffer for parsing XML");
            return 0;
        }
    }
    return item;
}

jm_vector(char) * fmiXMLGetParseBuffer(fmiXMLParserContext *context, size_t index) {
    jm_vector(jm_voidp)* parseBuffer = &context->parseBuffer;
    return jm_vector_get_item(jm_voidp)(parseBuffer,index);
}



int fmiXMLCreateAttrMap(fmiXMLParserContext* context) {
    int i;
    context->attrBuffer = jm_vector_alloc(jm_string)(fmiXMLAttrNum, fmiXMLAttrNum, context->callbacks);
    if(!context->attrBuffer) return -1;
    context->attrMap = jm_vector_alloc(jm_named_ptr)(fmiXMLAttrNum, fmiXMLAttrNum, context->callbacks);
    if(!context->attrMap) return -1;
    for(i = 0; i < fmiXMLAttrNum; i++) {
        jm_named_ptr map;
        jm_vector_set_item(jm_string)(context->attrBuffer, i, 0);
        map.name = fmiXMLAttrNames[i];
        map.ptr = jm_vector_get_itemp(jm_string)(context->attrBuffer, i);
        jm_vector_set_item(jm_named_ptr)(context->attrMap, i, map);
    }
    jm_vector_qsort(jm_named_ptr)(context->attrMap, jm_compare_named);
    return 0;
}

int fmiXMLCreateElmMap(fmiXMLParserContext* context) {
    size_t i;
    context->elmMap = jm_vector_alloc(fmiXMLElementHandleMap_t)(fmiXMLElmNum, fmiXMLElmNum, context->callbacks);
    if(!context->elmMap) return -1;
    for(i = 0; i < fmiXMLElmNum; i++) {
        fmiXMLElementHandleMap_t item = fmiXMLElementHandleMap[i];
        jm_vector_set_item(fmiXMLElementHandleMap_t)(context->elmMap, i, item);
    }
    jm_vector_qsort(fmiXMLElementHandleMap_t)(context->elmMap, fmiXML_compare_elmName);
    return 0;
}

void XMLCALL fmiXMLParseElementStart(void *c, const char *elm, const char **attr) {
    jm_named_ptr key;
    fmiXMLElementHandleMap_t keyEl;
    fmiXMLElementHandleMap_t* currentElMap;
    jm_named_ptr* currentMap;
    elementHandleF_t currentHandle;    
    int i;
    fmiXMLParserContext *context = c;
    keyEl.elementName = elm;

    /* find the element handle by name */
    currentElMap = jm_vector_bsearch(fmiXMLElementHandleMap_t)(context->elmMap, &keyEl, fmiXML_compare_elmName);
    if(!currentElMap) {
        /* not found error*/
        fmiXMLParseError(context, "Unknown element '%s' start in XML", elm);
        return;
    }
    currentHandle = currentElMap->elementHandle;

    /* process the attributes  */
    i = 0;
    while(attr[i]) {
        key.name = attr[i];
        /* find attribute by name  */
        currentMap = jm_vector_bsearch(jm_named_ptr)(context->attrMap, &key, jm_compare_named);
        if(!currentMap) {
            /* not found error*/
            fmiXMLParseError(context, "Unknown attribute '%s' in XML", attr[i]);
            return;
        }
        {
            /* save attr value (still as string) for further handling  */
            const char** mapItem = currentMap->ptr;
            *mapItem = attr[i+1];
        }
        i += 2;
    }

    /* handle the element */
    if( currentHandle(context, 0) ) {
        return;
    }
    /* check that the element handle had process all the attributes */
    for(i = 0; i < fmiXMLAttrNum; i++) {
        if(jm_vector_get_item(jm_string)(context->attrBuffer, i)) {
            fmiXMLParseError(context, "Attribute '%s' not processes by element '%s' hanlde", fmiXMLAttrNames[i], elm);
        }
    }
    if(context -> currentElmHandle) { /* with nested elements: put the parent on the stack*/
        jm_stack_push(elementHandleF_t)(&context->elmHandleStack, context -> currentElmHandle);
    }
    context -> currentElmHandle = currentHandle;
}

void XMLCALL fmiXMLParseElementEnd(void* c, const char *elm) {

    fmiXMLElementHandleMap_t keyEl;
    fmiXMLElementHandleMap_t* currentElMap;
    elementHandleF_t currentHandle;    
    fmiXMLParserContext *context = c;

    keyEl.elementName = elm;
    currentElMap = jm_vector_bsearch(fmiXMLElementHandleMap_t)(context->elmMap, &keyEl, fmiXML_compare_elmName);
    if(!currentElMap) {
        /* not found error*/
        fmiXMLParseError(context, "Unknown element end in XML (element: %s)", elm);
        return;
    }
    currentHandle = currentElMap->elementHandle;

    if(currentHandle != context -> currentElmHandle) {
        /* missmatch error*/
        fmiXMLParseError(context, "Element end '%s' does not match element start in XML", elm);
        return;
    }

    jm_vector_push_back(char)(&context->elmData, 0);

    if( currentHandle(context, jm_vector_get_itemp(char)(&context->elmData, 0) )) {
        return;
    }
    jm_vector_resize(char)(&context->elmData, 0);

    /* record the last handle and pop the stack */
    context->lastElmHandle = currentHandle;

    if(jm_stack_is_empty(elementHandleF_t)(&context->elmHandleStack)) {
        context -> currentElmHandle = 0;
    }
    else {
        context -> currentElmHandle = jm_stack_pop(elementHandleF_t)(&context->elmHandleStack);
    }
}

/*
// Called to handle element data, e.g. "xy" in <Name>xy</Name>
// Can be called many times, e.g. with "x" and then with "y" in the example above.
// Feature in expat:
// For some reason, if the element data is the empty string (Eg. <a></a>)
// instead of an empty string with len == 0 we get "\n". The workaround is
// to replace this with the empty string whenever we encounter "\n".
*/
void XMLCALL fmiXMLParseElementData(void* c, const XML_Char *s, int len) {
        fmiXMLParserContext *context = c;
        int i;
        jm_vector_reserve(char)(&context->elmData, len + jm_vector_get_size(char)(&context->elmData) + 1);
        for(i = 0; i< len;i++) {
            char ch = s[i];
            if(ch != '\n') {
                jm_vector_push_back(char)(&context->elmData, ch);
            }
        }
}

int fmiParseXML(fmiModelDescription* md, const char* filename) {
    XML_Memory_Handling_Suite memsuite;
    fmiXMLParserContext* context;
    XML_Parser parser = NULL;
    FILE* file;

    context = md->callbacks->calloc(1, sizeof(fmiXMLParserContext));
    if(!context) {
        md->callbacks->logger(md, 0, -1, "ERROR", "Could not allocate memory for XML parser context");
    }
    context->callbacks = md->callbacks;
    context->modelDescription = md;
    if(fmiXMLAllocBuffer(context, 16)) return -1;
    if(fmiXMLCreateAttrMap(context) || fmiXMLCreateElmMap(context)) {
        fmiXMLParseError(context, "Error in parsing initialization");
        return -1;
    }
    context->lastBaseUnit = 0;
    jm_vector_init(jm_voidp)(&context->directDependencyBuf, 0, context->callbacks);
    jm_vector_init(jm_string)(&context->directDependencyStringsStore, 0, context->callbacks);
    jm_stack_init(elementHandleF_t)(&context->elmHandleStack,  context->callbacks);
    jm_vector_init(char)(&context->elmData, 0, context->callbacks);
    context->lastElmHandle = 0;
    context->currentElmHandle = 0;

    memsuite.malloc_fcn = context->callbacks->malloc;
    memsuite.realloc_fcn = context->callbacks->realloc;
    memsuite.free_fcn = context->callbacks->free;
    context -> parser = parser = XML_ParserCreate_MM(0, &memsuite, 0);

    if(! parser) {
        fmiXMLParseError(context, "Could not initialize XML parsing library.");
        return -1;
    }

    XML_SetUserData( parser, context);

    XML_SetElementHandler(parser, fmiXMLParseElementStart, fmiXMLParseElementEnd);

    XML_SetCharacterDataHandler(parser, fmiXMLParseElementData);

    file = fopen(filename, "rb");
    if (file == NULL) {
        fmiXMLParseError(context, "Cannot open file '%s' for parsing", filename);
        return -1;
    }

    while (!feof(file)) {
        char * text = jm_vector_get_itemp(char)(fmiXMLReserveParseBuffer(context,0,XML_BLOCK_SIZE),0);
        int n = fread(text, sizeof(char), XML_BLOCK_SIZE, file);
        if(ferror(file)) {
            fmiXMLParseError(context, "Error reading from file %s", filename);
            fclose(file);
            return -1;
        }
        if (!XML_Parse(parser, text, n, feof(file))) {
             fmiXMLParseError(context, "Parse error in file %s at line %d:\n%s",
                          filename,
                         (int)XML_GetCurrentLineNumber(parser),
                         XML_ErrorString(XML_GetErrorCode(parser)));
             fclose(file);
             return -1; /* failure */
        }        
    }
    /* done later XML_ParserFree(parser);*/
    if(!jm_stack_is_empty(elementHandleF_t)(&context->elmHandleStack)) {
        fmiXMLParseError(context, "Unexpected end of file (not all elements ended) when parsing %s", filename);
        return -1;
    }

    md->status = fmiModelDescriptionOK;
    context->modelDescription = 0;
    fmiXMLParseFreeContext(context);

    return 0;
}

#define JM_TEMPLATE_INSTANCE_TYPE fmiXMLElementHandleMap_t
#include "jm_vector_template.h"

#undef JM_TEMPLATE_INSTANCE_TYPE
#define JM_TEMPLATE_INSTANCE_TYPE elementHandleF_t
#include "jm_vector_template.h"
