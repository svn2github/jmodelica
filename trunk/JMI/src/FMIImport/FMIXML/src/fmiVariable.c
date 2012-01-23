#include <string.h>

#include <jm_vector.h>

#include "fmiXMLParser.h"
#include "fmiVariableListImpl.h"
#include "fmiTypeImpl.h"
#include "fmiModelDescriptionImpl.h"

#include "fmiVariableImpl.h"

const char* fmiVariabilityToString(fmiVariability v) {
    switch(v) {
    case fmiVariabilityConstant: return "constant";
    case fmiVariabilityParameter: return "parameter";
    case fmiVariabilityDiscrete: return "discrete";
    case fmiVariabilityContinuous: return "continuous";
    }
    return "Error";
}

const char* fmiCausalityToString(fmiCausality c) {
    switch(c) {
    case fmiCausalityInput: return "input";
    case fmiCausalityOutput: return "output";
    case fmiCausalityInternal: return "internal";
    case fmiCausalityNone: return "none";
    };
    return "Error";
}

const char* fmiGetVariableName(fmiVariable* v) {
    return v->name;
}

fmiValueReference fmiGetVariableValueReference(fmiVariable* v) {
    return v->vr;
}

fmiVariableType* fmiGetVariableDeclaredType(fmiVariable* v) {
    return (fmiVariableType*)(fmiFindTypeStruct(v->typeBase, fmiTypeStructDefinition));
}

fmiBaseType fmiGetVariableBaseType(fmiVariable* v) {
    fmiVariableTypeBase* type = v->typeBase;
    type = fmiFindTypeStruct(type, fmiTypeStructBase);
    return (type->baseType);
}

int fmiGetVariableHasStart(fmiVariable* v) {
    return (v->typeBase->structKind == fmiTypeStructStart);
}

int   fmiGetVariableIsFixed(fmiVariable* v) {
    fmiVariableTypeBase* type = v->typeBase;
    return ((type->structKind == fmiTypeStructStart) && (type->isFixed));
}

fmiVariability fmiGetVariability(fmiVariable* v) {
    return v->variability;
}

fmiCausality fmiGetCausality(fmiVariable* v) {
    return v->causality;
}

fmiReal fmiGetRealVariableStart(fmiRealVariable* v) {
    fmiVariable* vv = (fmiVariable*)v;
    if(fmiGetVariableHasStart(vv)) {
        fmiVariableStartReal* start = (fmiVariableStartReal*)(vv->typeBase);
        return start->start;
    }
        return fmiGetRealVariableNominal(v);
}

fmiInteger fmiGetIntegerVariableStart(fmiIntegerVariable* v){
    fmiVariable* vv = (fmiVariable*)v;
    if(fmiGetVariableHasStart(vv)) {
        fmiVariableStartInteger* start = (fmiVariableStartInteger*)(vv->typeBase);
        return start->start;
    }
        return 0;
}

const char* fmiGetStringVariableStart(fmiStringVariable* v){
    fmiVariable* vv = (fmiVariable*)v;
    if(fmiGetVariableHasStart(vv)) {
        fmiVariableStartString* start = (fmiVariableStartString*)(vv->typeBase);
        return start->start;
    }
    return 0;
}

fmiInteger fmiGetEnumVariableStart(fmiEnumerationVariable* v) {
    fmiVariable* vv = (fmiVariable*)v;
    if(fmiGetVariableHasStart(vv)) {
        fmiVariableStartInteger* start = (fmiVariableStartInteger*)(vv->typeBase);
        return start->start;
    }
        return 0;
}

fmiBoolean fmiGetBooleanVariableStart(fmiBooleanVariable* v) {
    fmiVariable* vv = (fmiVariable*)v;
    if(fmiGetVariableHasStart(vv)) {
        fmiVariableStartInteger* start = (fmiVariableStartInteger*)(vv->typeBase);
        return start->start;
    }
        return 0;
}

fmiReal fmiGetRealVariableNominal(fmiRealVariable* v) {
    fmiVariable* vv = (fmiVariable*)v;
    fmiRealTypeProperties* props = (fmiRealTypeProperties*)fmiFindTypeStruct(vv->typeBase,fmiTypeStructProperties);
    return props->typeNominal;
}

