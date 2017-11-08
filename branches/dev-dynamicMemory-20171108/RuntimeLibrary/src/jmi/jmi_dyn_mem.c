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

#include "jmi_dyn_mem.h"

#include <stdlib.h>
#include <string.h>

void jmi_dynamic_list_free(jmi_dynamic_list* head) {
    jmi_dynamic_list* next = head->next;
    jmi_dynamic_list* curr;
    while ((curr = next)) {
        next = curr->next;
        free(curr->data);
        free(curr);
    }
    head->next = NULL;
}

void jmi_dynamic_add_pointer(jmi_dyn_mem_t* dyn_mem, void* pointer) {
    if (!(dyn_mem->head)) {
        jmi_dynamic_list** last = jmi_dyn_mem_last();
        jmi_dyn_mem_init(dyn_mem, *last, last);
    }
    jmi_dyn_mem_add(dyn_mem, pointer);
}

void jmi_dyn_mem_init(jmi_dyn_mem_t* mem, jmi_dynamic_list* head, jmi_dynamic_list** last) {
    *last = head;
    mem->head = head;
    mem->last = last;
}

void jmi_dyn_mem_add(jmi_dyn_mem_t* mem, void* data) {
    jmi_dynamic_list* l = (jmi_dynamic_list*)calloc(1, sizeof(jmi_dynamic_list));
    (*mem->last)->next = l;
    l->data = data;
    l->next = NULL;
    *mem->last = l;
}

void jmi_dyn_mem_free(jmi_dyn_mem_t* mem) {
    if (mem->head) {
        jmi_dynamic_list_free(mem->head);
        *mem->last = mem->head;
    }
}







jmi_dynamic_function_memory_t* jmi_dynamic_function_pool_create(size_t block) {
    jmi_dynamic_function_memory_t* mem = (jmi_dynamic_function_memory_t*)calloc(1, sizeof(jmi_dynamic_function_memory_t));
    
    mem->memory_block = (void*)calloc(1, block);
    mem->start_pos = (char*)(mem->memory_block);
    mem->cur_pos = mem->start_pos;
    mem->block_size = block;
    mem->new_block_size = 0;
    mem->trailing_memory = NULL;
    
    return mem;
}

void jmi_dynamic_function_pool_destroy(jmi_dynamic_function_memory_t* mem) {
    size_t i;
    
    if (mem != NULL) {
        free(mem->memory_block);
        for (i = 0; i < mem->nbr_trailing_memory; i++) { free(mem->trailing_memory[i]); }
        if (mem->trailing_memory != NULL) { free(mem->trailing_memory); }
        free(mem);
        mem = NULL;
    }
}

static size_t jmi_dynamic_function_pool_available(jmi_dynamic_function_memory_t *mem) {
    return mem->block_size - (size_t)(mem->cur_pos - mem->start_pos);
}

void *jmi_dynamic_function_pool_alloc(jmi_local_dynamic_function_memory_t* local_block, size_t block) {
    void *ptr = NULL;
    jmi_dynamic_function_memory_t* mem;
    
    if (local_block->mem == NULL) jmi_dynamic_function_init(local_block);
    mem = local_block->mem;
    
    if (jmi_dynamic_function_pool_available(mem) < block) { /* Not enough memory in the block */
        mem->cur_pos += jmi_dynamic_function_pool_available(mem); /* Move current position to block end, necessary */
        
        if (mem->nbr_trailing_memory == 0) {
            mem->trailing_memory = (char**)calloc(1, sizeof(char*));
            mem->trailing_memory[0] = (char*)calloc(1, block);
            mem->nbr_trailing_memory = 1;
        } else {
            mem->nbr_trailing_memory = mem->nbr_trailing_memory + 1;
            mem->trailing_memory = (char**)realloc(mem->trailing_memory, mem->nbr_trailing_memory*sizeof(char*));
            mem->trailing_memory[mem->nbr_trailing_memory-1] = (char*)calloc(1, block);
        }
        mem->new_block_size += block;
        ptr = mem->trailing_memory[mem->nbr_trailing_memory-1];
    } else {
        ptr = mem->cur_pos;
        memset(ptr, 0, block); /* Zero out memory */
        mem->cur_pos += block;
    }
        
    return ptr;
}

void jmi_dynamic_function_init(jmi_local_dynamic_function_memory_t* local_block) {
    if (local_block->mem == NULL) local_block->mem = jmi_dynamic_function_memory();
    
    /* Record position */
    local_block->start_pos = local_block->mem->cur_pos;
}

void jmi_dynamic_function_free(jmi_local_dynamic_function_memory_t* local_block) {
    size_t i;
    jmi_dynamic_function_memory_t* mem = local_block->mem;
    
    /* No memory used, return. */
    if (mem == NULL) return;
    /* if (mem == NULL) mem = jmi_dynamic_function_memory(); */
    
    mem->cur_pos = local_block->start_pos; /* Rewind pointer */
    
    if (mem->cur_pos == mem->start_pos) { /* We are back at the beginning */
        for (i = 0; i < mem->nbr_trailing_memory; i++) {
            free(mem->trailing_memory[i]);
        }
        mem->nbr_trailing_memory = 0;
        if (mem->trailing_memory != NULL) {
            free(mem->trailing_memory);
            mem->trailing_memory = NULL;
        }
        
        /* If more memory is request, allocate larger block */
        if (mem->new_block_size != 0) {
            mem->block_size = 2*(mem->block_size+mem->new_block_size);
            mem->memory_block = (void*)realloc(mem->memory_block, mem->block_size);
            mem->start_pos = (char*)(mem->memory_block);
            mem->cur_pos = mem->start_pos;
            mem->new_block_size = 0;
        }
    }
}
