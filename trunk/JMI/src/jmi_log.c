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
typedef jmi_log_type_t     base_type_t;

typedef jmi_log_t log_t;


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

/** \brief Output str bracketed by op and cl, escaping cl in str. */
static void buffer_wrapped(buf_t *buf, char op, const char *str, char cl) {
    buffer_char(buf, op);
    while (*str != 0) {
        char c = *str;
        buffer_char(buf, c);
        if (c == cl) buffer_char(buf, op); /* translates " to "" in strings, > to >< in comments */
        ++str;
    }
    buffer_char(buf, cl);
}

static BOOL needs_quoting(const char *str) {
    while (*str != 0) {
        char c = *str;
        if (!(isalnum(c) || c == '_' || c == '.' || c == '+' || c == '-')) return TRUE;
        ++str;
    }
    return FALSE;
}

/** \brief Output a comment. */
static void buffer_comment(buf_t *buf, const char *msg) {    
    buffer_wrapped(buf, '<', msg, '>');
}

/** \brief Output a string, wrap it in quotes if necessary. */
static void buffer_value(buf_t *buf, const char *value) {
    if (needs_quoting(value)) buffer_wrapped(buf, '"', value, '"');
    else buffer(buf, value);
}

/** \brief Output an identifier. */
static void buffer_ident(buf_t *buf, const char *name) {
    /* todo: consider: do we want this to behave differently from buffer_value? */
    buffer_value(buf, name);
}


/** ***************************************************************************
 * \brief Datatype for node types.
 */
typedef struct {
    base_type_t base;
    int nesting;
} type_t;

type_t nestedtype(base_type_t base, int nesting) {
    type_t type;
    type.base = base;
    type.nesting = nesting;
    return type;
}

type_t scalartype(base_type_t base) { return nestedtype(base, 0); }
type_t vectortype(base_type_t base) { return nestedtype(base, 1); }
type_t matrixtype(base_type_t base) { return nestedtype(base, 2); }

const type_t dicttype = {jmiLogNamed, 1};
const type_t toptype  = {jmiLogAny, 1};

static INLINE BOOL type_eq(type_t t1, type_t t2) { return t1.base == t2.base && t1.nesting == t2.nesting; }

/** \brief Output a type annotation, or nothing if type is scalartype(jmiLogAny). */
static void buffer_type(buf_t *buf, type_t type) {
    if (!type_eq(type, toptype)) {
        int k;
        buffer_char(buf, '{');
        for (k=0; k < type.nesting; k++) buffer_char(buf, '[');
        switch (type.base) {
            case jmiLogReal:   buffer(buf, "real");   break;
            case jmiLogInt:    buffer(buf, "int");    break;
            case jmiLogBool:   buffer(buf, "bool");   break;
            case jmiLogVref:   buffer(buf, "vref");   break;
            case jmiLogNamed:  buffer(buf, "named");  break;
            case jmiLogString: buffer(buf, "string"); break;
            case jmiLogAny:    buffer(buf, "any");    break;
        }
        for (k=0; k < type.nesting; k++) buffer_char(buf, ']');        
        buffer_char(buf, '}');
    }
}

static type_t list_peel_type(type_t type) {
    if (type.nesting > 0) return nestedtype(type.base, type.nesting-1);
    else return scalartype(jmiLogAny); /* includes fallback for lists where a scalar was expected */
}
static type_t named_peel_type(type_t type) {
    return scalartype(jmiLogAny); 
}


/** \brief Frame kind enum used by frame_t */
typedef enum { listFrame, namedFrame } kind_t;

/** ***************************************************************************
 * \brief Log frame used by jmi_log_t.
 */
typedef struct {
    kind_t kind;
    int id;
    jmi_log_category_t c;
    type_t type; /* type of child nodes */

    char closing;
    const char *name;
} frame_t;

static void logging_error(log_t *log, const char *msg);
static node_t merge_nodes(log_t *log, node_t outer, node_t inner) {
    node_t result;
    if (outer.inner_id != inner.outer_id) logging_error(log, "merge_nodes: nodes do not fit.");
    result.outer_id = outer.outer_id;
    result.inner_id = inner.inner_id;
    return result;
}


/** ***************************************************************************
 * \brief Structured logger
 */ 

