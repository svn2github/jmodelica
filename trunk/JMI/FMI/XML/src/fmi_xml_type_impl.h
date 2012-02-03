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

#ifndef FMI_XML_TYPEIMPL_H
#define FMI_XML_TYPEIMPL_H

#include <jm_named_ptr.h>
#include <jm_string_set.h>
#include "fmi_xml_model_description.h"
#include "fmi_xml_type.h"
#include "fmi_xml_parser.h"

#ifdef __cplusplus
extern "C" {
#endif

/* \defgroup Type definitions supporting structures
  \
*/

typedef enum {
    fmi_xml_type_struct_enu_base,
    fmi_xml_type_struct_enu_typedef,
    fmi_xml_type_struct_enu_props,
    fmi_xml_type_struct_enu_start
} fmi_xml_type_struct_kind_enu_t;

/*
  For each basic type there is exactly one instance of
  TypeContrainsBase with structKind=fmi_xml_type_struct_enu_base.
  Those instances do not have baseType.

  Each type definition creates 1 or 2 instances:
  (1)  instance with structKind=fmi_xml_type_struct_enu_typedef
    that gives the name & description of the type. baseType is a
    pointer to either  fmi_xml_type_struct_enu_base or fmi_xml_type_struct_enu_props
  (2)  optionally, an instance with the structKind=fmi_xml_type_contrain_properties
    providing information on min/max/quantity/etc. baseType is a pointer
    to structKind=fmi_xml_type_struct_enu_base

   Each variable definition may create none, 1 or 2 instances:
    (1) fmi_xml_type_struct_enu_start providing the start value
    (2) structKind=fmi_xml_type_struct_enu_props  providing information on min/max/quantity/etc.
    baseType is a pointer to either fmi_xml_type_struct_enu_base or fmi_xml_type_struct_enu_typedef.
  */

typedef struct fmi_xml_variable_type_base_t fmi_xml_variable_type_base_t;
struct fmi_xml_variable_type_base_t {
    fmi_xml_variable_type_base_t* baseTypeStruct; /* The fmi_xml_variable_type_base structs are put on a list that provide needed info on a variable */

    fmi_xml_variable_type_base_t* next;    /* dynamically allocated fmi_xml_variable_type_base structs are put on a linked list to prevent memory leaks*/

    char structKind; /* one of fmi_xml_type_contrains_kind.*/
    char baseType;   /* one of fmi_xml_base_type */
    char relativeQuantity; /* only used for fmi_xml_type_struct_enu_props (in fmi_xml_real_type_props_t) */
    char isFixed;   /* only used for fmi_xml_type_struct_enu_start*/
};

/* Variable type definition is general and is used for all types*/
struct fmi_xml_variable_typedef_t {
    fmi_xml_variable_type_base_t typeBase;
    jm_string description;
    char typeName[1];
};

typedef struct fmi_xml_real_type_props_t {
    fmi_xml_variable_type_base_t typeBase;
    jm_string quantity;

    fmi_xml_display_unit_t* displayUnit;

    fmiReal typeMin;
    fmiReal typeMax;
    fmiReal typeNominal;
} fmi_xml_real_type_props_t;

typedef struct fmi_xml_integer_type_props_t {
    fmi_xml_variable_type_base_t typeBase;

    jm_string  quantity;

    fmiInteger typeMin;
    fmiInteger typeMax;
} fmi_xml_integer_type_props_t;

typedef fmi_xml_variable_type_base_t fmi_xml_string_type_props_t;
typedef fmi_xml_variable_type_base_t fmi_xml_bool_type_props_t;

typedef struct fmi_xml_enum_type_item_t {
    jm_string itemName;
    char itemDesciption[1];
} fmi_xml_enum_type_item_t;

typedef struct fmi_xml_enum_type_props_t {
    fmi_xml_variable_type_base_t typeBase;

    jm_string quantity;
    fmiInteger typeMin;
    fmiInteger typeMax;
    jm_vector(jm_named_ptr) enumItems;
} fmi_xml_enum_type_props_t;

typedef struct fmi_xml_variable_start_real_t {
    fmi_xml_variable_type_base_t typeBase;
    fmiReal start;
} fmi_xml_variable_start_real_t ;

/* fmi_xml_variable_start_integer is used for boolean and enums as well*/
typedef struct fmi_xml_variable_start_integer_t {
    fmi_xml_variable_type_base_t typeBase;
    fmiInteger start;
} fmi_xml_variable_start_integer_t ;

typedef struct fmi_xml_variable_start_string_t {
    fmi_xml_variable_type_base_t typeBase;
    char start[1];
} fmi_xml_variable_start_string_t;

static fmi_xml_variable_type_base_t* fmi_xml_find_type_struct(fmi_xml_variable_type_base_t* type, fmi_xml_type_struct_kind_enu_t kind) {
    fmi_xml_variable_type_base_t* typeBase = type;
    while(typeBase) {
        if(typeBase->structKind == kind) return typeBase;
        typeBase = typeBase->baseTypeStruct;
    }
    return 0;
}

struct fmi_xml_type_definitions_t {
    jm_vector(jm_named_ptr) typeDefinitions;

    jm_string_set quantities;

    fmi_xml_variable_type_base_t* typePropsList;

    fmi_xml_real_type_props_t defaultRealType;
    fmi_xml_enum_type_props_t defaultEnumType;
    fmi_xml_integer_type_props_t defaultIntegerType;
    fmi_xml_bool_type_props_t defaultBooleanType;
    fmi_xml_string_type_props_t defaultStringType;
};

extern void fmi_xml_init_type_definitions(fmi_xml_type_definitions_t* td, jm_callbacks* cb) ;

extern void fmi_xml_free_type_definitions_data(fmi_xml_type_definitions_t* td);

extern void fmi_xml_init_integer_typedef(fmi_xml_integer_typedef_t* type);

extern void fmi_xml_init_enum_typedef(fmi_xml_enumeration_typedef_t* type, jm_callbacks* cb);

extern void fmi_xml_free_enum_type(jm_named_ptr named);

fmi_xml_variable_type_base_t* fmi_xml_alloc_variable_type_props(fmi_xml_type_definitions_t* td, fmi_xml_variable_type_base_t* base, size_t typeSize);

fmi_xml_variable_type_base_t* fmi_xml_alloc_variable_type_start(fmi_xml_type_definitions_t* td,fmi_xml_variable_type_base_t* base, size_t typeSize);

fmi_xml_real_type_props_t* fmi_xml_parse_real_type_properties(fmi_xml_parser_context_t* context, fmi_xml_elm_enu_t elmID);

fmi_xml_integer_type_props_t *fmi_xml_parse_integer_type_properties(fmi_xml_parser_context_t* context, fmi_xml_elm_enu_t elmID);

extern int fmi_check_last_elem_is_specific_type(fmi_xml_parser_context_t *context);

extern jm_named_ptr fmi_xml_variable_type_alloc(fmi_xml_parser_context_t* context, jm_vector(char)* name, jm_vector(char)* description, size_t size);

extern void* fmi_xml_variable_type_create(fmi_xml_parser_context_t* context, size_t size, jm_vector(jm_named_ptr)* typeList );

extern fmi_xml_real_typedef_t* fmi_xml_variable_type_create_real(fmi_xml_parser_context_t* context, fmi_xml_elm_enu_t elmID, jm_vector(jm_named_ptr)* typeList );

extern fmi_xml_integer_typedef_t* fmi_xml_variable_type_create_integer(fmi_xml_parser_context_t* context, fmi_xml_elm_enu_t elmID, jm_vector(jm_named_ptr)* typeList );

fmi_xml_variable_type_base_t* fmi_get_declared_type(fmi_xml_parser_context_t *context, fmi_xml_elm_enu_t elmID, fmi_xml_variable_type_base_t* defaultType);

#ifdef __cplusplus
}
#endif

#endif /* FMI_XML_TYPEIMPL_H */
