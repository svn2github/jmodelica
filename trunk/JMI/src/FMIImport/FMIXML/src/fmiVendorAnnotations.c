#include <string.h>

#include "fmiXMLParser.h"
#include "fmiModelDescriptionImpl.h"
#include "fmiVendorAnnotationsImpl.h"

void fmiVendorFree(fmiVendor* v) {
    jm_named_vector_free_data(&v->annotations);
    v->annotations.callbacks->free(v);
}

const char* fmiGetVendorName(fmiVendor* v) {
    return v->name;
}

unsigned int  fmiGetNumberOfVendorAnnotations(fmiVendor* v) {
    return jm_vector_get_size(jm_named_ptr)(&v->annotations);
}

fmiAnnotation* fmiGetVendorAnnotation(fmiVendor* v, unsigned int  index) {
    if(index >= fmiGetNumberOfVendorAnnotations(v)) return 0;
    return jm_vector_get_item(jm_named_ptr)(&v->annotations, index).ptr;
}

const char* fmiGetAnnotationName(fmiAnnotation* a) {
    return a->name;
}

const char* fmiGetAnnotationValue(fmiAnnotation* a) {
    return a->value;
}

int fmiXMLHandle_VendorAnnotations(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_fmiModelDescription) {
            fmiXMLParseError(context, "VendorAnnotations XML element must be a part of fmiModelDescription");
            return -1;
        }
    }
    else {
        /* might give out a warning if(data[0] != 0) */
    }
    return 0;
}

int fmiXMLHandle_Tool(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_VendorAnnotations) {
            fmiXMLParseError(context, "Tool XML element must be a part of VendorAnnotations");
            return -1;
        }
        {            
            fmiModelDescription* md = context->modelDescription;
            jm_vector(char)* bufName = fmiXMLReserveParseBuffer(context,1,100);
            fmiVendor* vendor = 0;
            fmiVendor dummyV;
            jm_voidp *pvendor;

            if(!bufName) return -1;
            /* <xs:attribute name="name" type="xs:normalizedString" use="required"> */
            if( fmiXMLSetAttrString(context, fmiXMLElmID_Tool, fmiXMLAttrID_name, 1, bufName)) return -1;
            pvendor = jm_vector_push_back(jm_voidp)(&md->vendorList, vendor);
            if(pvendor )
                *pvendor = vendor = jm_named_alloc_v(bufName,sizeof(fmiVendor), dummyV.name - (char*)&dummyV, context->callbacks).ptr;
            if(!pvendor || !vendor) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            jm_vector_init(jm_named_ptr)(&vendor->annotations,0, context->callbacks);
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}
int fmiXMLHandle_Annotation(fmiXMLParserContext *context, const char* data) {
    if(!data) {
        if(context -> currentElmHandle != fmiXMLHandle_Tool) {
            fmiXMLParseError(context, "Annotation XML element must be a part of Tool");
            return -1;
        }

        {
            fmiModelDescription* md = context->modelDescription;
            size_t numVendors = jm_vector_get_size(jm_voidp)(&(md->vendorList));
            fmiVendor* vendor =jm_vector_get_item(jm_voidp)(&(md->vendorList), numVendors-1);
            jm_vector(char)* bufName = fmiXMLReserveParseBuffer(context,1,100);
            jm_vector(char)* bufValue = fmiXMLReserveParseBuffer(context,2,100);
            jm_named_ptr named, *pnamed;
            fmiAnnotation* annotation = 0;
            size_t vallen;

            if(!bufName || !bufValue ||
            /*     <xs:attribute name="name" type="xs:normalizedString" use="required"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_Annotation, fmiXMLAttrID_name, 1, bufName) ||
            /* <xs:attribute name="value" type="xs:string" use="required"/> */
                fmiXMLSetAttrString(context, fmiXMLElmID_Annotation, fmiXMLAttrID_value, 1, bufValue)
                    )
                return -1;
            vallen = jm_vector_get_size(char)(bufValue);
            named.ptr = 0;
            pnamed = jm_vector_push_back(jm_named_ptr)(&vendor->annotations, named);

            if(pnamed) *pnamed = named = jm_named_alloc_v(bufName,sizeof(fmiAnnotation)+vallen+1,sizeof(fmiAnnotation)+vallen,context->callbacks);
            annotation = named.ptr;
            if( !pnamed || !annotation ) {
                fmiXMLParseError(context, "Could not allocate memory");
                return -1;
            }
            annotation->name = named.name;
            if(vallen)
                memcpy(annotation->value,jm_vector_get_itemp(char)(bufValue,0), vallen);
            annotation->value[vallen] = 0;
        }
    }
    else {
        /* don't do anything. might give out a warning if(data[0] != 0) */
        return 0;
    }
    return 0;
}

