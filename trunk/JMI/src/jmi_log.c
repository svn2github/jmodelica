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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>

#include "fmi1_me.h"
#include "jmi_log.h"

/*#define INLINE inline */ /* not supported in c89 */
#define INLINE 

/* convenience typedefs */
typedef jmi_log_node_t     node_t;
typedef jmi_log_category_t category_t;
typedef jmi_log_t          log_t;

typedef int BOOL;


/** ***************************************************************************
 * \brief Raw character buffer used by jmi_log_t.
 */
typedef struct {
    char *msg;
    int len, alloced;    
} buf_t;

/* buf_t constructor and destructor. */
static void init_buffer(buf_t *buf);
static void delete_buffer(buf_t *buf);


static INLINE BOOL isempty(buf_t *buf) { return buf->len == 0; }

static void clear(buf_t *buf) {
    buf->len = 0;
    buf->msg[0] = 0;
}

static void reserve(buf_t *buf, int len) {
    if (buf->alloced < len) {
        buf->alloced = 2*len;
        buf->msg = (char *)realloc(buf->msg, buf->alloced+1); /* Allocate space for the null byte too */
    }    
}

/** \brief buf_t constructor. */
static void init_buffer(buf_t *buf) {
    buf->alloced = 512;
    buf->msg = (char *)malloc(buf->alloced+1); /* Allocate space for the null byte too */
    clear(buf);    
}

/** \brief buf_t destructor. */
static void delete_buffer(buf_t *buf) {
    free(buf->msg);
    buf->msg = NULL;
    buf->alloced = buf->len = 0;
}


static INLINE char *destof(buf_t *buf) { return buf->msg + buf->len; }


 /* Raw output */

static void buffer_raw_char(buf_t *buf, char c) {
    reserve(buf, buf->len+1);
    destof(buf)[0] = c;
    ++(buf->len);
    destof(buf)[0] = 0;
}

static void buffer_char(buf_t *buf, char c) {
    /* Escape #, used for value references, 
       and %, since the logger callback takes a printf format string. */
    if (c == '#' || c == '%') buffer_raw_char(buf, c);
    buffer_raw_char(buf, c);    
}

static void buffer(buf_t *buf, const char *str) {
    while (*str != 0) buffer_char(buf, *(str++));
}


 /* Somewhat formatted output */

static void buffer_text_char(buf_t *buf, char c) {
    if (c == '<') buffer(buf, "&lt;");
    else if (c == '>') buffer(buf, "&gt;");
    else if (c == '&') buffer(buf, "&amp;");
    else buffer_char(buf, c);
}

static void buffer_attribute_char(buf_t *buf, char c) {
    if (c == '"') buffer(buf, "&quot;");
    else buffer_text_char(buf, c);
}

static void buffer_text(buf_t *buf, const char *str) {
    while (*str != 0) buffer_text_char(buf, *(str++));
}

static void buffer_attribute(buf_t *buf, const char *str) {
    while (*str != 0) buffer_attribute_char(buf, *(str++));
}

static void buffer_attribute_be(buf_t *buf, const char *str, const char *end) {
    if (end == NULL) buffer_attribute(buf, str);
    else {
        while (*str != 0 && str != end) buffer_attribute_char(buf, *(str++));
    }
}

/** \brief Output a comment. */
static void buffer_comment(buf_t *buf, const char *msg) {    
    buffer_text(buf, msg);
}

static BOOL needs_quoting(const char *str) {
    char c = *str;
    if (c == 0) return TRUE;
    if (isdigit(c) || c == '+' || c == '-') return TRUE;
    while (*str != 0) {
        char c = *str;
        if (!(isalnum(c) || c == '_')) return TRUE;
        ++str;
    }
    return FALSE;
}

/** \brief Output a string, wrap it in quotes if necessary. */
static void buffer_string_literal(buf_t *buf, const char *value) {
    if (!needs_quoting(value)) buffer_text(buf, value);    
    else {
        buffer_char(buf, '"');
        while (*value != 0) {
            char c = *value;
            buffer_text_char(buf, c);
            if (c == '"') buffer_char(buf, '"'); /* translates " to "" */
            ++value;
        }
        buffer_char(buf, '"');
    }
}

