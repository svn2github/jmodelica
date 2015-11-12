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



/** \file jmi_kinsol_solver.h
 *  \brief Interface to the KINSOL solver.
 */

#ifndef _JMI_KINSOL_SOLVER_H
#define _JMI_KINSOL_SOLVER_H

#include "jmi_block_solver.h"
#include "jmi_brent_solver.h"

/*
 *  TODO: Error codes...
 *  Introduce #defines to denote different error codes
 */
#include <nvector/nvector_serial.h>

#include <sundials/sundials_dense.h>

#include <kinsol/kinsol.h>

#define JMI_REGULARIZATION 1
#define JMI_MINIMUM_NORM 2

typedef struct jmi_kinsol_solver_t jmi_kinsol_solver_t;
typedef struct jmi_kinsol_solver_reset_t jmi_kinsol_solver_reset_t;

/**< \brief Kinsol solver constructor function */
int jmi_kinsol_solver_new(jmi_kinsol_solver_t** solver, jmi_block_solver_t* block_solver);

/**< \brief Kinsol solver main solve function */
int jmi_kinsol_solver_solve(jmi_block_solver_t* block_solver);

/**< \brief Kinsol solver destructor */
void jmi_kinsol_solver_delete(jmi_block_solver_t* block_solver);

int jmi_kinsol_completed_integrator_step(jmi_block_solver_t* block_solver);
int jmi_kinsol_restore_state(jmi_block_solver_t* block);

/**< \brief Retrieve residual scales used in Kinsol solver */
double* jmi_kinsol_solver_get_f_scales(jmi_kinsol_solver_t* solver);

/**< \brief Convert Kinsol return flag to readable name */
const char *jmi_kinsol_flag_to_name(int flag);

struct jmi_kinsol_solver_reset_t {
    DlsMat J;
    int * lapack_ipiv;
    N_Vector kin_y_scale;
    N_Vector kin_f_scale;
    int J_is_singular_flag;
    int handling_of_singular_jacobian_flag;
    int mbset;
};

struct jmi_kinsol_solver_t {
    jmi_brent_solver_t externalBrent; /**< Brent solver when run stand-alone. Temporary solution until supported by options. */
    jmi_kinsol_solver_reset_t *saved_state;

    void* kin_mem;                 /**< \brief A pointer to the Kinsol solver */
    N_Vector kin_y;                /**< \brief Work vector for Kinsol y */
    N_Vector last_residual;        /**< \brief Last residual vector submitted to linear solver */

    N_Vector kin_y_scale;          /**< \brief Work vector for Kinsol scaling of y */
    N_Vector kin_f_scale;          /**< \brief Work vector for Kinsol scaling of f */
    N_Vector gradient;              /**< \brief Steepest descent direction */
    realtype* residual_nominal;      /**< \brief Vector for reading in manual scaling factors for f  */
    realtype* residual_heuristic_nominal; /**< \brief Vector for reading in heuristic scaling factors for f  */
    realtype kin_scale_update_time; /**< \brief The last time when Kinsol scale was updated */
    realtype kin_jac_update_time; /**< \brief The last time when Jacobian was updated */
    realtype kin_ftol;             /**< \brief Tolerance for F */
    realtype kin_stol;             /**< \brief Tolerance for Step-size */
    realtype kin_reg_tol;          /**< \brief Regularization tolerance */
    
    DlsMat J;                       /**< \brief The Jacobian matrix  */    
    DlsMat JTJ;                     /**< \brief The Transpose(J).J used if J is singular */
    int J_is_singular_flag;         /**< \brief A flag indicating that J is singular. Regularized JTJ is setup */
    int use_steepest_descent_flag;  /**< \brief A flag indicating that steepest descent and not Newton direction should be used */
    int force_new_J_flag;           /**< \brief A flag indicating that J needs to be recalculated */
    int using_max_min_scaling_flag; /**< \brief A flag indicating if either the maximum scaling is used of the minimum */
    int updated_jacobian_flag;      /**< \brief A flag indicating if an updated Jacobian is used to solve the system */
    int handling_of_singular_jacobian_flag; /**< \brief A flag for determining how singular systems should be treated */
    DlsMat J_LU;                    /**< \brief Jacobian matrix/it's LU decomposition */
    DlsMat J_scale;                 /**< \brief Jacobian matrix scaled with xnorm for used for fnorm calculation */
    DlsMat J_sing;                  /**< \brief Jacobian matrix/it's right singular vectors */
    DlsMat J_SVD_U;                 /**< \brief The left singular vectors */
    DlsMat J_SVD_VT;                /**< \brief The right singular vectors */

