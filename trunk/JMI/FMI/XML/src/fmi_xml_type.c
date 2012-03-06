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

#include <limits.h>
#include <float.h>
#include <string.h>

#include "fmi_xml_model_description_impl.h"
#include "fmi_xml_type_impl.h"
#include "fmi_xml_unit_impl.h"
#include "fmi_xml_parser.h"

const char* fmi_xml_base_type2string(fmi_xml_base_type_enu_t bt) {
    switch(bt) {
    case fmi_xml_base_type_enu_real: return "Real";
    case fmi_xml_base_type_enu_int: return "Integer";
    case fmi_xml_base_type_enu_bool: return "Boolean";
    case fmi_xml_base_type_enu_str: return "String";
    case fmi_xml_base_type_enu_enum: return "Enumeration";
    }
    return "Error";
}

fmi_xml_display_unit_t* fmi_xml_get_type_display_unit(fmi_xml_real_typedef_t* t) {
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_real_type_props_t * props = (fmi_xml_real_type_props_t*)vt->typeBase.baseTypeStruct;
    fmi_xml_display_unit_t* du = props->displayUnit;
    if(du->displayUnit) return du;
    return 0;
}

size_t fmi_xml_get_type_definition_number(fmi_xml_type_definitions_t* td) {
    return jm_vector_get_size(jm_named_ptr)(&td->typeDefinitions);
}

fmi_xml_variable_typedef_t* fmi_xml_get_typedef(fmi_xml_type_definitions_t* td, unsigned int  index) {
    if(index >= fmi_xml_get_type_definition_number(td)) return 0;
    return jm_vector_get_item(jm_named_ptr)(&td->typeDefinitions, index).ptr;
}

const char* fmi_xml_get_type_name(fmi_xml_variable_typedef_t* t) {   
    return t->typeName;
}

/* Note that NULL pointer is returned if the attribute is not present in the XML.*/
const char* fmi_xml_get_type_description(fmi_xml_variable_typedef_t* t) {
    return t->description;
}

fmi_xml_base_type_enu_t fmi_xml_get_base_type(fmi_xml_variable_typedef_t* t) {
    return t->typeBase.baseType;
}

fmi_xml_real_typedef_t* fmi_xml_ret_type_as_real(fmi_xml_variable_typedef_t* t) {
    if(fmi_xml_get_base_type(t) == fmi_xml_base_type_enu_real) return (fmi_xml_real_typedef_t*)t;
    return 0;
}
fmi_xml_integer_typedef_t* fmi_xml_get_type_as_int(fmi_xml_variable_typedef_t* t) {
    if(fmi_xml_get_base_type(t) == fmi_xml_base_type_enu_int) return (fmi_xml_integer_typedef_t*)t;
    return 0;
}

fmi_xml_enumeration_typedef_t* fmi_xml_get_type_as_enum(fmi_xml_variable_typedef_t* t) {
    if(fmi_xml_get_base_type(t) == fmi_xml_base_type_enu_enum) return (fmi_xml_enumeration_typedef_t*)t;
    return 0;
}

/* Note that 0-pointer is returned for strings and booleans, empty string quantity if not defined*/
const char* fmi_xml_get_type_quantity(fmi_xml_variable_typedef_t* t) {
    fmi_xml_variable_type_base_t* props = t->typeBase.baseTypeStruct;
    if(props->structKind != fmi_xml_type_struct_enu_props) return 0;
    switch(props->baseType) {
    case fmi_xml_base_type_enu_real:
        return ((fmi_xml_real_type_props_t*)props)->quantity;
    case fmi_xml_base_type_enu_int:
        return ((fmi_xml_integer_type_props_t*)props)->quantity;
    case fmi_xml_base_type_enu_bool:
        return 0;
    case fmi_xml_base_type_enu_str:
        return 0;
    case fmi_xml_base_type_enu_enum:
        return ((fmi_xml_enum_type_props_t*)props)->quantity;
    default:
        return 0;
    }
}

fmi_xml_real_t fmi_xml_get_real_type_min(fmi_xml_real_typedef_t* t) {
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_real_type_props_t* props = (fmi_xml_real_type_props_t*)(vt->typeBase.baseTypeStruct);
    return props->typeMin;
}

