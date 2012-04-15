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
#include <stdio.h>

#include <jm_vector.h>

#include "fmi_xml_parser.h"
#include "fmi_xml_variable_list_impl.h"
#include "fmi_xml_type_impl.h"
#include "fmi_xml_model_description_impl.h"

#include "fmi_xml_variable_impl.h"

const char* fmi_xml_variability_to_string(fmi_xml_variability_enu_t v) {
    switch(v) {
    case fmi_xml_variability_enu_constant: return "constant";
    case fmi_xml_variability_enu_parameter: return "parameter";
    case fmi_xml_variability_enu_discrete: return "discrete";
    case fmi_xml_variability_enu_continuous: return "continuous";
    }
    return "Error";
}

const char* fmi_xml_causality_to_string(fmi_xml_causality_enu_t c) {
    switch(c) {
    case fmi_xml_causality_enu_input: return "input";
    case fmi_xml_causality_enu_output: return "output";
    case fmi_xml_causality_enu_internal: return "internal";
    case fmi_xml_causality_enu_none: return "none";
    };
    return "Error";
}

const char* fmi_xml_get_variable_name(fmi_xml_variable_t* v) {
    return v->name;
}

const char* fmi_xml_get_variable_description(fmi_xml_variable_t* v) {
    return v->description;
}


fmi_xml_value_reference_t fmi_xml_get_variable_vr(fmi_xml_variable_t* v) {
    return v->vr;
}

fmi_xml_variable_alias_kind_enu_t fmi_xml_get_variable_alias_kind(fmi_xml_variable_t* v) {
    return (fmi_xml_variable_alias_kind_enu_t)v->aliasKind;
}

fmi_xml_variable_t* fmi_xml_get_variable_alias_base(fmi_xml_model_description_t* md, fmi_xml_variable_t* v) {
    fmi_xml_variable_t key;
    fmi_xml_variable_t *pkey = &key, *base;
    void ** found;

    if(v->aliasKind == fmi_xml_variable_is_not_alias) return v;
    key = *v;
    key.aliasKind = fmi_xml_variable_is_not_alias;

    found = jm_vector_bsearch(jm_voidp)(&md->variablesByVR->variables,(void**)&pkey, fmi_xml_compare_vr);
    assert(found);
    base = *found;
    return base;
}

/*
    Return the list of all the variables aliased to the given one (including the base one.
    The list is ordered: base variable, aliases, negated aliases.
*/
fmi_xml_variable_list_t* fmi_xml_get_variable_aliases(fmi_xml_model_description_t* md,fmi_xml_variable_t*v) {
    fmi_xml_variable_t key, *cur;
    fmi_xml_variable_list_t* list = fmi_xml_alloc_variable_list(md->callbacks, 0);
    fmi_xml_value_reference_t vr = fmi_xml_get_variable_vr(v);
    size_t baseIndex, i, num = fmi_xml_get_variable_list_size(md->variablesByVR);
    key = *v;
    key.aliasKind = 0;
    cur = &key;
    baseIndex = jm_vector_bsearch_index(jm_voidp)(&md->variablesByVR->variables,(void**)&cur, fmi_xml_compare_vr);
    cur = fmi_xml_get_variable(md->variablesByVR, baseIndex);
    assert(cur);
    i = baseIndex + 1;
    while(fmi_xml_get_variable_vr(cur) == vr) {
        if(!jm_vector_push_back(jm_voidp)(&list->variables, cur)) {
            fmi_xml_report_error(md,"XML_Variable","Could not allocate memory");
            fmi_xml_free_variable_list(list);
            return 0;
        };
        if(i >= num) break;
        cur = fmi_xml_get_variable(md->variablesByVR, i);
        assert(cur);
        i++;
    }
    if(baseIndex) {
        i = baseIndex - 1;
        cur = fmi_xml_get_variable(md->variablesByVR, i);
        while(fmi_xml_get_variable_vr(cur) == vr) {
            if(!jm_vector_push_back(jm_voidp)(&list->variables, cur)) {
                fmi_xml_report_error(md,"XML_Variable","Could not allocate memory");
                fmi_xml_free_variable_list(list);
                return 0;
            };
            i--;
            if(!i) break;
            cur = fmi_xml_get_variable(md->variablesByVR, i - 1);
            assert(cur);
        }
    }
    return list;
}


fmi_xml_variable_typedef_t* fmi_xml_get_variable_declared_type(fmi_xml_variable_t* v) {
    return (fmi_xml_variable_typedef_t*)(fmi_xml_find_type_struct(v->typeBase, fmi_xml_type_struct_enu_typedef));
}

fmi_xml_base_type_enu_t fmi_xml_get_variable_base_type(fmi_xml_variable_t* v) {
    fmi_xml_variable_type_base_t* type = v->typeBase;
    type = fmi_xml_find_type_struct(type, fmi_xml_type_struct_enu_base);
    return (type->baseType);
}

int fmi_xml_get_variable_has_start(fmi_xml_variable_t* v) {
    return (v->typeBase->structKind == fmi_xml_type_struct_enu_start);
}

