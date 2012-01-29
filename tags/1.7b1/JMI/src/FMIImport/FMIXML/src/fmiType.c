#include <limits.h>
#include <float.h>
#include <string.h>

#include "fmiModelDescriptionImpl.h"
#include "fmiTypeImpl.h"
#include "fmiUnitImpl.h"
#include "fmiXMLParser.h"

const char* fmiConvertBaseTypeToString(fmiBaseType bt) {
    switch(bt) {
    case fmiBaseTypeReal: return "Real";
    case fmiBaseTypeInteger: return "Integer";
    case fmiBaseTypeBoolean: return "Boolean";
    case fmiBaseTypeString: return "String";
    case fmiBaseTypeEnumeration: return "Enumeration";
    }
    return "Error";
}

fmiDisplayUnit* fmiGetTypeDisplayUnit(fmiRealType* t) {
    fmiVariableType* vt = (void*)t;
    fmiRealTypeProperties* props = (fmiRealTypeProperties*)vt->typeBase.baseTypeStruct;
    fmiDisplayUnit* du = props->displayUnit;
    if(du->displayUnit) return du;
    return 0;
}

size_t fmiGetTypeDefinitionsNumber(fmiTypeDefinitions* td) {
    return jm_vector_get_size(jm_named_ptr)(&td->typeDefinitions);
}

fmiVariableType* fmiGetTypeDefinition(fmiTypeDefinitions* td, unsigned int  index) {
    if(index >= fmiGetTypeDefinitionsNumber(td)) return 0;
    return jm_vector_get_item(jm_named_ptr)(&td->typeDefinitions, index).ptr;
}

const char* fmiGetTypeName(fmiVariableType* t) {   
    return t->typeName;
}

/* Note that NULL pointer is returned if the attribute is not present in the XML.*/
const char* fmiGetTypeDescription(fmiVariableType* t) {
    return t->description;
}

fmiBaseType fmiGetBaseType(fmiVariableType* t) {
    return t->typeBase.baseType;
}

fmiRealType* fmiGetTypeAsReal(fmiVariableType* t) {
    if(fmiGetBaseType(t) == fmiBaseTypeReal) return (fmiRealType*)t;
    return 0;
}
fmiIntegerType* fmiGetTypeAsInteger(fmiVariableType* t) {
    if(fmiGetBaseType(t) == fmiBaseTypeInteger) return (fmiIntegerType*)t;
    return 0;
}

fmiEnumerationType* fmiGetTypeAsEnum(fmiVariableType* t) {
    if(fmiGetBaseType(t) == fmiBaseTypeEnumeration) return (fmiEnumerationType*)t;
    return 0;
}

/* Note that 0-pointer is returned for strings and booleans, empty string quantity if not defined*/
const char* fmiGetTypeQuantity(fmiVariableType* t) {
    fmiVariableTypeBase* props = t->typeBase.baseTypeStruct;
    if(props->structKind != fmiTypeStructProperties) return 0;
    switch(props->baseType) {
    case fmiBaseTypeReal:
        return ((fmiRealTypeProperties*)props)->quantity;
    case fmiBaseTypeInteger:
        return ((fmiIntegerTypeProperties*)props)->quantity;
    case fmiBaseTypeBoolean:
        return 0;
    case fmiBaseTypeString:
        return 0;
    case fmiBaseTypeEnumeration:
        return ((fmiEnumerationTypeProperties*)props)->quantity;
    default:
        return 0;
    }
}

fmiReal fmiGetRealTypeMin(fmiRealType* t) {
    fmiVariableType* vt = (void*)t;
    fmiRealTypeProperties* props = (fmiRealTypeProperties*)(vt->typeBase.baseTypeStruct);
    return props->typeMin;
}

fmiReal fmiGetRealTypeMax(fmiRealType* t) {
    fmiVariableType* vt = (void*)t;
    fmiRealTypeProperties* props = (fmiRealTypeProperties*)(vt->typeBase.baseTypeStruct);
    return props->typeMax;
}

