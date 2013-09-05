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
#include "jmi_opt_coll_radau.h"

/* The following functions are used to conveniently access variables in the
 * optimization vector.
 */

static jmi_real_t p_opt(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return jmi_opt_coll->x[nlp->offs_p_opt + i];
}
static jmi_real_t dx_0(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return jmi_opt_coll->x[nlp->offs_dx_0 + i];
}
static jmi_real_t x_0(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return jmi_opt_coll->x[nlp->offs_x_0 + i];
}
static jmi_real_t u_0(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return jmi_opt_coll->x[nlp->offs_u_0 + i];
}
static jmi_real_t w_0(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return jmi_opt_coll->x[nlp->offs_w_0 + i];
}

/* i is element, j is collocation point, k is variable index */
static jmi_real_t dx_coll(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return ((jmi_opt_coll->n_blocking_factors>0)?
            (jmi_opt_coll->x[nlp->offs_dx_coll + ((jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*nlp->n_cp + jmi->n_real_u)*i +
                            (j>1? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w) +
                            (j>2? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*(j-2) + k]) :
            (jmi_opt_coll->x[nlp->offs_dx_coll + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*(nlp->n_cp*i + j-1) + k]));
}
/* i is element, j is collocation point, k is variable index */
static jmi_real_t x_coll(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    /*printf("* %d %d *\n",i,j); */
    if (i==0 && j==0) {
        return jmi_opt_coll->x[nlp->offs_x_0 + k];
    } else if (i>0 && j==0) {
        return jmi_opt_coll->x[nlp->offs_x_el_junc + jmi->n_real_x*(i-1) + k];
    } else {
        return ((jmi_opt_coll->n_blocking_factors>0)?
                (jmi_opt_coll->x[nlp->offs_x_coll + ((jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*nlp->n_cp + jmi->n_real_u)*i +
                                (j>1? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w) +
                                (j>2? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*(j-2) + k]) :
                (jmi_opt_coll->x[nlp->offs_x_coll + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*(nlp->n_cp*i + j - 1) + k]));
    }
}
/* i is element, j is collocation point, k is variable index */
static jmi_real_t u_coll(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return ((jmi_opt_coll->n_blocking_factors>0)?
            (jmi_opt_coll->x[nlp->offs_u_coll + ((jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*nlp->n_cp + jmi->n_real_u)*i + k]) :
            (jmi_opt_coll->x[nlp->offs_u_coll + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*(nlp->n_cp*i + j - 1) + k]));
}
/* i is element, j is collocation point, k is variable index */
static jmi_real_t w_coll(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return ((jmi_opt_coll->n_blocking_factors>0)?
            (jmi_opt_coll->x[nlp->offs_w_coll + ((jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*nlp->n_cp + jmi->n_real_u)*i +
                            (j>1? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x /*+ jmi->n_real_u */+ jmi->n_real_w) +
                            (j>2? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*(j-2) + k]) :
            (jmi_opt_coll->x[nlp->offs_w_coll + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*(nlp->n_cp*i + j - 1) + k]));
}

/* i is time point, j is variable index */
static jmi_real_t dx_p(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi_opt_coll->x[nlp->offs_dx_p + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j];
}
/* i is time point, j is variable index */
static jmi_real_t x_p(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi_opt_coll->x[nlp->offs_x_p + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j];
}
/* i is time point, j is variable index */
static jmi_real_t u_p(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi_opt_coll->x[nlp->offs_u_p + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j];
}
/* i is time point, j is variable index */
static jmi_real_t w_p(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi_opt_coll->x[nlp->offs_w_p + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j];
}

static int offs_p_opt(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return nlp->offs_p_opt + i;
}
static int offs_dx_0(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return nlp->offs_dx_0 + i;
}
static int offs_x_0(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return nlp->offs_x_0 + i;
}
static int offs_u_0(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return nlp->offs_u_0 + i;
}
static int offs_w_0(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    return nlp->offs_w_0 + i;
}

/* i is element, j is collocation point, k is variable index */
static int offs_dx_coll(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return ((jmi_opt_coll->n_blocking_factors>0)?
            (nlp->offs_dx_coll + ((jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*nlp->n_cp + jmi->n_real_u)*i +
                            (j>1? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w) +
                            (j>2? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*(j-2) + k) :
            (nlp->offs_dx_coll + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*(nlp->n_cp*i + j-1) + k));
}

/* i is element, j is collocation point, k is variable index */
static int offs_x_coll(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    /*printf("* %d %d *\n",i,j); */
    if (i==0 && j==0) {
        return nlp->offs_x_0 + k;
    } else if (i>0 && j==0) {
        return nlp->offs_x_el_junc + jmi->n_real_x*(i-1) + k;
    } else {
        return ((jmi_opt_coll->n_blocking_factors>0)?
                (nlp->offs_x_coll + ((jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*nlp->n_cp + jmi->n_real_u)*i +
                                (j>1? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w) +
                                (j>2? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*(j-2) + k) :
                (nlp->offs_x_coll + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*(nlp->n_cp*i + j - 1) + k));
    }
}

/* i is element, j is collocation point, k is variable index */
static int offs_u_coll(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return ((jmi_opt_coll->n_blocking_factors>0)?
            (nlp->offs_u_coll + ((jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*nlp->n_cp + jmi->n_real_u)*i + k) :
            (nlp->offs_u_coll + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*(nlp->n_cp*i + j - 1) + k));
}
/* i is element, j is collocation point, k is variable index */
static int offs_w_coll(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return ((jmi_opt_coll->n_blocking_factors>0)?
            (nlp->offs_w_coll + ((jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*nlp->n_cp + jmi->n_real_u)*i +
                            (j>1? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x /*+ jmi->n_real_u */+ jmi->n_real_w) +
                            (j>2? 1 : 0)*(jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*(j-2) + k) :
            (nlp->offs_w_coll + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*(nlp->n_cp*i + j - 1) + k));
}

/* i is time point, j is variable index */
static int offs_dx_p(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return nlp->offs_dx_p + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j;
}
/* i is time point, j is variable index */
static int offs_x_p(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return nlp->offs_x_p + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j;
}
/* i is time point, j is variable index */
static int offs_u_p(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return nlp->offs_u_p + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j;
}
/* i is time point, j is variable index */
static int offs_w_p(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return nlp->offs_w_p + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j;
}

/* i equation index */
static int dh_ffdp_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i) {
    return i;
}

/* i equation index */
static int dh_init_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + i;
}

/* i element j collocation point k equation index */
static int dh_res_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(i*nlp->n_cp + j-1) + k;
}

/* i element j equation index */
static int dh_cont_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*i + j;
}

/* Interpolation equations for u_0 i equation index */
static int dh_u0_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + i;

}

/* i element j collocation point k equation index */
static int dh_coll_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + jmi->n_real_u + jmi->n_real_x*(nlp->n_cp*i + j-1) + k;

}

/* i interpolation point j equation index */
static int dh_dx_p_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + jmi->n_real_x*nlp->n_cp*jmi_opt_coll->n_e +
    jmi->n_real_u +
    (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j;
}

/* i interpolation point j equation index */
static int dh_x_p_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + jmi->n_real_x*nlp->n_cp*jmi_opt_coll->n_e +
    jmi->n_real_u +
    jmi->n_real_dx + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j;
}

/* i interpolation point j equation index */
static int dh_u_p_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + jmi->n_real_x*nlp->n_cp*jmi_opt_coll->n_e +
    jmi->n_real_u +
    jmi->n_real_dx + jmi->n_real_x + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j;
}

/* i interpolation point j equation index */
static int dh_w_p_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + jmi->n_real_x*nlp->n_cp*jmi_opt_coll->n_e +
    jmi->n_real_u +
    jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*i + j;
}

/* Constraint Ceq, element i, collocation point j, constraint k */
static int dh_Ceq_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i, int j, int k) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + jmi->n_real_x*nlp->n_cp*jmi_opt_coll->n_e +
    jmi->n_real_u +
     (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*jmi->n_tp +
    jmi->opt->Ceq->n_eq_F*(nlp->n_cp*i + (j - 1) + 1) + k;
}

/* Constraint Heq, constraint i */
static int dh_Heq_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + jmi->n_real_x*nlp->n_cp*jmi_opt_coll->n_e +
    jmi->n_real_u +
    (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*jmi->n_tp +
    jmi->opt->Ceq->n_eq_F*(nlp->n_cp*jmi_opt_coll->n_e + 1) + i;
}

/* Constraint for blocking factors, constraint i */
static int dh_blocking_eq_offs(jmi_opt_coll_t *jmi_opt_coll, int i) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    return jmi->opt->Ffdp->n_eq_F + jmi->init->F0->n_eq_F + jmi->dae->F->n_eq_F*(jmi_opt_coll->n_e*nlp->n_cp) +
    jmi->n_real_x*jmi_opt_coll->n_e + jmi->n_real_x*nlp->n_cp*jmi_opt_coll->n_e +
    jmi->n_real_u +
    (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*jmi->n_tp +
    jmi->opt->Ceq->n_eq_F*(nlp->n_cp*jmi_opt_coll->n_e + 1) + jmi->opt->Heq->n_eq_F + i;
}


/* Forward declarations */
static void print_problem_stats(jmi_opt_coll_t *jmi_opt_coll);

static void print_lp_pols(jmi_opt_coll_t *jmi_opt_coll);

/* Copy optimization parameters */
static void lp_radau_copy_p(jmi_opt_coll_t *jmi_opt_coll) {
    /*jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll; */
    jmi_t *jmi = jmi_opt_coll->jmi;
    int i;

    jmi_real_t *pi = jmi_get_real_pi(jmi);

    for (i=0;i<jmi->opt->n_p_opt;i++) {
        pi[jmi->opt->p_opt_indices[i]] = jmi_opt_coll->x[i];
    }
}

/* Copy variables, i denotes element and j denotes collocation point */
static void lp_radau_copy_v(jmi_opt_coll_t *jmi_opt_coll, int i, int j) {

    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;

    int k;
    jmi_real_t *v;

    v = jmi_get_real_dx(jmi);
    for(k=0;k<jmi->n_real_dx;k++) {
        v[k] = dx_coll(jmi_opt_coll, i, j, k);
    }

    v = jmi_get_real_x(jmi);
    for(k=0;k<jmi->n_real_x;k++) {
        v[k] = x_coll(jmi_opt_coll, i, j, k);
    }

    v = jmi_get_real_u(jmi);
    for(k=0;k<jmi->n_real_u;k++) {
        v[k] = u_coll(jmi_opt_coll, i, j, k);
    }

    v = jmi_get_real_w(jmi);
    for(k=0;k<jmi->n_real_w;k++) {
        v[k] = w_coll(jmi_opt_coll, i, j, k);
    }

    v = jmi_get_t(jmi);
    v[0] = 0;
    for (k=0;k<i;k++) {
        v[0] += jmi_opt_coll->hs[i];
    } /*TODO: Take into account the situation when initial and final times are free. */
    v[0] = jmi->opt->start_time + (jmi->opt->final_time - jmi->opt->start_time)*(v[0] +
            jmi_opt_coll->hs[i]*nlp->cp[j-1]);
    /*  printf("-\n%d, %d, %12.12f\n-\n",i,j,v[0]); */

}

/* Copy point wise values */
static void lp_radau_copy_q(jmi_opt_coll_t *jmi_opt_coll) {

    jmi_t *jmi = jmi_opt_coll->jmi;

    int i,j;
    jmi_real_t *_dx_p;
    jmi_real_t *_x_p;
    jmi_real_t *_u_p;
    jmi_real_t *_w_p;
    /*
    printf("1[\n");
    for(i=0;i<jmi->n_z;i++) {
        printf("-----> %d: %f\n",i+1,z[i]);
    }
    printf("]\n");
     */
    for(i=0;i<jmi->n_tp;i++) {
        _dx_p = jmi_get_real_dx_p(jmi,i);
        _x_p = jmi_get_real_x_p(jmi,i);
        _u_p = jmi_get_real_u_p(jmi,i);
        _w_p = jmi_get_real_w_p(jmi,i);

        for(j=0;j<jmi->n_real_dx;j++) {
            _dx_p[j] = dx_p(jmi_opt_coll,i,j);
        }
        for(j=0;j<jmi->n_real_x;j++) {
            _x_p[j] = x_p(jmi_opt_coll,i,j);
        }
        for(j=0;j<jmi->n_real_u;j++) {
            _u_p[j] = u_p(jmi_opt_coll,i,j);
        }
        for(j=0;j<jmi->n_real_w;j++) {
            _w_p[j] = w_p(jmi_opt_coll,i,j);
        }
    }

    /*
    printf("2[\n");
    for(i=0;i<jmi->n_z;i++) {
        printf("-----> %d: %f\n",i+1,z[i]);
    }
    printf("]\n");
     */
}

/* Copy initial point */
static void lp_radau_copy_initial_point(jmi_opt_coll_t *jmi_opt_coll) {

    /*  jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll; */
    jmi_t *jmi = jmi_opt_coll->jmi;

    int k;
    jmi_real_t *v;

    v = jmi_get_real_dx(jmi);
    for(k=0;k<jmi->n_real_dx;k++) {
        v[k] = dx_0(jmi_opt_coll,k);
    }

    v = jmi_get_real_x(jmi);
    for(k=0;k<jmi->n_real_x;k++) {
        v[k] = x_0(jmi_opt_coll,k);
    }

    v = jmi_get_real_u(jmi);
    for(k=0;k<jmi->n_real_u;k++) {
        v[k] = u_0(jmi_opt_coll,k);
    }

    v = jmi_get_real_w(jmi);
    for(k=0;k<jmi->n_real_w;k++) {
        v[k] = w_0(jmi_opt_coll,k);
    }

    /* TODO: take variable start time into account */
    v = jmi_get_t(jmi);
    v[0] = jmi->opt->start_time;

}

/* Cost function */
static int lp_radau_f(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *f) {
        jmi_opt_coll_radau_t* nlp;
    int i,j;
    
    if (jmi_opt_coll->jmi->opt == NULL) {
        return -1;
    }

    *f = 0;
    nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;

    /*printf("lp_radau_f\n"); */
/*  printf("<< %f\n",jmi_get_z(jmi_opt_coll->jmi)[0]); */

    /* Copy values into jmi->z */
    lp_radau_copy_p(jmi_opt_coll);

    /* Is there a point wise cost function? */
    if (jmi_opt_coll->jmi->opt->J->n_eq_F>0) {
        lp_radau_copy_q(jmi_opt_coll);
        /* Call cost function evaluation */
        jmi_opt_J(jmi_opt_coll->jmi, f);
    }

    /* Is there a Lagrange cost? */
    if (jmi_opt_coll->jmi->opt->L->n_eq_F>0) {
        /* Implement a quadrature cost function: sum over all elements
         and all collocation points */
        jmi_real_t tmp_f = 0;
        /* Loop over all elements */
        for (i=0;i<jmi_opt_coll->n_e;i++) {
            /* Loop over all collocation points */
            for (j=0;j<nlp->n_cp;j++) {
                /* Copy variables */
                lp_radau_copy_v(jmi_opt_coll,i,j+1);
                /* Call cost function evaluation */
                jmi_opt_L(jmi_opt_coll->jmi, &tmp_f);
                /* Sum and multiply with weight times element length. */
                *f += tmp_f*nlp->w[j]*jmi_opt_coll->hs[i]*
                      (jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time);
            }
        }
    }

    /* Add cost term for penalizing the delta u:s */

    if (jmi_opt_coll->n_blocking_factors>0) {
        for (i=0;i<jmi_opt_coll->n_e-1;i++) {
            for (j=0;j<jmi_opt_coll->jmi->n_real_u;j++) {
                *f += nlp->du_weights[j]/jmi_opt_coll->hs[i]/
                        (jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time)*
                        (u_coll(jmi_opt_coll,i+1,1,j) - u_coll(jmi_opt_coll,i,1,j))*
                        (u_coll(jmi_opt_coll,i+1,1,j) - u_coll(jmi_opt_coll,i,1,j));
            }
        }
    }
    return 0;
}

/* Gradient of cost function */
static int lp_radau_df(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *df) {
        jmi_opt_coll_radau_t* nlp;
        int i,j,k;
    
    if (jmi_opt_coll->jmi->opt == NULL) {
        return -1;
    }

/*  printf("lp_radau_df\n"); */
    nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    /*jmi_t *jmi = jmi_opt_coll->jmi; */

    /* Copy values into jmi->z */
    lp_radau_copy_p(jmi_opt_coll);

    for (i=0;i<jmi_opt_coll->n_x;i++) {
        df[i] = 0;
    }

    if (jmi_opt_coll->jmi->opt->J->n_eq_F>0) {
        lp_radau_copy_q(jmi_opt_coll);
        jmi_opt_dJ(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
                JMI_DER_PI | JMI_DER_PD, nlp->der_mask, df);

        jmi_opt_dJ(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
                JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
                df + nlp->offs_dx_p);
    }

    if (jmi_opt_coll->jmi->opt->L->n_eq_F>0) {
        jmi_real_t *dp = (jmi_real_t*)calloc(jmi_opt_coll->jmi->opt->n_p_opt,
                sizeof(jmi_real_t));
        jmi_real_t w_sum = 0;
        /* Take care of the case of blocking factors */
        if (jmi_opt_coll->n_blocking_factors>0) {
            /* Generate the sum of all weights for multiplication with the us */
            for (i=0;i<3;i++) {
                w_sum += nlp->w[i];
            }
            /* Loop over all elements */
            for (i=0;i<jmi_opt_coll->n_e;i++) {
                /* Loop over all collocation points */
                for (j=0;j<nlp->n_cp;j++) {
                    /* Copy collocation variables into model */
                    lp_radau_copy_v(jmi_opt_coll,i,j+1);
                    /* Evaluate Jacobian wrt to free parameters */
                    if (jmi_opt_coll->jmi->opt->n_p_opt>0) {
                        jmi_opt_dL(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
                                JMI_DER_PI | JMI_DER_PD, nlp->der_mask,dp);
                        for (k=0;k<jmi_opt_coll->jmi->opt->n_p_opt;k++) {
                            df[k] += dp[k]*nlp->w[j]*jmi_opt_coll->hs[i]*(jmi_opt_coll->jmi->opt->final_time -
                                jmi_opt_coll->jmi->opt->start_time);
                        }
                    }
                    /* The first collocation point in each element contains
                     us */
                    if (j==0) {
                        /* Evaluate Jacobian */
                        jmi_opt_dL(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
                                JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask,
                                df + offs_dx_coll(jmi_opt_coll,i,j+1,0));
                        /* Multiply with weights */
                        for (k=0;k<2*jmi_opt_coll->jmi->n_real_dx;k++) {
                            df[offs_dx_coll(jmi_opt_coll,i,j+1,0) + k] *= jmi_opt_coll->hs[i]*
                            nlp->w[j]*(jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time);
                        }
                        /* Threat the us differently to compensate for
                         blocking factors */
                        for (k=0;k<jmi_opt_coll->jmi->n_real_u;k++) {
                                df[offs_u_coll(jmi_opt_coll,i,j+1,0) + k] *= jmi_opt_coll->hs[i]*
                                w_sum*(jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time);
                        }
                        for (k=0;k<jmi_opt_coll->jmi->n_real_w;k++) {
                            df[offs_w_coll(jmi_opt_coll,i,j+1,0) + k] *= jmi_opt_coll->hs[i]*
                            nlp->w[j]*(jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time);
                        }
                    } else {
                        /* For all collocation points except the first, there
                         are no us in the case of blocking factors */
                        jmi_opt_dL(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
                                JMI_DER_DX | JMI_DER_X | JMI_DER_W, nlp->der_mask,
                                df + offs_dx_coll(jmi_opt_coll,i,j+1,0));
                        /* Multiply with the weights */
                        for (k=0;k<2*jmi_opt_coll->jmi->n_real_dx +
                            jmi_opt_coll->jmi->n_real_w;k++) {
                            df[offs_dx_coll(jmi_opt_coll,i,j+1,0) + k] *= jmi_opt_coll->hs[i]*
                                nlp->w[j]*(jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time);
                        }
                    }

                }
            }
        } else { /* No blocking factors */
            for (i=0;i<jmi_opt_coll->n_e;i++) {
                for (j=0;j<nlp->n_cp;j++) {
                    /* Copy variables */
                    lp_radau_copy_v(jmi_opt_coll,i,j+1);
                    /* Evaluate Jacobian wrt to free parameters */
                    if (jmi_opt_coll->jmi->opt->n_p_opt>0) {
                        jmi_opt_dL(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
                                JMI_DER_PI | JMI_DER_PD, nlp->der_mask,dp);
                        for (k=0;k<jmi_opt_coll->jmi->opt->n_p_opt;k++) {
                            df[k] += dp[k]*nlp->w[j]*jmi_opt_coll->hs[i]*(jmi_opt_coll->jmi->opt->final_time -
                                jmi_opt_coll->jmi->opt->start_time);
                        }
                    }
                    /* Evaluate Jacobian */
                    jmi_opt_dL(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_DENSE_COL_MAJOR,
                        JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask,
                        df + offs_dx_coll(jmi_opt_coll,i,j+1,0));
                    /* Multiply with weights */
                    for (k=0;k<2*jmi_opt_coll->jmi->n_real_dx +
                        jmi_opt_coll->jmi->n_real_u + jmi_opt_coll->jmi->n_real_w;k++) {
                        df[offs_dx_coll(jmi_opt_coll,i,j+1,0) + k] *= jmi_opt_coll->hs[i]*
                            nlp->w[j]*(jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time);
                    }
                }
            }
        }
        free(dp);
    }

    /* Add cost term for penalizing the delta u:s */
    if (jmi_opt_coll->n_blocking_factors>0) {
        for (i=0;i<jmi_opt_coll->n_e;i++) {
            for (j=0;j<jmi_opt_coll->jmi->n_real_u;j++) {
                if (i>0) {
                    df[offs_u_coll(jmi_opt_coll,i,1,j)] +=
                            2*nlp->du_weights[j]/jmi_opt_coll->hs[i]/
                            (jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time)*
                            (u_coll(jmi_opt_coll,i,1,j) - u_coll(jmi_opt_coll,i-1,1,j));
                }

                if (i<jmi_opt_coll->n_e-1) {
                    df[offs_u_coll(jmi_opt_coll,i,1,j)] +=
                            - 2*nlp->du_weights[j]/jmi_opt_coll->hs[i]/
                            (jmi_opt_coll->jmi->opt->final_time-jmi_opt_coll->jmi->opt->start_time)*
                            (u_coll(jmi_opt_coll,i+1,1,j) - u_coll(jmi_opt_coll,i,1,j));
                }
            }
        }
    }

    /*
    for (i=0;i<jmi_opt_coll->jmi->n_z;i++) {
        printf("mask[%d]=%d\n",i,nlp->der_mask[i]);
    }

    for (i=0;i<jmi_opt_coll->n_x;i++) {
        printf("3 df[%d]=%f\n",i,df[i]);
    }
*/

    return 0;
}

static int lp_radau_g(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *res) {
    int i,j;
    jmi_opt_coll_radau_t* nlp;
    jmi_t* jmi;
    
    if (jmi_opt_coll->jmi->opt == NULL) {
        return -1;
    }
/*  printf("lp_radau_g\n"); */

    nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi = jmi_opt_coll->jmi;

    /* Path inequality constraints */
    /* Initial variables */
    lp_radau_copy_p(jmi_opt_coll);
    lp_radau_copy_q(jmi_opt_coll);
    lp_radau_copy_initial_point(jmi_opt_coll);
    jmi_opt_Cineq(jmi_opt_coll->jmi,res);

    /* Collocation variables */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            lp_radau_copy_v(jmi_opt_coll,i,j+1);
            jmi_opt_Cineq(jmi_opt_coll->jmi, res + jmi->opt->Cineq->n_eq_F*(1 + i*nlp->n_cp + j));
        }
    }

    jmi_opt_Hineq(jmi,res + jmi->opt->Cineq->n_eq_F*(nlp->n_cp*jmi_opt_coll->n_e + 1));

    return 0;
}

static int lp_radau_dg(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *jac) {
    int i,j;
    jmi_opt_coll_radau_t* nlp;
    
    if (jmi_opt_coll->jmi->opt == NULL) {
        return -1;
    }

/*  printf("lp_radau_dg\n"); */
    nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;

    /* Initial variables */
    lp_radau_copy_p(jmi_opt_coll);
    lp_radau_copy_q(jmi_opt_coll);
    lp_radau_copy_initial_point(jmi_opt_coll);
    jmi_opt_dCineq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD, nlp->der_mask, jac);
    jmi_opt_dCineq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask, jac + nlp->dCineq_dp_n_nz);
    jmi_opt_dCineq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
            jac + nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz);

    /* collocation variables */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            lp_radau_copy_v(jmi_opt_coll,i,j+1);
            jmi_opt_dCineq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
                    JMI_DER_PI | JMI_DER_PD, nlp->der_mask,
                    jac + (nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz + nlp->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*
                    (1 + i*nlp->n_cp + j));
            jmi_opt_dCineq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
                    JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask,
                    jac + (nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz + nlp->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*
                    (1 + i*nlp->n_cp + j) + nlp->dCineq_dp_n_nz);
            jmi_opt_dCineq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
                    JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
                    jac + (nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz + nlp->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*
                    (1 + i*nlp->n_cp + j) + nlp->dCineq_dp_n_nz + nlp->dCineq_ddx_dx_du_dw_n_nz);
        }

    }

    jmi_opt_dHineq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD | JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
            jac + (nlp->dCineq_ddx_dx_du_dw_n_nz + nlp->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*
            (1 + nlp->n_cp*jmi_opt_coll->n_e));

    return 0;
}


