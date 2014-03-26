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