fmiReal fmiGetRealTypeNominal(fmiRealType* t) {
    fmiVariableType* vt = (void*)t;
    fmiRealTypeProperties* props = (fmiRealTypeProperties*)(vt->typeBase.baseTypeStruct);
    return props->typeNominal;
}

fmiUnit* fmiGetRealTypeUnit(fmiRealType* t) {    
    fmiVariableType* vt = (void*)t;
    fmiRealTypeProperties* props = (fmiRealTypeProperties*)(vt->typeBase.baseTypeStruct);
    fmiDisplayUnit* du = props->displayUnit;
    if(du) return du->baseUnit;
    return 0;
}

int fmiGetRealTypeIsRelativeQuantity(fmiRealType* t) {
    fmiVariableType* vt = (void*)t;
    fmiRealTypeProperties* props = (fmiRealTypeProperties*)(vt->typeBase.baseTypeStruct);
    return props->typeBase.relativeQuantity;
}

fmiInteger fmiGetIntegerTypeMin(fmiIntegerType* t) {
    fmiVariableType* vt = (void*)t;
    fmiIntegerTypeProperties* props = (fmiIntegerTypeProperties*)(vt->typeBase.baseTypeStruct);
    return props->typeMin;
}

fmiInteger fmiGetIntegerTypeMax(fmiIntegerType* t){
    fmiVariableType* vt = (void*)t;
    fmiIntegerTypeProperties* props = (fmiIntegerTypeProperties*)(vt->typeBase.baseTypeStruct);
    return props->typeMax;
}

fmiInteger fmiGetEnumTypeMin(fmiEnumerationType* t){
    fmiVariableType* vt = (void*)t;
    fmiEnumerationTypeProperties* props = (fmiEnumerationTypeProperties*)(vt->typeBase.baseTypeStruct);
    return props->typeMin;
}

fmiInteger fmiGetEnumTypeMax(fmiEnumerationType* t){
    fmiVariableType* vt = (void*)t;
    fmiEnumerationTypeProperties* props = (fmiEnumerationTypeProperties*)(vt->typeBase.baseTypeStruct);
    return props->typeMax;
}

unsigned int  fmiGetEnumTypeSize(fmiEnumerationType* t) {
    fmiVariableType* vt = (void*)t;
    fmiEnumerationTypeProperties* props = (fmiEnumerationTypeProperties*)(vt->typeBase.baseTypeStruct);
    return jm_vector_get_size(jm_named_ptr)(&props->enumItems);
}

const char* fmiGetEnumTypeItemName(fmiEnumerationType* t, unsigned int  item) {
    fmiVariableType* vt = (void*)t;
    fmiEnumerationTypeProperties* props = (fmiEnumerationTypeProperties*)(vt->typeBase.baseTypeStruct);
    if(item >= fmiGetEnumTypeSize(t) ) return  0;
    return jm_vector_get_item(jm_named_ptr)(&props->enumItems,item).name;
}

const char* fmiGetEnumTypeItemDescription(fmiEnumerationType* t, unsigned int  item){
    fmiVariableType* vt = (void*)t;
    fmiEnumerationTypeProperties* props = (fmiEnumerationTypeProperties*)(vt->typeBase.baseTypeStruct);
    fmiEnumerationTypeItem* e;
    if(item >= fmiGetEnumTypeSize(t) ) return  0;
    e = jm_vector_get_item(jm_named_ptr)(&props->enumItems,item).ptr;
    return e->itemDesciption;
}

void fmiInitVariableTypeBase(fmiVariableTypeBase* type, fmiTypeStructKind kind, fmiBaseType baseType) {
    type->baseTypeStruct = 0;
    type->next = 0;
    type->structKind = kind;
    type->baseType = baseType;
    type->relativeQuantity = 0;
    type->isFixed = 0;
}

