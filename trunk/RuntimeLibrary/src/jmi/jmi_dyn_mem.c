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
    jmi_dynamic_list_free(mem->head);
    *mem->last = mem->head;
}