static int lp_radau_dg_nz_indices(jmi_opt_coll_t *jmi_opt_coll, int *irow, int *icol) {
    int i;
    
    if (jmi_opt_coll->jmi->opt == NULL) {
        return -1;
    }

    for (i=0;i<jmi_opt_coll->dg_n_nz;i++) {
        irow[i] = jmi_opt_coll->dg_row[i];
        icol[i] = jmi_opt_coll->dg_col[i];
    }
    
    return 0;
}

static int lp_radau_h(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *res) {
    int i,j;
    int k,l;
    int el_ind = 0;
    int constr_ind = 0;
    
    jmi_opt_coll_radau_t* nlp;
    jmi_t* jmi;
    jmi_real_t el_length;
    
    if (jmi_opt_coll->jmi->opt == NULL) {
        return -1;
    }
    /*printf("-- g\n"); */
    /*printf("lp_radau_h\n"); */

    nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi = jmi_opt_coll->jmi;

    /*
        printf("**********************************************");
        for (i=0;i<jmi_opt_coll->n_x;i++) {
            printf(">> x[%d] = %12.12f\n",i,jmi_opt_coll->x[i]);
        }
     */

    /* Free dependent parameters */
    lp_radau_copy_p(jmi_opt_coll);
    jmi_opt_Ffdp(jmi_opt_coll->jmi,res+ dh_ffdp_eq_offs(jmi_opt_coll,0));

    lp_radau_copy_q(jmi_opt_coll);

    /* Initial system */
    lp_radau_copy_initial_point(jmi_opt_coll);
    jmi_init_F0(jmi_opt_coll->jmi,res+ dh_init_eq_offs(jmi_opt_coll,0));

    /*
        for (i=0;i<3;i++) {
            printf("%f\n",res[i]);
        }
     */

    /* collocation point residuals */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            lp_radau_copy_v(jmi_opt_coll,i,j+1);
            jmi_dae_F(jmi_opt_coll->jmi, res + dh_res_eq_offs(jmi_opt_coll, i, j + 1, 0));
        }
    }

    /* Continuity equations */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<jmi->n_real_x;j++) {
            res[dh_cont_eq_offs(jmi_opt_coll, i, j)] = x_coll(jmi_opt_coll,i,nlp->n_cp,j) -
            x_coll(jmi_opt_coll,i+1,0,j);
        }
    }

    /* Interpolation equation for u_0 */
    /* Compute element length, taking into account if the initial or
     terminal time, or the element lengths are free. */
    if (jmi->opt->final_time_free == 0 &&
            jmi->opt->start_time_free == 0 &&
            jmi_opt_coll->hs_free ==0) {
        el_length = jmi_opt_coll->hs[0]*(jmi->opt->final_time - jmi->opt->start_time);
    } else { /* TODO: Take care of the other cases */
        el_length=0;
    }
    for (k=0;k<jmi->n_real_u;k++) {
        res[dh_u0_eq_offs(jmi_opt_coll,k)] = u_0(jmi_opt_coll,k);
        if (jmi_opt_coll->n_blocking_factors>0) {
            res[dh_u0_eq_offs(jmi_opt_coll,k)] -= u_coll(jmi_opt_coll,0,1,k);
        } else {
            for (l=0;l<nlp->n_cp;l++) {
                /*printf("--- %d %d %d %d %d\n",i,jmi_opt_coll->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_coll, i, k),l); */
                res[dh_u0_eq_offs(jmi_opt_coll, k)] -=
                    jmi_opt_coll_radau_eval_pol(0,nlp->n_cp, nlp->Lp_coeffs, l)*
                    u_coll(jmi_opt_coll,0,l+1,k);
            }
        }
    }

    /* Collocation equations */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            int k,l;

            /* Compute element length, taking into account if the initial or
             terminal time, or the element lengths are free. */
            jmi_real_t el_length;
            if (jmi->opt->final_time_free == 0 &&
                    jmi->opt->start_time_free == 0 &&
                    jmi_opt_coll->hs_free ==0) {
                el_length = jmi_opt_coll->hs[i]*(jmi->opt->final_time - jmi->opt->start_time);
            } else { /* TODO: Take care of the other cases */
                el_length=0;
            }
            for (k=0;k<jmi->n_real_x;k++) {
                res[dh_coll_eq_offs(jmi_opt_coll, i, j+1, k)] = dx_coll(jmi_opt_coll,i,j+1,k);
                for (l=0;l<nlp->n_cp+1;l++) {
                    /*printf("-- %d %d %d %d %f---\n",i,j,k,l,nlp->Lpp_dot_vals[(nlp->n_cp+1)*(j + 1) + l]); */
                    res[dh_coll_eq_offs(jmi_opt_coll, i, j+1, k)] -=
                        nlp->Lpp_dot_vals[(nlp->n_cp+1)*(j + 1) + l]*x_coll(jmi_opt_coll,i,l,k)/el_length;
                }
            }
        }
    }

    /* Interpolation equations */
    for (i=0;i<jmi->n_tp;i++) {
        int k,l;
        /* Compute element length, taking into account if the initial or
         terminal time, or the element lengths are free. */
        if (jmi->opt->final_time_free == 0 &&
                jmi->opt->start_time_free == 0 &&
                jmi_opt_coll->hs_free ==0) {
            el_length = jmi_opt_coll->hs[jmi_opt_coll->tp_e[i]]*(jmi->opt->final_time - jmi->opt->start_time);
        } else { /* TODO: Take care of the other cases */
            el_length=0;
        }

        /* Interpolation equations for dx */
        for (k=0;k<jmi->n_real_dx;k++) {
            /*printf("### - %d\n",dh_dx_p_eq_offs(jmi_opt_coll, i, k)); */
            res[dh_dx_p_eq_offs(jmi_opt_coll, i, k)] = dx_p(jmi_opt_coll,i,k);
            for (l=0;l<nlp->n_cp+1;l++) {
                /*printf("--- %d %d %d %d %d\n",i,jmi_opt_coll->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_coll, i, k),l); */
                res[dh_dx_p_eq_offs(jmi_opt_coll, i, k)] -=
                    jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp+1, nlp->Lpp_dot_coeffs, l)*
                    x_coll(jmi_opt_coll,jmi_opt_coll->tp_e[i],l,k)/el_length;
            }
        }

        /* Interpolation equations for x */
        for (k=0;k<jmi->n_real_x;k++) {
            /*printf("### - %d\n",dh_dx_p_eq_offs(jmi_opt_coll, i, k)); */
            res[dh_x_p_eq_offs(jmi_opt_coll, i, k)] = x_p(jmi_opt_coll,i,k);
            for (l=0;l<nlp->n_cp+1;l++) {
                /*printf("--- %d %d %d %d %d\n",i,jmi_opt_coll->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_coll, i, k),l); */
                res[dh_x_p_eq_offs(jmi_opt_coll, i, k)] -=
                    jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp+1, nlp->Lpp_coeffs, l)*
                    x_coll(jmi_opt_coll,jmi_opt_coll->tp_e[i],l,k);
            }
        }

        /* Interpolation equations for u */
        for (k=0;k<jmi->n_real_u;k++) {
            /*printf("### - %d\n",dh_dx_p_eq_offs(jmi_opt_coll, i, k)); */
            res[dh_u_p_eq_offs(jmi_opt_coll, i, k)] = u_p(jmi_opt_coll,i,k);
            for (l=0;l<nlp->n_cp;l++) {
                /*printf("--- %d %d %d %d %d\n",i,jmi_opt_coll->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_coll, i, k),l); */
                res[dh_u_p_eq_offs(jmi_opt_coll, i, k)] -=
                    jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp, nlp->Lp_coeffs, l)*
                    u_coll(jmi_opt_coll,jmi_opt_coll->tp_e[i],l+1,k);
            }
        }

        /* Interpolation equations for w */
        for (k=0;k<jmi->n_real_w;k++) {
            /*printf("### - %d\n",dh_dx_p_eq_offs(jmi_opt_coll, i, k)); */
            res[dh_w_p_eq_offs(jmi_opt_coll, i, k)] = w_p(jmi_opt_coll,i,k);
            for (l=0;l<nlp->n_cp;l++) {
                /*printf("--- %d %d %d %d %d\n",i,jmi_opt_coll->tp_e[i],k,dh_dx_p_eq_offs(jmi_opt_coll, i, k),l); */
                res[dh_w_p_eq_offs(jmi_opt_coll, i, k)] -=
                    jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp, nlp->Lp_coeffs, l)*
                    w_coll(jmi_opt_coll,jmi_opt_coll->tp_e[i],l+1,k);
            }
        }
    }

    /* Constraints Ceq */
    lp_radau_copy_initial_point(jmi_opt_coll);
    /* Initial variables */
    /*printf("###> - %d\n",dh_Ceq_eq_offs(jmi_opt_coll,0,0,0)); */
    jmi_opt_Ceq(jmi_opt_coll->jmi,res + dh_Ceq_eq_offs(jmi_opt_coll,0,0,0));

    /* Collocation variables */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            lp_radau_copy_v(jmi_opt_coll,i,j+1);
            /*printf("###>> - %d\n",dh_Ceq_eq_offs(jmi_opt_coll,i,j+1,0)); */
            jmi_opt_Ceq(jmi_opt_coll->jmi,res + dh_Ceq_eq_offs(jmi_opt_coll,i,j+1,0));
        }
    }

    /* Constraints in Heq */

    jmi_opt_Heq(jmi_opt_coll->jmi,res + dh_Heq_eq_offs(jmi_opt_coll, 0));

    /* loop over all blocking factors */
    for (i=0;i<jmi_opt_coll->n_blocking_factors;i++) {
        /* loop over each constraint */
        for (j=0;j<jmi_opt_coll->blocking_factors[i]-1;j++) {
            for (k=0;k<jmi->n_real_u;k++) {
                res[dh_Heq_eq_offs(jmi_opt_coll,0) + jmi->opt->Heq->n_eq_F + constr_ind] =
                    u_coll(jmi_opt_coll,el_ind,0,k) -
                    u_coll(jmi_opt_coll,el_ind+j+1,0,k);
                constr_ind++;
            }
        }
        el_ind += jmi_opt_coll->blocking_factors[i];
    }

    /*
        for (i=0;i<jmi_opt_coll->n_h;i++) {
            printf(">> h[%d] = %12.12f\n",i,res[i]);
        }
        printf("**********************************************");
     */

    return 0;
}

