#include "jm_vector.h"

#define JM_TEMPLATE_INSTANCE_TYPE char
#include "jm_vector_template.h"

#undef JM_TEMPLATE_INSTANCE_TYPE
#define JM_TEMPLATE_INSTANCE_TYPE int
#include "jm_vector_template.h"

#undef JM_TEMPLATE_INSTANCE_TYPE
#define JM_TEMPLATE_INSTANCE_TYPE double
#include "jm_vector_template.h"

#undef JM_TEMPLATE_INSTANCE_TYPE
#define JM_TEMPLATE_INSTANCE_TYPE size_t
#include "jm_vector_template.h"

#undef JM_TEMPLATE_INSTANCE_TYPE
/* #undef JM_COMPAR_OP
#define JM_COMPAR_OP(f,s) ((char*)f -(char*)s) */
#define JM_TEMPLATE_INSTANCE_TYPE jm_voidp
#include "jm_vector_template.h"

#undef JM_TEMPLATE_INSTANCE_TYPE
#undef JM_COMPAR_OP
#define JM_TEMPLATE_INSTANCE_TYPE jm_string
#define JM_COMPAR_OP(f,s) strcmp(f,s)
#include "jm_vector_template.h"
