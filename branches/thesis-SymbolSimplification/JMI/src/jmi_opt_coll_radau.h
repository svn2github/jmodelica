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



/** \file jmi_opt_coll_radau.h
 *  \brief An implementation of a simultaneous optimization method based on
 *  Lagrange polynomials and Radau points.
 **/

/**
 * \defgroup jmi_opt_coll_radau JMI Simultaneous Optimization based on Lagrange \
 * polynomials and Radau points
 *
 * \brief This interface provides a particular implementation of a transcription
 * method based on Lagrange polynomials and Radau points.
 *
 * This implementation provides the call-back functions required by the JMI
 * Simultaneous Optimization interface.
 *
 * \section jmi_opt_coll_radau_mathematical_formulation Mathematical formulation
 *
 * Consider the optimization problem
 *
 *      \f$\displaystyle\min_{p_{opt},u} \int_{t_0}^{t_f} L(p,v) dt + J(p,q)\f$<br>
 *      subject to <br>
 *      \f$ F(p,v) = 0\f$, \f$[t_0,t_f]\f$ <br>
 *      \f$  F_0(p,v) = 0 \f$<br>
 *      \f$F_{fdp}(p) = 0\f$<br>
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
 * \subsection jmi_opt_coll_radau_vars NLP variables
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
 * \subsection jmi_opt_coll_radau_constr Equality constraints representing the DAE
 *
 * The free dependent parameter constraint is given by
 *
 *   \f$ F_{fdp}(p) = 0\f$<br>
 *
 * and consists of \f$n_{fdp}\f$ equations. At the initial point the relation
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
 * \f$n_{fdp} + 2n_x+n_w+(n_x+n_w)n_en_c + n_xn_e + n_u + n_xn_en_c +
 *   (2n_x+n_u+n_w)n_{tp}\f$
 *
 * and the number of free variables when considering the total number of
 * variables and the number of equality constraints deriving from the DAE
 * constraint is then
 *
 * \f$n_{p^{opt}} - n_{fdp} + n_un_en_c + 2\f$
 *
 * which corresponds the number of free independent optimization parameters,
 * the input profile and, optionally, the free initial and terminal points.
 *
 * \subsection jmi_opt_coll_nlp The NLP problem
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
 * f(\bar x) = \displaystyle\sum_{i=0}^{n_{e}-1}\displaystyle\sum_{j=1}^{n_{cp}}\alpha_jL(p^{opt},v_{i,j}) + J(\bar x)
 * \f$
 *
 * where the Lagrange cost function has been approximated by a Radau quadrature
 * and \f$\alpha_j\f$ are the quadrature weights. The equality constraint
 * is given by:
 *
 * \f$
 * h(\bar x) = \left[ \begin{array}{l}
 *                      F_{fdp}(p) \\
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
 * \subsection jmi_opt_coll_jac Jacobians
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
 *                      F_{fdp}(p) \\
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
 *           \displaystyle{\frac{\partial F_{fdp}}{\partial p^{opt}}} &0
 *           &
 *           &
 *           ...
 *           &
 *           0 \\
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
 *         0&&...&&0\\
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
 * \subsection jmi_opt_coll_hess Hessian of the Lagrangian
 *
 * \subsection jmi_opt_coll_blocking_factors Blocking factors
 * The collocation algorithm also supports blocking factors, which are used
 * to obtain piecewise constant controls. The implementation of blocking
 * factors is done in two steps. In the first step, constant controls in
 * each finite element is introduced by eliminating all but the first control
 * variable point in each element. In the second step, linear equality
 * constraints are introduced to handle the situation where controls are
 * constant over several elements.
 *
 * The vector of algebraic variables is then:
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
 *     w_{0,n_c}\\
 *     \vdots\\
 *     \dot x_{n_e-1,1}\\
 *     x_{n_e-1,1}\\
 *     u_{n_e-1,1}\\
 *     w_{n_e-1,1}\\
 *     \dot x_{n_e-1,n_c}\\
 *     x_{n_e-1,n_c}\\
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
 *  \f$ n_{\bar x} = n_{p^{opt}} + (2n_x + n_w)(n_en_c + 1 + n_{tp})
 *    + n_u(n_e+1+n_{tp}) +
 *    n_xn_e + n_e + 2 \f$
 *
 * variables in the NLP, assuming that \f$n_{\dot x}=n_x\f$.
 *
 * Blocking factors are specified by a vector of integers, where each entry
 * in the vector corresponds to the number of elements for which the control
 * profile should be kept constant. For example, the blocking factor
 * specification [2,1,5] means that \f$u_0=u_1\f$ and \f$u_3=u_4=u_5=u_6=u_7\f$ assuming
 * that the number of elements is 8. Notice that specification of blocking
 * factors implies that controls are present in only one collocation point (the first) in
 * each element. The number of constant control levels in the optimization
 * interval is equal to the length of the blocking factor vector. In the example
 * above, this implies that there are three constant control levels. If the
 * sum of the entries in the blocking factor vector is not equal to the number
 * of elements, the vector is normalized, either by truncation (if the sum
 * of the entries is larger than the number of element) or by increasing the
 * last entry of the vector. For example, if the number of elements is 4, the
 * normalized blocking factor vector in the example is [2,2]. If the number
 * of elements is 10, then the normalized vector is [2,1,7].
 *
 * Specification of blocking factors may increase the number of equality
 * constraints. Denoting the (normalized) blocking factor vector \f$\gamma\f$,
 * the number of equality constraints becomes
 *
 * \f$n_{fdp} + 2n_x+n_w+(n_x+n_w)n_en_c + n_xn_e + n_u + n_xn_en_c +
 *   (2n_x+n_u+n_w)n_{tp} + n_u\sum_i(\gamma_i-1)\f$
 *
 * \section jmi_opt_coll_radau_create Creation of a jmi_opt_coll_t struct
 *
 */

/* @{ */


#ifndef _JMI_OPT_COLL_RADAU_H
#define _JMI_OPT_COLL_RADAU_H

#include <math.h>
#include "jmi.h"
#include "jmi_opt_coll.h"

