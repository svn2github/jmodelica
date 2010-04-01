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
    jmi_real_t* var;
};

// Record array type declaration macro
#define JMI_RECORD_ARRAY_TYPE(rec, arr) \
	typedef arr struct _##arr {\
		int* size;\
		rec* var;\
	};

// Array creation macro
#define JMI_ARRAY_STATIC(name, n, ...) \
	int name##_size[] = { __VA_ARGS__ };\
	jmi_real_t name##_var[n];\
	jmi_array_t name##_obj = { name##_size, name##_var };\
	jmi_array_t* name = &name##_obj;

// Record array creation macro
#define JMI_RECORD_ARRAY_STATIC(type, arr, name, n, ...) \
	int name##_size[] = { __VA_ARGS__ };\
	type name##_var[n];\
	arr name##_arr = { name##_size, name##_var };\
	arr* name = &name##_arr;

// Dynamic array creation macro
#define JMI_ARRAY_DYNAMIC(name, n, ...) \
	int name##_size[] = { __VA_ARGS__ };\
	jmi_real_t* name##_var = (jmi_real_t*) malloc((n) * sizeof(jmi_real_t));\
	JMI_DYNAMIC_ADD_POINTER(name##_var)\
	jmi_array_t name##_arr = { name##_size, name##_var };\
	jmi_array_t* name = &name##_arr;

// Dynamic record array creation macro
#define JMI_RECORD_ARRAY_DYNAMIC(type, arr, name, n, ...) \
	int name##_size[] = { __VA_ARGS__ };\
	type* name##_var = (type*) malloc((n) * sizeof(type));\
	JMI_DYNAMIC_ADD_POINTER(name##_var)\
	arr name##_rec = { name##_size, name##_var };\
	arr* name = &name##_rec;

// Macro for declaring dynamic list variable - should be called at beginning of function
#define JMI_DYNAMIC_INIT() \
	jmi_dynamic_list* jmi_dynamic_first = calloc(1, sizeof(jmi_dynamic_list));\
	jmi_dynamic_list* jmi_dynamic_last = jmi_dynamic_first;

// Macro for adding a pointer to dynamic list - only for use in other macros
#define JMI_DYNAMIC_ADD_POINTER(pointer) \
	jmi_dynamic_last->next = calloc(1, sizeof(jmi_dynamic_list));\
	jmi_dynamic_last = jmi_dynamic_last->next;\
	jmi_dynamic_last->data = pointer;

// Dynamic deallocation of all dynamically allocated arrays and record arrays - should be called before return
#define JMI_DYNAMIC_FREE() \
	jmi_dynamic_list* prev = jmi_dynamic_first;\
	for (jmi_dynamic_list* cur = prev->next; cur; prev = cur, cur = cur->next) {\
		free(prev);\
		free(cur->data);\
	}\
	free(prev);

// Record array access macros
#define jmi_array_rec_1(arr, i1) (&((arr)->var[(int) i1]))
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

// Access macros
#define jmi_array_val_1(arr, i1) (arr)->var[(int) i1]
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

// Reference macros
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

#endif /* _JMI_ARRAY_NONE_H */
