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


/** \file jmi_opt_coll_rk.h
 *  \brief An implementation of a simultaneous optimization method based on
 *  a Runge-Kutta scheme.
 */

/**
 * \defgroup jmi_opt_sim_rk JMI Simultaneous Optimization based on a \
 *  Runge-Kutta scheme
 *
 * \brief This interface provides a particular implementation of a transcription
 * method based on a general Runge-Kutta scheme.
 *
 * Some thoughts in relation to Petzolds book.
 *
 *
 * 1) In the book the form
 *
 * \f$ F(\dot y,y,t)=0\f$
 *
 * is considered. In this formulation, all variables are treated in the same
 * way, regardless of if they occur differentiated or not. The corresponding
 * RK-forumlas are given by 10.13a-c and 10.14. It is noted that 10.14 may
 * be problematic for the algebraic variables. Also, the algebraic variables
 * may not be differentiable, which is why I think this operation seems a bit
 * suspicious.
 *
 * 2) If we assume a DAE of index-1 where we partition \f$y\f$ into states
 * and algebraic variables, we have
 *
 * \f$F(\dot x,x,w,t)=0\f$
 *
 * where \f$w\f$ are the algebraic variables. In line with the expressions on
 * top of p. 269 we get
 *
 * \f$\displaystyle x_{i,j}=x_{i-1}+h\sum_{k=1}^{N_c}a_{j,k} \dot x_{i,k}\f$<br>
 * \f$\displaystyle x_i=x_{i-1}+h\sum_{k=1}^{N_c}b_{k} \dot x_{i-1,k}\f$<br>
 * \f$F(\dot x_{i,j},x_{i,j},w_{i,j},t)=0\f$<br>
 *
 * assuming that the elements are indexed by \f$i\f$ and the "collocation
 * points" are indexed by \f$j\f$. This gives us \f$(2N_x+N_w)N_cN_e + N_eN_x\f$
 * variables and \f$(2N_x+N_w)N_cN_e + N_eN_x\f$ equations. So far so good.
 *
 * Issues:
 *   - Non-unique values in the \f$c\f$ vector in the Butcher tableau gives
 *     several state/derivative/algebraic variable values in the same time
 *     point. How is this handled with regards to constraints and output
 *     of result? In an integrator, the intermediate steps are typically
 *     discarded and only the \f$x_i\f$ variables are stored. This strategy
 *     is different from the Lagrange polynomial approach.
 *   - The method produces the algebraic variables only for \f$w_{i,j}\f$. If
 *     the Butcher tableau don't have special properties these does not correspond
 *     to the element junction points. This is problematic for two reasons:
 *       - How to handle non-uniqueness in \f$c\f$?
 *       - How to handle 'point-wise' accesses to algebraic variables. It is
 *         not enough to introduce new elements as in the case of the states.
 *
 *
*/

/* @{ */


#ifndef _JMI_OPT_SIM_RK_H
#define _JMI_OPT_SIM_RK_H

#include <math.h>
#include "jmi.h"
#include "jmi_opt_sim.h"

int jmi_opt_sim_rk_new(jmi_opt_sim_t **jmi_opt_sim, jmi_t *jmi, int n_e,
		            jmi_real_t *hs, int hs_free,
		            jmi_real_t *p_opt_init, jmi_real_t *dx_init, jmi_real_t *x_init,
		            jmi_real_t *u_init, jmi_real_t *w_init,
		            jmi_real_t *p_opt_lb, jmi_real_t *dx_lb, jmi_real_t *x_lb,
		            jmi_real_t *u_lb, jmi_real_t *w_lb, jmi_real_t t0_lb,
		            jmi_real_t tf_lb, jmi_real_t *hs_lb,
		            jmi_real_t *p_opt_ub, jmi_real_t *dx_ub, jmi_real_t *x_ub,
		            jmi_real_t *u_ub, jmi_real_t *w_ub, jmi_real_t t0_ub,
		            jmi_real_t tf_ub, jmi_real_t *hs_ub,
		            int n_cp, int der_eval_alg);

int jmi_opt_sim_rk_delete(jmi_opt_sim_t *jmi_opt_sim);


#endif
/* @} */