fmi_xml_real_t fmi_xml_get_real_type_max(fmi_xml_real_typedef_t* t) {
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_real_type_props_t* props = (fmi_xml_real_type_props_t*)(vt->typeBase.baseTypeStruct);
    return props->typeMax;
}

fmi_xml_real_t fmi_xml_get_real_type_nominal(fmi_xml_real_typedef_t* t) {
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_real_type_props_t* props = (fmi_xml_real_type_props_t*)(vt->typeBase.baseTypeStruct);
    return props->typeNominal;
}

fmi_xml_unit_t* fmi_xml_get_real_type_unit(fmi_xml_real_typedef_t* t) {    
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_real_type_props_t* props = (fmi_xml_real_type_props_t*)(vt->typeBase.baseTypeStruct);
    fmi_xml_display_unit_t* du = props->displayUnit;
    if(du) return du->baseUnit;
    return 0;
}

int fmi_xml_get_real_type_is_relative_quantity(fmi_xml_real_typedef_t* t) {
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_real_type_props_t* props = (fmi_xml_real_type_props_t*)(vt->typeBase.baseTypeStruct);
    return props->typeBase.relativeQuantity;
}

fmi_xml_int_t fmi_xml_get_integer_type_min(fmi_xml_integer_typedef_t* t) {
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_integer_type_props_t* props = (fmi_xml_integer_type_props_t*)(vt->typeBase.baseTypeStruct);
    return props->typeMin;
}

fmi_xml_int_t fmi_xml_get_integer_type_max(fmi_xml_integer_typedef_t* t){
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_integer_type_props_t* props = (fmi_xml_integer_type_props_t*)(vt->typeBase.baseTypeStruct);
    return props->typeMax;
}

fmi_xml_int_t fmi_xml_get_enum_type_min(fmi_xml_enumeration_typedef_t* t){
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_enum_type_props_t* props = (fmi_xml_enum_type_props_t*)(vt->typeBase.baseTypeStruct);
    return props->typeMin;
}

fmi_xml_int_t fmi_xml_get_enum_type_max(fmi_xml_enumeration_typedef_t* t){
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_enum_type_props_t* props = (fmi_xml_enum_type_props_t*)(vt->typeBase.baseTypeStruct);
    return props->typeMax;
}

unsigned int  fmi_xml_get_enum_type_size(fmi_xml_enumeration_typedef_t* t) {
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_enum_type_props_t* props = (fmi_xml_enum_type_props_t*)(vt->typeBase.baseTypeStruct);
    return jm_vector_get_size(jm_named_ptr)(&props->enumItems);
}

const char* fmi_xml_get_enum_type_item_name(fmi_xml_enumeration_typedef_t* t, unsigned int  item) {
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_enum_type_props_t* props = (fmi_xml_enum_type_props_t*)(vt->typeBase.baseTypeStruct);
    if(item >= fmi_xml_get_enum_type_size(t) ) return  0;
    return jm_vector_get_item(jm_named_ptr)(&props->enumItems,item).name;
}

const char* fmi_xml_get_enum_type_item_description(fmi_xml_enumeration_typedef_t* t, unsigned int  item){
    fmi_xml_variable_typedef_t* vt = (void*)t;
    fmi_xml_enum_type_props_t* props = (fmi_xml_enum_type_props_t*)(vt->typeBase.baseTypeStruct);
    fmi_xml_enum_type_item_t* e;
    if(item >= fmi_xml_get_enum_type_size(t) ) return  0;
    e = jm_vector_get_item(jm_named_ptr)(&props->enumItems,item).ptr;
    return e->itemDesciption;
}

void fmi_xml_init_variable_type_base(fmi_xml_variable_type_base_t* type, fmi_xml_type_struct_kind_enu_t kind, fmi_xml_base_type_enu_t baseType) {
    type->baseTypeStruct = 0;
    type->next = 0;
    type->structKind = kind;
    type->baseType = baseType;
    type->relativeQuantity = 0;
    type->isFixed = 0;
}