/** \brief Output an element name, replace invalid characters with `_`. */
static void buffer_element_name(buf_t *buf, const char *type) {
    char ch = *type;
    if (ch == 0) {
        buffer_char(buf, '_');
        return;
    }
    if (isalpha(ch) || ch == '_' || ch == ':') buffer_char(buf, ch);
    else buffer_char(buf, '_');

    ++type;
    while (*type != 0) {
        char ch = *type;
        if (isalnum(ch) || ch == '_' || ch == ':' || ch == '.' || ch == '-') buffer_char(buf, ch);
        else buffer_char(buf, '_');        
        ++type;
    }
}

/** \brief Output a start tag with element name `type`, and `name `attribute `name` if not `NULL`.
 *         If `name_end` is not `NULL`, it points one char past the end of the name.
*/
static void buffer_starttag(buf_t *buf, const char *type,
                            const char *name, const char *name_end) {
    buffer_char(buf, '<');
    buffer_element_name(buf, type);
    if (name != NULL) {
        buffer(buf, " name=\"");
        buffer_attribute_be(buf, name, name_end);
        buffer_char(buf, '"');
    }
    buffer_char(buf, '>');
}

static void buffer_endtag(buf_t *buf, const char *type) {
    buffer(buf, "</");
    buffer_element_name(buf, type);
    buffer_char(buf, '>');
}


/** ***************************************************************************
 * \brief Log frame used by jmi_log_t.
 */
typedef struct {
    int id;
    jmi_log_category_t c;
    const char *type;
} frame_t;

static void logging_error(log_t *log, const char *msg);


/** ***************************************************************************
 * \brief Structured logger
 */ 

struct jmi_log_t {
    jmi_t *jmi;
    buf_t buf;

    category_t c;
    const char *next_name;
    int leafdim;   /**< \brief  -1 when top is not a leaf, otherwise dimension of the leaf. */

    frame_t *frames;
    int topindex;  /**< \brief  Index of the top frame in frames. */
    int lineindex; /**< \brief  Index of the last frame that doesn't start on the current line. */
    int alloced_frames;
    int id_counter;

    int indent;
    BOOL outstanding_comma;
};

/* convenience typedef and functions */
static INLINE buf_t *bufof(log_t *log)    { return &(log->buf); }


/* constructor */
static void init_log(log_t *log, jmi_t *jmi);

/* logging primitives */
static void emit(log_t *log);
static node_t enter_(log_t *log, category_t c, const char *type, int leafdim, 
                     const char *name, const char *name_end);
static void leave_(log_t *log, node_t node);
static void log_value_(log_t *log, const char *value);
static void log_comment_(log_t *log, category_t c, const char *msg);
static void log_vref_(log_t *log, char t, int vref);
static void log_fmt_(log_t *log, category_t c, const char *fmt, va_list ap);


static void defer_comma(  log_t *log) { log->outstanding_comma = TRUE; }
static void cancel_commas(log_t *log) { log->outstanding_comma = FALSE; }

static void force_commas(log_t *log) {
    if (log->outstanding_comma) buffer(bufof(log), ", ");
    log->outstanding_comma = FALSE;
}

static INLINE int current_indent_of(log_t *log) { return 2*log->topindex; }

static BOOL emitted_category(log_t *log, category_t category) {
    jmi_t *jmi = log->jmi;
    if((jmi->fmi != NULL) && !jmi->fmi->fmi_logging_on) return FALSE;
    switch (category) {
    case logError:   break;
    case logWarning: if(jmi->options.log_level < 3) return FALSE; break;
    case logInfo:    if(jmi->options.log_level < 4) return FALSE; break;
    }
    return TRUE;    
}