static int lp_radau_dh(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *jac) {
    int i,j,k,l;
    jmi_opt_coll_radau_t* nlp;
    jmi_t* jmi;
    jmi_real_t el_length;
    
    int jac_ind;
    
    if (jmi_opt_coll->jmi->opt == NULL) {
        return -1;
    }
/*  printf("lp_radau_dh\n"); */
    nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi = jmi_opt_coll->jmi;

    /* Initial system */
    lp_radau_copy_p(jmi_opt_coll);
    jmi_opt_dFfdp(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD,
            nlp->der_mask, jac);

    /* Initial system */
    lp_radau_copy_initial_point(jmi_opt_coll);
    jmi_init_dF0(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD | JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
            nlp->der_mask, jac + nlp->dFfdp_dp_n_nz);
    /*
    for (i=0;i<3;i++) {
        printf("%f\n",jac[i]);
    }
     */
    /* collocation point residuals */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            lp_radau_copy_v(jmi_opt_coll,i,j+1);
            /* dF_dp */
            jmi_dae_dF(jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
                    JMI_DER_PI | JMI_DER_PD, nlp->der_mask, jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz + (nlp->dF_dp_n_nz + nlp->dF_ddx_dx_du_dw_n_nz)*(i*nlp->n_cp + j));
            /* dF_ddx_dx_du_dw */
            jmi_dae_dF(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_SPARSE,
                    JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
                    nlp->der_mask,
                    jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    nlp->dF_dp_n_nz*(i*nlp->n_cp + j + 1) +
                    nlp->dF_ddx_dx_du_dw_n_nz*(i*nlp->n_cp + j));
        }
    }

    /* Continuity equations */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<jmi->n_real_x;j++) {
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*2*i + j] = 1;
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*(2*i+1) + j] = -1;

        }
    }


    /* Interpolation equations for u_0 */
    if (jmi->opt->final_time_free == 0 &&
            jmi->opt->start_time_free == 0 &&
            jmi_opt_coll->hs_free ==0) {
        el_length = jmi_opt_coll->hs[0]*(jmi->opt->final_time - jmi->opt->start_time);
    } else { /* TODO: Take care of the other cases */
        el_length=0;
    }

    /* Entries for u_0,j */
    if (jmi_opt_coll->n_blocking_factors==0) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_u;k++) {
                jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*j + k] =
                                -jmi_opt_coll_radau_eval_pol(0,nlp->n_cp, nlp->Lp_coeffs, j);
            }
        }
    } else {
        for (k=0;k<jmi->n_real_u;k++) {
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*2*jmi_opt_coll->n_e +
                        jmi->n_real_u*0 + k] = -1;
        }
    }

    /* Entries for u_0 */
    for (k=0;k<jmi->n_real_u;k++) {
        jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
            (nlp->dF_dp_n_nz +
                    nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                    jmi->n_real_x*2*jmi_opt_coll->n_e +
                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 1 : nlp->n_cp) + k] = 1;
    }


    /* Collocation equations */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {

            /* Compute element length, taking into account if the initial or
             terminal time, or the element lengths are free. */
            jmi_real_t el_length;
            if (jmi->opt->final_time_free == 0 &&
                    jmi->opt->start_time_free == 0 &&
                    jmi_opt_coll->hs_free ==0) {
                el_length = jmi_opt_coll->hs[i]*(jmi->opt->final_time - jmi->opt->start_time);
            } else { /* TODO: Take care of the other cases */
                el_length=0;
            }

            /* dx */
            for (k=0;k<jmi->n_real_dx;k++) {
                jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) + jmi->n_real_x*(nlp->n_cp + 2)*(nlp->n_cp*i + j) + k] = 1;
            }

            /* x_i,j */
            for (k=0;k<nlp->n_cp;k++) {
                for (l=0;l<jmi->n_real_x;l++) {
                    /*                  printf("-- %d\n",nlp->dF0_n_nz +
                        (nlp->dF_dp_n_nz +
                         nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                         jmi->n_real_x*2*jmi_opt_coll->n_e +
                         jmi->n_real_u*(nlp->n_cp+1) + jmi->n_real_x*(nlp->n_cp + 2)*(nlp->n_cp*i + j) + jmi->n_real_x +
                         jmi->n_real_x*k + l);*/
                    jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                        (nlp->dF_dp_n_nz +
                                nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                                jmi->n_real_x*2*jmi_opt_coll->n_e +
                                jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                jmi->n_real_x*(nlp->n_cp + 2)*(nlp->n_cp*i + j) + jmi->n_real_x +
                                jmi->n_real_x*k + l] = -nlp->Lpp_dot_vals[(nlp->n_cp+1)*(j + 1) + k + 1]/el_length;
                }
            }

            /* x_i,0 */
            for (l=0;l<jmi->n_real_x;l++) {
                jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_x*(nlp->n_cp + 2)*(nlp->n_cp*i + j) + jmi->n_real_x +
                            jmi->n_real_x*nlp->n_cp + l] = -nlp->Lpp_dot_vals[(nlp->n_cp+1)*(j + 1) + 0]/el_length;
            }
        }
    }

    /* Interpolation equations */
    for (i=0;i<jmi->n_tp;i++) {
        /* Compute element length, taking into account if the initial or
         terminal time, or the element lengths are free. */
        jmi_real_t el_length;
        if (jmi->opt->final_time_free == 0 &&
                jmi->opt->start_time_free == 0 &&
                jmi_opt_coll->hs_free ==0) {
            el_length = jmi_opt_coll->hs[jmi_opt_coll->tp_e[i]]*(jmi->opt->final_time - jmi->opt->start_time);
        } else { /* TODO: Take care of the other cases */
            el_length=0;
        }

        /* Interpolation equations for dx_p */

        /* Entries for x_i,0 */
        for (k=0;k<jmi->n_real_x;k++) {
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*2*jmi_opt_coll->n_e +
                        jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                        jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                        (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                jmi->n_real_w*(nlp->n_cp + 1))*i + k] =
                                    -jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp+1, nlp->Lpp_dot_coeffs, 0)/el_length;
        }

        /* Entries for x_i,j */
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_x;k++) {
                jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                            jmi->n_real_x*(j+1) +
                            (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                    jmi->n_real_w*(nlp->n_cp + 1))*i + k] =
                                        -jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp+1, nlp->Lpp_dot_coeffs, j+1)/el_length;
            }
        }

        /* Entries for dx_p */
        for (k=0;k<jmi->n_real_dx;k++) {
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*2*jmi_opt_coll->n_e +
                        jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                        jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                        jmi->n_real_x*(nlp->n_cp+1) +
                        (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                jmi->n_real_w*(nlp->n_cp + 1))*i + k] = 1;
        }

        /* Interpolation equations for x */

        /* Entries for x_i,0 */
        for (k=0;k<jmi->n_real_x;k++) {
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*2*jmi_opt_coll->n_e +
                        jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                        jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                        jmi->n_real_x*(nlp->n_cp + 2) +
                        (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                jmi->n_real_w*(nlp->n_cp + 1))*i + k] =
                                    -jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp+1, nlp->Lpp_coeffs, 0);
        }

        /* Entries for x_i,j */
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_x;k++) {
                jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                            jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_x*(j+1) +
                            (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                    jmi->n_real_w*(nlp->n_cp + 1))*i + k] =
                                        -jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp+1, nlp->Lpp_coeffs, j+1);
            }
        }

        /* Entries for x_p */
        for (k=0;k<jmi->n_real_x;k++) {
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*2*jmi_opt_coll->n_e +
                        jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                        jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                        jmi->n_real_x*(nlp->n_cp + 2) +
                        jmi->n_real_x*(nlp->n_cp+1) +
                        (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                jmi->n_real_w*(nlp->n_cp + 1))*i + k] = 1;
        }


        /* Interpolation equations for u */

        /* Entries for u_i,j */
        if (jmi_opt_coll->n_blocking_factors>0) {
            for (k=0;k<jmi->n_real_u;k++) {
                jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                            jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_u*0 +
                            (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                2*jmi->n_real_u +
                                jmi->n_real_w*(nlp->n_cp + 1))*i + k] =
                                    -1;
            }
        } else {
            for (j=0;j<nlp->n_cp;j++) {
                for (k=0;k<jmi->n_real_u;k++) {
                    jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                        (nlp->dF_dp_n_nz +
                                nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                                jmi->n_real_x*2*jmi_opt_coll->n_e +
                                jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                                jmi->n_real_x*(nlp->n_cp + 2) +
                                jmi->n_real_x*(nlp->n_cp + 2) +
                                jmi->n_real_u*j +
                                (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                        jmi->n_real_u*(nlp->n_cp + 1) +
                                        jmi->n_real_w*(nlp->n_cp + 1))*i + k] =
                                        -jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp, nlp->Lp_coeffs, j);
                }
            }
        }

        /* Entries for u_p */
        for (k=0;k<jmi->n_real_u;k++) {
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*2*jmi_opt_coll->n_e +
                        jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                        jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                        jmi->n_real_x*(nlp->n_cp + 2) +
                        jmi->n_real_x*(nlp->n_cp + 2) +
                        (jmi_opt_coll->n_blocking_factors>0? jmi->n_real_u : jmi->n_real_u*nlp->n_cp) + /*jmi->n_real_u*nlp->n_cp + */
                        (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                (jmi_opt_coll->n_blocking_factors>0? 2* jmi->n_real_u : jmi->n_real_u*(nlp->n_cp + 1)) +
                                jmi->n_real_w*(nlp->n_cp + 1))*i + k] = 1;
        }

        /* Interpolation equations for w */

        /* Entries for w_i,j */
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_w;k++) {
                jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                            jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp + 1)) +
                            jmi->n_real_w*j +
                            (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                    jmi->n_real_w*(nlp->n_cp + 1))*i + k] =
                                        -jmi_opt_coll_radau_eval_pol(jmi_opt_coll->tp_tau[i],nlp->n_cp, nlp->Lp_coeffs, j);
            }
        }

        /* Entries for w_p */
        for (k=0;k<jmi->n_real_w;k++) {
            jac[nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                (nlp->dF_dp_n_nz +
                        nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                        jmi->n_real_x*2*jmi_opt_coll->n_e +
                        jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                        jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                        jmi->n_real_x*(nlp->n_cp + 2) +
                        jmi->n_real_x*(nlp->n_cp + 2) +
                        jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp + 1)) +
                        jmi->n_real_w*nlp->n_cp +
                        (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                jmi->n_real_w*(nlp->n_cp + 1))*i + k] = 1;
        }

    }

    /* Ceq */
    /* Initial variables */
    lp_radau_copy_initial_point(jmi_opt_coll);
    jmi_opt_dCeq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD, nlp->der_mask, jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
            (nlp->dF_dp_n_nz +
                    nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                    jmi->n_real_x*2*jmi_opt_coll->n_e +
                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                    jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                    (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_w*(nlp->n_cp + 1))*jmi->n_tp);
    jmi_opt_dCeq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask, jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
            (nlp->dF_dp_n_nz +
                    nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                    jmi->n_real_x*2*jmi_opt_coll->n_e +
                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                    jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                    (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_w*(nlp->n_cp + 1))*jmi->n_tp + nlp->dCeq_dp_n_nz);
    jmi_opt_dCeq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
            jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
            (nlp->dF_dp_n_nz +
                    nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                    jmi->n_real_x*2*jmi_opt_coll->n_e +
                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                    jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                    (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_w*(nlp->n_cp + 1))*jmi->n_tp +
                            nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz);

    /* collocation variables */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            lp_radau_copy_v(jmi_opt_coll,i,j+1);
            jmi_opt_dCeq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
                    JMI_DER_PI | JMI_DER_PD, nlp->der_mask,
                    jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) + jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                            (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                    jmi->n_real_w*(nlp->n_cp + 1))*jmi->n_tp +
                                    (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
                                    (1 + i*nlp->n_cp + j));
            jmi_opt_dCeq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
                    JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W, nlp->der_mask,
                    jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                            (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                    jmi->n_real_w*(nlp->n_cp + 1))*jmi->n_tp +
                                    (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
                                    (1 + i*nlp->n_cp + j) + nlp->dCeq_dp_n_nz);
            jmi_opt_dCeq(jmi_opt_coll->jmi,nlp->der_eval_alg, JMI_DER_SPARSE,
                    JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P, nlp->der_mask,
                    jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
                    (nlp->dF_dp_n_nz +
                            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                            jmi->n_real_x*2*jmi_opt_coll->n_e +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                            (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                                    jmi->n_real_w*(nlp->n_cp + 1))*jmi->n_tp +
                                    (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
                                    (1 + i*nlp->n_cp + j) + nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz);
        }

    }

    /* Heq */
    jmi_opt_dHeq(jmi_opt_coll->jmi, nlp->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD | JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
            nlp->der_mask,jac + nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
            (nlp->dF_dp_n_nz +
                    nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
                    jmi->n_real_x*2*jmi_opt_coll->n_e +
                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                    jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
                    (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                            jmi->n_real_w*(nlp->n_cp + 1))*jmi->n_tp +
                            (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
                            (1 + jmi_opt_coll->n_e*nlp->n_cp ));


    /* loop over all blocking factors */
    jac_ind = nlp->dFfdp_dp_n_nz + nlp->dF0_n_nz +
    (nlp->dF_dp_n_nz +
            nlp->dF_ddx_dx_du_dw_n_nz)*(jmi_opt_coll->n_e*nlp->n_cp) +
            jmi->n_real_x*2*jmi_opt_coll->n_e +
            jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
            jmi->n_real_x*(nlp->n_cp + 2)*jmi_opt_coll->n_e*nlp->n_cp +
            (jmi->n_real_x*(nlp->n_cp + 2) + jmi->n_real_x*(nlp->n_cp + 2) +
                    jmi->n_real_u*((jmi_opt_coll->n_blocking_factors>0)? 2 : (nlp->n_cp+1)) +
                    jmi->n_real_w*(nlp->n_cp + 1))*jmi->n_tp +
                    (nlp->dCeq_dp_n_nz + nlp->dCeq_ddx_dx_du_dw_n_nz + nlp->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*
                    (1 + jmi_opt_coll->n_e*nlp->n_cp ) + jmi->opt->Heq->n_eq_F;
    for (i=0;i<jmi_opt_coll->n_blocking_factors;i++) {
        /* loop over each constraint */
        for (j=0;j<jmi_opt_coll->blocking_factors[i]-1;j++) {
            for (k=0;k<jmi->n_real_u;k++) {
                jac[jac_ind++] = 1;
                jac[jac_ind++] = -1;
            }
        }
    }


    /*
    for (i=0;i<jmi_opt_coll->dh_n_nz;i++) {
        printf("<<< dh[%d;%d,%d]=%f\n",i,jmi_opt_coll->dh_row[i],jmi_opt_coll->dh_col[i],jac[i]);
    }
*/

    return 0;
}

static int lp_radau_dh_nz_indices(jmi_opt_coll_t *jmi_opt_coll, int *irow, int *icol) {
    int i;
    
    if (jmi_opt_coll->jmi->opt == NULL) {
        return -1;
    }

    for (i=0;i<jmi_opt_coll->dh_n_nz;i++) {
        irow[i] = jmi_opt_coll->dh_row[i];
        icol[i] = jmi_opt_coll->dh_col[i];
    }

    return 0;
}

static int lp_radau_write_file_matlab(jmi_opt_coll_t *jmi_opt_coll, const char* file_name) {
    int i,j,k;
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;


    FILE *f = fopen(file_name,"wt");

    fprintf(f,"t=[");
    /* initial time point */
    /* TODO: Support for free initial and final time */
    fprintf(f,"%12.12f\n",jmi->opt->start_time);

    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            jmi_real_t tt = jmi->opt->start_time;
            for (k=0;k<i;k++) {
                tt += jmi_opt_coll->hs[k]*(jmi->opt->final_time-jmi->opt->start_time);
            }
            tt += jmi_opt_coll->hs[i]*nlp->cp[j]*(jmi->opt->final_time-jmi->opt->start_time);
            fprintf(f,"%12.12f\n",tt);
        }
    }
    fprintf(f,"];\n");

    /* optimization parameters */
    fprintf(f,"p_opt=[");
    for (i=0;i<jmi->opt->n_p_opt;i++) {
        fprintf(f,"%12.12f\n",p_opt(jmi_opt_coll,i));
    }
    fprintf(f,"];\n");

    /* derivatives */
    fprintf(f,"dx=[");
    for (i=0;i<jmi->n_real_dx;i++) {
        fprintf(f,"%12.12f, ",dx_0(jmi_opt_coll,i));
    }
    fprintf(f,"\n");
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_dx;k++) {
                fprintf(f,"%12.12f, ",dx_coll(jmi_opt_coll,i,j+1,k));
            }
            fprintf(f,"\n");
        }
    }
    fprintf(f,"];\n");

    /* states */
    fprintf(f,"x=[");
    for (i=0;i<jmi->n_real_x;i++) {
        fprintf(f,"%12.12f, ",x_0(jmi_opt_coll,i));
    }
    fprintf(f,"\n");
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_x;k++) {
                fprintf(f,"%12.12f, ",x_coll(jmi_opt_coll,i,j+1,k));
            }
            fprintf(f,"\n");
        }
    }
    fprintf(f,"];\n");

    /* inputs */
    fprintf(f,"u=[");
    for (i=0;i<jmi->n_real_u;i++) {
        fprintf(f,"%12.12f, ",u_0(jmi_opt_coll,i));
    }
    fprintf(f,"\n");
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_u;k++) {
                fprintf(f,"%12.12f, ",u_coll(jmi_opt_coll,i,j+1,k));
            }
            fprintf(f,"\n");
        }
    }
    fprintf(f,"];\n");

    /* algebraics */
    fprintf(f,"w=[");
    for (i=0;i<jmi->n_real_w;i++) {
        fprintf(f,"%12.12f, ",w_0(jmi_opt_coll,i));
    }
    fprintf(f,"\n");
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_w;k++) {
                fprintf(f,"%12.12f, ",w_coll(jmi_opt_coll,i,j+1,k));
            }
            fprintf(f,"\n");
        }
    }
    fprintf(f,"];\n");

    fclose(f);

    return 0;

}

static int lp_radau_get_result_variable_vector_length(jmi_opt_coll_t
        *jmi_opt_coll, int *n) {
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    *n = jmi_opt_coll->n_e*nlp->n_cp + 1;
    return 0;
}

static int lp_radau_get_result(jmi_opt_coll_t *jmi_opt_coll, jmi_real_t *p_opt_,
        jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
        jmi_real_t *w) {

    int i,j,k;
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;

    /* Create time vector */
    t[0] = jmi->opt->start_time;
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            jmi_real_t tt = jmi->opt->start_time;
            for (k=0;k<i;k++) {
                tt += jmi_opt_coll->hs[k]*(jmi->opt->final_time-jmi->opt->start_time);
            }
            tt += jmi_opt_coll->hs[i]*nlp->cp[j]*(jmi->opt->final_time-jmi->opt->start_time);
            t[i*nlp->n_cp + j + 1] = tt;
        }
    }

    /* optimization parameters */
    for (i=0;i<jmi->opt->n_p_opt;i++) {
        p_opt_[i] = p_opt(jmi_opt_coll,i);
    }

    /* derivatives */
    for (i=0;i<jmi->n_real_dx;i++) {
        dx[i*(jmi_opt_coll->n_e*nlp->n_cp+1)] = dx_0(jmi_opt_coll,i);
    }
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_dx;k++) {
                dx[k*(jmi_opt_coll->n_e*nlp->n_cp+1) + i*nlp->n_cp + j + 1] =
                    dx_coll(jmi_opt_coll,i,j+1,k);
            }
        }
    }

    /* states */
    for (i=0;i<jmi->n_real_x;i++) {
        x[i*(jmi_opt_coll->n_e*nlp->n_cp+1)] = x_0(jmi_opt_coll,i);
    }
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_x;k++) {
                x[k*(jmi_opt_coll->n_e*nlp->n_cp+1) + i*nlp->n_cp + j + 1] =
                    x_coll(jmi_opt_coll,i,j+1,k);
            }
        }
    }

    /* inputs */
    for (i=0;i<jmi->n_real_u;i++) {
        u[i*(jmi_opt_coll->n_e*nlp->n_cp+1)] =u_0(jmi_opt_coll,i);
    }
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_u;k++) {
                u[k*(jmi_opt_coll->n_e*nlp->n_cp+1) + i*nlp->n_cp + j + 1] =
                    u_coll(jmi_opt_coll,i,j+1,k);
            }
        }
    }

    /* algebraics */
    for (i=0;i<jmi->n_real_w;i++) {
        w[i*(jmi_opt_coll->n_e*nlp->n_cp+1)] = w_0(jmi_opt_coll,i);
    }
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            for (k=0;k<jmi->n_real_w;k++) {
                w[k*(jmi_opt_coll->n_e*nlp->n_cp+1) + i*nlp->n_cp + j + 1] =
                    w_coll(jmi_opt_coll,i,j+1,k);
            }
        }
    }

    return 0;
}

