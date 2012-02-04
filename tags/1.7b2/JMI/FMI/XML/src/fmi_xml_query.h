#ifndef FMI_XML_QUERY_H
#define FMI_XML_QUERY_H

#include <jm_vector.h>
#include <jm_stack.h>

/* Query below has the following syntax:
  query =   elementary_query
                  | '(' query ')'
          | query '|' query
                  | query '&' query
                  | '!' query
  elementary_query =  "name" '=' <regexp>
                    | "quantity" '=' <string>
                    | "type" '=' <string>
                    | "unit" '=' <string>
                    | "displayUnit" '=' <string>
                    | "fixed" '=' ("true"|"false")
                    | "hasStart" '='  ("true"|"false")
                    | "alias" '=' ['-']<variable name> (negative value for negated-aliases)
                    | "alias" '=' ['-']<value reference> (negative value for negated-aliases)

Example: "name='a.*' & fixed=false"
*/

typedef enum fmi_xml_q_terminal_enu {
    enuLParant,
    enuRParant,
    enuAndOp,
    enuOrOp,
    enuQName,
    enuQBaseType,
    enuQUnit,
    enuTrue,
    enuFalse
} fmi_xml_q_terminal_enu;

typedef struct fmi_xml_q_terminal {
    fmi_xml_q_terminal_enu kind;
    jm_vector(char) data;
    fmi_xml_q_terminal* next;
} fmi_xml_q_terminal;

typedef struct fmi_xml_q_expression {
    jm_vector(jm_voidp) expression;

    jm_vector(jm_voidp) stack;

    fmi_xml_q_terminal termFalse, termTrue;
    fmi_xml_q_terminal * list;
} fmi_xml_q_expression;

int pattern2regexp(const char* pattern, jm_vector(char)* re) {
    size_t plen = strlen(pattern), i;
    if(jm_vector_reserve_char(re, plen * 2 + 3) < plen) return -1;
    jm_vector_resize_char(re, 0);
    jm_vector_push_back_char(re, '^');
    for(i=0; i < plen; i++) {
        char cur = pattern[i];
        switch(cur) {
        case '*':
            jm_vector_push_back_char('.');
            jm_vector_push_back_char('*');
            break;
        case '?':
            jm_vector_push_back_char('.');
            break;
        default:
            jm_vector_push_back_char('\\');
            jm_vector_push_back_char(cur);
        }
    }
    jm_vector_push_back_char(re, '$');
    jm_vector_push_back_char(re, 0);
    return 0;
}


int fmi_xml_filter_variable(fmiVariable* var, fmi_xml_q_expression* exp) {
    size_t cur, len = jm_vector_get_size_char(exp->expression);
    for(cur = 0; cur < len; cur++) {
        fmi_xml_q_terminal * term = jm_vector_get_item(jm_voidp)(exp->expression);
        fmi_xml_q_terminal *argL, *argR;
        size_t curlen = jm_vector_get_size(jm_voidp)(stack);

        argL = (curlen > 0) ? jm_vector_get_item(jm_voidp)(stack,curlen -1):0;
        argR = (curlen > 1) ? jm_vector_get_item(jm_voidp)(stack,curlen -2):0;

        switch(term -> kind) {
        case enuAndOp:
            assert(argL && argR);
            jm_vector_resize(jm_voidp)(stack, curlen -2);
            if((argL->kind == enuFalse) || (argR->kind == enuFalse))
                jm_vector_push_back(jm_voidp)(stack, &exp->termFalse);
            else {
                jm_vector_push_back(jm_voidp)(stack, fmi_xml_evaluate_terminal(argL) && fmi_xml_evaluate_terminal(argR));
            }
            break;
        case enuOrOp:
            assert(argL && argR);
            jm_vector_resize(jm_voidp)(stack, curlen -2);
            if((argL->kind == enuTrue) || (argR->kind == enuTrue))
                jm_vector_push_back(jm_voidp)(stack, &exp->termTrue);
            else {
                jm_vector_push_back(jm_voidp)(stack, fmi_xml_evaluate_terminal(argL) || fmi_xml_evaluate_terminal(argR));
            }
            break;
        default:
            jm_vector_push_back(jm_voidp)(stack, term);
        }
    }
    assert(jm_vector_get_size(jm_voidp)(stack) == 1);
    fmi_xml_q_terminal * term = jm_vector_get_item(jm_voidp)(stack,0);
    if(term->kind == enuFalse) return 0;
    return 1;
}