static void _emit(log_t *log, jmi_log_category_t category, char* message) {
    jmi_t *jmi = log->jmi;
    if (!emitted_category(log, category)) return;
    if(jmi->fmi) {
        fmiStatus status;
        fmiString fmiCategory;
        fmi_t* fmi = jmi->fmi;
        switch (category) {
        case logError:
            status = fmiError;
            fmiCategory = "ERROR";
            break;
        case logWarning:
            status = fmiWarning;
            fmiCategory = "WARNING";
            break;
        case logInfo:
            status = fmiOK;
            fmiCategory = "INFO";
            break;
        }
        fmi->fmi_functions.logger(fmi, fmi->fmi_instance_name,
                                  status, fmiCategory, message);
    }
    else {
        switch (category) {
        case logError:
            fprintf(stderr, "ERROR: %s\n", message);
            break;
        case logWarning:
            fprintf(stderr, "WARNING: %s\n", message);
            break;
        case logInfo:
            fprintf(stdout, "%s\n", message);
            break;
        }
    }
}

/** \brief Emit the currently buffered log message, if one exists. */
static void emit(log_t *log) {
    buf_t *buf = bufof(log);
    force_commas(log);
    if (!isempty(buf)) {
        /* todo: don't alloc/free each time! */
        char *msg2 = (char *)malloc(buf->len + log->indent + 1);
        memset(msg2, ' ', log->indent);
        strcpy(msg2+log->indent, buf->msg);

        /* jmi_log(log, log->c, buf->msg); */
        _emit(log, log->c, msg2);
        clear(buf);

        free(msg2);
    }
    log->indent = current_indent_of(log);
    log->lineindex = log->topindex;
}

/** \brief Set the current logging category; emit a log message if it was changed. */
static void set_category(log_t *log, category_t c) {
    force_commas(log);
    if (log->c != c) emit(log);
    log->c = c;
}


 /* Frame helpers */

/** \brief Return the top frame. */
static INLINE frame_t *topof(log_t *log) { return log->frames + log->topindex; } 
static INLINE BOOL can_pop(log_t *log)   { return log->topindex > 0; } /* always keep one frame */

static node_t node_from_top(log_t *log) {
    node_t node;
    node.inner_id = topof(log)->id;
    return node;
}

/** \brief Push a new frame to the top of the stack, initialize and return it. */
static frame_t *push_frame(log_t *log, category_t c, const char *type, int leafdim) {
    frame_t *top;

    ++(log->topindex);
    if (log->topindex >= log->alloced_frames) {
        log->alloced_frames = 2*(log->topindex+1);
        log->frames = (frame_t *)realloc(log->frames, log->alloced_frames*sizeof(frame_t));
    }

    top       = log->frames + log->topindex;
    top->id   = log->id_counter + log->topindex;
    top->c    = c;
    top->type = type;

    log->id_counter += 256;
    log->leafdim     = leafdim;

    return top;
}


/** log_t constructor. */
static void init_log(log_t *log, jmi_t *jmi) {
    log->jmi = jmi;
    init_buffer(bufof(log));
    log->c = logInfo;
    log->next_name = NULL;

    log->alloced_frames = 32;
    log->frames = (frame_t *)malloc(log->alloced_frames*sizeof(frame_t));
    log->topindex = -1;
    log->id_counter = 0;

    log->outstanding_comma = FALSE;
    push_frame(log, logInfo, "Log", -1);  /* todo: do we need to always have a frame on the stack? */
    log->lineindex = 0;
    log->indent = current_indent_of(log);
}

static void delete_log(log_t *log) {
    delete_buffer(bufof(log));
    free(log->frames);
    free(log);
}


 /* Logging primitives */

/** \brief Leave the top frame without printing any logging errors. */
static BOOL _leave_frame_(log_t *log) {
    int indent;
    buf_t   *buf = bufof(log);
    frame_t *top = topof(log);
    BOOL same_line = log->lineindex < log->topindex;

    log->next_name = NULL;
    log->leafdim = -1;
    if (log->lineindex > log->topindex) log->lineindex = log->topindex;

    if (!can_pop(log)) return FALSE;
    --(log->topindex);

    if (emitted_category(log, top->c)) {
        indent = current_indent_of(log);
        if (log->indent > indent) log->indent = indent;

        cancel_commas(log);
        set_category(log, top->c);
        buffer_endtag(bufof(log), top->type);
    }
    return TRUE;
}

