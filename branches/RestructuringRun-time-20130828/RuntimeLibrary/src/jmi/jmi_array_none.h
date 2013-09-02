 /*
    Copyright (C) 2009 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation, or optionally, under the terms of the
    Common Public License version 1.0 as published by IBM.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License, or the Common Public License, for more details.

    You should have received copies of the GNU General Public License
    and the Common Public License along with this program.  If not,
    see <http://www.gnu.org/licenses/> or
    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/



/** \file jmi_array_none.h
 *  \brief Handling of arrays in the JMI interface, version without AD.
 *
 *  Note that arrays are only used in functions at this point.
 */

#ifndef _JMI_ARRAY_NONE_H
#define _JMI_ARRAY_NONE_H

#include "jmi_array_common.h"

#include <stdlib.h>

typedef struct jmi_array_t jmi_array_t;
struct jmi_array_t {
    int*        size;
    int         num_dims;
    int         num_elems;
    jmi_real_t* var;
};

typedef struct jmi_int_array_t jmi_int_array_t;
struct jmi_int_array_t {
    int*        size;
    int         num_dims;
    int         num_elems;
    jmi_int_t*  var;
};

/* Linked list for saving pointers to be freed at return */
typedef struct _jmi_dynamic_list jmi_dynamic_list;
struct _jmi_dynamic_list {
    void* data;
    jmi_dynamic_list* next;
};

/* Record array type declaration macro */
#define JMI_RECORD_ARRAY_TYPE(rec, arr) \
    typedef struct _##arr {\
        int* size;\
        int  num_dims;\
        int  num_elems;\
        rec* var;\
    } arr;

/* Array creation macros */
#define JMI_ARRAY_STATIC(name, ne, nd) \
    JMI_RECORD_ARRAY_STATIC(jmi_real_t, jmi_array_t, name, ne, nd)

#define JMI_INT_ARRAY_STATIC(name, ne, nd) \
    JMI_RECORD_ARRAY_STATIC(jmi_int_t, jmi_int_array_t, name, ne, nd)

/* Record array creation macro */
#define JMI_RECORD_ARRAY_STATIC(type, arr, name, ne, nd) \
    int name##_size[nd];\
    type name##_var[(ne == 0) ? 1 : ne];\
    arr name##_obj = { 0, (int) (nd), (int) (ne), 0 };\
    arr* name = &name##_obj;

/* Dynamic array creation macro */
#define JMI_ARRAY_DYNAMIC(name, nd) \
    JMI_RECORD_ARRAY_DYNAMIC(jmi_real_t, jmi_array_t, name, nd)

#define JMI_INT_ARRAY_DYNAMIC(name, nd) \
    JMI_RECORD_ARRAY_DYNAMIC(jmi_int_t, jmi_int_array_t, name, nd)

/* Dynamic record array creation macro */
#define JMI_RECORD_ARRAY_DYNAMIC(type, arr, name, nd) \
    int name##_size[nd];\
    arr name##_obj = { 0, (int) (nd), 0, 0 };\
    arr* name = &name##_obj;

/* Array initialization macros */
#define JMI_ARRAY_STATIC_INIT_1(name, d1) \
    name##_obj.size = name##_size;\
    name##_obj.var = name##_var;\
    name##_size[0] = (int) (d1);
#define JMI_ARRAY_STATIC_INIT_2(name, d1, d2) \
    JMI_ARRAY_STATIC_INIT_1(name, d1)\
    name##_size[1] = (int) (d2);
#define JMI_ARRAY_STATIC_INIT_3(name, d1, d2, d3) \
    JMI_ARRAY_STATIC_INIT_2(name, d1, d2)\
    name##_size[2] = (int) (d3);
#define JMI_ARRAY_STATIC_INIT_4(name, d1, d2, d3, d4) \
    JMI_ARRAY_STATIC_INIT_3(name, d1, d2, d3)\
    name##_size[3] = (int) (d4);
