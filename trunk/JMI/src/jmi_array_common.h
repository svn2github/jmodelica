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

/* Size macro - gives the size of array arr for dimension d */
#define jmi_array_size(arr, d) ((arr)->size[(int) d])


/* Record array initialization macros */
#define JMI_RECORD_ARRAY_STATIC_INIT_1(type, name, d1) \
    JMI_ARRAY_STATIC_INIT_1(name, d1)
#define JMI_RECORD_ARRAY_STATIC_INIT_2(type, name, d1, d2) \
    JMI_ARRAY_STATIC_INIT_2(name, d1, d2)
#define JMI_RECORD_ARRAY_STATIC_INIT_3(type, name, d1, d2, d3) \
    JMI_ARRAY_STATIC_INIT_3(name, d1, d2, d3)
#define JMI_RECORD_ARRAY_STATIC_INIT_4(type, name, d1, d2, d3, d4) \
    JMI_ARRAY_STATIC_INIT_4(name, d1, d2, d3, d4)
#define JMI_RECORD_ARRAY_STATIC_INIT_5(type, name, d1, d2, d3, d4, d5) \
    JMI_ARRAY_STATIC_INIT_5(name, d1, d2, d3, d4, d5)
#define JMI_RECORD_ARRAY_STATIC_INIT_6(type, name, d1, d2, d3, d4, d5, d6) \
    JMI_ARRAY_STATIC_INIT_6(name, d1, d2, d3, d4, d5, d6)
#define JMI_RECORD_ARRAY_STATIC_INIT_7(type, name, d1, d2, d3, d4, d5, d6, d7) \
    JMI_ARRAY_STATIC_INIT_7(name, d1, d2, d3, d4, d5, d6, d7)
#define JMI_RECORD_ARRAY_STATIC_INIT_8(type, name, d1, d2, d3, d4, d5, d6, d7, d8) \
    JMI_ARRAY_STATIC_INIT_8(name, d1, d2, d3, d4, d5, d6, d7, d8)
#define JMI_RECORD_ARRAY_STATIC_INIT_9(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9) \
    JMI_ARRAY_STATIC_INIT_9(name, d1, d2, d3, d4, d5, d6, d7, d8, d9)
#define JMI_RECORD_ARRAY_STATIC_INIT_10(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10) \
    JMI_ARRAY_STATIC_INIT_10(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10)
#define JMI_RECORD_ARRAY_STATIC_INIT_11(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11) \
    JMI_ARRAY_STATIC_INIT_11(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11)
#define JMI_RECORD_ARRAY_STATIC_INIT_12(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12) \
    JMI_ARRAY_STATIC_INIT_12(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12)
#define JMI_RECORD_ARRAY_STATIC_INIT_13(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13) \
    JMI_ARRAY_STATIC_INIT_13(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13)
#define JMI_RECORD_ARRAY_STATIC_INIT_14(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14) \
    JMI_ARRAY_STATIC_INIT_14(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14)
#define JMI_RECORD_ARRAY_STATIC_INIT_15(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15) \
    JMI_ARRAY_STATIC_INIT_15(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15)
#define JMI_RECORD_ARRAY_STATIC_INIT_16(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16) \
    JMI_ARRAY_STATIC_INIT_16(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16)
#define JMI_RECORD_ARRAY_STATIC_INIT_17(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17) \
    JMI_ARRAY_STATIC_INIT_17(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17)
#define JMI_RECORD_ARRAY_STATIC_INIT_18(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18) \
    JMI_ARRAY_STATIC_INIT_18(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18)
#define JMI_RECORD_ARRAY_STATIC_INIT_19(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19) \
    JMI_ARRAY_STATIC_INIT_19(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19)
#define JMI_RECORD_ARRAY_STATIC_INIT_20(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20) \
    JMI_ARRAY_STATIC_INIT_20(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20)
#define JMI_RECORD_ARRAY_STATIC_INIT_21(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21) \
    JMI_ARRAY_STATIC_INIT_21(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21)