/** \brief Leave the top frame. */
static void leave_frame_(log_t *log) {
    if (!_leave_frame_(log)) {
        logging_error(log, "leave_frame_: frame stack empty; unable to pop.");
    }
}

static void _leave_(log_t *log, node_t node) {
    int k;
    
    for (k=log->topindex; k > 0; k--) {
        if (log->frames[k].id == node.inner_id) break;
    }
    if (k <= 0) logging_error(log, "leave_: trying to leave a node not on the stack.");
    else {
        while (can_pop(log)) {
            BOOL final = (topof(log)->id == node.inner_id);
            leave_frame_(log);
            if (final) break;
        }
    }
}

/** \brief Leave the range of log nodes given by node. */
static void leave_(log_t *log, node_t node) {
    if (topof(log)->id != node.inner_id) {
        logging_error(log, "leave_: trying to leave another node than the current one.");
    }
    _leave_(log, node);
}

/** \brief If the current node is a leaf, close it and give a logging_error. */
static void close_leaf(log_t *log) {
    if (log->leafdim >= 0) {
        _leave_frame_(log);
        logging_error(log, "trying to enter a comment or subnode within a leaf node; closing it first.");
    }
}

/** \brief Enter a frame for a node. */
static node_t enter_(log_t *log, category_t c, const char *type, int leafdim,
                     const char *name, const char *name_end) {
    close_leaf(log);
    log->next_name = NULL;

    push_frame(log, c, type, leafdim);
    if (emitted_category(log, c)) {
        set_category(log, c);
        buffer_starttag(bufof(log), type, name, name_end);
    }
    cancel_commas(log);
    return node_from_top(log);
}

void jmi_log_label_(jmi_log_t *log, jmi_log_node_t node, const char *name) {
    if (topof(log)->id != node.inner_id) {
        logging_error(log, "jmi_log_label_: trying to name a child not of the current node.");
        /* todo: leave nodes until node becomes current? */
    }
    else if (log->leafdim >= 0) {
        logging_error(log, "jmi_log_label_: trying to name a child of a leaf node.");
        return;
    }
    else log->next_name = name;
}


/** Log a value. */
static void log_value_(log_t *log, const char *value) {    
    force_commas(log);
    buffer_text(bufof(log), value);
    defer_comma(log);
}

/** Log a string. */
static void log_string_literal_(log_t *log, const char *value) {    
    force_commas(log);
    buffer_string_literal(bufof(log), value);
    defer_comma(log);
}

static void log_comment_(log_t *log, category_t c, const char *msg) {
    close_leaf(log);
    if (!emitted_category(log, c)) return;
    set_category(log, c);    
    buffer_comment(bufof(log), msg);
}

/** Log a value reference. */
static void log_vref_(log_t *log, char t, int vref) {
    buf_t *buf = bufof(log);
    char tmp[128];

    force_commas(log);
    buffer_char(buf, '"'); buffer_raw_char(buf, '#');

    buffer_text_char(buf, t);
    sprintf(tmp, "%d", vref);
    buffer_text(buf, tmp);

    buffer_raw_char(buf, '#'); buffer_char(buf, '"'); 
    defer_comma(log);
}

static void logging_error(log_t *log, const char *msg) {
    emit(log);
    log_comment_(log, logInfo, "Logger error: ");
    log_comment_(log, logInfo, msg);
    emit(log);
}


 /* User constructor, destructor */

jmi_log_t *jmi_log_init(jmi_t *jmi) {
    log_t *log = (log_t *)malloc(sizeof(log_t));
    init_log(log, jmi);
    return log;
}
void jmi_log_delete(log_t *log) { delete_log(log); }


 /* Entry/exit primitives */

