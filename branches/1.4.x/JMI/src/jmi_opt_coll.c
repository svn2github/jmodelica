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


#include "jmi_opt_coll.h"


int jmi_opt_coll_get_dimensions(jmi_opt_coll_t *jmi_opt_coll, int *n_x, int *n_g, int *n_h,
		int *dg_n_nz, int *dh_n_nz) {
	if (jmi_opt_coll->jmi->opt == NULL) {
		return -1;
	}
	*n_x = jmi_opt_coll->n_x;
	*n_g = jmi_opt_coll->n_g;
	*n_h = jmi_opt_coll->n_h;
	*dg_n_nz = jmi_opt_coll->dg_n_nz;
	*dh_n_nz = jmi_opt_coll->dh_n_nz;


	return 0;
}

int jmi_opt_coll_get_n_e(jmi_opt_coll_t *jmi_opt_coll,int *n_e) {
	if (jmi_opt_coll->jmi->opt == NULL) {
		return -1;
	}
	*n_e = jmi_opt_coll->n_e;
	return 0;
}


jmi_real_t* jmi_opt_coll_get_x(jmi_opt_coll_t *jmi_opt_coll) {
	return jmi_opt_coll->x;
}

int jmi_opt_coll_get_interval_spec(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *start_time, int *start_time_free,
		jmi_real_t *final_time, int *final_time_free) {
	if (jmi_opt_coll->jmi->opt == NULL) {
		return -1;
	}
	*start_time = jmi_opt_coll->jmi->opt->start_time;
	*start_time_free = jmi_opt_coll->jmi->opt->start_time_free;
	*final_time = jmi_opt_coll->jmi->opt->final_time;
	*final_time_free = jmi_opt_coll->jmi->opt->final_time_free;

	return 0;
}

int jmi_opt_coll_get_bounds(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *x_lb, jmi_real_t *x_ub) {
	if (jmi_opt_coll->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_opt_coll->n_x;i++) {
		x_lb[i] = jmi_opt_coll->x_lb[i];
		x_ub[i] = jmi_opt_coll->x_ub[i];
	}
	return 0;
}

int jmi_opt_coll_set_bounds(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *x_lb, jmi_real_t *x_ub) {
	if (jmi_opt_coll->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_opt_coll->n_x;i++) {
		jmi_opt_coll->x_lb[i] = x_lb[i];
		jmi_opt_coll->x_ub[i] = x_ub[i];
	}
	return 0;
}

int jmi_opt_coll_get_initial(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *x_init) {
	if (jmi_opt_coll->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_opt_coll->n_x;i++) {
		x_init[i] = jmi_opt_coll->x_init[i];
	}
	return 0;
}

int jmi_opt_coll_set_initial(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *x_init) {
	if (jmi_opt_coll->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_opt_coll->n_x;i++) {
		jmi_opt_coll->x_init[i] = x_init[i];
	}
	return 0;
}

int jmi_opt_coll_get_blocking_factors(jmi_opt_coll_t *jmi_opt_coll, int *blocking_factors) {
	int i;
	for (i=0;i<jmi_opt_coll->n_blocking_factors;i++) {
		blocking_factors[i] = jmi_opt_coll->blocking_factors[i];
	}
	return 0;
}

int jmi_opt_coll_get_n_blocking_factors(jmi_opt_coll_t *jmi_opt_coll, int *n_blocking_factors) {
	*n_blocking_factors = jmi_opt_coll->n_blocking_factors;
	return 0;
}

int jmi_opt_coll_set_initial_from_trajectory(
		jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *p_opt_init, jmi_real_t *trajectory_data_init,
		int traj_n_points, jmi_real_t *hs_init, jmi_real_t start_time_init,
		jmi_real_t final_time_init) {
	return jmi_opt_coll->set_initial_from_trajectory(jmi_opt_coll,
							p_opt_init,trajectory_data_init,traj_n_points,
							hs_init,start_time_init,
							final_time_init);
}

int jmi_opt_coll_f(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *f) {
	return jmi_opt_coll->f(jmi_opt_coll, f);
}

int jmi_opt_coll_df(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *df) {
	return jmi_opt_coll->df(jmi_opt_coll, df);
}

int jmi_opt_coll_g(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *res) {
	return jmi_opt_coll->g(jmi_opt_coll, res);
}

int jmi_opt_coll_dg(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *jac) {
	return jmi_opt_coll->dg(jmi_opt_coll, jac);
}

int jmi_opt_coll_dg_nz_indices(jmi_opt_coll_t *jmi_opt_coll, int *irow, int *icol) {
	return jmi_opt_coll->dg_nz_indices(jmi_opt_coll, irow, icol);
}

int jmi_opt_coll_h(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *res) {
	return jmi_opt_coll->h(jmi_opt_coll, res);
}

int jmi_opt_coll_dh(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *jac) {
	return jmi_opt_coll->dh(jmi_opt_coll, jac);
}


int jmi_opt_coll_dh_nz_indices(jmi_opt_coll_t *jmi_opt_coll, int *irow, int *icol) {
	return jmi_opt_coll->dh_nz_indices(jmi_opt_coll, irow, icol);

}

int jmi_opt_coll_write_file_matlab(jmi_opt_coll_t *jmi_opt_coll, const char *file_name) {
	return jmi_opt_coll->write_file_matlab(jmi_opt_coll, file_name);
}

int jmi_opt_coll_get_result_variable_vector_length(jmi_opt_coll_t
		*jmi_opt_coll, int *n) {
	return jmi_opt_coll->get_result_variable_vector_length(jmi_opt_coll, n);
}

int jmi_opt_coll_get_result(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w) {
	return jmi_opt_coll->get_result(jmi_opt_coll, p_opt, t, dx, x, u, w);
}

int jmi_opt_coll_get_result_mesh_interpolation(jmi_opt_coll_t *jmi_opt_coll,
		jmi_real_t *mesh, int n_mesh, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w) {
	return jmi_opt_coll->get_result_mesh_interpolation(jmi_opt_coll,
			mesh, n_mesh, p_opt, t, dx, x, u, w);
}

int jmi_opt_coll_get_result_element_interpolation(jmi_opt_coll_t *jmi_opt_coll,
		int n_interpolation_points, jmi_real_t *p_opt,
		jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
		jmi_real_t *w) {
	return jmi_opt_coll->get_result_element_interpolation(jmi_opt_coll,
			n_interpolation_points, p_opt, t, dx, x, u, w);
}