static int lp_radau_get_result_mesh_interpolation(jmi_opt_coll_t *jmi_opt_coll,
        jmi_real_t *mesh, int n_mesh, jmi_real_t *p_opt_,
        jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
        jmi_real_t *w) {
    int* t_e;
    jmi_real_t* t_tau;
    jmi_real_t ti;
    jmi_real_t mesh_norm;
    jmi_real_t el_length;
    
    /* Compute element indices and taus
     Compute elements and taus of time points */
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;
    int i,j,k,l;

    /* optimization parameters */
    for (i=0;i<jmi->opt->n_p_opt;i++) {
        p_opt_[i] = p_opt(jmi_opt_coll,i);
    }

    t_e = (int*)calloc(n_mesh,sizeof(int));
    t_tau = (jmi_real_t*)calloc(n_mesh,sizeof(jmi_real_t));

    ti = 0;
    mesh_norm = 0;
    for (i=0;i<n_mesh;i++) {
        t[i] = mesh[i];
        ti = 0;
        if (mesh[i]<=jmi->opt->start_time) {
            mesh_norm = 0.;
        } else if (mesh[i]>=jmi->opt->final_time) {
            mesh_norm = 1.;
        } else {
            mesh_norm = mesh[i]/(jmi->opt->final_time-jmi->opt->start_time);
        }
        for (j=0;j<jmi_opt_coll->n_e;j++) {
            ti += jmi_opt_coll->hs[j];
            if (mesh_norm<=ti) {
                t_e[i] = j;
                t_tau[i] = (mesh_norm - (ti - jmi_opt_coll->hs[j]))/(jmi_opt_coll->hs[j]);
                break;
            }
            t_e[i] = jmi_opt_coll->n_e-1;
            t_tau[i] = 1.0;
        }
    }

    /* Loop over all the time points */
    for (i=0;i<n_mesh;i++) {
        /* Compute element length, taking into account if the initial or
         terminal time, or the element lengths are free. */
        if (jmi->opt->final_time_free == 0 &&
                jmi->opt->start_time_free == 0 &&
                jmi_opt_coll->hs_free ==0) {
            el_length = jmi_opt_coll->hs[t_e[i]]*(jmi->opt->final_time - jmi->opt->start_time);
        } else { /* TODO: Take care of the other cases */
            el_length=0;
        }

        /* Interpolation equations for dx */
        for (k=0;k<jmi->n_real_dx;k++) {
            dx[i+k*n_mesh] = 0;
            for (l=0;l<nlp->n_cp+1;l++) {
                dx[i+k*n_mesh] += jmi_opt_coll_radau_eval_pol(t_tau[i],nlp->n_cp+1, nlp->Lpp_dot_coeffs, l)*
                    x_coll(jmi_opt_coll,t_e[i],l,k)/el_length;
            }
        }

        /* Interpolation equations for x */
        for (k=0;k<jmi->n_real_x;k++) {
            x[i+k*n_mesh] = 0;
            for (l=0;l<nlp->n_cp+1;l++) {
                x[i+k*n_mesh] += jmi_opt_coll_radau_eval_pol(t_tau[i],nlp->n_cp+1, nlp->Lpp_coeffs, l)*
                    x_coll(jmi_opt_coll,t_e[i],l,k);
            }
        }

        /* Interpolation equations for u */
        for (k=0;k<jmi->n_real_u;k++) {
            u[i+k*n_mesh] = 0;
            for (l=0;l<nlp->n_cp;l++) {
                u[i+k*n_mesh] += jmi_opt_coll_radau_eval_pol(t_tau[i],nlp->n_cp, nlp->Lp_coeffs, l)*
                    u_coll(jmi_opt_coll,t_e[i],l+1,k);
            }
        }

        /* Interpolation equations for w */
        for (k=0;k<jmi->n_real_w;k++) {
            w[i+k*n_mesh] = 0;
            for (l=0;l<nlp->n_cp;l++) {
                w[i+k*n_mesh] += jmi_opt_coll_radau_eval_pol(t_tau[i],nlp->n_cp, nlp->Lp_coeffs, l)*
                    w_coll(jmi_opt_coll,t_e[i],l+1,k);
            }
        }
    }

    free(t_e);
    free(t_tau);

    return 0;
}

static int lp_radau_get_result_element_interpolation(jmi_opt_coll_t *jmi_opt_coll,
        int n_interpolation_points, jmi_real_t *p_opt_,
        jmi_real_t *t, jmi_real_t *dx, jmi_real_t *x, jmi_real_t *u,
        jmi_real_t *w) {

    int i,j,k,l;
    int t_index;
    jmi_real_t el_length;
    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;

    /* Create time vector */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<n_interpolation_points;j++) {
            jmi_real_t tt = jmi->opt->start_time;
            for (k=0;k<i;k++) {
                tt += jmi_opt_coll->hs[k]*(jmi->opt->final_time-jmi->opt->start_time);
            }
            tt += ((jmi_real_t)j)/(((jmi_real_t)n_interpolation_points)-1.)*
                jmi_opt_coll->hs[i]*(jmi->opt->final_time-jmi->opt->start_time);
            t[i*n_interpolation_points + j] = tt;
        }
    }

    /* optimization parameters */
    for (i=0;i<jmi->opt->n_p_opt;i++) {
        p_opt_[i] = p_opt(jmi_opt_coll,i);
    }

    t_index = 0;
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        if (jmi->opt->final_time_free == 0 &&
                jmi->opt->start_time_free == 0 &&
                jmi_opt_coll->hs_free ==0) {
            el_length = jmi_opt_coll->hs[i]*(jmi->opt->final_time - jmi->opt->start_time);
        } else { /* TODO: Take care of the other cases */
            el_length=0;
        }

        for (j=0;j<n_interpolation_points;j++) {

            /* Loop over derivatives */
            for (k=0;k<jmi->n_real_dx;k++) {
                dx[k*(jmi_opt_coll->n_e*n_interpolation_points) +
                   i*n_interpolation_points + j] = 0;
                for (l=0;l<nlp->n_cp+1;l++) {
                    dx[k*(jmi_opt_coll->n_e*n_interpolation_points) +
                           i*n_interpolation_points + j] +=
                        jmi_opt_coll_radau_eval_pol(((jmi_real_t)j)/((jmi_real_t)n_interpolation_points-1),nlp->n_cp+1, nlp->Lpp_dot_coeffs, l)*
                        x_coll(jmi_opt_coll,i,l,k)/el_length;
                }
            }

            /* Loop over states */
            for (k=0;k<jmi->n_real_x;k++) {
                x[k*(jmi_opt_coll->n_e*n_interpolation_points) +
                   i*n_interpolation_points + j] = 0;

                for (l=0;l<nlp->n_cp+1;l++) {
                    x[k*(jmi_opt_coll->n_e*n_interpolation_points) +
                           i*n_interpolation_points + j] +=
                        jmi_opt_coll_radau_eval_pol(((jmi_real_t)j)/((jmi_real_t)n_interpolation_points-1),nlp->n_cp+1, nlp->Lpp_coeffs, l)*
                        x_coll(jmi_opt_coll,i,l,k);
                }
            }

            /*Loop over inputs */
            for (k=0;k<jmi->n_real_u;k++) {
                u[k*(jmi_opt_coll->n_e*n_interpolation_points) +
                   i*n_interpolation_points + j] = 0;
                for (l=0;l<nlp->n_cp;l++) {
                    u[k*(jmi_opt_coll->n_e*n_interpolation_points) +
                           i*n_interpolation_points + j] +=
                        jmi_opt_coll_radau_eval_pol(((jmi_real_t)j)/((jmi_real_t)n_interpolation_points-1),nlp->n_cp, nlp->Lp_coeffs, l)*
                        u_coll(jmi_opt_coll,i,l+1,k);
                }
            }

            /* Loop over algebraics */
            for (k=0;k<jmi->n_real_w;k++) {
                w[k*(jmi_opt_coll->n_e*n_interpolation_points) +
                   i*n_interpolation_points + j] = 0;
                for (l=0;l<nlp->n_cp;l++) {
                    w[k*(jmi_opt_coll->n_e*n_interpolation_points) +
                           i*n_interpolation_points + j] +=
                        jmi_opt_coll_radau_eval_pol(((jmi_real_t)j)/((jmi_real_t)n_interpolation_points-1),nlp->n_cp, nlp->Lp_coeffs, l)*
                        w_coll(jmi_opt_coll,i,l+1,k);
                }
            }

            t_index++;
        }
    }

    return 0;
}

static int lp_set_initial_from_trajectory(
        jmi_opt_coll_t *jmi_opt_coll,
        jmi_real_t *p_opt_init, jmi_real_t *trajectory_data_init,
        int traj_n_points, jmi_real_t *hs_init, jmi_real_t start_time_init,
        jmi_real_t final_time_init) {

    jmi_opt_coll_radau_t *nlp = (jmi_opt_coll_radau_t*)jmi_opt_coll;
    jmi_t *jmi = jmi_opt_coll->jmi;

    int i;
    int j;
    int k;
    int n_vars;
    int n_points;
    
    jmi_real_t* tp;
    jmi_real_t* vals;
    
    jmi_real_t start_time;
    int start_time_free;
    jmi_real_t final_time;
    int final_time_free;
    jmi_real_t tt;
    
    jmi_real_t* time_vec;

    int n_real_ci, n_real_cd, n_real_pi, n_real_pd, n_integer_ci, n_integer_cd, n_integer_pi, n_integer_pd,
        n_boolean_ci, n_boolean_cd, n_boolean_pi, n_boolean_pd,
        n_real_dx, n_x, n_real_u, n_real_w, n_tp,
        n_real_d,n_integer_d,n_integer_u,n_boolean_d,n_boolean_u,n_outputs,n_sw, n_sw_init, n_z,
        n_guards, n_guards_init;

    jmi_get_sizes(jmi, &n_real_ci, &n_real_cd, &n_real_pi, &n_real_pd,
            &n_integer_ci, &n_integer_cd, &n_integer_pi, &n_integer_pd,
            &n_boolean_ci, &n_boolean_cd, &n_boolean_pi, &n_boolean_pd,
            &n_real_dx, &n_x, &n_real_u, &n_real_w, &n_tp,
            &n_real_d,&n_integer_d,&n_integer_u,&n_boolean_d,&n_boolean_u,
            &n_outputs, &n_sw, &n_sw_init, &n_guards, &n_guards_init, &n_z);

    tp = (jmi_real_t*)calloc(n_tp,sizeof(jmi_real_t));
    jmi_get_tp(jmi,tp);

    n_vars = n_real_dx + n_x + n_real_u + n_real_w;
    jmi_opt_coll_get_result_variable_vector_length(jmi_opt_coll, &n_points);
    vals = (jmi_real_t*)calloc(n_vars,sizeof(jmi_real_t));

    jmi_opt_get_optimization_interval(jmi, &start_time, &start_time_free,
                                          &final_time, &final_time_free);

    tt = start_time;

    /* Create a collocation point vector */
    /*TODO: Take into account the situation when initial and final times are free. */
    time_vec =(jmi_real_t*)calloc(jmi_opt_coll->n_e*(nlp->n_cp),
            sizeof(jmi_real_t));

    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            time_vec[i*nlp->n_cp + j] = tt + nlp->cp[j]*jmi_opt_coll->hs[i]*
            (final_time - start_time);
        }
        tt += jmi_opt_coll->hs[i]*(final_time - start_time);
    }

    /* Initialize the optimization parameters */
    for (i=0;i<jmi_opt_coll->jmi->opt->n_p_opt;i++) {
        jmi_opt_coll->x_init[i] = p_opt_init[i];
    }

    /* Initialize the initial point */
    jmi_lin_interpolate(jmi_opt_coll->jmi->opt->start_time,
                    trajectory_data_init,traj_n_points,n_vars+1,jmi_opt_coll->x_init+
                    jmi->opt->n_p_opt);

    /* Loop over the collocation points, interpolate in input tables. */

    for (i=0;i<jmi_opt_coll->n_e;i++) {
        for (j=0;j<nlp->n_cp;j++) {
            if (jmi_opt_coll->n_blocking_factors==0) {
                jmi_lin_interpolate(time_vec[i*nlp->n_cp + j],
                                        trajectory_data_init,traj_n_points,n_vars+1,
                                        jmi_opt_coll->x_init + jmi->opt->n_p_opt +
                                        n_vars*(1 + i*nlp->n_cp + j));
            } else {
                jmi_lin_interpolate(time_vec[i*nlp->n_cp + j],
                                        trajectory_data_init,traj_n_points,n_vars+1,
                                        vals);
                /* dx */
                for (k=0;k<jmi->n_real_dx;k++) {
                    int offs_dx = offs_dx_coll(jmi_opt_coll,i,j+1,k);
                    /*printf("dx: %d, %d, %d: %d\n",i,j,k,offs_dx); */
                    jmi_opt_coll->x_init[offs_dx] = vals[k];
                }
                /* x */
                for (k=0;k<jmi->n_real_x;k++) {
                    int offs_x = offs_x_coll(jmi_opt_coll,i,j+1,k);
                    /*printf("x: %d, %d, %d: %d\n",i,j,k,offs_x); */
                    jmi_opt_coll->x_init[offs_x] = vals[jmi->n_real_dx + k];
                }
                /* u */
                if (j==0) {
                    for (k=0;k<jmi->n_real_u;k++) {
                        int offs_u = offs_u_coll(jmi_opt_coll,i,j+1,k);
                        /*printf("x: %d, %d, %d: %d\n",i,j,k,offs_u); */
                        jmi_opt_coll->x_init[offs_u] = vals[jmi->n_real_dx + jmi->n_real_x + k];
                    }
                }
                /* w */
                for (k=0;k<jmi->n_real_w;k++) {
                    int offs_w = offs_w_coll(jmi_opt_coll,i,j+1,k);
                    /*printf("x: %d, %d, %d: %d\n",i,j,k,offs_w); */
                    jmi_opt_coll->x_init[offs_w] = vals[jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + k];
                }
            }
        }

    }

    /* Loop over element junction states */
    for (i=0;i<jmi_opt_coll->n_e;i++) {
        /*printf("-- %f\n",time_vec[(i+1)*nlp->n_cp-1]); */
        jmi_lin_interpolate(time_vec[(i+1)*nlp->n_cp-1],
                        trajectory_data_init,traj_n_points,n_vars+1,vals);
        for (j=0;j<n_x;j++) {
            jmi_opt_coll->x_init[nlp->offs_x_el_junc +
                                        jmi->n_real_x*i + j] = vals[jmi->n_real_dx + j];
        }
    }

    /* Loop over time points */
    for (i=0;i<jmi->n_tp;i++) {
        int o_dx_p = offs_dx_p(jmi_opt_coll,i,0);
        jmi_lin_interpolate(tp[i]*(jmi->opt->final_time-jmi->opt->start_time),
                        trajectory_data_init,traj_n_points,n_vars+1,
                        jmi_opt_coll->x_init +  o_dx_p);
    }

    for (i=0;i<jmi_opt_coll->n_x;i++) {
        jmi_opt_coll->x[i] = jmi_opt_coll->x_init[i];
    }

    /* TODO: take care of varying start and final time. */

    free(tp);
    free(time_vec);
    free(vals);

    return 0;
}