int   fmi_xml_get_variable_is_fixed(fmi_xml_variable_t* v) {
    fmi_xml_variable_type_base_t* type = v->typeBase;
    return ((type->structKind == fmi_xml_type_struct_enu_start) && (type->isFixed));
}

fmi_xml_variability_enu_t fmi_xml_get_variability(fmi_xml_variable_t* v) {
    return v->variability;
}

fmi_xml_causality_enu_t fmi_xml_get_causality(fmi_xml_variable_t* v) {
    return v->causality;
}

fmi_xml_real_t fmi_xml_get_real_variable_start(fmi_xml_real_variable_t* v) {
    fmi_xml_variable_t* vv = (fmi_xml_variable_t*)v;
    if(fmi_xml_get_variable_has_start(vv)) {
        fmi_xml_variable_start_real_t* start = (fmi_xml_variable_start_real_t*)(vv->typeBase);
        return start->start;
    }
        return fmi_xml_get_real_variable_nominal(v);
}

fmi_xml_unit_t* fmi_xml_get_real_variable_unit(fmi_xml_real_variable_t* v) {
    fmi_xml_variable_t* vv = (fmi_xml_variable_t*)v;
    fmi_xml_real_type_props_t* props = (fmi_xml_real_type_props_t*)(fmi_xml_find_type_struct(vv->typeBase, fmi_xml_type_struct_enu_props));
    if(!props || !props->displayUnit) return 0;
    return props->displayUnit->baseUnit;
}

fmi_xml_display_unit_t* fmi_xml_get_real_variable_display_unit(fmi_xml_real_variable_t* v) {
    fmi_xml_variable_t* vv = (fmi_xml_variable_t*)v;
    fmi_xml_real_type_props_t* props = (fmi_xml_real_type_props_t*)(fmi_xml_find_type_struct(vv->typeBase, fmi_xml_type_struct_enu_props));
    if(!props || !props->displayUnit || !props->displayUnit->displayUnit[0]) return 0;
    return props->displayUnit;
}


fmi_xml_int_t fmi_xml_get_integer_variable_start(fmi_xml_integer_variable_t* v){
    fmi_xml_variable_t* vv = (fmi_xml_variable_t*)v;
    if(fmi_xml_get_variable_has_start(vv)) {
        fmi_xml_variable_start_integer_t* start = (fmi_xml_variable_start_integer_t*)(vv->typeBase);
        return start->start;
    }
        return 0;
}

const char* fmi_xml_get_string_variable_start(fmi_xml_string_variable_t* v){
    fmi_xml_variable_t* vv = (fmi_xml_variable_t*)v;
    if(fmi_xml_get_variable_has_start(vv)) {
        fmi_xml_variable_start_string_t* start = (fmi_xml_variable_start_string_t*)(vv->typeBase);
        return start->start;
    }
    return 0;
}

fmi_xml_int_t fmi_xml_get_enum_variable_start(fmi_xml_enum_variable_t* v) {
    fmi_xml_variable_t* vv = (fmi_xml_variable_t*)v;
    if(fmi_xml_get_variable_has_start(vv)) {
        fmi_xml_variable_start_integer_t* start = (fmi_xml_variable_start_integer_t*)(vv->typeBase);
        return start->start;
    }
        return 0;
}

fmiBoolean fmi_xml_get_boolean_variable_start(fmi_xml_bool_variable_t* v) {
    fmi_xml_variable_t* vv = (fmi_xml_variable_t*)v;
    if(fmi_xml_get_variable_has_start(vv)) {
        fmi_xml_variable_start_integer_t* start = (fmi_xml_variable_start_integer_t*)(vv->typeBase);
        return start->start;
    }
        return 0;
}

fmi_xml_real_t fmi_xml_get_real_variable_nominal(fmi_xml_real_variable_t* v) {
    fmi_xml_variable_t* vv = (fmi_xml_variable_t*)v;
    fmi_xml_real_type_props_t* props = (fmi_xml_real_type_props_t*)fmi_xml_find_type_struct(vv->typeBase,fmi_xml_type_struct_enu_props);
    return props->typeNominal;
}

/* DirectDependency is returned for variables with causality Output. Null pointer for others. */
fmi_xml_variable_list_t* fmi_xml_get_direct_dependency(fmi_xml_variable_t* v) {
    fmi_xml_variable_list_t* vl = 0;
    if(!v->directDependency) return 0;
    vl = fmi_xml_alloc_variable_list(v->directDependency->callbacks, jm_vector_get_size(jm_voidp)(v->directDependency));
    if(!vl) return 0;
    jm_vector_copy(jm_voidp)(&vl->variables,v->directDependency);
    return vl;
}

fmi_xml_real_variable_t* fmi_xml_get_variable_as_real(fmi_xml_variable_t* v) {
    if(fmi_xml_get_variable_base_type(v) == fmi_xml_base_type_enu_real)  return (void*)v;
    return 0;
}

