#include "arrayFunctions.h"

double sumArrayElements(double* a, size_t len)
{
    double sum = 0.0;
    int i;
    for (i = 0; i < len; i++) {
        sum = sum + a[i];
    }
    
    return sum;
}

void transposeMatrix(double* a, size_t a_rows, size_t a_cols, double* b, size_t b_rows, size_t b_cols)
{
    int i;
    int j;
    int a_index = 0;
    
    for (i = 0; i < a_rows; i++) {
        for (j = 0; j < a_cols; j++) {
            b[j * b_cols + i] = a[a_index];
            a_index++;
        }
    }
}

void extFunc1(double m, double* a, size_t a1, size_t a2, size_t a3, int* b, size_t b1, size_t b2, size_t b3, double* c, size_t c1, size_t c2, double* sum, 
    double* o, size_t o1, size_t o2, size_t o3)
{
    size_t i1,i2,i3,t;
    *sum = 0;
    for (i1 = 0; i1 < a1; i1++) {
        for (i2 = 0; i2 < a2; i2++) {
            t = ((i1*a1)+i2)*a2;
            for (i3 = 0; i3 < a3; i3++) {
                o[t + i3] = m*a[t + i3] / b[t + i3];
                if (c[t])
                    *sum += o[t + i3];
            }
        }
    }
}

double whileTrue(double a)
{
    while (1);
    return a;
}