struct jmi_log_t {
    jmi_t *jmi;
    buf_t buf;
    category_t c;

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
static node_t enter_named_(log_t *log, category_t c, const char *name);
static node_t enter_list_(log_t *log, type_t type);
static void leave_(log_t *log, node_t node);
static void log_value_(log_t *log, base_type_t type, const char *value);
static void log_indented_value_(log_t *log, base_type_t type, const char *value, int nspaces);
static void log_comment_(log_t *log, category_t c, const char *msg);
static void log_vref_(log_t *log, char t, int vref);
static void log_fmt_(log_t *log, category_t c, const char *fmt, va_list ap);


static void defer_comma(  log_t *log) { log->outstanding_comma = TRUE; }
static void cancel_commas(log_t *log) { log->outstanding_comma = FALSE; }

static void force_commas(log_t *log) {
    if (log->outstanding_comma) buffer(bufof(log), ", ");
    log->outstanding_comma = FALSE;
}

static INLINE int current_indent_of(log_t *log) { return log->topindex; }

static BOOL emitted_category(jmi_t *jmi, category_t category) {
    if((jmi->fmi != NULL) && !jmi->fmi->fmi_logging_on) return FALSE;
    switch (category) {
    case logError:   break;
    case logWarning: if(jmi->options.log_level < 3) return FALSE; break;
    case logInfo:    if(jmi->options.log_level < 4) return FALSE; break;
    }
    return TRUE;    
}

static void _emit(jmi_t *jmi, jmi_log_category_t category, char* message) {
    if (!emitted_category(jmi, category)) return;
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
        _emit(log->jmi, log->c, msg2);
        clear(buf);

        free(msg2);
    }
    log->indent = current_indent_of(log);
    log->lineindex = log->topindex;
}

/** \brief Set the current logging category; emit a log message if it was changed. */
void set_category(log_t *log, category_t c) {
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
    node.outer_id = log->frames[log->topindex-1].id;
    node.inner_id = topof(log)->id;
    return node;
}

/** \brief Push a new frame to the top of the stack, initialize and return it. */
static frame_t *push_frame(log_t *log, kind_t kind, category_t c, type_t type, char closing, const char *name) {
    frame_t *top;

    ++(log->topindex);
    if (log->topindex >= log->alloced_frames) {
        log->alloced_frames = 2*(log->topindex+1);
        log->frames = (frame_t *)realloc(log->frames, log->alloced_frames*sizeof(frame_t));
    }

    top          = log->frames + log->topindex;
    top->kind    = kind;
    top->id      = log->id_counter + log->topindex;
    top->c       = c;
    top->type    = type;
    top->closing = closing;
    top->name    = name;

    log->id_counter += 256;

    return top;
}

/** \brief Construct and push a list frame */
static INLINE frame_t *push_list(log_t *log, type_t type, char closing) { 
    return push_frame(log, listFrame, log->c, list_peel_type(type), closing, "");
}

/** \brief Construct and push a named frame */
static INLINE frame_t *push_named(log_t *log, category_t c, const char *name) { 
    type_t type = topof(log)->type;
    frame_t *frame = push_frame(log, namedFrame, c, named_peel_type(type), '?', name);
    return frame;
}


/** log_t constructor. */
static void init_log(log_t *log, jmi_t *jmi) {
    log->jmi = jmi;
    init_buffer(bufof(log));
    log->c = logInfo;
    log->alloced_frames = 32;
    log->frames = (frame_t *)malloc(log->alloced_frames*sizeof(frame_t));
    log->topindex = -1;
    log->id_counter = 0;
    log->outstanding_comma = FALSE;
    push_list(log, dicttype, '?');
    log->lineindex = 0;
    log->indent = current_indent_of(log);
}

static void delete_log(log_t *log) {
    delete_buffer(bufof(log));
    free(log->frames);
    free(log);
}


 /* Logging primitives */

/** \brief Enter a named frame. */
static node_t enter_named_(log_t *log, category_t c, const char *name) {
    push_named(log, c, name);
    set_category(log, c);
    buffer_ident(bufof(log), name);
    return node_from_top(log);
}

/** \brief Enter a list frame, with given type for the list. */
static node_t enter_list_(log_t *log, type_t type) {
    buf_t *buf = bufof(log);
    BOOL is_dict = type_eq(type, dicttype);
    BOOL suppress_type = is_dict || type_eq(topof(log)->type, type);
    frame_t *top = push_list(log, type, is_dict ? ')' : ']');

    set_category(log, top->c);
    if (!suppress_type) buffer_type(buf, type);
    buffer_char(buf, is_dict ? '(' : '[');
    return node_from_top(log);
}

/** \brief Leave the top frame. */
static void leave_frame_(log_t *log) {
    int indent;
    buf_t   *buf = bufof(log);
    frame_t *top = topof(log);
    BOOL same_line = log->lineindex < log->topindex;
    cancel_commas(log);

    if (can_pop(log)) --(log->topindex);
    else logging_error(log, "leave_frame_: frame stack empty; unable to pop.");
    indent = current_indent_of(log);
    if (log->indent > indent) log->indent = indent;
    if (top->kind == listFrame) {
        set_category(log, top->c);
        buffer_char(buf, top->closing);
        /* Note: relies on that topof(log) is the parent frame, which will name == "" if it's also a listFrame. */
        if (!same_line) buffer_ident(buf, topof(log)->name);
    }
    if (log->lineindex > log->topindex) log->lineindex = log->topindex;
    defer_comma(log);    
}

