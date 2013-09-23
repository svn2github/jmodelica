#ifndef MXVECTORWRAP_HPP
#define MXVECTORWRAP_HPP

#include "symbolic/casadi.hpp"
#include "casadi/MXVector.h"

typedef casadi::MXVector JMXVector;

inline std::vector<CasADi::MX> toMXVector(const JMXVector &jmxvector) {
    jlong p = JMXVector::getCPtr(jmxvector);
    return **(std::vector<CasADi::MX> **)&p;
}

#endif
