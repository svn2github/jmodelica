/*
    Copyright (C) 2015 Modelon AB

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

#ifndef JMI_BRENT_SEARCH_H
#define JMI_BRENT_SEARCH_H

/* A C89 implementation of zero() from
    Brent R.P.:
    Algorithms for Minimization without derivatives. Prentice Hall, 1973, pp. 58-59.
    Download: http://wwwmaths.anu.edu.au/~brent/pd/rpb011i.pdf
    Errata and new print: http://wwwmaths.anu.edu.au/~brent/pub/pub011.html 
*/
#include <sundials/sundials_types.h>
#include <sundials/sundials_math.h>

typedef int (*jmi_brent_func_t)(realtype u, realtype* f, void* data);

/* 
    \brief Solve scalar equation f(u) = 0 in a very reliable and efficient way 
        (u_min < u_max; f(u_min) and f(u_max) must have different signs).
    
    @param f        The function to search for the root.
    @param u_min    Lower bound  of search intervall
    @param u_max    Upper bound of search intervall
    @param f_min    f(u_min), both input and output
    @param f_max    f(u_max), both input and output
    @param tolerance      Relative tolerance for u
    @param u_out    Solution or best guess
    @param f_out    Residual at u_out
    @param data     User data propagated to the function
    @return Error flag (may be forwarded from the call to f() or one of jmi_brent_exit_codes_t)
 */
int jmi_brent_search(jmi_brent_func_t f, realtype u_min, realtype u_max,
                     realtype f_min, realtype f_max, realtype tolerance,
                     realtype* u_out, realtype* f_out, void *data);

#include <kinsol/kinsol.h>

/**< \brief Convert Brent return flag to readable name */
const char *jmi_brent_flag_to_name(int flag);

/**< \brief Error codes used by the Brent solver */
typedef enum {
    JMI_BRENT_SUCCESS = KIN_SUCCESS,
    JMI_BRENT_ILL_INPUT = KIN_ILL_INPUT,
    JMI_BRENT_MEM_FAIL = KIN_MEM_FAIL,
    JMI_BRENT_SYSFUNC_FAIL = KIN_SYSFUNC_FAIL,
    JMI_BRENT_FIRST_SYSFUNC_ERR = KIN_FIRST_SYSFUNC_ERR,
    JMI_BRENT_REPTD_SYSFUNC_ERR = KIN_REPTD_SYSFUNC_ERR,
    JMI_BRENT_ROOT_BRACKETING_FAILED = -16,
    JMI_BRENT_FAILED = -17
}
jmi_brent_exit_codes_t;

/* Interface to the residual function that is compatible with Brent search.
   @param y - input - function argument
   @param f - output - residual value
   @param problem_data - solver object propagated as opaques data
*/
int brentf(realtype y, realtype* f, void* problem_data);

#endif /* JMI_BRENT_SEARCH_H */