#define JMI_RECORD_ARRAY_STATIC_INIT_22(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22) \
    JMI_ARRAY_STATIC_INIT_22(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22)
#define JMI_RECORD_ARRAY_STATIC_INIT_23(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23) \
    JMI_ARRAY_STATIC_INIT_23(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23)
#define JMI_RECORD_ARRAY_STATIC_INIT_24(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24) \
    JMI_ARRAY_STATIC_INIT_24(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24)
#define JMI_RECORD_ARRAY_STATIC_INIT_25(type, name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25) \
    JMI_ARRAY_STATIC_INIT_25(name, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25)


/* Index macros - only for use in definitions of jmi_array_* functions & macros */
#define _JMI_ARR_I_1(arr, i1) (i1-1)
#define _JMI_ARR_I_2(arr, i1, i2) (_JMI_ARR_I_1(arr, i1)*(arr)->size[1]+i2-1)
#define _JMI_ARR_I_3(arr, i1, i2, i3) (_JMI_ARR_I_2(arr, i1, i2)*(arr)->size[2]+i3-1)
#define _JMI_ARR_I_4(arr, i1, i2, i3, i4) (_JMI_ARR_I_3(arr, i1, i2, i3)*(arr)->size[3]+i4-1)
#define _JMI_ARR_I_5(arr, i1, i2, i3, i4, i5) (_JMI_ARR_I_4(arr, i1, i2, i3, i4)*(arr)->size[4]+i5-1)
#define _JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6) (_JMI_ARR_I_5(arr, i1, i2, i3, i4, i5)*(arr)->size[5]+i6-1)
#define _JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7) (_JMI_ARR_I_6(arr, i1, i2, i3, i4, i5, i6)*(arr)->size[6]+i7-1)
#define _JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8) (_JMI_ARR_I_7(arr, i1, i2, i3, i4, i5, i6, i7)*(arr)->size[7]+i8-1)
#define _JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9) (_JMI_ARR_I_8(arr, i1, i2, i3, i4, i5, i6, i7, i8)*(arr)->size[8]+i9-1)
#define _JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10) (_JMI_ARR_I_9(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9)*(arr)->size[9]+i10-1)
#define _JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11) (_JMI_ARR_I_10(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10)*(arr)->size[10]+i11-1)
#define _JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12) (_JMI_ARR_I_11(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11)*(arr)->size[11]+i12-1)
#define _JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13) (_JMI_ARR_I_12(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12)*(arr)->size[12]+i13-1)
#define _JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14) (_JMI_ARR_I_13(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13)*(arr)->size[13]+i14-1)
#define _JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15) (_JMI_ARR_I_14(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14)*(arr)->size[14]+i15-1)
#define _JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16) (_JMI_ARR_I_15(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15)*(arr)->size[15]+i16-1)
#define _JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17) (_JMI_ARR_I_16(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16)*(arr)->size[16]+i17-1)
#define _JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18) (_JMI_ARR_I_17(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17)*(arr)->size[17]+i18-1)
#define _JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19) (_JMI_ARR_I_18(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18)*(arr)->size[18]+i19-1)
#define _JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20) (_JMI_ARR_I_19(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19)*(arr)->size[19]+i20-1)
#define _JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21) (_JMI_ARR_I_20(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20)*(arr)->size[20]+i21-1)
#define _JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22) (_JMI_ARR_I_21(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21)*(arr)->size[21]+i22-1)
#define _JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23) (_JMI_ARR_I_22(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22)*(arr)->size[22]+i23-1)
#define _JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24) (_JMI_ARR_I_23(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23)*(arr)->size[23]+i24-1)
#define _JMI_ARR_I_25(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24, i25) (_JMI_ARR_I_24(arr, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, i16, i17, i18, i19, i20, i21, i22, i23, i24)*(arr)->size[24]+i25-1)

#endif /* _JMI_ARRAY_COMMON_H */