fmi_xml_q_expression* fmi_xml_alloc_expression(jm_string query) {

}

static void fmi_xml_q_skip_space(char** cur) {
    char* curChP = *cur;
    char curCh;
    if(!curChP) return;
    curCh = *curChP;
    while(curCh || (curCh == ' ') || (curCh == '\t')) {
        curChP++; curCh = *curChP;
    }
    *cur = curChP;
}

fmi_xml_q_terminal* fmi_xml_get_terminal(jm_string str,size_t *offset) {
    fmi_xml_q_terminal* term = fmi_xml_alloc_term();
    if(!term) return 0;
    char* cur = (char*)str;
    fmi_xml_q_skip_space(&cur);
    switch(*cur) {
    case '(':
    case ')':
    case '&':
    case '|':
    case 0:
    default:
        fmi_xml_parse_elementary(cur, term);
    }

    return term;
}

int fmi_xml_parse_query(jm_string query, fmi_xml_q_expression* exp) {
    size_t qlen = strlen(query), curCh = 0, offset = 0;
    while(cur < qlen) {
        fmi_xml_q_terminal* term = fmi_xml_get_terminal(&query[curCh], &offset);
        size_t stacklen = jm_vector_get_size(jm_voidp)(exp->stack);
        fmi_xml_q_terminal* stackTop =  stacklen? jm_vector_get_item(jm_voidp)(exp->stack,stacklen -1):0;
        size_t explen = jm_vector_get_size(jm_voidp)(&exp->expression);
        fmi_xml_q_terminal* expTop =  explen? jm_vector_get_item(jm_voidp)(&exp->expression,explen -1):0;

        if(!term) return -1;

        switch(term -> kind) {
        case enuLParant:
            jm_vector_push_back(jm_voidp)(&exp->stack, term);
            break;
        case enuRParant:
            while(stackTop && (stackTop->kind != enuLParant)) {
                jm_vector_push_back(jm_voidp)(&exp->expression, stackTop);
                jm_vector_resize(jm_voidp)(exp->stack, stacklen -1);
                stacklen--;
                stackTop =  stacklen? jm_vector_get_item(jm_voidp)(exp->stack,stacklen -1):0;
            }
            if(!stackTop) return -1;
            jm_vector_resize(jm_voidp)(&exp->stack, stacklen -1);
            break;

        case enuAndOp:
            if(!expTop) return -1;
            if(stackTop && (stackTop->kind == enuAndOp))
                    jm_vector_push_back(jm_voidp)(&exp->expression, term);
                else
                    jm_vector_push_back(jm_voidp)(&exp->stack, term);
            break;
        case enuOrOp:
            if(!expTop) return -1;
            while(stackTop && ((stackTop->kind == enuAndOp)||(stackTop->kind == enuOrOp))) {
                jm_vector_push_back(jm_voidp)(&exp->expression, stackTop);
                jm_vector_resize(jm_voidp)(exp->stack, stacklen -1);
                stacklen--;
                stackTop =  stacklen? jm_vector_get_item(jm_voidp)(exp->stack,stacklen -1):0;
            }
            jm_vector_push_back(jm_voidp)(&exp->stack, term);
            break;
        default:
            jm_vector_push_back(jm_voidp)(&exp->expression, term);
        }
    }
    return 0;
}

#endif // FMI_XML_QUERY_H
