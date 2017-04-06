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

#include "jmi_ode_solver_impl.h"
#include "jmi_ode_problem.h"
#include "jmi_ode_euler.h"
#include "jmi_ode_cvode.h"

jmi_ode_solver_options_t jmi_ode_solver_default_options(void) {
    jmi_ode_solver_options_t options;
    
    options.experimental_mode = jmi_cs_experimental_none;
    options.method = JMI_ODE_CVODE;
    options.cvode_options.rel_tol = 1e-6;
    options.euler_options.step_size = 0.001;
    
    return options;
}

jmi_ode_solver_t* jmi_new_ode_solver(jmi_ode_problem_t* problem, jmi_ode_solver_options_t solver_options) {
    int flag = 0;
    jmi_ode_solver_t* solver;
    
    solver = (jmi_ode_solver_t*)calloc(1, sizeof(jmi_ode_solver_t));
    if(solver == NULL) return NULL;

    solver->states_derivative = calloc(problem->sizes.states, sizeof(jmi_real_t));
    solver->event_indicators_previous = calloc(problem->sizes.root_fnc, sizeof(jmi_real_t));
    solver->event_indicators = calloc(problem->sizes.root_fnc, sizeof(jmi_real_t));
    if (solver->states_derivative           == NULL ||
        solver->event_indicators            == NULL ||
        solver->event_indicators_previous   == NULL)
    {
        jmi_free_ode_solver(solver);
        return NULL;
    }

    solver->ode_problem = problem;
    solver->experimental_mode = solver_options.experimental_mode;
    solver->step_size =solver_options.euler_options.step_size;
    solver->rel_tol = solver_options.cvode_options.rel_tol;
    
    switch(solver_options.method) {
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
        flag = -1;
    }

    if (flag == -1) {
        jmi_free_ode_solver(solver);
        return NULL;
    } else {
        return solver;
    }
}

void jmi_free_ode_solver(jmi_ode_solver_t* solver){
    if(solver){
        if (solver->states_derivative)          free(solver->states_derivative);
        if (solver->event_indicators_previous)  free(solver->event_indicators_previous);
        if (solver->event_indicators)           free(solver->event_indicators);
        if (solver->delete_solver)              solver->delete_solver(solver);
        free(solver);
    }
}

jmi_ode_status_t jmi_ode_solver_solve(jmi_ode_solver_t* solver, jmi_real_t final_time, int initialize) {
    return solver->solve(solver, final_time, initialize);
}
