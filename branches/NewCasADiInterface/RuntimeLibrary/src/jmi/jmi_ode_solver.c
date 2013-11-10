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
#include "jmi_ode_problem.h"
#include "jmi_ode_cvode.h"
#include "jmi_ode_euler.h"
#include "jmi_log.h"


int jmi_new_ode_solver(jmi_ode_problem_t* problem, jmi_ode_method_t method,
                       jmi_real_t step_size, jmi_real_t rel_tol){
    int flag = 0;
    jmi_ode_solver_t* solver = (jmi_ode_solver_t*)calloc(1,sizeof(jmi_ode_solver_t));

    if(!solver) return -1;

    solver->ode_problem = problem;
    solver->step_size = step_size;
    solver->rel_tol = rel_tol;
    problem->ode_solver = solver;

    switch(method) {
    case JMI_ODE_CVODE: {
        jmi_ode_cvode_t* integrator;    
        flag = jmi_ode_cvode_new(&integrator, solver);
        solver->integrator = integrator;
        solver->solve = jmi_ode_cvode_solve;
        solver->delete_solver = jmi_ode_cvode_delete;
    }
        break;
    case JMI_ODE_EULER: {
        jmi_ode_euler_t* integrator;    
        flag = jmi_ode_euler_new(&integrator, solver);
        solver->integrator = integrator;
        solver->solve = jmi_ode_euler_solve;
        solver->delete_solver = jmi_ode_euler_delete;
    }
        break;

    default:
        return -1;
    }

    return flag;
}

void jmi_delete_ode_solver(jmi_ode_problem_t* problem){
    if(problem->ode_solver){
        (problem->ode_solver)->delete_solver(problem->ode_solver);
        free(problem->ode_solver);
    }
}
