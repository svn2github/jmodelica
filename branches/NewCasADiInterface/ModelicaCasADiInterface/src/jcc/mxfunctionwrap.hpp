#ifndef MXFUNCTIONWRAP_HPP
#define MXFUNCTIONWRAP_HPP

#include "symbolic/casadi.hpp"
#include "casadi/MXFunction.h"

typedef casadi::MXFunction JMXFunction;

inline CasADi::MXFunction toMXFunction(const JMXFunction &jmx) {
    jlong p = JMXFunction::getCPtr(jmx);
    return **(CasADi::MXFunction **)&p;
}
#ifdef org_jmodelica_modelica_compiler_FFunctionDecl_H  // if JCC-generated FFunctionDecl.h included:
inline CasADi::MXFunction toMXFunction(const org::jmodelica::modelica::compiler::FFunctionDecl &ex) { return toMXFunction(ex.toMXFunction()); }
#endif
#ifdef org_jmodelica_optimica_compiler_FFunctionDecl_H  // if JCC-generated FFunctionDecl.h included:
inline CasADi::MXFunction toMXFunction(const org::jmodelica::optimica::compiler::FFunctionDecl &ex) { return toMXFunction(ex.toMXFunction()); }
#endif

inline JMXFunction toJMX(const CasADi::MXFunction &ex) {
    CasADi::MXFunction *px = new CasADi::MXFunction(ex);
    return JMXFunction(*(jlong *)&px, (jboolean)true);
}

#endif