/** \brief Enter a named list node that contains named nodes, then emit. */
node_t jmi_log_enter(log_t *log, category_t c, const char *type) {
    node_t node = jmi_log_enter_(log, c, type);
    emit(log); return node;
}
node_t jmi_log_enter_(log_t *log, category_t c, const char *type) {
    /* todo: check that type is not "vector" etc? */
    return enter_(log, c, type, -1, log->next_name, NULL);
}

static node_t enter_value_(log_t *log, category_t c, 
                            const char *name, const char *name_end) {
    return enter_(log, c, "value", 0, name, name_end);
}
/* could be exported */
static node_t jmi_log_enter_value_(log_t *log, category_t c, const char *name) {
    return enter_value_(log, c, name, NULL);
}
node_t jmi_log_enter_vector_(log_t *log, category_t c, const char *name) {
    return enter_(log, c, "vector", 1, name, NULL);
}
/* could be exported if we also export an interface to begin a new row. */
static node_t jmi_log_enter_matrix_(log_t *log, category_t c, const char *name) {
    return enter_(log, c, "matrix", 2, name, NULL);
}

/** \brief Leave node, then emit. */
void jmi_log_leave(log_t *log, node_t node) { jmi_log_leave_(log, node); emit(log); }
void jmi_log_leave_(log_t *log, node_t node) { leave_(log, node); }

/** \brief Like jmi_log_leave, but may doesn't need to take innermost node. */
void jmi_log_unwind(log_t *log, node_t node) { _leave_(log, node); emit(log); }


static BOOL contains(const char *chars, char c) {
    while (*chars) if (*(chars++) == c) return TRUE;
    return FALSE;
}

static INLINE BOOL is_name_char(char c) { return isalnum(c) || c == '_'; }

static void log_fmt_(log_t *log, category_t c, const char *fmt, va_list ap) {
    buf_t *buf = bufof(log);

    close_leaf(log);
    if (!emitted_category(log, c)) return;
    set_category(log, c);
    while (*fmt != 0) {
        char ch = *fmt;
        if (ch == '<') {
            /* Copy comments verbatim */
            ++fmt;
            while ((*fmt != 0) && (*fmt != '>')) buffer_text_char(buf, *(fmt++));
            ++fmt;
        }
        else if (is_name_char(ch)) {
            /* Try to log an attribute */
            node_t node;
            const char *name_end;
            const char *name_start = fmt;

            while (is_name_char(*fmt)) ++fmt;
            name_end = fmt;
            if (name_end == name_start) { logging_error(log, "jmi_log_fmt: expected attribute name."); break; }
            while (isspace(*fmt)) ++fmt;
            if (*(fmt++) != ':') { logging_error(log, "jmi_log_fmt: expected ':'"); break; }            
            while (isspace(*fmt)) ++fmt;
            
            ch = *(fmt++);
            if (ch == '%') {
                char f = *(fmt++);
                if (!contains("diueEfFgGs", f)) { logging_error(log, "jmi_log_fmt: unknown format specifier"); break; }
                
                node = enter_value_(log, c, name_start, name_end);

                /* todo: consider: what if jmi_real_t is not double? */
                if      (contains("diu", f))    jmi_log_int_(   log, va_arg(ap, int));
                else if (contains("eEfFgG", f)) jmi_log_real_(  log, va_arg(ap, double));
                else if (f == 's')              jmi_log_string_(log, va_arg(ap, const char *));
                else { logging_error(log, "jmi_log_fmt: unknown format specifier"); break; }

                leave_(log, node);
            }
            else if (ch == '#') {
                char t = *(fmt++);
                if (!contains("ribs", t)) { logging_error(log, "jmi_log_fmt: unknown vref type"); break; }
                if (*(fmt++) != '%') { logging_error(log, "jmi_log_fmt: expected '#<type>%d#'"); break; }
                if (*(fmt++) != 'd') { logging_error(log, "jmi_log_fmt: expected '#<type>%d#'"); break; }
                if (*(fmt++) != '#') { logging_error(log, "jmi_log_fmt: expected '#<type>%d#'"); break; }
                
                node = enter_value_(log, c, name_start, name_end);
                jmi_log_vref_(log, t, va_arg(ap, int));
                leave_(log, node);
            }
            else { logging_error(log, "jmi_log_fmt: expected '%' or '#'"); break; }

        }
        else if (isspace(ch) || ch == ',') ++fmt;
        else { logging_error(log, "jmi_log_fmt: unknown format character"); break; }
    }
}

 /* Functions that involve log_fmt */

