// This interface offers additional functionality such as ad and fd support

#ifndef _JMI_H
#define _JMI_H

#include "jmi_low.h"

typedef struct Jmi Jmi;

typedef int (*jmi_dae_dF_t)(Jmi* jmi, Double_t* ci, Double_t* cd, 
                            Double_t* pi, Double_t* pd,
			    Double_t* dx, Double_t* x, Double_t* u, Double_t* w,
			    Double_t t, int der_method, int mask, Double_t* res);

struct Jmi {
  Jmi_low jmi_low;
  jmi_dae_dF_t dae_dF;
};

int jmi_init(Jmi* jmi);
int jmi_delete(Jmi* jmi);

#endif