int jmi_opt_coll_radau_new(jmi_opt_coll_t **jmi_opt_coll, jmi_t *jmi, int n_e,
        jmi_real_t *hs, int hs_free,
        jmi_real_t *p_opt_init, jmi_real_t *dx_init, jmi_real_t *x_init,
        jmi_real_t *u_init, jmi_real_t *w_init,
        jmi_real_t *p_opt_lb, jmi_real_t *dx_lb, jmi_real_t *x_lb,
        jmi_real_t *u_lb, jmi_real_t *w_lb, jmi_real_t t0_lb,
        jmi_real_t tf_lb, jmi_real_t *hs_lb,
        jmi_real_t *p_opt_ub, jmi_real_t *dx_ub, jmi_real_t *x_ub,
        jmi_real_t *u_ub, jmi_real_t *w_ub, jmi_real_t t0_ub,
        jmi_real_t tf_ub, jmi_real_t *hs_ub,
        int linearity_information_provided,
        int* p_opt_lin, int* dx_lin, int* x_lin, int* u_lin, int* w_lin,
        int* dx_tp_lin, int* x_tp_lin, int* u_tp_lin, int* w_tp_lin,
        int n_cp, int der_eval_alg, int n_blocking_factors,
        int *blocking_factors) {
    int i, j, k, l;
    jmi_opt_coll_radau_t* opt;
    
    int dFfdp_dp_n_nz, dFfdp_dp_n_cols;
    int dF0_n_nz, dF0_n_cols;
    int dF_dp_n_nz, dF_ddx_dx_du_dw_n_nz, dF_dp_n_cols, dF_ddx_dx_du_dw_n_cols;
    int dCeq_dp_n_nz, dCeq_ddx_dx_du_dw_n_nz, dCeq_ddx_p_dx_p_du_p_dw_p_n_nz,dCeq_dp_n_cols, dCeq_ddx_dx_du_dw_n_cols, dCeq_ddx_p_dx_p_du_p_dw_p_n_cols;
    int dCineq_dp_n_nz, dCineq_ddx_dx_du_dw_n_nz, dCineq_ddx_p_dx_p_du_p_dw_p_n_nz,dCineq_dp_n_cols, dCineq_ddx_dx_du_dw_n_cols, dCineq_ddx_p_dx_p_du_p_dw_p_n_cols;
    int dHeq_dp_n_nz, dHeq_ddx_p_dx_p_du_p_dw_p_n_nz,dHeq_dp_n_cols, dHeq_ddx_p_dx_p_du_p_dw_p_n_cols;
    int dHineq_dp_n_nz, dHineq_ddx_p_dx_p_du_p_dw_p_n_nz,dHineq_dp_n_cols, dHineq_ddx_p_dx_p_du_p_dw_p_n_cols;
    
    int* dFfdp_dp_irow;
    int* dFfdp_dp_icol;

    int* dF0_irow;
    int* dF0_icol;

    int* dF_dp_irow;
    int* dF_dp_icol;

    int* dF_ddx_dx_du_dw_irow;
    int* dF_ddx_dx_du_dw_icol;

    int* dCeq_dp_irow;
    int* dCeq_dp_icol;

    int* dCeq_ddx_dx_du_dw_irow;
    int* dCeq_ddx_dx_du_dw_icol;

    int* dCeq_ddx_p_dx_p_du_p_dw_p_irow;
    int* dCeq_ddx_p_dx_p_du_p_dw_p_icol;

    int* dCineq_dp_irow;
    int* dCineq_dp_icol;

    int* dCineq_ddx_dx_du_dw_irow;
    int* dCineq_ddx_dx_du_dw_icol;

    int* dCineq_ddx_p_dx_p_du_p_dw_p_irow;
    int* dCineq_ddx_p_dx_p_du_p_dw_p_icol;

    int* dHeq_dp_irow;
    int* dHeq_dp_icol;

    int* dHeq_ddx_p_dx_p_du_p_dw_p_irow;
    int* dHeq_ddx_p_dx_p_du_p_dw_p_icol;

    int* dHineq_dp_irow;
    int* dHineq_dp_icol;

    int* dHineq_ddx_p_dx_p_du_p_dw_p_irow;
    int* dHineq_ddx_p_dx_p_du_p_dw_p_icol;
    
    int row_index;
    int col_index;
    int rc_ind;
    int el_ind;
    
    if (jmi->opt == NULL) {
        return -1;
    }

    opt = (jmi_opt_coll_radau_t*)calloc(1,sizeof(jmi_opt_coll_radau_t));
    *jmi_opt_coll = (jmi_opt_coll_t*)opt;

    (*jmi_opt_coll)->jmi = jmi;

    /* Allocate memory for the du_weights */
    opt->du_weights = (jmi_real_t*)calloc(jmi->n_real_u,sizeof(jmi_real_t));

    for (i=0;i<jmi->n_real_u;i++) {
        opt->du_weights[i] = 0.;
    }

    /* Compute elements and taus of time points */
    (*jmi_opt_coll)->tp_e = (int*)calloc(jmi->n_tp,sizeof(int));
    (*jmi_opt_coll)->tp_tau = (jmi_real_t*)calloc(jmi->n_tp,sizeof(jmi_real_t));

    for (i=0;i<jmi->n_tp;i++) {
        jmi_real_t ti = 0;
        for (j=0;j<n_e;j++) {
            ti += hs[j];
            /*printf("%f %f %f\n", ti, hs[j], jmi->tp[i]); */
            if (jmi->tp[i]<=ti) {
                (*jmi_opt_coll)->tp_e[i] = j;
                (*jmi_opt_coll)->tp_tau[i] = (jmi->tp[i] - (ti - hs[j]))/
                (hs[j]);
                break;
            }
            (*jmi_opt_coll)->tp_e[i] = n_e-1;
            (*jmi_opt_coll)->tp_tau[i] = 1.0;
        }
    }
/*
    for (i=0;i<jmi->n_tp;i++) {
        printf("%d, %d, %f\n",i,(*jmi_opt_coll)->tp_e[i],(*jmi_opt_coll)->tp_tau[i]);
    }
*/
    /* Set blocking factors
     Normalize blocking factors vector so that sum(blocking_factors(i)) = n_e */

    /* Sum input blocking_factors */
    if (n_blocking_factors>0) {
        int n_b_f_input = 0;
        int max_b_f_index = 0;
        while (n_b_f_input + blocking_factors[max_b_f_index] < n_e &&
                max_b_f_index + 1 < n_blocking_factors) {
            n_b_f_input += blocking_factors[max_b_f_index];
            max_b_f_index++;
        }

        (*jmi_opt_coll)->blocking_factors = (int*)calloc(max_b_f_index + 1,sizeof(int));
        (*jmi_opt_coll)->n_blocking_factors = max_b_f_index + 1;
        for (i=0;i<(*jmi_opt_coll)->n_blocking_factors - 1;i++) {
            (*jmi_opt_coll)->blocking_factors[i] = blocking_factors[i];
        }
        (*jmi_opt_coll)->blocking_factors[(*jmi_opt_coll)->n_blocking_factors - 1] =
            n_e - n_b_f_input;

        /*printf("n_blocking_factors: %d\n",(*jmi_opt_coll)->n_blocking_factors); */
        (*jmi_opt_coll)->n_blocking_factor_constraints = 0;
        for (i=0;i<(*jmi_opt_coll)->n_blocking_factors;i++) {
            (*jmi_opt_coll)->n_blocking_factor_constraints +=
                (*jmi_opt_coll)->blocking_factors[i] - 1;
            /*printf("%d, %d\n",i,(*jmi_opt_coll)->blocking_factors[i]); */
        }
        /*printf("n_blocking_factor_constraints: %d\n",(*jmi_opt_coll)->n_blocking_factor_constraints); */

    } else {
        (*jmi_opt_coll)->blocking_factors = (int*)calloc(n_blocking_factors,sizeof(int));
        (*jmi_opt_coll)->n_blocking_factors = n_blocking_factors;
    }

    (*jmi_opt_coll)->n_e = n_e;

    /* Compute offsets */
    opt->offs_p_opt = 0;
    opt->offs_dx_0 = jmi->opt->n_p_opt;
    opt->offs_x_0 = opt->offs_dx_0 + jmi->n_real_dx;
    opt->offs_u_0 = opt->offs_x_0 + jmi->n_real_x;
    opt->offs_w_0 = opt->offs_u_0 + jmi->n_real_u;
    opt->offs_dx_coll = opt->offs_w_0 + jmi->n_real_w;
    opt->offs_x_coll= opt->offs_dx_coll + jmi->n_real_dx;
    opt->offs_u_coll = opt->offs_x_coll + jmi->n_real_x;
    opt->offs_w_coll = opt->offs_u_coll + jmi->n_real_u;
    opt->offs_x_el_junc = opt->offs_dx_coll +
    (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*(n_e)*n_cp +
    ((*jmi_opt_coll)->n_blocking_factors>0? jmi->n_real_u*n_e: jmi->n_real_u*n_e*n_cp);
    opt->offs_dx_p = opt->offs_x_el_junc + n_e*jmi->n_real_x;
    opt->offs_x_p = opt->offs_dx_p + jmi->n_real_dx;
    opt->offs_u_p = opt->offs_x_p + jmi->n_real_x;
    opt->offs_w_p = opt->offs_u_p + jmi->n_real_u;
    opt->offs_h = opt->offs_w_p + jmi->n_real_w;

    if (hs_free == 1) {
        opt->offs_t0 = opt->offs_h + n_e;
    } else {
        opt->offs_t0 = opt->offs_h;
    }

    if (jmi->opt->start_time_free == 1) {
        opt->offs_tf = opt->offs_h + 1;
    } else {
        opt->offs_tf = opt->offs_h;
    }

    opt->der_eval_alg = der_eval_alg;

    /* Compute Radau points and Lagrange polynomials */
    opt->n_cp = n_cp;
    opt->cp = (jmi_real_t*)calloc(n_cp,sizeof(jmi_real_t));
    opt->w = (jmi_real_t*)calloc(n_cp,sizeof(jmi_real_t));
    opt->cpp = (jmi_real_t*)calloc(n_cp+1,sizeof(jmi_real_t));
    opt->Lp_coeffs = (jmi_real_t*)malloc(sizeof(jmi_real_t)*n_cp*n_cp);
    opt->Lpp_coeffs = (jmi_real_t*)malloc(sizeof(jmi_real_t)*(n_cp+1)*(n_cp+1));
    opt->Lp_dot_coeffs = (jmi_real_t*)malloc(sizeof(jmi_real_t)*n_cp*n_cp);
    opt->Lpp_dot_coeffs = (jmi_real_t*)malloc(sizeof(jmi_real_t)*(n_cp+1)*(n_cp+1));
    opt->Lp_dot_vals = (jmi_real_t*)malloc(sizeof(jmi_real_t)*n_cp*n_cp);
    opt->Lpp_dot_vals = (jmi_real_t*)malloc(sizeof(jmi_real_t)*(n_cp+1)*(n_cp+1));

    jmi_opt_coll_radau_get_pols(n_cp, opt->cp, opt->w,opt->cpp, opt->Lp_coeffs,
            opt->Lpp_coeffs, opt->Lp_dot_coeffs,
            opt->Lpp_dot_coeffs, opt->Lp_dot_vals, opt->Lpp_dot_vals);

    /* Compute vector sizes */
    (*jmi_opt_coll)->n_x = jmi->opt->n_p_opt +                                   /* Number of parameters to be optimized */
    (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_w)*(n_e*n_cp + 1) +   /* Collocation variables + initial variables */
    ((*jmi_opt_coll)->n_blocking_factors>0? jmi->n_real_u*(n_e+1): jmi->n_real_u*(n_e*n_cp +1)) +
    jmi->n_real_x*n_e +                                        /* States at element junctions */
    (jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u + jmi->n_real_w)*jmi->n_tp;         /* Pointwise values */

    /* Free element lengths */
    if (hs_free == 1) {
        (*jmi_opt_coll)->n_x += n_e;
    }

    /* Free start time */
    if (jmi->opt->start_time_free == 1) {
        (*jmi_opt_coll)->n_x += 1;
    }

    /* Free final time */
    if (jmi->opt->final_time_free == 1) {
        (*jmi_opt_coll)->n_x += 1;
    }

    /* Number of equality constraints */
    (*jmi_opt_coll)->n_h = jmi->opt->Ffdp->n_eq_F +                                    /* Free dependent parameters */
        jmi->init->F0->n_eq_F +                                                    /* Initial equations */
    jmi->dae->F->n_eq_F*n_e*n_cp +                                                     /* Residual equations */
    jmi->n_real_x*n_e +                                                                /* Continuity equations */
    jmi->n_real_x*n_e*n_cp +                                                           /* Collocation equations */
    jmi->n_real_u +                                                                    /* Interpolation for u_0 */
    (jmi->n_real_dx + jmi->n_real_x  + jmi->n_real_u + jmi->n_real_w)*jmi->n_tp +      /* Pointwise equations */
    jmi->opt->Ceq->n_eq_F*(n_e*n_cp + 1) +                                             /* Path constraints from optimization */
    jmi->opt->Heq->n_eq_F +                                                            /* Point constraints from optimization */
    (*jmi_opt_coll)->n_blocking_factor_constraints*jmi->n_real_u;                          /* Number of blocking factor constraints */

    /* if free element lengths:
     TODO: should be modeled explicitly in the Optimica code?
     Add constraint sum(hs) = 1 */
    if (hs_free == 1) {
        (*jmi_opt_coll)->n_h += 1;
    }

    /* Number of inequality constraints */

    (*jmi_opt_coll)->n_g = jmi->opt->Cineq->n_eq_F*(n_e*n_cp + 1) +               /* Path inconstraints from optimization */
    jmi->opt->Hineq->n_eq_F;                                                      /* Point inconstraints from optimization */

    /* Allocate vectors */
    (*jmi_opt_coll)->hs = (jmi_real_t*)calloc(n_e,sizeof(jmi_real_t));
    (*jmi_opt_coll)->x = (jmi_real_t*)calloc((*jmi_opt_coll)->n_x,sizeof(jmi_real_t));
    (*jmi_opt_coll)->x_lb = (jmi_real_t*)calloc((*jmi_opt_coll)->n_x,sizeof(jmi_real_t));
    (*jmi_opt_coll)->x_ub = (jmi_real_t*)calloc((*jmi_opt_coll)->n_x,sizeof(jmi_real_t));
    (*jmi_opt_coll)->x_init = (jmi_real_t*)calloc((*jmi_opt_coll)->n_x,sizeof(jmi_real_t));

    /*Compute sparsity patters for dg and dh
     Mask for derivative evaluation */
    opt->der_mask = (int*)calloc(jmi->n_z,sizeof(int));
    for (i=0;i<jmi->n_z;i++) {
        opt->der_mask[i] = 1;
    }
    for (i=0;i<jmi->offs_real_dx;i++) {
        opt->der_mask[i] = 0;
    }

    for (i=0;i<jmi->opt->n_p_opt;i++) {
        opt->der_mask[jmi->offs_real_pi + jmi->opt->p_opt_indices[i]] = 1;
    }

    jmi_opt_dFfdp_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD, opt->der_mask,
            &dFfdp_dp_n_cols, &dFfdp_dp_n_nz);
    opt->dFfdp_dp_n_nz = dFfdp_dp_n_nz;

    jmi_init_dF0_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD | JMI_DER_DX | JMI_DER_X |
            JMI_DER_U | JMI_DER_W, opt->der_mask,
            &dF0_n_cols, &dF0_n_nz);
    opt->dF0_n_nz = dF0_n_nz;

    jmi_dae_dF_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD, opt->der_mask,
            &dF_dp_n_cols, &dF_dp_n_nz);

    jmi_dae_dF_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX | JMI_DER_X | JMI_DER_U |JMI_DER_W,
            opt->der_mask, &dF_ddx_dx_du_dw_n_cols,
            &dF_ddx_dx_du_dw_n_nz);
    opt->dF_dp_n_nz = dF_dp_n_nz;
    opt->dF_ddx_dx_du_dw_n_nz = dF_ddx_dx_du_dw_n_nz;

    jmi_opt_dCeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD, opt->der_mask,
            &dCeq_dp_n_cols, &dCeq_dp_n_nz);
    jmi_opt_dCeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
            opt->der_mask, &dCeq_ddx_dx_du_dw_n_cols, &dCeq_ddx_dx_du_dw_n_nz);
    jmi_opt_dCeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
            opt->der_mask, &dCeq_ddx_p_dx_p_du_p_dw_p_n_cols, &dCeq_ddx_p_dx_p_du_p_dw_p_n_nz);
    opt->dCeq_dp_n_nz = dCeq_dp_n_nz;
    opt->dCeq_ddx_dx_du_dw_n_nz = dCeq_ddx_dx_du_dw_n_nz;
    opt->dCeq_ddx_p_dx_p_du_p_dw_p_n_nz = dCeq_ddx_p_dx_p_du_p_dw_p_n_nz;

    jmi_opt_dCineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD, opt->der_mask,
            &dCineq_dp_n_cols, &dCineq_dp_n_nz);
    jmi_opt_dCineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX | JMI_DER_X | JMI_DER_U | JMI_DER_W,
            opt->der_mask, &dCineq_ddx_dx_du_dw_n_cols, &dCineq_ddx_dx_du_dw_n_nz);
    jmi_opt_dCineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
            opt->der_mask, &dCineq_ddx_p_dx_p_du_p_dw_p_n_cols, &dCineq_ddx_p_dx_p_du_p_dw_p_n_nz);
    opt->dCineq_dp_n_nz = dCineq_dp_n_nz;
    opt->dCineq_ddx_dx_du_dw_n_nz = dCineq_ddx_dx_du_dw_n_nz;
    opt->dCineq_ddx_p_dx_p_du_p_dw_p_n_nz = dCineq_ddx_p_dx_p_du_p_dw_p_n_nz;

    jmi_opt_dHeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD, opt->der_mask,
            &dHeq_dp_n_cols, &dHeq_dp_n_nz);
    jmi_opt_dHeq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
            opt->der_mask, &dHeq_ddx_p_dx_p_du_p_dw_p_n_cols, &dHeq_ddx_p_dx_p_du_p_dw_p_n_nz);
    opt->dHeq_dp_n_nz = dHeq_dp_n_nz;
    opt->dHeq_ddx_p_dx_p_du_p_dw_p_n_nz = dHeq_ddx_p_dx_p_du_p_dw_p_n_nz;

    jmi_opt_dHineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_PI | JMI_DER_PD, opt->der_mask,
            &dHineq_dp_n_cols, &dHineq_dp_n_nz);
    jmi_opt_dHineq_dim(jmi, opt->der_eval_alg, JMI_DER_SPARSE,
            JMI_DER_DX_P | JMI_DER_X_P | JMI_DER_U_P | JMI_DER_W_P,
            opt->der_mask, &dHineq_ddx_p_dx_p_du_p_dw_p_n_cols, &dHineq_ddx_p_dx_p_du_p_dw_p_n_nz);
    opt->dHineq_dp_n_nz = dHineq_dp_n_nz;
    opt->dHineq_ddx_p_dx_p_du_p_dw_p_n_nz = dHineq_ddx_p_dx_p_du_p_dw_p_n_nz;

    (*jmi_opt_coll)->dg_n_nz = (dCineq_dp_n_nz + dCineq_ddx_dx_du_dw_n_nz +
            dCineq_ddx_p_dx_p_du_p_dw_p_n_nz)*(n_e*n_cp+1) +                             /*  Inequality path constraints */
            (dHineq_dp_n_nz + dHineq_ddx_p_dx_p_du_p_dw_p_n_nz);                         /* Inequality point constraints */
            (*jmi_opt_coll)->dg_row = (int*)calloc((*jmi_opt_coll)->dg_n_nz,sizeof(int));
            (*jmi_opt_coll)->dg_col = (int*)calloc((*jmi_opt_coll)->dg_n_nz,sizeof(int));

            (*jmi_opt_coll)->dh_n_nz =  dFfdp_dp_n_nz +                                  /* Free dependent parameters */
                                       dF0_n_nz +                                    /* Initial equations */
            (dF_dp_n_nz + dF_ddx_dx_du_dw_n_nz)*n_e*n_cp +                               /* Dynamic residuals */
            2*jmi->n_real_x*n_e +                                                        /* Continuity equations */
            (((*jmi_opt_coll)->n_blocking_factors>0)? 2*jmi->n_real_u: jmi->n_real_u*(n_cp + 1))  + /* Interpolation of u_0 */
            (jmi->n_real_x*(n_cp+1) + jmi->n_real_dx)*n_e*n_cp +                                    /* Collocation equations */
            ((jmi->n_real_x+jmi->n_real_dx)*(n_cp+1) +jmi->n_real_x + jmi->n_real_dx+               /* Time points */
                    (((*jmi_opt_coll)->n_blocking_factors>0)? 2*jmi->n_real_u: jmi->n_real_u*(n_cp + 1)) +
                    jmi->n_real_w*(n_cp+1))*jmi->n_tp +
                    (dCeq_dp_n_nz + dCeq_ddx_dx_du_dw_n_nz +                                /* Equality path constraints */
                            dCeq_ddx_p_dx_p_du_p_dw_p_n_nz)*(n_e*n_cp+1) +
                            (dHeq_dp_n_nz + dHeq_ddx_p_dx_p_du_p_dw_p_n_nz) +       /* Equality point constraints */
            2*((*jmi_opt_coll)->n_blocking_factor_constraints)*jmi->n_real_u;
            (*jmi_opt_coll)->dh_row = (int*)calloc((*jmi_opt_coll)->dh_n_nz,sizeof(int));
            (*jmi_opt_coll)->dh_col = (int*)calloc((*jmi_opt_coll)->dh_n_nz,sizeof(int));

            /*  printf("%x\n",(int)(*jmi_opt_coll)->dh_row); */

            dFfdp_dp_irow = (int*)calloc(dFfdp_dp_n_nz,sizeof(int));
            dFfdp_dp_icol = (int*)calloc(dFfdp_dp_n_nz,sizeof(int));
            jmi_opt_dFfdp_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_PI | JMI_DER_PD, opt->der_mask, dFfdp_dp_irow,dFfdp_dp_icol);

            dF0_irow = (int*)calloc(dF0_n_nz,sizeof(int));
            dF0_icol = (int*)calloc(dF0_n_nz,sizeof(int));
            jmi_init_dF0_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_PI | JMI_DER_PD | JMI_DER_DX | JMI_DER_X |
                    JMI_DER_U | JMI_DER_W, opt->der_mask, dF0_irow,dF0_icol);

            dF_dp_irow = (int*)calloc(dF_dp_n_nz,sizeof(int));
            dF_dp_icol = (int*)calloc(dF_dp_n_nz,sizeof(int));
            jmi_dae_dF_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_PI | JMI_DER_PD, opt->der_mask, dF_dp_irow,dF_dp_icol);

            dF_ddx_dx_du_dw_irow = (int*)calloc(dF_ddx_dx_du_dw_n_nz,sizeof(int));
            dF_ddx_dx_du_dw_icol = (int*)calloc(dF_ddx_dx_du_dw_n_nz,sizeof(int));
            jmi_dae_dF_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_DX | JMI_DER_X |
                    JMI_DER_U | JMI_DER_W, opt->der_mask,
                    dF_ddx_dx_du_dw_irow,dF_ddx_dx_du_dw_icol);

            dCeq_dp_irow = (int*)calloc(dCeq_dp_n_nz,sizeof(int));
            dCeq_dp_icol = (int*)calloc(dCeq_dp_n_nz,sizeof(int));
            jmi_opt_dCeq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_PI | JMI_DER_PD, opt->der_mask, dCeq_dp_irow,dCeq_dp_icol);

            dCeq_ddx_dx_du_dw_irow = (int*)calloc(dCeq_ddx_dx_du_dw_n_nz,sizeof(int));
            dCeq_ddx_dx_du_dw_icol = (int*)calloc(dCeq_ddx_dx_du_dw_n_nz,sizeof(int));
            jmi_opt_dCeq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_DX | JMI_DER_X |
                    JMI_DER_U | JMI_DER_W, opt->der_mask,
                    dCeq_ddx_dx_du_dw_irow,dCeq_ddx_dx_du_dw_icol);

            dCeq_ddx_p_dx_p_du_p_dw_p_irow = (int*)calloc(dCeq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
            dCeq_ddx_p_dx_p_du_p_dw_p_icol = (int*)calloc(dCeq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
            jmi_opt_dCeq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_DX_P | JMI_DER_X_P |
                    JMI_DER_U_P | JMI_DER_W_P, opt->der_mask,
                    dCeq_ddx_p_dx_p_du_p_dw_p_irow,dCeq_ddx_p_dx_p_du_p_dw_p_icol);

            dCineq_dp_irow = (int*)calloc(dCineq_dp_n_nz,sizeof(int));
            dCineq_dp_icol = (int*)calloc(dCineq_dp_n_nz,sizeof(int));
            jmi_opt_dCineq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_PI | JMI_DER_PD, opt->der_mask, dCineq_dp_irow,dCineq_dp_icol);

            dCineq_ddx_dx_du_dw_irow = (int*)calloc(dCineq_ddx_dx_du_dw_n_nz,sizeof(int));
            dCineq_ddx_dx_du_dw_icol = (int*)calloc(dCineq_ddx_dx_du_dw_n_nz,sizeof(int));
            jmi_opt_dCineq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_DX | JMI_DER_X |
                    JMI_DER_U | JMI_DER_W, opt->der_mask,
                    dCineq_ddx_dx_du_dw_irow,dCineq_ddx_dx_du_dw_icol);

            dCineq_ddx_p_dx_p_du_p_dw_p_irow = (int*)calloc(dCineq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
            dCineq_ddx_p_dx_p_du_p_dw_p_icol = (int*)calloc(dCineq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
            jmi_opt_dCineq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_DX_P | JMI_DER_X_P |
                    JMI_DER_U_P | JMI_DER_W_P, opt->der_mask,
                    dCineq_ddx_p_dx_p_du_p_dw_p_irow,dCineq_ddx_p_dx_p_du_p_dw_p_icol);

            dHeq_dp_irow = (int*)calloc(dHeq_dp_n_nz,sizeof(int));
            dHeq_dp_icol = (int*)calloc(dHeq_dp_n_nz,sizeof(int));
            jmi_opt_dHeq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_PI | JMI_DER_PD, opt->der_mask, dHeq_dp_irow,dHeq_dp_icol);

            dHeq_ddx_p_dx_p_du_p_dw_p_irow = (int*)calloc(dHeq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
            dHeq_ddx_p_dx_p_du_p_dw_p_icol = (int*)calloc(dHeq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
            jmi_opt_dHeq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_DX_P | JMI_DER_X_P |
                    JMI_DER_U_P | JMI_DER_W_P, opt->der_mask,
                    dHeq_ddx_p_dx_p_du_p_dw_p_irow,dHeq_ddx_p_dx_p_du_p_dw_p_icol);


            dHineq_dp_irow = (int*)calloc(dHineq_dp_n_nz,sizeof(int));
            dHineq_dp_icol = (int*)calloc(dHineq_dp_n_nz,sizeof(int));
            jmi_opt_dHineq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_PI | JMI_DER_PD, opt->der_mask, dHineq_dp_irow,dHineq_dp_icol);

            dHineq_ddx_p_dx_p_du_p_dw_p_irow = (int*)calloc(dHineq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
            dHineq_ddx_p_dx_p_du_p_dw_p_icol = (int*)calloc(dHineq_ddx_p_dx_p_du_p_dw_p_n_nz,sizeof(int));
            jmi_opt_dHineq_nz_indices(jmi,opt->der_eval_alg,
                    JMI_DER_DX_P | JMI_DER_X_P |
                    JMI_DER_U_P | JMI_DER_W_P, opt->der_mask,
                    dHineq_ddx_p_dx_p_du_p_dw_p_irow,dHineq_ddx_p_dx_p_du_p_dw_p_icol);
/*

            for (i=0;i<dF0_n_nz;i++) {
                printf("> %d, %d\n", dF0_irow[i], dF0_icol[i]);
            }
            for (i=0;i<dF_dp_n_nz;i++) {
                printf(">> %d, %d\n", dF_dp_irow[i], dF_dp_icol[i]);
            }
            for (i=0;i<dF_ddx_dx_du_dw_n_nz;i++) {
                printf(">>> %d, %d\n", dF_ddx_dx_du_dw_irow[i], dF_ddx_dx_du_dw_icol[i]);
            }

            for (i=0;i<dCeq_ddx_dx_du_dw_n_nz;i++) {
                printf(">>>>Ceq %d, %d\n", dCeq_ddx_dx_du_dw_irow[i], dCeq_ddx_dx_du_dw_icol[i]);
            }

            for (i=0;i<dCineq_ddx_dx_du_dw_n_nz;i++) {
                printf(">>>>Cineq %d, %d\n", dCineq_ddx_dx_du_dw_irow[i], dCineq_ddx_dx_du_dw_icol[i]);
            }

            for (i=0;i<dCeq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
                printf(">>>>Ceq_p %d, %d\n", dCeq_ddx_p_dx_p_du_p_dw_p_irow[i], dCeq_ddx_p_dx_p_du_p_dw_p_icol[i]);
            }

            for (i=0;i<dCineq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
                printf(">>>>Cineq_p %d, %d\n", dCineq_ddx_p_dx_p_du_p_dw_p_irow[i], dCineq_ddx_p_dx_p_du_p_dw_p_icol[i]);
            }

            for (i=0;i<dHeq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
                printf(">>>>Heq_p %d, %d\n", dHeq_ddx_p_dx_p_du_p_dw_p_irow[i], dHeq_ddx_p_dx_p_du_p_dw_p_icol[i]);
            }

            for (i=0;i<dHineq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
                printf(">>>>Hineq_p %d, %d\n", dHineq_ddx_p_dx_p_du_p_dw_p_irow[i], dHineq_ddx_p_dx_p_du_p_dw_p_icol[i]);
            }
*/

            /***********************************************
             * Sparsity for inequality constraint Jacobian
             ***********************************************/
            row_index = 0;
            col_index = 0;
            rc_ind = 0;
            /* Sparsity indices for dCineq: variables at initial time
             Parameters */
            for (i=0;i<dCineq_dp_n_nz;i++) {
                (*jmi_opt_coll)->dg_row[rc_ind] = dCineq_dp_irow[i] + row_index;
                (*jmi_opt_coll)->dg_col[rc_ind] = dCineq_dp_icol[i] + col_index;
                rc_ind++;
            }

            /* Variables at collocation points */
            col_index = opt->offs_dx_0;
            for (i=0;i<dCineq_ddx_dx_du_dw_n_nz;i++) {
                (*jmi_opt_coll)->dg_row[rc_ind] = dCineq_ddx_dx_du_dw_irow[i] + row_index;
                (*jmi_opt_coll)->dg_col[rc_ind] = dCineq_ddx_dx_du_dw_icol[i] + col_index;
                rc_ind++;
            }

            /* Variables at interpolation points */
            col_index = opt->offs_dx_p;
            for (i=0;i<dCineq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
                (*jmi_opt_coll)->dg_row[rc_ind] = dCineq_ddx_p_dx_p_du_p_dw_p_irow[i] + row_index;
                (*jmi_opt_coll)->dg_col[rc_ind] = dCineq_ddx_p_dx_p_du_p_dw_p_icol[i] + col_index;
                rc_ind++;
            }

            /* Sparsity for dCineq: collocation equations */
            for (i=0;i<n_e;i++) {
                for (j=0;j<n_cp;j++) {
                    row_index = jmi->opt->Cineq->n_eq_F + jmi->opt->Cineq->n_eq_F*(i*n_cp + j);
                    col_index = 0;
                    for (k=0;k<dCineq_dp_n_nz;k++) {
                        (*jmi_opt_coll)->dg_row[rc_ind] = dCineq_dp_irow[k] + row_index;
                        (*jmi_opt_coll)->dg_col[rc_ind] = dCineq_dp_icol[k] + col_index;
                        rc_ind++;
                    }

                    col_index = offs_dx_coll((*jmi_opt_coll),i,j+1,0);
                    for (k=0;k<dCineq_ddx_dx_du_dw_n_nz;k++) {
/*                      printf("%d, %d, %d, %d, %d\n",i,j,k,dCineq_ddx_dx_du_dw_icol[k],rc_ind); */
                      if (((*jmi_opt_coll)->n_blocking_factors>0) &&
                           jmi_variable_type_spec(jmi, JMI_DER_DX | JMI_DER_X |
                                 JMI_DER_U | JMI_DER_W,
                                      opt->der_mask,dCineq_ddx_dx_du_dw_icol[k])==JMI_DER_U) {
                        (*jmi_opt_coll)->dg_row[rc_ind] = dCineq_ddx_dx_du_dw_irow[k] + row_index;
                        (*jmi_opt_coll)->dg_col[rc_ind] = dCineq_ddx_dx_du_dw_icol[k] +
                        col_index -
                          j*dCineq_ddx_dx_du_dw_n_cols + (j>1? (j-1)*(jmi->n_real_u): 0);
                      } else {
                        (*jmi_opt_coll)->dg_row[rc_ind] = dCineq_ddx_dx_du_dw_irow[k] + row_index;
                        (*jmi_opt_coll)->dg_col[rc_ind] = dCineq_ddx_dx_du_dw_icol[k] + col_index;
                      }
                        rc_ind++;
                    }

                    col_index = opt->offs_dx_p;
                    for (k=0;k<dCineq_ddx_p_dx_p_du_p_dw_p_n_nz;k++) {
                        (*jmi_opt_coll)->dg_row[rc_ind] = dCineq_ddx_p_dx_p_du_p_dw_p_irow[k] + row_index;
                        (*jmi_opt_coll)->dg_col[rc_ind] = dCineq_ddx_p_dx_p_du_p_dw_p_icol[k] + col_index;
                        rc_ind++;
                    }
                }
            }

            /* Sparsity for Hineq */
            row_index = jmi->opt->Cineq->n_eq_F*(n_e*n_cp + 1);
            col_index = 0;
            /* Parameters */
            for (j=0;j<dHineq_dp_n_nz;j++) {
                (*jmi_opt_coll)->dg_row[rc_ind] = dHineq_dp_irow[j] + row_index;
                (*jmi_opt_coll)->dg_col[rc_ind] = dHineq_dp_icol[j] + col_index;
                rc_ind++;
            }

            /* Variables at interpolation points */
            col_index = opt->offs_dx_p;
            for (j=0;j<dHineq_ddx_p_dx_p_du_p_dw_p_n_nz;j++) {
                (*jmi_opt_coll)->dg_row[rc_ind] = dHineq_ddx_p_dx_p_du_p_dw_p_irow[j] + row_index;
                (*jmi_opt_coll)->dg_col[rc_ind] = dHineq_ddx_p_dx_p_du_p_dw_p_icol[j] + col_index;
                rc_ind++;
            }

/*
            for (i=0;i<(*jmi_opt_coll)->dg_n_nz;i++) {
                printf("dg - %d, %d\n",(*jmi_opt_coll)->dg_row[i],(*jmi_opt_coll)->dg_col[i]);
            }
*/

            /**********************************************
             * Sparsity for equality constraint Jacobian
             **********************************************/
            row_index = 0;
            col_index = 0;
            rc_ind = 0;

            /* Sparsity for free dependent parameter equations */
            for (i=0;i<dFfdp_dp_n_nz;i++) {
                row_index = dh_ffdp_eq_offs(*jmi_opt_coll,0);
                (*jmi_opt_coll)->dh_row[rc_ind] = dFfdp_dp_irow[i] + row_index;
                (*jmi_opt_coll)->dh_col[rc_ind] = dFfdp_dp_icol[i] + col_index;
                rc_ind++;
            }

            /* Sparsity indices for initialization system */
            for (i=0;i<dF0_n_nz;i++) {
                row_index = dh_init_eq_offs(*jmi_opt_coll,0);
                (*jmi_opt_coll)->dh_row[rc_ind] = dF0_irow[i] + row_index;
                (*jmi_opt_coll)->dh_col[rc_ind] = dF0_icol[i] + col_index;
                rc_ind++;
            }

            /* Sparsity for dynamic residuals */
            for (i=0;i<n_e;i++) {
              for (j=0;j<n_cp;j++) {
                row_index = dh_res_eq_offs(*jmi_opt_coll,i,j+1,0);
                col_index = 0;
                for (k=0;k<dF_dp_n_nz;k++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = dF_dp_irow[k] + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = dF_dp_icol[k] + col_index;
                    rc_ind++;
                }

                col_index = offs_dx_coll((*jmi_opt_coll),i,j+1,0);
                for (k=0;k<dF_ddx_dx_du_dw_n_nz;k++) {
                  /* Special handling of u_coll due to blocking factors */
                  if (((*jmi_opt_coll)->n_blocking_factors>0) &&
                       jmi_variable_type_spec(jmi, JMI_DER_DX | JMI_DER_X |
                             JMI_DER_U | JMI_DER_W,
                                  opt->der_mask,dF_ddx_dx_du_dw_icol[k])==JMI_DER_U) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = dF_ddx_dx_du_dw_irow[k] + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = dF_ddx_dx_du_dw_icol[k] +
                    col_index -
                      j*dF_ddx_dx_du_dw_n_cols + (j>1? (j-1)*(jmi->n_real_u): 0);
                  /* Special handling of w_coll due to blocking factors */
                  } else if (((*jmi_opt_coll)->n_blocking_factors>0) &&
                           jmi_variable_type_spec(jmi, JMI_DER_DX | JMI_DER_X |
                                 JMI_DER_U | JMI_DER_W,
                                      opt->der_mask,dF_ddx_dx_du_dw_icol[k])==JMI_DER_W) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = dF_ddx_dx_du_dw_irow[k] + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = dF_ddx_dx_du_dw_icol[k] +
                        col_index - (j>0? (jmi->n_real_u): 0);
                  } else {
                    (*jmi_opt_coll)->dh_row[rc_ind] = dF_ddx_dx_du_dw_irow[k] + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = dF_ddx_dx_du_dw_icol[k] + col_index;
                  }
                    rc_ind++;
                }

              }
            }

            /* Sparsity for element junctions */
            for (i=0;i<n_e;i++) {
                row_index = dh_cont_eq_offs(*jmi_opt_coll,i,0);
                col_index = offs_x_coll((*jmi_opt_coll),i,n_cp,0);
                for (j=0;j<jmi->n_real_x;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + col_index;
                    rc_ind++;
                }
                col_index = opt->offs_x_el_junc + jmi->n_real_x*i;
                for (j=0;j<jmi->n_real_x;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + col_index;
                    rc_ind++;
                }
            }

            /* Sparsity for u_0 interpolation equation */

            row_index = dh_u0_eq_offs(*jmi_opt_coll,0);
            if ((*jmi_opt_coll)->n_blocking_factors==0) {
                for (i=0;i<n_cp;i++) {
                    col_index = dF0_n_cols + dF_ddx_dx_du_dw_n_cols*i + jmi->n_real_dx + jmi->n_real_x;
                    for (j=0;j<jmi->n_real_u;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + col_index;
                        rc_ind++;
                    }
                }
            } else {
                col_index = dF0_n_cols + dF_ddx_dx_du_dw_n_cols*0 + jmi->n_real_dx + jmi->n_real_x;
                for (j=0;j<jmi->n_real_u;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + col_index;
                    rc_ind++;
                }
            }


            col_index = jmi->opt->n_p_opt + jmi->n_real_dx + jmi->n_real_x;
            for (j=0;j<jmi->n_real_u;j++) {
                (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + col_index;
                rc_ind++;
            }

            /* Sparsity for collocation equations
             Take care of the first point separately */
            for (i=0;i<n_cp;i++) {
                row_index = dh_coll_eq_offs(*jmi_opt_coll,0,i+1,0);
                /* Elements corresponding to dx_{0,1} */
                for (j=0;j<jmi->n_real_dx;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = offs_dx_coll((*jmi_opt_coll),0,i+1,j) + 1;
                    rc_ind++;
                }

                /* Elements corresponding x_{0,k} */
                for (k=0;k<n_cp;k++) {
                    for (j=0;j<jmi->n_real_x;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_x_coll((*jmi_opt_coll),0,k+1,j) + 1;
                        rc_ind++;
                    }
                }

                /* Elements corresponding to x_{0,0} */
                for (j=0;j<jmi->n_real_x;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + jmi->opt->n_p_opt + jmi->n_real_dx;
                    rc_ind++;
                }
            }

            /* Take care of the remaining elements */
            for (l=1;l<n_e;l++) {
                for (i=0;i<n_cp;i++) {
                    row_index = dh_coll_eq_offs(*jmi_opt_coll,l,i+1,0);

                    /* Elements for dx_{l,i} */
                    for (j=0;j<jmi->n_real_dx;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_dx_coll((*jmi_opt_coll),l,i+1,j) + 1;
                        /*dF_ddx_dx_du_dw_n_cols*i; */
                        rc_ind++;
                    }

                    /* Elements for x_{l,i} */
                    for (k=0;k<n_cp;k++) {
                        for (j=0;j<jmi->n_real_x;j++) {
                            (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                            (*jmi_opt_coll)->dh_col[rc_ind] = offs_x_coll((*jmi_opt_coll),l,k+1,j) + 1;
                            rc_ind++;
                        }
                    }

                    /* Elements for x_{j,0} */
                    for (j=0;j<jmi->n_real_x;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_x_coll((*jmi_opt_coll),l,0,j) + 1;
                        rc_ind++;
                    }
                }
            }

            /* Sparsity for interpolation of time points */
            for (i=0;i<jmi->n_tp;i++) {
                row_index = dh_dx_p_eq_offs(*jmi_opt_coll,i,0);

                /* If the time point is in element 0, treat it separately
                 Elements for dx^p_i
                 Elements corresponding to x_{i,0} */
                if ((*jmi_opt_coll)->tp_e[i] == 0) {
                    for (j=0;j<jmi->n_real_x;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + jmi->opt->n_p_opt + jmi->n_real_dx;
                        rc_ind++;
                    }
                } else {
                    for (j=0;j<jmi->n_real_x;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + opt->offs_x_el_junc +
                        ((*jmi_opt_coll)->tp_e[i]-1)*jmi->n_real_x;
                        rc_ind++;
                    }
                }

                /* Elements corresponding x_{t_p[i],k} */
                for (k=0;k<n_cp;k++) {
                    for (j=0;j<jmi->n_real_x;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_x_coll((*jmi_opt_coll),(*jmi_opt_coll)->tp_e[i],k+1,j) + 1;
                        rc_ind++;
                    }
                }
                /* Elements corresponding to dx^p_i */
                for (j=0;j<jmi->n_real_dx;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + dF_ddx_dx_du_dw_n_cols*i +opt->offs_dx_p;
                    rc_ind++;
                }

                /* Elements for x^p_i
                 Elements corresponding to x_{i,0} */
                if ((*jmi_opt_coll)->tp_e[i] == 0) {
                    for (j=0;j<jmi->n_real_x;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx;
                        (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + jmi->opt->n_p_opt + jmi->n_real_dx;
                        rc_ind++;
                    }
                } else {
                    for (j=0;j<jmi->n_real_x;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx;
                        (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + opt->offs_x_el_junc +
                        ((*jmi_opt_coll)->tp_e[i]-1)*jmi->n_real_x;
                        rc_ind++;
                    }
                }

                /* Elements corresponding x_{t_p[i],k} */
                for (k=0;k<n_cp;k++) {
                    for (j=0;j<jmi->n_real_x;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_x_coll((*jmi_opt_coll),(*jmi_opt_coll)->tp_e[i],k+1,j) + 1;
                        rc_ind++;
                    }
                }
                /* Elements corresponding to x^p_i */
                for (j=0;j<jmi->n_real_x;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx;
                    (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + dF_ddx_dx_du_dw_n_cols*i + opt->offs_x_p;
                    rc_ind++;
                }

                /* Elements for u^p_i
                 Elements corresponding u_{t_p[i],k} */
                if ((*jmi_opt_coll)->n_blocking_factors>0) {
                    for (j=0;j<jmi->n_real_u;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx + jmi->n_real_x;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_u_coll((*jmi_opt_coll),
                                (*jmi_opt_coll)->tp_e[i],1,j) + 1;
                        rc_ind++;
                    }
                } else {
                    for (k=0;k<n_cp;k++) {
                        for (j=0;j<jmi->n_real_u;j++) {
                            (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx + jmi->n_real_x;
                            (*jmi_opt_coll)->dh_col[rc_ind] = offs_u_coll((*jmi_opt_coll),
                                    (*jmi_opt_coll)->tp_e[i],k+1,j) + 1;
                            rc_ind++;
                        }
                    }
                }
                /* Elements corresponding to u^p_i */
                for (j=0;j<jmi->n_real_u;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx + jmi->n_real_x;
                    (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + dF_ddx_dx_du_dw_n_cols*i + opt->offs_u_p;
                    rc_ind++;
                }

                /* Elements for w^p_i
                 Elements corresponding w_{t_p[i],k} */
                for (k=0;k<n_cp;k++) {
                    for (j=0;j<jmi->n_real_w;j++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_w_coll((*jmi_opt_coll),(*jmi_opt_coll)->tp_e[i],k+1,j) + 1;
                        rc_ind++;
                    }
                }
                /* Elements corresponding to w^p_i */
                for (j=0;j<jmi->n_real_w;j++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = j + 1 + row_index + jmi->n_real_dx + jmi->n_real_x + jmi->n_real_u;
                    (*jmi_opt_coll)->dh_col[rc_ind] = j + 1 + dF_ddx_dx_du_dw_n_cols*i + opt->offs_w_p;
                    rc_ind++;
                }
            }


            /* Sparsity indices for dCeq: variables at initial time */
            row_index = dh_Ceq_eq_offs(*jmi_opt_coll,0,0,0);
            col_index = 0;
            /* Parameters */
            for (i=0;i<dCeq_dp_n_nz;i++) {
                (*jmi_opt_coll)->dh_row[rc_ind] = dCeq_dp_irow[i] + row_index;
                (*jmi_opt_coll)->dh_col[rc_ind] = dCeq_dp_icol[i] + col_index;
                rc_ind++;
            }

            /* Variables at collocation points */
            col_index = opt->offs_dx_0;
            for (i=0;i<dCeq_ddx_dx_du_dw_n_nz;i++) {
                (*jmi_opt_coll)->dh_row[rc_ind] = dCeq_ddx_dx_du_dw_irow[i] + row_index;
                (*jmi_opt_coll)->dh_col[rc_ind] = dCeq_ddx_dx_du_dw_icol[i] + col_index;
                rc_ind++;
            }

            /* Variables at interpolation points */
            col_index = opt->offs_dx_p;
            for (i=0;i<dCeq_ddx_p_dx_p_du_p_dw_p_n_nz;i++) {
                (*jmi_opt_coll)->dh_row[rc_ind] = dCeq_ddx_p_dx_p_du_p_dw_p_irow[i] + row_index;
                (*jmi_opt_coll)->dh_col[rc_ind] = dCeq_ddx_p_dx_p_du_p_dw_p_icol[i] + col_index;
                rc_ind++;
            }

            /* Sparsity for dCeq: collocation points */
            for (i=0;i<n_e;i++) {
                for (j=0;j<n_cp;j++) {
                row_index = dh_Ceq_eq_offs(*jmi_opt_coll,i,j+1,0);

                col_index = 0;
                for (k=0;k<dCeq_dp_n_nz;k++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = dCeq_dp_irow[k] + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = dCeq_dp_icol[k] + col_index;
                    rc_ind++;
                }

                col_index = offs_dx_coll((*jmi_opt_coll),i,j+1,0);
                for (k=0;k<dCeq_ddx_dx_du_dw_n_nz;k++) {
                  /* Special handling of u_coll due to blocking factors */
                  if (((*jmi_opt_coll)->n_blocking_factors>0) &&
                       jmi_variable_type_spec(jmi, JMI_DER_DX | JMI_DER_X |
                             JMI_DER_U | JMI_DER_W,
                                  opt->der_mask,dCeq_ddx_dx_du_dw_icol[k])==JMI_DER_U) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = dCeq_ddx_dx_du_dw_irow[k] + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = dCeq_ddx_dx_du_dw_icol[k] +
                    col_index -
                      j*dCeq_ddx_dx_du_dw_n_cols + (j>1? (j-1)*(jmi->n_real_u): 0);
                  /* Special handling of w_coll due to blocking factors */
                  } else if (((*jmi_opt_coll)->n_blocking_factors>0) &&
                           jmi_variable_type_spec(jmi, JMI_DER_DX | JMI_DER_X |
                                 JMI_DER_U | JMI_DER_W,
                                      opt->der_mask,dCeq_ddx_dx_du_dw_icol[k])==JMI_DER_W) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = dCeq_ddx_dx_du_dw_irow[k] + row_index;
                        (*jmi_opt_coll)->dh_col[rc_ind] = dCeq_ddx_dx_du_dw_icol[k] +
                        col_index - (j>0? (jmi->n_real_u): 0);
                  } else {
                    (*jmi_opt_coll)->dh_row[rc_ind] = dCeq_ddx_dx_du_dw_irow[k] + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = dCeq_ddx_dx_du_dw_icol[k] + col_index;
                  }
                    rc_ind++;
                }


                col_index = opt->offs_dx_p;
                for (k=0;k<dCeq_ddx_p_dx_p_du_p_dw_p_n_nz;k++) {
                    (*jmi_opt_coll)->dh_row[rc_ind] = dCeq_ddx_p_dx_p_du_p_dw_p_irow[k] + row_index;
                    (*jmi_opt_coll)->dh_col[rc_ind] = dCeq_ddx_p_dx_p_du_p_dw_p_icol[k] + col_index;
                    rc_ind++;
                }
            }
            }

            /* Sparsity for Heq */
            row_index = dh_Heq_eq_offs(*jmi_opt_coll,0);
            col_index = 0;
            /* Parameters */
            for (j=0;j<dHeq_dp_n_nz;j++) {
                (*jmi_opt_coll)->dh_row[rc_ind] = dHeq_dp_irow[j] + row_index;
                (*jmi_opt_coll)->dh_col[rc_ind] = dHeq_dp_icol[j] + col_index;
                rc_ind++;
            }

            /* Variables at interpolation points */
            col_index = opt->offs_dx_p;
            for (j=0;j<dHeq_ddx_p_dx_p_du_p_dw_p_n_nz;j++) {
                (*jmi_opt_coll)->dh_row[rc_ind] = dHeq_ddx_p_dx_p_du_p_dw_p_irow[j] + row_index;
                (*jmi_opt_coll)->dh_col[rc_ind] = dHeq_ddx_p_dx_p_du_p_dw_p_icol[j] + col_index;
                rc_ind++;
            }

            /* loop over all blocking factors */
            row_index = dh_blocking_eq_offs(*jmi_opt_coll,0);
            el_ind = 0;
            for (i=0;i<(*jmi_opt_coll)->n_blocking_factors;i++) {
                /* loop over each constraint */
                for (j=0;j<(*jmi_opt_coll)->blocking_factors[i]-1;j++) {
                    for (k=0;k<jmi->n_real_u;k++) {
                        (*jmi_opt_coll)->dh_row[rc_ind] = row_index + 1;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_u_coll((*jmi_opt_coll),el_ind,0,k) + 1;
                        rc_ind++;

                        (*jmi_opt_coll)->dh_row[rc_ind] = row_index + 1;
                        (*jmi_opt_coll)->dh_col[rc_ind] = offs_u_coll((*jmi_opt_coll),el_ind+j+1,0,k) + 1;
                        rc_ind++;

                        row_index++;
                    }
                }
                el_ind += (*jmi_opt_coll)->blocking_factors[i];
            }
            /*
            FILE *f = fopen("sparsity.m","wt");

            fprintf(f,"n_x=%d;\n",jmi->n_real_x);
            fprintf(f,"n_real_u=%d;\n",jmi->n_real_u);
            fprintf(f,"n_real_w=%d;\n",jmi->n_real_w);
            fprintf(f,"n_tp=%d\n",jmi->n_tp);
            fprintf(f,"n_p_opt=%d\n",jmi->opt->n_p_opt);
            fprintf(f,"n_eq_Ceq=%d\n",jmi->opt->Ceq->n_eq_F);
            fprintf(f,"n_eq_Cineq=%d\n",jmi->opt->Cineq->n_eq_F);
            fprintf(f,"n_eq_Heq=%d\n",jmi->opt->Heq->n_eq_F);
            fprintf(f,"n_eq_Hineq=%d\n",jmi->opt->Hineq->n_eq_F);
            fprintf(f,"n_e=%d;\n",n_e);
            fprintf(f,"n_cp=%d;\n",n_cp);
            fprintf(f,"n_eq_F0=%d\n",jmi->init->F0->n_eq_F);
            fprintf(f,"n_eq_F=%d\n",jmi->dae->F->n_eq_F);
            fprintf(f,"dF0_n_cols=%d\n",dF0_n_cols);
            fprintf(f,"dF_dp_n_cols=%d\n",dF_dp_n_cols);
            fprintf(f,"dF_ddx_dx_du_dw_n_cols=%d\n",dF_ddx_dx_du_dw_n_cols);

            fprintf(f,"dCeq_dp_n_cols=%d\n",dCeq_dp_n_cols);
            fprintf(f,"dCeq_ddx_dx_du_dw_n_cols=%d\n",dCeq_ddx_dx_du_dw_n_cols);
            fprintf(f,"dCeq_ddx_p_dx_p_du_p_dw_p_n_cols=%d\n",dCeq_ddx_p_dx_p_du_p_dw_p_n_cols);
            fprintf(f,"dCeq_dp_n_nz=%d\n",dCeq_dp_n_nz);
            fprintf(f,"dCeq_ddx_dx_du_dw_n_nz=%d\n",dCeq_ddx_dx_du_dw_n_nz);
            fprintf(f,"dCeq_ddx_p_dx_p_du_p_dw_p_n_nz=%d\n",dCeq_ddx_p_dx_p_du_p_dw_p_n_nz);

            fprintf(f,"dCineq_dp_n_cols=%d\n",dCineq_dp_n_cols);
            fprintf(f,"dCineq_ddx_dx_du_dw_n_cols=%d\n",dCineq_ddx_dx_du_dw_n_cols);
            fprintf(f,"dCineq_ddx_p_dx_p_du_p_dw_p_n_cols=%d\n",dCineq_ddx_p_dx_p_du_p_dw_p_n_cols);
            fprintf(f,"dCineq_dp_n_nz=%d\n",dCineq_dp_n_nz);
            fprintf(f,"dCineq_ddx_dx_du_dw_n_nz=%d\n",dCineq_ddx_dx_du_dw_n_nz);
            fprintf(f,"dCineq_ddx_p_dx_p_du_p_dw_p_n_nz=%d\n",dCineq_ddx_p_dx_p_du_p_dw_p_n_nz);

            fprintf(f,"dHeq_dp_n_cols=%d\n",dHeq_dp_n_cols);
            fprintf(f,"dHeq_ddx_p_dx_p_du_p_dw_p_n_cols=%d\n",dHeq_ddx_p_dx_p_du_p_dw_p_n_cols);
            fprintf(f,"dHeq_dp_n_nz=%d\n",dHeq_dp_n_nz);
            fprintf(f,"dHeq_ddx_p_dx_p_du_p_dw_p_n_nz=%d\n",dHeq_ddx_p_dx_p_du_p_dw_p_n_nz);

            fprintf(f,"dHineq_dp_n_cols=%d\n",dHineq_dp_n_cols);
            fprintf(f,"dHineq_ddx_p_dx_p_du_p_dw_p_n_cols=%d\n",dHineq_ddx_p_dx_p_du_p_dw_p_n_cols);
            fprintf(f,"dHineq_dp_n_nz=%d\n",dHineq_dp_n_nz);
            fprintf(f,"dHineq_ddx_p_dx_p_du_p_dw_p_n_nz=%d\n",dHineq_ddx_p_dx_p_du_p_dw_p_n_nz);


            fprintf(f,"ind_dg=[");
            for (i=0;i<(*jmi_opt_coll)->dg_n_nz;i++) {
                fprintf(f,"%d %d %d;\n",i+1,(*jmi_opt_coll)->dg_row[i],(*jmi_opt_coll)->dg_col[i]);
            }
            fprintf(f,"];\n");
            fprintf(f,"ind_dh=[");
            for (i=0;i<(*jmi_opt_coll)->dh_n_nz;i++) {
                fprintf(f,"%d %d %d;\n",i+1,(*jmi_opt_coll)->dh_row[i],(*jmi_opt_coll)->dh_col[i]);
            }
            fprintf(f,"];\n");
            fprintf(f,"plotSparsityLP(n_x,n_real_u,n_real_w,n_p_opt,n_tp,n_eq_Ceq,n_eq_Cineq,n_eq_Heq,n_eq_Hineq,n_e,n_cp,n_eq_F0, \
                    n_eq_F, dF0_n_cols,dF_dp_n_cols,dF_ddx_dx_du_dw_n_cols, \
                    dCeq_dp_n_cols,dCeq_ddx_dx_du_dw_n_cols,dCeq_ddx_p_dx_p_du_p_dw_p_n_cols, \
                    dCineq_dp_n_cols,dCineq_ddx_dx_du_dw_n_cols,dCineq_ddx_p_dx_p_du_p_dw_p_n_cols, \
                    dHeq_dp_n_cols,dHeq_ddx_p_dx_p_du_p_dw_p_n_cols, \
                    dHineq_dp_n_cols,dHineq_ddx_p_dx_p_du_p_dw_p_n_cols, \
            ind_dg,ind_dh,1)");
            fclose(f);
*/

            /* Set the bounds vector
             Bounds for optimization parameters */
            for (i=0;i<jmi->opt->n_p_opt;i++) {
                (*jmi_opt_coll)->x_lb[offs_p_opt((*jmi_opt_coll),i)] = p_opt_lb[i];
                (*jmi_opt_coll)->x_ub[offs_p_opt((*jmi_opt_coll),i)] = p_opt_ub[i];
                (*jmi_opt_coll)->x_init[offs_p_opt((*jmi_opt_coll),i)] = p_opt_init[i];
            }

            /* Bounds on initial point */
            for (k=0;k<jmi->n_real_dx;k++) {
                (*jmi_opt_coll)->x_lb[offs_dx_0((*jmi_opt_coll),k)] = dx_lb[k];
                (*jmi_opt_coll)->x_ub[offs_dx_0((*jmi_opt_coll),k)] = dx_ub[k];
                (*jmi_opt_coll)->x_init[offs_dx_0((*jmi_opt_coll),k)] = dx_init[k];
            }

            for (k=0;k<jmi->n_real_x;k++) {
                (*jmi_opt_coll)->x_lb[offs_x_0((*jmi_opt_coll),k)] = x_lb[k];
                (*jmi_opt_coll)->x_ub[offs_x_0((*jmi_opt_coll),k)] = x_ub[k];
                (*jmi_opt_coll)->x_init[offs_x_0((*jmi_opt_coll),k)] = x_init[k];
            }

            for (k=0;k<jmi->n_real_u;k++) {
                (*jmi_opt_coll)->x_lb[offs_u_0((*jmi_opt_coll),k)] = u_lb[k];
                (*jmi_opt_coll)->x_ub[offs_u_0((*jmi_opt_coll),k)] = u_ub[k];
                (*jmi_opt_coll)->x_init[offs_u_0((*jmi_opt_coll),k)] = u_init[k];
            }

            for (k=0;k<jmi->n_real_w;k++) {
                (*jmi_opt_coll)->x_lb[offs_w_0((*jmi_opt_coll),k)] = w_lb[k];
                (*jmi_opt_coll)->x_ub[offs_w_0((*jmi_opt_coll),k)] = w_ub[k];
                (*jmi_opt_coll)->x_init[offs_w_0((*jmi_opt_coll),k)] = w_init[k];
            }

            /* Bounds on collocation points */
            for (i=0;i<(*jmi_opt_coll)->n_e;i++) {
                for (j=1;j<=opt->n_cp;j++) {
                    for (k=0;k<jmi->n_real_dx;k++) {
                        (*jmi_opt_coll)->x_lb[offs_dx_coll((*jmi_opt_coll),i,j,k)] = dx_lb[k];
                        (*jmi_opt_coll)->x_ub[offs_dx_coll((*jmi_opt_coll),i,j,k)] = dx_ub[k];
                        (*jmi_opt_coll)->x_init[offs_dx_coll((*jmi_opt_coll),i,j,k)] = dx_init[k];
                    }

                    for (k=0;k<jmi->n_real_x;k++) {
                        (*jmi_opt_coll)->x_lb[offs_x_coll((*jmi_opt_coll),i,j,k)] = x_lb[k];
                        (*jmi_opt_coll)->x_ub[offs_x_coll((*jmi_opt_coll),i,j,k)] = x_ub[k];
                        (*jmi_opt_coll)->x_init[offs_x_coll((*jmi_opt_coll),i,j,k)] = x_init[k];
                    }

                    for (k=0;k<jmi->n_real_u;k++) {
                        (*jmi_opt_coll)->x_lb[offs_u_coll((*jmi_opt_coll),i,j,k)] = u_lb[k];
                        (*jmi_opt_coll)->x_ub[offs_u_coll((*jmi_opt_coll),i,j,k)] = u_ub[k];
                        (*jmi_opt_coll)->x_init[offs_u_coll((*jmi_opt_coll),i,j,k)] = u_init[k];
                    }

                    for (k=0;k<jmi->n_real_w;k++) {
                        (*jmi_opt_coll)->x_lb[offs_w_coll((*jmi_opt_coll),i,j,k)] = w_lb[k];
                        (*jmi_opt_coll)->x_ub[offs_w_coll((*jmi_opt_coll),i,j,k)] = w_ub[k];
                        (*jmi_opt_coll)->x_init[offs_w_coll((*jmi_opt_coll),i,j,k)] = w_init[k];
                    }

                }
            }

            /* Bounds for the x variables at element junctions */
            for (i=0;i<n_e;i++) {
                for (j=0;j<jmi->n_real_x;j++) {
                    (*jmi_opt_coll)->x_lb[opt->offs_x_el_junc + (jmi->n_real_x)*i + j] = x_lb[j];
                    (*jmi_opt_coll)->x_ub[opt->offs_x_el_junc + (jmi->n_real_x)*i + j] = x_ub[j];
                    (*jmi_opt_coll)->x_init[opt->offs_x_el_junc + (jmi->n_real_x)*i + j] = x_init[j];
                }
            }

            /* Bounds for the time points */
            for (i=0;i<jmi->n_tp;i++) {
                for (k=0;k<jmi->n_real_dx;k++) {
                        (*jmi_opt_coll)->x_lb[offs_dx_p((*jmi_opt_coll),i,k)] = dx_lb[k];
                    (*jmi_opt_coll)->x_ub[offs_dx_p((*jmi_opt_coll),i,k)] = dx_ub[k];
                    (*jmi_opt_coll)->x_init[offs_dx_p((*jmi_opt_coll),i,k)] = dx_init[k];
                }

                for (k=0;k<jmi->n_real_x;k++) {
                    (*jmi_opt_coll)->x_lb[offs_x_p((*jmi_opt_coll),i,k)] = x_lb[k];
                    (*jmi_opt_coll)->x_ub[offs_x_p((*jmi_opt_coll),i,k)] = x_ub[k];
                    (*jmi_opt_coll)->x_init[offs_x_p((*jmi_opt_coll),i,k)] = x_init[k];
                }

                for (k=0;k<jmi->n_real_u;k++) {
                    (*jmi_opt_coll)->x_lb[offs_u_p((*jmi_opt_coll),i,k)] = u_lb[k];
                    (*jmi_opt_coll)->x_ub[offs_u_p((*jmi_opt_coll),i,k)] = u_ub[k];
                    (*jmi_opt_coll)->x_init[offs_u_p((*jmi_opt_coll),i,k)] = u_init[k];
                }

                for (k=0;k<jmi->n_real_w;k++) {
                    (*jmi_opt_coll)->x_lb[offs_w_p((*jmi_opt_coll),i,k)] = w_lb[k];
                    (*jmi_opt_coll)->x_ub[offs_w_p((*jmi_opt_coll),i,k)] = w_ub[k];
                    (*jmi_opt_coll)->x_init[offs_w_p((*jmi_opt_coll),i,k)] = w_init[k];
                }

            }

            /* Bounds for the element length variables (if free) */
            if (hs_free == 1) {
                for (i=0;i<n_e;i++) {
                    (*jmi_opt_coll)->x_lb[opt->offs_h + i] = hs_lb[i];
                    (*jmi_opt_coll)->x_ub[opt->offs_h + i] = hs_ub[i];
                }
            }

            /* Bounds for interval end points (if free) */
            if (jmi->opt->start_time_free == 1) {
                (*jmi_opt_coll)->x_lb[opt->offs_t0] = t0_lb;
                (*jmi_opt_coll)->x_ub[opt->offs_t0] = t0_ub;
            }

            if (jmi->opt->final_time_free == 1) {
                (*jmi_opt_coll)->x_lb[opt->offs_tf] = tf_lb;
                (*jmi_opt_coll)->x_ub[opt->offs_tf] = tf_ub;
            }

            /*
            for (i=0;i<(*jmi_opt_coll)->n_x;i++) {
              printf("%d, %f, %f, %f\n",i,(*jmi_opt_coll)->x_lb[i],(*jmi_opt_coll)->x_ub[i],(*jmi_opt_coll)->x_init[i]);
            }
*/
            /* Set mesh */
            for (i=0;i<n_e;i++) {
                (*jmi_opt_coll)->hs[i] = hs[i];
            }

            if (linearity_information_provided==1) {
                int n_nl_dx;
                int n_nl_x;
                int n_nl_u;
                int n_nl_w;
                int ind;
                int ind_x;
                
                /* Set linearity vector. */
                int n_nl_vars = 0;

                /* Count the number of non linear optimization parameters */
                int n_nl_p_opt = 0;
                for (i=0;i<jmi->opt->n_p_opt;i++) {
                    if (p_opt_lin[i]==0) {
                        n_nl_p_opt++;
                    }
                }

                /* Count the number of non linear derivative variables */
                n_nl_dx = 0;
                for (i=0;i<jmi->n_real_dx;i++) {
                    if (dx_lin[i]==0) {
                        n_nl_dx++;
                    }
                    for (j=0;j<jmi->n_tp;j++) {
                        if (dx_tp_lin[j*jmi->n_real_dx + i]==0) {
                            n_nl_vars++;
                        }
                    }
                }
                /* Count the number of non linear state variables */
                n_nl_x = 0;
                for (i=0;i<jmi->n_real_x;i++) {
                    if (x_lin[i]==0) {
                        n_nl_x++;
                    }
                    for (j=0;j<jmi->n_tp;j++) {
                        if (x_tp_lin[j*jmi->n_real_x + i]==0) {
                            n_nl_vars++;
                        }
                    }
                }
                /* Count the number of non linear input variables */
                n_nl_u = 0;
                for (i=0;i<jmi->n_real_u;i++) {
                    if (u_lin[i]==0) {
                        n_nl_u++;
                    }
                    for (j=0;j<jmi->n_tp;j++) {
                        if (u_tp_lin[j*jmi->n_real_u + i]==0) {
                            n_nl_vars++;
                        }
                    }
                }
                /* Count the number of non linear algebraic variables */
                n_nl_w = 0;
                for (i=0;i<jmi->n_real_w;i++) {
                    if (w_lin[i]==0) {
                        n_nl_w++;
                    }
                    for (j=0;j<jmi->n_tp;j++) {
                        if (w_tp_lin[j*jmi->n_real_w + i]==0) {
                            n_nl_vars++;
                        }
                    }
                }
/*
                printf(">> %d\n",n_nl_vars);
                printf(">> %d\n",n_nl_p_opt);
                printf(">> %d\n",n_nl_dx);
                printf(">> %d\n",n_nl_x);
                printf(">> %d\n",n_nl_u);
                printf(">> %d\n",n_nl_w);
*/
                /* Compute the total number of non linear variables in the NLP x vector */
                n_nl_vars += n_nl_p_opt + n_nl_dx*(1+n_cp*n_e) +
                n_nl_x*(1+n_cp*n_e) +
                  ((*jmi_opt_coll)->n_blocking_factors>0? n_nl_u*(n_e+1): n_nl_u*(1+n_cp*n_e)) +
                n_nl_w*(1+n_cp*n_e);

/*              printf("--- %d\n",n_nl_vars); */

                /* Initialize the corresponding field in the struct */
                (*jmi_opt_coll)->n_nonlinear_variables = n_nl_vars;

                /* Allocate memory. */
                (*jmi_opt_coll)->non_linear_variables_indices =
                    (int*)calloc(n_nl_vars,sizeof(int));

                ind = 0;   /* Counter for the non_linear_variables_indices vector */
                ind_x = 1; /* Counter for the indices in the NLP x vector, Fortran style */

                /* Set non linear variable indices corresponding to optimization parameters */
                for (i=0;i<jmi->opt->n_p_opt;i++) {
                    if (p_opt_lin[i]==0) {
                        (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                    }
                    ind_x++;
                }

                /* Add non-linear entries for initial point
                 Iterate over derivatives */
                for (k=0;k<jmi->n_real_dx;k++) {
                    if (dx_lin[k]==0) {
                        (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                    }
                    ind_x++;
                }
                /* Iterate over states */
                for (k=0;k<jmi->n_real_x;k++) {
                    if (x_lin[k]==0) {
                        (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                    }
                    ind_x++;
                }
                /* Iterate over inputs */
                for (k=0;k<jmi->n_real_u;k++) {
                    if (u_lin[k]==0) {
                        (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                    }
                    ind_x++;
                }
                /* Iterate over algebraic variables */
                for (k=0;k<jmi->n_real_w;k++) {
                    if (w_lin[k]==0) {
                        (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                    }
                    ind_x++;
                }

                /* Set non linear variables corresponding to collocation points
                 Iterate over all elements */
                for (i=0;i<n_e;i++) {
                    /* Iterate over all collocation points and initial point */
                    for (j=0;j<n_cp;j++) {
                        /* Iterate over derivatives */
                        for (k=0;k<jmi->n_real_dx;k++) {
                            if (dx_lin[k]==0) {
                                (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                            }
                            ind_x++;
                        }
                        /* Iterate over states */
                        for (k=0;k<jmi->n_real_x;k++) {
                            if (x_lin[k]==0) {
                                (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                            }
                            ind_x++;
                        }
                        /* Iterate over inputs */
                        if (!((*jmi_opt_coll)->n_blocking_factors>0 && j>0)) {

                          for (k=0;k<jmi->n_real_u;k++) {
                            if (u_lin[k]==0) {
                                (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                            }
                            ind_x++;
                          }
                        }
                        /* Iterate over algebraic variables */
                        for (k=0;k<jmi->n_real_w;k++) {
                            if (w_lin[k]==0) {
                                (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                            }
                            ind_x++;
                        }
                    }
                }

                /* Skip element junctions: they are always linear. */
                ind_x += jmi->n_real_x*n_e;

/*              printf("### %d\n",ind_x); */
                /* Iterate over time point variables. */
                for (i=0;i<jmi->n_tp;i++) {
                    /* Iterate over derivatives */
                    for (k=0;k<jmi->n_real_dx;k++) {
                        /*printf("<<%d %d %d %d\n",i,k,dx_tp_lin[i*jmi->n_real_dx + k],ind_x); */
                        if (dx_tp_lin[i*jmi->n_real_dx + k]==0) {
                            (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                        }
                        ind_x++;
                    }
                    /* Iterate over states */
                    for (k=0;k<jmi->n_real_x;k++) {
                        /*printf("<<%d %d %d %d\n",i,k,x_tp_lin[i*jmi->n_real_x + k],ind_x); */
                        if (x_tp_lin[i*jmi->n_real_x + k]==0) {
                            (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                        }
                        ind_x++;
                    }
                    /* Iterate over inputs */
                    for (k=0;k<jmi->n_real_u;k++) {
                        /*printf("<<%d %d %d %d\n",i,k,u_tp_lin[i*jmi->n_real_u + k],ind_x); */
                        if (u_tp_lin[i*jmi->n_real_u + k]==0) {
                            (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                        }
                        ind_x++;
                    }
                    /* Iterate over algebraic variables */
                    for (k=0;k<jmi->n_real_w;k++) {
                        /*printf("<<%d %d %d %d\n",i,k,w_tp_lin[i*jmi->n_real_w + k],ind_x); */
                        if (w_tp_lin[i*jmi->n_real_w + k]==0) {
                            (*jmi_opt_coll)->non_linear_variables_indices[ind++] = ind_x;
                        }
                        ind_x++;
                    }
                }

            } else {
                (*jmi_opt_coll)->n_nonlinear_variables = -1;
            }

            /*Set function pointers */
            (*jmi_opt_coll)->get_dimensions = *jmi_opt_coll_get_dimensions;
            (*jmi_opt_coll)->get_interval_spec = *jmi_opt_coll_get_interval_spec;
            (*jmi_opt_coll)->f = *lp_radau_f;
            (*jmi_opt_coll)->df = *lp_radau_df;
            (*jmi_opt_coll)->h = *lp_radau_h;
            (*jmi_opt_coll)->dh = *lp_radau_dh;
            (*jmi_opt_coll)->g = *lp_radau_g;
            (*jmi_opt_coll)->dg = *lp_radau_dg;
            (*jmi_opt_coll)->get_bounds = *jmi_opt_coll_get_bounds;
            (*jmi_opt_coll)->get_initial = *jmi_opt_coll_get_initial;
            (*jmi_opt_coll)->dh_nz_indices = *lp_radau_dh_nz_indices;
            (*jmi_opt_coll)->dg_nz_indices = *lp_radau_dg_nz_indices;
            (*jmi_opt_coll)->set_initial_from_trajectory =
                *lp_set_initial_from_trajectory;
            (*jmi_opt_coll)->write_file_matlab = *lp_radau_write_file_matlab;
            (*jmi_opt_coll)->get_result_variable_vector_length =
                *lp_radau_get_result_variable_vector_length;
            (*jmi_opt_coll)->get_result = *lp_radau_get_result;
            (*jmi_opt_coll)->get_result_mesh_interpolation =
                *lp_radau_get_result_mesh_interpolation;
            (*jmi_opt_coll)->get_result_element_interpolation =
                *lp_radau_get_result_element_interpolation;
            /*print_lp_pols(*jmi_opt_coll); */
            /*print_problem_stats(*jmi_opt_coll); */
            return 0;
}

int jmi_opt_coll_radau_delete(jmi_opt_coll_t *jmi_opt_coll) {

    return 0;
}




static void print_problem_stats(jmi_opt_coll_t *jmi_opt_coll) {
    jmi_opt_coll_radau_t *opt = (jmi_opt_coll_radau_t*)jmi_opt_coll;

    int i;

    printf("Creating NLP struct from Radau points and Lagrange polynomials:\n");
    printf("Number of mesh elements:                                   %d\n",jmi_opt_coll->n_e);
    printf("Number of collocation points:                              %d\n",opt->n_cp);
    printf("Number of variables:                                       %d\n",jmi_opt_coll->n_x);
    printf("Number of non-linear variables:                            %d\n",jmi_opt_coll->n_nonlinear_variables);

    printf("Number of inequality constraints:                          %d\n",jmi_opt_coll->n_g);
    printf("Number of non-zeros in inequality constraint Jacobian:     %d\n",jmi_opt_coll->dg_n_nz);
    printf("Number of equality constraints:                            %d\n",jmi_opt_coll->n_h);
    printf("Number of non-zeros in equality constraint Jacobian:       %d\n",jmi_opt_coll->dh_n_nz);

    printf("p_opt offset in x:                                         %d\n",opt->offs_p_opt);
    printf("dx_0 offset in x:                                          %d\n",opt->offs_dx_0);
    printf("x_0 offset in x:                                           %d\n",opt->offs_x_0);
    printf("u_0 offset in x:                                           %d\n",opt->offs_u_0);
    printf("w_0 offset in x:                                           %d\n",opt->offs_w_0);
    printf("dx_coll offset in x:                                       %d\n",opt->offs_dx_coll);
    printf("x_coll offset in x:                                        %d\n",opt->offs_x_coll);
    printf("u_coll offset in x:                                        %d\n",opt->offs_u_coll);
    printf("w_coll offset in x:                                        %d\n",opt->offs_w_coll);
    printf("x_el_junc offset in x:                                     %d\n",opt->offs_x_el_junc);
    printf("dx_p offset in x:                                          %d\n",opt->offs_dx_p);
    printf("x_p offset in x:                                           %d\n",opt->offs_x_p);
    printf("u_p offset in x:                                           %d\n",opt->offs_u_p);
    printf("w_p offset in x:                                           %d\n",opt->offs_w_p);
    printf("h offset in x:                                             %d\n",opt->offs_h);
    printf("t0 offset in x:                                            %d\n",opt->offs_t0);
    printf("tf offset in x:                                            %d\n",opt->offs_tf);

    printf("Time points (index, normalized time, element, tau):\n");
    for (i=0;i<jmi_opt_coll->jmi->n_tp;i++) {
        printf("%d %f, %d, %f\n",i,jmi_opt_coll->jmi->tp[i],
                jmi_opt_coll->tp_e[i],jmi_opt_coll->tp_tau[i]);
    }

}

static void print_lp_pols(jmi_opt_coll_t *jmi_opt_coll) {

    int i, j;

    jmi_opt_coll_radau_t *opt = (jmi_opt_coll_radau_t*)jmi_opt_coll;

    /* Print Lagrange polynomials */
    printf("cp = {");
    for (i=0;i<opt->n_cp;i++) {
        printf("%4.16e",opt->cp[i]);
        if (i<opt->n_cp-1) {
            printf(", ");
        }
    }
    printf("}\n\n");

    printf("w = {");
    for (i=0;i<opt->n_cp;i++) {
        printf("%4.16e",opt->w[i]);
        if (i<opt->n_cp-1) {
            printf(", ");
        }
    }
    printf("}\n\n");

    printf("cpp = {");
    for (i=0;i<opt->n_cp+1;i++) {
        printf("%4.16e",opt->cpp[i]);
        if (i<opt->n_cp+1) {
            printf(", ");
        }
    }
    printf("}\n\n");

    printf("Lp_coeffs = {");
    for (i=0;i<opt->n_cp;i++) {
        printf("{");
        for (j=0;j<opt->n_cp;j++) {
            printf("%4.16e",opt->Lp_coeffs[j*opt->n_cp + i]);
            if (j<opt->n_cp-1) {
                printf(", ");
            }
        }
        printf("}");
        if (i<opt->n_cp-1) {
            printf(",\n");
        }
    }
    printf("}\n\n");


    printf("Lp_dot_coeffs = {");
    for (i=0;i<opt->n_cp;i++) {
        printf("{");
        for (j=0;j<opt->n_cp;j++) {
            printf("%4.16e",opt->Lp_dot_coeffs[j*opt->n_cp + i]);
            if (j<opt->n_cp-1) {
                printf(", ");
            }
        }
        printf("}");
        if (i<opt->n_cp-1) {
            printf(",\n");
        }
    }
    printf("}\n\n");

    printf("Lp_dot_vals = {");
    for (i=0;i<opt->n_cp;i++) {
        printf("{");
        for (j=0;j<opt->n_cp;j++) {
            printf("%4.16e",opt->Lp_dot_vals[j*opt->n_cp + i]);
            if (j<opt->n_cp-1) {
                printf(", ");
            }
        }
        printf("}");
        if (i<opt->n_cp-1) {
            printf(",\n");
        }
    }
    printf("}\n\n");

    printf("Lpp_coeffs = {");
    for (i=0;i<opt->n_cp+1;i++) {
        printf("{");
        for (j=0;j<opt->n_cp+1;j++) {
            printf("%4.16e",opt->Lpp_coeffs[j*(opt->n_cp+1) + i]);
            if (j<opt->n_cp) {
                printf(", ");
            }
        }
        printf("}");
        if (i<opt->n_cp) {
            printf(",\n");
        }
    }
    printf("}\n\n");


    printf("Lpp_dot_coeffs = {");
    for (i=0;i<opt->n_cp+1;i++) {
        printf("{");
        for (j=0;j<opt->n_cp+1;j++) {
            printf("%4.16e",opt->Lpp_dot_coeffs[j*(opt->n_cp+1) + i]);
            if (j<opt->n_cp) {
                printf(", ");
            }
        }
        printf("}");
        if (i<opt->n_cp) {
            printf(",\n");
        }
    }
    printf("}\n\n");

    printf("Lpp_dot_vals = {");
    for (i=0;i<opt->n_cp+1;i++) {
        printf("{");
        for (j=0;j<opt->n_cp+1;j++) {
            printf("%4.16e",opt->Lpp_dot_vals[j*(opt->n_cp+1) + i]);
            if (j<opt->n_cp) {
                printf(", ");
            }
        }
        printf("}");
        if (i<opt->n_cp) {
            printf(",\n");
        }
    }
    printf("}\n\n");


}

jmi_real_t jmi_opt_coll_radau_eval_pol(jmi_real_t tau, int n, jmi_real_t* pol, int k) {
    int i;
    jmi_real_t val = 0;
    for (i=0;i<n;i++) {
        val += pol[n*i + k]*pow(tau,n-i-1);
    }
    return val;
}

int jmi_opt_coll_radau_get_pols(int n_cp, jmi_real_t *cp, jmi_real_t *w,
        jmi_real_t *cpp,
        jmi_real_t *Lp_coeffs, jmi_real_t *Lpp_coeffs,
        jmi_real_t *Lp_dot_coeffs, jmi_real_t *Lpp_dot_coeffs,
        jmi_real_t *Lp_dot_vals, jmi_real_t *Lpp_dot_vals){
    int i,j;
    switch (n_cp) {
    case 1:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_1[i];
            w[i] = jmi_opt_coll_w_1[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_1[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_1[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_1[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_1[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_1[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_1[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_1[i][j];
            }
        }

        break;
    case 2:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_2[i];
            w[i] = jmi_opt_coll_w_2[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_2[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_2[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_2[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_2[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_2[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_2[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_2[i][j];
            }
        }

        break;
    case 3:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_3[i];
            w[i] = jmi_opt_coll_w_3[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_3[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_3[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_3[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_3[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_3[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_3[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_3[i][j];
            }
        }
        break;
    case 4:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_4[i];
            w[i] = jmi_opt_coll_w_4[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_4[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_4[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_4[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_4[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_4[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_4[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_4[i][j];
            }
        }
        break;
    case 5:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_5[i];
            w[i] = jmi_opt_coll_w_5[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_5[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_5[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_5[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_5[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_5[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_5[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_5[i][j];
            }
        }
        break;
    case 6:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_6[i];
            w[i] = jmi_opt_coll_w_6[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_6[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_6[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_6[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_6[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_6[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_6[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_6[i][j];
            }
        }
        break;
    case 7:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_7[i];
            w[i] = jmi_opt_coll_w_7[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_7[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_7[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_7[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_7[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_7[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_7[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_7[i][j];
            }
        }
        break;
    case 8:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_8[i];
            w[i] = jmi_opt_coll_w_8[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_8[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_8[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_8[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_8[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_8[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_8[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_8[i][j];
            }
        }
        break;
    case 9:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_9[i];
            w[i] = jmi_opt_coll_w_9[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_9[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_9[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_9[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_9[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_9[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_9[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_9[i][j];
            }
        }
        break;
    case 10:

        for (i=0;i<n_cp;i++) {
            cp[i] = jmi_opt_coll_radau_p_10[i];
            w[i] = jmi_opt_coll_w_10[i];
        }
        for (i=0;i<n_cp+1;i++) {
            cpp[i] = jmi_opt_coll_radau_pp_10[i];
        }

        for (i=0;i<n_cp;i++) {
            for (j=0;j<n_cp;j++) {
                Lp_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_coeffs_10[i][j];
                Lp_dot_coeffs[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_coeffs_10[i][j];
                Lp_dot_vals[j*n_cp + i] = jmi_opt_coll_radau_lp_dot_vals_10[i][j];
            }
        }

        for (i=0;i<n_cp+1;i++) {
            for (j=0;j<n_cp+1;j++) {
                Lpp_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_coeffs_10[i][j];
                Lpp_dot_coeffs[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_coeffs_10[i][j];
                Lpp_dot_vals[j*(n_cp+1) + i] = jmi_opt_coll_radau_lpp_dot_vals_10[i][j];
            }
        }
        break;


    default:
        return -1;
    }

    return 0;
}

