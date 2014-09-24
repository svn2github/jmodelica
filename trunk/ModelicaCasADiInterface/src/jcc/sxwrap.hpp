/*
Copyright (C) 2013 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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