    char equed;                     /**< \brief Type of Jac scaling used */
    realtype* rScale;               /**< \brief Row scale factors */
    realtype* cScale;               /**< \brief Column scale factors */
    
    N_Vector work_vector;           /**< \brief work vector for vector operations */
    realtype* lapack_work;         /**< \brief work vector for lapack */
    int * lapack_iwork;            /**< \brief work vector for lapack */
    int * lapack_ipiv;            /**< \brief work vector for lapack */
    
    realtype* dgesdd_work;          /**< \brief Work vector for desdd */
    int dgesdd_lwork;               /**< \brief Work vector for desdd */
    int* dgesdd_iwork;              /**< \brief Work vector for desdd */
    
    realtype* dgelss_rwork;
    realtype* singular_values;
    
    int num_bounds;
    int range_most_limiting;       /**< \bried Flag indicating if the Newton step length is most limited by range */
    int* bound_vindex;             /**< \brief variable index for a bound */
    int* bound_kind;               /**< \brief +1 for max, -1 for min */    
    int* bound_limiting;           /**< \brief 1 if bound is limitng stepsize, 0 otherwise*/    
    realtype* bounds;              /**< \brief bound vals */
    realtype* active_bounds;
    realtype max_nw_step;           /**< \brief maximal newton step calculated from nominals */
    realtype* range_limits;         /**< \brief step limits on the different IVs */
    int* range_limited;             /**< \brief flags indicating if step in specific IV is limiting */
    
    realtype y_pos_min_1d;
    realtype f_pos_min_1d;
    realtype y_neg_max_1d;
    realtype f_neg_max_1d;

    realtype last_xnorm;           /**< \brief Last norm of Newton step before limiting */
    realtype last_fnorm;            /**< \brief Last fnorm before step is taken */
    realtype last_max_residual;     /**< \brief Last max residual before step is taken */
    int last_max_residual_index;    /**< \brief Last max residual index before step is taken */

    realtype sJpnorm;               /**< \brief Scalar product of J*p norm */
    int last_bounding_index;       /**< \brief Index of the variable that most limited Newton step, or -1 if none */
    int last_num_limiting_bounds;  /**< \brief Number of limiting bounds at last jmi_kinsol_limit_step */
    int last_num_active_bounds;    /**< \brief Number of active bounds at last jmi_kinsol_limit_step */
    double lambda, lambda_max;     /**< \brief lambda and lambda_max for logging */
    int iterationProgressFlag;     /**< \brief Flag indicating that KINStop was called and so there was some progress */

    realtype max_step_ratio;        /**< \brief Max ratio of the Newton step */

#define JMI_KINSOL_SOLVER_MAX_CHAR_LOG_LENGTH 8
    int char_log_length;                                     /** Number of chars in char_log */
    char char_log[JMI_KINSOL_SOLVER_MAX_CHAR_LOG_LENGTH+1];  /** Short log like "Js". Null-terminated. */
};


/* Utilized Lapack routines */
extern void dgetrf_(int* M, int* N, double* A, int* LDA, int* IPIV, int* INFO );
extern void dgetrs_(char* TRANS, int* N, int* NRHS, double* A, int* LDA, int* IPIV, double* B, int* LDB, int* INFO);
extern void dgelss_(int* M, int* N, int* NRHS, double* A, int* LDA, double* B, int* LDB,double* S,double* RCOND,int* RANK,double* WORK,int* LWORK, int* INFO);
extern void dgecon_(char *norm, int *n, double *a, int *lda, double *anorm, double *rcond, 
             double *work, int *iwork, int *info);
extern void dgesdd_(char* JOBZ, int* M, int* N, double* A, int* LDA, 
            double* S, double* U, int* LDU, double* VT, int* LDVT, 
            double* WORK, int* LWORK, int* IWORK, int* INFO);
extern double dlamch_(char *cmach);

extern double dlange_(char *norm, int *m, int *n, double *a, int *lda,
             double *work);
extern int dgeequ_(int *m, int *n, double *a, int *
    lda, double *r__, double *c__, double *rowcnd, double 
    *colcnd, double *amax, int *info);

extern int dlaqge_(int *m, int *n, double *a, int *
    lda, double *r__, double *c__, double *rowcnd, double 
    *colcnd, double *amax, char *equed);

#endif /* _JMI_KINSOL_SOLVER_H */
