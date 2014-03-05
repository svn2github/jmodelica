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
	return malloc(size);
}

$ECE_external_includes$
 
/* Manual debugging */
#define DEBUG 0
#define DBGP(x) if (DEBUG) { printf(x); fflush(stdout);}

/* Format specifier when printing jmi_ad_var_t */
#define jmi_real_format "%.16f"

/* Used record definitions */
$ECE_record_definitions$

/* Parses ND dimensions into dimension buffer */
#define parseArrayDims(ND) \
    for (di = 0; di < ND; di++) { scanf("%d",&d[di]); }

/* Parse/print basic types */
#define parseReal(X) \
    DBGP("Parse number: "); \
    scanf("%s",buff); \
    X = strtod(buff, 0); \

#define printReal(X) \
    printf(jmi_real_format, X); \
    printf("\n"); \
    fflush(stdout); \
    
#define parseString(STR) \
    parseArrayDims(1); \
    getchar(); \
    STR = malloc(sizeof(char)*(d[0]+1)); \
    DBGP("Parse string: "); \
    for (si = 0; si < d[0]; si++) STR[si] = getchar(); \
    STR[d[0]] = '\0';
    
#define printString(STR) \
    printf("%d\n%s\n", strlen(STR), STR); \
    fflush(stdout); \

#define parseInteger(X) parseReal(X)
#define parseBoolean(X) parseReal(X)
#define printInteger(X) printReal(X)
#define printBoolean(X) printReal(X)
#define parse(TYPE, X) parse##TYPE(X)
#define print(TYPE, X) print##TYPE(X)

/* Parse/print arrays */
#define parseArray(TYPE,ARR) for (vi = 1; vi <= ARR->num_elems; vi++) { parse##TYPE(jmi_array_ref_1(ARR,vi)); }
#define printArray(TYPE,ARR) for (vi = 1; vi <= ARR->num_elems; vi++) { print##TYPE(jmi_array_val_1(ARR,vi)); }

/* Main */
int main(int argc, const char* argv[])
{

	/* Char buffer when reading jmi_ad_var_t. This is necessary
	   since "%lf" is not allowed in c89. */
	char buff[32];

	/* Size buffer for reading array dimensions */
	size_t d[25];
	
	/* Indices for parsing/printing vars, dimensions, and strings */
    size_t vi,di,si;
	
    JMI_DYNAMIC_INIT()
    
    $ECE_main$
    
    JMI_DYNAMIC_FREE()
    return 0;
}

