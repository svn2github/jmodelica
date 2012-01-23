/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/

#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <assert.h>

#include "fmiCallbacks.h"

#ifdef FMU_REPLACE_SYSTEM_MALLOC
#define fmimalloc malloc
#define fmicalloc calloc
#define fmirealloc realloc
#define fmifree free
#endif

void *fmimalloc(size_t size) {
    fmiMemoryHeader* header;
    fmiCallbacks* fmiCB;
    jm_callbacks* jmCB = jm_get_default_callbacks();
    fmiCB = jmCB->context;

    header = fmiCB->fmiFunctions.allocateMemory(1, size + sizeof(fmiMemoryHeader) );
    if(!header) return 0;
    header->callbacks = fmiCB;
    header->size = size;
    header++;
    return header;
}

void *fmicalloc(size_t nelements, size_t elementSize){
    /* Use fmimalloc since header needs to be allocated and its in most cases != elementSize.
       Alternative might be to allocated nelements + (sizeof(fmiMemoryHeader)+elementSize-1)/elementSize
       and then align on elementSize. This would complicate realloc and free.
       Formally there should always be a check that (nelements * elementSize) can be represented with size_t.
       For now just put an assert on that.
    */
    assert(!nelements || !elementSize || ((ULONG_MAX/elementSize) > (nelements +(sizeof(fmiMemoryHeader)+elementSize-1)/elementSize)));
    return fmimalloc(nelements * elementSize);
}

/* fmifree gets the context pointer directly from the memory header. */
void fmifree ( void * ptr ){
    fmiMemoryHeader* header = ptr;
    header--;
    header->callbacks->fmiFunctions.freeMemory(header);
}

void *fmirealloc(void *pointer, size_t size) {
    fmiMemoryHeader* header;
    fmiCallbacks* fmiCB;
    void* newmem;
    size_t copysize;

    /* handle special cases first*/
    if(size == 0) { /* equivalent to free */
        fmifree(pointer);
        return 0;
    }
    if(!pointer) { /* equivalent to malloc */
        return fmimalloc(size);
    }

    header = pointer;
    header--;
    if(header->size == size) return pointer; /* no size change */

    newmem = header->callbacks->jmFunctions.malloc(size);
    if(!newmem) return 0; /* malloc failed */
    copysize = (size < header->size) ? size : header->size;
    memcpy(newmem, pointer, copysize);
    fmifree(pointer);
    return newmem;
}


void fmiInitCallbacks(fmiCallbacks* callbacks, fmiCallbackFunctions* fmiFunctions) {
    callbacks->jmFunctions.malloc = fmimalloc;
    callbacks->jmFunctions.calloc = fmicalloc;
    callbacks->jmFunctions.realloc = fmirealloc;
    callbacks->jmFunctions.free = fmifree;
    callbacks->jmFunctions.logger = (jm_logger_f)(fmiFunctions->logger);
    callbacks->jmFunctions.context = callbacks;

    callbacks->fmiFunctions.logger = fmiFunctions->logger;
    callbacks->fmiFunctions.allocateMemory = fmiFunctions->allocateMemory;
    callbacks->fmiFunctions.freeMemory = fmiFunctions->freeMemory;

    jm_set_default_callbacks(&callbacks->jmFunctions);
}
