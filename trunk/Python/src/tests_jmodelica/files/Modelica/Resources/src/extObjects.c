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

typedef struct {
    const char* s;
    double x;
} Obj2_t;

void my_constructor2(double x, void** o2, const char* s) {
    Obj2_t* res = malloc(sizeof(Obj2_t));
    res->s = s;
    res->x = x;
    *o2 = res;
}

void destructor(void* o2) {
    free(o2);
}

double use(void* p1) {
    ModelicaFormatMessage("String mess: %s", ((Obj2_t*)p1)->s);
    return ((Obj2_t*)p1)->x;
}
