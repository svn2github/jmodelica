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

#include "jmi_opt_sim_ipopt.h"
#include "IpIpoptApplication.hpp"
#include "jmi_TNLP.hpp"

//using namespace Ipopt;

struct jmi_opt_sim_ipopt_t{
	jmi_opt_sim_t *jmi_opt_sim;
	Ipopt::SmartPtr<Ipopt::IpoptApplication> ipopt_app;
};

int jmi_opt_sim_ipopt_new(jmi_opt_sim_ipopt_t **jmi_opt_sim_ipopt, jmi_opt_sim_t *jmi_opt_sim) {

	jmi_opt_sim_ipopt_t* nlp = (jmi_opt_sim_ipopt_t*)calloc(1,sizeof(jmi_opt_sim_ipopt_t));
	*jmi_opt_sim_ipopt = nlp;

	nlp->jmi_opt_sim = jmi_opt_sim;

	nlp->ipopt_app = new Ipopt::IpoptApplication();
	nlp->ipopt_app->Options()->SetStringValue("hessian_approximation", "limited-memory");

	return 0;
}

int jmi_opt_sim_ipopt_solve(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt) {
	int i;
	// Copy initial guess into x
	for (i=0;i<jmi_opt_sim_ipopt->jmi_opt_sim->n_x;i++) {
		jmi_opt_sim_ipopt->jmi_opt_sim->x[i] = jmi_opt_sim_ipopt->jmi_opt_sim->x_init[i];
	}

	// Initialize and process options
	if (jmi_opt_sim_ipopt->ipopt_app->Initialize() != Ipopt::Solve_Succeeded) {
		return false;
	}

    SmartPtr<TNLP> tnlp;

	tnlp = new jmi_TNLP(jmi_opt_sim_ipopt->jmi_opt_sim);

	Ipopt::ApplicationReturnStatus status;
	status = jmi_opt_sim_ipopt->ipopt_app->OptimizeTNLP(tnlp);

	return status;

}

int jmi_opt_sim_ipopt_set_string_option(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, char* key, char* val) {
	std::string tag(key);
	jmi_opt_sim_ipopt->ipopt_app->Options()->SetStringValue(tag, val);
	return 0;
}

int jmi_opt_sim_ipopt_set_int_option(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, char* key, int val) {
	std::string tag(key);
	jmi_opt_sim_ipopt->ipopt_app->Options()->SetIntegerValue(tag, val);
	return 0;
}

int jmi_opt_sim_ipopt_set_num_option(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, char* key, double val) {
	std::string tag(key);
	jmi_opt_sim_ipopt->ipopt_app->Options()->SetNumericValue(tag, val);
	return 0;
}

/*
int jmi_opt_sim_ipopt_get_starting_point(jmi_opt_sim_ipopt_t *jmi_opt_sim_ipopt, Index n, int init_x, Number* x,
				      int init_z, Number* z_L, Number* z_U,
				      Index m, int init_lambda,
				      Number* lambda) {

  return jmi_opt_sim_get_initial(x);

}

*/