void fmiInitRealTypeProperties(fmiRealTypeProperties* type) {
    fmiInitVariableTypeBase(&type->typeBase, fmiTypeStructProperties,fmiBaseTypeReal);
    type->quantity = 0;    
    type->typeMin = -DBL_MAX;
    type->typeMax = DBL_MAX;
    type->typeNominal = 1.0;
    type->displayUnit = 0;
}

void fmiInitIntegerTypeProperties(fmiIntegerTypeProperties* type) {
    fmiInitVariableTypeBase(&type->typeBase, fmiTypeStructProperties,fmiBaseTypeInteger);
    type->quantity = 0;
    type->typeMin = INT_MIN;
    type->typeMax = INT_MAX;
}

void fmiInitEnumerationTypeProperties(fmiEnumerationTypeProperties* type, jm_callbacks* cb) {
    fmiInitVariableTypeBase(&type->typeBase, fmiTypeStructProperties,fmiBaseTypeEnumeration);
    type->quantity = 0;
    type->typeMin = INT_MIN;
    type->typeMax = INT_MAX;
    jm_vector_init(jm_named_ptr)(&type->enumItems,0,cb);
}

void fmiFreeEnumerationTypeProps(fmiEnumerationTypeProperties* type) {
    jm_named_vector_free_data(&type->enumItems);
}


void fmiInitTypeDefinitions(fmiTypeDefinitions* td, jm_callbacks* cb) {
    jm_vector_init(jm_named_ptr)(&td->typeDefinitions,0,cb);

    jm_vector_init(jm_string)(&td->quantities, 0, cb);

    fmiInitRealTypeProperties(&td->defaultRealType);
    td->defaultRealType.typeBase.structKind = fmiTypeStructBase;
    fmiInitEnumerationTypeProperties(&td->defaultEnumType,cb);
    td->defaultEnumType.typeBase.structKind = fmiTypeStructBase;
    fmiInitIntegerTypeProperties(&td->defaultIntegerType);
    td->defaultIntegerType.typeBase.structKind = fmiTypeStructBase;

    fmiInitVariableTypeBase(&td->defaultBooleanType, fmiTypeStructBase,fmiBaseTypeBoolean);
    fmiInitVariableTypeBase(&td->defaultStringType, fmiTypeStructBase,fmiBaseTypeString);

    td->typePropsList = 0;
}

void fmiFreeTypeDefinitionsData(fmiTypeDefinitions* td) {
    jm_callbacks* cb = td->typeDefinitions.callbacks;

    jm_vector_foreach(jm_string)(&td->quantities,(void(*)(const char*))cb->free);
    jm_vector_free_data(jm_string)(&td->quantities);

    {
        fmiVariableTypeBase* next;
        fmiVariableTypeBase* cur = td->typePropsList;
        while(cur) {
            next = cur->next;
            if((cur->baseType == fmiBaseTypeEnumeration) && (cur->structKind == fmiTypeStructProperties)) {
                fmiEnumerationTypeProperties* props = (fmiEnumerationTypeProperties*)cur;
                fmiFreeEnumerationTypeProps(props);
            }
            cb->free(cur);
            cur = next;
        }
    }

    jm_named_vector_free_data(&td->typeDefinitions);
}

