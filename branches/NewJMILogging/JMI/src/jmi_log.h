/*
    Copyright (C) 2013 Modelon AB

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

#ifndef _JMI_LOG_H
#define _JMI_LOG_H

#include "jmi_common.h"  /* for jmi_t */
#include "jmi_util.h"    /* for jmi_log_category_t */


typedef int BOOL;
/* enum {FALSE=0, TRUE=1}; */

typedef struct {
    int outer_id;
    int inner_id;
} jmi_log_node_t;

typedef enum { jmiLogAny, jmiLogString, jmiLogReal, jmiLogInt, jmiLogBool, jmiLogVref, jmiLogNamed } jmi_log_type_t;


#ifdef __cplusplus
extern "C" {
#endif


jmi_log_t *jmi_log_init();
void jmi_log_delete(jmi_log_t *log);


/* Row primitives */

jmi_log_node_t jmi_log_enter(    jmi_t *jmi, jmi_log_category_t c, const char *name);
jmi_log_node_t jmi_log_enter_fmt(jmi_t *jmi, jmi_log_category_t c, const char *name, const char* fmt, ...);
void jmi_log_node( jmi_t *jmi, jmi_log_category_t c, const char *name, const char* fmt, ...);
void jmi_log_leave(jmi_t *jmi, jmi_log_node_t node);

void jmi_log_fmt(jmi_t *jmi, jmi_log_category_t c, const char *fmt, ...);

void jmi_log_reals(jmi_t *jmi, jmi_log_category_t c, const char *name, const jmi_real_t *data, int n);
void jmi_log_ints( jmi_t *jmi, jmi_log_category_t c, const char *name, const int *data, int n);
void jmi_log_bools(jmi_t *jmi, jmi_log_category_t c, const char *name, const BOOL *data, int n);
void jmi_log_vrefs(jmi_t *jmi, jmi_log_category_t c, const char *name, char t, const int *vrefs, int n);

void jmi_log_real_matrix(jmi_t *jmi, jmi_log_category_t c, const char *name, const jmi_real_t *data, int m, int n);


/* Subrow primitives */

void jmi_log_emit(jmi_t *jmi);

jmi_log_node_t jmi_log_enter_(jmi_t *jmi, jmi_log_category_t c, const char *name);
jmi_log_node_t jmi_log_enter_vector_(jmi_t *jmi, jmi_log_category_t c, const char *name, jmi_log_type_t eltype);
void jmi_log_leave_(jmi_t *jmi, jmi_log_node_t node);

void jmi_log_comment_(jmi_t *jmi, jmi_log_category_t c, const char *msg);

void jmi_log_string_(jmi_t *jmi, const char *x);
void jmi_log_real_(  jmi_t *jmi, jmi_real_t x);
void jmi_log_int_(   jmi_t *jmi, int x);
void jmi_log_bool_(  jmi_t *jmi, BOOL x);
void jmi_log_vref_(  jmi_t *jmi, char t, int vref);

void jmi_log_fmt_(jmi_t *jmi, jmi_log_category_t c, const char *fmt, ...);


#ifdef __cplusplus
}
#endif

#endif
