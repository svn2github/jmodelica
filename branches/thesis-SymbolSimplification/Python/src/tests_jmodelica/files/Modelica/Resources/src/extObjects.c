#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ModelicaUtilities.h"

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
    fprintf(stderr, "Destructing external object for file '%s'.\n", (char*)o);

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
    Obj1_t* o1;
    Obj2_t** o2;
} Obj3_t;
void my_constructor3(void* o1, void** o2, void** o3) {
    Obj3_t* res = malloc(sizeof(Obj3_t));
    res->o1 = (Obj1_t*)o1;
    res->o2 = (Obj2_t**)o2;
    ModelicaFormatMessage("%s", "O3 constructed");
    ModelicaFormatMessage("%s", "Testing\n\r\n some line breaks\n\r\n");
    *o3 = res;
}
double use3(void* o3) {
    Obj3_t* o = (Obj3_t*) o3;
    return use1((void*)o->o1) + use2((void*)o->o2[0]) + use2((void*)o->o2[1]);
}


typedef struct inc_int {
    int x;
} inc_int_t;
void* inc_int_con(int x) {
    inc_int_t* res;
    ModelicaMessage("Constructor message");
    res = malloc(sizeof(inc_int_t)); res->x = x;
    return res;
}
void inc_int_decon(void* o1) {
    free(o1);
}
int inc_int_use(void* o1) {
    inc_int_t* eo = (inc_int_t*) o1;
    eo->x += 1;
    return eo->x;
}
int inc_int_use2(void* o1) {
    return inc_int_use(o1);
}

void* crash_con(int x) {
    inc_int_t* res;
    exit(1);
    res = malloc(sizeof(inc_int_t)); res->x = x;
    return res;
}
void crash_decon(void* o1) {
    exit(1);
    free(o1);
}
int crash_use(void* o1) {
    inc_int_t* eo = (inc_int_t*) o1;
    eo->x += 1;
    exit(1);
    return eo->x;
}

void* error_con(int x) {
    inc_int_t* res;
    ModelicaError("Constructor error message");
    res = malloc(sizeof(inc_int_t)); res->x = x;
    return res;
}
void error_decon(void* o1) {
    ModelicaError("Deconstructor error message");
    free(o1);
}
int error_use(void* o1) {
    inc_int_t* eo = (inc_int_t*) o1;
    ModelicaError("Use error message");
    eo->x += 1;
    return eo->x;
}


