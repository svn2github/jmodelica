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



/** \file jmi_opt_sim_lp.h
 *  \brief An implementation of a simultaneous optimization method based on
 *  Lagrange polynomials and Radau points.
 **/

/**
 * \defgroup jmi_opt_sim_lp JMI Simultaneous Optimization based on Lagrange \
 * polynomials and Radau points
 *
 * \brief This interface provides a particular implementation of a transcription
 * method based on Lagrange polynomials and Radau points.
 *
 * This implementation provides the call-back functions required by the JMI
 * Simultaneous Optimization interface.
 *
 * \section jmi_opt_sim_lp_mathematical_formulation Mathematical formulation
 *
 * Consider the optimization problem
 *
 *      \f$\displaystyle\min_{p_{opt},u}J(p,q)\f$<br>
 *      subject to <br>
 *      \f$ F(p,v) = 0\f$, \f$[t_0,t_f]\f$ <br>
 *      \f$  F_0(p,v) = 0 \f$<br>
 *      \f$C_{eq}(p,v,q) = 0\f$, \f$[t_0,t_f]\f$ <br>
 *      \f$C_{ineq}(p,v,q) \leq 0,\f$ \f$[t_0,t_f]\f$<br>
 *      \f$H_{eq}(p,q) = 0\f$<br>
 *      \f$H_{ineq}(p,q) \leq 0\f$<br>
 *
 * where
 *
 *   \f$ p = [c_i^T, c_d^T, p_i^T, p_d^T]^T \f$ <br>
 *   \f$v = [dx^T, x^T, u^T, w^T, t]^T\f$ <br>
 *   \f$ q = [dx(t_1)^T, x(t_1)^T, u(t_1)^T, w(t_1)^T, ...,
 *    dx(t_{n_{tp}})^T, x(t_{n_{tp}})^T, u(t_{n_{tp}})^T, w(t_{n_{tp}})^T]^T\f$
 *
 * and where the initial and final times can be free or fixed respectively. For
 * details, see the <a href="group__Jmi.html"> JMI Model interface </a> for
 * details. Notice that the DAE initialization function \f$F_1\f$ is not
 * included in the optimization formulation considered here.
 *
 * The simultaneous transcription method implemented in this interfaces is based
 * on collocation on finite elements using Radau points. The number of elements
 * is denoted \f$n_e\f$, the number of collocation points is denoted
 * \f$n_c\f$ and the collocation points are denoted
 *
 * \f$\tau_j\in (0..1]\f$, \f$j=1..n_c\f$.
 *
 * Notice that since Radau points are used, one collocation
 * point in each element is located the upper element border.
 *
 * The normalized element lengths \f$h_0...h_{n_e-1}\f$ fullfills the condition
 *
 * \f$ \displaystyle \sum_{i=0}^{n_e-1}h_i=1\f$.
 *
 * The element junction times can now be written
 *
 * \f$t_i=t_0 + (t_f-t_0)\displaystyle\sum_{k=0}^{i-1}h_k\f$, \f$i=1..n_e-1\f$
 *
 * and the collocation point times
 *
 * \f$t_{i,j}=t_0 + (t_f-t_0)\left(
 * \displaystyle\sum_{k=0}^{i-1}h_k + \tau_jh_i \right)\f$,
 *    \f$i=0..n_e-1\f$, \f$j=1..n_c\f$.
 *
 * \subsection jmi_opt_sim_lp_vars NLP variables
 *
 * At the initial point \f$t_0\f$, introduce the variables
 *
 * \f$ \dot x_{0,0}, x_{0,0}, u_{0,0}, w_{0,0}\f$,
 *
 * at the collocation points
 *
 * \f$ \dot x_{i,j}, x_{i,j}, u_{i,j}, w_{i,j}\f$,
 *    \f$i=0..n_e-1\f$, \f$j=1..n_c\f$,
 *
 * and at the element junction points \f$t_i\f$
 *
 * \f$x_{i,0}\f$, \f$i=1..n_e\f$.
 *
 * At the interpolation time points, the variables
 *
 * \f$ \dot x^p_i, x^p_i, u^p_i, w^p_i\f$, \f$ i\in 1..n_{tp} \f$
 *
 * are defined. In addition, the parameters \f$p_{opt}\f$ are free variables in
 * the optimization, as may be the initial and final times.
 *
 * The vector of algebraic variables of the NLP is then defined as
 *
 * \f$
 *   \bar x=\left[
 *   \begin{array}{l}
 *     p^{opt}_1 \\
 *     \vdots\\
 *     p^{opt}_{n_{p^{opt}}} \\
 *     \dot x_{0,0}\\
 *     x_{0,0}\\
 *     u_{0,0}\\
 *     w_{0,0}\\
 *     \dot x_{0,1}\\
 *     x_{0,1}\\
 *     u_{0,1}\\
 *     w_{0,1}\\
 *     \vdots\\
 *     \dot x_{0,n_c}\\
 *     x_{0,n_c}\\
 *     u_{0,n_c}\\
 *     w_{0,n_c}\\
 *     \vdots\\
 *     \dot x_{n_e-1,n_c}\\
 *     x_{n_e-1,n_c}\\
 *     u_{n_e-1,n_c}\\
 *     w_{n_e-1,n_c}\\
 *     x_{1,0}\\
 *     \vdots\\
 *     x_{n_e,0}\\
 *     \dot x^p_1\\
 *     x^p_1\\
 *     u^p_1\\
 *     w^p_1\\
 *     \vdots\\
 *     \dot x^p_{n_{tp}}\\
 *     x^p_{n_{tp}}\\
 *     u^p_{n_{tp}}\\
 *     w^p_{n_{tp}}\\
 *     t_0\\
 *     t_f
 *   \end{array}
 *   \right]
 *  \f$
 *
 * where the two last elements are optional.
 *
 *  In total, this gives
 *
 *  \f$ n_{\bar x} = n_{p^{opt}} + (2n_x + n_u + n_w)(n_en_c + 1 + n_{tp})
 *    n_xn_e + n_e + 2 \f$
 *
 * variables in the NLP, assuming that \f$n_{\dot x}=n_x\f$.
 *
 * \subsection jmi_opt_sim_lp_constr Equality constraints representing the DAE
 *
 * A the initial point the relation
 *
 * \f$F_0(p,v_{0,0})=0\f$ ,  \f$v_{0,0} = [\dot x_{0,0}^T, x_{0,0}^T, u_{0,0}^T,
 *   w_{0,0}^T, t_{0}]^T\f$ <br>
 *
 * defines the initial variables. In total this gives \f$2n_x+n_w\f$ equality
 * constraints under normal assumptions. At the collocation points, the DAE
 * residual function gives the relations
 *
 * \f$F(p,v_{i,j})=0\f$, \f$v_{i,j} = [\dot x_{i,j}^T, x_{i,j}^T, u_{i,j}^T,
 *   w_{i,j}^T, t_{i,j}]^T.\f$
 *
 * This gives \f$(n_x+n_w)n_en_c\f$ equality constraints. In order to ensure
 * continuity of the differentiated \f$x\f$ variables, the relations
 *
 * \f$x_{i,n_c}-x_{i+1,0}=0\f$, \f$i=0..n_e-1\f$
 *
 * are introduced. This gives \f$n_en_x\f$ equality constraints. In order to
 * provide an equation for \f$u_{0,0}\f$, the following residual is introduced
 *
 * \f$^{u}r_{0,0}= u_{0,0} -
 *   \displaystyle\sum_{k=1}^{n_c}u_{0,k}L_k^{n_c}(0)\f$<br>
 *
 * where \f$L_k^{n_c}\f$ are Lagrange polynomials of order \f$n_c-1\f$ based
 * on the points \f$[\tau_1..\tau_{n_c}]\f$. This gives \f$n_u\f$ additional
 * equality constraints. In each finite element, the differentiated variables
 * are approximated by
 *
 * \f$x(t) = \displaystyle\sum_{k=0}^{n_c}x_{i,k}L_k^{n_c+1}
 *   \left(\frac{t-t_i}{h_i(t_f-t_0)}\right)\f$, \f$t\in[t_i,t_{i+1}]\f$
 *
 * where \f$L_k^{n_c+1}(\tau)\f$ are Lagrange polynomials of order \f$n_c\f$
 * which are computed based on the points \f$[\tau_0...\tau_{n_c}]\f$,
 * with \f$\tau_0=0\f$. Accordingly, the residual relations for the derivatives
 * \f$\dot x_{i,j} \f$ are written
 *
 * \f$^{\dot x}r_{i,j}=\dot x_{i,j} - \frac{1}{h_i(t_f-t_0)}
 * \displaystyle\sum_{k=0}^{n_c}
 *   x_{i,k} \dot L_k^{n_c+1}(\tau_j)\f$=0, \f$i=0..n_e-1\f$, \f$j=1..n_c\f$,
 *
 * which gives \f$(n_x+n_w)n_en_c\f$ equality constraints. As for the additional
 * time points included in the problem, the following residuals are defined:
 *
 * \f$^{\dot x}r_{l}^p= \dot x_l^p - \frac{1}{h_{i_l}(t_f-t_0)}
 *   \displaystyle\sum_{k=0}^{n_c}x_{i_l,k}\dot L_k^{n_c+1}(\tau_l^p)\f$,
 *   \f$l=1..n_{tp}\f$<br>
 * \f$^{x}r_{l}^p= x_l^p -
 *   \displaystyle\sum_{k=0}^{n_c}x_{i_l,k}L_k^{n_c+1}(\tau_l^p)\f$,
 *   \f$l=1..n_{tp}\f$<br>
 * \f$^{u}r_{l}^p= u_l^p -
 *   \displaystyle\sum_{k=1}^{n_c}u_{i_l,k}L_k^{n_c}(\tau_l^p)\f$,
 *   \f$l=1..n_{tp}\f$<br>
 * \f$^{w}r_{l}^p= w_l^p -
 *   \displaystyle\sum_{k=1}^{n_c}w_{i_l,k}L_k^{n_c}(\tau_l^p)\f$,
 *   \f$l=1..n_{tp}\f$<br>
 *
 * where \f$i_l\f$ are the indices of the elements in which the respective
 * interpolation points reside and \f$\tau_l\f$ are the respective locations
 * within the intervals. This gives \f$(2n_x+n_u+n_w)n_{tp}\f$
 * equality constraints.
 *
 * The number of equality constraints is
 *
 * \f$2n_x+n_w+(n_x+n_w)n_en_c + n_xn_e + n_u + n_xn_en_c +
 *   (2n_x+n_u+n_w)n_{tp}\f$
 *
 * and the number of free variables when considering the total number of
 * variables and the number of equality constraints deriving from the DAE
 * constraint is then
 *
 * \f$n_{p^{opt}} + n_un_en_c + 2\f$
 *
 * which corresponds the number of free optimization parameters, the input
 * profile and, optionally, the free initial and terminal points.
 *
 * \subsection jmi_opt_sim_nlp The NLP problem
 *
 * Based on the above collocation formulation, the optimization problem may
 * be cast as an NPL
 *
 * \f$
 *   \min f(\bar x)
 * \f$
 *
 *   subject to
 *
 * \f$ g(\bar x) \leq 0\f$<br>
 * \f$  h(\bar x) = 0 \f$
 *
 * where \f$x\in R^{n_{\bar x}}\f$, \f$g\in n_g\f$ and \f$h \in n_h\f$ and
 *
 * \f$
 * f(\bar x) = J(\bar x)
 * \f$
 *
 * \f$
 * h(\bar x) = \left[ \begin{array}{l}
 *                      F_0(p,v_{0,0}) \\
 *                      F(p,v_{0,1}) \\
 *                      \vdots\\
 *                      F(p,v_{0,n_c})\\
 *                      \vdots\\
 *                      F(p,v_{n_e-1,n_c})\\
 *                      x_{0,n_c}-x_{1,0}\\
 *                      \vdots \\
 *                      x_{n_e-1,n_c}-x_{n_e,0} \\
 *                      ^{u}r_{0,0} \\
 *                      ^{\dot x}r_{0,1}\\
 *                      \vdots\\
 *                      ^{\dot x}r_{0,n_c}\\
 *                      \vdots\\
 *                      ^{\dot x}r_{n_e-1,n_c}\\
 *                      ^{\dot x}r_{1}^p\\
 *                      ^{x}r_{1}^p\\
 *                      ^{u}r_{1}^p\\
 *                      ^{w}r_{1}^p\\
 *                      \vdots\\
 *                      ^{\dot x}r_{n_{tp}}^p\\
 *                      ^{x}r_{n_{tp}}^p\\
 *                      ^{u}r_{n_{tp}}^p\\
 *                      ^{w}r_{n_{tp}}^p\\
 *                      C_{eq}(p,v_{0,1},q)\\
 *                      \vdots\\
 *                      C_{eq}(p,v_{0,n_c},q)\\
 *                      \vdots\\
 *                      C_{eq}(p,v_{n_e-1,n_c},q)\\
 *                      H_{eq}(p,q)
 *                      \end{array}
 *             \right]
 * \f$
 *
 * Notice that the path and point equality constraints \f$C_{eq}\f$ and
 * \f$H_{eq}\f$ has been introduced. Further, the inequality constraints are
 * defined as
 *
 * \f$
 * g(\bar x) = \left[ \begin{array}{l}
 *                      C_{ineq}(p,v_{0,0},q)\\
 *                      C_{ineq}(p,v_{0,1},q)\\
 *                      \vdots\\
 *                      C_{ineq}(p,v_{0,n_c},q)\\
 *                      \vdots\\
 *                      C_{ineq}(p,v_{n_e-1,n_c},q)\\
 *                      H_{ineq}(p,q)
 *                      \end{array}
 *             \right]
 * \f$
 *
 * \subsection jmi_opt_sim_jac Jacobians
 * In order to avoid excessively large Jacobian matrix formulas, the
 * matrices are split into blocks. For this purpose, introduce
 *
 * \f$
 *   \bar x_1=\left[
 *   \begin{array}{l}
 *     p^{opt}_1 \\
 *     \vdots\\
 *     p^{opt}_{n_{p^{opt}}} \\
 *     \dot x_{0,0}\\
 *     x_{0,0}\\
 *     u_{0,0}\\
 *     w_{0,0}
 *   \end{array}
 *   \right]
 *  \f$
 *
 * \f$
 *   \bar x_2=\left[
 *   \begin{array}{l}
 *     \dot x_{0,1}\\
 *     x_{0,1}\\
 *     u_{0,1}\\
 *     w_{0,1}\\
 *     \vdots\\
 *     \dot x_{0,n_c}\\
 *     x_{0,n_c}\\
 *     u_{0,n_c}\\
 *     w_{0,n_c}\\
 *     \vdots\\
 *     \dot x_{n_e-1,n_c}\\
 *     x_{n_e-1,n_c}\\
 *     u_{n_e-1,n_c}\\
 *     w_{n_e-1,n_c}\\
 *     x_{1,0}\\
 *     \vdots\\
 *     x_{n_e,0}\\
 *   \end{array}
 *   \right]
 *  \f$
 *
 * \f$
 *   \bar x_3=\left[
 *   \begin{array}{l}
 *     \dot x^p_1\\
 *     x^p_1\\
 *     u^p_1\\
 *     w^p_1\\
 *     \vdots\\
 *     \dot x^p_{n_{tp}}\\
 *     x^p_{n_{tp}}\\
 *     u^p_{n_{tp}}\\
 *     w^p_{n_{tp}}\\
 *     t_0\\
 *     t_f
 *   \end{array}
 *   \right]
 *  \f$
 *
 * and
 *
 * \f$
 * h_1(\bar x) = \left[ \begin{array}{l}
 *                      F_0(p,v_{0,0}) \\
 *                      F(p,v_{0,1}) \\
 *                      \vdots\\
 *                      F(p,v_{0,n_c})\\
 *                      \vdots\\
 *                      F(p,v_{n_e-1,n_c})\\
 *                      x_{0,n_c}-x_{1,0}\\
 *                      \vdots \\
 *                      x_{n_e-1,n_c}-x_{n_e,0} \\
 *   \end{array}
 *             \right]
 * \f$
 *
 * \f$
 * h_2(\bar x) = \left[ \begin{array}{l}
 *                      ^{u}r_{0,0} \\
 *                      ^{\dot x}r_{0,1}\\
 *                      \vdots\\
 *                      ^{\dot x}r_{0,n_c}\\
 *                      \vdots\\
 *                      ^{\dot x}r_{n_e-1,n_c}\\
 *                      ^{\dot x}r_{1}^p\\
 *                      ^{x}r_{1}^p\\
 *                      ^{u}r_{1}^p\\
 *                      ^{w}r_{1}^p\\
 *                      \vdots\\
 *                      ^{\dot x}r_{n_{tp}}^p\\
 *                      ^{x}r_{n_{tp}}^p\\
 *                      ^{u}r_{n_{tp}}^p\\
 *                      ^{w}r_{n_{tp}}^p\\
 *   \end{array}
 *             \right]
 * \f$
 *
 * \f$
 * h_3(\bar x) = \left[ \begin{array}{l}
 *                      C_{eq}(p,v_{0,1},q)\\
 *                      \vdots\\
 *                      C_{eq}(p,v_{0,n_c},q)\\
 *                      \vdots\\
 *                      C_{eq}(p,v_{n_e-1,n_c},q)\\
 *                      H_{eq}(p,q)
 *                      \end{array}
 *             \right]
 * \f$
 *
 * The Jacobian of the equality contstraint in then given by
 *
 * \f$
 * \displaystyle \frac{\partial h}{\partial\bar x}=
 *  \left[ \begin{array}{ccc}
 *  \displaystyle \frac{\partial h_1}{\partial \bar x_1} &
 *  \displaystyle\frac{\partial h_1}{\partial \bar x_2} &
 *  \displaystyle\frac{\partial h_1}{\partial \bar x_3}\\
 *  \displaystyle \frac{\partial h_2}{\partial \bar x_1} &
 *  \displaystyle\frac{\partial h_2}{\partial \bar x_2} &
 *  \displaystyle\frac{\partial h_2}{\partial \bar x_3}\\
 *  \displaystyle \frac{\partial h_3}{\partial \bar x_1} &
 *  \displaystyle\frac{\partial h_3}{\partial \bar x_2} &
 *  \displaystyle\frac{\partial h_3}{\partial \bar x_3}
 *  \end{array}
 *  \right]
 * \f$
 *
 * \f$
 *   \displaystyle \frac{\partial h_1}{\partial \bar x_1}=
 *     \left[
 *         \begin{array}{c cccc}
 *           \displaystyle{\frac{\partial F_0}{\partial p^{opt}}} &
 *           \displaystyle{\frac{\partial F_0}{\partial \dot x_{0,0}}} &
 *           \displaystyle{\frac{\partial F_0}{\partial x_{0,0}}} &
 *           \displaystyle{\frac{\partial F_0}{\partial u_{0,0}}} &
 *           \displaystyle{\frac{\partial F_0}{\partial w_{0,0}}} \\
 *           \displaystyle{\frac{\partial F}{\partial p^{opt}}} \\
 *           & &&&\\
 *           \displaystyle{\frac{\partial F}{\partial p^{opt}}} & &&&\\
 *           & &&&\\
 *           \displaystyle{\frac{\partial F}{\partial p^{opt}}} \\
 *           0& & \\
 *           & &\ddots& \\
 *           & &&&0 \\
 *         \end{array}
 *      \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial h_2}{\partial \bar x_1}=
 *     \left[
 *         \begin{array}{c cccc}
 *           0& 0&0&I &0 \\
 *            & &\displaystyle{\frac{\partial ^{\dot x}r_{0,1}}
 *           {\partial x_{0,0}}}&0& \\
 *           & &\vdots&& \\
 *           & &\displaystyle{\frac{\partial ^{\dot x}r_{0,n_c}}
 *           {\partial x_{0,0}}}
 *           &&  \\
 *           & &&&\\
 *           \vdots& \vdots&&\vdots&\vdots\\
 *           & &\displaystyle{\frac{\partial ^{\dot x^p}r_{1}}
 *           {\partial x_{i_1,0}}}&
 *           &  \\
 *           & &\displaystyle{\frac{\partial ^{x^p}r_{1}}{\partial x_{i_1,0}}}&
 *           &  \\
 *           & &&&\\
 *           0& 0&...&0&0\\
 *         \end{array}
 *      \right]
 *  \f$
 *
 *
 * \f$
 *   \displaystyle \frac{\partial h_3}{\partial \bar x_1}=
 *     \left[
 *         \begin{array}{c cccc}
 *           \displaystyle{\frac{\partial C_{eq}}{\partial p^{opt}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial \dot x_{0,0}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial x_{0,0}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial u_{0,0}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial w_{0,0}}} \\
 *           \displaystyle{\frac{\partial C_{eq}}{\partial p^{opt}}} & &&&\\
 *           & &&& \\
 *           \displaystyle{\frac{\partial C_{eq}}{\partial p^{opt}}} & &&&\\
 *           & &&& \\
 *           \displaystyle{\frac{\partial C_{eq}}{\partial p^{opt}}} &
 *           &&&  \\
 *           \displaystyle{\frac{\partial H_{eq}}{\partial p^{opt}}} &
 *           &&&  \\
 *         \end{array}
 *     \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial h_1}{\partial \bar x_2}=
 *     \left[
 *         \begin{array}{c cc ccccccccccc ccc cccc}
 *         0 & &&&&&& ... &&&&&& 0 &0&&\\
 *           \displaystyle{\frac{\partial F}{\partial \dot x_{0,1}}} &
 *           \displaystyle{\frac{\partial F}{\partial x_{0,1}}} &
 *           \displaystyle{\frac{\partial F}{\partial u_{0,1}}} &
 *           \displaystyle{\frac{\partial F}{\partial w_{0,1}}}
 *           &&&&&&&&&&&&\ddots\\
 *           & &&& \ddots  \\
 *           &&&&& \displaystyle{\frac{\partial F}{\partial \dot x_{0,n_c}}} &
 *           \displaystyle{\frac{\partial F}{\partial x_{0,n_c}}} &
 *           \displaystyle{\frac{\partial F}{\partial u_{0,n_c}}} &
 *           \displaystyle{\frac{\partial F}{\partial w_{0,n_c}}}
 *           &&&&&&&\\
 *           & &&&& &&&&   \ddots\\
 *            & &&&& & && &&
 *           \displaystyle{\frac{\partial F}{\partial \dot x_{n_e-1,n_c}}} &
 *           \displaystyle{\frac{\partial F}{\partial x_{n_e-1,n_c}}} &
 *           \displaystyle{\frac{\partial F}{\partial u_{n_e-1,n_c}}} &
 *           \displaystyle{\frac{\partial F}{\partial w_{n_e-1,n_c}}} &&&&0\\
 *             &&&& & &I&&& & &&&&  -I&\\
 *             &&&& & &&&& \ddots &&&& && \ddots \\
 *             &&&& & &&&& & &&&& & & -I\\
 *             &&&& & &&&& & &I&&& & & & -I\\
 *         \end{array}
 *      \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial h_2}{\partial \bar x_2}=
 *     \left[
 *         \begin{array}{c cc ccccccccccc ccc cccc}
 *           &&\displaystyle{\frac{\partial ^{u}r_{0,0}}{\partial u_{0,1}}} && &
 *           &&\displaystyle{\frac{\partial ^{u}r_{0,0}}
 *           {\partial u_{0,n_c}}} & \\
 *           I & \displaystyle{\frac{\partial ^{\dot x}r_{0,1}}
 *           {\partial x_{0,1}}} &&& &
 *           &\displaystyle{\frac{\partial ^{\dot x}r_{0,1}}
 *           {\partial x_{0,n_c}}} &&& \\
 *            &&&& \ddots &&& \\
 *             & \displaystyle{\frac{\partial ^{\dot x}r_{0,n_c}}
 *           {\partial x_{0,1}}} &&& &
 *           I&\displaystyle{\frac{\partial ^{\dot x}r_{0,n_c}}
 *           {\partial x_{0,n_c}}}\\
 *            &&&& & &&&& \ddots &&&& &&  \\
 *            &&&& & &&&& & I &
 *           \displaystyle{\frac{\partial ^{\dot x}r_{n_e-1,n_c}}
 *             {\partial x_{n_e-1,n_c}}}
 *           &&&& &\displaystyle{\frac{\partial ^{\dot x}r_{n_e-1,n_c}}
 *           {\partial x_{n_e-1,0}}}\\
 *             & \displaystyle{\frac{\partial ^{\dot x^p}r_{1}}
 *           {\partial x_{i_1,1}}} &&& &
 *           &\displaystyle{\frac{\partial ^{\dot x^p}r_{1}}
 *           {\partial x_{i_1,n_c}}} \\
 *           & \displaystyle{\frac{\partial ^{x^p}r_{1}}
 *           {\partial x_{i_1,1}}} &&& &
 *           &\displaystyle{\frac{\partial ^{x^p}r_{1}}{\partial x_{i_1,n_c}}}\\
 *             & &\displaystyle{\frac{\partial ^{u^p}r_{1}}
 *           {\partial u_{i_1,1}}} && &
 *           &&\displaystyle{\frac{\partial ^{u^p}r_{1}}
 *           {\partial u_{i_1,n_c}}}\\
 *            & &&\displaystyle{\frac{\partial ^{w^p}r_{1}}
 *           {\partial w_{i_1,1}}} & &
 *           &&&\displaystyle{\frac{\partial ^{w^p}r_{1}}{\partial w_{i_1,n_c}}}
 *         \end{array}
 *      \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial h_3}{\partial \bar x_2}=
 *     \left[
 *         \begin{array}{c cc ccccccccccc ccc cccc}
 *         0 & &&&&&& ... &&&&&& 0 &0&&\\
 *           \displaystyle{\frac{\partial C_{eq}}{\partial \dot x_{0,1}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial x_{0,1}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial u_{0,1}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial w_{0,1}}}
 *           &&&&&&&&&&&&\ddots\\
 *           & &&& \ddots  \\
 *           &&&&& \displaystyle{\frac{\partial C_{eq}}
 *           {\partial \dot x_{0,n_c}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial x_{0,n_c}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial u_{0,n_c}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial w_{0,n_c}}}
 *           &&&&&&&\\
 *           & &&&& &&&&   \ddots\\
 *            & &&&& & && &&
 *           \displaystyle{\frac{\partial C_{eq}}{\partial \dot x_{n_e-1,n_c}}}&
 *           \displaystyle{\frac{\partial C_{eq}}{\partial x_{n_e-1,n_c}}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial u_{n_e-1,n_c}}} &
 *           \displaystyle{\frac{\partial C_{eq}}
 *           {\partial w_{n_e-1,n_c}}} &&&0\\
 *            0 &&&& & &&&&... & &&&&  &&0\\
 *         \end{array}
 *      \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial h_1}{\partial \bar x_3}=
 *     \left[
 *         \begin{array}{ccc cc}
 *           0&&& \displaystyle{\frac{\partial F_0}{\partial t_0}}\\
 *           &\ddots&&\displaystyle{\frac{\partial F}{\partial t_0}} &
 *           \displaystyle{\frac{\partial F}{\partial t_f}}\\
 *           &&& \vdots &\vdots \\
 *           &&&\displaystyle{\frac{\partial F}{\partial t_0}} &
 *           \displaystyle{\frac{\partial F}{\partial t_f}}\\
 *           &&& \vdots& \vdots \\
 *           &&0&\displaystyle{\frac{\partial F}{\partial t_0}} &
 *           \displaystyle{\frac{\partial F}{\partial t_f}}\\
 *           0\\
 *           &\ddots\\
 *           &&&&0
 *         \end{array}
 *      \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial h_2}{\partial \bar x_3}=
 *     \left[
 *         \begin{array}{cccc ccc}
 *           0& &&& ... &&0 \\
 *           &\ddots&&&
 *           \displaystyle{\frac{\partial ^{\dot x}r_{0,1}}{\partial t_0}}&&
 *           \displaystyle{\frac{\partial ^{\dot x}r_{0,1}}{\partial t_f}}\\
 *           &&&&\vdots &&\vdots\\
 *           &&&&
 *           \displaystyle{\frac{\partial ^{\dot x}r_{0,n_c}}{\partial t_0}}&&
 *           \displaystyle{\frac{\partial ^{\dot x}r_{0,n_c}}{\partial t_f}}\\
 *           & &&&\vdots  &&\vdots \\
 *           &&&0&
 *           \displaystyle{\frac{\partial ^{\dot x}r_{n_e-1,n_c}}
 *           {\partial t_0}}&&
 *           \displaystyle{\frac{\partial ^{\dot x}r_{n_e-1,n_c}}
 *           {\partial t_f}}\\
 *           I &&& &
 *           \displaystyle{\frac{\partial ^{\dot x^p}r_{1}}{\partial t_0}} &&
 *           \displaystyle{\frac{\partial ^{\dot x^p}r_{1}}{\partial t_f}}\\
 *           &I&&&0\\
 *           &&I&&&\ddots\\
 *           &&&I&&&0\\
 *         \end{array}
 *      \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial h_3}{\partial \bar x_3}=
 *     \left[
 *         \begin{array}{cccc cc}
 *           \displaystyle{\frac{\partial C_{eq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial w_{i_l}^p}}  &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial t_0}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial t_f}} \\
 *           \displaystyle{\frac{\partial C_{eq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial w_{i_l}^p}}  &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial t_0}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial t_f}}\\
 *            \vdots &&&&&\vdots \\
 *           \displaystyle{\frac{\partial C_{eq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial w_{i_l}^p}}  &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial t_0}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial t_f}}\\
 *            \vdots &&&&&\vdots \\
 *           \displaystyle{\frac{\partial C_{eq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial w_{i_l}^p}}  &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial t_0}} &
 *           \displaystyle{\frac{\partial C_{eq}}{\partial t_f}} \\
 *           \displaystyle{\frac{\partial H_{eq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial H_{eq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial H_{eq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial H_{eq}}{\partial w_{i_l}^p}}  \\
 *         \end{array}
 *      \right]
 *  \f$
 *
 *
 * where
 *
 * \f$
 * \displaystyle{\frac{\partial F_0(p,v_{0,0})}{\partial t_0}} =
 *  \left. \displaystyle{\frac{\partial F_0}{\partial t}}\right|_{p,v_{0,0}}
 * \f$<br>
 * \f$
 * \displaystyle{\frac{\partial F_0(p,v_{0,0})}{\partial t_f}} = 0
 * \f$<br>
 * \f$
 * \displaystyle{\frac{\partial F(p,v_{i,j})}{\partial t_0}} =
 *  \left. \displaystyle{\frac{\partial F}{\partial t}}\right|_{p,v_{i,j}}
 * \left(1-\sum_{k=0}^{i-1}h_k - \tau_jh_i \right)
 * \f$<br>
 * \f$
 * \displaystyle{\frac{\partial F(p,v_{i,j})}{\partial t_f}} =
 *  \left. \displaystyle{\frac{\partial F}{\partial t}}\right|_{p,v_{i,j}}
 * \left(\sum_{k=0}^{i-1}h_k + \tau_jh_i \right)
 * \f$<br>
 * \f$
 * \displaystyle{\frac{\partial ^{u}r_{0,0}}{\partial u_{0,k}}} =
 * -L_k^{N_c}(0)
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{\dot x}r_{i,j}}{\partial x_{i,k}} =
 * -\frac{1}{h_i(t_f-t_0)}\dot{L}_k^{N_c+1}(\tau_j)
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{\dot x}r_{i,j}}{\partial t_0} =
 * -\frac{1}{h_i(t_f-t_0)^2}\sum_{k=0}^{N_c}x_{i,k}\dot{L}_k^{N_c+1}(\tau_j)
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{\dot x}r_{i,j}}{\partial t_f} =
 * \frac{1}{h_i(t_f-t_0)^2}\sum_{k=0}^{N_c}x_{i,k}\dot{L}_k^{N_c+1}(\tau_j)
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{\dot x}r_l^p}{\partial x_{i_l,k}} =
 * -\frac{1}{h_{i_l}(t_f-t_0)}\dot{L}_k^{N_c+1}(\tau_l^p)
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{\dot x}r_{l}^p}{\partial t_0} =
 * -\frac{1}{h_{i_l}(t_f-t_0)^2}\sum_{k=0}^{N_c}x_{i,k}
 * \dot{L}_k^{N_c+1}(\tau_l^p)
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{\dot x}r_{l}^p}{\partial t_f} =
 * \frac{1}{h_{i_l}(t_f-t_0)^2}\sum_{k=0}^{N_c}x_{i,k}
 * \dot{L}_k^{N_c+1}(\tau_{i_l})
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{x}r_{l}^p}{\partial x_{i_l,k}} =
 * -L_k^{N_c+1}(\tau_l^p)
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{u}r_{l}^p}{\partial u_{i_l,k}} =
 * -L_k^{N_c}(\tau_l^p)
 * \f$<br>
 * \f$
 * \displaystyle\frac{\partial ^{w}r_{l}^p}{\partial w_{i_l,k}} =
 * -L_k^{N_c}(\tau_l^p)
 * \f$<br>
 * \f$
 * \displaystyle{\frac{\partial C_{eq}(p,v_{i,j},q)}{\partial t_0}} =
 *  \left. \displaystyle{\frac{\partial C_{eq}}{\partial t}}
 *  \right|_{p,v_{i,j},q}
 * \left(1-\sum_{k=0}^{i-1}h_k - \tau_jh_i \right)
 * \f$<br>
 * \f$
 * \displaystyle{\frac{\partial C_{eq}(p,v_{i,j},q)}{\partial t_f}} =
 *  \left. \displaystyle{\frac{\partial C_{eq}}{\partial t}}
 *  \right|_{p,v_{i,j},q} \left(\sum_{k=0}^{i-1}h_k + \tau_jh_i \right)
 * \f$<br>
 *
 * The Jacobian of the inequality constraints can now be expressed
 *
 * \f$
 * \displaystyle \frac{\partial g}{\partial\bar x}=
 *  \left[ \begin{array}{ccc}
 *  \displaystyle \frac{\partial g}{\partial \bar x_1} &
 *  \displaystyle\frac{\partial g}{\partial \bar x_2} &
 *  \displaystyle\frac{\partial g}{\partial \bar x_3}\\
 *  \end{array}
 *  \right]
 * \f$
 *
 * \f$
 *   \displaystyle \frac{\partial g}{\partial \bar x_1}=
 *     \left[
 *         \begin{array}{c cccc}
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial p^{opt}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial \dot x_{0,0}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial x_{0,0}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial u_{0,0}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial w_{0,0}}} \\
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial p^{opt}}} & &&&\\
 *           & &&& \\
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial p^{opt}}} & &&&\\
 *           & &&& \\
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial p^{opt}}} &
 *           &&&  \\
 *           \displaystyle{\frac{\partial H_{ineq}}{\partial p^{opt}}} &
 *           &&&  \\
 *         \end{array}
 *     \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial g}{\partial \bar x_2}=
 *     \left[
 *         \begin{array}{c cc ccccccccccc ccc cccc}
 *         0 & &&&&&& ... &&&&&& 0 &0&&\\
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial \dot x_{0,1}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial x_{0,1}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial u_{0,1}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial w_{0,1}}}
 *           &&&&&&&&&&&&\ddots\\
 *           & &&& \ddots  \\
 *           &&&&& \displaystyle{\frac{\partial C_{ineq}}
 *           {\partial \dot x_{0,n_c}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial x_{0,n_c}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial u_{0,n_c}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial w_{0,n_c}}}
 *           &&&&&&&\\
 *           & &&&& &&&&   \ddots\\
 *            & &&&& & && &&
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial \dot x_{n_e-1,n_c}}}&
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial x_{n_e-1,n_c}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial u_{n_e-1,n_c}}} &
 *           \displaystyle{\frac{\partial C_{ineq}}
 *           {\partial w_{n_e-1,n_c}}} &&&0\\
 *            0 &&&& & &&&&... & &&&&  &&0\\
 *         \end{array}
 *      \right]
 *  \f$
 *
 * \f$
 *   \displaystyle \frac{\partial g}{\partial \bar x_3}=
 *     \left[
 *         \begin{array}{cccc cc}
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial w_{i_l}^p}}  &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial t_0}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial t_f}} \\
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial w_{i_l}^p}}  &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial t_0}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial t_f}}\\
 *            \vdots &&&&&\vdots \\
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial w_{i_l}^p}}  &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial t_0}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial t_f}}\\
 *            \vdots &&&&&\vdots \\
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial w_{i_l}^p}}  &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial t_0}} &
 *           \displaystyle{\frac{\partial C_{ineq}}{\partial t_f}} \\
 *           \displaystyle{\frac{\partial H_{ineq}}{\partial \dot x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial H_{ineq}}{\partial x_{i_l}^p}} &
 *           \displaystyle{\frac{\partial H_{ineq}}{\partial u_{i_l}^p}} &
 *           \displaystyle{\frac{\partial H_{ineq}}{\partial w_{i_l}^p}}  \\
 *         \end{array}
 *      \right]
 *  \f$
 *
 * where
 *
 * \f$
 * \displaystyle{\frac{\partial C_{ineq}(p,v_{i,j},q)}{\partial t_0}} =
 *  \left. \displaystyle{\frac{\partial C_{ineq}}{\partial t}}
 *  \right|_{p,v_{i,j},q}
 * \left(1-\sum_{k=0}^{i-1}h_k - \tau_jh_i \right)
 * \f$<br>
 * \f$
 * \displaystyle{\frac{\partial C_{ineq}(p,v_{i,j},q)}{\partial t_f}} =
 *  \left. \displaystyle{\frac{\partial C_{ineq}}{\partial t}}
 *  \right|_{p,v_{i,j},q} \left(\sum_{k=0}^{i-1}h_k + \tau_jh_i \right)
 * \f$<br>
 *
 * \subsection jmi_opt_sim_hess Hessian of the Lagrangian
 *
 * \section jmi_opt_sim_lp_create Creation of a jmi_opt_sim_t struct
 *
 */

