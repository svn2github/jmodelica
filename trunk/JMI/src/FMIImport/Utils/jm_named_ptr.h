#ifndef JM_NAMED_PTR_H
#define JM_NAMED_PTR_H

#include "jm_vector.h"
#include "jm_callbacks.h"

typedef struct jm_named_ptr jm_named_ptr;

struct jm_named_ptr {
    jm_voidp ptr;
    jm_string name;
};

/*
The function jm_named_alloc is intended for types defined as:
struct T {
    < some data fields>
    char name[1];
}
It allocates memory for the object and the name string and sets pointer to it packed together with the name pointer.
The "name" is copied into the allocated memory.
*/
jm_named_ptr jm_named_alloc(jm_string name, size_t size, size_t nameoffset, jm_callbacks* c);

jm_named_ptr jm_named_alloc_v(jm_vector(char)* name, size_t size, size_t nameoffset, jm_callbacks* c);

/* jm_named_free frees the memory allocated for the object pointed by jm_named_ptr */
static void jm_named_free(jm_named_ptr np, jm_callbacks* c) { c->free(np.ptr); }

jm_vector_declare_template(jm_named_ptr)

#define jm_diff_named(a, b) strcmp(a.name,b.name)

jm_define_comp_f(jm_compare_named, jm_named_ptr, jm_diff_named)

/* jm_named_vector_free_data releases the data allocated by the items
  in a vector and then clears the memory used by the vector as well.
  This should be used for vectors initialized with vector_init.
*/
static void jm_named_vector_free_data(jm_vector(jm_named_ptr)* v) {
    jm_vector_foreach_c(jm_named_ptr)(v, (void (*)(jm_named_ptr, void*))jm_named_free,v->callbacks);
    jm_vector_free_data(jm_named_ptr)(v);
}

/* jm_named_vector_free releases the data allocated by the items
  in a vector and then clears the memory used by the vector as well.
  This should be used for vectors created with vector_alloc.
*/
static void jm_named_vector_free(jm_vector(jm_named_ptr)* v) {
    jm_vector_foreach_c(jm_named_ptr)(v,(void (*)(jm_named_ptr, void*))jm_named_free,v->callbacks);
    jm_vector_free(jm_named_ptr)(v);
}

/* JM_NAMED_PTR_H */
#endif