void fmi_xml_init_real_type_properties(fmi_xml_real_type_props_t* type) {
    fmi_xml_init_variable_type_base(&type->typeBase, fmi_xml_type_struct_enu_props,fmi_xml_base_type_enu_real);
    type->quantity = 0;    
    type->typeMin = -DBL_MAX;
    type->typeMax = DBL_MAX;
    type->typeNominal = 1.0;
    type->displayUnit = 0;
}

void fmi_xml_init_integer_type_properties(fmi_xml_integer_type_props_t* type) {
    fmi_xml_init_variable_type_base(&type->typeBase, fmi_xml_type_struct_enu_props,fmi_xml_base_type_enu_int);
    type->quantity = 0;
    type->typeMin = INT_MIN;
    type->typeMax = INT_MAX;
}

void fmi_xml_init_enumeration_type_properties(fmi_xml_enum_type_props_t* type, jm_callbacks* cb) {
    fmi_xml_init_variable_type_base(&type->typeBase, fmi_xml_type_struct_enu_props,fmi_xml_base_type_enu_enum);
    type->quantity = 0;
    type->typeMin = INT_MIN;
    type->typeMax = INT_MAX;
    jm_vector_init(jm_named_ptr)(&type->enumItems,0,cb);
}

void fmi_xml_free_enumeration_type_props(fmi_xml_enum_type_props_t* type) {
    jm_named_vector_free_data(&type->enumItems);
}


void fmi_xml_init_type_definitions(fmi_xml_type_definitions_t* td, jm_callbacks* cb) {
    jm_vector_init(jm_named_ptr)(&td->typeDefinitions,0,cb);

    jm_vector_init(jm_string)(&td->quantities, 0, cb);

    fmi_xml_init_real_type_properties(&td->defaultRealType);
    td->defaultRealType.typeBase.structKind = fmi_xml_type_struct_enu_base;
    fmi_xml_init_enumeration_type_properties(&td->defaultEnumType,cb);
    td->defaultEnumType.typeBase.structKind = fmi_xml_type_struct_enu_base;
    fmi_xml_init_integer_type_properties(&td->defaultIntegerType);
    td->defaultIntegerType.typeBase.structKind = fmi_xml_type_struct_enu_base;

    fmi_xml_init_variable_type_base(&td->defaultBooleanType, fmi_xml_type_struct_enu_base,fmi_xml_base_type_enu_bool);
    fmi_xml_init_variable_type_base(&td->defaultStringType, fmi_xml_type_struct_enu_base,fmi_xml_base_type_enu_str);

    td->typePropsList = 0;
}

void fmi_xml_free_type_definitions_data(fmi_xml_type_definitions_t* td) {
    jm_callbacks* cb = td->typeDefinitions.callbacks;

    jm_vector_foreach(jm_string)(&td->quantities,(void(*)(const char*))cb->free);
    jm_vector_free_data(jm_string)(&td->quantities);

    {
        fmi_xml_variable_type_base_t* next;
        fmi_xml_variable_type_base_t* cur = td->typePropsList;
        while(cur) {
            next = cur->next;
            if((cur->baseType == fmi_xml_base_type_enu_enum) && (cur->structKind == fmi_xml_type_struct_enu_props)) {
                fmi_xml_enum_type_props_t* props = (fmi_xml_enum_type_props_t*)cur;
                fmi_xml_free_enumeration_type_props(props);
            }
            cb->free(cur);
            cur = next;
        }
    }

    jm_named_vector_free_data(&td->typeDefinitions);
}