void jmi_log_fmt_(log_t *log, category_t c, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    log_fmt_(log, c, fmt, ap);
    va_end(ap);
}

void jmi_log_fmt(log_t *log, category_t c, const char *fmt, ...) {
    va_list ap;
    if (!emitted_category(log, c)) return;
    va_start(ap, fmt);
    log_fmt_(log, c, fmt, ap);
    va_end(ap);
    emit(log);
}

jmi_log_node_t jmi_log_enter_fmt(log_t *log, jmi_log_category_t c, const char *type, const char* fmt, ...) {
    va_list ap;
    node_t node = jmi_log_enter_(log, c, type); 

    va_start(ap, fmt);
    log_fmt_(log, c, fmt, ap);
    va_end(ap);
    
    emit(log);
    return node;    
}

void jmi_log_node(log_t *log, category_t c, const char *type, const char* fmt, ...) {
    va_list ap;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_(log, c, type); 

    va_start(ap, fmt);
    log_fmt_(log, c, fmt, ap);
    va_end(ap);
    
    leave_(log, node); emit(log);
}


 /* Subrow primitives */

void jmi_log_emit(log_t *log) { emit(log); }

void jmi_log_comment_(log_t *log, category_t c, const char *msg) { log_comment_(log, c, msg); }
void jmi_log_comment(log_t *log, category_t c, const char *msg) { jmi_log_comment_(log, c, msg); emit(log); }


void jmi_log_string_(log_t *log, const char *x) { log_string_literal_(log, x); }

void jmi_log_real_(log_t *log, jmi_real_t x) {
    char buf[128];
    char *rep;
    sprintf(buf, "%30.16E", x);
    log_value_(log, buf);
}

void jmi_log_int_(log_t *log, int x) {
    char buf[128];
    sprintf(buf, "%d", x);
    log_value_(log, buf);
}

void jmi_log_vref_(log_t *log, char t, int vref) { log_vref_(log, t, vref); }


 /* Row primitives */

void jmi_log_reals(log_t *log, category_t c, const char *name, const jmi_real_t *data, int n) {
    int k;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_vector_(log, logInfo, name);
    for (k=0; k < n; k++) jmi_log_real_(log, data[k]);
    jmi_log_leave(log, node);
}

void jmi_log_ints(log_t *log, category_t c, const char *name, const int *data, int n) {
    int k;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_vector_(log, logInfo, name);
    for (k=0; k < n; k++) jmi_log_int_(log, data[k]);
    jmi_log_leave(log, node);
}

void jmi_log_vrefs(log_t *log, jmi_log_category_t c, const char *name, char t, const int *vrefs, int n) {
    int k;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_vector_(log, logInfo, name);
    for (k=0; k < n; k++) jmi_log_vref_(log, t, vrefs[k]);
    jmi_log_leave(log, node);    
}

void jmi_log_real_matrix(log_t *log, category_t c, const char *name, const jmi_real_t *data, int m, int n) {
    int k, l;
    node_t node;
    if (!emitted_category(log, c)) return;
    node = jmi_log_enter_matrix_(log, c, name);
    emit(log);
    for (l=0; l < m; l++) {
        for (k=0; k < n; k++) {
            jmi_log_real_(log, data[k*m + l]);
        }
        cancel_commas(log);
        buffer_char(bufof(log), ';'); emit(log);  /* todo: better way to signal end of the row? */
    }
    jmi_log_leave(log, node);
}