/* DirectDependency is returned for variables with causality Output. Null pointer for others. */
fmiVariableList* fmiGetDirectDependency(fmiVariable* v) {
    fmiVariableList* vl = 0;
    if(!v->directDependency) return 0;
    vl = fmiVariableListAlloc(v->directDependency->callbacks, jm_vector_get_size(jm_voidp)(v->directDependency));
    if(!vl) return 0;
    jm_vector_copy(jm_voidp)(&vl->variables,v->directDependency);
    return vl;
}

fmiRealVariable* fmiGetVariableAsReal(fmiVariable* v) {
    if(fmiGetVariableBaseType(v) == fmiBaseTypeReal)  return (void*)v;
    return 0;
}

fmiIntegerVariable* fmiGetVariableAsInteger(fmiVariable*v){
    if(fmiGetVariableBaseType(v) == fmiBaseTypeReal)  return (void*)v;
    return 0;
}
fmiEnumerationVariable* fmiGetVariableAsEnumeration(fmiVariable* v){
    if(fmiGetVariableBaseType(v) == fmiBaseTypeReal)  return (void*)v;
    return 0;
}
fmiStringVariable* fmiGetVariableAsString(fmiVariable* v){
    if(fmiGetVariableBaseType(v) == fmiBaseTypeReal)  return (void*)v;
    return 0;
}
fmiBooleanVariable* fmiGetVariableAsBoolean(fmiVariable* v){
    if(fmiGetVariableBaseType(v) == fmiBaseTypeReal)  return (void*)v;
    return 0;
}