int fmi_xml_handle_TypeDefinitions(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_fmiModelDescription) {
            fmi_xml_parse_error(context, "TypeDefinitions XML element must be a part of fmiModelDescription");
            return -1;
        }
        if((context->lastElmHandle != 0)  &&
           (context->lastElmHandle != fmi_xml_handle_UnitDefinitions)
          ) {
            fmi_xml_parse_error(context, "TypeDefinitions XML element must follow UnitDefinitions");
            return -1;
        }
    }
    else {
        fmi_xml_type_definitions_t* defs =  &context->modelDescription->typeDefinitions;

        jm_vector_qsort(jm_named_ptr)(&defs->typeDefinitions, jm_compare_named);
        /* might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_xml_handle_Type(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_TypeDefinitions) {
            fmi_xml_parse_error(context, "Type XML element must be a part of TypeDefinitions");
            return -1;
        }
        {            
            fmi_xml_model_description_t* md = context->modelDescription;
            fmi_xml_type_definitions_t* td = &md->typeDefinitions;
            jm_named_ptr named, *pnamed;
            jm_vector(char)* bufName = fmi_xml_reserve_parse_buffer(context,1,100);
            jm_vector(char)* bufDescr = fmi_xml_reserve_parse_buffer(context,2,100);

            if(!bufName || !bufDescr) return -1;
            if(
            /*  <xs:attribute name="name" type="xs:normalizedString" use="required"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_Type, fmi_attr_id_name, 1, bufName) ||
            /* <xs:attribute name="description" type="xs:string"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_Type, fmi_attr_id_description, 0, bufDescr)
                    ) return -1;
            named.ptr = 0;
			named.name = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&td->typeDefinitions,named);
            if(pnamed) {
                fmi_xml_variable_typedef_t dummy;
                *pnamed = named = jm_named_alloc_v(bufName, sizeof(fmi_xml_variable_typedef_t), dummy.typeName - (char*)&dummy,  context->callbacks);
            }
            if(!pnamed || !named.ptr) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            else {
                fmi_xml_variable_typedef_t* type = named.ptr;
                fmi_xml_init_variable_type_base(&type->typeBase,fmi_xml_type_struct_enu_typedef,fmi_xml_base_type_enu_real);
                if(jm_vector_get_size(char)(bufDescr)) {
                    const char* description = jm_string_set_put(&md->descriptions, jm_vector_get_itemp(char)(bufDescr,0));
                    type->description = description;
                }
                else type->description = "";
            }
        }
    }
    else {
        jm_named_ptr named = jm_vector_get_last(jm_named_ptr)(&(context->modelDescription->typeDefinitions.typeDefinitions));
        fmi_xml_variable_typedef_t* type = named.ptr;
        if(type->typeBase.baseTypeStruct == 0) {
            fmi_xml_parse_error(context, "No specific type given for type definition %s", type->typeName);
            return -1;
        }
        /* might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_check_last_elem_is_specific_type(fmi_xml_parser_context_t *context) {
    if(context -> currentElmHandle != fmi_xml_handle_Type) {
        fmi_xml_parse_error(context, "Specific element types XML elements must be a part of Type element");
        return -1;
    }
    if (
                (context->lastElmHandle == fmi_xml_handle_RealType)  ||
                (context->lastElmHandle == fmi_xml_handle_IntegerType)  ||
                (context->lastElmHandle == fmi_xml_handle_BooleanType)  ||
                (context->lastElmHandle == fmi_xml_handle_StringType)  ||
                (context->lastElmHandle == fmi_xml_handle_EnumerationType)
                ) {
        fmi_xml_parse_error(context, "Multiple definitions for a type aer not allowed");
        return -1;
    }
    return 0;
}

fmi_xml_variable_type_base_t* fmi_xml_alloc_variable_type_props(fmi_xml_type_definitions_t* td, fmi_xml_variable_type_base_t* base, size_t typeSize) {
    jm_callbacks* cb = td->typeDefinitions.callbacks;
    fmi_xml_variable_type_base_t* type = cb->malloc(typeSize);
    if(!type) return 0;
    fmi_xml_init_variable_type_base(type,fmi_xml_type_struct_enu_props,base->baseType);
    type->baseTypeStruct = base;
    type->next = td->typePropsList;
    td->typePropsList = type;
    return type;
}

fmi_xml_variable_type_base_t* fmi_xml_alloc_variable_type_start(fmi_xml_type_definitions_t* td,fmi_xml_variable_type_base_t* base, size_t typeSize) {
    jm_callbacks* cb = td->typeDefinitions.callbacks;
    fmi_xml_variable_type_base_t* type = cb->malloc(typeSize);
    if(!type) return 0;
    fmi_xml_init_variable_type_base(type,fmi_xml_type_struct_enu_start,base->baseType);
    type->baseTypeStruct = base;
    type->next = td->typePropsList;
    td->typePropsList = type;
    return type;
}


fmi_xml_real_type_props_t* fmi_xml_parse_real_type_properties(fmi_xml_parser_context_t* context, fmi_xml_elm_enu_t elmID) {
    jm_named_ptr named, *pnamed;
    fmi_xml_model_description_t* md = context->modelDescription;
    fmi_xml_real_type_props_t* props;
    const char* quantity = 0;
    int boolBuf;

/*        jm_vector(char)* bufName = fmi_get_parse_buffer(context,1);
    jm_vector(char)* bufDescr = fmi_get_parse_buffer(context,2); */
    jm_vector(char)* bufQuantity = fmi_xml_reserve_parse_buffer(context,3,100);
    jm_vector(char)* bufUnit = fmi_xml_reserve_parse_buffer(context,4,100);
    jm_vector(char)* bufDispUnit = fmi_xml_reserve_parse_buffer(context,5,100);

    props = (fmi_xml_real_type_props_t*)fmi_xml_alloc_variable_type_props(&md->typeDefinitions, &md->typeDefinitions.defaultRealType.typeBase, sizeof(fmi_xml_real_type_props_t));

    if(!bufQuantity || !bufUnit || !bufDispUnit || !props ||
            /* <xs:attribute name="quantity" type="xs:normalizedString"/> */
            fmi_xml_set_attr_string(context, elmID, fmi_attr_id_quantity, 0, bufQuantity) ||
            /* <xs:attribute name="unit" type="xs:normalizedString"/>  */
            fmi_xml_set_attr_string(context, elmID, fmi_attr_id_unit, 0, bufUnit) ||
            /* <xs:attribute name="displayUnit" type="xs:normalizedString">  */
            fmi_xml_set_attr_string(context, elmID, fmi_attr_id_displayUnit, 0, bufDispUnit)
            ) {
        fmi_xml_parse_error(context, "Error parsing real type properties");
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
            fmi_xml_parse_error(context, "Unknown display unit %s in real type definition", jm_vector_get_itemp(char)(bufDispUnit, 0));
            return 0;
        }
        props->displayUnit = pnamed->ptr;
    }
    else {
        if(jm_vector_get_size(char)(bufUnit)) {
            props->displayUnit = fmi_xml_get_parsed_unit(context, bufUnit, 1);
        }
    }
    if(    /*    <xs:attribute name="relativeQuantity" type="xs:boolean" default="false"> */
            fmi_xml_set_attr_boolean(context, elmID, fmi_attr_id_relativeQuantity, 0, &boolBuf, 0) ||
            /* <xs:attribute name="min" type="xs:double"/> */
            fmi_xml_set_attr_double(context, elmID, fmi_attr_id_min, 0, &props->typeMin, -DBL_MAX) ||
            /* <xs:attribute name="max" type="xs:double"/> */
            fmi_xml_set_attr_double(context, elmID, fmi_attr_id_max, 0, &props->typeMax, DBL_MAX) ||
            /*  <xs:attribute name="nominal" type="xs:double"/> */
            fmi_xml_set_attr_double(context, elmID, fmi_attr_id_nominal, 0, &props->typeNominal, 1)
            ) return 0;
    props->typeBase.relativeQuantity = boolBuf;
    return props;
}

