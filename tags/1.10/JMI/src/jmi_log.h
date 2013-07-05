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

/** \file jmi_log.h
    \brief Logging utilities for the JMI runtime.

    Logs are composed of nested log nodes.
    Nodes can contain either
     * Other nodes, or
     * a matrix or vector of scalar values, or
     * a single scalar value.

    Every log entry has an associated log category, described by the jmi_log_category_t type.
    Log calls either take a category (`logError`, `logWarning`, or `logInfo`), 
    or use the category of the current node.

    Nodes are entered with one of the functions jmi_log_enter, jmi_log_enter_fmt, and jmi_log_enter_,
    and must be left in the corresponding order with jmi_log_leave or jmi_log_leave_,
    supplying the jmi_log_node_t that was returned when the node was entered.
    This is to keep track of that log nodes don't become unbalanced. If an unbalance is detected,
    jmi_log_leave will emit a warning comment to the log, and attempt leave the specified node.

*/    

#ifndef _JMI_LOG_H
#define _JMI_LOG_H

#include "jmi_common.h"  /* for jmi_t */


/**
 * \brief Types of log messages.
 * Higher value = less severe
 */
typedef enum {
    logError,
    logWarning,
    logInfo
} jmi_log_category_t;

typedef struct {
    int inner_id;
} jmi_log_node_t;


#ifdef __cplusplus
extern "C" {
#endif


/** \brief Allocate and intialize a log, with output to `jmi` */
jmi_log_t *jmi_log_init(jmi_t *jmi);

/** \brief Deallocate the log */
void jmi_log_delete(jmi_log_t *log);


/* Row primitives */

/** \brief Enter a new log node with given category and type. */
jmi_log_node_t jmi_log_enter(    jmi_log_t *log, jmi_log_category_t c, const char *type);

/** \brief Enter a new log node with given category and type, then call jmi_log_fmt with the remaining parameters. */
jmi_log_node_t jmi_log_enter_fmt(jmi_log_t *log, jmi_log_category_t c, const char *type, const char* fmt, ...);

/** \brief Leave the current log node, as returned by the `jmi_log_enterXXX` functions. */
void jmi_log_leave(jmi_log_t *log, jmi_log_node_t node);

/** \brief Leave log nodes until `node` is left. Use only upon abrupt return. */
void jmi_log_unwind(jmi_log_t *log, jmi_log_node_t node);

/** \brief Create a new log node with contents given by invoking jmi_log_fmt. */
void jmi_log_node( jmi_log_t *log, jmi_log_category_t c, const char *type, const char* fmt, ...);


/** \brief Log comments and scalar attributes according to the format string `fmt`.
 *    
 *  The format string can contain
 *  * Comments, verbatim
 *  * Scalar attributes between angle brackets, in the form `<` *name* `:%` *format* `>` (e.g. `<t:%e>`, where
 *      * *name* is an identifier and
 *      * *format* is one of the printf format characters
 *          `diu` for `int`, 
 *          `eEfFgG` for `jmi_real_t`, or
 *          `s` for `char *`.
 *        No format specifiers beyond the single character are supported;
 *        a default format is used for all reals, etc.
 *  * Scalar attributes with a variable reference as value, in the form `<` *name* `:#` *type* `%d#>`
 *    (e.g. `<var:#r%d#>`), where `<type>` is one of the characters `ribs`.
 * 
 *  The values for consecutive attributes should be supplied as additional arguments, just like for `printf`.
 * 
 */
void jmi_log_fmt(jmi_log_t *log, jmi_log_node_t node, jmi_log_category_t c, const char *fmt, ...);

/** \brief Log a comment inside the current node. */
void jmi_log_comment(jmi_log_t *log, jmi_log_category_t c, const char *msg);


/** \brief Log a vector of `n` reals. */
void jmi_log_reals(jmi_log_t *log,  jmi_log_node_t node,
                   jmi_log_category_t c, const char *name, const jmi_real_t *data, int n);

/** \brief Log a vector of `n` ints. */
void jmi_log_ints( jmi_log_t *log, jmi_log_node_t node,
                   jmi_log_category_t c, const char *name, const int *data, int n);

/** \brief Log a vector of `n` variable references of type `t`, which should be one of `ribs`. */
void jmi_log_vrefs(jmi_log_t *log, jmi_log_node_t node,
                   jmi_log_category_t c, const char *name, char t, const int *vrefs, int n);

/** \brief Log a matrix of `m x n` reals, stored in column major order. */
void jmi_log_real_matrix(jmi_log_t *log, jmi_log_node_t node,
                         jmi_log_category_t c, const char *name, const jmi_real_t *data, int m, int n);


/** \brief Emit the current accumulated log line to the logger callback. */
void jmi_log_emit(jmi_log_t *log);


/* Subrow primitives. End in _ since they don't emit a log message. */

/** \brief Supply a name for the next child of `node`. `name` must remain valid until the next `enter` call. */
void jmi_log_label_(jmi_log_t *log, jmi_log_node_t node, const char *name);

/** \brief Enter a new log node with given category and type, without ending the line. */
jmi_log_node_t jmi_log_enter_(jmi_log_t *log, jmi_log_category_t c, const char *type);

/** \brief Enter a new log node that is a vector of the given element type, without ending the line. */
jmi_log_node_t jmi_log_enter_vector_(jmi_log_t *log, jmi_log_node_t node,
                                     jmi_log_category_t c, const char *name);

/** \brief Leave the current log node, as returned by the `jmi_log_enterXXX` functions, without ending the line. */
void jmi_log_leave_(jmi_log_t *log, jmi_log_node_t node);


/** \brief Log comments and scalar attributes according like jmi_log_fmt, without ending the line. */
void jmi_log_fmt_(jmi_log_t *log,  jmi_log_node_t node,
                  jmi_log_category_t c, const char *fmt, ...);

/** \brief Log a comment inside the current node, without ending the line. */
void jmi_log_comment_(jmi_log_t *log, jmi_log_category_t c, const char *msg);


/** \brief Log a string value, without ending the line. */
void jmi_log_string_(jmi_log_t *log, const char *x);

/** \brief Log a real value, without ending the line. */
void jmi_log_real_(  jmi_log_t *log, jmi_real_t x);

/** \brief Log an int value, without ending the line. */
void jmi_log_int_(   jmi_log_t *log, int x);

/** \brief Log a value reference of type `t` (one of `ribs`), without ending the line. */
void jmi_log_vref_(  jmi_log_t *log, char t, int vref);


#ifdef __cplusplus
}
#endif

#endif