fmi_xml_integer_variable_t* fmi_xml_get_variable_as_integer(fmi_xml_variable_t*v){
    if(fmi_xml_get_variable_base_type(v) == fmi_xml_base_type_enu_int)  return (void*)v;
    return 0;
}
fmi_xml_enum_variable_t* fmI_xml_get_variable_as_enum(fmi_xml_variable_t* v){
    if(fmi_xml_get_variable_base_type(v) == fmi_xml_base_type_enu_enum)  return (void*)v;
    return 0;
}
fmi_xml_string_variable_t* fmi_xml_get_variable_as_string(fmi_xml_variable_t* v){
    if(fmi_xml_get_variable_base_type(v) == fmi_xml_base_type_enu_str)  return (void*)v;
    return 0;
}
fmi_xml_bool_variable_t* fmi_xml_get_variable_as_boolean(fmi_xml_variable_t* v){
    if(fmi_xml_get_variable_base_type(v) == fmi_xml_base_type_enu_bool)  return (void*)v;
    return 0;
}

void fmi_xml_free_direct_dependencies(jm_named_ptr named) {
        fmi_xml_variable_t* v = named.ptr;
        if(v->directDependency) {
                jm_vector_free(jm_voidp)(v->directDependency);
                v->directDependency = 0;
        }
}

int fmi_xml_handle_ScalarVariable(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_ModelVariables) {
            fmi_xml_parse_error(context, "ScalarVariable XML element must be a part of ModelVariables");
            return -1;
        }
        {            
            fmi_xml_model_description_t* md = context->modelDescription;
            fmi_xml_variable_t* variable;
            fmi_xml_variable_t dummyV;
            const char* description = 0;
            jm_named_ptr named, *pnamed;
            jm_vector(char)* bufName = fmi_xml_reserve_parse_buffer(context,1,100);
            jm_vector(char)* bufDescr = fmi_xml_reserve_parse_buffer(context,2,100);
            unsigned int vr;

            if(!bufName || !bufDescr) return -1;

            /*   <xs:attribute name="valueReference" type="xs:unsignedInt" use="required"> */
            if(fmi_xml_set_attr_uint(context, fmi_xml_elmID_ScalarVariable, fmi_attr_id_valueReference, 1, &vr, 0)) return -1;

            if(vr == fmi_xml_value_reference_enu_undefined) {
                context->skipOneVariableFlag = 1;
            }

            if(
            /*  <xs:attribute name="name" type="xs:normalizedString" use="required"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_ScalarVariable, fmi_attr_id_name, 1, bufName) ||
            /* <xs:attribute name="description" type="xs:string"/> */
                fmi_xml_set_attr_string(context, fmi_xml_elmID_ScalarVariable, fmi_attr_id_description, 0, bufDescr)
            ) return -1;

            if(context->skipOneVariableFlag) {
                fmi_xml_parse_warning(context, "Ignoring variable with undefined vr '%s'", jm_vector_get_itemp(char)(bufName,0));
                return 0;
            }
            if(jm_vector_get_size(char)(bufDescr)) {
                description = jm_string_set_put(&md->descriptions, jm_vector_get_itemp(char)(bufDescr,0));
            }

            named.ptr = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&md->variables, named);

            if(pnamed) *pnamed = named = jm_named_alloc_v(bufName,sizeof(fmi_xml_variable_t), dummyV.name - (char*)&dummyV, context->callbacks);
            variable = named.ptr;
            if( !pnamed || !variable ) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            variable->vr = vr;
            variable->description = description;
            variable->typeBase = 0;
            variable->directDependency = 0;

              {
                jm_name_ID_map_t variabilityConventionMap[] = {{"continuous",fmi_xml_variability_enu_continuous},
                                                               {"constant", fmi_xml_variability_enu_constant},
                                                               {"parameter", fmi_xml_variability_enu_parameter},
                                                               {"discrete", fmi_xml_variability_enu_discrete},{0,0}};
                unsigned int variability;
                /*  <xs:attribute name="variability" default="continuous"> */
                if(fmi_xml_set_attr_enum(context, fmi_xml_elmID_ScalarVariable, fmi_attr_id_variability,0,&variability,fmi_xml_variability_enu_continuous,variabilityConventionMap))
                    return -1;
                variable->variability = variability;
            }
            {
                jm_name_ID_map_t causalityConventionMap[] = {{"internal",fmi_xml_causality_enu_internal},
                                                             {"input",fmi_xml_causality_enu_input},
                                                             {"output",fmi_xml_causality_enu_output},
                                                             {"none",fmi_xml_causality_enu_none},{0,0}};
                /* <xs:attribute name="causality" default="internal"> */
                unsigned int causality;
                if(fmi_xml_set_attr_enum(context, fmi_xml_elmID_ScalarVariable, fmi_attr_id_causality,0,&causality,fmi_xml_causality_enu_internal,causalityConventionMap))
                    return -1;
                variable->causality = causality;
            }
            {
                jm_name_ID_map_t aliasConventionMap[] = {{"alias", 1},
                                                         {"negatedAlias", 2},
                                                         {"noAlias", 0}, {0,0}};
                unsigned int alias;
                /* <xs:attribute name="alias" default="noAlias"> */
                if(fmi_xml_set_attr_enum(context, fmi_xml_elmID_ScalarVariable, fmi_attr_id_alias ,0,&alias,0,aliasConventionMap))
                    return -1;
                if(alias == 0) variable->aliasKind = fmi_xml_variable_is_not_alias;
                else if (alias == 1) variable->aliasKind = fmi_xml_variable_is_alias;
                else if (alias == 2) variable->aliasKind = fmi_xml_variable_is_negated_alias;
                else assert(0);
            }
        }
    }
    else {
        if(context->skipOneVariableFlag) {
            context->skipOneVariableFlag = 0;
        }
        else {
            /* check that the type for the variable is set */
            fmi_xml_model_description_t* md = context->modelDescription;
            fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
            if(!variable->typeBase) {
                fmi_xml_parse_error(context, "No variable type element for variable %s", variable->name);
                return -1;
            }
        }
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}


