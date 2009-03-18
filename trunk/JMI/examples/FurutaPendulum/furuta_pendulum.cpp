/*
    Copyright (C) 2009 Modelon AB

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

/*
 * Model of a Furuta pendulum:
 *
 *
 * \frac{d}{dt}\theta =& \dot\theta\\
 * \frac{d}{dt}\dot \theta =&
 * \frac{1}{\alpha\beta-\gamma^2+(\beta^2+\gamma^2)\sin^2\theta}
 * \left[2\beta\gamma\sin\theta\cos^2\theta\dot\theta\dot\varphi-
 * \gamma^2\sin\theta\cos\theta\dot\theta^2+\right.\\
 * &\left.+\beta(\alpha+\beta\sin^2\theta)\sin\theta\cos\theta\dot\varphi^2+
 * \delta(\alpha+\beta\sin^2\theta)\sin\theta-
 * \gamma\cos\theta\tau_\varphi \right]\\
 * \frac{d}{dt}\varphi =& \dot\varphi\\
 * \frac{d}{dt}\dot \varphi =&
 * \frac{1}{\alpha\beta-\gamma^2+(\beta^2+\gamma^2)\sin^2\theta}
 * \left[-2\beta^2\sin\theta\cos\theta\dot\theta\dot\varphi+
 * \beta\gamma\sin\theta\dot\theta^2-\right.\\
 * &-\left.\beta\gamma\sin\theta\cos^2\theta\dot\varphi^2-
 * \delta\gamma\sin\theta\cos\theta+\beta\tau_\varphi\right]
 *
 * The states are selected as:
 *
 * x(0) = \theta (Pendulum angle)
 * x(1) = \dot \theta
 * x(2) = \varphi (Arm angle)
 * x(3) = \dot \varphi
 *
 * The input
 *
 * u(0) = \tau (Motor torque)
 *
 * The parameters are
 *
 * pi(0) = \alpha = 0.00354
 * pi(1) = \beta = 0.00384
 * pi(2) = \gamma = 0.00258
 * pi(3) = \delta = 0.103
 * pi(4) = \theta_0
 * pi(5) = \dot\theta_0
 * pi(6) = \varphi_0
 * pi(7) = \dot\varphi_0
 *
 *
 */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <jmi.h>


static const int N_ci = 0;
static const int N_cd = 0;
static const int N_pi = 8;
static const int N_pd = 0;
static const int N_dx = 4;
static const int N_x = 4;
static const int N_u = 1;
static const int N_w = 0;
static const int N_eq_F = 4;

static const int N_eq_F0 = 8;
static const int N_eq_F1 = 0;

static const int N_eq_Ceq = 0;
static const int N_eq_Cineq = 0;
static const int N_eq_Heq = 0;
static const int N_eq_Hineq = 0;

static const int N_t_p = 0;

#define _ci(i) ((*(jmi->z))[jmi->offs_ci+i])
#define _cd(i) ((*(jmi->z))[jmi->offs_cd+i])
#define _pi(i) ((*(jmi->z))[jmi->offs_pi+i])
#define _pd(i) ((*(jmi->z))[jmi->offs_pd+i])
#define _dx(i) ((*(jmi->z))[jmi->offs_dx+i])
#define _x(i) ((*(jmi->z))[jmi->offs_x+i])
#define _u(i) ((*(jmi->z))[jmi->offs_u+i])
#define _w(i) ((*(jmi->z))[jmi->offs_w+i])
#define _t ((*(jmi->z))[jmi->offs_t])
#define _dx_p(j,i) ((*(jmi->z))[jmi->offs_dx_p + \
  j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w)+ i])
#define _x_p(j,i) ((*(jmi->z))[jmi->offs_x_p + \
  j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])
#define _u_p(j,i) ((*(jmi->z))[jmi->offs_u_p + \
  j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])
#define _w_p(j,i) ((*(jmi->z))[jmi->offs_w_p + \
  j*(jmi->n_dx + jmi->n_x + jmi->n_u + jmi->n_w) + i])

/*
 * The res argument is of type pointer to a vector. This means that
 * in the case of no AD, the type of res is double**. This is
 * necessary in order to accommodate the AD case, in which case
 * the type of res is vector< CppAD::AD<double> >. In C++, it would
 * be ok to pass such an object by reference, using the & operator:
 * 'vector< CppAD::AD<double> > &res'. However, since we would like
 * to be able to compile the code both with a C and a C++ compiler
 * this solution does not work. Probably not too bad, since we can use
 * macros.
 */
