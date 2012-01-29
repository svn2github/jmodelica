#include "fmiModelDescriptionImpl.h"
#include "fmiUnitImpl.h"

fmiUnit* fmiGetUnit(fmiUnitDefinitions* ud, unsigned int  index) {
    if(index >= fmiGetUnitDefinitionsNumber(ud)) return 0;
    return jm_vector_get_item(jm_named_ptr)(&ud->definitions, index).ptr;
}

const char* fmiGetUnitName(fmiUnit* u) {
    return u->baseUnit;
}

unsigned int fmiGetUnitDisplayUnitsNumber(fmiUnit* u) {
    return jm_vector_get_size(jm_voidp)(&u->displayUnits);
}

fmiDisplayUnit* fmiGetUnitDisplayUnit(fmiUnit* u, size_t index) {
    if(index >= fmiGetUnitDisplayUnitsNumber(u)) return 0;
    return jm_vector_get_item(jm_voidp)(&u->displayUnits, index);
}


fmiUnit* fmiGetBaseUnit(fmiDisplayUnit* du) {
    return du->baseUnit;
}

const char* fmiGetDisplayUnitName(fmiDisplayUnit* du) {
    return du->displayUnit;
}

fmiReal fmiGetDisplayUnitGain(fmiDisplayUnit* du) {
    return du->gain;
}

fmiReal fmiGetDisplayUnitOffset(fmiDisplayUnit* du) {
    return du->offset;
}

fmiReal fmiConvertToDisplayUnit(fmiReal val , fmiDisplayUnit* du, int isRelativeQuantity) {
    double gain = fmiGetDisplayUnitGain(du);
    double offset = fmiGetDisplayUnitOffset(du);
    if(isRelativeQuantity)
        return val/gain;
    else
        return (val - offset)/gain;
}

fmiReal fmiConvertFromDisplayUnit(fmiReal val, fmiDisplayUnit* du, int isRelativeQuantity) {
    double gain = fmiGetDisplayUnitGain(du);
    double offset = fmiGetDisplayUnitOffset(du);
    if(isRelativeQuantity)
        return val + gain;
    else
        return (val*gain + offset);
}

int fmiXMLHandle_UnitDefinitions(fmiXMLParserContext *context, const char* data) {
    fmiModelDescription* md = context->modelDescription;
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_fmiModelDescription) {
            fmiXMLParseError(context, "UnitDefinitions XML element must be a part of fmiModelDescription");
            return -1;
        }
        if(context->lastElmHandle != 0) {
            fmiXMLParseError(context, "UnitDefinitions XML element must be the first inside fmiModelDescription");
            return -1;
        }
    }
    else {
        jm_vector_qsort(jm_named_ptr)(&(md->unitDefinitions),jm_compare_named);
        jm_vector_qsort(jm_named_ptr)(&(md->displayUnitDefinitions),jm_compare_named);
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}


fmiDisplayUnit* fmiXMLGetUnit(fmiXMLParserContext *context, jm_vector(char)* name, int sorted) {
    fmiUnit* unit;
    jm_named_ptr named, *pnamed;
    fmiModelDescription* md = context->modelDescription;

    named.name = jm_vector_get_itemp(char)(name,0);
    if(sorted)
        pnamed = jm_vector_bsearch(jm_named_ptr)(&(md->unitDefinitions), &named,jm_compare_named);
    else
        pnamed = jm_vector_find(jm_named_ptr)(&(md->unitDefinitions), &named,jm_compare_named);

    if(pnamed) {
        unit = pnamed->ptr;
        return &unit->defaultDisplay;
    }

    named.ptr = 0;
    pnamed = jm_vector_push_back(jm_named_ptr)(&(md->unitDefinitions),named);
    if(pnamed) *pnamed = named = jm_named_alloc_v(name,sizeof(fmiUnit),unit->baseUnit - (char*)unit,context->callbacks);

    if(!pnamed || !named.ptr) {
        fmiXMLParseError(context, "Could not allocate memory");
        return 0;
    }

    unit = named.ptr;
    unit->defaultDisplay.baseUnit = unit;
    unit->defaultDisplay.offset = 0;
    unit->defaultDisplay.gain = 1.0;
    unit->defaultDisplay.displayUnit[0] = 0;
    jm_vector_init(jm_voidp)(&(unit->displayUnits),0,context->callbacks);

    if(sorted) jm_vector_qsort_jm_named_ptr(&(md->unitDefinitions), jm_compare_named);
    return &unit->defaultDisplay;
}

int fmiXMLHandle_BaseUnit(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_UnitDefinitions) {
            fmiXMLParseError(context, "BaseUnit XML element must be a part of UnitDefinitions");
            return -1;
        }
        {
            fmiDisplayUnit* unit;
            jm_vector(char)* buf = fmiXMLReserveParseBuffer(context,1,100);

            if(!buf) return -1;
            if( /*  <xs:attribute name="unit" type="xs:normalizedString" use="required"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_BaseUnit, fmiXMLAttrID_unit, 1, buf) ||
                !(unit = fmiXMLGetUnit(context, buf, 0))
               ) return -1;
            context->lastBaseUnit = unit->baseUnit;
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

int fmiXMLHandle_DisplayUnitDefinition(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_BaseUnit) {
            fmiXMLParseError(context, "DisplayUnitDefinition XML element must be a part of BaseUnit");
            return -1;
        }
        {
            fmiModelDescription* md = context->modelDescription;
            jm_vector(char)* buf = fmiXMLReserveParseBuffer(context,1,100);
            /* this display unit belongs to the last created base unit */
            fmiUnit* unit = context->lastBaseUnit;
            fmiDisplayUnit *dispUnit = 0;
            fmiDisplayUnit dummyDU;
            jm_named_ptr named, *pnamed;
            int ret;

            if(!buf) return -1;
            /* first read the required name attribute */
            /*  <xs:attribute name="displayUnit" type="xs:normalizedString" use="required"/> */
            ret = fmiXMLSetAttrString(context, fmiXMLElmID_DisplayUnitDefinition, fmiXMLAttrID_displayUnit, 1, buf);
            if(ret) return ret;
            /* alloc memory to the correct size and put display unit on the list for the base unit */
            named.ptr = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&(md->displayUnitDefinitions),named);
            if(pnamed) *pnamed = jm_named_alloc(jm_vector_get_itemp_char(buf,0),sizeof(fmiDisplayUnit), dummyDU.displayUnit - (char*)&dummyDU,context->callbacks);
            dispUnit = pnamed->ptr;
            if( !pnamed || !dispUnit ||
                !jm_vector_push_back(jm_voidp)(&unit->displayUnits, dispUnit) ) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            dispUnit->baseUnit = unit;
            /* finally process the attributes */
            return (
                        /*  <xs:attribute name="gain" type="xs:double" default="1"/>  */
                        fmiXMLSetAttrDouble(context, fmiXMLElmID_DisplayUnitDefinition, fmiXMLAttrID_gain, 0, &dispUnit->gain, 1)  ||
                         /*  <xs:attribute name="offset" type="xs:double" default="0"/>  */
                        fmiXMLSetAttrDouble(context, fmiXMLElmID_DisplayUnitDefinition, fmiXMLAttrID_offset, 0, &dispUnit->offset, 0)
                     );
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