#define JMI_ARRAY_STATIC_INIT_5(name, d1, d2, d3, d4, d5) \
    JMI_ARRAY_STATIC_INIT_4(name, d1, d2, d3, d4)\
    name##_size[4] = (int) (d5);
#define JMI_ARRAY_STATIC_INIT_6(name, d1, d2, d3, d4, d5, d6) \
    JMI_ARRAY_STATIC_INIT_5(name, d1, d2, d3, d4, d5)\
    name##_size[5] = (int) (d6);
#define JMI_ARRAY_STATIC_INIT_7(name, d1, d2, d3, d4, d5, d6, d7) \
    JMI_ARRAY_STATIC_INIT_6(name, d1, d2, d3, d4, d5, d6)\
    name##_size[6] = (int) (d7);
#define JMI_ARRAY_STATIC_INIT_8(name, d1, d2, d3, d4, d5, d6, d7, d8) \
    JMI_ARRAY_STATIC_INIT_7(name, d1, d2, d3, d4, d5, d6, d7)\
    name##_size[7] = (int) (d8);
#define JMI_ARRAY_STATIC_INIT_9(name, d1, d2, d3, d4, d5, d6, d7, d8, d9) \
    JMI_ARRAY_STATIC_INIT_8(name, d1, d2, d3, d4, d5, d6, d7, d8)\
    name##_size[8] = (int) (d9);
#define JMI_ARRAY_STATIC_INIT_10(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10) \
    JMI_ARRAY_STATIC_INIT_9(name, d1, d2, d3, d4, d5, d6, d7, d8, d9)\
    name##_size[9] = (int) (d10);
#define JMI_ARRAY_STATIC_INIT_11(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11) \
    JMI_ARRAY_STATIC_INIT_10(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10)\
    name##_size[10] = (int) (d11);
#define JMI_ARRAY_STATIC_INIT_12(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12) \
    JMI_ARRAY_STATIC_INIT_11(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11)\
    name##_size[11] = (int) (d12);
#define JMI_ARRAY_STATIC_INIT_13(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13) \
    JMI_ARRAY_STATIC_INIT_12(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12)\
    name##_size[12] = (int) (d13);
#define JMI_ARRAY_STATIC_INIT_14(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14) \
    JMI_ARRAY_STATIC_INIT_13(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13)\
    name##_size[13] = (int) (d14);
#define JMI_ARRAY_STATIC_INIT_15(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15) \
    JMI_ARRAY_STATIC_INIT_14(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14)\
    name##_size[14] = (int) (d15);
#define JMI_ARRAY_STATIC_INIT_16(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16) \
    JMI_ARRAY_STATIC_INIT_15(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15)\
    name##_size[15] = (int) (d16);
#define JMI_ARRAY_STATIC_INIT_17(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17) \
    JMI_ARRAY_STATIC_INIT_16(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16)\
    name##_size[16] = (int) (d17);
#define JMI_ARRAY_STATIC_INIT_18(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18) \
    JMI_ARRAY_STATIC_INIT_17(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17)\
    name##_size[17] = (int) (d18);
#define JMI_ARRAY_STATIC_INIT_19(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19) \
    JMI_ARRAY_STATIC_INIT_18(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18)\
    name##_size[18] = (int) (d19);
#define JMI_ARRAY_STATIC_INIT_20(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20) \
    JMI_ARRAY_STATIC_INIT_19(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19)\
    name##_size[19] = (int) (d20);
#define JMI_ARRAY_STATIC_INIT_21(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21) \
    JMI_ARRAY_STATIC_INIT_20(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20)\
    name##_size[20] = (int) (d21);
#define JMI_ARRAY_STATIC_INIT_22(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22) \
    JMI_ARRAY_STATIC_INIT_21(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21)\
    name##_size[21] = (int) (d22);
