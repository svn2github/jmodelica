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



/** \file jmi_array_common.h
 *  \brief Handling of arrays in the JMI interface, common macros.
 *
 *  Note that arrays are only used in functions at this point.
 */

#ifndef _JMI_ARRAY_COMMON_H
#define _JMI_ARRAY_COMMON_H

// Size macro - gives the size of array arr for dimension d
#define jmi_array_size(arr, d) ((arr)->size[d])

// Index macros - only for use in definitions of jmi_array_* functions & macros
#define _JMI_ARR_I_1(arr, i1) i1-1
#define _JMI_ARR_I_2(arr, i1, i2) (_JMI_ARR_I_1(arr, i1))*(arr)->size[0]+i2-1
#define _JMI_ARR_I_3(arr, i1, i2, i3) (_JMI_ARR_I_2(arr, i1, i2))*(arr)->size[1]+i3-1
#define _JMI_ARR_I_4(arr, i1, i2, i3, i4) (_JMI_ARR_I_3(arr, i1, i2, i3))*(arr)->size[2]+i4-1
#define _JMI_ARR_I_5(arr, i1, i2, i3, i4, i5) (_JMI_ARR_I_4(arr, i1, i2, i3, i4))*(arr)->size[3]+i5-1
#define _JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6) (_JMI_ARR_I_5(arr, i1, i2, i3, i4, i5))*(arr)->size[4]+i6-1
#define _JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7) (_JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6))*(arr)->size[5]+i7-1
#define _JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8) (_JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7))*(arr)->size[6]+i8-1
#define _JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9) (_JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8))*(arr)->size[7]+i9-1
#define _JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10) (_JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9))*(arr)->size[8]+i10-1
#define _JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11) (_JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10))*(arr)->size[9]+i11-1
#define _JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12) (_JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11))*(arr)->size[10]+i12-1
#define _JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13) (_JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12))*(arr)->size[11]+i13-1
#define _JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14) (_JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13))*(arr)->size[12]+i14-1
#define _JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15) (_JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14))*(arr)->size[13]+i15-1
#define _JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16) (_JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15))*(arr)->size[14]+i16-1
#define _JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17) (_JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16))*(arr)->size[15]+i17-1
#define _JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18) (_JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17))*(arr)->size[16]+i18-1
#define _JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19) (_JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18))*(arr)->size[17]+i19-1
#define _JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20) (_JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19))*(arr)->size[18]+i20-1
#define _JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21) (_JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20))*(arr)->size[19]+i21-1
#define _JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22) (_JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21))*(arr)->size[20]+i22-1
#define _JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23) (_JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22))*(arr)->size[21]+i23-1
#define _JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24) (_JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23))*(arr)->size[22]+i24-1
#define _JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25) (_JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24))*(arr)->size[23]+i25-1

#endif /* _JMI_ARRAY_COMMON_H */

