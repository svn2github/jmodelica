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

#ifndef MXFUNCTIONWRAP_HPP
#define MXFUNCTIONWRAP_HPP

#include "casadi/casadi.hpp"
#include "ifcasadi/JFunction.h"

typedef ifcasadi::JFunction JFunction;

inline casadi::Function toFunction(const JFunction &jmx) {
    jlong p = JFunction::getCPtr(jmx);
    return **(casadi::Function **)&p;
}
#ifdef org_jmodelica_modelica_compiler_FFunctionDecl_H  // if JCC-generated FFunctionDecl.h included:
inline casadi::Function toFunction(const org::jmodelica::modelica::compiler::FFunctionDecl &ex) { return toFunction(ex.toFunction()); }
#endif
#ifdef org_jmodelica_optimica_compiler_FFunctionDecl_H  // if JCC-generated FFunctionDecl.h included:
inline casadi::Function toFunction(const org::jmodelica::optimica::compiler::FFunctionDecl &ex) { return toFunction(ex.toFunction()); }
#endif

inline JFunction toJMX(const casadi::Function &ex) {
    casadi::Function *px = new casadi::Function(ex);
    return JFunction(*(jlong *)&px, (jboolean)true);
}

#endif
