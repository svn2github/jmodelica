#include "externalFunctionsC.h"

#include <string.h>
#include <ModelicaUtilities.h>


double fRealScalar(double in)
{
	return in*3.14;
}

void fRealArray(double* in, size_t in_d1, double* out, size_t out_d1)
{
	size_t i;
	for (i = 0; i < in_d1; i++)
		out[i] = in[in_d1 - 1 - i];
}

int fIntegerScalar(int in)
{
	return in*3;
}

void fIntegerArray(int* in, size_t in_d1, int* out, size_t out_d1)
{
	size_t i;
	for (i = 0; i < in_d1; i++)
		out[i] = in[in_d1 - 1 - i];
}

int fBooleanScalar(int in)
{
	return !in;
}

void fBooleanArray(int* in, size_t in_d1, int* out, size_t out_d1)
{
	size_t i;
	for (i = 0; i < in_d1; i++)
		out[i] = !in[i];
}

const char* fStringScalar(const char* in)
{
	char* c = ModelicaAllocateString(3);
	c[0] = in[3];
	c[1] = in[2];
	c[2] = in[1];
	return c;
}

void fStringArray(const char** in, size_t in_d1, const char** out, size_t out_d1)
{
	size_t i;
	char* temp[in_d1];
	
	for (i = 0; i < in_d1; i++)
		temp[i] = ModelicaAllocateString(strlen(in[i]));
	for (i = 0; i < in_d1; i++)
		strcpy(temp[i], in[i]);
	for (i = 1; i < in_d1; i++)
		temp[i][1] = temp[0][1];
	for (i = 0; i < in_d1; i++)
		out[i] = temp[i];
}

int fEnumScalar(int in)
{
	return 2;
}

void fEnumArray(int* in, size_t in_d1, int* out, size_t out_d1)
{
	size_t i;
	for (i = 0; i < in_d1; i++)
		out[i] = in[in_d1 - 1 - i];
}