int fmi_xml_handle_DirectDependency(fmi_xml_parser_context_t *context, const char* data) {
    if(context->skipOneVariableFlag) return 0;
    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        if(context -> currentElmHandle != fmi_xml_handle_ScalarVariable) {
            fmi_xml_parse_error(context, "DirectDependency XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->causality != fmi_xml_causality_enu_output) {
            fmi_xml_parse_error(context, "DirectDependency XML element cannot be defined for '%s' since causality is not output", variable->name);
            return -1;
        }
    }
    else {
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        if(jm_vector_get_size(jm_voidp)(&context->directDependencyBuf)) {
            variable->directDependency = jm_vector_clone(jm_voidp)(&context->directDependencyBuf);
            if(!variable->directDependency) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
        }
        jm_vector_resize(jm_voidp)(&context->directDependencyBuf,0);
    }
    return 0;
}

int fmi_xml_handle_Name(fmi_xml_parser_context_t *context, const char* data) {
    if(context->skipOneVariableFlag) return 0;

    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_DirectDependency) {
            fmi_xml_parse_error(context, "Name XML element must be a part of DirectDependency");
            return -1;
        }
    }
    else {
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        size_t namelen = strlen(data);
        char* name = 0;
        jm_voidp* itemp;
        jm_string* namep;
        if(namelen == 0) {
            fmi_xml_parse_error(context, "Unexpected empty Name element for DirectDependency of variable %s", variable->name);
            return -1;
        }
        namep = jm_vector_push_back(jm_string)(&context->directDependencyStringsStore, name);
        if(namep) *namep = name  = context->callbacks->malloc(namelen + 1);
        itemp = jm_vector_push_back(jm_voidp)(&context->directDependencyBuf, name);
        if(!namep || !itemp || !name)  {
            fmi_xml_parse_error(context, "Could not allocate memory");
            return -1;
        }
        memcpy(name, data, namelen);
        name[namelen] = 0;
    }
    return 0;
}

