#ifndef EXTERNALFUNCTIONS_H
#define EXTERNALFUNCTIONS_H

#include <stdlib.h>

double fRealScalar(double in);
int fIntegerScalar(int in);
int fEnumScalar(int in);
int fBooleanScalar(int in);
const char* fStringScalar(const char* in);
void fRealArray(double* in, size_t in_d1, double* out, size_t out_d1);
void fIntegerArray(int* in, size_t in_d1, int* out, size_t out_d1);
void fEnumArray(int* in, size_t in_d1, int* out, size_t out_d1);
void fBooleanArray(int* in, size_t in_d1, int* out, size_t out_d1);
void fStringArray(const char** in, size_t in_d1, const char** out, size_t out_d1);

#endif
