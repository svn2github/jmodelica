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

#ifndef _JMI_UTIL_H
#define _JMI_UTIL_H

#define VREF_INDEX_MASK 0x0FFFFFFF
#define VREF_TYPE_MASK 0xF0000000

/**
 * \brief Translates a value reference into the corresponding index in the z vector.
 *
 * @param vref A value reference.
 * @return Index in z vector.
 */
int jmi_get_index_from_value_ref(int vref);

/**
 * \brief Translates a value reference into the corresponding primitive type.
 *
 * @param vref A value reference.
 * @return Type.
 */
int jmi_get_type_from_value_ref(int vref);

/**
 * \brief Evaluates the directional derivative with the Finite Difference method.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param res (Output) The DAE residual vector.
 * @param(Output) The directional derivative.
 * @dv Seed vector of size n_x + n_x + n_u + n_w.
 * @return Error code.
 *
 */
int jmi_dae_directional_FD_dF(jmi_t* jmi, jmi_func_t *func, jmi_real_t* res, jmi_real_t* dF, jmi_real_t* dv);


void compute_cpr_groups(jmi_simple_color_info_t *color_info);

/**
 * \brief Performs the graph coloring, that is used in the CAD approach.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param n_col Number of dependent columns in incidence matrix (Columns with zeros are not included).
 * @param n_nz Number of non-zeros in the incidence matrix.
 * @param row The sparse triplet representation of the rows in the incidence matrix
 * @param col The sparse triplet representation of the columns in the incidence matrix
 * @param sparse_repr (Output) Vector that contains information about which column that corresponds to each color.
 * @param offs (Output) Color offset vector, used togheter with sparse_repr, to achieve complete information of each color.
 * @param n_colors (Output) number of colors used.
 * @param map_info (Output) Vector that contains info of which jacobian element that are evaluated when each "color" is used.
 * @param map_off (Output) Offset vector that corresponds to the map_info vector.   
 * @return Error code.
 *
 */
int jmi_dae_cad_color_graph(jmi_t *jmi, jmi_func_t *func, int n_col, int n_nz, int *row, int *col, int *sparse_repr, int *offs, int *n_colors, int *map_info, int *map_off);

/**
 * \brief Help function that are used in the jmi_dae_cad_color_graph function, Calculates the map_info and map_off vectors.
 *
 * @param n_nz Number of non-zeros in the incidence matrix.
 * @param row The sparse triplet representation of the rows in the incidence matrix
 * @param col The sparse triplet representation of the columns in the incidence matrix
 * @param n_col Number of dependent columns in incidence matrix (Columns with zeros are not included).
 * @param color vector of length n_col that contains the color of each column.
 * @param sparse_repr Vector that contains information about which column that corresponds to each color.
 * @param offs Color offset vector, used togheter with sparse_repr, to achieve complete information of each color.
 * @param numb_color vector that contains how many times each color occur.
 * @param map_info (Output) Vector that contains info of which jacobian element that are evaluated when each "color" is used.
 * @param map_off (Output) Offset vector that corresponds to the map_info vector.   
 * @return Error code.
 *
 */
int jmi_dae_cad_get_compression_info(int n_nz, int *row, int *row_off, int n_col, int *color, int *sparse_repr, int *offs, int *numb_color, int *map_info, int *map_off);

/**
 * \brief Help function that are used in the jmi_dae_cad_color_graph function. This function runs the graph coloring algorithm.
 *
 * @param n_col Number of dependent columns in incidence matrix (Columns with zeros are not included).
 * @param inc_vec Matrix that contains info of the connections between every variable (or in this case the connections between all fictive "graph nodes").
 * @param inc_length Vector that contains info of how many variables each variable are connected to.
 * @param color (Output) vector of length n_col that contains the color of each column.
 * @param numb_color (Output) vector that contains how many times each color occur.
 * @return Error code.
 *
 */
int jmi_dae_cad_first_fit(int n_col, int **inc_vec, int *inc_length, int *color, int *numb_col);

/**
 * \brief Help function that are used in the jmi_dae_cad_color_graph function. This function runs the graph coloring algorithm.
 *
 * @param n_col Number of dependent columns in incidence matrix (Columns with zeros are not included).
 * @param n_nz Number of non-zeros in the incidence matrix.
 * @param row The sparse triplet representation of the rows in the incidence matrix
 * @param col The sparse triplet representation of the columns in the incidence matrix
 * @param inc_length (output) Vector that contains info of how many variables each variable are connected to.
 * @return Error code.
 *
 */
int jmi_dae_cad_get_connection_length( int n_col, int n_nz, int *row, int *col, int *inc_length);


