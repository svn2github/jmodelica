set(SOURCE
 jm_callbacks.c
 jm_templates_inst.c
 jm_named_ptr.c
)

set(HEADERS
  jm_callbacks.h
  jm_vector.h
  jm_vector_template.h
  jm_stack.h
  jm_types.h
  jm_named_ptr.h
  jm_string_set.h
)

add_library(jm_utils ${SOURCE} ${HEADERS})
