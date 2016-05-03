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


/** \file jmi_block_log.h
 *  \brief Equiation block solver interface.
 */

#ifndef _JMI_BLOCK_LOG_H
#define _JMI_BLOCK_LOG_H

#include "jmi_block_solver.h"

/** \brief Check and log illegal iv inputs */
int jmi_check_and_log_illegal_iv_input(jmi_block_solver_t* block, double* ivs, int N);

/** \brief Check and log illegal residual output(s) */
int jmi_check_and_log_illegal_residual_output(jmi_block_solver_t *block, double* f, double* ivs, double* heuristic_nominal,int N);

#endif /* _JMI_BLOCK_LOG_H */
