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



/** \file jmi_kinsol_solver.h
 *  \brief Interface to the KINSOL solver.
 */

#ifndef _JMI_KINSOL_SOLVER_H
#define _JMI_KINSOL_SOLVER_H

#include "jmi_common.h"

/*
 *  TODO: Error codes...
 *  Introduce #defines to denote different error codes
 */
#include <nvector/nvector_serial.h>

#include <sundials/sundials_dense.h>

#include <kinsol/kinsol.h>

#if JMI_AD == JMI_AD_CPPAD
/* This must be done outside of 'extern "C"' */
#include <cppad/cppad.hpp>
#include <vector>
#endif /* JMI_AD == JMI_AD_CPPAD */

#ifdef JMI_AD_NONE_AND_CPP
extern "C" {
#endif /* JMI_AD_NONE_AND_CPP */


typedef struct jmi_kinsol_solver_t jmi_kinsol_solver_t;

int jmi_kinsol_solver_new(jmi_kinsol_solver_t** solver, jmi_block_residual_t* block);

int jmi_kinsol_solver_solve(jmi_block_residual_t* block);

int jmi_kinsol_solver_evaluate_jacobian(jmi_block_residual_t* block, jmi_real_t* jacobian);

int jmi_kinsol_solver_evaluate_jacobian_factorization(jmi_block_residual_t* block, jmi_real_t* factorization);

void jmi_kinsol_solver_delete(jmi_block_residual_t* block);

struct jmi_kinsol_solver_t {
    void* kin_mem;                 /**< \brief A pointer to the Kinsol solver */
    N_Vector kin_y;                /**< \brief Work vector for Kinsol y */
    N_Vector kin_y_scale;          /**< \brief Work vector for Kinsol scaling of y */
    N_Vector kin_f_scale;          /**< \brief Work vector for Kinsol scaling of f */
    realtype kin_scale_update_time; /**< \brief The last time when Kinsol scale was updated */
    realtype kin_jac_update_time; /**< \brief The last time when Jacobian was updated */
    realtype kin_ftol;		       /**< \brief Tolerance for F */
    realtype kin_stol;		       /**< \brief Tolerance for Step-size */
    DlsMat J;                       /**< \brief A copy of the Jacobian matrix */
    
    realtype* lapack_work;         /**< \brief work vector for lapack */
    int * lapack_iwork;            /**< \brief work vector for lapack */

    int (*kin_lsolve)(void *kin_mem, N_Vector xx, N_Vector bb, 
              realtype *res_norm );
    
    int num_bounds;
    int* bound_vindex;             /**< \brief variable index for a bound */
    int* bound_kind;               /**< \brief +1 for max, -1 for min */    
    realtype* bounds;              /**< \brief bound vals */
    realtype* active_bounds;
};


#ifdef JMI_AD_NONE_AND_CPP
}
#endif /* JMI_AD_NONE_AND_CPP */
#endif /* _JMI_KINSOL_SOLVER_H */
