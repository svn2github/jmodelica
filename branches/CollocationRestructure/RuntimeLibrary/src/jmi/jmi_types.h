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

/* Temporary remains of CppAD*/            
typedef jmi_real_t jmi_ad_var_t; 

typedef int BOOL;

#define TRUE  1
#define FALSE 0

typedef char jmi_boolean;
typedef const char* jmi_string;

#endif
