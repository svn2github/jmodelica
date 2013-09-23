#ifndef MXWRAP_HPP
#define MXWRAP_HPP

#include "symbolic/casadi.hpp"
#include "casadi/MX.h"

typedef casadi::MX JMX;

inline CasADi::MX toMX(const JMX &jmx) {
    jlong p = JMX::getCPtr(jmx);
    return **(CasADi::MX **)&p;
}
#ifdef org_jmodelica_modelica_compiler_FExp_H  // if JCC-generated FExp.h included:
inline CasADi::MX toMX(const org::jmodelica::modelica::compiler::FExp &ex) { return toMX(ex.toMX()); }
#endif
#ifdef org_jmodelica_optimica_compiler_FExp_H  // if JCC-generated FExp.h included:
inline CasADi::MX toMX(const org::jmodelica::optimica::compiler::FExp &ex) { return toMX(ex.toMX()); }
#endif

inline JMX toJMX(const CasADi::MX &ex) {
    CasADi::MX *px = new CasADi::MX(ex);
    return JMX(*(jlong *)&px, (jboolean)true);
}

#endif