static int vdp_dae_F(jmi_t* jmi, jmi_ad_var_vec_p res) {

	(*res)[0] = _x(1) - _dx(0);

	(*res)[1] =
	1/(_pi(0)*_pi(1)-_pi(2)*_pi(2)+(_pi(1)*_pi(1)+_pi(2)*_pi(2))*
			sin(_x(0))*sin(_x(0)))*
	(2*_pi(1)*_pi(2)*sin(_x(0))*cos(_x(0))*cos(_x(0))*_x(1)*_x(3)-
	_pi(2)*_pi(2)*sin(_x(0))*cos(_x(0))*_x(1)*_x(1)+
	_pi(1)*(_pi(0)+_pi(1)*sin(_x(0))*sin(_x(0)))*sin(_x(0))*cos(_x(0))*_x(3)*_x(3)+
	_pi(3)*(_pi(0)+_pi(1)*sin(_x(0))*sin(_x(0)))*sin(_x(0))-
	_pi(2)*cos(_x(0))*_u(0)*_x(2)) - _dx(1);


	(*res)[2] = _x(3) - _dx(2);

	(*res)[3] =
    1/(_pi(0)*_pi(1)-_pi(2)*_pi(2)+(_pi(1)*_pi(1)+_pi(2)*_pi(2))*sin(_x(0))*sin(_x(0)))*
	(-2*_pi(1)*_pi(1)*sin(_x(0))*cos(_x(0))*_x(1)*_x(3)+
	_pi(1)*_pi(2)*sin(_x(0))*_x(1)*_x(1)-
	_pi(1)*_pi(2)*sin(_x(0))*cos(_x(0))*cos(_x(0))*_x(3)*_x(3)-
	_pi(3)*_pi(2)*sin(_x(0))*cos(_x(0))+_pi(1)*_u(0)*_x(2)) - _dx(3);

	return 0;

}

static int vdp_init_F0(jmi_t* jmi, jmi_ad_var_vec_p res) {
	(*res)[0] = _x(1) - _dx(0);

	(*res)[1] =
	1/(_pi(0)*_pi(1)-_pi(2)*_pi(2)+(_pi(1)*_pi(1)+_pi(2)*_pi(2))*
			sin(_x(0))*sin(_x(0)))*
	(2*_pi(1)*_pi(2)*sin(_x(0))*cos(_x(0))*cos(_x(0))*_x(1)*_x(3)-
	_pi(2)*_pi(2)*sin(_x(0))*cos(_x(0))*_x(1)*_x(1)+
	_pi(1)*(_pi(0)+_pi(1)*sin(_x(0))*sin(_x(0)))*sin(_x(0))*cos(_x(0))*_x(3)*_x(3)+
	_pi(3)*(_pi(0)+_pi(1)*sin(_x(0))*sin(_x(0)))*sin(_x(0))-
	_pi(2)*cos(_x(0))*_u(0)*_x(2)) - _dx(1);


	(*res)[2] = _x(3) - _dx(2);

	(*res)[3] =
    1/(_pi(0)*_pi(1)-_pi(2)*_pi(2)+(_pi(1)*_pi(1)+_pi(2)*_pi(2))*sin(_x(0))*sin(_x(0)))*
	(-2*_pi(1)*_pi(1)*sin(_x(0))*cos(_x(0))*_x(1)*_x(3)+
	_pi(1)*_pi(2)*sin(_x(0))*_x(1)*_x(1)-
	_pi(1)*_pi(2)*sin(_x(0))*cos(_x(0))*cos(_x(0))*_x(3)*_x(3)-
	_pi(3)*_pi(2)*sin(_x(0))*cos(_x(0))+_pi(1)*_u(0)*_x(2)) - _dx(3);

	(*res)[4] = _pi(4);

	(*res)[5] = _pi(5);

	(*res)[6] = _pi(6);

	(*res)[7] = _pi(7);

}

static int vdp_init_F1(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int vdp_opt_J(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int vdp_opt_Ceq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int vdp_opt_Cineq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int vdp_opt_Heq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

static int vdp_opt_Hineq(jmi_t* jmi, jmi_ad_var_vec_p res) {
	return -1;
}

int jmi_new(jmi_t** jmi) {

	jmi_init(jmi, N_ci, N_cd, N_pi, N_pd, N_dx,
			      N_x, N_u, N_w, N_t_p);

	// Initialize the DAE interface
	jmi_dae_init(*jmi, *vdp_dae_F, N_eq_F, NULL, 0, NULL, NULL);

	// Initialize the Init interface
	jmi_init_init(*jmi, *vdp_init_F0, N_eq_F0, NULL,
			0, NULL, NULL, *vdp_init_F1, N_eq_F1, NULL,
			            0, NULL, NULL);
	// Initialize the Opt interface
	jmi_opt_init(*jmi, *vdp_opt_J, NULL, 0, NULL, NULL,
	           *vdp_opt_Ceq, N_eq_Ceq, NULL, 0, NULL, NULL,
	           *vdp_opt_Cineq, N_eq_Cineq, NULL, 0, NULL, NULL,
	           *vdp_opt_Heq, N_eq_Heq, NULL, 0, NULL, NULL,
	           *vdp_opt_Hineq, N_eq_Hineq, NULL, 0, NULL, NULL);

	return 0;
}
