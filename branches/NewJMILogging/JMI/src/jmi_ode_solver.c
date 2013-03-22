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

#include "jmi_ode_solver.h"
#include "jmi_ode_cvode.h"
#include "jmi_ode_euler.h"


int jmi_new_ode_solver(jmi_t* jmi, jmi_ode_solvers_t solver, jmi_ode_rhs_func_t rhs_fcn, jmi_ode_root_func_t root_fcn){
	int flag = 0;
	jmi_ode_solver_t* b = (jmi_ode_solver_t*)calloc(1,sizeof(jmi_ode_solver_t));

    if(!b) return -1;

	b->jmi = jmi;
	jmi->ode_solver = b;

    switch(solver) {
    case JMI_ODE_CVODE: {
        jmi_ode_cvode_t* integrator;    
        flag = jmi_ode_cvode_new(&integrator, b);
        b->integrator = integrator;
        b->solve = jmi_ode_cvode_solve;
        b->delete_solver = jmi_ode_cvode_delete;
        b->rhs_fcn = rhs_fcn;
        b->root_fcn = root_fcn;
    }
        break;
    case JMI_ODE_EULER: {
        jmi_ode_euler_t* integrator;    
        flag = jmi_ode_euler_new(&integrator, b);
        b->integrator = integrator;
        b->solve = jmi_ode_euler_solve;
        b->delete_solver = jmi_ode_euler_delete;
        b->rhs_fcn = rhs_fcn;
        b->root_fcn = root_fcn;
    }
        break;

    default:
        return -1;
    }

	return flag;
}

void jmi_delete_ode_solver(jmi_t* jmi){
	if(jmi->ode_solver){
		(jmi->ode_solver)->delete_solver(jmi->ode_solver);
		free(jmi->ode_solver);
	}
}