#ifdef __cplusplus
extern "C" {
#endif


typedef struct {
    jmi_opt_coll_t jmi_opt_coll;
    int n_cp;                       /* Number of collocation points */
    jmi_real_t *cp;                 /* Collocation points for algebraic variables */
    jmi_real_t *w;                  /* Quadrature weights */
    jmi_real_t *cpp;                /* Collocation points for dynamic variables */
    jmi_real_t *Lp_coeffs;          /* Lagrange polynomial coefficients based on the points in cp */
    jmi_real_t *Lpp_coeffs;         /* Lagrange polynomial coefficients based on the points in cp plus one more point */
    jmi_real_t *Lp_dot_coeffs;      /* Lagrange polynomial derivative coefficients based on the points in cp */
    jmi_real_t *Lpp_dot_coeffs;     /* Lagrange polynomial derivative coefficients based on the points in cp plus one more point */
    jmi_real_t *Lp_dot_vals;        /* Values of the derivative of the Lagrange polynomials at the points in cp */
    jmi_real_t *Lpp_dot_vals;       /* Values of the derivative of the Lagrange polynomials at the points in cpp */
    int der_eval_alg;               /* Evaluation algorithm used for computation of derivatives */
    int dFfdp_dp_n_nz;
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
    jmi_real_t *du_weights;
} jmi_opt_coll_radau_t;

/**
 * \brief Create a new jmi_opt_coll_t struct based on collocation by means
 * of Lagrange polynomials.
 *
 * This function takes as its arguments information about initial guesses,
 * bounds, number of finite elements and number of collocation points. The
 * resulting jmi_opt_coll_t struct contains callback functions which evaluate
 * the constraints and cost function resulting from transcription of the
 * continuous time dynamic optimization problem by means of a simultaneous method
 * based on orthogonal collocation on finite elements and Lagrange polynomials
 * on Radau points. Notice that the returned jmi_opt_coll_t struct is generic in
 * the sense that it represents a general NLP where the particular transcription
 * method is implemented in the cost function and constraints callback functions.
 *
 * @param jmi_opt_coll (Output) The returned jmi_opt_coll_t struct.
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
 * @param n_blocking_factors Length of the blocking factor vector.
 * @param blocking_factors Blocking factor vector.
 * @return Error code.
 */
int jmi_opt_coll_radau_new(jmi_opt_coll_t **jmi_opt_coll, jmi_t *jmi, int n_e,
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
 * \brief Deallocate the fields of a jmi_opt_coll_t struct created by the function
 * jmi_opt_coll_radau_new.
 *
 * @jmi_opt_coll The jmi_opt_coll_t struct to delete.
 * @return Error code.
 */
int jmi_opt_coll_radau_delete(jmi_opt_coll_t *jmi_opt_coll);

/* Radau points */
static jmi_real_t jmi_opt_coll_radau_p_1[1] = {1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_2[2] = {3.3333333333333337e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_3[3] = {1.5505102572168217e-01,
                                              6.4494897427831788e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_4[4] = {8.8587959512703707e-02,
                                              4.0946686444073477e-01,
                                              7.8765946176084678e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_5[5] = {5.7104196114518224e-02,
                                              2.7684301363812369e-01,
                                              5.8359043236891683e-01,
                                              8.6024013565621915e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_6[6] = {3.9809857051469444e-02,
                                              1.9801341787360816e-01,
                                              4.3797481024738616e-01,
                                              6.9546427335363614e-01,
                                              9.0146491420117303e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_7[7] = {2.9316427159785330e-02,
                                              1.4807859966848380e-01,
                                              3.3698469028115419e-01,
                                              5.5867151877155008e-01,
                                              7.6923386203005428e-01,
                                              9.2694567131974104e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_8[8] = {2.2479386438714499e-02,
                                              1.1467905316090210e-01,
                                              2.6578982278458985e-01,
                                              4.5284637366944458e-01,
                                              6.4737528288683044e-01,
                                              8.1975930826310761e-01,
                                              9.4373743946307853e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_9[9] = {1.7779915147364100e-02,
                                              9.1323607899795212e-02,
                                              2.1430847939562991e-01,
                                              3.7193216458327238e-01,
                                              5.4518668480342669e-01,
                                              7.1317524285556999e-01,
                                              8.5563374295785422e-01,
                                              9.5536604471003073e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_p_10[10] = {1.4412409648874247e-02,
                                              7.4387389709197449e-02,
                                              1.7611665616299477e-01,
                                              3.0966757992763794e-01,
                                              4.6197040108101095e-01,
                                              6.1811723469529389e-01,
                                              7.6282301518504014e-01,
                                              8.8192102120999860e-01,
                                              9.6374218711679271e-01,
                                              1.0000000000000000e+00};

/* Radau weights */
static jmi_real_t jmi_opt_coll_w_1[1] = {1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_w_2[2] = {7.4999999999999989e-01,
                                              2.5000000000000000e-01};

static jmi_real_t jmi_opt_coll_w_3[3] = {3.7640306270046731e-01,
                                              5.1248582618842153e-01,
                                              1.1111111111111110e-01};

static jmi_real_t jmi_opt_coll_w_4[4] = {2.2046221117676834e-01,
                                              3.8819346884317174e-01,
                                              3.2884431998006236e-01,
                                              6.2500000000000000e-02};

static jmi_real_t jmi_opt_coll_w_5[5] = {1.4371356079122682e-01,
                                              2.8135601514946229e-01,
                                              3.1182652297574132e-01,
                                              2.2310390108357608e-01,
                                              4.0000000000000001e-02};

static jmi_real_t jmi_opt_coll_w_6[6] = {1.0079419262674506e-01,
                                              2.0845066715595353e-01,
                                              2.6046339159478743e-01,
                                              2.4269359423448439e-01,
                                              1.5982037661026549e-01,
                                              2.7777777777777776e-02};

static jmi_real_t jmi_opt_coll_w_7[7] = {7.4494235556001084e-02,
                                              1.5910211573364982e-01,
                                              2.1235188950297854e-01,
                                              2.2355491450728351e-01,
                                              1.9047493682211886e-01,
                                              1.1961374461266094e-01,
                                              2.0408163265306121e-02};

static jmi_real_t jmi_opt_coll_w_8[8] = {5.7254407372161233e-02,
                                              1.2482395066493217e-01,
                                              1.7350739781724883e-01,
                                              1.9578608372624701e-01,
                                              1.8825877269455848e-01,
                                              1.5206531032337875e-01,
                                              9.2679077401487481e-02,
                                              1.5625000000000000e-02};

static jmi_real_t jmi_opt_coll_w_9[9] = {4.5357252461567590e-02,
                                              1.0027664901201105e-01,
                                              1.4319334817861440e-01,
                                              1.6884698348796420e-01,
                                              1.7413650138648315e-01,
                                              1.5842188783521444e-01,
                                              1.2359468910229793e-01,
                                              7.3827009523225601e-02,
                                              1.2345679012345678e-02};

static jmi_real_t jmi_opt_coll_w_10[10] = {3.6808502742733402e-02,
                                              8.2188006368823452e-02,
                                              1.1959671585715127e-01,
                                              1.4530508241645701e-01,
                                              1.5679122861346922e-01,
                                              1.5292964386221222e-01,
                                              1.3409741892056978e-01,
                                              1.0213506593989868e-01,
                                              6.0148335277774877e-02,
                                              1.0000000000000000e-02};

/* Lagrange polynomial coefficients. Lagrange polynomials based on */
/* Radau points. The first index denotes polynomial */
/* and the second index denotes coefficient. */
static jmi_real_t jmi_opt_coll_radau_lp_coeffs_1[1][1] = {{1.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_2[2][2] = {{-1.5000000000000000e+00, 1.5000000000000000e+00},
                                                  {1.5000000000000000e+00, -5.0000000000000011e-01}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_3[3][3] = {{2.4158162379719630e+00, -3.9738944426968859e+00, 1.5580782047249224e+00},
                                                  {-5.7491495713052974e+00, 6.6405611093635519e+00, -8.9141153805825557e-01},
                                                  {3.3333333333333339e+00, -2.6666666666666674e+00, 3.3333333333333337e-01}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_4[4][4] = {{-4.8912794196728990e+00, 1.0746758781771321e+01, -7.4330170018726145e+00, 1.5775376397741934e+00},
                                                  {1.3954090584570263e+01, -2.6181326475517483e+01, 1.3200912486148241e+01, -9.7367659520101935e-01},
                                                  {-1.7812811164897351e+01, 2.6684567693746143e+01, -9.5178954842756163e+00, 6.4613895542682465e-01},
                                                  {8.7499999999999858e+00, -1.1249999999999979e+01, 3.7499999999999907e+00, -2.4999999999999889e-01}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_5[5][5] = {{1.1414409029082462e+01, -3.1054881095723236e+01, 2.9933327727048070e+01, -1.1879263560593634e+01, 1.5864079001863365e+00},
                                                  {-3.5165389444477917e+01, 8.7946344956204456e+01, -7.3334306169638353e+01, 2.1561468539410203e+01, -1.0081178814983849e+00},
                                                  {5.3750332212318270e+01, -1.1793829875179102e+02, 8.0478815606138582e+01, -1.7021823932825626e+01, 7.3097486615979501e-01},
                                                  {-5.5199351796922784e+01, 1.0584683489130974e+02, -6.2277837163548270e+01, 1.2139618954009054e+01, -5.0926488484774746e-01},
                                                  {2.5199999999999957e+01, -4.4799999999999926e+01, 2.5199999999999971e+01, -4.7999999999999998e+00, 2.0000000000000140e-01}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_6[6][6] = {{-2.9265438774851084e+01, 9.4612746692610031e+01, -1.1595572961240207e+02, 6.6330337221894723e+01, -1.7313107012600931e+01, 1.5911914853493214e+00},
                                                  {9.3862243458277121e+01, -2.8859954040881246e+02, 3.2683532366348692e+02, -1.6282705310569253e+02, 3.1755042868352465e+01, -1.0260164756115342e+00},
                                                  {-1.5604141784878044e+02, 4.4233879349568332e+02, -4.4461800568959046e+02, 1.8355073841348317e+02, -2.6001275978573940e+01, 7.7116760777840498e-01},
                                                  {1.8980539155673657e+02, -4.8917841274080240e+02, 4.3627049246594612e+02, -1.5672374153332373e+02, 2.0417003947766382e+01, -5.9073369632294448e-01},
                                                  {-1.7536077839138181e+02, 4.1582641296132078e+02, -3.4253208082743993e+02, 1.1633638567030489e+02, -1.4690997158277316e+01, 4.2105774547342106e-01},
                                                  {7.6999999999999631e+01, -1.7499999999999920e+02, 1.3999999999999943e+02, -4.6666666666666522e+01, 5.8333333333333321e+00, -1.6666666666666871e-01}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_7[7][7] = {{8.0192571118313580e+01, -2.9991334685292821e+02, 4.4460407199704991e+02, -3.3044796361162054e+02, 1.2770531294598692e+02, -2.3734709815362667e+01, 1.5940642185610547e+00},
                                                  {-2.6339129063052718e+02, 9.5377994351054360e+02, -1.3479394370610530e+03, 9.2856101230387776e+02, -3.1376478422401311e+02, 4.3791109853368397e+01, -1.0365537521964947e+00},
                                                  {4.5903989725135841e+02, -1.5755378874224089e+03, 2.0644088105172614e+03, -1.2704932284472802e+03, 3.5833018973663974e+02, -3.6541603359061291e+01, 7.9382172349080138e-01},
                                                  {-6.0643975001337560e+02, 1.9470107492516190e+03, -2.3409775958036098e+03, 1.2896754064093052e+03, -3.1850024808582930e+02, 2.9864015894140671e+01, -6.3257765224994122e-01},
                                                  {6.5684878289722349e+02, -1.9705443171902239e+03, 2.1979125494283803e+03, -1.1227169721397872e+03, 2.6173837993058368e+02, -2.3736033639779727e+01, 4.9761071360300674e-01},
                                                  {-5.7139306776584931e+02, 1.6240620015605396e+03, -1.7251512562208843e+03, 8.4827888834264718e+02, -1.9265170744622489e+02, 1.7214363923837464e+01, -3.5922239406557116e-01},
                                                  {2.4514285714285657e+02, -6.7885714285714118e+02, 7.0714285714285529e+02, -3.4285714285714187e+02, 7.7142857142856926e+01, -6.8571428571428479e+00, 1.4285714285714407e-01}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_8[8][8] = {{-2.3085816523144169e+02, 9.7980528841204796e+02, -1.7017155453485216e+03, 1.5528919867040499e+03, -7.9381355971283188e+02, 2.2323821096678870e+02, -3.1144139898170128e+01, 1.5959241080787685e+00},
                                                  {7.6990929430945312e+02, -3.1966538534958145e+03, 5.3820668269752041e+03, -4.6892414237820185e+03, 2.2260191874091715e+03, -5.4873006841358858e+02, 5.7673331484963867e+01, -1.0432944873712324e+00},
                                                  {-1.3819003387178368e+03, 5.5288130657289930e+03, -8.8486869508106192e+03, 7.1725913980152918e+03, -3.0542660859920979e+03, 6.3131054228953690e+02, -4.8669590446175100e+01, 8.0795993290660173e-01},
                                                  {1.9160856046504723e+03, -7.3076061621358258e+03, 1.0997549563995837e+04, -8.2260511127469999e+03, 3.1531186006670332e+03, -5.7306888079470207e+02, 4.0629916197778940e+01, -6.5752983359441874e-01},
                                                  {-2.2464886031842225e+03, 8.1306968452642586e+03, -1.1510169400172195e+04, 8.0320915088963784e+03, -2.8645405499679018e+03, 4.9155068754921956e+02, -3.3679750058431857e+01, 5.3926167289361826e-01},
                                                  {2.2719920421295083e+03, -7.8313460882505333e+03, 1.0544388395827085e+04, -7.0154076914103334e+03, 2.4049231128886399e+03, -4.0115829086019215e+02, 2.7039216726600738e+01, -4.3069705077572346e-01},
                                                  {-1.9031148339559429e+03, 6.3239159044769085e+03, -8.2418078904668382e+03, 5.3387503343236613e+03, -1.7933157052920242e+03, 2.9498279926293958e+02, -1.9723984006566621e+01, 3.1337565786239668e-01},
                                                  {8.0437500000000966e+02, -2.6276250000000323e+03, 3.3783750000000427e+03, -2.1656250000000286e+03, 7.2187500000001012e+02, -1.1812500000000192e+02, 7.8750000000001927e+00, -1.2500000000001063e-01}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_9[9][9] = {{6.9035610596340666e+02, -3.2770693260166217e+03, 6.5204215834556289e+03, -7.0475272864590670e+03, 4.4797768814509955e+03, -1.6915350697082847e+03, 3.6352134388948741e+02, -3.9541429729041575e+01, 1.5971971534948251e+00},
                                                  {-2.3263571802094434e+03, 1.0871956410037621e+04, -2.1175949197701953e+04, 2.2205512776736407e+04, -1.3490283295360583e+04, 4.7365459030300935e+03, -8.9378092696402575e+02, 7.3403382769902308e+01, -1.0478723380169608e+00},
                                                  {4.2585922385048334e+03, -1.9378287062346568e+04, 3.6428947745069658e+04, -3.6382124712903838e+04, 2.0610317460680664e+04, -6.5089246994039004e+03, 1.0330579105620034e+03, -6.2396293547197857e+01, 8.1741338434518895e-01},
                                                  {-6.0920503037760300e+03, 2.6760998461758081e+04, -4.8100379751692089e+04, 4.5323902440857724e+04, -2.3780141942999173e+04, 6.7852307504230457e+03, -9.4965008810489212e+02, 5.2764208365109226e+01, -6.7377483177517672e-01},
                                                  {7.4903564686532463e+03, -3.1605702915971582e+04, 5.4147682660584593e+04, -4.8202867992866428e+04, 2.3685521938909620e+04, -6.3043087155015482e+03, 8.3349480902159644e+02, -4.4741413962537408e+01, 5.6516113304107252e-01},
                                                  {-8.1712910607782433e+03, 3.3106236096994042e+04, -5.4257049198908717e+04, 4.6094377121017234e+04, -2.1633949419633791e+04, 5.5355559522627700e+03, -7.1092366907890641e+02, 3.7515491173276871e+01, -4.7131304767248944e-01},
                                                  {7.9054903909924024e+03, -3.0903132235683988e+04, 4.8892910433752564e+04, -4.0196664569174704e+04, 1.8340648636640435e+04, -4.5895341573660253e+03, 5.8024237685767378e+02, -3.0340939334290873e+01, 3.8006331593299070e-01},
                                                  {-6.4562077704613212e+03, 2.4593889460118040e+04, -3.8027695385671032e+04, 3.0662281111681765e+04, -1.3773001370799378e+04, 3.4058589251527678e+03, -4.2707286729405195e+02, 2.2225883153668516e+01, -2.7798588046056832e-01},
                                                  {2.7011111111111500e+03, -1.0168888888889041e+04, 1.5571111111111353e+04, -1.2456888888889094e+04, 5.5611111111112095e+03, -1.3688888888889162e+03, 1.7111111111111532e+02, -8.8888888888891966e+00, 1.1111111111111800e-01}};

static jmi_real_t jmi_opt_coll_radau_lp_coeffs_10[10][10] = {{-2.1277026297222887e+03, 1.1167769571364659e+04, -2.5035524039942455e+04, 3.1258288058656774e+04, -2.3757874060979837e+04, 1.1277614817080563e+04, -3.2958025830231131e+03, 5.6055935626116172e+02, -4.8926596413445928e+01, 1.5981067179820483e+00},
                                                  {7.2230802184577997e+03, -3.7478905592982454e+04, 8.2748518314991321e+04, -1.0118444551156728e+05, 7.4655257871953756e+04, -3.3894000472149542e+04, 9.2190144427504219e+03, -1.3784502682070677e+03, 9.0982122231756463e+01, -1.0511254786984925e+00},
                                                  {-1.3406900863964804e+04, 6.8201457576460292e+04, -1.4675451862998513e+05, 1.7338976337585726e+05, -1.2200299099283898e+05, 5.1732353023571326e+04, -1.2680473303114655e+04, 1.5982127985562988e+03, -7.7727045637451823e+01, 8.2406109581589237e-01},
                                                  {1.9595521595582828e+04, -9.7066226437354097e+04, 2.0199396598781185e+05, -2.2865181509782391e+05, 1.5214608776568100e+05, -5.9902317362824680e+04, 1.3300500349208938e+04, -1.4813200470578668e+03, 6.6288249869051455e+01, -6.8500309307874596e-01},
                                                  {-2.4862025780776843e+04, 1.1936724724561458e+05, -2.3927459126531176e+05, 2.5892885809454112e+05, -1.6325542551998733e+05, 6.0359814687658116e+04, -1.2525965620334207e+04, 1.3185022728678221e+03, -5.6996691903951621e+01, 5.8257763243299010e-01},
                                                  {2.8402058691740225e+04, -1.3192871745201977e+05, 2.5479275470963691e+05, -2.6458214425319782e+05, 1.5960757482447790e+05, -5.6455979139478986e+04, 1.1267923175149344e+04, -1.1519089711159843e+03, 4.8935820112297996e+01, -4.9740530410247114e-01},
                                                  {-2.9545453378743645e+04, 1.3296443437253163e+05, -2.4845203821837815e+05, 2.4954062812373266e+05, -1.4580423581959284e+05, 5.0133766889878934e+04, -9.7796045179223966e+03, 9.8346107598161348e+02, -4.1377801858240431e+01, 4.1927437045040905e-01},
                                                  {2.7724954333935089e+04, -1.2146959224468426e+05, 2.2119524080031080e+05, -2.1693497261869835e+05, 1.2412694926090578e+05, -4.1944135835636764e+04, 8.0723651542001062e+03, -8.0411350409124441e+02, 3.3644962096538812e+01, -3.4030833766997265e-01},
                                                  {-2.2241332186508705e+04, 9.5624732961070884e+04, -1.7122660765913595e+05, 1.6550303982850205e+05, -9.3553143329620798e+04, 3.1305483391901460e+04, -5.9803570969144994e+03, 5.9265728680527263e+02, -2.4723018496554918e+01, 2.4982239686833119e-01},
                                                  {9.2378000000003485e+03, -3.9382200000001467e+04, 7.0012800000002564e+04, -6.7267200000002413e+04, 3.7837800000001327e+04, -1.2612600000000421e+04, 2.4024000000000724e+03, -2.3760000000000559e+02, 9.9000000000000359e+00, -9.9999999999989389e-02}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_1[1][1] = {{0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_2[2][2] = {{0.0000000000000000e+00, -1.5000000000000000e+00},
                                                      {0.0000000000000000e+00, 1.5000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_3[3][3] = {{0.0000000000000000e+00, 4.8316324759439260e+00, -3.9738944426968859e+00},
                                                      {0.0000000000000000e+00, -1.1498299142610595e+01, 6.6405611093635519e+00},
                                                      {0.0000000000000000e+00, 6.6666666666666679e+00, -2.6666666666666674e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_4[4][4] = {{0.0000000000000000e+00, -1.4673838259018698e+01, 2.1493517563542643e+01, -7.4330170018726145e+00},
                                                      {0.0000000000000000e+00, 4.1862271753710786e+01, -5.2362652951034967e+01, 1.3200912486148241e+01},
                                                      {0.0000000000000000e+00, -5.3438433494692049e+01, 5.3369135387492285e+01, -9.5178954842756163e+00},
                                                      {0.0000000000000000e+00, 2.6249999999999957e+01, -2.2499999999999957e+01, 3.7499999999999907e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_5[5][5] = {{0.0000000000000000e+00, 4.5657636116329847e+01, -9.3164643287169710e+01, 5.9866655454096140e+01, -1.1879263560593634e+01},
                                                      {0.0000000000000000e+00, -1.4066155777791167e+02, 2.6383903486861334e+02, -1.4666861233927671e+02, 2.1561468539410203e+01},
                                                      {0.0000000000000000e+00, 2.1500132884927308e+02, -3.5381489625537307e+02, 1.6095763121227716e+02, -1.7021823932825626e+01},
                                                      {0.0000000000000000e+00, -2.2079740718769114e+02, 3.1754050467392921e+02, -1.2455567432709654e+02, 1.2139618954009054e+01},
                                                      {0.0000000000000000e+00, 1.0079999999999983e+02, -1.3439999999999978e+02, 5.0399999999999942e+01, -4.7999999999999998e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_6[6][6] = {{0.0000000000000000e+00, -1.4632719387425541e+02, 3.7845098677044012e+02, -3.4786718883720619e+02, 1.3266067444378945e+02, -1.7313107012600931e+01},
                                                      {0.0000000000000000e+00, 4.6931121729138562e+02, -1.1543981616352498e+03, 9.8050597099046081e+02, -3.2565410621138506e+02, 3.1755042868352465e+01},
                                                      {0.0000000000000000e+00, -7.8020708924390215e+02, 1.7693551739827333e+03, -1.3338540170687713e+03, 3.6710147682696635e+02, -2.6001275978573940e+01},
                                                      {0.0000000000000000e+00, 9.4902695778368286e+02, -1.9567136509632096e+03, 1.3088114773978384e+03, -3.1344748306664746e+02, 2.0417003947766382e+01},
                                                      {0.0000000000000000e+00, -8.7680389195690907e+02, 1.6633056518452831e+03, -1.0275962424823197e+03, 2.3267277134060978e+02, -1.4690997158277316e+01},
                                                      {0.0000000000000000e+00, 3.8499999999999818e+02, -6.9999999999999682e+02, 4.1999999999999829e+02, -9.3333333333333044e+01, 5.8333333333333321e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_7[7][7] = {{0.0000000000000000e+00, 4.8115542670988145e+02, -1.4995667342646411e+03, 1.7784162879881997e+03, -9.9134389083486167e+02, 2.5541062589197384e+02, -2.3734709815362667e+01},
                                                      {0.0000000000000000e+00, -1.5803477437831630e+03, 4.7688997175527184e+03, -5.3917577482442121e+03, 2.7856830369116333e+03, -6.2752956844802623e+02, 4.3791109853368397e+01},
                                                      {0.0000000000000000e+00, 2.7542393835081502e+03, -7.8776894371120443e+03, 8.2576352420690455e+03, -3.8114796853418406e+03, 7.1666037947327948e+02, -3.6541603359061291e+01},
                                                      {0.0000000000000000e+00, -3.6386385000802538e+03, 9.7350537462580942e+03, -9.3639103832144392e+03, 3.8690262192279156e+03, -6.3700049617165860e+02, 2.9864015894140671e+01},
                                                      {0.0000000000000000e+00, 3.9410926973833411e+03, -9.8527215859511198e+03, 8.7916501977135213e+03, -3.3681509164193617e+03, 5.2347675986116735e+02, -2.3736033639779727e+01},
                                                      {0.0000000000000000e+00, -3.4283584065950959e+03, 8.1203100078026982e+03, -6.9006050248835372e+03, 2.5448366650279413e+03, -3.8530341489244978e+02, 1.7214363923837464e+01},
                                                      {0.0000000000000000e+00, 1.4708571428571395e+03, -3.3942857142857060e+03, 2.8285714285714212e+03, -1.0285714285714257e+03, 1.5428571428571385e+02, -6.8571428571428479e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_8[8][8] = {{0.0000000000000000e+00, -1.6160071566200918e+03, 5.8788317304722877e+03, -8.5085777267426074e+03, 6.2115679468161998e+03, -2.3814406791384954e+03, 4.4647642193357740e+02, -3.1144139898170128e+01},
                                                      {0.0000000000000000e+00, 5.3893650601661720e+03, -1.9179923120974887e+04, 2.6910334134876022e+04, -1.8756965695128074e+04, 6.6780575622275146e+03, -1.0974601368271772e+03, 5.7673331484963867e+01},
                                                      {0.0000000000000000e+00, -9.6733023710248581e+03, 3.3172878394373955e+04, -4.4243434754053094e+04, 2.8690365592061167e+04, -9.1627982579762938e+03, 1.2626210845790738e+03, -4.8669590446175100e+01},
                                                      {0.0000000000000000e+00, 1.3412599232553306e+04, -4.3845636972814958e+04, 5.4987747819979188e+04, -3.2904204450988000e+04, 9.4593558020011005e+03, -1.1461377615894041e+03, 4.0629916197778940e+01},
                                                      {0.0000000000000000e+00, -1.5725420222289558e+04, 4.8784181071585554e+04, -5.7550847000860973e+04, 3.2128366035585514e+04, -8.5936216499037055e+03, 9.8310137509843912e+02, -3.3679750058431857e+01},
                                                      {0.0000000000000000e+00, 1.5903944294906558e+04, -4.6988076529503203e+04, 5.2721941979135430e+04, -2.8061630765641334e+04, 7.2147693386659193e+03, -8.0231658172038431e+02, 2.7039216726600738e+01},
                                                      {0.0000000000000000e+00, -1.3321803837691601e+04, 3.7943495426861453e+04, -4.1209039452334189e+04, 2.1355001337294645e+04, -5.3799471158760725e+03, 5.8996559852587916e+02, -1.9723984006566621e+01},
                                                      {0.0000000000000000e+00, 5.6306250000000673e+03, -1.5765750000000193e+04, 1.6891875000000215e+04, -8.6625000000001146e+03, 2.1656250000000305e+03, -2.3625000000000384e+02, 7.8750000000001927e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_9[9][9] = {{0.0000000000000000e+00, 5.5228488477072533e+03, -2.2939485282116351e+04, 3.9122529500733770e+04, -3.5237636432295338e+04, 1.7919107525803982e+04, -5.0746052091248539e+03, 7.2704268777897482e+02, -3.9541429729041575e+01},
                                                      {0.0000000000000000e+00, -1.8610857441675547e+04, 7.6103694870263353e+04, -1.2705569518621173e+05, 1.1102756388368203e+05, -5.3961133181442332e+04, 1.4209637709090281e+04, -1.7875618539280515e+03, 7.3403382769902308e+01},
                                                      {0.0000000000000000e+00, 3.4068737908038667e+04, -1.3564800943642599e+05, 2.1857368647041795e+05, -1.8191062356451919e+05, 8.2441269842722657e+04, -1.9526774098211703e+04, 2.0661158211240067e+03, -6.2396293547197857e+01},
                                                      {0.0000000000000000e+00, -4.8736402430208240e+04, 1.8732698923230657e+05, -2.8860227851015254e+05, 2.2661951220428862e+05, -9.5120567771996692e+04, 2.0355692251269138e+04, -1.8993001762097842e+03, 5.2764208365109226e+01},
                                                      {0.0000000000000000e+00, 5.9922851749225971e+04, -2.2123992041180108e+05, 3.2488609596350754e+05, -2.4101433996433215e+05, 9.4742087755638480e+04, -1.8912926146504644e+04, 1.6669896180431929e+03, -4.4741413962537408e+01},
                                                      {0.0000000000000000e+00, -6.5370328486225946e+04, 2.3174365267895829e+05, -3.2554229519345227e+05, 2.3047188560508617e+05, -8.6535797678535164e+04, 1.6606667856788310e+04, -1.4218473381578128e+03, 3.7515491173276871e+01},
                                                      {0.0000000000000000e+00, 6.3243923127939219e+04, -2.1632192564978791e+05, 2.9335746260251536e+05, -2.0098332284587351e+05, 7.3362594546561741e+04, -1.3768602472098075e+04, 1.1604847537153476e+03, -3.0340939334290873e+01},
                                                      {0.0000000000000000e+00, -5.1649662163690569e+04, 1.7215722622082627e+05, -2.2816617231402619e+05, 1.5331140555840882e+05, -5.5092005483197514e+04, 1.0217576775458303e+04, -8.5414573458810389e+02, 2.2225883153668516e+01},
                                                      {0.0000000000000000e+00, 2.1608888888889200e+04, -7.1182222222223296e+04, 9.3426666666668112e+04, -6.2284444444445471e+04, 2.2244444444444838e+04, -4.1066666666667488e+03, 3.4222222222223064e+02, -8.8888888888891966e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_coeffs_10[10][10] = {{0.0000000000000000e+00, -1.9149323667500597e+04, 8.9342156570917272e+04, -1.7524866827959719e+05, 1.8754972835194063e+05, -1.1878937030489919e+05, 4.5110459268322251e+04, -9.8874077490693398e+03, 1.1211187125223234e+03, -4.8926596413445928e+01},
                                                      {0.0000000000000000e+00, 6.5007721966120196e+04, -2.9983124474385963e+05, 5.7923962820493919e+05, -6.0710667306940362e+05, 3.7327628935976879e+05, -1.3557600188859817e+05, 2.7657043328251268e+04, -2.7569005364141353e+03, 9.0982122231756463e+01},
                                                      {0.0000000000000000e+00, -1.2066210777568324e+05, 5.4561166061168234e+05, -1.0272816304098959e+06, 1.0403385802551436e+06, -6.1001495496419491e+05, 2.0692941209428530e+05, -3.8041419909343967e+04, 3.1964255971125976e+03, -7.7727045637451823e+01},
                                                      {0.0000000000000000e+00, 1.7635969436024546e+05, -7.7652981149883277e+05, 1.4139577619146830e+06, -1.3719108905869434e+06, 7.6073043882840499e+05, -2.3960926945129872e+05, 3.9901501047626814e+04, -2.9626400941157335e+03, 6.6288249869051455e+01},
                                                      {0.0000000000000000e+00, -2.2375823202699158e+05, 9.5493797796491662e+05, -1.6749221388571823e+06, 1.5535731485672467e+06, -8.1627712759993668e+05, 2.4143925875063246e+05, -3.7577896861002620e+04, 2.6370045457356441e+03, -5.6996691903951621e+01},
                                                      {0.0000000000000000e+00, 2.5561852822566201e+05, -1.0554297396161582e+06, 1.7835492829674585e+06, -1.5874928655191869e+06, 7.9803787412238948e+05, -2.2582391655791595e+05, 3.3803769525448035e+04, -2.3038179422319686e+03, 4.8935820112297996e+01},
                                                      {0.0000000000000000e+00, -2.6590908040869283e+05, 1.0637154749802530e+06, -1.7391642675286471e+06, 1.4972437687423960e+06, -7.2902117909796420e+05, 2.0053506755951574e+05, -2.9338813553767191e+04, 1.9669221519632270e+03, -4.1377801858240431e+01},
                                                      {0.0000000000000000e+00, 2.4952458900541579e+05, -9.7175673795747408e+05, 1.5483666856021755e+06, -1.3016098357121900e+06, 6.2063474630452890e+05, -1.6777654334254705e+05, 2.4217095462600319e+04, -1.6082270081824888e+03, 3.3644962096538812e+01},
                                                      {0.0000000000000000e+00, -2.0017198967857833e+05, 7.6499786368856707e+05, -1.1985862536139516e+06, 9.9301823897101230e+05, -4.6776571664810402e+05, 1.2522193356760584e+05, -1.7941071290743497e+04, 1.1853145736105453e+03, -2.4723018496554918e+01},
                                                      {0.0000000000000000e+00, 8.3140200000003140e+04, -3.1505760000001173e+05, 4.9008960000001796e+05, -4.0360320000001451e+05, 1.8918900000000664e+05, -5.0450400000001682e+04, 7.2072000000002172e+03, -4.7520000000001119e+02, 9.9000000000000359e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_1[1][1] = {{0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_2[2][2] = {{-1.5000000000000000e+00, -1.5000000000000000e+00},
                                                      {1.5000000000000000e+00, 1.5000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_3[3][3] = {{-3.2247448713915894e+00, -8.5773803324704145e-01, 8.5773803324704012e-01},
                                                      {4.8577380332470401e+00, -7.7525512860841328e-01, -4.8577380332470428e+00},
                                                      {-1.6329931618554527e+00, 1.6329931618554530e+00, 4.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_4[4][4] = {{-5.6441078759500849e+00, -1.0923951625919903e+00, 3.9279722479070234e-01, -6.1333769734866994e-01},
                                                      {8.8907397551196716e+00, -1.2211000288946980e+00, -2.0713622171778425e+00, 2.7005312888240596e+00},
                                                      {-5.2094082376126378e+00, 3.3753429231863858e+00, -6.3479209515520729e-01, -9.5871935914753799e+00},
                                                      {1.9627763584430522e+00, -1.0618477316996962e+00, 2.3133570875423501e+00, 7.4999999999999911e+00}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_5[5][5] = {{-8.7559239779383820e+00, -1.4771725091407362e+00, 4.0335296739259441e-01, -2.5747222895190092e-01, 4.8038472266264343e-01},
                                                      {1.4020232546567769e+01, -1.8060777240836323e+00, -2.1328158609906147e+00, 1.0919862533645777e+00, -1.9296667091648310e+00},
                                                      {-8.9441834771237865e+00, 4.9829302097451702e+00, -8.5676524539718457e-01, -3.5197917271527484e+00, 5.1222398733515462e+00},
                                                      {6.0213169205853880e+00, -2.6906317587962150e+00, 3.7121252077103133e+00, -5.8123305258081359e-01, -1.5672957886849415e+01},
                                                      {-2.3414420120909916e+00, 9.9095178227540703e-01, -1.1258970687151293e+00, 3.2665107553208506e+00, 1.1999999999999989e+01}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_6[6][6] = {{-1.2559703476291546e+01, -1.9708240584738359e+00, 4.7103385387539731e-01, -2.3516436042816835e-01, 1.9368194333684485e-01, -3.9582850983295970e-01},
                                                      {2.0273075426320773e+01, -2.5250814079637003e+00, -2.5067421826700915e+00, 9.9410487502889211e-01, -7.6089426018875272e-01, 1.5199633035640581e+00},
                                                      {-1.3391271572648341e+01, 6.9279952973720462e+00, -1.1416181668474508e+00, -3.1928012250522642e+00, 1.9198484936513225e+00, -3.6057314815477888e+00},
                                                      {9.8918725928821321e+00, -4.0650644195781851e+00, 4.7239924539027101e+00, -7.1894419189777281e-01, -5.2542109930169261e+00, 8.0943050994305921e+00},
                                                      {-6.9541488680808037e+00, 2.6558734439037757e+00, -2.4246670510446986e+00, 4.4849266890457073e+00, -5.5465275699924454e-01, -2.3112708411613131e+01},
                                                      {2.7401758978177799e+00, -1.0228988552600891e+00, 8.7800109278423211e-01, -1.3321217866960531e+00, 4.4562275732173102e+00, 1.7499999999999947e+01}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_7[7][7] = {{-1.7055284304421733e+01, -2.5636255666347090e+00, 5.6780734279692169e-01, -2.4980399709669854e-01, 1.6500058257478756e-01, -1.5635154519247152e-01, 3.3700567518948432e-01},
                                                      {2.7655985502972552e+01, -3.3765851454523315e+00, -3.0374211748103974e+00, 1.0577969119951831e+00, -6.4555885400947233e-01, 5.9183834531843615e-01, -1.2611961576812121e+00},
                                                      {-1.8605167998638272e+01, 9.2257793366121987e+00, -1.4837469310040490e+00, -3.4144667139831739e+00, 1.6167797624413112e+00, -1.3617336747762536e+00, 2.8242792375289767e+00},
                                                      {1.4285861237240793e+01, -5.6075711696757793e+00, 5.9593286381636865e+00, -8.9498029378587773e-01, -4.3847168714624587e+00, 2.8819169019901132e+00, -5.6053980862011983e+00},
                                                      {-1.1070009682140503e+01, 4.0147991200829303e+00, -3.3104024600462623e+00, 5.1439535049116358e+00, -6.4999738659561501e-01, -7.2889709326902192e+00, 1.1611118947768567e+01},
                                                      {7.9378673298500217e+00, -2.7852886750572239e+00, 2.1098969499512261e+00, -2.5584449004114909e+00, 5.5157599052839803e+00, -5.3940593873992171e-01, -3.1905809616606309e+01},
                                                      {-3.1492520848628640e+00, 1.0924921001249217e+00, -8.0546236505110791e-01, 9.1594548837020451e-01, -1.6172671382329309e+00, 5.8727068440900796e+00, 2.3999999999999901e+01}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_8[8][8] = {{-2.2242599964336460e+01, -3.2521931152632071e+00, 6.8660629189414735e-01, -2.7995703272413408e-01, 1.6444979911028312e-01, -1.2744641004191948e-01, 1.3167367235769234e-01, -2.9360317729936369e-01},
                                                      {3.6171371117915214e+01, -4.3599941420721819e+00, -3.6869514741383469e+00, 1.1882094936350640e+00, -6.4336246506535844e-01, 4.8061155009327194e-01, -4.8796587478859976e-01, 1.0811358245347975e+00},
                                                      {-2.4602018795924121e+01, 1.1877956852641574e+01, -1.8811856479744264e+00, -3.8555726689766985e+00, 1.6120580831342224e+00, -1.0979538209563202e+00, 1.0710644149729447e+00, -2.3399024862276221e+00},
                                                      {1.9285491806528988e+01, -7.3594220434675606e+00, 7.4125094940935057e+00, -1.1041272031140394e+00, -4.3845652428878310e+00, 2.2985030279663121e+00, -2.0509958690644652e+00, 4.3535853390127528e+00},
                                                      {-1.5572247842669974e+01, 5.4775333981118735e+00, -4.2602558195935529e+00, 6.0270550746427816e+00, -7.7234953699638709e-01, -5.7358844785960663e+00, 3.9830566092426523e+00, -7.9201408431585989e+00},
                                                      {1.2343852935381888e+01, -4.1853202092082071e+00, 2.9678656658449754e+00, -3.2316839088417098e+00, 5.8668578867248158e+00, -6.0993512969077557e-01, -9.6293445326881688e+00, 1.5670952569585051e+01},
                                                      {-8.9482571779964335e+00, 2.9815377691594165e+00, -2.0313844928394111e+00, 2.0233217883837220e+00, -2.8584988926859296e+00, 6.7563649902256202e+00, -5.2980837581585405e-01, -4.2052027226452410e+01},
                                                      {3.5644079211009325e+00, -1.1800985099016819e+00, 7.9279598271301754e-01, -7.6724554300518744e-01, 1.0154103686641198e+00, -1.9642597290042110e+00, 7.5123199557776861e+00, 3.1500000000001357e+01}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_9[9][9] = {{-2.8121619021007689e+01, -4.0350724989718785e+00, 8.2486225432727878e-01, -3.1997767984157832e-01, 1.7475313839353390e-01, -1.2149285049653002e-01, 1.0422600634641555e-01, -1.1404716615002286e-01, 2.6020875839542867e-01},
                                                      {4.5820285652942921e+01, -5.4750355521285741e+00, -4.4417963771915652e+00, 1.3608554744805303e+00, -6.8430396438365904e-01, 4.5782439972538214e-01, -3.8501527665025037e-01, 4.1702666426384383e-01, -9.4781745209017743e-01},
                                                      {-3.1388257476396259e+01, 1.4884627518566717e+01, -2.3330854729127140e+00, -4.4348721108072553e+00, 1.7182858362070448e+00, -1.0446981063560443e+00, 8.3996056072672332e-01, -8.9009551924294072e-01, 2.0066495991912774e+00},
                                                      {2.4917261255808722e+01, -9.3322459347803886e+00, 9.0756125205727969e+00, -1.3443311646901748e+00, -4.6943603085026950e+00, 2.1847862278293277e+00, -1.5931518092426842e+00, 1.6173139684897180e+00, -3.5909923378260089e+00},
                                                      {-2.0572336339696179e+01, 7.0941642255281678e+00, -5.3157955173250571e+00, 7.0966670707284720e+00, -9.1711704254111481e-01, -5.4567254574461117e+00, 3.0520111965368670e+00, -2.8284674497672526e+00, 6.0971498147902281e+00},
                                                      {1.7021026252287704e+01, -5.6484267921097739e+00, 3.8462725162583027e+00, -3.9306407163908830e+00, 6.4939432881787980e+00, -7.0108995651759898e-01, -7.2556027659881934e+00, 5.2258331204630792e+00, -1.0547064365156700e+01},
                                                      {-1.3667446627898919e+01, 4.4461365958016827e+00, -2.8945723455482870e+00, 2.6827971098822445e+00, -3.3996857897129829e+00, 6.7912507706577756e+00, -5.8436218079667057e-01, -1.2277656383969781e+01, 2.0273123637883351e+01},
                                                      {9.9745463768255025e+00, -3.2119296883286630e+00, 2.0457826669166472e+00, -1.8164455014825300e+00, 2.1013636176490706e+00, -3.2623396371888091e+00, 8.1886600277076358e+00, -5.2335960943977966e-01, -5.3551257655322956e+01},
                                                      {-3.9834600728657890e+00, 1.2777821264228084e+00, -8.0728024509690322e-01, 7.0594751812226697e-01, -7.9287877529192130e-01, 1.1524846097763408e+00, -2.3667257587096788e+00, 9.3734523752104355e+00, 3.9999999999972033e+01}};

static jmi_real_t jmi_opt_coll_radau_lp_dot_vals_10[10][10] = {{-3.4692325029698161e+01, -4.9115478561740247e+00, 9.8143401805972985e-01, -3.6775331048820448e-01, 1.9121638423754206e-01, -1.2408990809124276e-01, 9.6223320256619616e-02, -8.8463943715588300e-02, 1.0077041106992368e-01, -2.3369377727075147e-01},
                                                      {5.6603253600356922e+01, -6.7215693675332773e+00, -5.2960018378352913e+00, 1.5666798127589345e+00, -7.4958552757244945e-01, 4.6772377450673730e-01, -3.5511453054068909e-01, 3.2261977214704984e-01, -3.6516285116267966e-01, 8.4474303563187902e-01},
                                                      {-3.8966916656231867e+01, 1.8245679717215509e+01, -2.8390273293470187e+00, -5.1230037481631712e+00, 1.8864617305903124e+00, -1.0679618517731484e+00, 7.7342275254308390e-01, -6.8513036943831196e-01, 7.6532837604078452e-01, -1.7615465317040560e+00},
                                                      {3.1192370903591033e+01, -1.1530523555797274e+01, 1.0944137320037719e+01, -1.6146346353615257e+00, -5.1750239925153068e+00, 2.2367771578147000e+00, -1.4635884580984992e+00, 1.2350870713363520e+00, -1.3470035561633580e+00, 3.0727696387902910e+00},
                                                      {-2.6108160026319723e+01, 8.8807438072874234e+00, -6.4873036779643840e+00, 8.3305128075088604e+00, -1.0823204231908221e+00, -5.6060053772833101e+00, 2.7969974109039839e+00, -2.1353420187459378e+00, 2.2277655204750388e+00, -5.0022084856859763e+00},
                                                      {2.2111298282661789e+01, -7.2317634275917939e+00, 4.7929023928610093e+00, -4.6990352615855357e+00, 7.3161083078767177e+00, -8.0890803868569350e-01, -6.6431381160607756e+00, 3.8832732948373661e+00, -3.6947404485203776e+00, 8.0510255771949133e+00},
                                                      {-1.8554095822477205e+01, 5.9416201571761320e+00, -3.7561373554357687e+00, 3.3272592202057467e+00, -3.9500296610452565e+00, 7.1887761121490996e+00, -6.5546003469023617e-01, -8.9477806430657481e+00, 6.6116291004235350e+00, -1.3484956801521761e+01},
                                                      {1.5020559656937017e+01, -4.7532185448675932e+00, 2.9299357811895526e+00, -2.4724390735854485e+00, 2.6554375982435410e+00, -3.7003260578332373e+00, 7.8790832705550393e+00, -5.6694419100520577e-01, -1.5235067377697305e+01, 2.5417316423452995e+01},
                                                      {-1.1011152125248527e+01, 3.4622889236230350e+00, -2.1062630699520604e+00, 1.7353084415603881e+00, -1.7828633044187185e+00, 2.2657181682319418e+00, -3.7466986022650417e+00, 9.8044738701922789e+00, -5.1881095026405788e-01, -6.6403449078269887e+01},
                                                      {4.4051672164287723e+00, -1.3817098533379522e+00, 8.3632375838792150e-01, -6.8289425284501171e-01, 6.9059888780713763e-01, -8.5170397898239081e-01, 1.3182729875424304e+00, -2.8217928421078309e+00, 1.1455291776248121e+01, 4.9500000000037232e+01}};

/* Radau points plus starting point of interval (0) */
static jmi_real_t jmi_opt_coll_radau_pp_1[2] = {0.0000000000000000e+00,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_2[3] = {0.0000000000000000e+00,
                                              3.3333333333333337e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_3[4] = {0.0000000000000000e+00,
                                              1.5505102572168217e-01,
                                              6.4494897427831788e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_4[5] = {0.0000000000000000e+00,
                                              8.8587959512703707e-02,
                                              4.0946686444073477e-01,
                                              7.8765946176084678e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_5[6] = {0.0000000000000000e+00,
                                              5.7104196114518224e-02,
                                              2.7684301363812369e-01,
                                              5.8359043236891683e-01,
                                              8.6024013565621915e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_6[7] = {0.0000000000000000e+00,
                                              3.9809857051469444e-02,
                                              1.9801341787360816e-01,
                                              4.3797481024738616e-01,
                                              6.9546427335363614e-01,
                                              9.0146491420117303e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_7[8] = {0.0000000000000000e+00,
                                              2.9316427159785330e-02,
                                              1.4807859966848380e-01,
                                              3.3698469028115419e-01,
                                              5.5867151877155008e-01,
                                              7.6923386203005428e-01,
                                              9.2694567131974104e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_8[9] = {0.0000000000000000e+00,
                                              2.2479386438714499e-02,
                                              1.1467905316090210e-01,
                                              2.6578982278458985e-01,
                                              4.5284637366944458e-01,
                                              6.4737528288683044e-01,
                                              8.1975930826310761e-01,
                                              9.4373743946307853e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_9[10] = {0.0000000000000000e+00,
                                              1.7779915147364100e-02,
                                              9.1323607899795212e-02,
                                              2.1430847939562991e-01,
                                              3.7193216458327238e-01,
                                              5.4518668480342669e-01,
                                              7.1317524285556999e-01,
                                              8.5563374295785422e-01,
                                              9.5536604471003073e-01,
                                              1.0000000000000000e+00};

static jmi_real_t jmi_opt_coll_radau_pp_10[11] = {0.0000000000000000e+00,
                                              1.4412409648874247e-02,
                                              7.4387389709197449e-02,
                                              1.7611665616299477e-01,
                                              3.0966757992763794e-01,
                                              4.6197040108101095e-01,
                                              6.1811723469529389e-01,
                                              7.6282301518504014e-01,
                                              8.8192102120999860e-01,
                                              9.6374218711679271e-01,
                                              1.0000000000000000e+00};

/* Lagrange polynomial coefficients. Lagrange polynomials based on */
/* Radau points plus the beginning of the interval. The first index */
/* denotes polynomial and the second index denotes coefficient. */
static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_1[2][2] = {{-1.0000000000000000e+00, 1.0000000000000000e+00},
                                                  {1.0000000000000000e+00, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_2[3][3] = {{2.9999999999999996e+00, -3.9999999999999996e+00, 1.0000000000000000e+00},
                                                  {-4.5000000000000000e+00, 4.5000000000000000e+00, -0.0000000000000000e+00},
                                                  {1.5000000000000000e+00, -5.0000000000000011e-01, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_3[4][4] = {{-1.0000000000000000e+01, 1.8000000000000000e+01, -9.0000000000000000e+00, 1.0000000000000000e+00},
                                                  {1.5580782047249222e+01, -2.5629591447076638e+01, 1.0048809399827414e+01, -0.0000000000000000e+00},
                                                  {-8.9141153805825564e+00, 1.0296258113743304e+01, -1.3821427331607485e+00, -0.0000000000000000e+00},
                                                  {3.3333333333333339e+00, -2.6666666666666674e+00, 3.3333333333333337e-01, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_4[5][5] = {{3.5000000000000099e+01, -8.0000000000000213e+01, 6.0000000000000142e+01, -1.6000000000000028e+01, 1.0000000000000000e+00},
                                                  {-5.5213817392096935e+01, 1.2131173176226292e+02, -8.3905499604680529e+01, 1.7807585234514530e+01, -0.0000000000000000e+00},
                                                  {3.4078680832035779e+01, -6.3940037031511515e+01, 3.2239269236543826e+01, -2.3779130370680996e+00, -0.0000000000000000e+00},
                                                  {-2.2614863439938929e+01, 3.3878305269248763e+01, -1.2083769631863431e+01, 8.2032780255359727e-01, -0.0000000000000000e+00},
                                                  {8.7499999999999858e+00, -1.1249999999999979e+01, 3.7499999999999907e+00, -2.4999999999999889e-01, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_5[6][6] = {{-1.2599999999999891e+02, 3.4999999999999699e+02, -3.4999999999999710e+02, 1.4999999999999883e+02, -2.4999999999999837e+01, 1.0000000000000000e+00},
                                                  {1.9988739542347662e+02, -5.4382835603613034e+02, 5.2418788396948969e+02, -2.0802785730090045e+02, 2.7780933944064511e+01, -0.0000000000000000e+00},
                                                  {-1.2702285306879540e+02, 3.1767586907995377e+02, -2.6489491356822725e+02, 7.7883376055118177e+01, -3.6414784980492581e+00, -0.0000000000000000e+00},
                                                  {9.2102833136133356e+01, -2.0209087094360774e+02, 1.3790290440413506e+02, -2.9167414317829795e+01, 1.2525477211691316e+00, -0.0000000000000000e+00},
                                                  {-6.4167375490815630e+01, 1.2304335789978730e+02, -7.2395874805400354e+01, 1.4111895563613244e+01, -5.9200316718454860e-01, -0.0000000000000000e+00},
                                                  {2.5199999999999957e+01, -4.4799999999999926e+01, 2.5199999999999971e+01, -4.7999999999999998e+00, 2.0000000000000140e-01, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_6[7][7] = {{4.6199999999999216e+02, -1.5119999999999745e+03, 1.8899999999999684e+03, -1.1199999999999818e+03, 3.1499999999999517e+02, -3.5999999999999559e+01, 1.0000000000000000e+00},
                                                  {-7.3513046623137404e+02, 2.3766160870732824e+03, -2.9127391606175574e+03, 1.6661787339788091e+03, -4.3489498066313394e+02, 3.9969786459973939e+01, -0.0000000000000000e+00},
                                                  {4.7401961173252084e+02, -1.4574746676663367e+03, 1.6505715984969549e+03, -8.2230312902141293e+02, 1.6036813671193590e+02, -5.1815502536623050e+00, -0.0000000000000000e+00},
                                                  {-3.5627943479361710e+02, 1.0099640051121485e+03, -1.0151679852054780e+03, 4.1908971502220919e+02, -5.9367058036710745e+01, 1.7607579014483001e+00, -0.0000000000000000e+00},
                                                  {2.7291896770119570e+02, -7.0338395728354033e+02, 6.2730827330954389e+02, -2.2535124741574091e+02, 2.9357372808400974e+01, -8.4940911985936440e-01, -0.0000000000000000e+00},
                                                  {-1.9452867840871721e+02, 4.6127853276441999e+02, -3.7997272598343170e+02, 1.2905259410278393e+02, -1.6296804153820723e+01, 4.6708167876565504e-01, -0.0000000000000000e+00},
                                                  {7.6999999999999631e+01, -1.7499999999999920e+02, 1.3999999999999943e+02, -4.6666666666666522e+01, 5.8333333333333321e+00, -1.6666666666666871e-01, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_7[8][8] = {{-1.7159999999999814e+03, 6.4679999999999291e+03, -9.7019999999998909e+03, 7.3499999999999172e+03, -2.9399999999999668e+03, 5.8799999999999363e+02, -4.8999999999999524e+01, 1.0000000000000000e+00},
                                                  {2.7354141990507414e+03, -1.0230214794534480e+04, 1.5165697701626259e+04, -1.1271767934426576e+04, 4.3561008389578292e+03, -8.0960444756790298e+02, 5.4374436894128259e+01, -0.0000000000000000e+00},
                                                  {-1.7787262387691653e+03, 6.4410383785763252e+03, -9.1028645602997349e+03, 6.2707306415830963e+03, -2.1189070191537817e+03, 2.9572882206751876e+02, -7.0000240042593322e+00, -0.0000000000000000e+00},
                                                  {1.3621980775102002e+03, -4.6753990102870875e+03, 6.1261204738852584e+03, -3.7701808571400620e+03, 1.0633426386156491e+03, -1.0843698367594618e+02, 2.3556610919875833e+00, -0.0000000000000000e+00},
                                                  {-1.0855032512608877e+03, 3.4850725047392007e+03, -4.1902576328772439e+03, 2.3084681482334067e+03, -5.7010289120550146e+02, 5.3455411437132092e+01, -1.1322890661061473e+00, -0.0000000000000000e+00},
                                                  {8.5389998454275008e+02, -2.5616973126869880e+03, 2.8572748261860929e+03, -1.4595261955536773e+03, 3.4025852585303574e+02, -3.0856719667980954e+01, 6.4689132676736594e-01, -0.0000000000000000e+00},
                                                  {-6.1642562821651347e+02, 1.7520573770502397e+03, -1.8611136656635938e+03, 9.1513334016103454e+02, -2.0783495021012027e+02, 1.8571060264328615e+01, -3.8753338537535587e-01, -0.0000000000000000e+00},
                                                  {2.4514285714285657e+02, -6.7885714285714118e+02, 7.0714285714285529e+02, -3.4285714285714187e+02, 7.7142857142856926e+01, -6.8571428571428479e+00, 1.4285714285714407e-01, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_8[9][9] = {{6.4349999999995334e+03, -2.7455999999998017e+04, 4.8047999999996537e+04, -4.4351999999996813e+04, 2.3099999999998352e+04, -6.7199999999995271e+03, 1.0079999999999313e+03, -6.3999999999996191e+01, 1.0000000000000000e+00},
                                                  {-1.0269771635486131e+04, 4.3586834146176057e+04, -7.5701156256551083e+04, 6.9080710496155953e+04, -3.5312954909912885e+04, 9.9307964465757377e+03, -1.3854532899765002e+03, 7.0995003018864963e+01, -0.0000000000000000e+00},
                                                  {6.7136000262333937e+03, -2.7874784150953030e+04, 4.6931559675713550e+04, -4.0890130276910379e+04, 1.9410861234491731e+04, -4.7849197677250168e+03, 5.0291077485654210e+02, -9.0975157067910484e+00, -0.0000000000000000e+00},
                                                  {-5.1992221682536047e+03, 2.0801447579164214e+04, -3.3292045790564604e+04, 2.6985951993460407e+04, -1.1491283052125877e+04, 2.3752246631398834e+03, -1.8311307008026233e+02, 3.0398452598443368e+00, -0.0000000000000000e+00},
                                                  {4.2312044791797762e+03, -1.6137053506516571e+04, 2.4285387282406511e+04, -1.8165213615581713e+04, 6.9628880432829828e+03, -1.2654818810871477e+03, 8.9721191468426667e+01, -1.4519931522613510e+00, -0.0000000000000000e+00},
                                                  {-3.4701488650701817e+03, 1.2559479887781890e+04, -1.7779748013926444e+04, 1.2407164316003846e+04, -4.4248531349453142e+03, 7.5929789187695781e+02, -5.2025078727510717e+01, 8.3299700675765254e-01, -0.0000000000000000e+00},
                                                  {2.7715355217415795e+03, -9.5532261839678995e+03, 1.2862785807419938e+04, -8.5578872001764303e+03, 2.9336941815081691e+03, -4.8936106832401771e+02, 3.2984336321707609e+01, -5.2539452304393730e-01, -0.0000000000000000e+00},
                                                  {-2.0165723583443760e+03, 6.7009272283133969e+03, -8.7331577044944388e+03, 5.6570292870451776e+03, -1.9002273622971836e+03, 3.1256871554313284e+02, -2.0899863862334641e+01, 3.3205809662556751e-01, -0.0000000000000000e+00},
                                                  {8.0437500000000966e+02, -2.6276250000000323e+03, 3.3783750000000427e+03, -2.1656250000000286e+03, 7.2187500000001012e+02, -1.1812500000000192e+02, 7.8750000000001927e+00, -1.2500000000001063e-01, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_9[10][10] = {{-2.4309999999998843e+04, 1.1582999999999453e+05, -2.3165999999998912e+05, 2.5225199999998833e+05, -1.6216199999999267e+05, 6.2369999999997257e+04, -1.3859999999999425e+04, 1.6199999999999397e+03, -8.0999999999997812e+01, 1.0000000000000000e+00},
                                                  {3.8827862801457355e+04, -1.8431299018333346e+05, 3.6672962325257738e+05, -3.9637575477990258e+05, 2.5195715751855713e+05, -9.5137409582016902e+04, 2.0445617477729076e+04, -2.2239380447720341e+03, 8.9831539704035805e+01, -0.0000000000000000e+00},
                                                  {-2.5473776537191101e+04, 1.1904869573228936e+05, -2.3187814941496012e+05, 2.4315194381174026e+05, -1.4771956130076229e+05, 5.1865514426754402e+04, -9.7869647018843825e+03, 8.0377226062338809e+02, -1.1474276609469241e+01, -0.0000000000000000e+00},
                                                  {1.9871319373430601e+04, -9.0422400070193966e+04, 1.6998369755505110e+05, -1.6976521328276349e+05, 9.6171264519274715e+04, -3.0371755320926546e+04, 4.8204248076199501e+03, -2.9115177207715379e+02, 3.8141905847606767e+00, -0.0000000000000000e+00},
                                                  {-1.6379466160453763e+04, 7.1951288460739001e+04, -1.2932567906727205e+05, 1.2186066911325195e+05, -6.3936771829463542e+04, 1.8243194314816763e+04, -2.5532884179805146e+03, 1.4186513937085365e+02, -1.8115530086786142e+00, -0.0000000000000000e+00},
                                                  {1.3739067144227816e+04, -5.7972257571491085e+04, 9.9319525164317136e+04, -8.8415343471285465e+04, 4.3444791663335840e+04, -1.1563577928860530e+04, 1.5288245884473909e+03, -8.2066226504907078e+01, 1.0366378137882213e+00, -0.0000000000000000e+00},
                                                  {-1.1457620188917675e+04, 4.6420899251123636e+04, -7.6078144526809774e+04, 6.4632609702566639e+04, -3.0334689315645566e+04, 7.7618453636980939e+03, -9.9684288847766459e+02, 5.2603468150498308e+01, -6.6086568819374780e-01, -0.0000000000000000e+00},
                                                  {9.2393392103305614e+03, -3.6117243493523827e+04, 5.7142335533348501e+04, -4.6978821136971768e+04, 2.1435162869148138e+04, -5.3639003780991525e+03, 6.7814340146500570e+02, -3.5460194953748292e+01, 4.4418925628054778e-01, -0.0000000000000000e+00},
                                                  {-6.7578367539960918e+03, 2.5742896763284778e+04, -3.9804319607374200e+04, 3.2094798932265017e+04, -1.4416465235562882e+04, 3.5649779935255096e+03, -4.4702537803054906e+02, 2.3264259052052058e+01, -2.9097316363691950e-01, -0.0000000000000000e+00},
                                                  {2.7011111111111500e+03, -1.0168888888889041e+04, 1.5571111111111353e+04, -1.2456888888889094e+04, 5.5611111111112095e+03, -1.3688888888889162e+03, 1.7111111111111532e+02, -8.8888888888891966e+00, 1.1111111111111800e-01, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_coeffs_10[11][11] = {{9.2378000000013257e+04, -4.8620000000006973e+05, 1.0939500000001565e+06, -1.3728000000001956e+06, 1.0510500000001490e+06, -5.0450400000007096e+05, 1.5015000000002087e+05, -2.6400000000003587e+04, 2.4750000000003188e+03, -1.0000000000001080e+02, 1.0000000000000000e+00},
                                                  {-1.4762990239376685e+05, 7.7487178365326091e+05, -1.7370810745653471e+06, 2.1688453784061261e+06, -1.6484317778766134e+06, 7.8249335758794902e+05, -2.2867810888795741e+05, 3.8894214771708699e+04, -3.3947547707449185e+03, 1.1088407538477624e+02, -0.0000000000000000e+00},
                                                  {9.7100869471223297e+04, -5.0383412752482254e+05, 1.1123998118293979e+06, -1.3602365388425053e+06, 1.0036009888746401e+06, -4.5564175063342520e+05, 1.2393249015445105e+05, -1.8530698194893546e+04, 1.2230852915720363e+03, -1.4130425638104198e+01, -0.0000000000000000e+00},
                                                  {-7.6125115909291460e+04, 3.8725160392177966e+05, -8.3328017819146439e+05, 9.8451655370623351e+05, -6.9273965138155955e+05, 2.9373912809072068e+05, -7.2000420513202160e+04, 9.0747396264278614e+03, -4.4133841358829790e+02, 4.6790639441463728e+00, -0.0000000000000000e+00},
                                                  {6.3279215732437478e+04, -3.1345298225935118e+05, 6.5229290723624721e+05, -7.3837828019082453e+05, 4.9132068588269403e+05, -1.9344071270496724e+05, 4.2950897062963304e+04, -4.7835813080724074e+03, 2.1406260831224725e+02, -2.2120594388305523e+00, -0.0000000000000000e+00},
                                                  {-5.3817356528902492e+04, 2.5838721910818358e+05, -5.1794355375454610e+05, 5.6048798253881093e+05, -3.5338936247423990e+05, 1.3065732035302727e+05, -2.7114216822167502e+04, 2.8540838758988166e+03, -1.2337736740401411e+02, 1.2610713393536863e+00, -0.0000000000000000e+00},
                                                  {4.5949307182384677e+04, -2.1343640016291593e+05, 4.1220781497095642e+05, -4.2804524676233291e+05, 2.5821570062377868e+05, -9.1335390716470545e+04, 1.8229427271517441e+04, -1.8635768531576814e+03, 7.9169156537790641e+01, -8.0471029795451543e-01, -0.0000000000000000e+00},
                                                  {-3.8731727793473459e+04, 1.7430574553427449e+05, -3.2570076318175910e+05, 3.2712781753602554e+05, -1.9113769893823232e+05, 6.5721361170150121e+04, -1.2820279833258744e+04, 1.2892388619699059e+03, -5.4242990883282779e+01, 5.4963518680503443e-01, -0.0000000000000000e+00},
                                                  {3.1437003617281240e+04, -1.3773295944122929e+05, 2.5081071374943547e+05, -2.4598004515309414e+05, 1.4074610568937703e+05, -4.7559968326970215e+04, 9.1531610655167169e+03, -9.1177496028839153e+02, 3.8149631642046373e+01, -3.8587167046213322e-01, -0.0000000000000000e+00},
                                                  {-2.3078093377906007e+04, 9.9222317170891300e+04, -1.7766847809307906e+05, 1.7172957876175790e+05, -9.7072790399994628e+04, 3.2483255180057462e+04, -6.2053494978836716e+03, 6.1495418041033690e+02, -2.5653145443926508e+01, 2.5922119028089824e-01, -0.0000000000000000e+00},
                                                  {9.2378000000003485e+03, -3.9382200000001467e+04, 7.0012800000002564e+04, -6.7267200000002413e+04, 3.7837800000001327e+04, -1.2612600000000421e+04, 2.4024000000000724e+03, -2.3760000000000559e+02, 9.9000000000000359e+00, -9.9999999999989389e-02, 0.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_1[2][2] = {{0.0000000000000000e+00, -1.0000000000000000e+00},
                                                      {0.0000000000000000e+00, 1.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_2[3][3] = {{0.0000000000000000e+00, 5.9999999999999991e+00, -3.9999999999999996e+00},
                                                      {0.0000000000000000e+00, -9.0000000000000000e+00, 4.5000000000000000e+00},
                                                      {0.0000000000000000e+00, 3.0000000000000000e+00, -5.0000000000000011e-01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_3[4][4] = {{0.0000000000000000e+00, -3.0000000000000000e+01, 3.6000000000000000e+01, -9.0000000000000000e+00},
                                                      {0.0000000000000000e+00, 4.6742346141747667e+01, -5.1259182894153277e+01, 1.0048809399827414e+01},
                                                      {0.0000000000000000e+00, -2.6742346141747667e+01, 2.0592516227486609e+01, -1.3821427331607485e+00},
                                                      {0.0000000000000000e+00, 1.0000000000000002e+01, -5.3333333333333348e+00, 3.3333333333333337e-01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_4[5][5] = {{0.0000000000000000e+00, 1.4000000000000040e+02, -2.4000000000000063e+02, 1.2000000000000028e+02, -1.6000000000000028e+01},
                                                      {0.0000000000000000e+00, -2.2085526956838774e+02, 3.6393519528678877e+02, -1.6781099920936106e+02, 1.7807585234514530e+01},
                                                      {0.0000000000000000e+00, 1.3631472332814312e+02, -1.9182011109453455e+02, 6.4478538473087653e+01, -2.3779130370680996e+00},
                                                      {0.0000000000000000e+00, -9.0459453759755718e+01, 1.0163491580774630e+02, -2.4167539263726862e+01, 8.2032780255359727e-01},
                                                      {0.0000000000000000e+00, 3.4999999999999943e+01, -3.3749999999999936e+01, 7.4999999999999813e+00, -2.4999999999999889e-01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_5[6][6] = {{0.0000000000000000e+00, -6.2999999999999454e+02, 1.3999999999999879e+03, -1.0499999999999914e+03, 2.9999999999999767e+02, -2.4999999999999837e+01},
                                                      {0.0000000000000000e+00, 9.9943697711738309e+02, -2.1753134241445214e+03, 1.5725636519084692e+03, -4.1605571460180090e+02, 2.7780933944064511e+01},
                                                      {0.0000000000000000e+00, -6.3511426534397697e+02, 1.2707034763198151e+03, -7.9468474070468176e+02, 1.5576675211023635e+02, -3.6414784980492581e+00},
                                                      {0.0000000000000000e+00, 4.6051416568066679e+02, -8.0836348377443096e+02, 4.1370871321240520e+02, -5.8334828635659591e+01, 1.2525477211691316e+00},
                                                      {0.0000000000000000e+00, -3.2083687745407815e+02, 4.9217343159914918e+02, -2.1718762441620106e+02, 2.8223791127226487e+01, -5.9200316718454860e-01},
                                                      {0.0000000000000000e+00, 1.2599999999999979e+02, -1.7919999999999970e+02, 7.5599999999999909e+01, -9.5999999999999996e+00, 2.0000000000000140e-01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_6[7][7] = {{0.0000000000000000e+00, 2.7719999999999527e+03, -7.5599999999998727e+03, 7.5599999999998736e+03, -3.3599999999999454e+03, 6.2999999999999034e+02, -3.5999999999999559e+01},
                                                      {0.0000000000000000e+00, -4.4107827973882440e+03, 1.1883080435366412e+04, -1.1650956642470230e+04, 4.9985362019364275e+03, -8.6978996132626787e+02, 3.9969786459973939e+01},
                                                      {0.0000000000000000e+00, 2.8441176703951251e+03, -7.2873733383316830e+03, 6.6022863939878198e+03, -2.4669093870642387e+03, 3.2073627342387181e+02, -5.1815502536623050e+00},
                                                      {0.0000000000000000e+00, -2.1376766087617025e+03, 5.0498200255607426e+03, -4.0606719408219119e+03, 1.2572691450666275e+03, -1.1873411607342149e+02, 1.7607579014483001e+00},
                                                      {0.0000000000000000e+00, 1.6375138062071742e+03, -3.5169197864177017e+03, 2.5092330932381756e+03, -6.7605374224722277e+02, 5.8714745616801949e+01, -8.4940911985936440e-01},
                                                      {0.0000000000000000e+00, -1.1671720704523032e+03, 2.3063926638221001e+03, -1.5198909039337268e+03, 3.8715778230835178e+02, -3.2593608307641446e+01, 4.6708167876565504e-01},
                                                      {0.0000000000000000e+00, 4.6199999999999778e+02, -8.7499999999999602e+02, 5.5999999999999773e+02, -1.3999999999999957e+02, 1.1666666666666664e+01, -1.6666666666666871e-01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_7[8][8] = {{0.0000000000000000e+00, -1.2011999999999869e+04, 3.8807999999999578e+04, -4.8509999999999454e+04, 2.9399999999999669e+04, -8.8199999999999000e+03, 1.1759999999999873e+03, -4.8999999999999524e+01},
                                                      {0.0000000000000000e+00, 1.9147899393355190e+04, -6.1381288767206883e+04, 7.5828488508131297e+04, -4.5087071737706305e+04, 1.3068302516873488e+04, -1.6192088951358060e+03, 5.4374436894128259e+01},
                                                      {0.0000000000000000e+00, -1.2451083671384156e+04, 3.8646230271457949e+04, -4.5514322801498674e+04, 2.5082922566332385e+04, -6.3567210574613455e+03, 5.9145764413503753e+02, -7.0000240042593322e+00},
                                                      {0.0000000000000000e+00, 9.5353865425714012e+03, -2.8052394061722523e+04, 3.0630602369426291e+04, -1.5080723428560248e+04, 3.1900279158469475e+03, -2.1687396735189236e+02, 2.3556610919875833e+00},
                                                      {0.0000000000000000e+00, -7.5985227588262142e+03, 2.0910435028435204e+04, -2.0951288164386220e+04, 9.2338725929336269e+03, -1.7103086736165044e+03, 1.0691082287426418e+02, -1.1322890661061473e+00},
                                                      {0.0000000000000000e+00, 5.9772998917992509e+03, -1.5370183876121928e+04, 1.4286374130930464e+04, -5.8381047822147093e+03, 1.0207755775591072e+03, -6.1713439335961908e+01, 6.4689132676736594e-01},
                                                      {0.0000000000000000e+00, -4.3149793975155944e+03, 1.0512344262301438e+04, -9.3055683283179696e+03, 3.6605333606441382e+03, -6.2350485063036081e+02, 3.7142120528657230e+01, -3.8753338537535587e-01},
                                                      {0.0000000000000000e+00, 1.7159999999999959e+03, -4.0731428571428469e+03, 3.5357142857142762e+03, -1.3714285714285675e+03, 2.3142857142857076e+02, -1.3714285714285696e+01, 1.4285714285714407e-01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_8[9][9] = {{0.0000000000000000e+00, 5.1479999999996267e+04, -1.9219199999998612e+05, 2.8828799999997922e+05, -2.2175999999998405e+05, 9.2399999999993408e+04, -2.0159999999998581e+04, 2.0159999999998627e+03, -6.3999999999996191e+01},
                                                      {0.0000000000000000e+00, -8.2158173083889051e+04, 3.0510783902323240e+05, -4.5420693753930647e+05, 3.4540355248077976e+05, -1.4125181963965154e+05, 2.9792389339727211e+04, -2.7709065799530003e+03, 7.0995003018864963e+01},
                                                      {0.0000000000000000e+00, 5.3708800209867150e+04, -1.9512348905667121e+05, 2.8158935805428133e+05, -2.0445065138455189e+05, 7.7643444937966924e+04, -1.4354759303175051e+04, 1.0058215497130842e+03, -9.0975157067910484e+00},
                                                      {0.0000000000000000e+00, -4.1593777346028837e+04, 1.4561013305414951e+05, -1.9975227474338762e+05, 1.3492975996730203e+05, -4.5965132208503506e+04, 7.1256739894196508e+03, -3.6622614016052466e+02, 3.0398452598443368e+00},
                                                      {0.0000000000000000e+00, 3.3849635833438209e+04, -1.1295937454561600e+05, 1.4571232369443908e+05, -9.0826068077908567e+04, 2.7851552173131931e+04, -3.7964456432614434e+03, 1.7944238293685333e+02, -1.4519931522613510e+00},
                                                      {0.0000000000000000e+00, -2.7761190920561454e+04, 8.7916359214473225e+04, -1.0667848808355867e+05, 6.2035821580019227e+04, -1.7699412539781257e+04, 2.2778936756308735e+03, -1.0405015745502143e+02, 8.3299700675765254e-01},
                                                      {0.0000000000000000e+00, 2.2172284173932636e+04, -6.6872583287775298e+04, 7.7176714844519622e+04, -4.2789436000882153e+04, 1.1734776726032676e+04, -1.4680832049720532e+03, 6.5968672643415218e+01, -5.2539452304393730e-01},
                                                      {0.0000000000000000e+00, -1.6132578866755008e+04, 4.6906490598193777e+04, -5.2398946226966633e+04, 2.8285146435225888e+04, -7.6009094491887345e+03, 9.3770614662939852e+02, -4.1799727724669282e+01, 3.3205809662556751e-01},
                                                      {0.0000000000000000e+00, 6.4350000000000773e+03, -1.8393375000000226e+04, 2.0270250000000255e+04, -1.0828125000000144e+04, 2.8875000000000405e+03, -3.5437500000000574e+02, 1.5750000000000385e+01, -1.2500000000001063e-01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_9[10][10] = {{0.0000000000000000e+00, -2.1878999999998958e+05, 9.2663999999995623e+05, -1.6216199999999239e+06, 1.5135119999999299e+06, -8.1080999999996333e+05, 2.4947999999998903e+05, -4.1579999999998276e+04, 3.2399999999998795e+03, -8.0999999999997812e+01},
                                                      {0.0000000000000000e+00, 3.4945076521311619e+05, -1.4745039214666677e+06, 2.5671073627680419e+06, -2.3782545286794156e+06, 1.2597857875927857e+06, -3.8054963832806761e+05, 6.1336852433187232e+04, -4.4478760895440682e+03, 8.9831539704035805e+01},
                                                      {0.0000000000000000e+00, -2.2926398883471990e+05, 9.5238956585831486e+05, -1.6231470459047209e+06, 1.4589116628704416e+06, -7.3859780650381139e+05, 2.0746205770701761e+05, -2.9360894105653148e+04, 1.6075445212467762e+03, -1.1474276609469241e+01},
                                                      {0.0000000000000000e+00, 1.7884187436087540e+05, -7.2337920056155173e+05, 1.1898858828853576e+06, -1.0185912796965810e+06, 4.8085632259637356e+05, -1.2148702128370618e+05, 1.4461274422859849e+04, -5.8230354415430759e+02, 3.8141905847606767e+00},
                                                      {0.0000000000000000e+00, -1.4741519544408386e+05, 5.7561030768591200e+05, -9.0527975347090443e+05, 7.3116401467951166e+05, -3.1968385914731771e+05, 7.2972777259267052e+04, -7.6598652539415434e+03, 2.8373027874170731e+02, -1.8115530086786142e+00},
                                                      {0.0000000000000000e+00, 1.2365160429805034e+05, -4.6377806057192868e+05, 6.9523667615021998e+05, -5.3049206082771276e+05, 2.1722395831667920e+05, -4.6254311715442120e+04, 4.5864737653421726e+03, -1.6413245300981416e+02, 1.0366378137882213e+00},
                                                      {0.0000000000000000e+00, -1.0311858170025908e+05, 3.7136719400898908e+05, -5.3254701168766839e+05, 3.8779565821539983e+05, -1.5167344657822783e+05, 3.1047381454792376e+04, -2.9905286654329939e+03, 1.0520693630099662e+02, -6.6086568819374780e-01},
                                                      {0.0000000000000000e+00, 8.3154052892975058e+04, -2.8893794794819062e+05, 3.9999634873343952e+05, -2.8187292682183062e+05, 1.0717581434574068e+05, -2.1455601512396610e+04, 2.0344302043950170e+03, -7.0920389907496585e+01, 4.4418925628054778e-01},
                                                      {0.0000000000000000e+00, -6.0820530785964824e+04, 2.0594317410627822e+05, -2.7863023725161940e+05, 1.9256879359359009e+05, -7.2082326177814408e+04, 1.4259911974102039e+04, -1.3410761340916472e+03, 4.6528518104104116e+01, -2.9097316363691950e-01},
                                                      {0.0000000000000000e+00, 2.4310000000000349e+04, -8.1351111111112332e+04, 1.0899777777777947e+05, -7.4741333333334565e+04, 2.7805555555556050e+04, -5.4755555555556648e+03, 5.1333333333334599e+02, -1.7777777777778393e+01, 1.1111111111111800e-01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_coeffs_10[11][11] = {{0.0000000000000000e+00, 9.2378000000013260e+05, -4.3758000000006277e+06, 8.7516000000012517e+06, -9.6096000000013690e+06, 6.3063000000008941e+06, -2.5225200000003548e+06, 6.0060000000008347e+05, -7.9200000000010768e+04, 4.9500000000006376e+03, -1.0000000000001080e+02},
                                                      {0.0000000000000000e+00, -1.4762990239376687e+06, 6.9738460528793484e+06, -1.3896648596522776e+07, 1.5181917648842882e+07, -9.8905906672596801e+06, 3.9124667879397450e+06, -9.1471243555182964e+05, 1.1668264431512609e+05, -6.7895095414898369e+03, 1.1088407538477624e+02},
                                                      {0.0000000000000000e+00, 9.7100869471223303e+05, -4.5345071477234028e+06, 8.8991984946351834e+06, -9.5216557718975376e+06, 6.0216059332478400e+06, -2.2782087531671259e+06, 4.9572996061780420e+05, -5.5592094584680643e+04, 2.4461705831440727e+03, -1.4130425638104198e+01},
                                                      {0.0000000000000000e+00, -7.6125115909291455e+05, 3.4852644352960167e+06, -6.6662414255317152e+06, 6.8916158759436347e+06, -4.1564379082893571e+06, 1.4686956404536034e+06, -2.8800168205280864e+05, 2.7224218879283584e+04, -8.8267682717659579e+02, 4.6790639441463728e+00},
                                                      {0.0000000000000000e+00, 6.3279215732437477e+05, -2.8210768403341607e+06, 5.2183432578899777e+06, -5.1686479613357717e+06, 2.9479241152961641e+06, -9.6720356352483621e+05, 1.7180358825185322e+05, -1.4350743924217222e+04, 4.2812521662449450e+02, -2.2120594388305523e+00},
                                                      {0.0000000000000000e+00, -5.3817356528902496e+05, 2.3254849719736520e+06, -4.1435484300363688e+06, 3.9234158777716765e+06, -2.1203361748454394e+06, 6.5328660176513635e+05, -1.0845686728867001e+05, 8.5622516276964488e+03, -2.4675473480802822e+02, 1.2610713393536863e+00},
                                                      {0.0000000000000000e+00, 4.5949307182384678e+05, -1.9209276014662434e+06, 3.2976625197676513e+06, -2.9963167273363303e+06, 1.5492942037426722e+06, -4.5667695358235273e+05, 7.2917709086069764e+04, -5.5907305594730442e+03, 1.5833831307558128e+02, -8.0471029795451543e-01},
                                                      {0.0000000000000000e+00, -3.8731727793473459e+05, 1.5687517098084704e+06, -2.6056061054540728e+06, 2.2898947227521790e+06, -1.1468261936293938e+06, 3.2860680585075059e+05, -5.1281119333034978e+04, 3.8677165859097177e+03, -1.0848598176656556e+02, 5.4963518680503443e-01},
                                                      {0.0000000000000000e+00, 3.1437003617281240e+05, -1.2395966349710636e+06, 2.0064857099954837e+06, -1.7218603160716589e+06, 8.4447663413626212e+05, -2.3779984163485107e+05, 3.6612644262066868e+04, -2.7353248808651747e+03, 7.6299263284092746e+01, -3.8587167046213322e-01},
                                                      {0.0000000000000000e+00, -2.3078093377906008e+05, 8.9300085453802173e+05, -1.4213478247446325e+06, 1.2021070513323054e+06, -5.8243674239996774e+05, 1.6241627590028732e+05, -2.4821397991534686e+04, 1.8448625412310107e+03, -5.1306290887853017e+01, 2.5922119028089824e-01},
                                                      {0.0000000000000000e+00, 9.2378000000003492e+04, -3.5443980000001320e+05, 5.6010240000002051e+05, -4.7087040000001690e+05, 2.2702680000000796e+05, -6.3063000000002103e+04, 9.6096000000002896e+03, -7.1280000000001678e+02, 1.9800000000000072e+01, -9.9999999999989389e-02}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_1[2][2] = {{-1.0000000000000000e+00, -1.0000000000000000e+00},
                                                      {1.0000000000000000e+00, 1.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_2[3][3] = {{-3.9999999999999996e+00, -1.9999999999999996e+00, 1.9999999999999996e+00},
                                                      {4.5000000000000000e+00, 1.4999999999999996e+00, -4.5000000000000000e+00},
                                                      {-5.0000000000000011e-01, 4.9999999999999989e-01, 2.5000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_3[4][4] = {{-9.0000000000000000e+00, -4.1393876913398140e+00, 1.7393876913398127e+00, -3.0000000000000000e+00},
                                                      {1.0048809399827414e+01, 3.2247448713915885e+00, -3.5678400846904061e+00, 5.5319726474218047e+00},
                                                      {-1.3821427331607485e+00, 1.1678400846904053e+00, 7.7525512860840973e-01, -7.5319726474218065e+00},
                                                      {3.3333333333333337e-01, -2.5319726474218085e-01, 1.0531972647421810e+00, 5.0000000000000000e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_4[5][5] = {{-1.6000000000000028e+01, -7.1555920234752595e+00, 2.5082250819484742e+00, -1.9648779564323959e+00, 4.0000000000000284e+00},
                                                      {1.7807585234514530e+01, 5.6441078759501213e+00, -5.0492146383914225e+00, 3.4924661586254420e+00, -6.9234882564454985e+00},
                                                      {-2.3779130370680996e+00, 1.9235072770547075e+00, 1.2211000288946812e+00, -3.9845178957825143e+00, 6.5952376696281174e+00},
                                                      {8.2032780255359727e-01, -5.8590148210381499e-01, 1.7546809887608412e+00, 6.3479209515522794e-01, -1.2171749413182686e+01},
                                                      {-2.4999999999999889e-01, 1.7387835257424505e-01, -4.3479146121258117e-01, 1.8221375984342469e+00, 8.4999999999999911e+00}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_5[6][6] = {{-2.4999999999999837e+01, -1.1038679241208802e+01, 3.5830685225010370e+00, -2.3441715579038878e+00, 2.2826355002055720e+00, -5.0000000000001208e+00},
                                                      {2.7780933944064511e+01, 8.7559239779381777e+00, -7.1613807201453490e+00, 4.1221652462434122e+00, -3.8786632197238369e+00, 8.4124242235945097e+00},
                                                      {-3.6414784980492581e+00, 2.8919426153801462e+00, 1.8060777240836643e+00, -4.4960171258133368e+00, 3.3931519180651275e+00, -6.9702561166565484e+00},
                                                      {1.2525477211691316e+00, -8.7518639620027083e-01, 2.3637971760686058e+00, 8.5676524539719279e-01, -5.1883409064071486e+00, 8.7771142041505730e+00},
                                                      {-5.9200316718454860e-01, 3.9970520793996767e-01, -8.6590078028313155e-01, 2.5183209492110761e+00, 5.8123305258083524e-01, -1.8219282311088087e+01},
                                                      {2.0000000000000140e-01, -1.3370616384921608e-01, 2.7433807777519359e-01, -6.5706275713435414e-01, 2.8099836552797051e+00, 1.2999999999999993e+01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_6[7][7] = {{-3.5999999999999559e+01, -1.5786539322178442e+01, 4.9221069407461329e+00, -2.9607523846504407e+00, 2.4340720577571346e+00, -2.6345685975967896e+00, 5.9999999999989626e+00},
                                                      {3.9969786459973939e+01, 1.2559703476291030e+01, -9.8028387125678975e+00, 5.1821578385588083e+00, -4.1082390934585646e+00, 4.3857850634015136e+00, -9.9429774219286671e+00},
                                                      {-5.1815502536623050e+00, 4.0758259888763710e+00, 2.5250814079637554e+00, -5.5445229095274851e+00, 3.4915029091136880e+00, -3.4640050474516459e+00, 7.6760621572326393e+00},
                                                      {1.7607579014483001e+00, -1.2172038084642767e+00, 3.1322258626473305e+00, 1.1416181668475449e+00, -5.0698787509933805e+00, 3.9515424565884416e+00, -8.2327371282174795e+00},
                                                      {-8.4940911985936440e-01, 5.6623186694415006e-01, -1.1574099927743819e+00, 2.9749762538212301e+00, 7.1894419189758751e-01, -6.8105394388916807e+00, 1.1638707277367823e+01},
                                                      {4.6708167876565504e-01, -3.0710421225684409e-01, 5.8338219245410994e-01, -1.1780193270588464e+00, 3.4600417960862453e+00, 5.5465275699958994e-01, -2.5639054884453895e+01},
                                                      {-1.6666666666666871e-01, 1.0908601078800775e-01, -2.0254769846905121e-01, 3.8454236200917102e-01, -9.2644311040311789e-01, 4.0171328069512606e+00, 1.8499999999999911e+01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_7[8][8] = {{-4.8999999999999524e+01, -2.1398490858564056e+01, 6.5150217985268313e+00, -3.7382371560182861e+00, 2.8296298188947588e+00, -2.6124734408871646e+00, 3.0031865922222707e+00, -6.9999999999886100e+00},
                                                      {5.4374436894128259e+01, 1.7055284304421072e+01, -1.2948988698811512e+01, 6.5267974337015247e+00, -4.7604156431686988e+00, 4.3294510166373286e+00, -4.9436238335155736e+00, 1.1495455205109330e+01},
                                                      {-7.0000240042593322e+00, 5.4752995121855825e+00, 3.3765851454525073e+00, -6.9123049254819424e+00, 3.9908603180952351e+00, -3.3535280016801261e+00, 3.7048026760214370e+00, -8.5170724230638388e+00},
                                                      {2.3556610919875833e+00, -1.6185811051907946e+00, 4.0540135039255585e+00, 1.4837469310040214e+00, -5.6606883336575411e+00, 3.6906179318630246e+00, -3.7457284313746042e+00, 8.3810313019654199e+00},
                                                      {-1.1322890661061473e+00, 7.4965412823850963e-01, -1.4863139760065329e+00, 3.5946033544558933e+00, 8.9498029378593991e-01, -6.0373091872652260e+00, 4.7816656257629324e+00, -1.0033441651948813e+01},
                                                      {6.4689132676736594e-01, -4.2189137598301785e-01, 7.7285447377889072e-01, -1.4502156012225418e+00, 3.7358993914999603e+00, 6.4999738659502915e-01, -8.7833887559257704e+00, 1.5094393942989660e+01},
                                                      {-3.8753338537535587e-01, 2.5105021424639296e-01, -4.4494694720106748e-01, 7.6703844918134501e-01, -1.5419785025494011e+00, 4.5773009414141468e+00, 5.3940593874002640e-01, -3.4420366375066855e+01},
                                                      {1.4285714285714407e-01, -9.2324819353684279e-02, 1.6177470033537913e-01, -2.7142848561987282e-01, 5.1171265709970304e-01, -1.2440566466771756e+00, 5.4436801880591492e+00, 2.5000000000000004e+01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_8[9][9] = {{-6.3999999999996191e+01, -2.7874257744135953e+01, 8.3581274411957764e+00, -4.6566310317067590e+00, 3.3584094491301073e+00, -2.8644703520264443e+00, 2.8323162584579364e+00, -3.3812988502914578e+00, 8.0000000000192699e+00},
                                                      {7.0995003018864963e+01, 2.2242599964331411e+01, -1.6591130197062299e+01, 8.1182360178222055e+00, -5.6397236373886273e+00, 4.7359270908051485e+00, -4.6476082085685846e+00, 5.5279700242061409e+00, -1.3060996041835324e+01},
                                                      {-9.0975157067910484e+00, 7.0903116738932805e+00, 4.3599941420735924e+00, -8.5451889592400239e+00, 4.6920195582473490e+00, -3.6318485925780006e+00, 3.4355514890348573e+00, -4.0156563254176270e+00, 9.4274917235457654e+00},
                                                      {3.0398452598443368e+00, -2.0807353791507204e+00, 5.1249247660281583e+00, 1.8811856479741871e+00, -6.5690329421679978e+00, 3.9264353565756958e+00, -3.3863518750975308e+00, 3.8030184071966349e+00, -8.8035819494447374e+00},
                                                      {-1.4519931522613510e+00, 9.5733575045933605e-01, -1.8637038978971598e+00, 4.3506356667047861e+00, 1.1041272031142775e+00, -6.2680399567908385e+00, 4.1608354660877414e+00, -4.2743007393847030e+00, 9.6138240078075370e+00},
                                                      {8.3299700675765254e-01, -5.4072898089933907e-01, 9.7031561191454752e-01, -1.7491131793870709e+00, 4.2159935768431422e+00, 7.7234953699531139e-01, -7.2632440822927453e+00, 5.8064614838011783e+00, -1.2234234226312379e+01},
                                                      {-5.2539452304393730e-01, 3.3849233242015186e-01, -5.8549937027752152e-01, 9.6226841393821305e-01, -1.7852268638039615e+00, 4.6331389540705850e+00, 6.0993512969307206e-01, -1.1085659975286870e+01, 1.9116528975804307e+01},
                                                      {3.3205809662556751e-01, -2.1314332000182590e-01, 3.6230408377694345e-01, -5.7210967985579753e-01, 9.7087801789151762e-01, -1.9608436116899535e+00, 5.8687860194586623e+00, 5.2980837581565365e-01, -4.4559032489354870e+01},
                                                      {-1.2500000000001063e-01, 8.0125703083642807e-02, -1.3533257975211652e-01, 2.1071710374962174e-01, -3.4744436186398664e-01, 6.5735157465982585e-01, -1.6102201966984788e+00, 7.0896575994900051e+00, 3.2499999999996909e+01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_9[10][10] = {{-8.0999999999997812e+01, -3.5213710416993734e+01, 1.0449814072751323e+01, -5.7084591899166668e+00, 3.9904463666218675e+00, -3.2455064190566816e+00, 2.9750500648062115e+00, -3.0750780530857043e+00, 3.7653682880635699e+00, -8.9999999999364206e+00},
                                                      {8.9831539704035805e+01, 2.8121619021005792e+01, -2.0725485790520565e+01, 9.9423970233029308e+00, -6.6935072577871040e+00, 5.3584667525465903e+00, -4.8732343455414053e+00, 5.0157319195754297e+00, -6.1280826774267467e+00, 1.4634983139975503e+01},
                                                      {-1.1474276609469241e+01, 8.9208125880354867e+00, 5.4750355521279435e+00, -1.0423532855003135e+01, 5.5423338384107286e+00, -4.0851803637452377e+00, 3.5752970669361304e+00, -3.6073045055227047e+00, 4.3626519360119822e+00, -1.0378668493966059e+01},
                                                      {3.8141905847606767e+00, -2.6040992690899674e+00, 6.3428096315810336e+00, 2.3330854729129422e+00, -7.6967163804008454e+00, 4.3712062221087038e+00, -3.4765438484929034e+00, 3.3535705190208089e+00, -3.9679579550844841e+00, 9.3633700579389192e+00},
                                                      {-1.8115530086786142e+00, 1.1911494434189822e+00, -2.2914242158304092e+00, 5.2293963901917948e+00, 1.3443311646910789e+00, -6.8811008500220412e+00, 4.1893000847815633e+00, -3.6650620071510636e+00, 4.1543243533272669e+00, -9.6549658238217688e+00},
                                                      {1.0366378137882213e+00, -6.7091586184779439e-01, 1.1883354641034258e+00, -2.0895962536333696e+00, 4.8414218808272809e+00, 9.1711704254292625e-01, -7.1381081229270738e+00, 4.7899257931869963e+00, -4.9565072577377380e+00, 1.1183600012103714e+01},
                                                      {-6.6086568819374780e-01, 4.2434507579789948e-01, -7.2329307387048436e-01, 1.1558012179446853e+00, -2.0498912777637659e+00, 4.9642937665742037e+00, 7.0108995650998374e-01, -8.7049271749741255e+00, 7.0005003239158103e+00, -1.4788881794178888e+01},
                                                      {4.4418925628054778e-01, -2.8400708051218143e-01, 4.7454560842852656e-01, -7.2499641696080208e-01, 1.1661748317290401e+00, -2.1661878582093306e+00, 5.6605433779469401e+00, 5.8436218076863966e-01, -1.3708734741290531e+01, 2.3693693481195591e+01},
                                                      {-2.9097316363691950e-01, 1.8563208227400713e-01, -3.0702892266562076e-01, 4.5891161293464311e-01, -7.0715775482582899e-01, 1.1991586582086804e+00, -2.4353177255093978e+00, 7.3338317476417796e+00, 5.2335960937600157e-01, -5.6053130579467698e+01},
                                                      {1.1111111111111800e-01, -7.0825582088466496e-02, 1.1669167389480468e-01, -1.7300700177284667e-01, 2.6256458849744835e-01, -4.3226695095250706e-01, 8.2192349146488597e-01, -2.0250504194765573e+00, 8.9550781209895405e+00, 4.0999999999984460e+01}};

static jmi_real_t jmi_opt_coll_radau_lpp_dot_vals_10[11][11] = {{-1.0000000000001080e+02, -4.3416781419342648e+01, 1.2789280640127870e+01, -6.8903321459110458e+00, 4.7142404222016552e+00, -3.7156264261982983e+00, 3.2525107071646175e+00, -3.1266401233890662e+00, 3.3319441718536353e+00, -4.1534382571651491e+00, 9.9999999997536406e+00},
                                                      {1.1088407538477624e+02, 3.4692325029711540e+01, -2.5350183165320416e+01, 1.1992920109565915e+01, -7.9016125993947099e+00, 6.1291839374507759e+00, -5.3219491195150823e+00, 5.0929279058776444e+00, -5.4132663091945261e+00, 6.7384079921253175e+00, -1.6214760958011524e+01},
                                                      {-1.4130425638104198e+01, 1.0966768447402506e+01, 6.7215693675305506e+00, -1.2538605513097139e+01, 6.5219380332406285e+00, -4.6551751335160194e+00, 3.8865206483669201e+00, -3.6416056276688202e+00, 3.8249111829923397e+00, -4.7309476298984219e+00, 1.1355997819397844e+01},
                                                      {4.6790639441463728e+00, -3.1888361830092400e+00, 7.7065310982147324e+00, 2.8390273293474664e+00, -9.0078258764223538e+00, 4.9483649150227578e+00, -3.7482293892476353e+00, 3.3499652390256958e+00, -3.4308559344737706e+00, 4.1880152585686101e+00, -1.0002157489304869e+01},
                                                      {-2.2120594388305523e+00, 1.4517413398174619e+00, -2.7698267590575805e+00, 6.2242384877488046e+00, 1.6146346353614844e+00, -7.7202395871990861e+00, 4.4647570524756954e+00, -3.6053466136761134e+00, 3.5174791348020342e+00, -4.1921216101415855e+00, 9.9228005693846324e+00},
                                                      {1.2610713393536863e+00, -8.1451429917844198e-01, 1.4299949714405731e+00, -2.4731502897231361e+00, 5.5841017836234741e+00, 1.0823204231885502e+00, -7.5008453645139443e+00, 4.6185080115030086e+00, -4.0764581658064607e+00, 4.6474657469277982e+00, -1.0827984810701201e+01},
                                                      {-8.0471029795451543e-01, 5.1556091762312095e-01, -8.7030740153715658e-01, 1.3656146364570070e+00, -2.3541470707696446e+00, 5.4679360154211158e+00, 8.0890803870265560e-01, -8.1983454974951755e+00, 5.5405999986507668e+00, -5.7606826680914276e+00, 1.3025078618233421e+01},
                                                      {5.4963518680503443e-01, -3.5055212589927065e-01, 5.7940256827288983e-01, -8.6719768276501918e-01, 1.3506990350351911e+00, -2.3921627303691841e+00, 5.8250817330321478e+00, 6.5546003470533298e-01, -1.0344779438075214e+01, 8.3530593109638680e+00, -1.7677700506079404e+01},
                                                      {-3.8587167046213322e-01, 2.4546694513995782e-01, -4.0091971023090200e-01, 5.8509830262054752e-01, -8.6814375213057460e-01, 1.3909789457353772e+00, -2.5934695458478765e+00, 6.8150615676062962e+00, 5.6694419124090545e-01, -1.6648517046710957e+01, 2.8820399800015768e+01},
                                                      {2.5922119028089824e-01, -1.6466772675991814e-01, 2.6724017988451243e-01, -3.8490377804184067e-01, 5.5758559987269396e-01, -8.5461660475530055e-01, 1.4531681475291378e+00, -2.9655938725136815e+00, 8.9720795909774509e+00, 5.1881095045832226e-01, -6.8901673047017482e+01},
                                                      {-9.9999999999989389e-02, 6.3489074494962563e-02, -1.0278178932528789e-01, 1.4729054379694795e-01, -2.1147021062500782e-01, 3.1903624518642260e-01, -5.2645290826362556e-01, 1.0056089751903754e+00, -2.4885984249579423e+00, 1.1039947950526285e+01, 5.0500000000032777e+01}};

/**
 * \brief Evaluate Lagrange polynomial\f$L_k^{n}(\tau)\f$.
 *
 * The polynomial coefficients are
 * given in column major format in the vector pol. This vector should contain
 * coefficients for all Lagrange polynomials as returned by jmi_opt_coll_radau_get_pols.
 * This means that the pol matrix should have dimensions n x n.
 *
 * @param tau \f$\tau\f$, value of independent variable in polynomial evaluation.
 * @param n Order of polynomials.
 * @param pol Vector containing the polynomial coefficients.
 * @param k Specify evaluation of the k:th Lagrange polynomial.
 * @return Value of polynomial.
 *
 */
jmi_real_t jmi_opt_coll_radau_eval_pol(jmi_real_t tau, int n, jmi_real_t* pol, int k);

/* Lagrange polynomial matrices are returned in column major format. */

/**
 * \brief Get Lagrange polynomials of a specified order.
 *
 * @param n_cp Number of collocation points.
 * @param cp (Output) Radu collocation points for polynomials of order n_cp-1.
 * @param w (Output) Radau quadrature weights.
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
int jmi_opt_coll_radau_get_pols(int n_cp, jmi_real_t *cp, jmi_real_t *w,
        jmi_real_t *cpp, jmi_real_t *Lp_coeffs, jmi_real_t *Lpp_coeffs,
        jmi_real_t *Lp_dot_coeffs, jmi_real_t *Lpp_dot_coeffs,
                                  jmi_real_t *Lp_dot_vals, jmi_real_t *Lpp_dot_vals);

#ifdef __cplusplus
}
#endif

#endif
/* @} */
