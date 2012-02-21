/*
    Copyright (C) 2012 Modelon AB

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



/** \file fmi_xml_variable_list.h
*  \brief Public interface to the FMI XML C-library. Handling of variable lists.
*/

#ifndef FMI_XML_VARIABLELIST_H_
#define FMI_XML_VARIABLELIST_H_

 #include "fmi_xml_model_description.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Get the list of all the variables in the model */
fmi_xml_variable_list_t* fmi_xml_get_variable_list(fmi_xml_model_description_t* md);

/* Note that variable lists are allocated dynamically and must be freed when not needed any longer */
void fmi_xml_free_variable_list(fmi_xml_variable_list_t*);

/* Make a copy */
fmi_xml_variable_list_t* fmi_xml_clone_variable_list(fmi_xml_variable_list_t*);

/* Get number of variables in a list */
size_t  fmi_xml_get_variable_list_size(fmi_xml_variable_list_t*);

/* Get a pointer to the list of the value references for all the variables */
const fmi_xml_value_reference_t* fmi_xml_get_value_referece_list(fmi_xml_variable_list_t*);

/* Get a single variable from the list*/
fmi_xml_variable_t* fmi_xml_get_variable(fmi_xml_variable_list_t*, unsigned int  index);

/* Operations on variable lists. Every operation creates a new list. */
/* Select sub-lists. Both fromIndex and toIndex are "inclusive" */
fmi_xml_variable_list_t* fmi_xml_get_sublist(fmi_xml_variable_list_t*, unsigned int  fromIndex, unsigned int  toIndex);

/* Callback function typedef for the fmiFilterVariables. The function should return 0 to prevent a 
 variable from coming to the output list. */
typedef int (*fmi_xml_variable_filter_function_ft)(fmi_xml_variable_t*);

/* fmi_xml_filter_variables calls  the provided 'filter' function on every variable in the list.
  It returns a sub-list list with the variables for which filter returned non-zero value. */
fmi_xml_variable_list_t* fmi_xml_filter_variables(fmi_xml_variable_list_t*, fmi_xml_variable_filter_function_ft filter);

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
                    |
                    | "alias" '=' ['-']<variable name> (negative value for negated-aliases)
                    | "alias" '=' ['-']<value reference> (negative value for negated-aliases)

Example: "name='a.*' & fixed=false" 
*/
fmi_xml_variable_list_t* fmi_xml_select_variables(fmi_xml_variable_list_t*, const char* query);

/* Join different lists */
fmi_xml_variable_list_t* fmi_xml_join_var_list(fmi_xml_variable_list_t*, fmi_xml_variable_list_t*);
fmi_xml_variable_list_t* fmi_xml_create_var_list(fmi_xml_model_description_t* md,fmi_xml_variable_t*);
fmi_xml_variable_list_t* fmi_xml_append_to_var_list(fmi_xml_variable_list_t*, fmi_xml_variable_t*);
fmi_xml_variable_list_t* fmi_xml_prepend_to_var_list(fmi_xml_variable_list_t*, fmi_xml_variable_list_t*);

#ifdef __cplusplus
}
#endif
#endif
