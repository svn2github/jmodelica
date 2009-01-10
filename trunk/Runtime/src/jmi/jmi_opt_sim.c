
#include "jmi_opt_sim.h"


int jmi_opt_sim_get_dimensions(jmi_opt_sim_t *jmi_opt_sim, int *n_x, int *n_g, int *n_h,
		int *dg_n_nz, int *dh_n_nz) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	*n_x = jmi_opt_sim->n_x;
	*n_g = jmi_opt_sim->n_g;
	*n_h = jmi_opt_sim->n_h;
	*dg_n_nz = jmi_opt_sim->dg_n_nz;
	*dh_n_nz = jmi_opt_sim->dh_n_nz;


	return 0;
}


int jmi_opt_sim_get_x(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t **x) {
	*x = jmi_opt_sim->x;
	return 0;
}

int jmi_opt_sim_get_interval_spec(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *start_time, int *start_time_free,
		jmi_real_t *final_time, int *final_time_free) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	*start_time = jmi_opt_sim->jmi->opt->start_time;
	*start_time_free = jmi_opt_sim->jmi->opt->start_time_free;
	*final_time = jmi_opt_sim->jmi->opt->final_time;
	*final_time_free = jmi_opt_sim->jmi->opt->final_time_free;

	return 0;
}

int jmi_opt_sim_get_bounds(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *x_lb, jmi_real_t *x_ub) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_opt_sim->n_x;i++) {
		x_lb[i] = jmi_opt_sim->x_lb[i];
		x_ub[i] = jmi_opt_sim->x_ub[i];
	}
	return 0;
}

int jmi_opt_sim_get_initial(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *x_init) {
	if (jmi_opt_sim->jmi->opt == NULL) {
		return -1;
	}
	int i;
	for (i=0;i<jmi_opt_sim->n_x;i++) {
		x_init[i] = jmi_opt_sim->x_init[i];
	}
	return 0;
}


int jmi_opt_sim_f(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *f) {
	return jmi_opt_sim->f(jmi_opt_sim, f);
}

int jmi_opt_sim_df(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *df) {
	return jmi_opt_sim->df(jmi_opt_sim, df);
}

int jmi_opt_sim_g(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res) {
	return jmi_opt_sim->g(jmi_opt_sim, res);
}

int jmi_opt_sim_dg(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac) {
	return jmi_opt_sim->dg(jmi_opt_sim, jac);
}

int jmi_opt_sim_dg_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *irow, int *icol) {
	return jmi_opt_sim->dg_nz_indices(jmi_opt_sim, irow, icol);
}

int jmi_opt_sim_h(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *res) {
	return jmi_opt_sim->h(jmi_opt_sim, res);
}

int jmi_opt_sim_dh(jmi_opt_sim_t *jmi_opt_sim, jmi_real_t *jac) {
	return jmi_opt_sim->dh(jmi_opt_sim, jac);
}


int jmi_opt_sim_dh_nz_indices(jmi_opt_sim_t *jmi_opt_sim, int *irow, int *icol) {
	return jmi_opt_sim->dh_nz_indices(jmi_opt_sim, irow, icol);

}



