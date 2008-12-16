
#include "jmi_opt_sim.h"


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

