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
#include "jmi.h"

$ECE_external_includes$
 
#define DEBUG 0
#define DBGP(x) if (DEBUG) { printf(x); fflush(stdout);}

/* Format specifier when printing jmi_ad_var_t */
#define jmi_real_format "%.16f"

/* Char buffer when reading jmi_ad_var_t. This is necessary
   since "%lf" is not allowed in c89. */
char buff[32];

/* Used record definitions */
$ECE_record_definitions$

/* Dimensions */
int parseArrayDims(int nd, size_t* d)
{
    int i;
    int ne = 1;
    for (i = 0; i < nd; i++) {
        scanf("%d",&d[i]);
        ne = ne * d[i];
    }
    return ne;
}
 
/* Basic types */
#define parseReal(X) \
    DBGP("Parse number: "); \
    scanf("%s",buff); \
    X = strtod(buff, 0); \

#define printReal(X) \
    printf(jmi_real_format, X); \
    printf("\n"); \
    fflush(stdout); \
    
#define parseString(STR) \
    parseArrayDims(1,&d); \
    str = malloc(sizeof(char)*(d[0]+1)); \
    DBGP("Parse string: "); \
    for (i = 0; i < d[0]; i++) str[i] = getchar(); \
    str[d[0]] = '\0';
    
#define printString(STR) \
    printf("%d %s\n", strlen(*str), str); \
    fflush(stdout); \

#define parseInteger(X) parseReal(X)
#define parseBoolean(X) parseReal(X)
#define printInteger(X) printReal(X)
#define printBoolean(X) printReal(X)
#define parse(TYPE, X) parse##TYPE(X)
#define print(TYPE, X) print##TYPE(X)

/* Arrays */
#define parseArray(TYPE,ARR) for (i = 1; i <= ARR->num_elems; i++) { parse##TYPE(jmi_array_ref_1(ARR,i)); }
#define printArray(TYPE,ARR) for (i = 1; i <= ARR->num_elems; i++) { print##TYPE(jmi_array_val_1(ARR,i)); }

/* Parse, run, print */
int main(int argc, const char* argv[])
{
    size_t i;
    JMI_DYNAMIC_INIT()
    
    $ECE_main$
    
    JMI_DYNAMIC_FREE()
    return 0;
}

