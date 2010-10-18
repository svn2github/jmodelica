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

#include "jmi_opt_coll_ipopt.h"
#include "IpIpoptApplication.hpp"
#include "IpSolveStatistics.hpp"
#include "jmi_opt_coll_TNLP.hpp"

//using namespace Ipopt;

struct jmi_opt_coll_ipopt_t{
	jmi_opt_coll_t *jmi_opt_coll;
	Ipopt::SmartPtr<Ipopt::IpoptApplication> ipopt_app;
	Ipopt::SmartPtr<Ipopt::TNLP> tnlp;
	int solved;
	int return_status;
};

int jmi_opt_coll_ipopt_new(jmi_opt_coll_ipopt_t **jmi_opt_coll_ipopt, jmi_opt_coll_t *jmi_opt_coll) {

	jmi_opt_coll_ipopt_t* nlp = (jmi_opt_coll_ipopt_t*)calloc(1,sizeof(jmi_opt_coll_ipopt_t));
	*jmi_opt_coll_ipopt = nlp;

	nlp->jmi_opt_coll = jmi_opt_coll;

	nlp->ipopt_app = new Ipopt::IpoptApplication();
	nlp->ipopt_app->Options()->SetStringValue("hessian_approximation", "limited-memory");
	nlp->tnlp = new jmi_opt_coll_TNLP(jmi_opt_coll);
	nlp->solved = 0;
	nlp->return_status = -1;

	return 0;
}

int jmi_opt_coll_ipopt_solve(jmi_opt_coll_ipopt_t *jmi_opt_coll_ipopt) {
	int i;
	// Copy initial guess into x
	for (i=0;i<jmi_opt_coll_ipopt->jmi_opt_coll->n_x;i++) {
		jmi_opt_coll_ipopt->jmi_opt_coll->x[i] = jmi_opt_coll_ipopt->jmi_opt_coll->x_init[i];
	}

	// Initialize and process options
	if (jmi_opt_coll_ipopt->ipopt_app->Initialize() != Ipopt::Solve_Succeeded) {
		return false;
	}

	Ipopt::ApplicationReturnStatus status;
	status = jmi_opt_coll_ipopt->ipopt_app->OptimizeTNLP(jmi_opt_coll_ipopt->tnlp);
	jmi_opt_coll_ipopt->solved = 1;
	jmi_opt_coll_ipopt->return_status = status;
	return status;

}

int jmi_opt_coll_ipopt_set_string_option(jmi_opt_coll_ipopt_t *jmi_opt_coll_ipopt, char* key, char* val) {
	std::string tag(key);
	if (jmi_opt_coll_ipopt->ipopt_app->Options()->SetStringValue(tag, val)) {
		return 0;
	} else {
		return -1;
	}
}

int jmi_opt_coll_ipopt_set_int_option(jmi_opt_coll_ipopt_t *jmi_opt_coll_ipopt, char* key, int val) {
	std::string tag(key);
	if (jmi_opt_coll_ipopt->ipopt_app->Options()->SetIntegerValue(tag, val)) {
		return 0;
	} else {
		return -1;
	}

}

int jmi_opt_coll_ipopt_set_num_option(jmi_opt_coll_ipopt_t *jmi_opt_coll_ipopt, char* key, double val) {
	std::string tag(key);
	if (jmi_opt_coll_ipopt->ipopt_app->Options()->SetNumericValue(tag, val)) {
		return 0;
	} else {
		return -1;
	}

}

int jmi_opt_coll_ipopt_get_statistics(jmi_opt_coll_ipopt_t* jmi_opt_coll_ipopt,
		int* return_status, int* nbr_iter, jmi_real_t* objective,
		jmi_real_t* total_exec_time) {
	if (jmi_opt_coll_ipopt->solved==1) {
		*return_status = jmi_opt_coll_ipopt->return_status;
		*nbr_iter = jmi_opt_coll_ipopt->ipopt_app->Statistics()->IterationCount();
		*objective = jmi_opt_coll_ipopt->ipopt_app->Statistics()->FinalObjective();
		*total_exec_time = jmi_opt_coll_ipopt->ipopt_app->Statistics()->TotalCPUTime();
		return 0;
	} else {
		return -1;
	}
}

/*
int jmi_opt_coll_ipopt_get_starting_point(jmi_opt_coll_ipopt_t *jmi_opt_coll_ipopt, Index n, int init_x, Number* x,
				      int init_z, Number* z_L, Number* z_U,
				      Index m, int init_lambda,
				      Number* lambda) {

  return jmi_opt_coll_get_initial(x);

}

*/
