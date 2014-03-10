/*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "jmi.h"

/* Modelica utility functions */
char* ModelicaAllocateString(size_t size)
{
	return calloc((size+1),sizeof(char));
}

$ECE_external_includes$
 
/* Manual debugging */
#define DEBUG 0
#define DBGP(x) if (DEBUG) { printf(x); fflush(stdout);}

/* Format specifier when printing jmi_ad_var_t */
#define jmi_real_format "%.16f"

/* Used record definitions */
$ECE_record_definitions$

/* Parses ND dimensions into dimension buffer d*/
#define parseArrayDims(ND) \
    for (di = 0; di < ND; di++) { scanf("%d",&d[di]); }

/* Parse/print basic types */
double parseReal() {
    /* Char buffer when reading jmi_ad_var_t. This is necessary
       since "%lf" is not allowed in c89. */
    char buff[32];
    DBGP("Parse number: "); 
    scanf("%s",buff);
    return strtod(buff, 0);
}

void printReal(double x) {
    printf(jmi_real_format, x); \
    printf("\n"); \
    fflush(stdout); \
}

char* parseString() {
    int d[1];
    char* str;
    size_t si,di;
    parseArrayDims(1);
    getchar();
    str = ModelicaAllocateString(d[0]);
    DBGP("Parse string: ");
    for (si = 0; si < d[0]; si++) str[si] = getchar();
    str[d[0]] = '\0';
    return str;
}

void printString(char* str) {
    printf("%d\n%s\n", strlen(str), str);
    fflush(stdout);
}

#define parseInteger()  parseReal()
#define parseBoolean()  parseInteger()
#define parseEnum()     parseInteger()
#define printInteger(X) printReal(X)
#define printBoolean(X) printInteger(X)
#define printEnum(X)    printInteger(X)
#define parse(TYPE, X)  X = parse##TYPE()
#define print(TYPE, X)  print##TYPE(X)

/* Parse/print arrays */
#define parseArray(TYPE,ARR) for (vi = 1; vi <= ARR->num_elems; vi++) { parse(TYPE, jmi_array_ref_1(ARR,vi)); }
#define printArray(TYPE,ARR) for (vi = 1; vi <= ARR->num_elems; vi++) { print(TYPE, jmi_array_val_1(ARR,vi)); }

/* Main */
int main(int argc, const char* argv[])
{
    /* Size buffer for reading array dimensions */
    int d[25];
    
    /* Indices for parsing/printing vars, dimensions */
    size_t vi,di;
    
    JMI_DYNAMIC_INIT()
    
    $ECE_main$
    
    JMI_DYNAMIC_FREE()
    return 0;
}