static void _leave_(log_t *log, node_t node) {
    int k;
    
    for (k=log->topindex; k >= 0; k--) {
        if (log->frames[k].id == node.outer_id) break;
    }
    if (k < 0) logging_error(log, "leave_: trying to leave into a node not on the stack.");
    else {
        while (can_pop(log)) {
            if (topof(log)->id == node.outer_id) break;
            leave_frame_(log);
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

static void pre_log_value_(log_t *log, base_type_t type) {
    buf_t   *buf = bufof(log);
    frame_t *top = topof(log);
    type_t t = scalartype(type);

    set_category(log, top->c);
    if (!type_eq(top->type, t)) buffer_type(buf, t);
    if (top->kind == namedFrame) buffer_char(buf, ':');
}

/** Log a value, annotated with type type if necessary. */
static void log_value_(log_t *log, base_type_t type, const char *value) {
    log_indented_value_(log, type, value, 0);
}

/** Log a value, annotated with type type if necessary, with nspaces spaces between the type and value. */
static void log_indented_value_(log_t *log, base_type_t type, const char *value, int nspaces) {    
    pre_log_value_(log, type);
    for (; nspaces > 0; nspaces--) buffer_char(bufof(log), ' ');
    buffer_value(bufof(log), value);
    defer_comma(log);
}

static void log_comment_(log_t *log, category_t c, const char *msg) {
    set_category(log, c);    
    buffer_comment(bufof(log), msg);
    buffer_char(bufof(log), ' ');
}

/** Log a value reference. */
static void log_vref_(log_t *log, char t, int vref) {
    buf_t *buf = bufof(log);
    char tmp[128];

    pre_log_value_(log, jmiLogVref);
    buffer_char(buf, '"'); buffer_raw_char(buf, '#');

    buffer_char(buf, t);
    sprintf(tmp, "%d", vref);
    buffer(buf, tmp);

    buffer_raw_char(buf, '#'); buffer_char(buf, '"'); 
    defer_comma(log);
}

static BOOL contains(const char *chars, char c) {
    while (*chars) if (*(chars++) == c) return TRUE;
    return FALSE;
}

static INLINE BOOL is_name_char(char c) { return isalnum(c) || c == '_'; }

static INLINE node_t enter_named_be_(log_t *log, category_t c, const char *begin, const char *end) {
    /* note: A bit of a hack to avoid extracting the name into a new string. */
    force_commas(log);
    while (begin != end) buffer_char(bufof(log), *(begin++));
    return enter_named_(log, c, "");
}

static void log_fmt_(log_t *log, category_t c, const char *fmt, va_list ap) {
    buf_t *buf = bufof(log);

    set_category(log, c);
    while (*fmt != 0) {
        char ch = *fmt;
        if (ch == '<') {
            /* Copy comments verbatim */
            force_commas(log);
            while ((*fmt != 0) && (*fmt != '>')) buffer_char(buf, *(fmt++));
            buffer(buf, "> "); 
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
                
                node = enter_named_be_(log, c, name_start, name_end);

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
                
                node = enter_named_be_(log, c, name_start, name_end);
                jmi_log_vref_(log, t, va_arg(ap, int));
                leave_(log, node);
            }
            else { logging_error(log, "jmi_log_fmt: expected '%' or '#'"); break; }

        }
        else if (isspace(ch) || ch == ',') ++fmt;
        else { logging_error(log, "jmi_log_fmt: unknown format character"); break; }
    }
}

static void logging_error(log_t *log, const char *msg) {
    char buf[1024];
    emit(log);
    sprintf(buf, "Logger error: %s", msg);
    log_comment_(log, logInfo, buf);
    emit(log);
}


 /* Helpers for user primitives */

node_t enter_(log_t *log, category_t c, const char *name, type_t type) {
    node_t node1 = enter_named_(log, c, name);
    node_t node2 = enter_list_(log, type);
    return merge_nodes(log, node1, node2);
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
node_t jmi_log_enter(log_t *log, category_t c, const char *name) {
    node_t node = jmi_log_enter_(log, c, name);
    emit(log); return node;
}
node_t jmi_log_enter_(log_t *log, category_t c, const char *name) {
    return enter_(log, c, name, dicttype);
}
node_t jmi_log_enter_vector_(log_t *log, category_t c, const char *name, base_type_t eltype) {
    return enter_(log, c, name, vectortype(eltype));
}

/** \brief Leave node, then emit. */
void jmi_log_leave(log_t *log, node_t node) { jmi_log_leave_(log, node); emit(log); }
void jmi_log_leave_(log_t *log, node_t node) { leave_(log, node); }

/** \brief Like jmi_log_leave, but may doesn't need to take innermost node. */
void jmi_log_unwind(log_t *log, node_t node) { _leave_(log, node); emit(log); }


 /* Functions that involve log_fmt */

void jmi_log_fmt_(log_t *log, category_t c, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    log_fmt_(log, c, fmt, ap);
    va_end(ap);
}

void jmi_log_fmt(log_t *log, category_t c, const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    log_fmt_(log, c, fmt, ap);
    va_end(ap);
    emit(log);
}

jmi_log_node_t jmi_log_enter_fmt(log_t *log, jmi_log_category_t c, const char *name, const char* fmt, ...) {
    va_list ap;
    node_t node = jmi_log_enter_(log, c, name); 

    va_start(ap, fmt);
    log_fmt_(log, c, fmt, ap);
    va_end(ap);
    
    emit(log);
    return node;    
}

void jmi_log_node(log_t *log, category_t c, const char *name, const char* fmt, ...) {
    va_list ap;
    node_t node = jmi_log_enter_(log, c, name); 

    va_start(ap, fmt);
    log_fmt_(log, c, fmt, ap);
    va_end(ap);
    
    leave_(log, node); emit(log);
}


 /* Subrow primitives */

void jmi_log_emit(log_t *log) { emit(log); }

void jmi_log_comment_(log_t *log, category_t c, const char *msg) { log_comment_(log, c, msg); }
void jmi_log_comment(log_t *log, category_t c, const char *msg) { jmi_log_comment_(log, c, msg); emit(log); }


void jmi_log_string_(log_t *log, const char *x) { log_value_(log, jmiLogString, x); }

void jmi_log_real_(log_t *log, jmi_real_t x) {
    char buf[128];
    char *rep;
    sprintf(buf, "%30.16E", x);

    /* Don't put spaces in the value; it will be quoted. */
    force_commas(log);
    rep = buf;
    while (*rep == ' ') ++rep;

    log_indented_value_(log, jmiLogReal, rep, rep-buf);
}

void jmi_log_int_(log_t *log, int x) {
    char buf[128];
    sprintf(buf, "%d", x);
    log_value_(log, jmiLogInt, buf);
}

void jmi_log_bool_(log_t *log, BOOL x) {
    char buf[128];
    sprintf(buf, "%d", x);
    log_value_(log, jmiLogBool, buf);
}

void jmi_log_vref_(log_t *log, char t, int vref) { log_vref_(log, t, vref); }


 /* Row primitives */

void jmi_log_reals(log_t *log, category_t c, const char *name, const jmi_real_t *data, int n) {
    int k;
    jmi_log_node_t node = jmi_log_enter_vector_(log, logInfo, name, jmiLogReal);
    for (k=0; k < n; k++) jmi_log_real_(log, data[k]);
    jmi_log_leave(log, node);
}

void jmi_log_ints(log_t *log, category_t c, const char *name, const int *data, int n) {
    int k;
    jmi_log_node_t node = jmi_log_enter_vector_(log, logInfo, name, jmiLogInt);
    for (k=0; k < n; k++) jmi_log_int_(log, data[k]);
    jmi_log_leave(log, node);
}

void jmi_log_bools(log_t *log, category_t c, const char *name, const BOOL *data, int n) {
    int k;
    jmi_log_node_t node = jmi_log_enter_vector_(log, logInfo, name, jmiLogBool);
    for (k=0; k < n; k++) jmi_log_bool_(log, data[k]);
    jmi_log_leave(log, node);
}

void jmi_log_vrefs(log_t *log, jmi_log_category_t c, const char *name, char t, const int *vrefs, int n) {
    int k;
    jmi_log_node_t node = jmi_log_enter_vector_(log, logInfo, name, jmiLogVref);
    for (k=0; k < n; k++) jmi_log_vref_(log, t, vrefs[k]);
    jmi_log_leave(log, node);    
}


void jmi_log_real_matrix(log_t *log, category_t c, const char *name, const jmi_real_t *data, int m, int n) {
    int k, l;
    node_t node = enter_(log, c, name, matrixtype(jmiLogReal));
    emit(log);
    for (l=0; l < m; l++) {
        node_t rownode = enter_list_(log, vectortype(jmiLogReal));
        for (k=0; k < n; k++) {
            jmi_log_real_(log, data[k*m + l]);
        }
        jmi_log_leave(log, rownode);
    }
    jmi_log_leave(log, node);
}


/* Catch invocations of old logging function; something seems to require it? */
void jmi_log(jmi_t *jmi, jmi_log_category_t category, const char* message) {
    jmi_log_node(jmi->log, category, "oldlog", "message: %s", message);
}