/* @{ */


#ifndef _JMI_OPT_SIM_LP_H
#define _JMI_OPT_SIM_LP_H

#include <math.h>
#include "jmi.h"
#include "jmi_opt_sim.h"

#ifdef __cplusplus
extern "C" {
#endif


typedef struct {
	jmi_opt_sim_t jmi_opt_sim;
    int n_cp;                      // Number of collocation points
    jmi_real_t *cp;                // Collocation points for algebraic variables
    jmi_real_t *cpp;               // Collocation points for dynamic variables
    jmi_real_t *Lp_coeffs;               // Lagrange polynomial coefficients based on the points in cp
    jmi_real_t *Lpp_coeffs;              // Lagrange polynomial coefficients based on the points in cp plus one more point
    jmi_real_t *Lp_dot_coeffs;               // Lagrange polynomial derivative coefficients based on the points in cp
    jmi_real_t *Lpp_dot_coeffs;              // Lagrange polynomial derivative coefficients based on the points in cp plus one more point
    jmi_real_t *Lp_dot_vals;        // Values of the derivative of the Lagrange polynomials at the points in cp
    jmi_real_t *Lpp_dot_vals;       // Values of the derivative of the Lagrange polynomials at the points in cpp
    int der_eval_alg;                   // Evaluation algorithm used for computation of derivatives
    int dF0_n_nz;
    int dF_dp_n_nz;
    int dF_ddx_dx_du_dw_n_nz;
	int dCeq_dp_n_nz;
	int dCeq_ddx_dx_du_dw_n_nz;
	int dCeq_ddx_p_dx_p_du_p_dw_p_n_nz;
	int dCineq_dp_n_nz;
	int dCineq_ddx_dx_du_dw_n_nz;
	int dCineq_ddx_p_dx_p_du_p_dw_p_n_nz;
	int dHeq_dp_n_nz;
	int dHeq_ddx_p_dx_p_du_p_dw_p_n_nz;
	int dHineq_dp_n_nz;
	int dHineq_ddx_p_dx_p_du_p_dw_p_n_nz;
	int offs_p_opt;
    int offs_dx_0;
    int offs_x_0;
    int offs_u_0;
    int offs_w_0;
    int offs_dx_coll;
    int offs_x_coll;
    int offs_u_coll;
    int offs_w_coll;
    int offs_x_el_junc;
    int offs_dx_p;
    int offs_x_p;
    int offs_u_p;
    int offs_w_p;
    int offs_h;
    int offs_t0;
    int offs_tf;
    int *der_mask;
} jmi_opt_sim_lp_t;

/**
 * \brief Create a new jmi_opt_sim_t struct based on collocation by means
 * of Lagrange polynomials.
 *
 * This function takes as its arguments information about initial guesses,
 * bounds, number of finite elements and number of collocation points. The
 * resulting jmi_opt_sim_t struct contains callback functions which evaluate
 * the constraints and cost function resulting from transcription of the
 * continuous time dynamic optimization problem by means of a simultaneous method
 * based on orthogonal collocation on finite elements and Lagrange polynomials
 * on Radau points. Notice that the returned jmi_opt_sim_t struct is generic in
 * the sense that it represents a general NLP where the particular transcription
 * method is implemented in the cost function and constraints callback functions.
 *
 * @param jmi_opt_sim (Output) The returned jmi_opt_sim_t struct.
 * @param jmi A jmi_t struct representing the dynamic model.
 * @param n_e Number of finite elements.
 * @param hs A vector containing the normalized element lengths: sum(hs)=1.
 * @param hs_free A flag indicating if the elements are free. If hs_free is
 * 0 then the element lenths are assumed to be fixed, otherwise free. NOTICE:
 * THIS FEATURE IS CURRENTLY NOT SUPPORTED.
 * @param p_opt_init Initial guesses for the optimized parameters.
 * @param dx_init Initial guesses for the derivatives.
 * @param x_init Initial guesses for the states.
 * @param u_init Initial guesses for the inputs.
 * @param w_init Initial guesses for the algebraic variables.
 * @param p_opt_lb Lower bounds for the optimized parameters.
 * @param dx_lb Lower bounds for the derivatives.
 * @param x_lb Lower bounds for the states.
 * @param u_lb Lower bounds for the inputs.
 * @param t0_lb Lower bound for interval start time.
 * @param tf_lb Lower bound for interval final time.
 * @param hs_lb Lower bound for element lengths.
 * @param w_lb Lower bounds for the algebraic variables.
 * @param p_opt_ub Upper bounds for the optimized parameters.
 * @param dx_ub Upper bounds for the derivatives.
 * @param x_ub Upper bounds for the states.
 * @param u_ub Upper bounds for the inputs.
 * @param w_ub Upper bounds for the algebraic variables.
 * @param t0_ub Upper bound for interval start time.
 * @param tf_ub Upper bound for interval final time.
 * @param hs_ub Upper bound for element lengths.
 * @param linearity_information_provided 1 if linearity information is provided
 * in the following arguments, otherwise 0.
 * @param p_opt_lin Vector of size n_p_opt. A value of 1 indicates that
 * the corresponding variable appears linearly in all equations and constraints
 * and a value of 0 indicates that it appear non-linearly in some equation
 * or constraint. If this vector is NULL then it is assumed that no
 * information about linearity is provided.
 * @param dx_lin Vector of size n_dx. See argument documentation of p_opt_lin
 * for details on the interpretation of the content of this vector.
 * @param x_lin Vector of size n_x. See argument documentation of p_opt_lin
 * for details on the interpretation of the content of this vector.
 * @param u_lin Vector of size n_u. See argument documentation of p_opt_lin
 * for details on the interpretation of the content of this vector.
 * @param w_lin Vector of size n_w. See argument documentation of p_opt_lin
 * for details on the interpretation of the content of this vector.
 * @param dx_tp_lin Vector of size n_dx*n_tp. The first n_dx elements are used
 * to store linearity information about the dx vector at the first time point.
 * Elements n_dx..2*n_dx-1 are used to store linearity information about the
 * dx vector at the section time point etc.
 * @param x_tp_lin Vector of size n_x*n_tp. The first n_x elements are used
 * to store linearity information about the x vector at the first time point.
 * Elements n_x..2*n_x-1 are used to store linearity information about the
 * x vector at the second time point etc.
 * @param u_tp_lin Vector of size n_u*n_tp. The first n_u elements are used
 * to store linearity information bout the u vector at the first time point.
 * Elements n_u..2*n_u-1 are used to store linearity information about the
 * u vector at the second time point etc.
 * @param w_tp_lin Vector of size n_w*n_tp. The first n_w elements are used
 * to store linearity information about the w vector at the first time point.
 * Elements n_w..2*n_w-1 are used to store linearity information about the
 * w vector at the second time point etc.
 * @param n_cp Number of collocation points. Valid numbers are 2..10.
 * @param der_eval_alg Specification of evaluation algorithm for derivatives.
 * Valid arguments are JMI_DER_SYMBOLIC and JMI_DER_CPPAD. Notice that if
 * JMI_DER_SYMBOLIC is used, then symbolic Jacobians need to be present in
 * in the generated code.
 * @return Error code.
 */
int jmi_opt_sim_lp_new(jmi_opt_sim_t **jmi_opt_sim, jmi_t *jmi, int n_e,
		            jmi_real_t *hs, int hs_free,
		            jmi_real_t *p_opt_init, jmi_real_t *dx_init, jmi_real_t *x_init,
		            jmi_real_t *u_init, jmi_real_t *w_init,
		            jmi_real_t *p_opt_lb, jmi_real_t *dx_lb, jmi_real_t *x_lb,
		            jmi_real_t *u_lb, jmi_real_t *w_lb, jmi_real_t t0_lb,
		            jmi_real_t tf_lb, jmi_real_t *hs_lb,
		            jmi_real_t *p_opt_ub, jmi_real_t *dx_ub, jmi_real_t *x_ub,
		            jmi_real_t *u_ub, jmi_real_t *w_ub, jmi_real_t t0_ub,
		            jmi_real_t tf_ub, jmi_real_t *hs_ub,
		            int linearity_information_provided,
		            int* p_opt_lin, int* dx_lin, int* x_lin, int* u_lin, int* w_lin,
		            int* dx_tp_lin, int* x_tp_lin, int* u_tp_lin, int* w_tp_lin,
		            int n_cp, int der_eval_alg, int n_blocking_factors,
		            int *blocking_factors);

/**
 * \brief Deallocate the fields of a jmi_opt_sim_t struct created by the function
 * jmi_opt_sim_lp_new.
 *
 * @jmi_opt_sim The jmi_opt_sim_t struct to delete.
 * @return Error code.
 */
int jmi_opt_sim_lp_delete(jmi_opt_sim_t *jmi_opt_sim);



// Radau points

static jmi_real_t jmi_opt_sim_lp_1[1] = {1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_2[2] = {3.3333333333333337e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_3[3] = {1.5505102572168217e-001,
                                               6.4494897427831788e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_4[4] = {8.8587959512703929e-002,
                                               4.0946686444073477e-001,
                                               7.8765946176084722e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_5[5] = {5.7104196114518224e-002,
                                               2.7684301363812369e-001,
                                               5.8359043236891683e-001,
                                               8.6024013565621915e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_6[6] = {3.9809857051469333e-002,
                                               1.9801341787360782e-001,
                                               4.3797481024738605e-001,
                                               6.9546427335363603e-001,
                                               9.0146491420117336e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_7[7] = {2.9316427159785663e-002,
                                               1.4807859966848447e-001,
                                               3.3698469028115419e-001,
                                               5.5867151877155008e-001,
                                               7.6923386203005462e-001,
                                               9.2694567131974170e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_8[8] = {2.2479386438713611e-002,
                                               1.1467905316090432e-001,
                                               2.6578982278458951e-001,
                                               4.5284637366944469e-001,
                                               6.4737528288683033e-001,
                                               8.1975930826310772e-001,
                                               9.4373743946307775e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_9[9] = {1.7779915147364544e-002,
                                               9.1323607899792103e-002,
                                               2.1430847939563114e-001,
                                               3.7193216458327227e-001,
                                               5.4518668480342658e-001,
                                               7.1317524285557021e-001,
                                               8.5563374295785399e-001,
                                               9.5536604471002917e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_10[10] = {1.4412409648876801e-002,
                                               7.4387389709196450e-002,
                                               1.7611665616299321e-001,
                                               3.0966757992763827e-001,
                                               4.6197040108101095e-001,
                                               6.1811723469529423e-001,
                                               7.6282301518503881e-001,
                                               8.8192102121000115e-001,
                                               9.6374218711679016e-001,
                                               1.0000000000000000e+000};

// Lagrange polynomial coefficients. Lagrange polynomials based on
// Radau points. The first index denotes polynomial
// and the second index denotes coefficient.
static jmi_real_t jmi_opt_sim_lp_coeffs_1[1][1] = {{1.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lp_coeffs_2[2][2] = {{-1.5000000000000000e+000, 1.5000000000000000e+000},
                                                   {1.5000000000000000e+000, -5.0000000000000011e-001}};

static jmi_real_t jmi_opt_sim_lp_coeffs_3[3][3] = {{2.4158162379719630e+000, -3.9738944426968859e+000, 1.5580782047249224e+000},
                                                   {-5.7491495713052974e+000, 6.6405611093635519e+000, -8.9141153805825557e-001},
                                                   {3.3333333333333339e+000, -2.6666666666666674e+000, 3.3333333333333337e-001}};

static jmi_real_t jmi_opt_sim_lp_coeffs_4[4][4] = {{-4.8912794196729017e+000, 1.0746758781771328e+001, -7.4330170018726225e+000, 1.5775376397741954e+000},
                                                   {1.3954090584570253e+001, -2.6181326475517480e+001, 1.3200912486148248e+001, -9.7367659520102201e-001},
                                                   {-1.7812811164897361e+001, 2.6684567693746160e+001, -9.5178954842756305e+000, 6.4613895542682664e-001},
                                                   {8.7500000000000071e+000, -1.1250000000000011e+001, 3.7500000000000040e+000, -2.5000000000000022e-001}};

static jmi_real_t jmi_opt_sim_lp_coeffs_5[5][5] = {{1.1414409029082462e+001, -3.1054881095723236e+001, 2.9933327727048070e+001, -1.1879263560593634e+001, 1.5864079001863365e+000},
                                                   {-3.5165389444477917e+001, 8.7946344956204456e+001, -7.3334306169638353e+001, 2.1561468539410203e+001, -1.0081178814983849e+000},
                                                   {5.3750332212318270e+001, -1.1793829875179102e+002, 8.0478815606138582e+001, -1.7021823932825626e+001, 7.3097486615979501e-001},
                                                   {-5.5199351796922784e+001, 1.0584683489130974e+002, -6.2277837163548270e+001, 1.2139618954009054e+001, -5.0926488484774746e-001},
                                                   {2.5199999999999957e+001, -4.4799999999999926e+001, 2.5199999999999971e+001, -4.7999999999999998e+000, 2.0000000000000140e-001}};

static jmi_real_t jmi_opt_sim_lp_coeffs_6[6][6] = {{-2.9265438774851106e+001, 9.4612746692610102e+001, -1.1595572961240211e+002, 6.6330337221894737e+001, -1.7313107012600927e+001, 1.5911914853493199e+000},
                                                   {9.3862243458277021e+001, -2.8859954040881206e+002, 3.2683532366348646e+002, -1.6282705310569230e+002, 3.1755042868352419e+001, -1.0260164756115300e+000},
                                                   {-1.5604141784878010e+002, 4.4233879349568235e+002, -4.4461800568958944e+002, 1.8355073841348266e+002, -2.6001275978573837e+001, 7.7116760777840010e-001},
                                                   {1.8980539155673600e+002, -4.8917841274080098e+002, 4.3627049246594476e+002, -1.5672374153332311e+002, 2.0417003947766275e+001, -5.9073369632294026e-001},
                                                   {-1.7536077839138161e+002, 4.1582641296132016e+002, -3.4253208082743930e+002, 1.1633638567030457e+002, -1.4690997158277259e+001, 4.2105774547341840e-001},
                                                   {7.6999999999999829e+001, -1.7499999999999960e+002, 1.3999999999999969e+002, -4.6666666666666586e+001, 5.8333333333333313e+000, -1.6666666666666832e-001}};

static jmi_real_t jmi_opt_sim_lp_coeffs_7[7][7] = {{8.0192571118313495e+001, -2.9991334685292816e+002, 4.4460407199704997e+002, -3.3044796361162071e+002, 1.2770531294598710e+002, -2.3734709815362727e+001, 1.5940642185610621e+000},
                                                   {-2.6339129063052809e+002, 9.5377994351054747e+002, -1.3479394370610592e+003, 9.2856101230388219e+002, -3.1376478422401482e+002, 4.3791109853368695e+001, -1.0365537521965111e+000},
                                                   {4.5903989725135960e+002, -1.5755378874224139e+003, 2.0644088105172696e+003, -1.2704932284472864e+003, 3.5833018973664207e+002, -3.6541603359061675e+001, 7.9382172349081681e-001},
                                                   {-6.0643975001337481e+002, 1.9470107492516181e+003, -2.3409775958036103e+003, 1.2896754064093068e+003, -3.1850024808583032e+002, 2.9864015894140881e+001, -6.3257765224995144e-001},
                                                   {6.5684878289722167e+002, -1.9705443171902198e+003, 2.1979125494283780e+003, -1.1227169721397872e+003, 2.6173837993058413e+002, -2.3736033639779841e+001, 4.9761071360301362e-001},
                                                   {-5.7139306776585136e+002, 1.6240620015605462e+003, -1.7251512562208927e+003, 8.4827888834265218e+002, -1.9265170744622640e+002, 1.7214363923837649e+001, -3.5922239406557838e-001},
                                                   {2.4514285714285938e+002, -6.7885714285714948e+002, 7.0714285714286450e+002, -3.4285714285714681e+002, 7.7142857142858176e+001, -6.8571428571429820e+000, 1.4285714285714821e-001}};

static jmi_real_t jmi_opt_sim_lp_coeffs_8[8][8] = {{-2.3085816523143205e+002, 9.7980528841200726e+002, -1.7017155453484520e+003, 1.5528919867039876e+003, -7.9381355971280118e+002, 2.2323821096678063e+002, -3.1144139898169112e+001, 1.5959241080787296e+000},
                                                   {7.6990929430945539e+002, -3.1966538534958222e+003, 5.3820668269752132e+003, -4.6892414237820230e+003, 2.2260191874091715e+003, -5.4873006841358756e+002, 5.7673331484963498e+001, -1.0432944873711927e+000},
                                                   {-1.3819003387178520e+003, 5.5288130657290540e+003, -8.8486869508107193e+003, 7.1725913980153782e+003, -3.0542660859921375e+003, 6.3131054228954622e+002, -4.8669590446175924e+001, 8.0795993290659407e-001},
                                                   {1.9160856046504819e+003, -7.3076061621358622e+003, 1.0997549563995894e+004, -8.2260511127470436e+003, 3.1531186006670528e+003, -5.7306888079470639e+002, 4.0629916197779259e+001, -6.5752983359440687e-001},
                                                   {-2.2464886031842320e+003, 8.1306968452642932e+003, -1.1510169400172248e+004, 8.0320915088964211e+003, -2.8645405499679196e+003, 4.9155068754922326e+002, -3.3679750058432141e+001, 5.3926167289360893e-001},
                                                   {2.2719920421295251e+003, -7.8313460882505924e+003, 1.0544388395827167e+004, -7.0154076914103907e+003, 2.4049231128886622e+003, -4.0115829086019625e+002, 2.7039216726601023e+001, -4.3069705077571713e-001},
                                                   {-1.9031148339559459e+003, 6.3239159044769194e+003, -8.2418078904668564e+003, 5.3387503343236776e+003, -1.7933157052920315e+003, 2.9498279926294117e+002, -1.9723984006566734e+001, 3.1337565786239047e-001},
                                                   {8.0437500000000000e+002, -2.6276250000000009e+003, 3.3783750000000036e+003, -2.1656250000000045e+003, 7.2187500000000250e+002, -1.1812500000000081e+002, 7.8750000000001226e+000, -1.2500000000000627e-001}};

static jmi_real_t jmi_opt_sim_lp_coeffs_9[9][9] = {{6.9035610596344168e+002, -3.2770693260167855e+003, 6.5204215834559491e+003, -7.0475272864594044e+003, 4.4797768814512046e+003, -1.6915350697083597e+003, 3.6352134388950219e+002, -3.9541429729042932e+001, 1.5971971534948577e+000},
                                                   {-2.3263571802094007e+003, 1.0871956410037421e+004, -2.1175949197701568e+004, 2.2205512776736006e+004, -1.3490283295360343e+004, 4.7365459030300126e+003, -8.9378092696401268e+002, 7.3403382769901526e+001, -1.0478723380169714e+000},
                                                   {4.2585922385047588e+003, -1.9378287062346204e+004, 3.6428947745068937e+004, -3.6382124712903074e+004, 2.0610317460680191e+004, -6.5089246994037312e+003, 1.0330579105619711e+003, -6.2396293547195256e+001, 8.1741338434516597e-001},
                                                   {-6.0920503037760363e+003, 2.6760998461758096e+004, -4.8100379751692068e+004, 4.5323902440857652e+004, -2.3780141942999100e+004, 6.7852307504230102e+003, -9.4965008810488280e+002, 5.2764208365108296e+001, -6.7377483177517394e-001},
                                                   {7.4903564686532463e+003, -3.1605702915971560e+004, 5.4147682660584505e+004, -4.8202867992866304e+004, 2.3685521938909522e+004, -6.3043087155015091e+003, 8.3349480902158723e+002, -4.4741413962536591e+001, 5.6516113304106963e-001},
                                                   {-8.1712910607782860e+003, 3.3106236096994187e+004, -5.4257049198908891e+004, 4.6094377121017329e+004, -2.1633949419633802e+004, 5.5355559522627555e+003, -7.1092366907890164e+002, 3.7515491173276352e+001, -4.7131304767248927e-001},
                                                   {7.9054903909925188e+003, -3.0903132235684428e+004, 4.8892910433753212e+004, -4.0196664569175184e+004, 1.8340648636640624e+004, -4.5895341573660608e+003, 5.8024237685767571e+002, -3.0340939334290752e+001, 3.8006331593299431e-001},
                                                   {-6.4562077704612957e+003, 2.4593889460117935e+004, -3.8027695385670835e+004, 3.0662281111681576e+004, -1.3773001370799277e+004, 3.4058589251527346e+003, -4.2707286729404609e+002, 2.2225883153668043e+001, -2.7798588046056610e-001},
                                                   {2.7011111111110486e+003, -1.0168888888888650e+004, 1.5571111111110742e+004, -1.2456888888888589e+004, 5.5611111111109758e+003, -1.3688888888888555e+003, 1.7111111111110691e+002, -8.8888888888886992e+000, 1.1111111111111326e-001}};

static jmi_real_t jmi_opt_sim_lp_coeffs_10[10][10] = {{-2.1277026297225334e+003, 1.1167769571365932e+004, -2.5035524039945296e+004, 3.1258288058660295e+004, -2.3757874060982482e+004, 1.1277614817081801e+004, -3.2958025830234674e+003, 5.6055935626122027e+002, -4.8926596413450824e+001, 1.5981067179821966e+000},
                                                   {7.2230802184581680e+003, -3.7478905592984374e+004, 8.2748518314995556e+004, -1.0118444551157250e+005, 7.4655257871957641e+004, -3.3894000472151369e+004, 9.2190144427509385e+003, -1.3784502682071529e+003, 9.0982122231763540e+001, -1.0511254786987225e+000},
                                                   {-1.3406900863964809e+004, 6.8201457576460336e+004, -1.4675451862998525e+005, 1.7338976337585752e+005, -1.2200299099283923e+005, 5.1732353023571508e+004, -1.2680473303114741e+004, 1.5982127985563202e+003, -7.7727045637454566e+001, 8.2406109581602793e-001},
                                                   {1.9595521595582726e+004, -9.7066226437353573e+004, 2.0199396598781069e+005, -2.2865181509782263e+005, 1.5214608776568013e+005, -5.9902317362824375e+004, 1.3300500349208893e+004, -1.4813200470578699e+003, 6.6288249869053033e+001, -6.8500309307884766e-001},
                                                   {-2.4862025780776879e+004, 1.1936724724561475e+005, -2.3927459126531205e+005, 2.5892885809454150e+005, -1.6325542551998762e+005, 6.0359814687658261e+004, -1.2525965620334266e+004, 1.3185022728678357e+003, -5.6996691903953511e+001, 5.8257763243308092e-001},
                                                   {2.8402058691740429e+004, -1.3192871745202070e+005, 2.5479275470963874e+005, -2.6458214425319969e+005, 1.5960757482447903e+005, -5.6455979139479430e+004, 1.1267923175149450e+004, -1.1519089711160027e+003, 4.8935820112299893e+001, -4.9740530410255152e-001},
                                                   {-2.9545453378743434e+004, 1.3296443437253070e+005, -2.4845203821837643e+005, 2.4954062812373100e+005, -1.4580423581959200e+005, 5.0133766889878694e+004, -9.7796045179223729e+003, 9.8346107598161711e+002, -4.1377801858241540e+001, 4.1927437045047178e-001},
                                                   {2.7724954333935730e+004, -1.2146959224468695e+005, 2.2119524080031554e+005, -2.1693497261870292e+005, 1.2412694926090837e+005, -4.1944135835637659e+004, 8.0723651542002954e+003, -8.0411350409126840e+002, 3.3644962096540596e+001, -3.4030833767003216e-001},
                                                   {-2.2241332186509251e+004, 9.5624732961073256e+004, -1.7122660765914031e+005, 1.6550303982850633e+005, -9.3553143329623301e+004, 3.1305483391902333e+004, -5.9803570969146822e+003, 5.9265728680529458e+002, -2.4723018496556413e+001, 2.4982239686837665e-001},
                                                   {9.2377999999998556e+003, -3.9382199999999371e+004, 7.0012799999998839e+004, -6.7267199999998833e+004, 3.7837799999999312e+004, -1.2612599999999760e+004, 2.4023999999999528e+003, -2.3759999999999545e+002, 9.8999999999998369e+000, -9.9999999999999561e-002}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_1[1][1] = {{0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_2[2][2] = {{0.0000000000000000e+000, -1.5000000000000000e+000},
                                                       {0.0000000000000000e+000, 1.5000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_3[3][3] = {{0.0000000000000000e+000, 4.8316324759439260e+000, -3.9738944426968859e+000},
                                                       {0.0000000000000000e+000, -1.1498299142610595e+001, 6.6405611093635519e+000},
                                                       {0.0000000000000000e+000, 6.6666666666666679e+000, -2.6666666666666674e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_4[4][4] = {{0.0000000000000000e+000, -1.4673838259018705e+001, 2.1493517563542657e+001, -7.4330170018726225e+000},
                                                       {0.0000000000000000e+000, 4.1862271753710758e+001, -5.2362652951034960e+001, 1.3200912486148248e+001},
                                                       {0.0000000000000000e+000, -5.3438433494692084e+001, 5.3369135387492321e+001, -9.5178954842756305e+000},
                                                       {0.0000000000000000e+000, 2.6250000000000021e+001, -2.2500000000000021e+001, 3.7500000000000040e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_5[5][5] = {{0.0000000000000000e+000, 4.5657636116329847e+001, -9.3164643287169710e+001, 5.9866655454096140e+001, -1.1879263560593634e+001},
                                                       {0.0000000000000000e+000, -1.4066155777791167e+002, 2.6383903486861334e+002, -1.4666861233927671e+002, 2.1561468539410203e+001},
                                                       {0.0000000000000000e+000, 2.1500132884927308e+002, -3.5381489625537307e+002, 1.6095763121227716e+002, -1.7021823932825626e+001},
                                                       {0.0000000000000000e+000, -2.2079740718769114e+002, 3.1754050467392921e+002, -1.2455567432709654e+002, 1.2139618954009054e+001},
                                                       {0.0000000000000000e+000, 1.0079999999999983e+002, -1.3439999999999978e+002, 5.0399999999999942e+001, -4.7999999999999998e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_6[6][6] = {{0.0000000000000000e+000, -1.4632719387425553e+002, 3.7845098677044041e+002, -3.4786718883720630e+002, 1.3266067444378947e+002, -1.7313107012600927e+001},
                                                       {0.0000000000000000e+000, 4.6931121729138511e+002, -1.1543981616352482e+003, 9.8050597099045945e+002, -3.2565410621138460e+002, 3.1755042868352419e+001},
                                                       {0.0000000000000000e+000, -7.8020708924390055e+002, 1.7693551739827294e+003, -1.3338540170687684e+003, 3.6710147682696532e+002, -2.6001275978573837e+001},
                                                       {0.0000000000000000e+000, 9.4902695778368002e+002, -1.9567136509632039e+003, 1.3088114773978343e+003, -3.1344748306664621e+002, 2.0417003947766275e+001},
                                                       {0.0000000000000000e+000, -8.7680389195690805e+002, 1.6633056518452806e+003, -1.0275962424823178e+003, 2.3267277134060913e+002, -1.4690997158277259e+001},
                                                       {0.0000000000000000e+000, 3.8499999999999915e+002, -6.9999999999999841e+002, 4.1999999999999909e+002, -9.3333333333333172e+001, 5.8333333333333313e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_7[7][7] = {{0.0000000000000000e+000, 4.8115542670988100e+002, -1.4995667342646407e+003, 1.7784162879881999e+003, -9.9134389083486212e+002, 2.5541062589197421e+002, -2.3734709815362727e+001},
                                                       {0.0000000000000000e+000, -1.5803477437831684e+003, 4.7688997175527375e+003, -5.3917577482442366e+003, 2.7856830369116465e+003, -6.2752956844802964e+002, 4.3791109853368695e+001},
                                                       {0.0000000000000000e+000, 2.7542393835081575e+003, -7.8776894371120688e+003, 8.2576352420690782e+003, -3.8114796853418593e+003, 7.1666037947328414e+002, -3.6541603359061675e+001},
                                                       {0.0000000000000000e+000, -3.6386385000802488e+003, 9.7350537462580905e+003, -9.3639103832144410e+003, 3.8690262192279206e+003, -6.3700049617166064e+002, 2.9864015894140881e+001},
                                                       {0.0000000000000000e+000, 3.9410926973833302e+003, -9.8527215859510979e+003, 8.7916501977135122e+003, -3.3681509164193617e+003, 5.2347675986116826e+002, -2.3736033639779841e+001},
                                                       {0.0000000000000000e+000, -3.4283584065951081e+003, 8.1203100078027310e+003, -6.9006050248835709e+003, 2.5448366650279568e+003, -3.8530341489245279e+002, 1.7214363923837649e+001},
                                                       {0.0000000000000000e+000, 1.4708571428571563e+003, -3.3942857142857474e+003, 2.8285714285714580e+003, -1.0285714285714405e+003, 1.5428571428571635e+002, -6.8571428571429820e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_8[8][8] = {{0.0000000000000000e+000, -1.6160071566200245e+003, 5.8788317304720440e+003, -8.5085777267422600e+003, 6.2115679468159506e+003, -2.3814406791384035e+003, 4.4647642193356126e+002, -3.1144139898169112e+001},
                                                       {0.0000000000000000e+000, 5.3893650601661875e+003, -1.9179923120974934e+004, 2.6910334134876066e+004, -1.8756965695128092e+004, 6.6780575622275146e+003, -1.0974601368271751e+003, 5.7673331484963498e+001},
                                                       {0.0000000000000000e+000, -9.6733023710249636e+003, 3.3172878394374326e+004, -4.4243434754053596e+004, 2.8690365592061513e+004, -9.1627982579764121e+003, 1.2626210845790924e+003, -4.8669590446175924e+001},
                                                       {0.0000000000000000e+000, 1.3412599232553373e+004, -4.3845636972815177e+004, 5.4987747819979471e+004, -3.2904204450988174e+004, 9.4593558020011587e+003, -1.1461377615894128e+003, 4.0629916197779259e+001},
                                                       {0.0000000000000000e+000, -1.5725420222289624e+004, 4.8784181071585757e+004, -5.7550847000861242e+004, 3.2128366035585685e+004, -8.5936216499037582e+003, 9.8310137509844651e+002, -3.3679750058432141e+001},
                                                       {0.0000000000000000e+000, 1.5903944294906676e+004, -4.6988076529503553e+004, 5.2721941979135838e+004, -2.8061630765641563e+004, 7.2147693386659867e+003, -8.0231658172039249e+002, 2.7039216726601023e+001},
                                                       {0.0000000000000000e+000, -1.3321803837691621e+004, 3.7943495426861518e+004, -4.1209039452334284e+004, 2.1355001337294711e+004, -5.3799471158760944e+003, 5.8996559852588234e+002, -1.9723984006566734e+001},
                                                       {0.0000000000000000e+000, 5.6306250000000000e+003, -1.5765750000000005e+004, 1.6891875000000018e+004, -8.6625000000000182e+003, 2.1656250000000073e+003, -2.3625000000000162e+002, 7.8750000000001226e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_9[9][9] = {{0.0000000000000000e+000, 5.5228488477075334e+003, -2.2939485282117497e+004, 3.9122529500735691e+004, -3.5237636432297018e+004, 1.7919107525804819e+004, -5.0746052091250795e+003, 7.2704268777900438e+002, -3.9541429729042932e+001},
                                                       {0.0000000000000000e+000, -1.8610857441675205e+004, 7.6103694870261941e+004, -1.2705569518620940e+005, 1.1102756388368004e+005, -5.3961133181441372e+004, 1.4209637709090039e+004, -1.7875618539280254e+003, 7.3403382769901526e+001},
                                                       {0.0000000000000000e+000, 3.4068737908038071e+004, -1.3564800943642342e+005, 2.1857368647041364e+005, -1.8191062356451538e+005, 8.2441269842720765e+004, -1.9526774098211194e+004, 2.0661158211239422e+003, -6.2396293547195256e+001},
                                                       {0.0000000000000000e+000, -4.8736402430208291e+004, 1.8732698923230666e+005, -2.8860227851015242e+005, 2.2661951220428827e+005, -9.5120567771996401e+004, 2.0355692251269029e+004, -1.8993001762097656e+003, 5.2764208365108296e+001},
                                                       {0.0000000000000000e+000, 5.9922851749225971e+004, -2.2123992041180091e+005, 3.2488609596350702e+005, -2.4101433996433154e+005, 9.4742087755638087e+004, -1.8912926146504527e+004, 1.6669896180431745e+003, -4.4741413962536591e+001},
                                                       {0.0000000000000000e+000, -6.5370328486226288e+004, 2.3174365267895930e+005, -3.2554229519345332e+005, 2.3047188560508663e+005, -8.6535797678535208e+004, 1.6606667856788266e+004, -1.4218473381578033e+003, 3.7515491173276352e+001},
                                                       {0.0000000000000000e+000, 6.3243923127940150e+004, -2.1632192564979100e+005, 2.9335746260251926e+005, -2.0098332284587593e+005, 7.3362594546562497e+004, -1.3768602472098182e+004, 1.1604847537153514e+003, -3.0340939334290752e+001},
                                                       {0.0000000000000000e+000, -5.1649662163690366e+004, 1.7215722622082554e+005, -2.2816617231402500e+005, 1.5331140555840789e+005, -5.5092005483197107e+004, 1.0217576775458205e+004, -8.5414573458809218e+002, 2.2225883153668043e+001},
                                                       {0.0000000000000000e+000, 2.1608888888888388e+004, -7.1182222222220560e+004, 9.3426666666664445e+004, -6.2284444444442939e+004, 2.2244444444443903e+004, -4.1066666666665660e+003, 3.4222222222221382e+002, -8.8888888888886992e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_coeffs_10[10][10] = {{0.0000000000000000e+000, -1.9149323667502802e+004, 8.9342156570927458e+004, -1.7524866827961706e+005, 1.8754972835196176e+005, -1.1878937030491242e+005, 4.5110459268327206e+004, -9.8874077490704021e+003, 1.1211187125224405e+003, -4.8926596413450824e+001},
                                                       {0.0000000000000000e+000, 6.5007721966123514e+004, -2.9983124474387500e+005, 5.7923962820496887e+005, -6.0710667306943494e+005, 3.7327628935978818e+005, -1.3557600188860547e+005, 2.7657043328252817e+004, -2.7569005364143059e+003, 9.0982122231763540e+001},
                                                       {0.0000000000000000e+000, -1.2066210777568328e+005, 5.4561166061168269e+005, -1.0272816304098967e+006, 1.0403385802551452e+006, -6.1001495496419619e+005, 2.0692941209428603e+005, -3.8041419909344222e+004, 3.1964255971126404e+003, -7.7727045637454566e+001},
                                                       {0.0000000000000000e+000, 1.7635969436024452e+005, -7.7652981149882858e+005, 1.4139577619146749e+006, -1.3719108905869359e+006, 7.6073043882840069e+005, -2.3960926945129750e+005, 3.9901501047626676e+004, -2.9626400941157399e+003, 6.6288249869053033e+001},
                                                       {0.0000000000000000e+000, -2.2375823202699190e+005, 9.5493797796491801e+005, -1.6749221388571844e+006, 1.5535731485672491e+006, -8.1627712759993807e+005, 2.4143925875063305e+005, -3.7577896861002795e+004, 2.6370045457356714e+003, -5.6996691903953511e+001},
                                                       {0.0000000000000000e+000, 2.5561852822566387e+005, -1.0554297396161656e+006, 1.7835492829674713e+006, -1.5874928655191981e+006, 7.9803787412239518e+005, -2.2582391655791772e+005, 3.3803769525448348e+004, -2.3038179422320054e+003, 4.8935820112299893e+001},
                                                       {0.0000000000000000e+000, -2.6590908040869090e+005, 1.0637154749802456e+006, -1.7391642675286350e+006, 1.4972437687423860e+006, -7.2902117909796000e+005, 2.0053506755951478e+005, -2.9338813553767119e+004, 1.9669221519632342e+003, -4.1377801858241540e+001},
                                                       {0.0000000000000000e+000, 2.4952458900542156e+005, -9.7175673795749561e+005, 1.5483666856022088e+006, -1.3016098357122175e+006, 6.2063474630454183e+005, -1.6777654334255063e+005, 2.4217095462600886e+004, -1.6082270081825368e+003, 3.3644962096540596e+001},
                                                       {0.0000000000000000e+000, -2.0017198967858325e+005, 7.6499786368858605e+005, -1.1985862536139821e+006, 9.9301823897103802e+005, -4.6776571664811647e+005, 1.2522193356760933e+005, -1.7941071290744047e+004, 1.1853145736105892e+003, -2.4723018496556413e+001},
                                                       {0.0000000000000000e+000, 8.3140199999998702e+004, -3.1505759999999497e+005, 4.9008959999999189e+005, -4.0360319999999297e+005, 1.8918899999999657e+005, -5.0450399999999041e+004, 7.2071999999998588e+003, -4.7519999999999089e+002, 9.8999999999998369e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_1[1][1] = {{0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_2[2][2] = {{-1.5000000000000000e+000, -1.5000000000000000e+000},
                                                       {1.5000000000000000e+000, 1.5000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_3[3][3] = {{-3.2247448713915894e+000, -8.5773803324704145e-001, 8.5773803324704012e-001},
                                                       {4.8577380332470401e+000, -7.7525512860841328e-001, -4.8577380332470428e+000},
                                                       {-1.6329931618554527e+000, 1.6329931618554530e+000, 4.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_4[4][4] = {{-5.6441078759500876e+000, -1.0923951625919930e+000, 3.9279722479070056e-001, -6.1333769734867083e-001},
                                                       {8.8907397551196681e+000, -1.2211000288946927e+000, -2.0713622171778425e+000, 2.7005312888240454e+000},
                                                       {-5.2094082376126396e+000, 3.3753429231863805e+000, -6.3479209515522861e-001, -9.5871935914753941e+000},
                                                       {1.9627763584430562e+000, -1.0618477316996979e+000, 2.3133570875423599e+000, 7.5000000000000036e+000}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_5[5][5] = {{-8.7559239779383820e+000, -1.4771725091407362e+000, 4.0335296739259441e-001, -2.5747222895190092e-001, 4.8038472266264343e-001},
                                                       {1.4020232546567769e+001, -1.8060777240836323e+000, -2.1328158609906147e+000, 1.0919862533645777e+000, -1.9296667091648310e+000},
                                                       {-8.9441834771237865e+000, 4.9829302097451702e+000, -8.5676524539718457e-001, -3.5197917271527484e+000, 5.1222398733515462e+000},
                                                       {6.0213169205853880e+000, -2.6906317587962150e+000, 3.7121252077103133e+000, -5.8123305258081359e-001, -1.5672957886849415e+001},
                                                       {-2.3414420120909916e+000, 9.9095178227540703e-001, -1.1258970687151293e+000, 3.2665107553208506e+000, 1.1999999999999989e+001}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_6[6][6] = {{-1.2559703476291553e+001, -1.9708240584738412e+000, 4.7103385387540797e-001, -2.3516436042812927e-001, 1.9368194333693012e-001, -3.9582850983287088e-001},
                                                       {2.0273075426320773e+001, -2.5250814079636825e+000, -2.5067421826700880e+000, 9.9410487502893119e-001, -7.6089426018886286e-001, 1.5199633035641256e+000},
                                                       {-1.3391271572648305e+001, 6.9279952973720214e+000, -1.1416181668475041e+000, -3.1928012250524027e+000, 1.9198484936510241e+000, -3.6057314815480268e+000},
                                                       {9.8918725928820930e+000, -4.0650644195781602e+000, 4.7239924539027331e+000, -7.1894419189771952e-001, -5.2542109930169403e+000, 8.0943050994304855e+000},
                                                       {-6.9541488680807877e+000, 2.6558734439037579e+000, -2.4246670510447572e+000, 4.4849266890455439e+000, -5.5465275699956784e-001, -2.3112708411613387e+001},
                                                       {2.7401758978177817e+000, -1.0228988552600944e+000, 8.7800109278422589e-001, -1.3321217866960628e+000, 4.4562275732173600e+000, 1.7499999999999989e+001}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_7[7][7] = {{-1.7055284304421711e+001, -2.5636255666346877e+000, 5.6780734279694656e-001, -2.4980399709663104e-001, 1.6500058257482308e-001, -1.5635154519243599e-001, 3.3700567518956603e-001},
                                                       {2.7655985502972602e+001, -3.3765851454523812e+000, -3.0374211748104969e+000, 1.0577969119949699e+000, -6.4555885400997681e-001, 5.9183834531796009e-001, -1.2611961576820505e+000},
                                                       {-1.8605167998638365e+001, 9.2257793366122129e+000, -1.4837469310039708e+000, -3.4144667139829252e+000, 1.6167797624419080e+000, -1.3617336747754507e+000, 2.8242792375300709e+000},
                                                       {1.4285861237240804e+001, -5.6075711696757686e+000, 5.9593286381636652e+000, -8.9498029378547983e-001, -4.3847168714612188e+000, 2.8819169019919890e+000, -5.6053980861989423e+000},
                                                       {-1.1070009682140475e+001, 4.0147991200829161e+000, -3.3104024600462019e+000, 5.1439535049120302e+000, -6.4999738659466999e-001, -7.2889709326882652e+000, 1.1611118947771182e+001},
                                                       {7.9378673298500448e+000, -2.7852886750572416e+000, 2.1098969499512368e+000, -2.5584449004114305e+000, 5.5157599052838542e+000, -5.3940593874075304e-001, -3.1905809616606408e+001},
                                                       {-3.1492520848629031e+000, 1.0924921001249333e+000, -8.0546236505113633e-001, 9.1594548837011835e-001, -1.6172671382331947e+000, 5.8727068440899277e+000, 2.3999999999999766e+001}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_8[8][8] = {{-2.2242599964336073e+001, -3.2521931152629371e+000, 6.8660629189411182e-001, -2.7995703272426908e-001, 1.6444979911015167e-001, -1.2744641004285739e-001, 1.3167367235616112e-001, -2.9360317730084873e-001},
                                                       {3.6171371117915626e+001, -4.3599941420726864e+000, -3.6869514741383682e+000, 1.1882094936351422e+000, -6.4336246506638162e-001, 4.8061155009233403e-001, -4.8796587479514386e-001, 1.0811358245291984e+000},
                                                       {-2.4602018795925375e+001, 1.1877956852641894e+001, -1.8811856479741564e+000, -3.8555726689761727e+000, 1.6120580831361835e+000, -1.0979538209524833e+000, 1.0710644149832405e+000, -2.3399024862152586e+000},
                                                       {1.9285491806529823e+001, -7.3594220434676387e+000, 7.4125094940935341e+000, -1.1041272031134142e+000, -4.3845652428860262e+000, 2.2985030279694243e+000, -2.0509958690585322e+000, 4.3535853390189843e+000},
                                                       {-1.5572247842670691e+001, 5.4775333981118806e+000, -4.2602558195934819e+000, 6.0270550746427674e+000, -7.7234953699564812e-001, -5.7358844785971854e+000, 3.9830566092370816e+000, -7.9201408431715024e+000},
                                                       {1.2343852935382479e+001, -4.1853202092082142e+000, 2.9678656658451388e+000, -3.2316839088414859e+000, 5.8668578867257679e+000, -6.0993512968667574e-001, -9.6293445326832448e+000, 1.5670952569593521e+001},
                                                       {-8.9482571779968225e+000, 2.9815377691594236e+000, -2.0313844928393650e+000, 2.0233217883838712e+000, -2.8584988926858266e+000, 6.7563649902256024e+000, -5.2980837581898754e-001, -4.2052027226456616e+001},
                                                       {3.5644079211010364e+000, -1.1800985099016703e+000, 7.9279598271294915e-001, -7.6724554300534820e-001, 1.0154103686640328e+000, -1.9642597290041195e+000, 7.5123199557770803e+000, 3.1500000000000320e+001}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_9[9][9] = {{-2.8121619021008335e+001, -4.0350724989723687e+000, 8.2486225432734273e-001, -3.1997767984133674e-001, 1.7475313839470630e-001, -1.2149285049406444e-001, 1.0422600635390467e-001, -1.1404716613786547e-001, 2.6020875840907820e-001},
                                                       {4.5820285652941948e+001, -5.4750355521276219e+000, -4.4417963771916220e+000, 1.3608554744805303e+000, -6.8430396438280638e-001, 4.5782439972977329e-001, -3.8501527664497814e-001, 4.1702666427208612e-001, -9.4781745208845791e-001},
                                                       {-3.1388257476394010e+001, 1.4884627518566219e+001, -2.3330854729130834e+000, -4.4348721108071274e+000, 1.7182858362086364e+000, -1.0446981063518095e+000, 8.3996056074370529e-001, -8.9009551923262364e-001, 2.0066495992311673e+000},
                                                       {2.4917261255807528e+001, -9.3322459347804312e+000, 9.0756125205730740e+000, -1.3443311646904093e+000, -4.6943603085022474e+000, 2.1847862278254624e+000, -1.5931518092387407e+000, 1.6173139685071192e+000, -3.5909923378010191e+000},
                                                       {-2.0572336339695173e+001, 7.0941642255281536e+000, -5.3157955173256255e+000, 7.0966670707268236e+000, -9.1711704254687731e-001, -5.4567254574551782e+000, 3.0520111965221091e+000, -2.8284674497649789e+000, 6.0971498147580760e+000},
                                                       {1.7021026252286941e+001, -5.6484267921099374e+000, 3.8462725162578835e+000, -3.9306407163924888e+000, 6.4939432881774160e+000, -7.0108995651926875e-001, -7.2556027659727462e+000, 5.2258331204780362e+000, -1.0547064365147669e+001},
                                                       {-1.3667446627898432e+001, 4.4461365958017822e+000, -2.8945723455485464e+000, 2.6827971098818537e+000, -3.3996857897138604e+000, 6.7912507706603336e+000, -5.8436218081036984e-001, -1.2277656383992497e+001, 2.0273123637867329e+001},
                                                       {9.9745463768249714e+000, -3.2119296883287163e+000, 2.0457826669166685e+000, -1.8164455014829954e+000, 2.1013636176510815e+000, -3.2623396371900206e+000, 8.1886600277382957e+000, -5.2335960939210224e-001, -5.3551257655264429e+001},
                                                       {-3.9834600728654417e+000, 1.2777821264227729e+000, -8.0728024509691920e-001, 7.0594751812250678e-001, -7.9287877529068140e-001, 1.1524846097804904e+000, -2.3667257586995527e+000, 9.3734523752264334e+000, 3.9999999999996632e+001}};

static jmi_real_t jmi_opt_sim_lp_dot_vals_10[10][10] = {{-3.4692325029699376e+001, -4.9115478561746286e+000, 9.8143401805992170e-001, -3.6775331048787052e-001, 1.9121638423842313e-001, -1.2408990808796005e-001, 9.6223320270546253e-002, -8.8463943703295911e-002, 1.0077041109097706e-001, -2.3369377726768903e-001},
                                                       {5.6603253600356631e+001, -6.7215693675324104e+000, -5.2960018378360871e+000, 1.5666798127560497e+000, -7.4958552758280916e-001, 4.6772377447722135e-001, -3.5511453059936571e-001, 3.2261977204156267e-001, -3.6516285135037663e-001, 8.4474303541749407e-001},
                                                       {-3.8966916656228371e+001, 1.8245679717214713e+001, -2.8390273293468056e+000, -5.1230037481630291e+000, 1.8864617305966078e+000, -1.0679618517505531e+000, 7.7342275262761007e-001, -6.8513036921302728e-001, 7.6532837646557539e-001, -1.7615465313075305e+000},
                                                       {3.1192370903587502e+001, -1.1530523555796620e+001, 1.0944137320037228e+001, -1.6146346353635437e+000, -5.1750239925229806e+000, 2.2367771577521580e+000, -1.4635884582494327e+000, 1.2350870709715878e+000, -1.3470035568102219e+000, 3.0727696381233898e+000},
                                                       {-2.6108160026316927e+001, 8.8807438072868834e+000, -6.4873036779647961e+000, 8.3305128075087325e+000, -1.0823204231916677e+000, -5.6060053772691489e+000, 2.7969974109727573e+000, -2.1353420185659928e+000, 2.2277655206750282e+000, -5.0022084853695432e+000},
                                                       {2.2111298282659487e+001, -7.2317634275915452e+000, 4.7929023928604124e+000, -4.6990352615887687e+000, 7.3161083078769309e+000, -8.0890803868916095e-001, -6.6431381160181928e+000, 3.8832732948435478e+000, -3.6947404485288615e+000, 8.0510255774437383e+000},
                                                       {-1.8554095822475034e+001, 5.9416201571757554e+000, -3.7561373554360102e+000, 3.3272592202039135e+000, -3.9500296610538257e+000, 7.1887761121297444e+000, -6.5546003470650760e-001, -8.9477806431670288e+000, 6.6116291004882584e+000, -1.3484956801704769e+001},
                                                       {1.5020559656935646e+001, -4.7532185448674227e+000, 2.9299357811895241e+000, -2.4724390735858179e+000, 2.6554375982410185e+000, -3.7003260578466524e+000, 7.8790832705096889e+000, -5.6694419107009253e-001, -1.5235067377789399e+001, 2.5417316423304939e+001},
                                                       {-1.1011152125247603e+001, 3.4622889236229177e+000, -2.1062630699522735e+000, 1.7353084415603277e+000, -1.7828633044192692e+000, 2.2657181682259626e+000, -3.7466986022761155e+000, 9.8044738700569312e+000, -5.1881095035546210e-001, -6.6403449078427599e+001},
                                                       {4.4051672164280413e+000, -1.3817098533378100e+000, 8.3632375838786288e-001, -6.8289425284490513e-001, 6.9059888780641288e-001, -8.5170397897753602e-001, 1.3182729875491397e+000, -2.8217928421080654e+000, 1.1455291776230771e+001, 4.9500000000040956e+001}};

// Radau points plus starting point of interval (0)
static jmi_real_t jmi_opt_sim_lp_p_1[2] = {0.0000000000000000e+000,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_2[3] = {0.0000000000000000e+000,
                                               3.3333333333333337e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_3[4] = {0.0000000000000000e+000,
                                               1.5505102572168217e-001,
                                               6.4494897427831788e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_4[5] = {0.0000000000000000e+000,
                                               8.8587959512703929e-002,
                                               4.0946686444073477e-001,
                                               7.8765946176084722e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_5[6] = {0.0000000000000000e+000,
                                               5.7104196114518224e-002,
                                               2.7684301363812369e-001,
                                               5.8359043236891683e-001,
                                               8.6024013565621915e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_6[7] = {0.0000000000000000e+000,
                                               3.9809857051469333e-002,
                                               1.9801341787360782e-001,
                                               4.3797481024738605e-001,
                                               6.9546427335363603e-001,
                                               9.0146491420117336e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_7[8] = {0.0000000000000000e+000,
                                               2.9316427159785663e-002,
                                               1.4807859966848447e-001,
                                               3.3698469028115419e-001,
                                               5.5867151877155008e-001,
                                               7.6923386203005462e-001,
                                               9.2694567131974170e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_8[9] = {0.0000000000000000e+000,
                                               2.2479386438713611e-002,
                                               1.1467905316090432e-001,
                                               2.6578982278458951e-001,
                                               4.5284637366944469e-001,
                                               6.4737528288683033e-001,
                                               8.1975930826310772e-001,
                                               9.4373743946307775e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_9[10] = {0.0000000000000000e+000,
                                               1.7779915147364544e-002,
                                               9.1323607899792103e-002,
                                               2.1430847939563114e-001,
                                               3.7193216458327227e-001,
                                               5.4518668480342658e-001,
                                               7.1317524285557021e-001,
                                               8.5563374295785399e-001,
                                               9.5536604471002917e-001,
                                               1.0000000000000000e+000};

static jmi_real_t jmi_opt_sim_lp_p_10[11] = {0.0000000000000000e+000,
                                               1.4412409648876801e-002,
                                               7.4387389709196450e-002,
                                               1.7611665616299321e-001,
                                               3.0966757992763827e-001,
                                               4.6197040108101095e-001,
                                               6.1811723469529423e-001,
                                               7.6282301518503881e-001,
                                               8.8192102121000115e-001,
                                               9.6374218711679016e-001,
                                               1.0000000000000000e+000};

// Lagrange polynomial coefficients. Lagrange polynomials based on
// Radau points plus the beginning of the interval. The first index
// denotes polynomial and the second index denotes coefficient.
static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_1[2][2] = {{-1.0000000000000000e+000, 1.0000000000000000e+000},
                                                   {1.0000000000000000e+000, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_2[3][3] = {{2.9999999999999996e+000, -3.9999999999999996e+000, 1.0000000000000000e+000},
                                                   {-4.5000000000000000e+000, 4.5000000000000000e+000, -0.0000000000000000e+000},
                                                   {1.5000000000000000e+000, -5.0000000000000011e-001, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_3[4][4] = {{-1.0000000000000000e+001, 1.8000000000000000e+001, -9.0000000000000000e+000, 1.0000000000000000e+000},
                                                   {1.5580782047249222e+001, -2.5629591447076638e+001, 1.0048809399827414e+001, -0.0000000000000000e+000},
                                                   {-8.9141153805825564e+000, 1.0296258113743304e+001, -1.3821427331607485e+000, -0.0000000000000000e+000},
                                                   {3.3333333333333339e+000, -2.6666666666666674e+000, 3.3333333333333337e-001, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_4[5][5] = {{3.4999999999999993e+001, -8.0000000000000000e+001, 6.0000000000000000e+001, -1.6000000000000000e+001, 1.0000000000000000e+000},
                                                   {-5.5213817392096836e+001, 1.2131173176226274e+002, -8.3905499604680415e+001, 1.7807585234514509e+001, -0.0000000000000000e+000},
                                                   {3.4078680832035765e+001, -6.3940037031511494e+001, 3.2239269236543841e+001, -2.3779130370681054e+000, -0.0000000000000000e+000},
                                                   {-2.2614863439938929e+001, 3.3878305269248770e+001, -1.2083769631863442e+001, 8.2032780255359949e-001, -0.0000000000000000e+000},
                                                   {8.7500000000000071e+000, -1.1250000000000011e+001, 3.7500000000000040e+000, -2.5000000000000022e-001, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_5[6][6] = {{-1.2599999999999891e+002, 3.4999999999999699e+002, -3.4999999999999710e+002, 1.4999999999999883e+002, -2.4999999999999837e+001, 1.0000000000000000e+000},
                                                   {1.9988739542347662e+002, -5.4382835603613034e+002, 5.2418788396948969e+002, -2.0802785730090045e+002, 2.7780933944064511e+001, -0.0000000000000000e+000},
                                                   {-1.2702285306879540e+002, 3.1767586907995377e+002, -2.6489491356822725e+002, 7.7883376055118177e+001, -3.6414784980492581e+000, -0.0000000000000000e+000},
                                                   {9.2102833136133356e+001, -2.0209087094360774e+002, 1.3790290440413506e+002, -2.9167414317829795e+001, 1.2525477211691316e+000, -0.0000000000000000e+000},
                                                   {-6.4167375490815630e+001, 1.2304335789978730e+002, -7.2395874805400354e+001, 1.4111895563613244e+001, -5.9200316718454860e-001, -0.0000000000000000e+000},
                                                   {2.5199999999999957e+001, -4.4799999999999926e+001, 2.5199999999999971e+001, -4.7999999999999998e+000, 2.0000000000000140e-001, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_6[7][7] = {{4.6199999999999420e+002, -1.5119999999999809e+003, 1.8899999999999764e+003, -1.1199999999999859e+003, 3.1499999999999625e+002, -3.5999999999999631e+001, 1.0000000000000000e+000},
                                                   {-7.3513046623137654e+002, 2.3766160870732901e+003, -2.9127391606175670e+003, 1.6661787339788143e+003, -4.3489498066313507e+002, 3.9969786459974003e+001, -0.0000000000000000e+000},
                                                   {4.7401961173252096e+002, -1.4574746676663369e+003, 1.6505715984969554e+003, -8.2230312902141293e+002, 1.6036813671193582e+002, -5.1815502536622926e+000, -0.0000000000000000e+000},
                                                   {-3.5627943479361642e+002, 1.0099640051121462e+003, -1.0151679852054756e+003, 4.1908971502220805e+002, -5.9367058036710503e+001, 1.7607579014482893e+000, -0.0000000000000000e+000},
                                                   {2.7291896770119496e+002, -7.0338395728353839e+002, 6.2730827330954207e+002, -2.2535124741574012e+002, 2.9357372808400836e+001, -8.4940911985935852e-001, -0.0000000000000000e+000},
                                                   {-1.9452867840871693e+002, 4.6127853276441920e+002, -3.7997272598343073e+002, 1.2905259410278356e+002, -1.6296804153820656e+001, 4.6708167876565188e-001, -0.0000000000000000e+000},
                                                   {7.6999999999999829e+001, -1.7499999999999960e+002, 1.3999999999999969e+002, -4.6666666666666586e+001, 5.8333333333333313e+000, -1.6666666666666832e-001, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_7[8][8] = {{-1.7159999999999523e+003, 6.4679999999998217e+003, -9.7019999999997381e+003, 7.3499999999998054e+003, -2.9399999999999254e+003, 5.8799999999998636e+002, -4.8999999999999091e+001, 1.0000000000000000e+000},
                                                   {2.7354141990507064e+003, -1.0230214794534351e+004, 1.5165697701626081e+004, -1.1271767934426449e+004, 4.3561008389577837e+003, -8.0960444756789548e+002, 5.4374436894127882e+001, -0.0000000000000000e+000},
                                                   {-1.7787262387691640e+003, 6.4410383785763215e+003, -9.1028645602997331e+003, 6.2707306415830990e+003, -2.1189070191537839e+003, 2.9572882206751956e+002, -7.0000240042594131e+000, -0.0000000000000000e+000},
                                                   {1.3621980775102036e+003, -4.6753990102871012e+003, 6.1261204738852821e+003, -3.7701808571400798e+003, 1.0633426386156561e+003, -1.0843698367594733e+002, 2.3556610919876300e+000, -0.0000000000000000e+000},
                                                   {-1.0855032512608864e+003, 3.4850725047391984e+003, -4.1902576328772448e+003, 2.3084681482334104e+003, -5.7010289120550340e+002, 5.3455411437132462e+001, -1.1322890661061649e+000, -0.0000000000000000e+000},
                                                   {8.5389998454274769e+002, -2.5616973126869825e+003, 2.8572748261860888e+003, -1.4595261955536764e+003, 3.4025852585303613e+002, -3.0856719667981103e+001, 6.4689132676737482e-001, -0.0000000000000000e+000},
                                                   {-6.1642562821651529e+002, 1.7520573770502460e+003, -1.8611136656636015e+003, 9.1513334016103920e+002, -2.0783495021012166e+002, 1.8571060264328814e+001, -3.8753338537536342e-001, -0.0000000000000000e+000},
                                                   {2.4514285714285938e+002, -6.7885714285714948e+002, 7.0714285714286450e+002, -3.4285714285714681e+002, 7.7142857142858176e+001, -6.8571428571429820e+000, 1.4285714285714821e-001, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_8[9][9] = {{6.4349999999996735e+003, -2.7455999999998614e+004, 4.8047999999997599e+004, -4.4351999999997817e+004, 2.3099999999998883e+004, -6.7199999999996871e+003, 1.0079999999999563e+003, -6.3999999999997776e+001, 1.0000000000000000e+000},
                                                   {-1.0269771635486104e+004, 4.3586834146175963e+004, -7.5701156256550967e+004, 6.9080710496155894e+004, -3.5312954909912885e+004, 9.9307964465757632e+003, -1.3854532899765097e+003, 7.0995003018866058e+001, -0.0000000000000000e+000},
                                                   {6.7136000262332846e+003, -2.7874784150952568e+004, 4.6931559675712728e+004, -4.0890130276909636e+004, 1.9410861234491356e+004, -4.7849197677249149e+003, 5.0291077485652903e+002, -9.0975157067905226e+000, -0.0000000000000000e+000},
                                                   {-5.1992221682536692e+003, 2.0801447579164480e+004, -3.3292045790565033e+004, 2.6985951993460767e+004, -1.1491283052126042e+004, 2.3752246631399212e+003, -1.8311307008026557e+002, 3.0398452598443120e+000, -0.0000000000000000e+000},
                                                   {4.2312044791797953e+003, -1.6137053506516648e+004, 2.4285387282406631e+004, -1.8165213615581812e+004, 6.9628880432830247e+003, -1.2654818810871566e+003, 8.9721191468427406e+001, -1.4519931522613254e+000, -0.0000000000000000e+000},
                                                   {-3.4701488650701967e+003, 1.2559479887781945e+004, -1.7779748013926532e+004, 1.2407164316003915e+004, -4.4248531349453433e+003, 7.5929789187696349e+002, -5.2025078727511122e+001, 8.3299700675763799e-001, -0.0000000000000000e+000},
                                                   {2.7715355217415995e+003, -9.5532261839679704e+003, 1.2862785807420036e+004, -8.5578872001765012e+003, 2.9336941815081955e+003, -4.8936106832402265e+002, 3.2984336321707964e+001, -5.2539452304392975e-001, -0.0000000000000000e+000},
                                                   {-2.0165723583443805e+003, 6.7009272283134133e+003, -8.7331577044944661e+003, 5.6570292870451995e+003, -1.9002273622971929e+003, 3.1256871554313477e+002, -2.0899863862334779e+001, 3.3205809662556118e-001, -0.0000000000000000e+000},
                                                   {8.0437500000000000e+002, -2.6276250000000009e+003, 3.3783750000000036e+003, -2.1656250000000045e+003, 7.2187500000000250e+002, -1.1812500000000081e+002, 7.8750000000001226e+000, -1.2500000000000627e-001, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_9[10][10] = {{-2.4309999999998978e+004, 1.1582999999999510e+005, -2.3165999999999010e+005, 2.5225199999998917e+005, -1.6216199999999299e+005, 6.2369999999997293e+004, -1.3859999999999396e+004, 1.6199999999999297e+003, -8.0999999999996774e+001, 1.0000000000000000e+000},
                                                   {3.8827862801458352e+004, -1.8431299018333806e+005, 3.6672962325258611e+005, -3.9637575477991160e+005, 2.5195715751856251e+005, -9.5137409582018736e+004, 2.0445617477729396e+004, -2.2239380447720550e+003, 8.9831539704035364e+001, -0.0000000000000000e+000},
                                                   {-2.5473776537191497e+004, 1.1904869573229123e+005, -2.3187814941496379e+005, 2.4315194381174413e+005, -1.4771956130076476e+005, 5.1865514426755319e+004, -9.7869647018845753e+003, 8.0377226062340719e+002, -1.1474276609469754e+001, -0.0000000000000000e+000},
                                                   {1.9871319373430146e+004, -9.0422400070191783e+004, 1.6998369755504688e+005, -1.6976521328275901e+005, 9.6171264519271994e+004, -3.0371755320925597e+004, 4.8204248076197737e+003, -2.9115177207713998e+002, 3.8141905847605462e+000, -0.0000000000000000e+000},
                                                   {-1.6379466160453783e+004, 7.1951288460739030e+004, -1.2932567906727201e+005, 1.2186066911325179e+005, -6.3936771829463374e+004, 1.8243194314816668e+004, -2.5532884179804910e+003, 1.4186513937085124e+002, -1.8115530086786076e+000, -0.0000000000000000e+000},
                                                   {1.3739067144227820e+004, -5.7972257571491056e+004, 9.9319525164317020e+004, -8.8415343471285247e+004, 4.3444791663335665e+004, -1.1563577928860459e+004, 1.5288245884473749e+003, -8.2066226504905600e+001, 1.0366378137882166e+000, -0.0000000000000000e+000},
                                                   {-1.1457620188917730e+004, 4.6420899251123832e+004, -7.6078144526810007e+004, 6.4632609702566755e+004, -3.0334689315645570e+004, 7.7618453636980776e+003, -9.9684288847765811e+002, 5.2603468150497577e+001, -6.6086568819374736e-001, -0.0000000000000000e+000},
                                                   {9.2393392103306996e+003, -3.6117243493524329e+004, 5.7142335533349258e+004, -4.6978821136972336e+004, 2.1435162869148364e+004, -5.3639003780991943e+003, 6.7814340146500831e+002, -3.5460194953748164e+001, 4.4418925628055200e-001, -0.0000000000000000e+000},
                                                   {-6.7578367539960773e+003, 2.5742896763284713e+004, -3.9804319607374076e+004, 3.2094798932264886e+004, -1.4416465235562804e+004, 3.5649779935254801e+003, -4.4702537803054344e+002, 2.3264259052051610e+001, -2.9097316363691772e-001, -0.0000000000000000e+000},
                                                   {2.7011111111110486e+003, -1.0168888888888650e+004, 1.5571111111110742e+004, -1.2456888888888589e+004, 5.5611111111109758e+003, -1.3688888888888555e+003, 1.7111111111110691e+002, -8.8888888888886992e+000, 1.1111111111111326e-001, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_coeffs_10[11][11] = {{9.2377999999998952e+004, -4.8619999999999430e+005, 1.0939499999999865e+006, -1.3727999999999825e+006, 1.0510499999999860e+006, -5.0450399999999284e+005, 1.5014999999999776e+005, -2.6399999999999593e+004, 2.4749999999999613e+003, -9.9999999999998764e+001, 1.0000000000000000e+000},
                                                   {-1.4762990239375769e+005, 7.7487178365321236e+005, -1.7370810745652369e+006, 2.1688453784059868e+006, -1.6484317778765052e+006, 7.8249335758789652e+005, -2.2867810888794152e+005, 3.8894214771705876e+004, -3.3947547707446552e+003, 1.1088407538476685e+002, -0.0000000000000000e+000},
                                                   {9.7100869471229526e+004, -5.0383412752485485e+005, 1.1123998118294694e+006, -1.3602365388425929e+006, 1.0036009888747056e+006, -4.5564175063345564e+005, 1.2393249015445962e+005, -1.8530698194894929e+004, 1.2230852915721478e+003, -1.4130425638107489e+001, -0.0000000000000000e+000},
                                                   {-7.6125115909292159e+004, 3.8725160392178316e+005, -8.3328017819147208e+005, 9.8451655370624328e+005, -6.9273965138156712e+005, 2.9373912809072435e+005, -7.2000420513203280e+004, 9.0747396264280651e+003, -4.4133841358831745e+002, 4.6790639441471802e+000, -0.0000000000000000e+000},
                                                   {6.3279215732437056e+004, -3.1345298225934908e+005, 6.5229290723624267e+005, -7.3837828019081941e+005, 4.9132068588269065e+005, -1.9344071270496599e+005, 4.2950897062963108e+004, -4.7835813080724129e+003, 2.1406260831225211e+002, -2.2120594388308779e+000, -0.0000000000000000e+000},
                                                   {-5.3817356528902557e+004, 2.5838721910818384e+005, -5.1794355375454650e+005, 5.6048798253881151e+005, -3.5338936247424030e+005, 1.3065732035302749e+005, -2.7114216822167607e+004, 2.8540838758988443e+003, -1.2337736740401813e+002, 1.2610713393538833e+000, -0.0000000000000000e+000},
                                                   {4.5949307182384975e+004, -2.1343640016291724e+005, 4.1220781497095892e+005, -4.2804524676233548e+005, 2.5821570062378026e+005, -9.1335390716471171e+004, 1.8229427271517608e+004, -1.8635768531577110e+003, 7.9169156537793683e+001, -8.0471029795464522e-001, -0.0000000000000000e+000},
                                                   {-3.8731727793473241e+004, 1.7430574553427353e+005, -3.2570076318175730e+005, 3.2712781753602391e+005, -1.9113769893823154e+005, 6.5721361170149903e+004, -1.2820279833258734e+004, 1.2892388619699136e+003, -5.4242990883284364e+001, 5.4963518680511747e-001, -0.0000000000000000e+000},
                                                   {3.1437003617281873e+004, -1.3773295944123194e+005, 2.5081071374944018e+005, -2.4598004515309865e+005, 1.4074610568937959e+005, -4.7559968326971117e+004, 9.1531610655169115e+003, -9.1177496028841665e+002, 3.8149631642048298e+001, -3.8587167046219967e-001, -0.0000000000000000e+000},
                                                   {-2.3078093377906629e+004, 9.9222317170894021e+004, -1.7766847809308398e+005, 1.7172957876176271e+005, -9.7072790399997422e+004, 3.2483255180058433e+004, -6.2053494978838744e+003, 6.1495418041036112e+002, -2.5653145443928125e+001, 2.5922119028094609e-001, -0.0000000000000000e+000},
                                                   {9.2377999999998556e+003, -3.9382199999999371e+004, 7.0012799999998839e+004, -6.7267199999998833e+004, 3.7837799999999312e+004, -1.2612599999999760e+004, 2.4023999999999528e+003, -2.3759999999999545e+002, 9.8999999999998369e+000, -9.9999999999999561e-002, 0.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_1[2][2] = {{0.0000000000000000e+000, -1.0000000000000000e+000},
                                                       {0.0000000000000000e+000, 1.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_2[3][3] = {{0.0000000000000000e+000, 5.9999999999999991e+000, -3.9999999999999996e+000},
                                                       {0.0000000000000000e+000, -9.0000000000000000e+000, 4.5000000000000000e+000},
                                                       {0.0000000000000000e+000, 3.0000000000000000e+000, -5.0000000000000011e-001}};
static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_3[4][4] = {{0.0000000000000000e+000, -3.0000000000000000e+001, 3.6000000000000000e+001, -9.0000000000000000e+000},
                                                       {0.0000000000000000e+000, 4.6742346141747667e+001, -5.1259182894153277e+001, 1.0048809399827414e+001},
                                                       {0.0000000000000000e+000, -2.6742346141747667e+001, 2.0592516227486609e+001, -1.3821427331607485e+000},
                                                       {0.0000000000000000e+000, 1.0000000000000002e+001, -5.3333333333333348e+000, 3.3333333333333337e-001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_4[5][5] = {{0.0000000000000000e+000, 1.3999999999999997e+002, -2.4000000000000000e+002, 1.2000000000000000e+002, -1.6000000000000000e+001},
                                                       {0.0000000000000000e+000, -2.2085526956838734e+002, 3.6393519528678820e+002, -1.6781099920936083e+002, 1.7807585234514509e+001},
                                                       {0.0000000000000000e+000, 1.3631472332814306e+002, -1.9182011109453447e+002, 6.4478538473087681e+001, -2.3779130370681054e+000},
                                                       {0.0000000000000000e+000, -9.0459453759755718e+001, 1.0163491580774631e+002, -2.4167539263726884e+001, 8.2032780255359949e-001},
                                                       {0.0000000000000000e+000, 3.5000000000000028e+001, -3.3750000000000028e+001, 7.5000000000000080e+000, -2.5000000000000022e-001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_5[6][6] = {{0.0000000000000000e+000, -6.2999999999999454e+002, 1.3999999999999879e+003, -1.0499999999999914e+003, 2.9999999999999767e+002, -2.4999999999999837e+001},
                                                       {0.0000000000000000e+000, 9.9943697711738309e+002, -2.1753134241445214e+003, 1.5725636519084692e+003, -4.1605571460180090e+002, 2.7780933944064511e+001},
                                                       {0.0000000000000000e+000, -6.3511426534397697e+002, 1.2707034763198151e+003, -7.9468474070468176e+002, 1.5576675211023635e+002, -3.6414784980492581e+000},
                                                       {0.0000000000000000e+000, 4.6051416568066679e+002, -8.0836348377443096e+002, 4.1370871321240520e+002, -5.8334828635659591e+001, 1.2525477211691316e+000},
                                                       {0.0000000000000000e+000, -3.2083687745407815e+002, 4.9217343159914918e+002, -2.1718762441620106e+002, 2.8223791127226487e+001, -5.9200316718454860e-001},
                                                       {0.0000000000000000e+000, 1.2599999999999979e+002, -1.7919999999999970e+002, 7.5599999999999909e+001, -9.5999999999999996e+000, 2.0000000000000140e-001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_6[7][7] = {{0.0000000000000000e+000, 2.7719999999999654e+003, -7.5599999999999045e+003, 7.5599999999999054e+003, -3.3599999999999577e+003, 6.2999999999999250e+002, -3.5999999999999631e+001},
                                                       {0.0000000000000000e+000, -4.4107827973882595e+003, 1.1883080435366450e+004, -1.1650956642470268e+004, 4.9985362019364429e+003, -8.6978996132627015e+002, 3.9969786459974003e+001},
                                                       {0.0000000000000000e+000, 2.8441176703951260e+003, -7.2873733383316849e+003, 6.6022863939878216e+003, -2.4669093870642387e+003, 3.2073627342387164e+002, -5.1815502536622926e+000},
                                                       {0.0000000000000000e+000, -2.1376766087616984e+003, 5.0498200255607308e+003, -4.0606719408219024e+003, 1.2572691450666241e+003, -1.1873411607342101e+002, 1.7607579014482893e+000},
                                                       {0.0000000000000000e+000, 1.6375138062071696e+003, -3.5169197864176922e+003, 2.5092330932381683e+003, -6.7605374224722038e+002, 5.8714745616801672e+001, -8.4940911985935852e-001},
                                                       {0.0000000000000000e+000, -1.1671720704523016e+003, 2.3063926638220960e+003, -1.5198909039337229e+003, 3.8715778230835065e+002, -3.2593608307641311e+001, 4.6708167876565188e-001},
                                                       {0.0000000000000000e+000, 4.6199999999999898e+002, -8.7499999999999795e+002, 5.5999999999999875e+002, -1.3999999999999977e+002, 1.1666666666666663e+001, -1.6666666666666832e-001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_7[8][8] = {{0.0000000000000000e+000, -1.2011999999999665e+004, 3.8807999999998930e+004, -4.8509999999998690e+004, 2.9399999999999221e+004, -8.8199999999997763e+003, 1.1759999999999727e+003, -4.8999999999999091e+001},
                                                       {0.0000000000000000e+000, 1.9147899393354946e+004, -6.1381288767206104e+004, 7.5828488508130409e+004, -4.5087071737705795e+004, 1.3068302516873351e+004, -1.6192088951357910e+003, 5.4374436894127882e+001},
                                                       {0.0000000000000000e+000, -1.2451083671384147e+004, 3.8646230271457927e+004, -4.5514322801498667e+004, 2.5082922566332396e+004, -6.3567210574613518e+003, 5.9145764413503912e+002, -7.0000240042594131e+000},
                                                       {0.0000000000000000e+000, 9.5353865425714248e+003, -2.8052394061722607e+004, 3.0630602369426411e+004, -1.5080723428560319e+004, 3.1900279158469684e+003, -2.1687396735189466e+002, 2.3556610919876300e+000},
                                                       {0.0000000000000000e+000, -7.5985227588262042e+003, 2.0910435028435189e+004, -2.0951288164386224e+004, 9.2338725929336415e+003, -1.7103086736165101e+003, 1.0691082287426492e+002, -1.1322890661061649e+000},
                                                       {0.0000000000000000e+000, 5.9772998917992336e+003, -1.5370183876121895e+004, 1.4286374130930444e+004, -5.8381047822147057e+003, 1.0207755775591083e+003, -6.1713439335962207e+001, 6.4689132676737482e-001},
                                                       {0.0000000000000000e+000, -4.3149793975156072e+003, 1.0512344262301476e+004, -9.3055683283180078e+003, 3.6605333606441568e+003, -6.2350485063036501e+002, 3.7142120528657628e+001, -3.8753338537536342e-001},
                                                       {0.0000000000000000e+000, 1.7160000000000157e+003, -4.0731428571428969e+003, 3.5357142857143226e+003, -1.3714285714285872e+003, 2.3142857142857451e+002, -1.3714285714285964e+001, 1.4285714285714821e-001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_8[9][9] = {{0.0000000000000000e+000, 5.1479999999997388e+004, -1.9219199999999031e+005, 2.8828799999998556e+005, -2.2175999999998909e+005, 9.2399999999995533e+004, -2.0159999999999061e+004, 2.0159999999999127e+003, -6.3999999999997776e+001},
                                                       {0.0000000000000000e+000, -8.2158173083888832e+004, 3.0510783902323176e+005, -4.5420693753930577e+005, 3.4540355248077947e+005, -1.4125181963965154e+005, 2.9792389339727291e+004, -2.7709065799530194e+003, 7.0995003018866058e+001},
                                                       {0.0000000000000000e+000, 5.3708800209866276e+004, -1.9512348905666798e+005, 2.8158935805427638e+005, -2.0445065138454817e+005, 7.7643444937965425e+004, -1.4354759303174746e+004, 1.0058215497130581e+003, -9.0975157067905226e+000},
                                                       {0.0000000000000000e+000, -4.1593777346029354e+004, 1.4561013305415137e+005, -1.9975227474339021e+005, 1.3492975996730383e+005, -4.5965132208504168e+004, 7.1256739894197635e+003, -3.6622614016053114e+002, 3.0398452598443120e+000},
                                                       {0.0000000000000000e+000, 3.3849635833438362e+004, -1.1295937454561653e+005, 1.4571232369443978e+005, -9.0826068077909062e+004, 2.7851552173132099e+004, -3.7964456432614697e+003, 1.7944238293685481e+002, -1.4519931522613254e+000},
                                                       {0.0000000000000000e+000, -2.7761190920561574e+004, 8.7916359214473618e+004, -1.0667848808355919e+005, 6.2035821580019576e+004, -1.7699412539781373e+004, 2.2778936756308904e+003, -1.0405015745502224e+002, 8.3299700675763799e-001},
                                                       {0.0000000000000000e+000, 2.2172284173932796e+004, -6.6872583287775793e+004, 7.7176714844520218e+004, -4.2789436000882502e+004, 1.1734776726032782e+004, -1.4680832049720680e+003, 6.5968672643415928e+001, -5.2539452304392975e-001},
                                                       {0.0000000000000000e+000, -1.6132578866755044e+004, 4.6906490598193894e+004, -5.2398946226966800e+004, 2.8285146435225997e+004, -7.6009094491887718e+003, 9.3770614662940432e+002, -4.1799727724669559e+001, 3.3205809662556118e-001},
                                                       {0.0000000000000000e+000, 6.4350000000000000e+003, -1.8393375000000007e+004, 2.0270250000000022e+004, -1.0828125000000022e+004, 2.8875000000000100e+003, -3.5437500000000244e+002, 1.5750000000000245e+001, -1.2500000000000627e-001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_9[10][10] = {{0.0000000000000000e+000, -2.1878999999999080e+005, 9.2663999999996077e+005, -1.6216199999999306e+006, 1.5135119999999350e+006, -8.1080999999996496e+005, 2.4947999999998917e+005, -4.1579999999998188e+004, 3.2399999999998595e+003, -8.0999999999996774e+001},
                                                       {0.0000000000000000e+000, 3.4945076521312515e+005, -1.4745039214667045e+006, 2.5671073627681029e+006, -2.3782545286794696e+006, 1.2597857875928124e+006, -3.8054963832807494e+005, 6.1336852433188193e+004, -4.4478760895441101e+003, 8.9831539704035364e+001},
                                                       {0.0000000000000000e+000, -2.2926398883472348e+005, 9.5238956585832988e+005, -1.6231470459047465e+006, 1.4589116628704648e+006, -7.3859780650382384e+005, 2.0746205770702127e+005, -2.9360894105653726e+004, 1.6075445212468144e+003, -1.1474276609469754e+001},
                                                       {0.0000000000000000e+000, 1.7884187436087133e+005, -7.2337920056153426e+005, 1.1898858828853280e+006, -1.0185912796965541e+006, 4.8085632259636000e+005, -1.2148702128370239e+005, 1.4461274422859322e+004, -5.8230354415427996e+002, 3.8141905847605462e+000},
                                                       {0.0000000000000000e+000, -1.4741519544408406e+005, 5.7561030768591224e+005, -9.0527975347090408e+005, 7.3116401467951073e+005, -3.1968385914731689e+005, 7.2972777259266673e+004, -7.6598652539414725e+003, 2.8373027874170248e+002, -1.8115530086786076e+000},
                                                       {0.0000000000000000e+000, 1.2365160429805038e+005, -4.6377806057192845e+005, 6.9523667615021917e+005, -5.3049206082771148e+005, 2.1722395831667833e+005, -4.6254311715441836e+004, 4.5864737653421253e+003, -1.6413245300981120e+002, 1.0366378137882166e+000},
                                                       {0.0000000000000000e+000, -1.0311858170025957e+005, 3.7136719400899066e+005, -5.3254701168767002e+005, 3.8779565821540053e+005, -1.5167344657822786e+005, 3.1047381454792310e+004, -2.9905286654329743e+003, 1.0520693630099515e+002, -6.6086568819374736e-001},
                                                       {0.0000000000000000e+000, 8.3154052892976295e+004, -2.8893794794819463e+005, 3.9999634873344481e+005, -2.8187292682183400e+005, 1.0717581434574182e+005, -2.1455601512396777e+004, 2.0344302043950249e+003, -7.0920389907496329e+001, 4.4418925628055200e-001},
                                                       {0.0000000000000000e+000, -6.0820530785964693e+004, 2.0594317410627770e+005, -2.7863023725161853e+005, 1.9256879359358933e+005, -7.2082326177814015e+004, 1.4259911974101920e+004, -1.3410761340916304e+003, 4.6528518104103220e+001, -2.9097316363691772e-001},
                                                       {0.0000000000000000e+000, 2.4309999999999436e+004, -8.1351111111109203e+004, 1.0899777777777519e+005, -7.4741333333331539e+004, 2.7805555555554878e+004, -5.4755555555554220e+003, 5.1333333333332075e+002, -1.7777777777777398e+001, 1.1111111111111326e-001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_coeffs_10[11][11] = {{0.0000000000000000e+000, 9.2377999999998952e+005, -4.3757999999999488e+006, 8.7515999999998920e+006, -9.6095999999998771e+006, 6.3062999999999162e+006, -2.5225199999999641e+006, 6.0059999999999104e+005, -7.9199999999998778e+004, 4.9499999999999227e+003, -9.9999999999998764e+001},
                                                       {0.0000000000000000e+000, -1.4762990239375769e+006, 6.9738460528789116e+006, -1.3896648596521895e+007, 1.5181917648841908e+007, -9.8905906672590300e+006, 3.9124667879394824e+006, -9.1471243555176607e+005, 1.1668264431511762e+005, -6.7895095414893103e+003, 1.1088407538476685e+002},
                                                       {0.0000000000000000e+000, 9.7100869471229520e+005, -4.5345071477236934e+006, 8.8991984946357552e+006, -9.5216557718981504e+006, 6.0216059332482340e+006, -2.2782087531672781e+006, 4.9572996061783849e+005, -5.5592094584684790e+004, 2.4461705831442955e+003, -1.4130425638107489e+001},
                                                       {0.0000000000000000e+000, -7.6125115909292153e+005, 3.4852644352960484e+006, -6.6662414255317766e+006, 6.8916158759437026e+006, -4.1564379082894027e+006, 1.4686956404536217e+006, -2.8800168205281312e+005, 2.7224218879284195e+004, -8.8267682717663490e+002, 4.6790639441471802e+000},
                                                       {0.0000000000000000e+000, 6.3279215732437058e+005, -2.8210768403341416e+006, 5.2183432578899413e+006, -5.1686479613357354e+006, 2.9479241152961440e+006, -9.6720356352482992e+005, 1.7180358825185243e+005, -1.4350743924217239e+004, 4.2812521662450422e+002, -2.2120594388308779e+000},
                                                       {0.0000000000000000e+000, -5.3817356528902554e+005, 2.3254849719736543e+006, -4.1435484300363720e+006, 3.9234158777716807e+006, -2.1203361748454417e+006, 6.5328660176513740e+005, -1.0845686728867043e+005, 8.5622516276965325e+003, -2.4675473480803626e+002, 1.2610713393538833e+000},
                                                       {0.0000000000000000e+000, 4.5949307182384975e+005, -1.9209276014662553e+006, 3.2976625197676714e+006, -2.9963167273363485e+006, 1.5492942037426815e+006, -4.5667695358235587e+005, 7.2917709086070434e+004, -5.5907305594731333e+003, 1.5833831307558737e+002, -8.0471029795464522e-001},
                                                       {0.0000000000000000e+000, -3.8731727793473238e+005, 1.5687517098084618e+006, -2.6056061054540584e+006, 2.2898947227521674e+006, -1.1468261936293892e+006, 3.2860680585074949e+005, -5.1281119333034934e+004, 3.8677165859097408e+003, -1.0848598176656873e+002, 5.4963518680511747e-001},
                                                       {0.0000000000000000e+000, 3.1437003617281874e+005, -1.2395966349710876e+006, 2.0064857099955215e+006, -1.7218603160716905e+006, 8.4447663413627748e+005, -2.3779984163485558e+005, 3.6612644262067646e+004, -2.7353248808652497e+003, 7.6299263284096597e+001, -3.8587167046219967e-001},
                                                       {0.0000000000000000e+000, -2.3078093377906628e+005, 8.9300085453804617e+005, -1.4213478247446718e+006, 1.2021070513323389e+006, -5.8243674239998451e+005, 1.6241627590029215e+005, -2.4821397991535498e+004, 1.8448625412310835e+003, -5.1306290887856250e+001, 2.5922119028094609e-001},
                                                       {0.0000000000000000e+000, 9.2377999999998559e+004, -3.5443979999999434e+005, 5.6010239999999071e+005, -4.7087039999999182e+005, 2.2702679999999586e+005, -6.3062999999998799e+004, 9.6095999999998112e+003, -7.1279999999998631e+002, 1.9799999999999674e+001, -9.9999999999999561e-002}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_1[2][2] = {{-1.0000000000000000e+000, -1.0000000000000000e+000},
                                                       {1.0000000000000000e+000, 1.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_2[3][3] = {{-3.9999999999999996e+000, -1.9999999999999996e+000, 1.9999999999999996e+000},
                                                       {4.5000000000000000e+000, 1.4999999999999996e+000, -4.5000000000000000e+000},
                                                       {-5.0000000000000011e-001, 4.9999999999999989e-001, 2.5000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_3[4][4] = {{-9.0000000000000000e+000, -4.1393876913398140e+000, 1.7393876913398127e+000, -3.0000000000000000e+000},
                                                       {1.0048809399827414e+001, 3.2247448713915885e+000, -3.5678400846904061e+000, 5.5319726474218047e+000},
                                                       {-1.3821427331607485e+000, 1.1678400846904053e+000, 7.7525512860840973e-001, -7.5319726474218065e+000},
                                                       {3.3333333333333337e-001, -2.5319726474218085e-001, 1.0531972647421810e+000, 5.0000000000000000e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_4[5][5] = {{-1.6000000000000000e+001, -7.1555920234752328e+000, 2.5082250819484635e+000, -1.9648779564324279e+000, 3.9999999999999716e+000},
                                                       {1.7807585234514509e+001, 5.6441078759500929e+000, -5.0492146383914118e+000, 3.4924661586254135e+000, -6.9234882564454630e+000},
                                                       {-2.3779130370681054e+000, 1.9235072770547124e+000, 1.2211000288946954e+000, -3.9845178957824761e+000, 6.5952376696281680e+000},
                                                       {8.2032780255359949e-001, -5.8590148210381654e-001, 1.7546809887608346e+000, 6.3479209515521329e-001, -1.2171749413182692e+001},
                                                       {-2.5000000000000022e-001, 1.7387835257424600e-001, -4.3479146121258100e-001, 1.8221375984342594e+000, 8.5000000000000071e+000}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_5[6][6] = {{-2.4999999999999837e+001, -1.1038679241208802e+001, 3.5830685225010370e+000, -2.3441715579038878e+000, 2.2826355002055720e+000, -5.0000000000001208e+000},
                                                       {2.7780933944064511e+001, 8.7559239779381777e+000, -7.1613807201453490e+000, 4.1221652462434122e+000, -3.8786632197238369e+000, 8.4124242235945097e+000},
                                                       {-3.6414784980492581e+000, 2.8919426153801462e+000, 1.8060777240836643e+000, -4.4960171258133368e+000, 3.3931519180651275e+000, -6.9702561166565484e+000},
                                                       {1.2525477211691316e+000, -8.7518639620027083e-001, 2.3637971760686058e+000, 8.5676524539719279e-001, -5.1883409064071486e+000, 8.7771142041505730e+000},
                                                       {-5.9200316718454860e-001, 3.9970520793996767e-001, -8.6590078028313155e-001, 2.5183209492110761e+000, 5.8123305258083524e-001, -1.8219282311088087e+001},
                                                       {2.0000000000000140e-001, -1.3370616384921608e-001, 2.7433807777519359e-001, -6.5706275713435414e-001, 2.8099836552797051e+000, 1.2999999999999993e+001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_6[7][7] = {{-3.5999999999999631e+001, -1.5786539322178488e+001, 4.9221069407462394e+000, -2.9607523846501209e+000, 2.4340720577581649e+000, -2.6345685975951056e+000, 6.0000000000015064e+000},
                                                       {3.9969786459974003e+001, 1.2559703476291080e+001, -9.8028387125679544e+000, 5.1821578385586307e+000, -4.1082390934592823e+000, 4.3857850633991049e+000, -9.9429774219308769e+000},
                                                       {-5.1815502536622926e+000, 4.0758259888763604e+000, 2.5250814079637767e+000, -5.5445229095274229e+000, 3.4915029091138567e+000, -3.4640050474511717e+000, 7.6760621572333907e+000},
                                                       {1.7607579014482893e+000, -1.2172038084642693e+000, 3.1322258626473256e+000, 1.1416181668474907e+000, -5.0698787509935084e+000, 3.9515424565874326e+000, -8.2327371282185986e+000},
                                                       {-8.4940911985935852e-001, 5.6623186694414640e-001, -1.1574099927743768e+000, 2.9749762538212288e+000, 7.1894419189768199e-001, -6.8105394388916700e+000, 1.1638707277367665e+001},
                                                       {4.6708167876565188e-001, -3.0710421225684259e-001, 5.8338219245411227e-001, -1.1780193270588040e+000, 3.4600417960863603e+000, 5.5465275699967642e-001, -2.5639054884453536e+001},
                                                       {-1.6666666666666832e-001, 1.0908601078800748e-001, -2.0254769846905324e-001, 3.8454236200916592e-001, -9.2644311040313088e-001, 4.0171328069512580e+000, 1.8499999999999996e+001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_7[8][8] = {{-4.8999999999999091e+001, -2.1398490858563715e+001, 6.5150217985266536e+000, -3.7382371560184637e+000, 2.8296298188918882e+000, -2.6124734408928276e+000, 3.0031865922092535e+000, -7.0000000000063665e+000},
                                                       {5.4374436894127882e+001, 1.7055284304420709e+001, -1.2948988698811249e+001, 6.5267974337019155e+000, -4.7604156431651390e+000, 4.3294510166477735e+000, -4.9436238334854323e+000, 1.1495455205147607e+001},
                                                       {-7.0000240042594131e+000, 5.4752995121856332e+000, 3.3765851454524567e+000, -6.9123049254818314e+000, 3.9908603180960442e+000, -3.3535280016802931e+000, 3.7048026760232604e+000, -8.5170724230650556e+000},
                                                       {2.3556610919876300e+000, -1.6185811051908212e+000, 4.0540135039255878e+000, 1.4837469310041733e+000, -5.6606883336573670e+000, 3.6906179318648644e+000, -3.7457284313687658e+000, 8.3810313019713494e+000},
                                                       {-1.1322890661061649e+000, 7.4965412823851896e-001, -1.4863139760065331e+000, 3.5946033544559421e+000, 8.9498029378619237e-001, -6.0373091872651257e+000, 4.7816656257641181e+000, -1.0033441651948319e+001},
                                                       {6.4689132676737482e-001, -4.2189137598302140e-001, 7.7285447377889271e-001, -1.4502156012225449e+000, 3.7358993915001593e+000, 6.4999738659523476e-001, -8.7833887559256230e+000, 1.5094393942990507e+001},
                                                       {-3.8753338537536342e-001, 2.5105021424639695e-001, -4.4494694720106687e-001, 7.6703844918136854e-001, -1.5419785025493291e+000, 4.5773009414147730e+000, 5.3940593874143561e-001, -3.4420366375064759e+001},
                                                       {1.4285714285714821e-001, -9.2324819353686360e-002, 1.6177470033538152e-001, -2.7142848561988187e-001, 5.1171265709969926e-001, -1.2440566466772733e+000, 5.4436801880592869e+000, 2.4999999999999627e+001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_8[9][9] = {{-6.3999999999997776e+001, -2.7874257744137736e+001, 8.3581274411958972e+000, -4.6566310317072066e+000, 3.3584094491278265e+000, -2.8644703520396675e+000, 2.8323162584336288e+000, -3.3812988503059671e+000, 7.9999999999367404e+000},
                                                       {7.0995003018866058e+001, 2.2242599964333557e+001, -1.6591130197061943e+001, 8.1182360178231363e+000, -5.6397236373846766e+000, 4.7359270908212636e+000, -4.6476082085462451e+000, 5.5279700242647891e+000, -1.3060996041773294e+001},
                                                       {-9.0975157067905226e+000, 7.0903116738929430e+000, 4.3599941420729067e+000, -8.5451889592399528e+000, 4.6920195582459723e+000, -3.6318485925858655e+000, 3.4355514890126457e+000, -4.0156563254718236e+000, 9.4274917234619355e+000},
                                                       {3.0398452598443120e+000, -2.0807353791507435e+000, 5.1249247660283945e+000, 1.8811856479741937e+000, -6.5690329421683336e+000, 3.9264353565760017e+000, -3.3863518750997930e+000, 3.8030184071983260e+000, -8.8035819494476044e+000},
                                                       {-1.4519931522613254e+000, 9.5733575045934161e-001, -1.8637038978971945e+000, 4.3506356667047363e+000, 1.1041272031141103e+000, -6.2680399567961294e+000, 4.1608354660776561e+000, -4.2743007394216361e+000, 9.6138240077753903e+000},
                                                       {8.3299700675763799e-001, -5.4072898089934163e-001, 9.7031561191456817e-001, -1.7491131793870858e+000, 4.2159935768429166e+000, 7.7234953699514053e-001, -7.2632440822934141e+000, 5.8064614837938224e+000, -1.2234234226318206e+001},
                                                       {-5.2539452304392975e-001, 3.3849233242015486e-001, -5.8549937027752974e-001, 9.6226841393821883e-001, -1.7852268638039153e+000, 4.6331389540712502e+000, 6.0993512969288177e-001, -1.1085659975285111e+001, 1.9116528975808436e+001},
                                                       {3.3205809662556118e-001, -2.1314332000182712e-001, 3.6230408377694995e-001, -5.7210967985580086e-001, 9.7087801789127326e-001, -1.9608436116915740e+000, 5.8687860194552250e+000, 5.2980837581120133e-001, -4.4559032489364817e+001},
                                                       {-1.2500000000000627e-001, 8.0125703083642058e-002, -1.3533257975211704e-001, 2.1071710374961294e-001, -3.4744436186398958e-001, 6.5735157466036021e-001, -1.6102201966978673e+000, 7.0896575994918001e+000, 3.2500000000000519e+001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_9[10][10] = {{-8.0999999999996774e+001, -3.5213710416992143e+001, 1.0449814072751607e+001, -5.7084591899161694e+000, 3.9904463666259318e+000, -3.2455064190422718e+000, 2.9750500648403602e+000, -3.0750780529360497e+000, 3.7653682881965409e+000, -8.9999999997225615e+000},
                                                       {8.9831539704035364e+001, 2.8121619021003710e+001, -2.0725485790521844e+001, 9.9423970233027177e+000, -6.6935072577935983e+000, 5.3584667525298073e+000, -4.8732343455963587e+000, 5.0157319194108112e+000, -6.1280826780317881e+000, 1.4634983139613084e+001},
                                                       {-1.1474276609469754e+001, 8.9208125880358189e+000, 5.4750355521293024e+000, -1.0423532855003934e+001, 5.5423338384064067e+000, -4.0851803637669502e+000, 3.5752970668736790e+000, -3.6073045056446187e+000, 4.3626519357349167e+000, -1.0378668494215773e+001},
                                                       {3.8141905847605462e+000, -2.6040992690898306e+000, 6.3428096315805984e+000, 2.3330854729126571e+000, -7.6967163803980565e+000, 4.3712062221160108e+000, -3.4765438484426867e+000, 3.3535705192439234e+000, -3.9679579547337842e+000, 9.3633700585011965e+000},
                                                       {-1.8115530086786076e+000, 1.1911494434189560e+000, -2.2914242158303653e+000, 5.2293963901917504e+000, 1.3443311646898159e+000, -6.8811008500251631e+000, 4.1893000847600046e+000, -3.6650620071458033e+000, 4.1543243532815932e+000, -9.6549658238429643e+000},
                                                       {1.0366378137882166e+000, -6.7091586184777774e-001, 1.1883354641034083e+000, -2.0895962536334709e+000, 4.8414218808268519e+000, 9.1711704254261173e-001, -7.1381081229180019e+000, 4.7899257932194566e+000, -4.9565072577077842e+000, 1.1183600012226718e+001},
                                                       {-6.6086568819374736e-001, 4.2434507579789082e-001, -7.2329307387047137e-001, 1.1558012179447235e+000, -2.0498912777636011e+000, 4.9642937665755742e+000, 7.0108995651909578e-001, -8.7049271749500470e+000, 7.0005003239979766e+000, -1.4788881794138968e+001},
                                                       {4.4418925628055200e-001, -2.8400708051217843e-001, 4.7454560842853494e-001, -7.2499641696074058e-001, 1.1661748317297629e+000, -2.1661878582061491e+000, 5.6605433779641450e+000, 5.8436218081611369e-001, -1.3708734741172266e+001, 2.3693693481327500e+001},
                                                       {-2.9097316363691772e-001, 1.8563208227400252e-001, -3.0702892266561782e-001, 4.5891161293462324e-001, -7.0715775482602794e-001, 1.1991586582083991e+000, -2.4353177255099290e+000, 7.3338317476588335e+000, 5.2335960939016235e-001, -5.6053130579439035e+001},
                                                       {1.1111111111111326e-001, -7.0825582088462111e-002, 1.1669167389479521e-001, -1.7300700177286521e-001, 2.6256458849737879e-001, -4.3226695095207202e-001, 8.2192349146585442e-001, -2.0250504194735912e+000, 8.9550781209911055e+000, 4.0999999999992042e+001}};

static jmi_real_t jmi_opt_sim_lpp_radau_dot_vals_10[11][11] = {{-9.9999999999998764e+001, -4.3416781419330995e+001, 1.2789280640125170e+001, -6.8903321459095963e+000, 4.7142404222016978e+000, -3.7156264261778631e+000, 3.2525107072447383e+000, -3.1266401235263572e+000, 3.3319441719357457e+000, -4.1534382576547415e+000, 1.0000000000098552e+001},
                                                       {1.1088407538476685e+002, 3.4692325029698054e+001, -2.5350183165318526e+001, 1.1992920109566995e+001, -7.9016125993842365e+000, 6.1291839375170127e+000, -5.3219491191861152e+000, 5.0929279072858407e+000, -5.4132663073305451e+000, 6.7384079969992854e+000, -1.6214760952692188e+001},
                                                       {-1.4130425638107489e+001, 1.0966768447404537e+001, 6.7215693675317141e+000, -1.2538605513098201e+001, 6.5219380332414438e+000, -4.6551751334863294e+000, 3.8865206485061492e+000, -3.6416056270969843e+000, 3.8249111845431720e+000, -4.7309476276197238e+000, 1.1355997822280379e+001},
                                                       {4.6790639441471802e+000, -3.1888361830095464e+000, 7.7065310982143904e+000, 2.8390273293479495e+000, -9.0078258764222312e+000, 4.9483649150070734e+000, -3.7482293892554059e+000, 3.3499652390039576e+000, -3.4308559345504888e+000, 4.1880152581475940e+000, -1.0002157489721519e+001},
                                                       {-2.2120594388308779e+000, 1.4517413398175529e+000, -2.7698267590573953e+000, 6.2242384877487869e+000, 1.6146346353642085e+000, -7.7202395871751204e+000, 4.4647570525118105e+000, -3.6053466135626131e+000, 3.5174791349464543e+000, -4.1921216096077218e+000, 9.9228005697560064e+000},
                                                       {1.2610713393538833e+000, -8.1451429917849860e-001, 1.4299949714404590e+000, -2.4731502897233213e+000, 5.5841017836219766e+000, 1.0823204231957060e+000, -7.5008453644988364e+000, 4.6185080116438639e+000, -4.0764581652977965e+000, 4.6474657472135670e+000, -1.0827984809533980e+001},
                                                       {-8.0471029795464522e-001, 5.1556091762315770e-001, -8.7030740153711628e-001, 1.3656146364569179e+000, -2.3541470707703924e+000, 5.4679360154148675e+000, 8.0890803867009642e-001, -8.1983454975925749e+000, 5.5405999984582763e+000, -5.7606826685329811e+000, 1.3025078618004724e+001},
                                                       {5.4963518680511747e-001, -3.5055212589929297e-001, 5.7940256827284875e-001, -8.6719768276510378e-001, 1.3506990350338053e+000, -2.3921627303749373e+000, 5.8250817330073748e+000, 6.5546003468141534e-001, -1.0344779438083020e+001, 8.3530593109196118e+000, -1.7677700506190263e+001},
                                                       {-3.8587167046219967e-001, 2.4546694513997841e-001, -4.0091971023087841e-001, 5.8509830262059759e-001, -8.6814375213082640e-001, 1.3909789457343720e+000, -2.5934695458547958e+000, 6.8150615675788133e+000, 5.6694419107673655e-001, -1.6648517046887395e+001, 2.8820399800170073e+001},
                                                       {2.5922119028094609e-001, -1.6466772675993407e-001, 2.6724017988449994e-001, -3.8490377804190229e-001, 5.5758559987230205e-001, -8.5461660475917212e-001, 1.4531681475040115e+000, -2.9655938725737108e+000, 8.9720795908328199e+000, 5.1881095017213130e-001, -6.8901673047351736e+001},
                                                       {-9.9999999999999561e-002, 6.3489074494963299e-002, -1.0278178932527715e-001, 1.4729054379692935e-001, -2.1147021062505000e-001, 3.1903624518598728e-001, -5.2645290826627766e-001, 1.0056089751861816e+000, -2.4885984249742834e+000, 1.1039947950453129e+001, 5.0499999999977341e+001}};

/**
 * \brief Evaluate Lagrange polynomial\f$L_k^{n}(\tau)\f$.
 *
 * The polynomial coefficients are
 * given in column major format in the vector pol. This vector should contain
 * coefficients for all Lagrange polynomials as returned by jmi_opt_sim_lp_get_pols.
 * This means that the pol matrix should have dimensions n x n.
 *
 * @param tau \f$\tau\f$, value of independent variable in polynomial evaluation.
 * @param n Order of polynomials.
 * @param pol Vector containing the polynomial coefficients.
 * @param k Specify evaluation of the k:th Lagrange polynomial.
 * @return Value of polynomial.
 *
 */
jmi_real_t jmi_opt_sim_lp_eval_pol(jmi_real_t tau, int n, jmi_real_t* pol, int k);

// Lagrange polynomial matrices are returned in column major format.

/**
 * \brief Get Lagrange polynomials of a specified order.
 *
 * @param n_cp Number of collocation points.
 * @param cp (Output) Radu collocation points for polynomials of order n_cp-1.
 * @param cpp (Output) Radau collocation points for polynomials of order n_cp.
 *  In this case, the point 0 has been added to cp.
 * @param Lp_coeffs (Output) Polynomial coefficients for polynomials based on the points
 * given by cp. The coefficients are stored in a matrix (vectorized using column
 * major convention) of size n_cp x n_cp where each row contains the
 * coefficients of one Lagrange polynomial.
 * @param Lpp_coeffs (Output) Polynomial coefficients for polynomials based on the points
 * given by cpp. The coefficients are stored in a matrix (vectorized using
 * column major format) of size n_cp+1 x n_cp+1.
 * @param Lp_dot_coeffs (Output) Polynomial coefficients for the derivatives of the
 * polynomials based on the cp points. The coefficients are stored in a matrix
 * (vectorized using column major format) of size n_cp x n_cp-1.
 * @param Lpp_dot_coeffs. (Output) Polynomial coefficients for the derivatives of the
 * polynomials based on the cpp points. The coefficients are stored in a matrix
 * (vectorized using column major format) of size n_cp+1 x n_cp.
 * @param Lp_dot_vals (Output) Values of the derivatives of the cp polynomials when
 * evaluated at the Radau collocation points. The vector has the size n_cp.
 * @param Lpp_dot_vals (Output) Values of the derivatives of the cpp polynomials when
 * evaluated at the collocation points. The vector has the size n_cp+1.
 * @return Error code.
 */
int jmi_opt_sim_lp_get_pols(int n_cp, jmi_real_t *cp, jmi_real_t *cpp,
		jmi_real_t *Lp_coeffs, jmi_real_t *Lpp_coeffs,
		jmi_real_t *Lp_dot_coeffs, jmi_real_t *Lpp_dot_coeffs,
		                          jmi_real_t *Lp_dot_vals, jmi_real_t *Lpp_dot_vals);

#ifdef __cplusplus
}
#endif

#endif
/* @} */