int fmi_xml_handle_RealType(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        jm_named_ptr named;
        fmi_xml_variable_typedef_t* type;
        fmi_xml_real_type_props_t * props;
        if(fmi_check_last_elem_is_specific_type(context)) return -1;

        props = fmi_xml_parse_real_type_properties(context, fmi_xml_elmID_RealType);
        if(!props) return -1;
        named = jm_vector_get_last(jm_named_ptr)(&md->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmi_xml_base_type_enu_real;
        type->typeBase.baseTypeStruct = &props->typeBase;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

fmi_xml_integer_type_props_t * fmi_xml_parse_integer_type_properties(fmi_xml_parser_context_t* context, fmi_xml_elm_enu_t elmID) {

    fmi_xml_model_description_t* md = context->modelDescription;
    fmi_xml_integer_type_props_t * props = 0;
    const char* quantity = 0;

    /*        jm_vector(char)* bufName = fmi_get_parse_buffer(context,1);
            jm_vector(char)* bufDescr = fmi_get_parse_buffer(context,2); */
    jm_vector(char)* bufQuantity = fmi_xml_reserve_parse_buffer(context,3,100);

    props = (fmi_xml_integer_type_props_t*)fmi_xml_alloc_variable_type_props(&md->typeDefinitions, &md->typeDefinitions.defaultIntegerType.typeBase, sizeof(fmi_xml_integer_type_props_t));

    if(!bufQuantity || !props ||
            /* <xs:attribute name="quantity" type="xs:normalizedString"/> */
            fmi_xml_set_attr_string(context, elmID, fmi_attr_id_quantity, 0, bufQuantity)
            )
        return 0;
    if(jm_vector_get_size(char)(bufQuantity))
        quantity = jm_string_set_put(&md->typeDefinitions.quantities, jm_vector_get_itemp(char)(bufQuantity, 0));

    props->quantity = quantity;

    if(
            /* <xs:attribute name="min" type="xs:int"/> */
            fmi_xml_set_attr_int(context, elmID, fmi_attr_id_min, 0, &props->typeMin, INT_MIN) ||
            /* <xs:attribute name="max" type="xs:int"/> */
            fmi_xml_set_attr_int(context, elmID, fmi_attr_id_max, 0, &props->typeMax, INT_MAX)
            ) return 0;
    return props;
}

int fmi_xml_handle_IntegerType(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        jm_named_ptr named;
        fmi_xml_variable_typedef_t* type;
        fmi_xml_integer_type_props_t * props;
        if(fmi_check_last_elem_is_specific_type(context)) return -1;

        props = fmi_xml_parse_integer_type_properties(context, fmi_xml_elmID_IntegerType);
        if(!props) return -1;
        named = jm_vector_get_last(jm_named_ptr)(&md->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmi_xml_base_type_enu_int;
        type->typeBase.baseTypeStruct = &props->typeBase;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}


int fmi_xml_handle_BooleanType(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        jm_named_ptr named;
        fmi_xml_variable_typedef_t* type;
        if(fmi_check_last_elem_is_specific_type(context)) return -1;

        named = jm_vector_get_last(jm_named_ptr)(&context->modelDescription->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmi_xml_base_type_enu_bool;
        type->typeBase.baseTypeStruct = &md->typeDefinitions.defaultBooleanType;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_xml_handle_StringType(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        jm_named_ptr named;
        fmi_xml_variable_typedef_t* type;
        if(fmi_check_last_elem_is_specific_type(context)) return -1;

        named = jm_vector_get_last(jm_named_ptr)(&context->modelDescription->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmi_xml_base_type_enu_bool;
        type->typeBase.baseTypeStruct = &md->typeDefinitions.defaultBooleanType;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_xml_handle_EnumerationType(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        jm_named_ptr named;
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_enum_type_props_t * props;
        fmi_xml_variable_typedef_t* type;
        const char * quantity = 0;
        /*        jm_vector(char)* bufName = fmi_get_parse_buffer(context,1);
                jm_vector(char)* bufDescr = fmi_get_parse_buffer(context,2); */
        jm_vector(char)* bufQuantity = fmi_xml_reserve_parse_buffer(context,3,100);

        if(fmi_check_last_elem_is_specific_type(context)) return -1;

        props = (fmi_xml_enum_type_props_t*)fmi_xml_alloc_variable_type_props(&md->typeDefinitions, &md->typeDefinitions.defaultEnumType.typeBase, sizeof(fmi_xml_enum_type_props_t));
        if(props) jm_vector_init(jm_named_ptr)(&props->enumItems,0,context->callbacks);
        if(!bufQuantity || !props ||
                /* <xs:attribute name="quantity" type="xs:normalizedString"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_IntegerType, fmi_attr_id_quantity, 0, bufQuantity)
                )
            return -1;
        if(jm_vector_get_size(char)(bufQuantity))
            quantity = jm_string_set_put(&md->typeDefinitions.quantities, jm_vector_get_itemp(char)(bufQuantity, 0));

        props->quantity = quantity;



        if(
                /* <xs:attribute name="min" type="xs:int"/> */
                fmi_xml_set_attr_int(context, fmi_xml_elmID_EnumerationType, fmi_attr_id_min, 0,  &props->typeMin, 1) ||
                /* <xs:attribute name="max" type="xs:int"/> */
                fmi_xml_set_attr_int(context, fmi_xml_elmID_EnumerationType, fmi_attr_id_max, 0, &props->typeMax, INT_MAX)
                ) return -1;
        named = jm_vector_get_last(jm_named_ptr)(&context->modelDescription->typeDefinitions.typeDefinitions);
        type = named.ptr;
        type->typeBase.baseType = fmi_xml_base_type_enu_enum;
        type->typeBase.baseTypeStruct = &props->typeBase;
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_xml_handle_Item(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_EnumerationType) {
            fmi_xml_parse_error(context, "Item XML element must be a part of EnumerationType");
            return -1;
        }

        {
            fmi_xml_model_description_t* md = context->modelDescription;
            jm_vector(char)* bufName = fmi_xml_reserve_parse_buffer(context,1,100);
            jm_vector(char)* bufDescr = fmi_xml_reserve_parse_buffer(context,2,100);
            /* this enum item belongs to the last created enum = head of typePropsList */
            fmi_xml_enum_type_props_t * enumProps = (fmi_xml_enum_type_props_t*)md->typeDefinitions.typePropsList;
            fmi_xml_enum_type_item_t * item;
            jm_named_ptr named, *pnamed;
            size_t descrlen;

            assert((enumProps->typeBase.structKind == fmi_xml_type_struct_enu_props) && (enumProps->typeBase.baseType == fmi_xml_base_type_enu_enum));

            if(!bufName || !bufDescr ||
            /*  <xs:attribute name="name" type="xs:normalizedString" use="required"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_Type, fmi_attr_id_name, 1, bufName) ||
            /* <xs:attribute name="description" type="xs:string"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_Type, fmi_attr_id_description, 0, bufDescr)
                    )
                return -1;
            descrlen = jm_vector_get_size(char)(bufDescr);
            named.ptr = 0;
			named.name = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&enumProps->enumItems, named);

            if(pnamed) *pnamed = named = jm_named_alloc_v(bufName,sizeof(fmi_xml_enum_type_item_t)+descrlen+1,sizeof(fmi_xml_enum_type_item_t)+descrlen,context->callbacks);
            item = named.ptr;
            if( !pnamed || !item ) {
                fmi_xml_parse_error(context, "Could not allocate memory");
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

fmi_xml_variable_type_base_t* fmi_get_declared_type(fmi_xml_parser_context_t *context, fmi_xml_elm_enu_t elmID, fmi_xml_variable_type_base_t* defaultType) {
    jm_named_ptr key, *found;
    jm_vector(char)* bufDeclaredType = fmi_xml_reserve_parse_buffer(context,1, 100);
    /*         <xs:attribute name="declaredType" type="xs:normalizedString"> */
    fmi_xml_set_attr_string(context, elmID, fmi_attr_id_declaredType, 0, bufDeclaredType);
    if(! jm_vector_get_size(char)(bufDeclaredType) ) return defaultType;
    key.name = jm_vector_get_itemp(char)(bufDeclaredType,0);
    found = jm_vector_bsearch(jm_named_ptr)(&(context->modelDescription->typeDefinitions.typeDefinitions),&key, jm_compare_named);
    if(!found) {
        fmi_xml_parse_error(context, "Declared type %s not found in type definitions", key.name);
        return 0;
    }
    else  {
        fmi_xml_variable_type_base_t* retType = found->ptr;
        if(retType->baseType != defaultType->baseType) {
            fmi_xml_parse_error(context, "Declared type %s does not match variable type", key.name);
            return 0;
        }
        return retType;
    }
}
