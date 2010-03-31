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

typedef struct jmi_array_t jmi_array_t;
struct jmi_array_t {
    int*        size;
    jmi_real_t* var;
};

#include "jmi_array_common.h"

// Array creation macro
#define JMI_ARRAY_DECL(name, n, ...) \
	int name##_size[] = { __VA_ARGS__ };\
	jmi_real_t name##_var[n];\
	jmi_array_t name##_arr = { name##_size, name##_var };\
	jmi_array_t* name = &name##_arr;

// Access macros
#define jmi_array_val_1  jmi_array_rec_1
#define jmi_array_val_2  jmi_array_rec_2
#define jmi_array_val_3  jmi_array_rec_3
#define jmi_array_val_4  jmi_array_rec_4
#define jmi_array_val_5  jmi_array_rec_5
#define jmi_array_val_6  jmi_array_rec_6
#define jmi_array_val_7  jmi_array_rec_7
#define jmi_array_val_8  jmi_array_rec_8
#define jmi_array_val_9  jmi_array_rec_9
#define jmi_array_val_10 jmi_array_rec_10
#define jmi_array_val_11 jmi_array_rec_11
#define jmi_array_val_12 jmi_array_rec_12
#define jmi_array_val_13 jmi_array_rec_13
#define jmi_array_val_14 jmi_array_rec_14
#define jmi_array_val_15 jmi_array_rec_15
#define jmi_array_val_16 jmi_array_rec_16
#define jmi_array_val_17 jmi_array_rec_17
#define jmi_array_val_18 jmi_array_rec_18
#define jmi_array_val_19 jmi_array_rec_19
#define jmi_array_val_20 jmi_array_rec_20
#define jmi_array_val_21 jmi_array_rec_21
#define jmi_array_val_22 jmi_array_rec_22
#define jmi_array_val_23 jmi_array_rec_23
#define jmi_array_val_24 jmi_array_rec_24
#define jmi_array_val_25 jmi_array_rec_25

// Reference macros
#define jmi_array_ref_1  jmi_array_rec_1
#define jmi_array_ref_2  jmi_array_rec_2
#define jmi_array_ref_3  jmi_array_rec_3
#define jmi_array_ref_4  jmi_array_rec_4
#define jmi_array_ref_5  jmi_array_rec_5
#define jmi_array_ref_6  jmi_array_rec_6
#define jmi_array_ref_7  jmi_array_rec_7
#define jmi_array_ref_8  jmi_array_rec_8
#define jmi_array_ref_9  jmi_array_rec_9
#define jmi_array_ref_10 jmi_array_rec_10
#define jmi_array_ref_11 jmi_array_rec_11
#define jmi_array_ref_12 jmi_array_rec_12
#define jmi_array_ref_13 jmi_array_rec_13
#define jmi_array_ref_14 jmi_array_rec_14
#define jmi_array_ref_15 jmi_array_rec_15
#define jmi_array_ref_16 jmi_array_rec_16
#define jmi_array_ref_17 jmi_array_rec_17
#define jmi_array_ref_18 jmi_array_rec_18
#define jmi_array_ref_19 jmi_array_rec_19
#define jmi_array_ref_20 jmi_array_rec_20
#define jmi_array_ref_21 jmi_array_rec_21
#define jmi_array_ref_22 jmi_array_rec_22
#define jmi_array_ref_23 jmi_array_rec_23
#define jmi_array_ref_24 jmi_array_rec_24
#define jmi_array_ref_25 jmi_array_rec_25

#endif /* _JMI_ARRAY_NONE_H */