int fmiXMLHandle_ScalarVariable(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_ModelVariables) {
            fmiXMLParseError(context, "ScalarVariable XML element must be a part of ModelVariables");
            return -1;
        }
        {
            int ret;
            fmiModelDescription* md = context->modelDescription;
            fmiVariable* variable;
            const char* description = 0;
            jm_named_ptr named, *pnamed;
            jm_vector(char)* bufName = fmiXMLReserveParseBuffer(context,1,100);
            jm_vector(char)* bufDescr = fmiXMLReserveParseBuffer(context,2,100);

            if(!bufName || !bufDescr) return -1;
            if(
            /*  <xs:attribute name="name" type="xs:normalizedString" use="required"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_ScalarVariable, fmiXMLAttrID_name, 1, bufName) ||
            /* <xs:attribute name="description" type="xs:string"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_ScalarVariable, fmiXMLAttrID_description, 0, bufDescr)
            ) return -1;

            if(jm_vector_get_size(char)(bufDescr)) {
                description = jm_string_set_put(&md->descriptions, jm_vector_get_itemp(char)(bufDescr,0));
            }

            named.ptr = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&md->variables, named);

            if(pnamed) *pnamed = named = jm_named_alloc_v(bufName,sizeof(fmiVariable),context->callbacks);
            variable = named.ptr;
            variable->description = description;
            if( !pnamed || !variable ) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }

            variable->typeBase = 0;
            variable->directDependency = 0;
            variable->alias = 0;

            /*   <xs:attribute name="valueReference" type="xs:unsignedInt" use="required"> */
            if(fmiXMLSetAttrUint(context, fmiXMLElmID_ScalarVariable, fmiXMLAttrID_valueReference, 1, variable->vr, 0)) return -1;

            {
                jm_name_ID_map_t variabilityConventionMap[] = {{"continuous",fmiVariabilityContinuous},
                                                               {"constant", fmiVariabilityConstant},
                                                               {"parameter", fmiVariabilityParameter},
                                                               {"discrete", fmiVariabilityDiscrete},{0,0}};
                unsigned int variability;
                /*  <xs:attribute name="variability" default="continuous"> */
                if(fmiXMLSetAttrEnum(context, fmiXMLElmID_ScalarVariable, fmiXMLAttrID_variability,0,&variability,fmiVariabilityContinuous,variabilityConventionMap))
                    return -1;
                variable->variability = variability;
            }
            {
                jm_name_ID_map_t causalityConventionMap[] = {{"internal",fmiCausalityInternal},
                                                             {"input",fmiCausalityInput},
                                                             {"output",fmiCausalityOutput},
                                                             {"none",fmiCausalityNone},{0,0}};
                /* <xs:attribute name="causality" default="internal"> */
                unsigned int causality;
                if(fmiXMLSetAttrEnum(context, fmiXMLElmID_ScalarVariable, fmiXMLAttrID_causality,0,&causality,fmiCausalityInternal,causalityConventionMap))
                    return -1;
                variable->causality = causality;
            }
            {
                jm_name_ID_map_t aliasConventionMap[] = {{"alias", 1}, {"negatedAlias", 2}, {"noAlias", 0}, {0,0}};
                unsigned int alias;
                /* <xs:attribute name="alias" default="noAlias"> */
                if(fmiXMLSetAttrEnum(context, fmiXMLElmID_ScalarVariable, fmiXMLAttrID_alias ,0,&alias,0,aliasConventionMap))
                    return -1;
                if(alias == 1) variable->aliasKind = 1;
                else if(alias == 2) variable->aliasKind = -1;
                else variable->aliasKind = 0;
            }
        }
    }
    else {
        /* check that the type for the variable is set */
         fmiModelDescription* md = context->modelDescription;
         fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
         if(!variable->typeBase) {
             fmiXMLParseError(context, "No variable type element for variable %s", variable->name);
             return -1;
         }
        /* might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}


int fmiXMLHandle_DirectDependency(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        if(context -> currentElmHandle != fmiXMLHandle_ScalarVariable) {
            fmiXMLParseError(context, "DirectDependency XML element must be a part of ScalarVariable");
            return -1;
        }
    }
    else {
        fmiModelDescription* md = context->modelDescription;
        fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        if(jm_vector_get_size(jm_voidp)(&context->directDependencyBuf)) {
            variable->directDependency = jm_vector_clone(jm_voidp)(&context->directDependencyBuf);
            if(!variable->directDependency) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
        }
        jm_vector_resize(jm_voidp)(&context->directDependencyBuf,0);
    }
}

int fmiXMLHandle_Name(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_DirectDependency) {
            fmiXMLParseError(context, "Name XML element must be a part of DirectDependency");
            return -1;
        }
    }
    else {
        fmiModelDescription* md = context->modelDescription;
        fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        size_t namelen = strlen(data) + 1;
        char* name = 0;
        jm_voidp* itemp;
        char** namep;
        if(namelen == 0) {
            fmiXMLParseError(context, "Unexpected empty Name element for DirectDependency of variable %s", variable->name);
            return -1;
        }
        itemp = jm_vector_push_back(jm_voidp)(&context->directDependencyBuf, name);
        if(itemp) *itemp = name = context->callbacks->malloc(namelen);
        if(!itemp || !name)  {
            fmiXMLParseError(context, "Could not allocate memory");
            return -1;
        }
        memcpy(name, data, namelen);
    }
    return 0;
}

int fmiXMLHandle_Real(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        fmiTypeDefinitions* td = &md->typeDefinitions;
        fmiVariableTypeBase * declaredType = 0;
        fmiRealTypeProperties * type = 0;
        int hasStart;

        if(context -> currentElmHandle != fmiXMLHandle_ScalarVariable) {
            fmiXMLParseError(context, "Real XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmiXMLParseError(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        declaredType = fmiXMLGetDeclaredType(context, fmiXMLElmID_Real, &td->defaultRealType.typeBase);

        if(!declaredType) return -1;

        if(
                fmiXMLAttrIsDefined(fmiXMLAttrID_unit) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_displayUnit) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_min) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_max) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_nominal) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_quantity) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_relativeQuantity)
                ) {
            fmiRealTypeProperties* props = 0;

            if(declaredType->structKind == fmiTypeStructProperties)
                props = (fmiRealTypeProperties* )declaredType;
            else
                props = (fmiRealTypeProperties*)(declaredType->baseTypeStruct);

            fmiXMLReserveParseBuffer(context, 1, 0);
            fmiXMLReserveParseBuffer(context, 2, 0);

            type = fmiParseRealTypeProperties(context, fmiXMLElmID_Real);

            if(!type) return -1;
            type->typeBase.baseTypeStruct = declaredType;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_displayUnit)) type->displayUnit = props->displayUnit;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_min)) type->typeMin = props->typeMin;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_max)) type->typeMax = props->typeMax;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_nominal)) type->typeNominal = props->typeNominal;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_quantity)) type->quantity = props->quantity;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_relativeQuantity)) type->typeBase.relativeQuantity = props->typeBase.relativeQuantity;
        }
        else
            type = (fmiRealTypeProperties*)declaredType;

        variable->typeBase = &type->typeBase;

        hasStart = fmiXMLAttrIsDefined(fmiXMLAttrID_start);
        if(hasStart) {
            fmiVariableStartReal * start = (fmiVariableStartReal*)fmiAllocVariableTypeStart(td, &type->typeBase, sizeof(fmiVariableStartReal));
            if(!start) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            if(
                /*  <xs:attribute name="start" type="xs:double"/> */
                    fmiXMLSetAttrDouble(context, fmiXMLElmID_Real, fmiXMLAttrID_start, 0, &start->start, 0) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmiXMLSetAttrBoolean(context, fmiXMLElmID_Real, fmiXMLAttrID_fixed, 0, &(start->typeBase.isFixed), 1)
                )
                    return -1;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmiXMLAttrIsDefined(fmiXMLAttrID_fixed)) {
                fmiXMLParseError(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_Integer(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        fmiTypeDefinitions* td = &md->typeDefinitions;
        fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        fmiVariableTypeBase * declaredType = 0;
        fmiIntegerTypeProperties * type = 0;
        int hasStart;

        if(context -> currentElmHandle != fmiXMLHandle_ScalarVariable) {
            fmiXMLParseError(context, "Integer XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmiXMLParseError(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        declaredType = fmiXMLGetDeclaredType(context, fmiXMLElmID_Integer,&td->defaultIntegerType.typeBase) ;

        if(!declaredType) return -1;

        if(
                fmiXMLAttrIsDefined(fmiXMLAttrID_min) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_max) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_quantity)
                ) {
            fmiIntegerTypeProperties* props = 0;

            if(declaredType->structKind == fmiTypeStructProperties)
                props = (fmiIntegerTypeProperties*)declaredType;
            else
                props = (fmiIntegerTypeProperties*)(declaredType->baseTypeStruct);
            assert(props->typeBase.structKind == fmiTypeStructProperties);
            fmiXMLReserveParseBuffer(context, 1, 0);
            fmiXMLReserveParseBuffer(context, 2, 0);
            type = fmiParseIntegerTypeProperties(context, fmiXMLElmID_Integer);
            if(!type) return -1;
            type->typeBase.baseTypeStruct = declaredType;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_min)) type->typeMin = props->typeMin;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_max)) type->typeMax = props->typeMax;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_quantity)) type->quantity = props->quantity;
        }
        else
            type = (fmiIntegerTypeProperties*)declaredType;

        variable->typeBase = &type->typeBase;

        hasStart = fmiXMLAttrIsDefined(fmiXMLAttrID_start);
        if(hasStart) {
            fmiVariableStartInteger * start = (fmiVariableStartInteger*)fmiAllocVariableTypeStart(td, &type->typeBase, sizeof(fmiVariableStartInteger));
            if(!start) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            if(
                /*  <xs:attribute name="start" type="xs:integer"/> */
                    fmiXMLSetAttrInt(context, fmiXMLElmID_Integer, fmiXMLAttrID_start, 0, &start->start, 0) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmiXMLSetAttrBoolean(context, fmiXMLElmID_Integer, fmiXMLAttrID_fixed, 0, &(start->typeBase.isFixed), 1)
                )
                    return -1;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmiXMLAttrIsDefined(fmiXMLAttrID_fixed)) {
                fmiXMLParseError(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_Boolean(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        fmiTypeDefinitions* td = &md->typeDefinitions;
        fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        int hasStart;

        if(context -> currentElmHandle != fmiXMLHandle_ScalarVariable) {
            fmiXMLParseError(context, "Boolean XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmiXMLParseError(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        variable->typeBase = fmiXMLGetDeclaredType(context, fmiXMLElmID_Boolean, &td->defaultBooleanType) ;

        if(!variable->typeBase) return -1;

        hasStart = fmiXMLAttrIsDefined(fmiXMLAttrID_start);
        if(hasStart) {
            fmiVariableStartInteger * start = (fmiVariableStartInteger*)fmiAllocVariableTypeStart(td, variable->typeBase, sizeof(fmiVariableStartInteger));
            if(!start) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            if(
                  /*  <xs:attribute name="start" type="xs:boolean"/> */
                    fmiXMLSetAttrBoolean(context, fmiXMLElmID_Boolean, fmiXMLAttrID_start, 0, &start->start, 0) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmiXMLSetAttrBoolean(context, fmiXMLElmID_Boolean, fmiXMLAttrID_fixed, 0, &(start->typeBase.isFixed), 1)
                )
                    return -1;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmiXMLAttrIsDefined(fmiXMLAttrID_fixed)) {
                fmiXMLParseError(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }            
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_String(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        fmiTypeDefinitions* td = &md->typeDefinitions;
        fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        int hasStart;

        if(context -> currentElmHandle != fmiXMLHandle_ScalarVariable) {
            fmiXMLParseError(context, "String XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmiXMLParseError(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        variable->typeBase = fmiXMLGetDeclaredType(context, fmiXMLElmID_String,&td->defaultStringType) ;

        if(!variable->typeBase) return -1;

        hasStart = fmiXMLAttrIsDefined(fmiXMLAttrID_start);
        if(hasStart) {
            jm_vector(char)* bufStartStr = fmiXMLReserveParseBuffer(context,1, 100);
            size_t strlen;
            int isFixed;
            char* str = 0;
            fmiVariableStartString * start;
            if(
                 /*   <xs:attribute name="start" type="xs:string"/> */
                    fmiXMLSetAttrString(context, fmiXMLElmID_String, fmiXMLAttrID_start, 0, bufStartStr) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmiXMLSetAttrBoolean(context, fmiXMLElmID_Boolean, fmiXMLAttrID_fixed, 0, isFixed, 1)
                )
                    return -1;
            strlen = jm_vector_get_size_char(bufStartStr);

            start = (fmiVariableStartString*)fmiAllocVariableTypeStart(td, variable->typeBase, sizeof(fmiVariableStartString) + strlen);

            if(!start) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            memcpy(start->start, jm_vector_get_itemp_char(bufStartStr,0), strlen);
            str[strlen] = 0;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmiXMLAttrIsDefined(fmiXMLAttrID_fixed)) {
                fmiXMLParseError(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_Enumeration(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        fmiModelDescription* md = context->modelDescription;
        fmiTypeDefinitions* td = &md->typeDefinitions;
        fmiVariable* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        fmiVariableTypeBase * declaredType = 0;
        fmiIntegerTypeProperties * type = 0;
        int hasStart;

        if(context -> currentElmHandle != fmiXMLHandle_ScalarVariable) {
            fmiXMLParseError(context, "Integer XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmiXMLParseError(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        declaredType = fmiXMLGetDeclaredType(context, fmiXMLElmID_Enumeration,&td->defaultEnumType.typeBase);

        if(!declaredType) return -1;

        if(
                fmiXMLAttrIsDefined(fmiXMLAttrID_min) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_max) ||
                fmiXMLAttrIsDefined(fmiXMLAttrID_quantity)
                ) {
            fmiIntegerTypeProperties* props = 0;

            if(declaredType->structKind == fmiTypeStructProperties)
                props = (fmiIntegerTypeProperties*)declaredType;
            else
                props = (fmiIntegerTypeProperties*)declaredType->baseTypeStruct;
            assert(props->typeBase.structKind == fmiTypeStructProperties);
            fmiXMLReserveParseBuffer(context, 1, 0);
            fmiXMLReserveParseBuffer(context, 2, 0);
            type = fmiParseIntegerTypeProperties(context, fmiXMLElmID_Enumeration);
            if(!type) return -1;
            type->typeBase.baseTypeStruct = declaredType;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_min)) type->typeMin = props->typeMin;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_max)) type->typeMax = props->typeMax;
            if(!fmiXMLAttrIsDefined(fmiXMLAttrID_quantity)) type->quantity = props->quantity;
        }
        else
            type = (fmiIntegerTypeProperties*)declaredType;

        variable->typeBase = &type->typeBase;

        hasStart = fmiXMLAttrIsDefined(fmiXMLAttrID_start);
        if(hasStart) {
            fmiVariableStartInteger * start = (fmiVariableStartInteger*)fmiAllocVariableTypeStart(td, &type->typeBase, sizeof(fmiVariableStartInteger));
            if(!start) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            if(
                /*  <xs:attribute name="start" type="xs:integer"/> */
                    fmiXMLSetAttrInt(context, fmiXMLElmID_Enumeration, fmiXMLAttrID_start, 0, &start->start, 0) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmiXMLSetAttrBoolean(context, fmiXMLElmID_Enumeration, fmiXMLAttrID_fixed, 0, &(start->typeBase.isFixed), 1)
                )
                    return -1;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmiXMLAttrIsDefined(fmiXMLAttrID_fixed)) {
                fmiXMLParseError(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }            
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