int fmiXMLHandle_TypeDefinitions(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_fmiModelDescription) {
            fmiXMLParseError(context, "TypeDefinitions XML element must be a part of fmiModelDescription");
            return -1;
        }
        if((context->lastElmHandle != 0)  &&
           (context->lastElmHandle != fmiXMLHandle_UnitDefinitions)
          ) {
            fmiXMLParseError(context, "TypeDefinitions XML element must follow UnitDefinitions");
            return -1;
        }
    }
    else {
        fmiTypeDefinitions* defs =  &context->modelDescription->typeDefinitions;

        jm_vector_qsort(jm_named_ptr)(&defs->typeDefinitions, jm_compare_named);
        /* might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_Type(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_TypeDefinitions) {
            fmiXMLParseError(context, "Type XML element must be a part of TypeDefinitions");
            return -1;
        }
        {            
            fmiModelDescription* md = context->modelDescription;
            fmiTypeDefinitions* td = &md->typeDefinitions;
            jm_named_ptr named, *pnamed;
            jm_vector(char)* bufName = fmiXMLReserveParseBuffer(context,1,100);
            jm_vector(char)* bufDescr = fmiXMLReserveParseBuffer(context,2,100);

            if(!bufName || !bufDescr) return -1;
            if(
            /*  <xs:attribute name="name" type="xs:normalizedString" use="required"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_Type, fmiXMLAttrID_name, 1, bufName) ||
            /* <xs:attribute name="description" type="xs:string"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_Type, fmiXMLAttrID_description, 0, bufDescr)
                    ) return -1;
            named.ptr = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&td->typeDefinitions,named);
            if(pnamed) {
                fmiVariableType dummy;
                *pnamed = named = jm_named_alloc_v(bufName, sizeof(fmiVariableType), dummy.typeName - (char*)&dummy,  context->callbacks);
            }
            if(!pnamed || !named.ptr) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            else {
                fmiVariableType* type = named.ptr;
                fmiInitVariableTypeBase(&type->typeBase,fmiTypeStructDefinition,fmiBaseTypeReal);
                if(jm_vector_get_size(char)(bufDescr)) {
                    const char* description = jm_string_set_put(&md->descriptions, jm_vector_get_itemp(char)(bufDescr,0));
                    type->description = description;
                }
            }
        }
    }
    else {
        jm_named_ptr named = jm_vector_get_last(jm_named_ptr)(&(context->modelDescription->typeDefinitions.typeDefinitions));
        fmiVariableType* type = named.ptr;
        if(type->typeBase.baseTypeStruct == 0) {
            fmiXMLParseError(context, "No specific type given for type definition %s", type->typeName);
            return -1;
        }
        /* might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLCheckLastElementIsSpecificType(fmiXMLParserContext *context) {
    if(context -> currentElmHandle != fmiXMLHandle_Type) {
        fmiXMLParseError(context, "Specific element types XML elements must be a part of Type element");
        return -1;
    }
    if (
                (context->lastElmHandle == fmiXMLHandle_RealType)  ||
                (context->lastElmHandle == fmiXMLHandle_IntegerType)  ||
                (context->lastElmHandle == fmiXMLHandle_BooleanType)  ||
                (context->lastElmHandle == fmiXMLHandle_StringType)  ||
                (context->lastElmHandle == fmiXMLHandle_EnumerationType)
                ) {
        fmiXMLParseError(context, "Multiple definitions for a type aer not allowed");
        return -1;
    }
    return 0;
}

fmiVariableTypeBase* fmiAllocVariableTypeProps(fmiTypeDefinitions* td, fmiVariableTypeBase* base, size_t typeSize) {
    jm_callbacks* cb = td->typeDefinitions.callbacks;
    fmiVariableTypeBase* type = cb->malloc(typeSize);
    if(!type) return 0;
    fmiInitVariableTypeBase(type,fmiTypeStructProperties,base->baseType);
    type->baseTypeStruct = base;
    type->next = td->typePropsList;
    td->typePropsList = type;
    return type;
}

fmiVariableTypeBase* fmiAllocVariableTypeStart(fmiTypeDefinitions* td,fmiVariableTypeBase* base, size_t typeSize) {
    jm_callbacks* cb = td->typeDefinitions.callbacks;
    fmiVariableTypeBase* type = cb->malloc(typeSize);
    if(!type) return 0;
    fmiInitVariableTypeBase(type,fmiTypeStructStart,base->baseType);
    type->baseTypeStruct = base;
    type->next = td->typePropsList;
    td->typePropsList = type;
    return type;
}


fmiRealTypeProperties* fmiParseRealTypeProperties(fmiXMLParserContext* context, fmiXMLElmEnum elmID) {
    jm_named_ptr named, *pnamed;
    fmiModelDescription* md = context->modelDescription;
    fmiRealTypeProperties* props;    
    const char* quantity = 0;
    unsigned int boolBuf;

/*        jm_vector(char)* bufName = fmiXMLGetParseBuffer(context,1);
    jm_vector(char)* bufDescr = fmiXMLGetParseBuffer(context,2); */
    jm_vector(char)* bufQuantity = fmiXMLReserveParseBuffer(context,3,100);
    jm_vector(char)* bufUnit = fmiXMLReserveParseBuffer(context,4,100);
    jm_vector(char)* bufDispUnit = fmiXMLReserveParseBuffer(context,5,100);

    props = (fmiRealTypeProperties*)fmiAllocVariableTypeProps(&md->typeDefinitions, &md->typeDefinitions.defaultRealType.typeBase, sizeof(fmiRealTypeProperties));

    if(!bufQuantity || !bufUnit || !bufDispUnit || !props ||
            /* <xs:attribute name="quantity" type="xs:normalizedString"/> */
            fmiXMLSetAttrString(context, elmID, fmiXMLAttrID_quantity, 0, bufQuantity) ||
            /* <xs:attribute name="unit" type="xs:normalizedString"/>  */
            fmiXMLSetAttrString(context, elmID, fmiXMLAttrID_unit, 0, bufUnit) ||
            /* <xs:attribute name="displayUnit" type="xs:normalizedString">  */
            fmiXMLSetAttrString(context, elmID, fmiXMLAttrID_displayUnit, 0, bufDispUnit)
            ) {
        fmiXMLParseError(context, "Error parsing real type properties");
        return 0;
    }
    if(jm_vector_get_size(char)(bufQuantity))
        quantity = jm_string_set_put(&md->typeDefinitions.quantities, jm_vector_get_itemp(char)(bufQuantity, 0));

    props->quantity = quantity;
    props->displayUnit = 0;
    if(jm_vector_get_size(char)(bufDispUnit)) {
        named.name = jm_vector_get_itemp(char)(bufDispUnit, 0);
        pnamed = jm_vector_bsearch(jm_named_ptr)(&(md->displayUnitDefinitions), &named, jm_compare_named);
        if(!pnamed) {
            fmiXMLParseError(context, "Unknown display unit %s in real type definition", jm_vector_get_itemp(char)(bufDispUnit, 0));
            return 0;
        }
        props->displayUnit = pnamed->ptr;
    }
    else {
        if(jm_vector_get_size(char)(bufUnit)) {
            props->displayUnit = fmiXMLGetUnit(context, bufUnit, 1);
        }
    }
    if(    /*    <xs:attribute name="relativeQuantity" type="xs:boolean" default="false"> */
            fmiXMLSetAttrBoolean(context, elmID, fmiXMLAttrID_relativeQuantity, 0, &boolBuf, 0) ||
            /* <xs:attribute name="min" type="xs:double"/> */
            fmiXMLSetAttrDouble(context, elmID, fmiXMLAttrID_min, 0, &props->typeMin, -DBL_MAX) ||
            /* <xs:attribute name="max" type="xs:double"/> */
            fmiXMLSetAttrDouble(context, elmID, fmiXMLAttrID_max, 0, &props->typeMax, DBL_MAX) ||
            /*  <xs:attribute name="nominal" type="xs:double"/> */
            fmiXMLSetAttrDouble(context, elmID, fmiXMLAttrID_nominal, 0, &props->typeNominal, 1)
            ) return 0;
    props->typeBase.relativeQuantity = boolBuf;
    return props;
}

