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



/** \file jmi_array_cppad.h
 *  \brief Handling of arrays in the JMI interface, version with CppAD.
 *
 *  Note that arrays are only used in functions at this point.
 */

#ifndef _JMI_ARRAY_CPPAD_H
#define _JMI_ARRAY_CPPAD_H

#include <cppad/cppad.hpp>
#include <vector>

typedef struct jmi_array_t jmi_array_t;
struct jmi_array_t {
    int*                      size;
    CppAD::VecAD<jmi_real_t>* var;
};

typedef CppAD::VecAD<jmi_real_t>::reference jmi_ad_array_ref_t;

// Record array type declaration macro
#define RECORD_ARRAY_TYPE(rec, arr) typedef std::vector<rec> arr;

// Array creation macro
#define JMI_ARRAY_DECL(name, n, ...) int name##_size[] = { __VA_ARGS__ };\
                                     CppAD::VecAD<jmi_real_t> name##_var(n);\
                                     jmi_array_t name##_arr = { name##_size, &name##_var };\
                                     jmi_array_t* name = &name##_arr;

// Access functions
jmi_ad_var_t jmi_array_val_1(jmi_array_t* arr, jmi_ad_var_t i1);
jmi_ad_var_t jmi_array_val_2(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2);
jmi_ad_var_t jmi_array_val_3(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3);
jmi_ad_var_t jmi_array_val_4(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4);
jmi_ad_var_t jmi_array_val_5(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5);
jmi_ad_var_t jmi_array_val_6(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6);
jmi_ad_var_t jmi_array_val_7(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7);
jmi_ad_var_t jmi_array_val_8(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8);
jmi_ad_var_t jmi_array_val_9(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9);
jmi_ad_var_t jmi_array_val_10(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10);
jmi_ad_var_t jmi_array_val_11(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11);
jmi_ad_var_t jmi_array_val_12(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12);
jmi_ad_var_t jmi_array_val_13(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13);
jmi_ad_var_t jmi_array_val_14(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14);
jmi_ad_var_t jmi_array_val_15(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15);
jmi_ad_var_t jmi_array_val_16(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16);
jmi_ad_var_t jmi_array_val_17(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17);
jmi_ad_var_t jmi_array_val_18(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18);
jmi_ad_var_t jmi_array_val_19(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19);
jmi_ad_var_t jmi_array_val_20(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20);
jmi_ad_var_t jmi_array_val_21(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21);
jmi_ad_var_t jmi_array_val_22(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22);
jmi_ad_var_t jmi_array_val_23(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23);
jmi_ad_var_t jmi_array_val_24(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23, jmi_ad_var_t i24);
jmi_ad_var_t jmi_array_val_25(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23, jmi_ad_var_t i24, jmi_ad_var_t i25);

// Reference functions
jmi_ad_array_ref_t jmi_array_ref_1(jmi_array_t* arr, jmi_ad_var_t i1);
jmi_ad_array_ref_t jmi_array_ref_2(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2);
jmi_ad_array_ref_t jmi_array_ref_3(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3);
jmi_ad_array_ref_t jmi_array_ref_4(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4);
jmi_ad_array_ref_t jmi_array_ref_5(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5);
jmi_ad_array_ref_t jmi_array_ref_6(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6);
jmi_ad_array_ref_t jmi_array_ref_7(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7);
jmi_ad_array_ref_t jmi_array_ref_8(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8);
jmi_ad_array_ref_t jmi_array_ref_9(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9);
jmi_ad_array_ref_t jmi_array_ref_10(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10);
jmi_ad_array_ref_t jmi_array_ref_11(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11);
jmi_ad_array_ref_t jmi_array_ref_12(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12);
jmi_ad_array_ref_t jmi_array_ref_13(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13);
jmi_ad_array_ref_t jmi_array_ref_14(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14);
jmi_ad_array_ref_t jmi_array_ref_15(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15);
jmi_ad_array_ref_t jmi_array_ref_16(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16);
jmi_ad_array_ref_t jmi_array_ref_17(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17);
jmi_ad_array_ref_t jmi_array_ref_18(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18);
jmi_ad_array_ref_t jmi_array_ref_19(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19);
jmi_ad_array_ref_t jmi_array_ref_20(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20);
jmi_ad_array_ref_t jmi_array_ref_21(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21);
jmi_ad_array_ref_t jmi_array_ref_22(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22);
jmi_ad_array_ref_t jmi_array_ref_23(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23);
jmi_ad_array_ref_t jmi_array_ref_24(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23, jmi_ad_var_t i24);
jmi_ad_array_ref_t jmi_array_ref_25(jmi_array_t* arr, jmi_ad_var_t i1, jmi_ad_var_t i2, jmi_ad_var_t i3, jmi_ad_var_t i4, jmi_ad_var_t i5, jmi_ad_var_t i6, jmi_ad_var_t i7, jmi_ad_var_t i8, jmi_ad_var_t i9, jmi_ad_var_t i10, jmi_ad_var_t i11, jmi_ad_var_t i12, jmi_ad_var_t i13, jmi_ad_var_t i14, jmi_ad_var_t i15, jmi_ad_var_t i16, jmi_ad_var_t i17, jmi_ad_var_t i18, jmi_ad_var_t i19, jmi_ad_var_t i20, jmi_ad_var_t i21, jmi_ad_var_t i22, jmi_ad_var_t i23, jmi_ad_var_t i24, jmi_ad_var_t i25);

#endif /* _JMI_ARRAY_CPPAD_H */
