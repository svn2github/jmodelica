#include <stdio.h>
#include <string.h>

void* constructor_string(const char* str) {
    void* res = malloc(strlen(str) + 1);
    strcpy(res, str);
    fprintf(stderr, "Constructing external object for file '%s'.\n", str);
    return res;
}

double constant_extobj_func(void* o) {
    return 1.0;
}

void destructor_string_create_file(void* o) {
    FILE* f = fopen((char*) o, "w");
    fprintf(f, "Test file.");
    fclose(f);
    fprintf(stderr, "Destructing external object for file '%s'.\n", o);

    free(o);
}

void destructor(void* o) {
    free(o);
}
typedef struct {
    double x;
    const char* s;
} Obj1_t;
void* my_constructor1(double x, int y, int b, const char* s) {
    Obj1_t* res = malloc(sizeof(Obj1_t));
    res->s = s;
    res->x = b ? x + y : -1;
    return res;
}
double use1(void* o1) {
    ModelicaFormatMessage("String mess: %s", ((Obj1_t*)o1)->s);
    return ((Obj1_t*)o1)->x;
}

typedef struct {
    double* x;
    int* y;
    int* b;
    const char** s;
} Obj2_t;
void my_constructor2(double* x, int* y, void** o2, int* b, const char** s) {
    Obj2_t* res = malloc(sizeof(Obj2_t));
    res->x = x;
    res->y = y;
    res->b = b;
    res->s = s;
    *o2 = res;
}
double use2(void* o2) {
    Obj2_t* o = (Obj2_t*) o2;
    return o->x[0] + o->x[1] + o->y[0] + o->y[1];
}

typedef struct {
    Obj2_t** o2;
} Obj3_t;
void my_constructor3(void** o2, void** o3) {
    Obj3_t* res = malloc(sizeof(Obj3_t));
    res->o2 = (Obj2_t**)o2;
    *o3 = res;
}
double use3(void* o3) {
    Obj3_t* o = (Obj3_t*) o3;
    return use2((void*)o->o2[0]) + use2((void*)o->o2[1]);
}