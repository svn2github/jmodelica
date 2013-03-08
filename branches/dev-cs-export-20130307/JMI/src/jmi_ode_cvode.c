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

#include <cvode/cvode.h>             /* main integrator header file */
#include <cvode/cvode_dense.h>       /* use CVDENSE linear solver */
#include <nvector/nvector_serial.h>  /* serial N_Vector types, fct. and macros */
#include <sundials/sundials_types.h> /* definition of realtype */
#include <sundials/sundials_math.h>  /* contains the macros ABS, SQR, and EXP*/
#include "jmi_ode_solver.h"
#include "jmi_ode_cvode.h"

int cv_rhs(realtype t, N_Vector yy, N_Vector yydot, void *problem_data){
	realtype *y, *ydot;
	int nbr_y,flag;
	jmi_ode_solver_t *solver = (jmi_ode_solver_t*)problem_data;
	jmi_t* jmi = solver->jmi;

	nbr_y = jmi->n_real_x;
	y = NV_DATA_S(yy); /*y is now a vector of realtype*/
	ydot = NV_DATA_S(yydot); /*ydot is now a vector of realtype*/

	/* Set time */
    *(jmi_get_t(jmi)) = t;
    /* Set states */
	memcpy(jmi_get_real_x(jmi), y, nbr_y*sizeof(realtype));

	/* Calculate the derivative */
    flag = jmi_ode_derivatives(jmi);
    
	if(flag != 0) {
		jmi_log_warning(jmi, "[CVODE] Evaluating the derivatives failed (recoverable error).");
		return 1; /* Recoverable failiure */
	}
	memcpy(ydot, jmi_get_real_dx(jmi), nbr_y*sizeof(realtype));

    return CV_SUCCESS;
}

int cv_root(realtype t, N_Vector yv, realtype *gout,  void* problem_data){
    return CV_SUCCESS;
}

int jmi_ode_cvode_solve(jmi_ode_solver_t* solver, realtype t_stop){
	int flag = 0;
	jmi_ode_cvode_t* integrator = (jmi_ode_cvode_t*)solver->integrator;
	realtype tret,*y;
	

	flag = CVode(integrator->cvode_mem, t_stop, integrator->y_work,&tret,CV_NORMAL);
	if(flag<0){
		jmi_log_error(solver->jmi,"[CVODE] CVode failed to calculate the next step.");
		return -1;
	}

	/* Set time */
    *(jmi_get_t(solver->jmi)) = tret;
    /* Set states */
	y = NV_DATA_S(integrator->y_work);
	memcpy(jmi_get_real_x(solver->jmi), y, (solver->jmi->n_real_x)*sizeof(realtype));

	return flag;
}

int jmi_ode_cvode_new(jmi_ode_cvode_t** integrator_ptr, jmi_ode_solver_t* solver) {
    jmi_ode_cvode_t* integrator;
    jmi_t* jmi = solver->jmi;
	realtype t0;
    int flag = 0;
    
	integrator = (jmi_ode_cvode_t*)calloc(1,sizeof(jmi_ode_cvode_t));
    if(!integrator){
		jmi_log_error(jmi, "[CVODE] Failed to allocate the internal CVODE struct.");
		return -1;
	}

	/* DEFAULT VALUES NEEDS TO BE IMPROVED*/
	integrator->lmm  = CV_BDF;
	integrator->iter = CV_NEWTON;
	integrator->rtol = 1e-4;
	integrator->atol = 1e-6;

    void* cvode_mem = CVodeCreate(integrator->lmm,integrator->iter);
    if(!cvode_mem){
		jmi_log_error(jmi, "[CVODE] Failed to allocate the CVODE struct.");
		return -1;
	}

	/* Get the default values for the time and states */
	t0 = *(jmi_get_t(jmi));
	integrator->y0 = N_VNew_Serial(jmi->n_real_x);
	integrator->y_work = N_VNew_Serial(jmi->n_real_x);
	memcpy(NV_DATA_S(integrator->y_work), jmi_get_real_x(jmi), (jmi->n_real_x)*sizeof(realtype));

	flag = CVodeInit(cvode_mem, cv_rhs, t0, integrator->y0);
    if(flag != 0) {
		jmi_log_error(jmi, "[CVODE] Failed to initialize CVODE.");
        return -1;
    }

	flag = CVodeSStolerances(cvode_mem, integrator->rtol, integrator->atol);
	if(flag!=0){
		jmi_log_error(jmi, "[CVODE] Failed to specify the tolerances to CVODE.");
        return -1;
	}

	flag = CVDense(cvode_mem, jmi->n_real_x);
	if(flag!=0){
		jmi_log_error(jmi, "[CVODE] Failed to specify the linear solver to CVODE.");
		return -1;
	}

	flag = CVodeSetUserData(cvode_mem, (void*)solver);
	if(flag!=0){
		jmi_log_error(jmi, "[CVODE] Failed to specify the user data to CVODE.");
		return -1;
	}

    integrator->cvode_mem = cvode_mem;    
      
    *integrator_ptr = integrator;
    return 0;
}

void jmi_ode_cvode_delete(jmi_ode_solver_t* solver) {
    
    if((jmi_ode_cvode_t*)(solver->integrator)){
		/*Deallocate work vectors.*/
        N_VDestroy_Serial((((jmi_ode_cvode_t*)(solver->integrator))->y_work));
		N_VDestroy_Serial((((jmi_ode_cvode_t*)(solver->integrator))->y0));
        /*Deallocate CVode */
        CVodeFree(&(((jmi_ode_cvode_t*)(solver->integrator))->cvode_mem));        
    }
}