#define JMI_ARRAY_STATIC_INIT_23(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23) \
    JMI_ARRAY_STATIC_INIT_22(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22)\
    name##_size[22] = (int) (d23);
#define JMI_ARRAY_STATIC_INIT_24(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24) \
    JMI_ARRAY_STATIC_INIT_23(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23)\
    name##_size[23] = (int) (d24);
#define JMI_ARRAY_STATIC_INIT_25(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25) \
    JMI_ARRAY_STATIC_INIT_24(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24)\
    name##_size[24] = (int) (d25);

/* Dynamic array initialization macros */
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_1(type, name, ne, d1) \
    name##_obj.size = name##_size;\
    name##_obj.var = (type*) calloc((int) (ne), sizeof(type));\
    JMI_DYNAMIC_ADD_POINTER(name##_obj.var)\
    name##_obj.num_elems = (int) (ne);\
    name##_size[0] = (int) (d1);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_2(type, name, ne, d1, d2) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_1(type, name, ne, d1)\
    name##_size[1] = (int) (d2);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_3(type, name, ne, d1, d2, d3) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_2(type, name, ne, d1, d2)\
    name##_size[2] = (int) (d3);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_4(type, name, ne, d1, d2, d3, d4) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_3(type, name, ne, d1, d2, d3)\
    name##_size[3] = (int) (d4);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_5(type, name, ne, d1, d2, d3, d4, d5) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_4(type, name, ne, d1, d2, d3, d4)\
    name##_size[4] = (int) (d5);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_6(type, name, ne, d1, d2, d3, d4, d5, d6) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_5(type, name, ne, d1, d2, d3, d4, d5)\
    name##_size[5] = (int) (d6);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_7(type, name, ne, d1, d2, d3, d4, d5, d6, d7) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_6(type, name, ne, d1, d2, d3, d4, d5, d6)\
    name##_size[6] = (int) (d7);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_8(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_7(type, name, ne, d1, d2, d3, d4, d5, d6, d7)\
    name##_size[7] = (int) (d8);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_9(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_8(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8)\
    name##_size[8] = (int) (d9);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_10(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_9(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9)\
    name##_size[9] = (int) (d10);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_11(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_10(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10)\
    name##_size[10] = (int) (d11);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_12(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_11(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11)\
    name##_size[11] = (int) (d12);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_13(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_12(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12)\
    name##_size[12] = (int) (d13);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_14(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_13(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13)\
    name##_size[13] = (int) (d14);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_15(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_14(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14)\
    name##_size[14] = (int) (d15);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_16(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_15(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15)\
    name##_size[15] = (int) (d16);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_17(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_16(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16)\
    name##_size[16] = (int) (d17);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_18(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_17(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17)\
    name##_size[17] = (int) (d18);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_19(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_18(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18)\
    name##_size[18] = (int) (d19);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_20(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_19(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19)\
    name##_size[19] = (int) (d20);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_21(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_20(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20)\
    name##_size[20] = (int) (d21);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_22(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_21(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21)\
    name##_size[21] = (int) (d22);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_23(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_22(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22)\
    name##_size[22] = (int) (d23);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_24(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_23(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23)\
    name##_size[23] = (int) (d24);
#define JMI_RECORD_ARRAY_DYNAMIC_INIT_25(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_24(type, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24)\
    name##_size[24] = (int) (d25);

/* Dynamic array initialization macros */
#define JMI_ARRAY_DYNAMIC_INIT_1(name, ne, d1) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_1(jmi_real_t, name, ne, d1)
#define JMI_ARRAY_DYNAMIC_INIT_2(name, ne, d1, d2) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_2(jmi_real_t, name, ne, d1, d2)
#define JMI_ARRAY_DYNAMIC_INIT_3(name, ne, d1, d2, d3) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_3(jmi_real_t, name, ne, d1, d2, d3)
#define JMI_ARRAY_DYNAMIC_INIT_4(name, ne, d1, d2, d3, d4) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_4(jmi_real_t, name, ne, d1, d2, d3, d4)
#define JMI_ARRAY_DYNAMIC_INIT_5(name, ne, d1, d2, d3, d4, d5) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_5(jmi_real_t, name, ne, d1, d2, d3, d4, d5)
#define JMI_ARRAY_DYNAMIC_INIT_6(name, ne, d1, d2, d3, d4, d5, d6) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_6(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6)
#define JMI_ARRAY_DYNAMIC_INIT_7(name, ne, d1, d2, d3, d4, d5, d6, d7) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_7(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7)
#define JMI_ARRAY_DYNAMIC_INIT_8(name, ne, d1, d2, d3, d4, d5, d6, d7, d8) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_8(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8)
#define JMI_ARRAY_DYNAMIC_INIT_9(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_9(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9)
#define JMI_ARRAY_DYNAMIC_INIT_10(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_10(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10)
#define JMI_ARRAY_DYNAMIC_INIT_11(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_11(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11)
#define JMI_ARRAY_DYNAMIC_INIT_12(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_12(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12)
#define JMI_ARRAY_DYNAMIC_INIT_13(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_13(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13)
#define JMI_ARRAY_DYNAMIC_INIT_14(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_14(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14)
#define JMI_ARRAY_DYNAMIC_INIT_15(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_15(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15)
#define JMI_ARRAY_DYNAMIC_INIT_16(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_16(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16)
#define JMI_ARRAY_DYNAMIC_INIT_17(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_17(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17)
#define JMI_ARRAY_DYNAMIC_INIT_18(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_18(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18)
#define JMI_ARRAY_DYNAMIC_INIT_19(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_19(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19)
#define JMI_ARRAY_DYNAMIC_INIT_20(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_20(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20)
#define JMI_ARRAY_DYNAMIC_INIT_21(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_21(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21)
#define JMI_ARRAY_DYNAMIC_INIT_22(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_22(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22)
#define JMI_ARRAY_DYNAMIC_INIT_23(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_23(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23)
#define JMI_ARRAY_DYNAMIC_INIT_24(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_24(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24)
#define JMI_ARRAY_DYNAMIC_INIT_25(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_25(jmi_real_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25)

/* Dynamic array initialization macros for integer arrays */
#define JMI_INT_ARRAY_DYNAMIC_INIT_1(name, ne, d1) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_1(jmi_int_t, name, ne, d1)
#define JMI_INT_ARRAY_DYNAMIC_INIT_2(name, ne, d1, d2) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_2(jmi_int_t, name, ne, d1, d2)
#define JMI_INT_ARRAY_DYNAMIC_INIT_3(name, ne, d1, d2, d3) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_3(jmi_int_t, name, ne, d1, d2, d3)
#define JMI_INT_ARRAY_DYNAMIC_INIT_4(name, ne, d1, d2, d3, d4) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_4(jmi_int_t, name, ne, d1, d2, d3, d4)
#define JMI_INT_ARRAY_DYNAMIC_INIT_5(name, ne, d1, d2, d3, d4, d5) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_5(jmi_int_t, name, ne, d1, d2, d3, d4, d5)
#define JMI_INT_ARRAY_DYNAMIC_INIT_6(name, ne, d1, d2, d3, d4, d5, d6) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_6(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6)
#define JMI_INT_ARRAY_DYNAMIC_INIT_7(name, ne, d1, d2, d3, d4, d5, d6, d7) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_7(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7)
#define JMI_INT_ARRAY_DYNAMIC_INIT_8(name, ne, d1, d2, d3, d4, d5, d6, d7, d8) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_8(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8)
#define JMI_INT_ARRAY_DYNAMIC_INIT_9(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_9(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9)
#define JMI_INT_ARRAY_DYNAMIC_INIT_10(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_10(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10)
#define JMI_INT_ARRAY_DYNAMIC_INIT_11(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_11(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11)
#define JMI_INT_ARRAY_DYNAMIC_INIT_12(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_12(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12)
#define JMI_INT_ARRAY_DYNAMIC_INIT_13(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_13(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13)
#define JMI_INT_ARRAY_DYNAMIC_INIT_14(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_14(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14)
#define JMI_INT_ARRAY_DYNAMIC_INIT_15(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_15(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15)
#define JMI_INT_ARRAY_DYNAMIC_INIT_16(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_16(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16)
#define JMI_INT_ARRAY_DYNAMIC_INIT_17(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_17(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17)
#define JMI_INT_ARRAY_DYNAMIC_INIT_18(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_18(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18)
#define JMI_INT_ARRAY_DYNAMIC_INIT_19(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_19(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19)
#define JMI_INT_ARRAY_DYNAMIC_INIT_20(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_20(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20)
#define JMI_INT_ARRAY_DYNAMIC_INIT_21(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_21(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21)
#define JMI_INT_ARRAY_DYNAMIC_INIT_22(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_22(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22)
#define JMI_INT_ARRAY_DYNAMIC_INIT_23(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_23(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23)
#define JMI_INT_ARRAY_DYNAMIC_INIT_24(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_24(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24)
#define JMI_INT_ARRAY_DYNAMIC_INIT_25(name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25) \
    JMI_RECORD_ARRAY_DYNAMIC_INIT_25(jmi_int_t, name, ne, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25)

#if 0
/* Macro for declaring dynamic list variable - should be called at beginning of function */
#define JMI_DYNAMIC_INIT() \
    jmi_dynamic_list* jmi_dynamic_prev;\
    jmi_dynamic_list* jmi_dynamic_cur;\
    jmi_dynamic_list* jmi_dynamic_first = (jmi_dynamic_list*)calloc(1, sizeof(jmi_dynamic_list));\
    jmi_dynamic_list* jmi_dynamic_last = jmi_dynamic_first;

/* Macro for adding a pointer to dynamic list - only for use in other macros */
#define JMI_DYNAMIC_ADD_POINTER(pointer) \
    jmi_dynamic_last->next = (jmi_dynamic_list*)calloc(1, sizeof(jmi_dynamic_list));\
    jmi_dynamic_last = jmi_dynamic_last->next;\
    jmi_dynamic_last->data = pointer;

/* Dynamic deallocation of all dynamically allocated arrays and record arrays - should be called before return */
#define JMI_DYNAMIC_FREE() \
    jmi_dynamic_prev = jmi_dynamic_first;\
    for (jmi_dynamic_cur = jmi_dynamic_prev->next; jmi_dynamic_cur; jmi_dynamic_prev = jmi_dynamic_cur, jmi_dynamic_cur = jmi_dynamic_cur->next) {\
        free(jmi_dynamic_prev);\
        free(jmi_dynamic_cur->data);\
    }\
    free(jmi_dynamic_prev);

#else

/* Macro for declaring dynamic list variable - should be called at beginning of function */
#define JMI_DYNAMIC_INIT() \
    jmi_dynamic_list* jmi_dynamic_first = 0;\
    jmi_dynamic_list* jmi_dynamic_last = 0;

/* Macro for adding a pointer to dynamic list - only for use in other macros */
#define JMI_DYNAMIC_ADD_POINTER(pointer) \
    do { \
       if(jmi_dynamic_first) {\
          jmi_dynamic_last->next = (jmi_dynamic_list*)calloc(1, sizeof(jmi_dynamic_list));\
          jmi_dynamic_last = jmi_dynamic_last->next;\
       }\
       else jmi_dynamic_last = jmi_dynamic_first = (jmi_dynamic_list*)calloc(1, sizeof(jmi_dynamic_list));\
       jmi_dynamic_last->data = pointer; \
    } while(0);

/* Dynamic deallocation of all dynamically allocated arrays and record arrays - should be called before return */
#define JMI_DYNAMIC_FREE() \
    if(jmi_dynamic_first) jmi_dynamic_free(jmi_dynamic_first);

/* Clean up the linked list */
void jmi_dynamic_free(jmi_dynamic_list* jmi_dynamic_first);

#endif

/* Record array access macros */
#define jmi_array_rec_1(arr, i1) (&((arr)->var[(int) _JMI_ARR_I_1(arr, i1)]))
#define jmi_array_rec_2(arr, i1, i2) (&((arr)->var[(int) _JMI_ARR_I_2(arr, i1, i2)]))
#define jmi_array_rec_3(arr, i1, i2, i3) (&((arr)->var[(int) _JMI_ARR_I_3(arr, i1, i2, i3)]))
#define jmi_array_rec_4(arr, i1, i2, i3, i4) (&((arr)->var[(int) _JMI_ARR_I_4(arr, i1, i2, i3, i4)]))
#define jmi_array_rec_5(arr, i1, i2, i3, i4, i5) (&((arr)->var[(int) _JMI_ARR_I_5(arr, i1, i2, i3, i4, i5)]))
#define jmi_array_rec_6(arr, i1, i2, i3, i4, i5, i6) (&((arr)->var[(int) _JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6)]))
#define jmi_array_rec_7(arr, i1, i2, i3, i4, i5, i6, i7) (&((arr)->var[(int) _JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7)]))
#define jmi_array_rec_8(arr, i1, i2, i3, i4, i5, i6, i7, i8) (&((arr)->var[(int) _JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8)]))
#define jmi_array_rec_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9) (&((arr)->var[(int) _JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9)]))
#define jmi_array_rec_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10) (&((arr)->var[(int) _JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10)]))
#define jmi_array_rec_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11) (&((arr)->var[(int) _JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11)]))
#define jmi_array_rec_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12) (&((arr)->var[(int) _JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12)]))
#define jmi_array_rec_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13) (&((arr)->var[(int) _JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13)]))
#define jmi_array_rec_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14) (&((arr)->var[(int) _JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14)]))
#define jmi_array_rec_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15) (&((arr)->var[(int) _JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15)]))
#define jmi_array_rec_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16) (&((arr)->var[(int) _JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16)]))
#define jmi_array_rec_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17) (&((arr)->var[(int) _JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17)]))
#define jmi_array_rec_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18) (&((arr)->var[(int) _JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18)]))
#define jmi_array_rec_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19) (&((arr)->var[(int) _JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19)]))
#define jmi_array_rec_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20) (&((arr)->var[(int) _JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20)]))
#define jmi_array_rec_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21) (&((arr)->var[(int) _JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21)]))
#define jmi_array_rec_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22) (&((arr)->var[(int) _JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22)]))
#define jmi_array_rec_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23) (&((arr)->var[(int) _JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23)]))
#define jmi_array_rec_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24) (&((arr)->var[(int) _JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24)]))
#define jmi_array_rec_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25) (&((arr)->var[(int) _JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25)]))

/* Access macros */
#define jmi_array_val_1(arr, i1) (arr)->var[(int) _JMI_ARR_I_1(arr, i1)]
#define jmi_array_val_2(arr, i1, i2) (arr)->var[(int) _JMI_ARR_I_2(arr, i1, i2)]
#define jmi_array_val_3(arr, i1, i2, i3) (arr)->var[(int) _JMI_ARR_I_3(arr, i1, i2, i3)]
#define jmi_array_val_4(arr, i1, i2, i3, i4) (arr)->var[(int) _JMI_ARR_I_4(arr, i1, i2, i3, i4)]
#define jmi_array_val_5(arr, i1, i2, i3, i4, i5) (arr)->var[(int) _JMI_ARR_I_5(arr, i1, i2, i3, i4, i5)]
#define jmi_array_val_6(arr, i1, i2, i3, i4, i5, i6) (arr)->var[(int) _JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6)]
#define jmi_array_val_7(arr, i1, i2, i3, i4, i5, i6, i7) (arr)->var[(int) _JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7)]
#define jmi_array_val_8(arr, i1, i2, i3, i4, i5, i6, i7, i8) (arr)->var[(int) _JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8)]
#define jmi_array_val_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9) (arr)->var[(int) _JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9)]
#define jmi_array_val_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10) (arr)->var[(int) _JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10)]
#define jmi_array_val_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11) (arr)->var[(int) _JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11)]
#define jmi_array_val_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12) (arr)->var[(int) _JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12)]
#define jmi_array_val_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13) (arr)->var[(int) _JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13)]
#define jmi_array_val_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14) (arr)->var[(int) _JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14)]
#define jmi_array_val_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15) (arr)->var[(int) _JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15)]
#define jmi_array_val_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16) (arr)->var[(int) _JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16)]
#define jmi_array_val_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17) (arr)->var[(int) _JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17)]
#define jmi_array_val_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18) (arr)->var[(int) _JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18)]
#define jmi_array_val_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19) (arr)->var[(int) _JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19)]
#define jmi_array_val_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20) (arr)->var[(int) _JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20)]
#define jmi_array_val_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21) (arr)->var[(int) _JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21)]
#define jmi_array_val_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22) (arr)->var[(int) _JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22)]
#define jmi_array_val_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23) (arr)->var[(int) _JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23)]
#define jmi_array_val_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24) (arr)->var[(int) _JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24)]
#define jmi_array_val_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25) (arr)->var[(int) _JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25)]

/* Reference macros */
#define jmi_array_ref_1  jmi_array_val_1
#define jmi_array_ref_2  jmi_array_val_2
#define jmi_array_ref_3  jmi_array_val_3
#define jmi_array_ref_4  jmi_array_val_4
#define jmi_array_ref_5  jmi_array_val_5
#define jmi_array_ref_6  jmi_array_val_6
#define jmi_array_ref_7  jmi_array_val_7
#define jmi_array_ref_8  jmi_array_val_8
#define jmi_array_ref_9  jmi_array_val_9
#define jmi_array_ref_10 jmi_array_val_10
#define jmi_array_ref_11 jmi_array_val_11
#define jmi_array_ref_12 jmi_array_val_12
#define jmi_array_ref_13 jmi_array_val_13
#define jmi_array_ref_14 jmi_array_val_14
#define jmi_array_ref_15 jmi_array_val_15
#define jmi_array_ref_16 jmi_array_val_16
#define jmi_array_ref_17 jmi_array_val_17
#define jmi_array_ref_18 jmi_array_val_18
#define jmi_array_ref_19 jmi_array_val_19
#define jmi_array_ref_20 jmi_array_val_20
#define jmi_array_ref_21 jmi_array_val_21
#define jmi_array_ref_22 jmi_array_val_22
#define jmi_array_ref_23 jmi_array_val_23
#define jmi_array_ref_24 jmi_array_val_24
#define jmi_array_ref_25 jmi_array_val_25

#ifdef __cplusplus
extern "C" {
#endif
void jmi_transpose_matrix(jmi_array_t* arr, jmi_ad_var_t* src, jmi_ad_var_t* dest);
void jmi_transpose_matrix_to_int(jmi_array_t* arr, jmi_ad_var_t* src, jmi_int_t* dest);
void jmi_transpose_matrix_from_int(jmi_array_t* arr, jmi_int_t* src, jmi_ad_var_t* dest);
void jmi_copy_matrix_to_int(jmi_array_t* arr, jmi_ad_var_t* src, jmi_int_t* dest);
void jmi_copy_matrix_from_int(jmi_array_t* arr, jmi_int_t* src, jmi_ad_var_t* dest);
#ifdef __cplusplus
}
#endif
#endif /* _JMI_ARRAY_NONE_H */
