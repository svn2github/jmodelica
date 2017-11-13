 /*
    Copyright (C) 2015 Modelon AB

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

#ifndef _JMI_DYN_MEM_H
#define _JMI_DYN_MEM_H

#include <stdio.h>

typedef struct jmi_dynamic_function_memory_t {
    char* cur_pos;
    char* start_pos;
    size_t block_size;
    size_t new_block_size;
    void* memory_block;
    size_t nbr_trailing_memory;
    char** trailing_memory; /* Temporary usage when the memory block is all used up */
} jmi_dynamic_function_memory_t;

typedef struct jmi_local_dynamic_function_memory_t {
    jmi_dynamic_function_memory_t* mem;
    char* start_pos;
} jmi_local_dynamic_function_memory_t;


/* Macro for declaring dynamic list variable - should be called at beginning of function */
#define JMI_DYNAMIC_INIT() \
    jmi_local_dynamic_function_memory_t dyn_mem = {NULL, NULL};

/* Dynamic deallocation of all dynamically allocated arrays and record arrays - should be called before return */
#define JMI_DYNAMIC_FREE() \
    jmi_dynamic_function_free(&dyn_mem);

/* Evaluate and assign expression only if computed flag is false. Sets computed flag to true. */
#define JMI_CACHED(var, exp) ((!var##_computed && (var##_computed = 1)) ? (var = exp) : var)


jmi_dynamic_function_memory_t* jmi_dynamic_function_memory();

/* Creates a memory pool and returns the allocated object */
jmi_dynamic_function_memory_t* jmi_dynamic_function_pool_create(size_t block);
/* Destroys the memory pool */
void jmi_dynamic_function_pool_destroy(jmi_dynamic_function_memory_t* mem);

/* Allocates memory from the memory pool (i.e. no actually system allocating takes place if there is memory available in the pool */
void *jmi_dynamic_function_pool_alloc(jmi_local_dynamic_function_memory_t* local_block, size_t block);
/* Internal method for the allocation */
void *_jmi_dynamic_function_pool_alloc(jmi_dynamic_function_memory_t* mem, size_t block);

/* Initializes the local block to point to the current place in memory pool */
void jmi_dynamic_function_init(jmi_local_dynamic_function_memory_t* local_block);
/* Rewinds the memory pool to the position of the local block */
void jmi_dynamic_function_free(jmi_local_dynamic_function_memory_t* local_block);

#endif /* _JMI_DYN_MEM_H */
