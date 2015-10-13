/*
    Copyright (C) 2013 Modelon AB

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

/** \file jmi_types.h
    \brief Basic type definitions used in the run-time.
*/    

#ifndef _JMI_TYPES_H
#define _JMI_TYPES_H
/* Typedef for the doubles used in the interface. */
typedef double jmi_real_t; /*< Typedef for the real number
               < representation used in the Runtime
               < Library. */
typedef int jmi_int_t; /*< Typedef for the integer number
               < representation used in the Runtime
               < Library. */
typedef char* jmi_string_t; /*< Typedef for the string
               < representation used in the external constant
               < evaluation framework. */
typedef void* jmi_extobj_t; /*< Typedef for the external object
               < representation used in the Runtime
               < Library. */

#define JMI_MIN(X,Y) ((X) < (Y) ? (X) : (Y))
#define JMI_ABS(X)   ((X) < (0) ? (-1*X) : (X))

/* Max allowed length of strings */
#define JMI_STR_MAX 16 * 1024 - 1

/* Declaration for string */
#define JMI_DEF_STR_STAT(NAME, LEN) \
    char NAME[JMI_MIN(LEN, JMI_STR_MAX) + 1];
#define JMI_DEF_STR_DYNA(NAME) \
    jmi_string_t NAME;

/* Initialization of string */
#define JMI_INI_STR_STAT(NAME) \
    NAME[0] = '\0';
#define JMI_INI_STR_DYNA(NAME, LEN) \
    NAME = calloc(JMI_MIN(LEN, JMI_STR_MAX) + 1, 1); \
    JMI_INI_STR_STAT(NAME)

/* Assign (copy) SRC to DEST */
#define JMI_ASG(TYPE, DEST, SRC) \
    JMI_ASG_##TYPE(DEST, SRC)
#define JMI_ASG_STR(DEST,SRC) \
    JMI_SET_STR(DEST, SRC) \
    JMI_DYNAMIC_ADD_POINTER(DEST)
    
#define JMI_ASG_STR_ARR(DEST, SRC) \
    { \
      int i; \
      for (i = 1; i <= DEST->num_elems; i++) { \
        JMI_ASG_STR(jmi_array_ref_1(DEST,i), jmi_array_val_1(SRC,i)) \
      }\
    }
    
#define JMI_SET_STR(DEST, SRC) \
    JMI_INI_STR_DYNA(DEST, JMI_LEN(SRC)) \
    strcpy(DEST,SRC);
    
/* Handle return value */
#define JMI_RET(TYPE, DEST, SRC) \
    if (DEST != NULL) { JMI_RET_##TYPE(DEST, SRC) }
    
/* Put return value in return variable in function */
#define JMI_RET_GEN(DEST, SRC) \
    *DEST = SRC;
#define JMI_RET_STR(DEST, SRC) \
    JMI_SET_STR(*DEST, SRC)
#define JMI_RET_STR_ARR(DEST, SRC) \
    { \
      int i; \
      for (i = 1; i <= DEST->num_elems; i++) { \
        JMI_RET_STR(&jmi_array_ref_1(DEST,i), jmi_array_val_1(SRC,i)) \
      }\
    }

/* Free string */
#define JMI_FREE(NAME) free(NAME);

/* Length of string */
#define JMI_LEN(NAME) \
    strlen(NAME)
    
/* Pointer to end of string */
#define JMI_STR_END(DEST) DEST + JMI_LEN(DEST)
    
/* Number of empty bytes at end of string */
#define JMI_STR_LEFT(DEST) JMI_STR_MAX - JMI_LEN(DEST)

/* Temporary remains of CppAD*/            
typedef jmi_real_t jmi_ad_var_t; 

typedef int BOOL;

#define TRUE  1
#define FALSE 0

#define JMI_REAL    0x00000000
#define JMI_INTEGER 0x10000000
#define JMI_BOOLEAN 0x20000000

typedef char jmi_boolean;
typedef const char* jmi_string;

#endif