int fmi_xml_handle_Real(fmi_xml_parser_context_t *context, const char* data) {
    if(context->skipOneVariableFlag) return 0;

    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        fmi_xml_type_definitions_t* td = &md->typeDefinitions;
        fmi_xml_variable_type_base_t * declaredType = 0;
        fmi_xml_real_type_props_t * type = 0;
        int hasStart;

        if(context -> currentElmHandle != fmi_xml_handle_ScalarVariable) {
            fmi_xml_parse_error(context, "Real XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmi_xml_parse_error(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        declaredType = fmi_get_declared_type(context, fmi_xml_elmID_Real, &td->defaultRealType.typeBase);

        if(!declaredType) return -1;

        {
            int hasUnit = fmi_xml_is_attr_defined(context, fmi_attr_id_unit) ||
                    fmi_xml_is_attr_defined(context, fmi_attr_id_displayUnit);
            int hasMin =  fmi_xml_is_attr_defined(context, fmi_attr_id_min);
            int hasMax = fmi_xml_is_attr_defined(context, fmi_attr_id_max);
            int hasNom = fmi_xml_is_attr_defined(context, fmi_attr_id_nominal);
            int hasQuan = fmi_xml_is_attr_defined(context, fmi_attr_id_quantity);
            int hasRelQ = fmi_xml_is_attr_defined(context, fmi_attr_id_relativeQuantity);


            if(hasUnit || hasMin || hasMax || hasNom || hasQuan || hasRelQ) {
                fmi_xml_real_type_props_t* props = 0;

                if(declaredType->structKind == fmi_xml_type_struct_enu_typedef)
                    props = (fmi_xml_real_type_props_t*)(declaredType->baseTypeStruct);
                else
                    props = (fmi_xml_real_type_props_t* )declaredType;

                fmi_xml_reserve_parse_buffer(context, 1, 0);
                fmi_xml_reserve_parse_buffer(context, 2, 0);

                type = fmi_xml_parse_real_type_properties(context, fmi_xml_elmID_Real);

                if(!type) return -1;
                type->typeBase.baseTypeStruct = declaredType;
                if( !hasUnit) type->displayUnit = props->displayUnit;
                if( !hasMin)  type->typeMin = props->typeMin;
                if( !hasMax) type->typeMax = props->typeMax;
                if( !hasNom) type->typeNominal = props->typeNominal;
                if( !hasQuan) type->quantity = props->quantity;
                if( !hasRelQ) type->typeBase.relativeQuantity = props->typeBase.relativeQuantity;
            }
            else
                type = (fmi_xml_real_type_props_t*)declaredType;
        }
        variable->typeBase = &type->typeBase;

        hasStart = fmi_xml_is_attr_defined(context, fmi_attr_id_start);
        if(hasStart) {
            fmi_xml_variable_start_real_t * start = (fmi_xml_variable_start_real_t*)fmi_xml_alloc_variable_type_start(td, &type->typeBase, sizeof(fmi_xml_variable_start_real_t));
            int isFixedBuf;
            if(!start) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            if(
                /*  <xs:attribute name="start" type="xs:double"/> */
                    fmi_xml_set_attr_double(context, fmi_xml_elmID_Real, fmi_attr_id_start, 0, &start->start, 0) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmi_xml_set_attr_boolean(context, fmi_xml_elmID_Real, fmi_attr_id_fixed, 0, &(isFixedBuf), 1)
                )
                    return -1;
            start->typeBase.isFixed = isFixedBuf;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmi_xml_is_attr_defined(context,fmi_attr_id_fixed)) {
                fmi_xml_parse_error(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_xml_handle_Integer(fmi_xml_parser_context_t *context, const char* data) {
    if(context->skipOneVariableFlag) return 0;

    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_type_definitions_t* td = &md->typeDefinitions;
        fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        fmi_xml_variable_type_base_t * declaredType = 0;
        fmi_xml_integer_type_props_t * type = 0;
        int hasStart;

        if(context -> currentElmHandle != fmi_xml_handle_ScalarVariable) {
            fmi_xml_parse_error(context, "Integer XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmi_xml_parse_error(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        declaredType = fmi_get_declared_type(context, fmi_xml_elmID_Integer,&td->defaultIntegerType.typeBase) ;

        if(!declaredType) return -1;

        if(
                fmi_xml_is_attr_defined(context,fmi_attr_id_min) ||
                fmi_xml_is_attr_defined(context,fmi_attr_id_max) ||
                fmi_xml_is_attr_defined(context,fmi_attr_id_quantity)
                ) {
            fmi_xml_integer_type_props_t* props = 0;

            if(declaredType->structKind != fmi_xml_type_struct_enu_typedef)
                props = (fmi_xml_integer_type_props_t*)declaredType;
            else
                props = (fmi_xml_integer_type_props_t*)(declaredType->baseTypeStruct);
            assert((props->typeBase.structKind == fmi_xml_type_struct_enu_props) || (props->typeBase.structKind == fmi_xml_type_struct_enu_base));
            fmi_xml_reserve_parse_buffer(context, 1, 0);
            fmi_xml_reserve_parse_buffer(context, 2, 0);
            type = fmi_xml_parse_integer_type_properties(context, fmi_xml_elmID_Integer);
            if(!type) return -1;
            type->typeBase.baseTypeStruct = declaredType;
            if(!fmi_xml_is_attr_defined(context,fmi_attr_id_min)) type->typeMin = props->typeMin;
            if(!fmi_xml_is_attr_defined(context,fmi_attr_id_max)) type->typeMax = props->typeMax;
            if(!fmi_xml_is_attr_defined(context,fmi_attr_id_quantity)) type->quantity = props->quantity;
        }
        else
            type = (fmi_xml_integer_type_props_t*)declaredType;

        variable->typeBase = &type->typeBase;

        hasStart = fmi_xml_is_attr_defined(context,fmi_attr_id_start);
        if(hasStart) {
            fmi_xml_variable_start_integer_t * start = (fmi_xml_variable_start_integer_t*)fmi_xml_alloc_variable_type_start(td, &type->typeBase, sizeof(fmi_xml_variable_start_integer_t));
            int isFixedBuf;
            if(!start) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            if(
                /*  <xs:attribute name="start" type="xs:integer"/> */
                    fmi_xml_set_attr_int(context, fmi_xml_elmID_Integer, fmi_attr_id_start, 0, &start->start, 0) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmi_xml_set_attr_boolean(context, fmi_xml_elmID_Integer, fmi_attr_id_fixed, 0, &isFixedBuf, 1)
                )
                    return -1;
            start->typeBase.isFixed = isFixedBuf;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmi_xml_is_attr_defined(context,fmi_attr_id_fixed)) {
                fmi_xml_parse_error(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_xml_handle_Boolean(fmi_xml_parser_context_t *context, const char* data) {
    if(context->skipOneVariableFlag) return 0;

    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_type_definitions_t* td = &md->typeDefinitions;
        fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        int hasStart;

        if(context -> currentElmHandle != fmi_xml_handle_ScalarVariable) {
            fmi_xml_parse_error(context, "Boolean XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmi_xml_parse_error(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        variable->typeBase = fmi_get_declared_type(context, fmi_xml_elmID_Boolean, &td->defaultBooleanType) ;

        if(!variable->typeBase) return -1;

        hasStart = fmi_xml_is_attr_defined(context,fmi_attr_id_start);
        if(hasStart) {
            int isFixedBuf;
            fmi_xml_variable_start_integer_t * start = (fmi_xml_variable_start_integer_t*)fmi_xml_alloc_variable_type_start(td, variable->typeBase, sizeof(fmi_xml_variable_start_integer_t ));
            if(!start) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            if(
                  /*  <xs:attribute name="start" type="xs:boolean"/> */
                    fmi_xml_set_attr_boolean(context, fmi_xml_elmID_Boolean, fmi_attr_id_start, 0, (int*)&start->start, 0) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmi_xml_set_attr_boolean(context, fmi_xml_elmID_Boolean, fmi_attr_id_fixed, 0, &isFixedBuf, 1)
                )
                    return -1;
            start->typeBase.isFixed = isFixedBuf;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmi_xml_is_attr_defined(context,fmi_attr_id_fixed)) {
                fmi_xml_parse_error(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }            
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_xml_handle_String(fmi_xml_parser_context_t *context, const char* data) {
    if(context->skipOneVariableFlag) return 0;

    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_type_definitions_t* td = &md->typeDefinitions;
        fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        int hasStart;

        if(context -> currentElmHandle != fmi_xml_handle_ScalarVariable) {
            fmi_xml_parse_error(context, "String XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmi_xml_parse_error(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        variable->typeBase = fmi_get_declared_type(context, fmi_xml_elmID_String,&td->defaultStringType) ;

        if(!variable->typeBase) return -1;

        hasStart = fmi_xml_is_attr_defined(context,fmi_attr_id_start);
        if(hasStart) {
            jm_vector(char)* bufStartStr = fmi_xml_reserve_parse_buffer(context,1, 100);
            size_t strlen;
            int isFixed;
            fmi_xml_variable_start_string_t * start;
            if(
                 /*   <xs:attribute name="start" type="xs:string"/> */
                    fmi_xml_set_attr_string(context, fmi_xml_elmID_String, fmi_attr_id_start, 0, bufStartStr) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmi_xml_set_attr_boolean(context, fmi_xml_elmID_Boolean, fmi_attr_id_fixed, 0, &isFixed, 1)
                )
                    return -1;
            strlen = jm_vector_get_size_char(bufStartStr);

            start = (fmi_xml_variable_start_string_t*)fmi_xml_alloc_variable_type_start(td, variable->typeBase, sizeof(fmi_xml_variable_start_string_t) + strlen);

            if(!start) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            memcpy(start->start, jm_vector_get_itemp_char(bufStartStr,0), strlen);
            start->start[strlen] = 0;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmi_xml_is_attr_defined(context,fmi_attr_id_fixed)) {
                fmi_xml_parse_error(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmi_xml_handle_Enumeration(fmi_xml_parser_context_t *context, const char* data) {
    if(context->skipOneVariableFlag) return 0;

    if(!data) {
        fmi_xml_model_description_t* md = context->modelDescription;
        fmi_xml_type_definitions_t* td = &md->typeDefinitions;
        fmi_xml_variable_t* variable = jm_vector_get_last(jm_named_ptr)(&md->variables).ptr;
        fmi_xml_variable_type_base_t * declaredType = 0;
        fmi_xml_integer_type_props_t * type = 0;
        int hasStart;

        if(context -> currentElmHandle != fmi_xml_handle_ScalarVariable) {
            fmi_xml_parse_error(context, "Integer XML element must be a part of ScalarVariable");
            return -1;
        }
        if(variable->typeBase) {
            fmi_xml_parse_error(context, "Several types are defined for variable %s", variable->name);
            return -1;
        }

        declaredType = fmi_get_declared_type(context, fmi_xml_elmID_Enumeration,&td->defaultEnumType.typeBase);

        if(!declaredType) return -1;

        if(
                fmi_xml_is_attr_defined(context,fmi_attr_id_min) ||
                fmi_xml_is_attr_defined(context,fmi_attr_id_max) ||
                fmi_xml_is_attr_defined(context,fmi_attr_id_quantity)
                ) {
            fmi_xml_integer_type_props_t* props = 0;

            if(declaredType->structKind != fmi_xml_type_struct_enu_typedef)
                props = (fmi_xml_integer_type_props_t*)declaredType;
            else
                props = (fmi_xml_integer_type_props_t*)declaredType->baseTypeStruct;
            assert(props->typeBase.structKind == fmi_xml_type_struct_enu_props);
            fmi_xml_reserve_parse_buffer(context, 1, 0);
            fmi_xml_reserve_parse_buffer(context, 2, 0);
            type = fmi_xml_parse_integer_type_properties(context, fmi_xml_elmID_Enumeration);
            if(!type) return -1;
            type->typeBase.baseTypeStruct = declaredType;
            if(!fmi_xml_is_attr_defined(context,fmi_attr_id_min)) type->typeMin = props->typeMin;
            if(!fmi_xml_is_attr_defined(context,fmi_attr_id_max)) type->typeMax = props->typeMax;
            if(!fmi_xml_is_attr_defined(context,fmi_attr_id_quantity)) type->quantity = props->quantity;
        }
        else
            type = (fmi_xml_integer_type_props_t*)declaredType;

        variable->typeBase = &type->typeBase;

        hasStart = fmi_xml_is_attr_defined(context,fmi_attr_id_start);
        if(hasStart) {
            fmi_xml_variable_start_integer_t * start = (fmi_xml_variable_start_integer_t*)fmi_xml_alloc_variable_type_start(td, &type->typeBase, sizeof(fmi_xml_variable_start_integer_t ));
            int isFixedBuf;
            if(!start) {
                fmi_xml_parse_error(context, "Could not allocate memory");
                return -1;
            }
            if(
                /*  <xs:attribute name="start" type="xs:integer"/> */
                    fmi_xml_set_attr_int(context, fmi_xml_elmID_Enumeration, fmi_attr_id_start, 0, &start->start, 0) ||
                /*  <xs:attribute name="fixed" type="xs:boolean"> */
                    fmi_xml_set_attr_boolean(context, fmi_xml_elmID_Enumeration, fmi_attr_id_fixed, 0, &isFixedBuf, 1)
                )
                    return -1;
            start->typeBase.isFixed = isFixedBuf;
            variable->typeBase = &start->typeBase;
        }
        else {
            if(fmi_xml_is_attr_defined(context,fmi_attr_id_fixed)) {
                fmi_xml_parse_error(context, "When parsing variable %s: 'fixed' attributed is only allowed when start is defined", variable->name);
            }            
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

void fmi_xml_eliminate_bad_alias(fmi_xml_parser_context_t *context, size_t indexVR) {
    fmi_xml_model_description_t* md = context->modelDescription;
    jm_vector(jm_voidp)* varByVR = &md->variablesByVR->variables;
    fmi_xml_variable_t* v = (fmi_xml_variable_t*)jm_vector_get_item(jm_voidp)(varByVR, indexVR);
    fmi_xml_value_reference_t vr = v->vr;
    fmi_xml_base_type_enu_t vt = fmi_xml_get_variable_base_type(v);
    size_t i, n = jm_vector_get_size(jm_voidp)(varByVR);
    for(i = 0; i< n; i++) {
        jm_named_ptr key;
        size_t index;
        v = (fmi_xml_variable_t*)jm_vector_get_item(jm_voidp)(varByVR, i);
        if((v->vr != vr)||(vt != fmi_xml_get_variable_base_type(v))) continue;
        jm_vector_remove_item_jm_voidp(varByVR,i);
        n--; i--;
        key.name = v->name;
        index = jm_vector_bsearch_index(jm_named_ptr)(&md->variables, &key, jm_compare_named);
        assert(index <= n);
        jm_vector_remove_item(jm_named_ptr)(&md->variables,index);
        fmi_xml_parse_warning(context,"Removing incorrect alias variable '%s'", v->name);
        md->callbacks->free(v);
    }
}

int fmi_xml_handle_ModelVariables(fmi_xml_parser_context_t *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmi_xml_handle_fmiModelDescription) {
            fmi_xml_parse_error(context, "ModelVariables XML element must be a part of fmiModelDescription");
            return -1;
        }
    }
    else {
         /* postprocess variable list */

        fmi_xml_model_description_t* md = context->modelDescription;
        jm_vector(jm_voidp)* varByVR;
        size_t i, numvar;

        numvar = jm_vector_get_size(jm_named_ptr)(&md->variables);
        /* vars with  vr = fmiUndefinedValueReference were alreade skipped. Just sanity: */
        /* remove any variable with vr = fmiUndefinedValueReference */
        for(i = 0; i< numvar; i++) {
            jm_named_ptr named = jm_vector_get_item(jm_named_ptr)(&md->variables, i);
            fmi_xml_variable_t* v = named.ptr;
            if(v->vr == fmi_xml_value_reference_enu_undefined) {
                jm_vector_remove_item(jm_named_ptr)(&md->variables,i);
                numvar--; i--;
                fmi_xml_free_direct_dependencies(named);
                md->callbacks->free(v);
                assert(0);
            }
        }

        /* sort the variables by names */
        jm_vector_qsort(jm_named_ptr)(&md->variables,jm_compare_named);

        /* create VR index */
        md->status = fmi_xml_model_description_enu_ok;
        md->variablesByVR = fmi_xml_get_variable_list(md);
        md->status = fmi_xml_model_description_enu_empty;
        if(!md->variablesByVR) {
            fmi_xml_parse_error(context, "Could not allocate memory");
            return -1;
        }
        varByVR = &md->variablesByVR->variables;
        jm_vector_qsort(jm_voidp)(varByVR, fmi_xml_compare_vr);

        {
            int foundBadAlias;

            do {
                fmi_xml_variable_t* a = (fmi_xml_variable_t*)jm_vector_get_item(jm_voidp)(varByVR, 0);
                foundBadAlias = 0;

                if(a->aliasKind == fmi_xml_variable_is_alias) {
                    fmi_xml_parse_warning(context,"All variables with vr %d (base type %s) are marked as aliases.",
                                          a->vr, fmi_xml_base_type2string(fmi_xml_get_variable_base_type(a)));
                    fmi_xml_eliminate_bad_alias(context,0);
                    foundBadAlias = 1;
                    continue;
                }
                numvar = jm_vector_get_size(jm_voidp)(varByVR);

                for(i = 1; i< numvar; i++) {
                    fmi_xml_variable_t* b = (fmi_xml_variable_t*)jm_vector_get_item(jm_voidp)(varByVR, i);
                    if((fmi_xml_get_variable_base_type(a)!=fmi_xml_get_variable_base_type(b))
                            || (a->vr != b->vr)) {
                        /* a different vr */
                        if(a->aliasKind == fmi_xml_variable_is_negated_alias) {
                            fmi_xml_parse_warning(context,"All variables with vr %u (base type %s) are marked as negated aliases",
                                                  a->vr, fmi_xml_base_type2string(fmi_xml_get_variable_base_type(a)));
                            fmi_xml_eliminate_bad_alias(context,i-1);
                            foundBadAlias = 1;
                            break;
                        }
                        if(b->aliasKind == fmi_xml_variable_is_alias) {
                            fmi_xml_parse_warning(context,"All variables with vr %u (base type %s) are marked as aliases",
                                                b->vr, fmi_xml_base_type2string(fmi_xml_get_variable_base_type(b)));
                          fmi_xml_eliminate_bad_alias(context,i);
                          foundBadAlias = 1;
                          break;
                        }
                    }
                    else {
                        if(   (a->aliasKind == fmi_xml_variable_is_negated_alias)
                                && (b->aliasKind == fmi_xml_variable_is_alias)) {
                            fmi_xml_parse_error(context,"All variables with vr %u (base type %s) are marked as aliases",
                                                b->vr, fmi_xml_base_type2string(fmi_xml_get_variable_base_type(b)));
                          fmi_xml_eliminate_bad_alias(context,i);
                          foundBadAlias = 1;
                          break;
                        }
                        if((a->aliasKind == fmi_xml_variable_is_not_alias) && (a->aliasKind == b->aliasKind)) {
                            fmi_xml_variable_t* c;
                            size_t j = i+1;
                            fmi_xml_parse_warning(context,"Variables %s and %s reference the same vr %u. Marking '%s' as alias.",
                                                a->name, b->name, b->vr, b->name);
                            b->aliasKind = fmi_xml_variable_is_alias;

                            while(j < numvar) {
                                c = (fmi_xml_variable_t*)jm_vector_get_item(jm_voidp)(varByVR, j);
                                if(fmi_xml_compare_vr(&b,&c) <= 0) break;
                                j++;
                            }
                            j--;
                            if(i != j) {
                                c = (fmi_xml_variable_t*)jm_vector_get_item(jm_voidp)(varByVR, j);
                                jm_vector_set_item(jm_voidp)(varByVR, j, b);
                                jm_vector_set_item(jm_voidp)(varByVR, i, c);
                            }
                            /* jm_vector_qsort(jm_voidp)(varByVR, fmi_xml_compare_vr); */
                            foundBadAlias = 1;
                            i--;
                            continue;
                        }
                    }
                    a = b;
                }
            } while(foundBadAlias);
        }

        numvar = jm_vector_get_size(jm_named_ptr)(&md->variables);
        /* postprocess direct dependencies */
        for(i = 0; i< numvar; i++) {
            size_t numdep, j, var_i = 0;
            jm_vector(jm_voidp)* dep;
            fmi_xml_variable_t* variable = jm_vector_get_item(jm_named_ptr)(&md->variables, i).ptr;

            if(!variable->directDependency) continue;
            dep = variable->directDependency;
            numdep = jm_vector_get_size(jm_voidp)(dep);
            for(j = 0; j < numdep; j++) {
                jm_string name = jm_vector_get_item(jm_voidp)(dep, j);
                jm_named_ptr key;
                fmi_xml_variable_t* depvar;
                key.name = name;
                depvar = jm_vector_bsearch(jm_named_ptr)(&md->variables, &key, jm_compare_named)->ptr;
                if(!depvar) {
                    fmi_xml_parse_warning(context, "Could not find variable %s mentioned in dependecies of %s. Ignoring", name, variable->name);
                    continue;
                }
                if(depvar->causality != fmi_xml_causality_enu_input) {
                    fmi_xml_parse_warning(context, "Only input variables are allowed in DirectDependecies, but %s is not input. Ignoring", name);
                    continue;
                }
                jm_vector_set_item(jm_voidp)(dep,var_i++, depvar);
            }
            jm_vector_resize(jm_voidp)(dep,var_i);
        }
        jm_vector_foreach(jm_string)(&context->directDependencyStringsStore, (void(*)(jm_string))context->callbacks->free);
        jm_vector_free_data(jm_string)(&context->directDependencyStringsStore);

        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}
