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



/** \file jmi_newton_solvers.h
 *  \brief Newton solvers
 **/

#ifndef _JMI_NEWTON_SOLVERS_H
#define _JMI_NEWTON_SOLVERS_H

#include "jmi.h"
#include <kinsol/kinsol.h>
#include <kinsol/kinsol_dense.h>
#include <nvector/nvector_serial.h>
#include <sundials/sundials_types.h>
#include <sundials/sundials_math.h>

extern void dgesv_(int* N, int* NRHS, double* A, int* LDA, int* IPIV,
                double* B, int* LDB, int* INFO );

extern double dnrm2_(int* N, double* X, int* INCX);


/**
 * \brief A function wrapper for Kinsol f.
 * 
 * @param y An N_Vector (input)
 * @param f An N_Vector (output)
 * @param problem_data A void pointer
 * @return Error code
 */
int kin_f(N_Vector y, N_Vector f, void *problem_data);
#define Ith(v,i)    NV_Ith_S(v,i)

int jmi_simple_newton_solve(jmi_block_residual_t *block);

int jmi_simple_newton_jac(jmi_block_residual_t *block);


#endif
