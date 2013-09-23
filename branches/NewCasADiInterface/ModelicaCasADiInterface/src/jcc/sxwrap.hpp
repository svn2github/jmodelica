#ifndef SXWRAP_HPP
#define SXWRAP_HPP

#include "symbolic/casadi.hpp"
#include "casadi/SX.h"

typedef casadi::SX JSX;

inline CasADi::SX toSX(const JSX &jsx) {
    jlong p = JSX::getCPtr(jsx);
    return **(CasADi::SX **)&p;
}
#ifdef org_jmodelica_modelica_compiler_FExp_H  // if JCC-generated FExp.h included:
inline CasADi::SX toSX(const org::jmodelica::modelica::compiler::FExp &ex) { return toSX(ex.toSX()); }
#endif
#ifdef org_jmodelica_optimica_compiler_FExp_H  // if JCC-generated FExp.h included:
inline CasADi::SX toSX(const org::jmodelica::optimica::compiler::FExp &ex) { return toSX(ex.toSX()); }
#endif

inline JSX toJSX(const CasADi::SX &ex) {
    CasADi::SX *px = new CasADi::SX(ex);
    return JSX(*(jlong *)&px, true);
}

#endif
