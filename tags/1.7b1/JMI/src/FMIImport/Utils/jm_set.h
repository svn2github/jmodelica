#ifndef JM_STRING_SET_H
#define JM_STRING_SET_H

#include "jm_types.h"
#include "jm_vector.h"

typedef jm_vector(jm_string) jm_string_set;

/*
// jm_set_put puts an element in the set if it is not there yet.
// Returns a pointer to the inserted (or found) element or zero pointer if failed.
// T* jm_set_put_item(jm_set(T)* a, T item)
// T* jm_set_put_itemp(jm_set(T)* a, T& itemp)
*/
static jm_string jm_string_set_put(jm_string_set* s. jm_string* str) {
    jm_string found = jm_string_set_find(T)(a, str);
    if(found) return found;
    {
        jm_string *pnewstr = jm_vector_push_back(jm_string)(s, found);
        if(pnewstr) *pnewstr = found = s->
    if(!found) return ERROR;
    return
}

#define jm_set_declare_template(T, COMPARE_F, ERROR)		\
T jm_set_find_item(T)(jm_vector(T)* a, T* item, jm_compare_ft f) \
    T* jm_set_put_item(jm_set(T)* a, T item) {
}

jm_set_declare_template(char)
jm_set_declare_template(int)
jm_set_declare_template(double)
jm_set_declare_template(jm_voidp)
jm_set_declare_template(size_t)


#endif /* JM_SET_H */
