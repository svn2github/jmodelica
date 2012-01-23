/*
   Copyright (C) 2012 Modelon AB

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



/** \file fmiVariableList.h
*  \brief Public interface to the FMI XML C-library. Handling of variable lists.
*/

#ifndef FMIVARIABLELIST_H_
#define FMIVARIABLELIST_H_

 #include "fmiModelDescription.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Get the list of all the variables in the model */
fmiVariableList* fmiGetVariableList(fmiModelDescription* md);

/* Note that variable lists are allocated dynamically and must be freed when not needed any longer */
void fmiVariableListFree(fmiVariableList*);

/* Make a copy */
fmiVariableList* fmiVariableListClone(fmiVariableList*);

/* Get number of variables in a list */
size_t  fmiGetVariableListSize(fmiVariableList*);

/* Get a pointer to the list of the value references for all the variables */
const fmiValueReference* fmiGetValueReferceList(fmiVariableList*);

/* Get a single variable from the list*/
fmiVariable* fmiGetVariable(fmiVariableList*, unsigned int  index);

/* Operations on variable lists. Every operation creates a new list. */
/* Select sub-lists. Both fromIndex and toIndex are "inclusive" */
fmiVariableList* fmiGetSublist(fmiVariableList*, unsigned int  fromIndex, unsigned int  toIndex);

/* Callback function typedef for the fmiFilterVariables. The function should return 0 to prevent a 
 variable from coming to the output list. */
typedef int (*fmiVariableFilterFunction)(fmiVariable*);

/* fmiFilterVariables calls  the provided 'filter' function on every variable in the list.
  It returns a sub-list list with the variables for which filter returned non-zero value. */
fmiVariableList* fmiFilterVariables(fmiVariableList*, fmiVariableFilterFunction filter);

/* Query below has the following syntax:
  query =   elementary_query 
		  | '(' query ')'
          | query '|' query
		  | query '&' query
		  | '!' query
  elementary_query =  "name" '=' <regexp>
                    | "quantity" '=' <string>
                    | "type" '=' <string>
                    | "unit" '=' <string>
                    | "displayUnit" '=' <string>
                    | "fixed" '=' ("true"|"false")
                    | "has_start" '='  ("true"|"false")
                    | "alias" '=' ['-']<variable name> (negative value for negated-aliases)
                    | "alias" '=' ['-']<value reference> (negative value for negated-aliases)

Example: "name='a.*' & fixed=false" 
*/
fmiVariableList* fmiSelectVariables(fmiVariableList*, const char* query);

/* Join different lists */
fmiVariableList* fmiVariableListJoin(fmiVariableList*, fmiVariableList*);
fmiVariableList* fmiVariableListCreate(fmiVariable*);
fmiVariableList* fmiVariableListAppend(fmiVariableList*, fmiVariable*);
fmiVariableList* fmiVariableListPrepend(fmiVariable*, fmiVariableList*);

#ifdef __cplusplus
}
#endif
#endif