/**
 * \brief Help function that are used in the jmi_dae_cad_color_graph function. This function runs the graph coloring algorithm.
 *
 * @param n_col Number of dependent columns in incidence matrix (Columns with zeros are not included).
 * @param n_nz Number of non-zeros in the incidence matrix.
 * @param row The sparse triplet representation of the rows in the incidence matrix
 * @param col The sparse triplet representation of the columns in the incidence matrix
 * @param inc_vec Matrix (Output) that contains info of the connections between every variable (or in this case the connections between all fictive "graph nodes").
 * @param inc_length Vector (Output) that contains info of how many variables each variable are connected to.
 * @return Error code.
 *
 */
int jmi_dae_cad_get_connections( int n_col, int n_nz, int *row, int *col, int **inc_vec, int *inc_length);

/**
 * \brief Compare the evaluated CAD derivative with the FD evaluation
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param sparsity Set to JMI_DER_SPARSE, JMI_DER_DENSE_COL_MAJOR, or JMI_DER_DENS_ROW_MAJOR
 *                to indicate the output format of the Jacobian.
 * @param independent_vars Used to indicate which columns of the full Jacobian should
 *                         be evaluated. The constants JMI_DER_DX, JMI_DER_X etc are used
 *                         to set this argument.
 * @param screen_use Set the flag to JMI_DER_CHECK_SCREEN_ON to print the result of the comparasion on the screen
 *             or JMI_DER_CHECK_SCREEN_OFF to return -1 if the comparasion failes. 
 * @param mask This argument is a vector containing ones for the Jacobian columns that
 *             should be included in the Jacobian and zeros for those which should not.
 *             The size of this vector is the same as the z vector.
 * @return Error code.
 *
 */
int jmi_util_dae_derivative_checker(jmi_t *jmi,jmi_func_t *func, int sparsity, int independent_vars, int screen_use, int *mask);

/**
 * \brief Help function that is used in jmi_func_cad_dF and jmi_func_fd_dF that determines the mapping between the original col vector
 *              in the sparse triplet representation and the decrease col vector due to independent_vars.
 *
 * @param jmi A jmi_t struct.
 * @param func The jmi_func_t struct.
 * @param independent_vars Used to indicate which columns of the full Jacobian should
 *                         be evaluated. The constants JMI_DER_DX, JMI_DER_X etc are used
 *                         to set this argument.
 * @param col_independent_ind (Output) Vector that contains the mapping between the original and decresed col vector in the sparse triplet representation.
 * @return Error code.
 *
 */
int jmi_func_cad_dF_get_independent_ind(jmi_t *jmi, jmi_func_t *func, int independent_vars, int *col_independent_ind);


#ifdef __cplusplus
extern "C" {
#endif

/**
 * \brief Call a jmi_generic_func_t, and handle exceptions and setting the current jmi_t pointer.
 */
int jmi_generic_func(jmi_t *jmi, jmi_generic_func_t func);

/**
 * \brief Evaluates the switches.
 * 
 * Evaluates the switches. Depending on the mode, it either evaluates
 * all the switches at initial time (mode=0) or otherwise (mode=1).
 * 
 * @param jmi The jmi_t struct
 * @param switches The switches (Input, Output)
 * @param eps The epsilon used in determining if a switch or not
 * @param mode Determine if we are evaluating initial switches or not.
 * @return Error code.
 */
int jmi_evaluate_switches(jmi_t* jmi, jmi_real_t* switches, jmi_int_t mode);

/**
 * \brief Compares two sets of switches.
 * 
 * Compares two sets of switches and returns (1) if they are equal and
 * (0) if not.
 * 
 * @param sw_pre The first set of switches
 * @param sw_post The second set of switches
 * @param size The size of the switches
 * @return 1 if equal, 0 if not
 */
int jmi_compare_switches(jmi_real_t* sw_pre, jmi_real_t* sw_post, jmi_int_t size);

/**
 * \brief Turns a switch.
 * 
 * Turns a switch depending on the indicator value and the relation 
 * expression. The relation expression can either be >, >=, <, <=. An
 * Example is if ev_ind is postive and the relation is > then a switch
 * occurs if ev_ind is <= 0.0. If on the other hand the relation is >=
 * , then the switch occurs if ev_ind < -eps.
 * 
 * @param ev_ind The indicator value.
 * @param sw The switch value
 * @param eps The epsilon used for "moving" the zero.
 * @param rel The relation expression
 * @return The new switch value
 */
jmi_real_t jmi_turn_switch(jmi_real_t ev_ind, jmi_real_t sw, jmi_real_t eps, int rel);

#ifdef __cplusplus
}
#endif

#endif
