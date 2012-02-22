/*
    Copyright (C) 2012 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef JM_STRING_SET_H
#define JM_STRING_SET_H

#include <string.h>

#include "jm_types.h"
#include "jm_vector.h"
#ifdef __cplusplus
extern "C" {
#endif

typedef jm_vector(jm_string) jm_string_set;

static jm_string jm_string_set_find(jm_string_set* s, jm_string str) {
    jm_string* found = jm_vector_find(jm_string)(s,&str,jm_compare_string);
    if(found) return *found;
    return 0;
}

/*
// jm_set_put puts an element in the set if it is not there yet.
// Returns a pointer to the inserted (or found) element or zero pointer if failed.
// T* jm_set_put_item(jm_set(T)* a, T item)
// T* jm_set_put_itemp(jm_set(T)* a, T& itemp)
*/
static jm_string jm_string_set_put(jm_string_set* s, jm_string str) {
    jm_string found = jm_string_set_find(s, str);
    if(found) return found;
    {
        char* newstr = 0;
        size_t len = strlen(str) + 1;
        jm_string* pnewstr = jm_vector_push_back(jm_string)(s, newstr);
        if(pnewstr) *pnewstr = newstr = s->callbacks->malloc(len);
        if(!pnewstr || !newstr) return 0;
        memcpy(newstr, str, len);
        jm_vector_qsort(jm_string)(s, jm_compare_string);
        found = newstr;
    }
    return found;
}

#ifdef __cplusplus
}
#endif

#endif /* JM_STRING_SET_H */