int fmiXMLHandle_RealType(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        jm_named_ptr named;
        fmiVariableType* type;
        fmiRealTypeProperties * props;
        if(fmiXMLCheckLastElementIsSpecificType(context)) return -1;

        props = fmiParseRealTypeProperties(context, fmiXMLElmID_RealType);
        if(!props) return -1;
        named = jm_vector_get_last(jm_named_ptr)(&md->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmiBaseTypeReal;
        type->typeBase.baseTypeStruct = &props->typeBase;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

fmiIntegerTypeProperties * fmiParseIntegerTypeProperties(fmiXMLParserContext* context, fmiXMLElmEnum elmID) {

    fmiModelDescription* md = context->modelDescription;
    fmiIntegerTypeProperties * props = 0;
    const char* quantity = 0;

    /*        jm_vector(char)* bufName = fmiXMLGetParseBuffer(context,1);
            jm_vector(char)* bufDescr = fmiXMLGetParseBuffer(context,2); */
    jm_vector(char)* bufQuantity = fmiXMLReserveParseBuffer(context,3,100);

    props = (fmiIntegerTypeProperties*)fmiAllocVariableTypeProps(&md->typeDefinitions, &md->typeDefinitions.defaultIntegerType.typeBase, sizeof(fmiIntegerTypeProperties));

    if(!bufQuantity || !props ||
            /* <xs:attribute name="quantity" type="xs:normalizedString"/> */
            fmiXMLSetAttrString(context, elmID, fmiXMLAttrID_quantity, 0, bufQuantity)
            )
        return 0;
    if(jm_vector_get_size(char)(bufQuantity))
        quantity = jm_string_set_put(&md->typeDefinitions.quantities, jm_vector_get_itemp(char)(bufQuantity, 0));

    props->quantity = quantity;

    if(
            /* <xs:attribute name="min" type="xs:int"/> */
            fmiXMLSetAttrInt(context, elmID, fmiXMLAttrID_min, 0, &props->typeMin, INT_MIN) ||
            /* <xs:attribute name="max" type="xs:int"/> */
            fmiXMLSetAttrInt(context, elmID, fmiXMLAttrID_max, 0, &props->typeMax, INT_MAX)
            ) return 0;
    return props;
}

int fmiXMLHandle_IntegerType(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        jm_named_ptr named;
        fmiVariableType* type;
        fmiIntegerTypeProperties * props;
        if(fmiXMLCheckLastElementIsSpecificType(context)) return -1;

        props = fmiParseIntegerTypeProperties(context, fmiXMLElmID_IntegerType);
        if(!props) return -1;
        named = jm_vector_get_last(jm_named_ptr)(&md->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmiBaseTypeInteger;
        type->typeBase.baseTypeStruct = &props->typeBase;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}


int fmiXMLHandle_BooleanType(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        jm_named_ptr named;
        fmiVariableType* type;
        if(fmiXMLCheckLastElementIsSpecificType(context)) return -1;

        named = jm_vector_get_last(jm_named_ptr)(&context->modelDescription->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmiBaseTypeBoolean;
        type->typeBase.baseTypeStruct = &md->typeDefinitions.defaultBooleanType;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_StringType(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        jm_named_ptr named;
        fmiVariableType* type;
        if(fmiXMLCheckLastElementIsSpecificType(context)) return -1;

        named = jm_vector_get_last(jm_named_ptr)(&context->modelDescription->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmiBaseTypeBoolean;
        type->typeBase.baseTypeStruct = &md->typeDefinitions.defaultBooleanType;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_EnumerationType(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        jm_named_ptr named;
        fmiModelDescription* md = context->modelDescription;
        fmiEnumerationTypeProperties * props;
        fmiVariableType* type;
        const char * quantity = 0;
        /*        jm_vector(char)* bufName = fmiXMLGetParseBuffer(context,1);
                jm_vector(char)* bufDescr = fmiXMLGetParseBuffer(context,2); */
        jm_vector(char)* bufQuantity = fmiXMLReserveParseBuffer(context,3,100);

        if(fmiXMLCheckLastElementIsSpecificType(context)) return -1;

        props = (fmiEnumerationTypeProperties*)fmiAllocVariableTypeProps(&md->typeDefinitions, &md->typeDefinitions.defaultEnumType.typeBase, sizeof(fmiEnumerationTypeProperties));
        if(props) jm_vector_init(jm_named_ptr)(&props->enumItems,0,context->callbacks);
        if(!bufQuantity || !props ||
                /* <xs:attribute name="quantity" type="xs:normalizedString"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_IntegerType, fmiXMLAttrID_quantity, 0, bufQuantity)
                )
            return -1;
        if(jm_vector_get_size(char)(bufQuantity))
            quantity = jm_string_set_put(&md->typeDefinitions.quantities, jm_vector_get_itemp(char)(bufQuantity, 0));

        props->quantity = quantity;



        if(
                /* <xs:attribute name="min" type="xs:int"/> */
                fmiXMLSetAttrInt(context, fmiXMLElmID_EnumerationType, fmiXMLAttrID_min, 0,  &props->typeMin, 1) ||
                /* <xs:attribute name="max" type="xs:int"/> */
                fmiXMLSetAttrInt(context, fmiXMLElmID_EnumerationType, fmiXMLAttrID_max, 0, &props->typeMax, INT_MAX)
                ) return -1;
        named = jm_vector_get_last(jm_named_ptr)(&context->modelDescription->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmiBaseTypeEnumeration;
        type->typeBase.baseTypeStruct = &props->typeBase;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_Item(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_EnumerationType) {
            fmiXMLParseError(context, "Item XML element must be a part of EnumerationType");
            return -1;
        }

        {
            fmiModelDescription* md = context->modelDescription;
            jm_vector(char)* bufName = fmiXMLReserveParseBuffer(context,1,100);
            jm_vector(char)* bufDescr = fmiXMLReserveParseBuffer(context,2,100);
            /* this enum item belongs to the last created enum = head of typePropsList */
            fmiEnumerationTypeProperties * enumProps = (fmiEnumerationTypeProperties*)md->typeDefinitions.typePropsList;
            fmiEnumerationTypeItem * item;
            jm_named_ptr named, *pnamed;
            size_t descrlen;

            assert((enumProps->typeBase.structKind == fmiTypeStructProperties) && (enumProps->typeBase.baseType == fmiBaseTypeEnumeration));

            if(!bufName || !bufDescr ||
            /*  <xs:attribute name="name" type="xs:normalizedString" use="required"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_Type, fmiXMLAttrID_name, 1, bufName) ||
            /* <xs:attribute name="description" type="xs:string"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_Type, fmiXMLAttrID_description, 0, bufDescr)
                    )
                return -1;
            descrlen = jm_vector_get_size(char)(bufDescr);
            named.ptr = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&enumProps->enumItems, named);

            if(pnamed) *pnamed = named = jm_named_alloc_v(bufName,sizeof(fmiEnumerationTypeItem)+descrlen+1,sizeof(fmiEnumerationTypeItem)+descrlen,context->callbacks);
            item = named.ptr;
            if( !pnamed || !item ) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            item->itemName = named.name;
            if(descrlen)
                memcpy(item->itemDesciption,jm_vector_get_itemp(char)(bufDescr,0), descrlen);
            item->itemDesciption[descrlen] = 0;
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

fmiVariableTypeBase* fmiXMLGetDeclaredType(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiVariableTypeBase* defaultType) {
    jm_named_ptr key, *found;
    jm_vector(char)* bufDeclaredType = fmiXMLReserveParseBuffer(context,1, 100);
    /*         <xs:attribute name="declaredType" type="xs:normalizedString"> */
    fmiXMLSetAttrString(context, elmID, fmiXMLAttrID_declaredType, 0, bufDeclaredType);
    if(! jm_vector_get_size(char)(bufDeclaredType) ) return defaultType;
    key.name = jm_vector_get_itemp(char)(bufDeclaredType,0);
    found = jm_vector_bsearch(jm_named_ptr)(&(context->modelDescription->typeDefinitions.typeDefinitions),&key, jm_compare_named);
    if(!found) {
        fmiXMLParseError(context, "Declared type %s not found in type definitions", key.name);
        return 0;
    }
    else  {
        fmiVariableTypeBase* retType = found->ptr;
        if(retType->baseType != defaultType->baseType) {
            fmiXMLParseError(context, "Declared type %s does not match variable type", key.name);
            return 0;
        }
        return retType;
    }
}
