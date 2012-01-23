#ifndef FMITYPEIMPL_H
#define FMITYPEIMPL_H

#include <jm_named_ptr.h>
#include <jm_string_set.h>
#include "fmiModelDescription.h"
#include "fmiType.h"
#include "fmiXMLParser.h"

/* Type definitions supporting structures*/

typedef enum {
    fmiTypeStructBase,
    fmiTypeStructDefinition,
    fmiTypeStructProperties,
    fmiTypeStructStart
} fmiTypeStructKind;

/*
  For each basic type there is exactly one instance of
  TypeContrainsBase with structKind=fmiTypeStructBase.
  Those instances do not have baseType.

  Each type definition creates 1 or 2 instances:
  (1)  instance with structKind=fmiTypeStructDefinition
    that gives the name & description of the type. baseType is a
    pointer to either  fmiTypeStructBase or fmiTypeStructProperties
  (2)  optionally, an instance with the structKind=fmiTypeContrainProperties
    providing information on min/max/quantity/etc. baseType is a pointer
    to structKind=fmiTypeStructBase

   Each variable definition may create none, 1 or 2 instances:
    (1) fmiTypeStructStart providing the start value
    (2) structKind=fmiTypeStructProperties  providing information on min/max/quantity/etc.
    baseType is a pointer to either fmiTypeStructBase or fmiTypeStructDefinition.
  */

typedef struct fmiVariableTypeBase fmiVariableTypeBase;
struct fmiVariableTypeBase {
    fmiVariableTypeBase* baseTypeStruct; /* The fmiVariableTypeBase structs are put on a list that provide needed info on a variable */

    fmiVariableTypeBase* next;    /* dynamically allocated fmiVariableTypeBase structs are put on a linked list to prevent memory leaks*/

    char structKind; /* one of fmiTypeContrainsKind.*/
    char baseType;   /* one of fmiBaseType */
    char relativeQuantity; /* only used for fmiTypeStructProperties (in fmiRealTypeProperties) */
    char isFixed;   /* only used for fmiTypeStructStart*/
};

/* Variable type definition is general and is used for all types*/
struct fmiVariableType {
    fmiVariableTypeBase typeBase;
    jm_string description;
    char typeName[1];
};

typedef struct fmiRealTypeProperties {
    fmiVariableTypeBase typeBase;
    jm_string quantity;

    fmiDisplayUnit* displayUnit;

    fmiReal typeMin;
    fmiReal typeMax;
    fmiReal typeNominal;
} fmiRealTypeProperties;

typedef struct fmiIntegerTypeProperties {
    fmiVariableTypeBase typeBase;

    jm_string  quantity;

    fmiInteger typeMin;
    fmiInteger typeMax;
} fmiIntegerTypeProperties;

typedef fmiVariableTypeBase fmiStringTypeProperties;
typedef fmiVariableTypeBase fmiBooleanTypeProperties;

typedef struct fmiEnumerationTypeItem {
    jm_string itemName;
    char itemDesciption[1];
} fmiEnumerationTypeItem;

typedef struct fmiEnumerationTypeProperties {
    fmiVariableTypeBase typeBase;

    jm_string quantity;
    fmiInteger typeMin;
    fmiInteger typeMax;
    jm_vector(jm_named_ptr) enumItems;
} fmiEnumerationTypeProperties;

typedef struct fmiVariableStartReal {
    fmiVariableTypeBase typeBase;
    fmiReal start;
} fmiVariableStartReal ;

/* fmiVariableStartInteger is used for boolean ans enums as well*/
typedef struct fmiVariableStartInteger {
    fmiVariableTypeBase typeBase;
    fmiInteger start;
} fmiVariableStartInteger ;

typedef struct fmiVariableStartString {
    fmiVariableTypeBase typeBase;
    char start[1];
} fmiVariableStartString;

static fmiVariableTypeBase* fmiFindTypeStruct(fmiVariableTypeBase* type, fmiTypeStructKind kind) {
    fmiVariableTypeBase* typeBase = type;
    while(typeBase) {
        if(typeBase->structKind == kind) return typeBase;
        typeBase = typeBase->baseTypeStruct;
    }
    return 0;
}

struct fmiTypeDefinitions {
    jm_vector(jm_named_ptr) typeDefinitions;

    jm_string_set quantities;

    fmiVariableTypeBase* typePropsList;

    fmiRealTypeProperties defaultRealType;
    fmiEnumerationTypeProperties defaultEnumType;
    fmiIntegerTypeProperties defaultIntegerType;
    fmiBooleanTypeProperties defaultBooleanType;
    fmiStringTypeProperties defaultStringType;
};

extern void fmiInitTypeDefinitions(fmiTypeDefinitions* td, jm_callbacks* cb) ;

extern void fmiFreeTypeDefinitionsData(fmiTypeDefinitions* td);



extern void fmiIntegerTypeInit(fmiIntegerType* type);


extern void fmiEnumerationTypeInit(fmiEnumerationType* type, jm_callbacks* cb);

extern void fmiEnumeratioTypeFree(jm_named_ptr named);

fmiVariableTypeBase* fmiAllocVariableTypeProps(fmiTypeDefinitions* td, fmiVariableTypeBase* base, size_t typeSize);

fmiVariableTypeBase* fmiAllocVariableTypeStart(fmiTypeDefinitions* td,fmiVariableTypeBase* base, size_t typeSize);

fmiRealTypeProperties* fmiParseRealTypeProperties(fmiXMLParserContext* context, fmiXMLElmEnum elmID);

fmiIntegerTypeProperties *fmiParseIntegerTypeProperties(fmiXMLParserContext* context, fmiXMLElmEnum elmID);

extern int fmiXMLCheckLastElementIsSpecificType(fmiXMLParserContext *context);

extern jm_named_ptr fmiVariableTypeAlloc(fmiXMLParserContext* context, jm_vector(char)* name, jm_vector(char)* description, size_t size);

extern void* fmiVariableTypeCreate(fmiXMLParserContext* context, size_t size, jm_vector(jm_named_ptr)* typeList );

extern fmiRealType* fmiVariableTypeCreateReal(fmiXMLParserContext* context, fmiXMLElmEnum elmID, jm_vector(jm_named_ptr)* typeList );

extern fmiIntegerType* fmiVariableTypeCreateInteger(fmiXMLParserContext* context, fmiXMLElmEnum elmID, jm_vector(jm_named_ptr)* typeList );

fmiVariableTypeBase* fmiXMLGetDeclaredType(fmiXMLParserContext *context, fmiXMLElmEnum elmID, fmiVariableTypeBase* defaultType);

#endif /* FMITYPEIMPL_H */
