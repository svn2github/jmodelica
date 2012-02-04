#include <string.h>
#include "jm_callbacks.h"
#include "jm_named_ptr.h"

jm_named_ptr jm_named_alloc(const char* name, size_t size, size_t nameoffset, jm_callbacks* c) {
    jm_named_ptr out;
    size_t namelen = strlen(name);
    size_t sizefull = size + namelen;
    out.ptr = c->malloc(sizefull);
    if(out.ptr) {
        char* outname;
        outname = out.ptr;
        outname += nameoffset;
        if(namelen)
            memcpy(outname, name, namelen);
        outname[namelen] = 0;
        out.name = outname;
    }
    return out;
}

jm_named_ptr jm_named_alloc_v(jm_vector(char)* name, size_t size, size_t nameoffset, jm_callbacks* c) {
    jm_named_ptr out;
    size_t namelen = jm_vector_get_size(char)(name);
    size_t sizefull = size + namelen;
    out.ptr = c->malloc(sizefull);
    if(out.ptr) {
        char * outname = out.ptr;
        outname += nameoffset;
        if(namelen)
            memcpy(outname, jm_vector_get_itemp(char)(name,0), namelen);
        outname[namelen] = 0;
        out.name = outname;
    }
    return out;
}

#define JM_TEMPLATE_INSTANCE_TYPE jm_named_ptr
#include "jm_vector_template.h"
