#ifndef _EXT_OBJECTS_H_
#define _EXT_OBJECTS_H_

void* constructor_string(const char* str);

double constant_extobj_func(void* o);

void destructor_string_create_file(void* o);


typedef struct {
    const char* s;
    double x;
} Obj2_t;

void my_constructor2(double x, void** o2, const char* s);
void destructor(void* o2);
double use(void* p1);

#endif
